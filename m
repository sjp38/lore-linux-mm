Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DF12F6B004D
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 02:39:36 -0400 (EDT)
Received: by pzk26 with SMTP id 26so2969335pzk.27
        for <linux-mm@kvack.org>; Mon, 14 Sep 2009 23:39:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <84144f020909141310y164b2d1ak44dd6945d35e6ec@mail.gmail.com>
References: <200909100215.36350.ngupta@vflare.org>
	 <200909100249.26284.ngupta@vflare.org>
	 <84144f020909141310y164b2d1ak44dd6945d35e6ec@mail.gmail.com>
Date: Tue, 15 Sep 2009 12:09:38 +0530
Message-ID: <d760cf2d0909142339i30d74a9dic7ece86e7227c2e2@mail.gmail.com>
Subject: Re: [PATCH 2/4] virtual block device driver (ramzswap)
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ed Tomlinson <edt@aei.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

Hi Pekka,

Thanks for review. My comments inline.

On Tue, Sep 15, 2009 at 1:40 AM, Pekka Enberg <penberg@cs.helsinki.fi> wrot=
e:
>
> I am not a block driver expert but here are some comments on the code
> that probably need to be addressed before merging.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Pekka

>
> On Thu, Sep 10, 2009 at 12:19 AM, Nitin Gupta <ngupta@vflare.org> wrote:
>> +
>> +/* Globals */
>> +static int RAMZSWAP_MAJOR;
>> +static struct ramzswap *DEVICES;
>> +
>> +/*
>> + * Pages that compress to larger than this size are
>> + * forwarded to backing swap, if present or stored
>> + * uncompressed in memory otherwise.
>> + */
>> +static unsigned int MAX_CPAGE_SIZE;
>> +
>> +/* Module params (documentation at end) */
>> +static unsigned long NUM_DEVICES;
>
> These variable names should be in lower case.
>

Global variables with lower case causes confusion.


>> +
>> +/* Function declarations */
>> +static int __init ramzswap_init(void);
>> +static int ramzswap_ioctl(struct block_device *, fmode_t,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned, unsigned long);
>> +static int setup_swap_header(struct ramzswap *, union swap_header *);
>> +static void ramzswap_set_memlimit(struct ramzswap *, size_t);
>> +static void ramzswap_set_disksize(struct ramzswap *, size_t);
>> +static void reset_device(struct ramzswap *rzs);
>
> It's preferable not to use forward declarations in new kernel code.
>

okay, I will rearrange functions to avoid this.


>> +static int test_flag(struct ramzswap *rzs, u32 index, enum rzs_pageflag=
s flag)
>> +{
>> + =A0 =A0 =A0 return rzs->table[index].flags & BIT(flag);
>> +}
>> +
>> +static void set_flag(struct ramzswap *rzs, u32 index, enum rzs_pageflag=
s flag)
>> +{
>> + =A0 =A0 =A0 rzs->table[index].flags |=3D BIT(flag);
>> +}
>> +
>> +static void clear_flag(struct ramzswap *rzs, u32 index,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 enum rzs_pageflags flag)
>> +{
>> + =A0 =A0 =A0 rzs->table[index].flags &=3D ~BIT(flag);
>> +}
>
> These function names could use a ramzswap specific prefix.

okay.

>
>> +
>> +static int page_zero_filled(void *ptr)
>> +{
>> + =A0 =A0 =A0 u32 pos;
>> + =A0 =A0 =A0 u64 *page;
>> +
>> + =A0 =A0 =A0 page =3D (u64 *)ptr;
>> +
>> + =A0 =A0 =A0 for (pos =3D 0; pos !=3D PAGE_SIZE / sizeof(*page); pos++)=
 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page[pos])
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 return 1;
>> +}
>
> This looks like something that could be in lib/string.c.
>
> /me looks
>
> There's strspn so maybe you could introduce a memspn equivalent.
>


Maybe this is just too specific to this driver. Who else will use it?
So, this simple function should stay within this driver only. If it
finds more user,
we can them move it to lib/string.c.

If I now move it to string.c I am sure I will get reverse argument
from someone else:
"currently, it has no other users so bury it with this driver only".


>> +
>> +/*
>> + * Given <pagenum, offset> pair, provide a dereferencable pointer.
>> + */
>> +static void *get_ptr_atomic(struct page *page, u16 offset, enum km_type=
 type)
>> +{
>> + =A0 =A0 =A0 unsigned char *base;
>> +
>> + =A0 =A0 =A0 base =3D kmap_atomic(page, type);
>> + =A0 =A0 =A0 return base + offset;
>> +}
>> +
>> +static void put_ptr_atomic(void *ptr, enum km_type type)
>> +{
>> + =A0 =A0 =A0 kunmap_atomic(ptr, type);
>> +}
>
> These two functions also appear in xmalloc. It's probably best to just
> kill the wrappers and use kmap/kunmap directly.
>

Wrapper for kmap_atomic is nice as spreading:
kmap_atomic(page, KM_USER0,1) + offset everywhere looks worse.
What is the problem if these little 1-liner wrappers are repeated in
xvmalloc too?
To me, they just add some clarity.


>> +
>> +static void ramzswap_flush_dcache_page(struct page *page)
>> +{
>> +#ifdef CONFIG_ARM
>> + =A0 =A0 =A0 int flag =3D 0;
>> + =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0* Ugly hack to get flush_dcache_page() work on ARM.
>> + =A0 =A0 =A0 =A0* page_mapping(page) =3D=3D NULL after clearing this sw=
ap cache flag.
>> + =A0 =A0 =A0 =A0* Without clearing this flag, flush_dcache_page() will =
simply set
>> + =A0 =A0 =A0 =A0* "PG_dcache_dirty" bit and return.
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 if (PageSwapCache(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 flag =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageSwapCache(page);
>> + =A0 =A0 =A0 }
>> +#endif
>> + =A0 =A0 =A0 flush_dcache_page(page);
>> +#ifdef CONFIG_ARM
>> + =A0 =A0 =A0 if (flag)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageSwapCache(page);
>> +#endif
>> +}
>
> The above CONFIG_ARM magic really has no place in drivers/block.
>

Please read the comment above this hack to see why its needed. Also,
for details see this mail:
http://www.linux-mips.org/archives/linux-mips/2008-11/msg00038.html

No one replied to above mail. So, I though just to temporarily introduce th=
is
hack while someone makes a proper fix for ARM (I will probably ping ARM/MIP=
S
folks again for this).

Without this hack, ramzswap simply won't work on ARM. See:
http://code.google.com/p/compcache/issues/detail?id=3D33

So, its extremely difficult to wait for the _proper_ fix.


>> +
>> + =A0 =A0 =A0 pr_debug(C "extent: [%lu, %lu] %lu\n", phy_pagenum,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_pagenum + num_pages - 1, num_pages);
>
> What's this "C" thing everywhere? A subsystem prefix? Shouldn't you
> override pr_fmt() instead?
>

Yes, "C" is subsystem prefix. Will now override pr_fmt() instead.


>> +
>> + =A0 =A0 =A0 trace_mark(ramzswap_lock_wait, "ramzswap_lock_wait");
>> + =A0 =A0 =A0 mutex_lock(&rzs->lock);
>> + =A0 =A0 =A0 trace_mark(ramzswap_lock_acquired, "ramzswap_lock_acquired=
");
>
> Hmm? What's this? I don't think you should be doing ad hoc
> trace_mark() in driver code.
>

This is not ad hoc. It is to see contention over this lock which I believe =
is a
major bottleneck even on dual-cores. I need to keep this to measure improve=
ments
as I gradually make this locking more fine grained (using per-cpu buffer et=
c).



>> +#if 0
>> + =A0 =A0 =A0 /* Back-reference needed for memory defragmentation */
>> + =A0 =A0 =A0 if (!test_flag(rzs, index, RZS_UNCOMPRESSED)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zheader =3D (struct zobj_header *)cmem;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zheader->table_idx =3D index;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cmem +=3D sizeof(*zheader);
>> + =A0 =A0 =A0 }
>> +#endif
>
> Drop the above dead code?


This is a reminder for me that every object has to contain this header
ultimately
and hence object data does not start immediately from start of chunk.

More than the dead code, the comment adds more value to it. So lets keep it=
.


>
>> +
>> + =A0 =A0 =A0 memcpy(cmem, src, clen);
>> +
>> + =A0 =A0 =A0 put_ptr_atomic(cmem, KM_USER1);
>> + =A0 =A0 =A0 if (unlikely(test_flag(rzs, index, RZS_UNCOMPRESSED)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_ptr_atomic(src, KM_USER0);
>> +
>> + =A0 =A0 =A0 /* Update stats */
>> + =A0 =A0 =A0 rzs->stats.compr_size +=3D clen;
>> + =A0 =A0 =A0 stat_inc(rzs->stats.pages_stored);
>> + =A0 =A0 =A0 stat_inc_if_less(rzs->stats.good_compress, clen, PAGE_SIZE=
 / 2 + 1);
>> +
>> + =A0 =A0 =A0 mutex_unlock(&rzs->lock);
>> +
>> + =A0 =A0 =A0 set_bit(BIO_UPTODATE, &bio->bi_flags);
>> + =A0 =A0 =A0 bio_endio(bio, 0);
>> + =A0 =A0 =A0 return 0;
>> +
>> +out:
>> + =A0 =A0 =A0 if (fwd_write_request) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat_inc(rzs->stats.bdev_num_writes);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bio->bi_bdev =3D rzs->backing_swap;
>> +#if 0
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* TODO: We currently have linear mappin=
g of ramzswap and
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* backing swap sectors. This is not des=
ired since we want
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to optimize writes to backing swap to=
 minimize disk seeks
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* or have effective wear leveling (for =
SSDs). Also, a
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* non-linear mapping is required to imp=
lement compressed
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* on-disk swapping.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bio->bi_sector =3D get_backing_swap_pag=
e()
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 << SECTORS_PER_PAGE_SHIFT;
>> +#endif
>
> This too?
>

Again, I want to retain this comment. Its very important for me. So, I pref=
er to
keep this small bit of dead code.


>> +static int ramzswap_ioctl_init_device(struct ramzswap *rzs)
>> +{
>> + =A0 =A0 =A0 int ret;
>> + =A0 =A0 =A0 size_t num_pages, totalram_bytes;
>> + =A0 =A0 =A0 struct sysinfo i;
>> + =A0 =A0 =A0 struct page *page;
>> + =A0 =A0 =A0 union swap_header *swap_header;
>> +
>> + =A0 =A0 =A0 if (rzs->init_done) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info(C "Device already initialized!\n")=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 ret =3D setup_backing_swap(rzs);
>> + =A0 =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;
>> +
>> + =A0 =A0 =A0 si_meminfo(&i);
>> + =A0 =A0 =A0 /* Here is a trivia: guess unit used for i.totalram !! */
>> + =A0 =A0 =A0 totalram_bytes =3D i.totalram << PAGE_SHIFT;
>
> You can use totalram_pages here. OTOH, I'm not sure why the driver
> needs this information. Hmm?
>

The driver sets 'disksize' as 25% of RAM by default. So, it needs to know
how much RAM the system has.

>> +
>> + =A0 =A0 =A0 if (rzs->backing_swap)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ramzswap_set_memlimit(rzs, totalram_bytes)=
;
>> + =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ramzswap_set_disksize(rzs, totalram_bytes)=
;
>> +
>> + =A0 =A0 =A0 rzs->compress_workmem =3D kzalloc(LZO1X_MEM_COMPRESS, GFP_=
KERNEL);
>> + =A0 =A0 =A0 if (rzs->compress_workmem =3D=3D NULL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err(C "Error allocating compressor work=
ing memory!\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 rzs->compress_buffer =3D kzalloc(2 * PAGE_SIZE, GFP_KERNEL=
);
>
> Use alloc_pages(__GFP_ZERO) here?
>

alloc pages then map them (i.e. vmalloc). What did we gain? With
vmalloc, pages might
not be physically contiguous which might hurt performance as
compressor runs over this buffer.

So, use kzalloc().


>> diff --git a/drivers/block/ramzswap/ramzswap_drv.h b/drivers/block/ramzs=
wap/ramzswap_drv.h
>> new file mode 100644
>> index 0000000..7f77edc
>> --- /dev/null
>> +++ b/drivers/block/ramzswap/ramzswap_drv.h
>
>> +
>> +#define SECTOR_SHIFT =A0 =A0 =A0 =A0 =A0 9
>> +#define SECTOR_SIZE =A0 =A0 =A0 =A0 =A0 =A0(1 << SECTOR_SHIFT)
>> +#define SECTORS_PER_PAGE_SHIFT (PAGE_SHIFT - SECTOR_SHIFT)
>> +#define SECTORS_PER_PAGE =A0 =A0 =A0 (1 << SECTORS_PER_PAGE_SHIFT)
>
> Don't we have these defines somewhere in include/linux?
>

I couldn't find something equivalent. At least swap code hard codes a
value of 9.
So, a #define looks somewhat better.


>> +
>> +/* Message prefix */
>> +#define C "ramzswap: "
>
> Use pr_fmt() instead.

okay.


>
>> +
>> +/* Debugging and Stats */
>> +#define NOP =A0 =A0do { } while (0)
>
> Huh? Drop this.

This is more of individual taste. This makes the code look cleaner to me.
I hope its not considered 'over decoration'.


>
>> +
>> +#if defined(CONFIG_BLK_DEV_RAMZSWAP_STATS)
>> +#define STATS
>> +#endif
>
> Why can't you rename that to CONFIG_RAMZSWAP_STATS and use that
> instead of the very generic STATS?
>

Everything in drivers/block/Kconfig has BLK_DEV_ as prefix
BLK_DEV_RAM
BLK_DEV_RAM_COUNT
BLK_DEV_RAM_SIZE

and following the pattern:

BLK_DEV_RAMZSWAP
BLK_DEV_RAMZSWAP_STATS


STATS is just a convenient shortcut for very longish BLK_DEV_RAMZSWAP_STATS
but I see this not used very often, so this shortcut is really not
needed. I will now directly
use the long version.


>> +
>> +#if defined(STATS)
>> +#define stat_inc(stat) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((stat)++)
>> +#define stat_dec(stat) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((stat)--)
>> +#define stat_inc_if_less(stat, val1, val2) \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((stat) +=
=3D ((val1) < (val2) ? 1 : 0))
>> +#define stat_dec_if_less(stat, val1, val2) \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((stat) -=
=3D ((val1) < (val2) ? 1 : 0))
>> +#else =A0/* STATS */
>> +#define stat_inc(x) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NOP
>> +#define stat_dec(x) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NOP
>> +#define stat_inc_if_less(x, v1, v2) =A0 =A0NOP
>> +#define stat_dec_if_less(x, v1, v2) =A0 =A0NOP
>> +#endif /* STATS */
>
> Why do you need inc_if_less() and dec_if_less()?

No good reason. I will get rid of inc/dec_if_less().


> And why are these not static inlines?
>

stats variables exist only when 'STATS' is defined. So, every call to stati=
c
inline will have to be enclosed within '#if defined (STATS)'. Thus we use
macros instead.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
