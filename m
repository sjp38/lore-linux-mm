Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E2CCE6B004D
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 04:21:53 -0400 (EDT)
Received: by pxi1 with SMTP id 1so3175637pxi.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2009 01:21:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <84144f020909150030h1f9d8062sc39057b55a7ba6c0@mail.gmail.com>
References: <200909100215.36350.ngupta@vflare.org>
	 <200909100249.26284.ngupta@vflare.org>
	 <84144f020909141310y164b2d1ak44dd6945d35e6ec@mail.gmail.com>
	 <d760cf2d0909142339i30d74a9dic7ece86e7227c2e2@mail.gmail.com>
	 <84144f020909150030h1f9d8062sc39057b55a7ba6c0@mail.gmail.com>
Date: Tue, 15 Sep 2009 13:51:59 +0530
Message-ID: <d760cf2d0909150121i7f6f45b9p76f8eb89ab0d5882@mail.gmail.com>
Subject: Re: [PATCH 2/4] virtual block device driver (ramzswap)
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ed Tomlinson <edt@aei.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org, Ingo Molnar <mingo@elte.hu>, =?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

Hi Pekka,

On Tue, Sep 15, 2009 at 1:00 PM, Pekka Enberg <penberg@cs.helsinki.fi> wrot=
e:

>
> On Tue, Sep 15, 2009 at 9:39 AM, Nitin Gupta <ngupta@vflare.org> wrote:
>>> On Thu, Sep 10, 2009 at 12:19 AM, Nitin Gupta <ngupta@vflare.org> wrote=
:
>>>> +
>>>> +/* Globals */
>>>> +static int RAMZSWAP_MAJOR;
>>>> +static struct ramzswap *DEVICES;
>>>> +
>>>> +/*
>>>> + * Pages that compress to larger than this size are
>>>> + * forwarded to backing swap, if present or stored
>>>> + * uncompressed in memory otherwise.
>>>> + */
>>>> +static unsigned int MAX_CPAGE_SIZE;
>>>> +
>>>> +/* Module params (documentation at end) */
>>>> +static unsigned long NUM_DEVICES;
>>>
>>> These variable names should be in lower case.
>>
>> Global variables with lower case causes confusion.
>
> Hmm? You are not following the kernel coding style here. It's as simple a=
s that.
>

ok....all lower case/.



>>>> +static int page_zero_filled(void *ptr)
>>>> +{
>>>> + =A0 =A0 =A0 u32 pos;
>>>> + =A0 =A0 =A0 u64 *page;
>>>> +
>>>> + =A0 =A0 =A0 page =3D (u64 *)ptr;
>>>> +
>>>> + =A0 =A0 =A0 for (pos =3D 0; pos !=3D PAGE_SIZE / sizeof(*page); pos+=
+) {
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page[pos])
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>>> + =A0 =A0 =A0 }
>>>> +
>>>> + =A0 =A0 =A0 return 1;
>>>> +}
>>>
>>> This looks like something that could be in lib/string.c.
>>>
>>> /me looks
>>>
>>> There's strspn so maybe you could introduce a memspn equivalent.
>>
>> Maybe this is just too specific to this driver. Who else will use it?
>> So, this simple function should stay within this driver only. If it
>> finds more user, we can them move it to lib/string.c.
>>
>> If I now move it to string.c I am sure I will get reverse argument
>> from someone else:
>> "currently, it has no other users so bury it with this driver only".
>
> How can you be sure about that? If you don't want to move it to
> generic code, fine, but the above argumentation doesn't really
> convince me. Check the git logs to see that this is *exactly* how new
> functions get added to lib/string.c. It's not always a question of two
> or more users, it's also an API issue. It doesn't make sense to put
> helpers in driver code where they don't belong (and won't be
> discovered if they're needed somewhere else).
>

I don't want to ponder too much about this point now. If you all are okay
with keeping this function buried in driver, I will do so. I'm almost tired
maintaining this compcache thing outside of mainline.


>>>> +/*
>>>> + * Given <pagenum, offset> pair, provide a dereferencable pointer.
>>>> + */
>>>> +static void *get_ptr_atomic(struct page *page, u16 offset, enum km_ty=
pe type)
>>>> +{
>>>> + =A0 =A0 =A0 unsigned char *base;
>>>> +
>>>> + =A0 =A0 =A0 base =3D kmap_atomic(page, type);
>>>> + =A0 =A0 =A0 return base + offset;
>>>> +}
>>>> +
>>>> +static void put_ptr_atomic(void *ptr, enum km_type type)
>>>> +{
>>>> + =A0 =A0 =A0 kunmap_atomic(ptr, type);
>>>> +}
>>>
>>> These two functions also appear in xmalloc. It's probably best to just
>>> kill the wrappers and use kmap/kunmap directly.
>>
>> Wrapper for kmap_atomic is nice as spreading:
>> kmap_atomic(page, KM_USER0,1) + offset everywhere looks worse.
>> What is the problem if these little 1-liner wrappers are repeated in
>> xvmalloc too?
>> To me, they just add some clarity.
>
> To me, they look like useless wrappers which we don't do in the kernel.
>

I will see how it looks without wrappers and depending on that I will decid=
e
if keeping this wrapper is better. Again, I don't want to ponder too much a=
bout
this and will open code this if so required.


>>>> +static void ramzswap_flush_dcache_page(struct page *page)
>>>> +{
>>>> +#ifdef CONFIG_ARM
>>>> + =A0 =A0 =A0 int flag =3D 0;
>>>> + =A0 =A0 =A0 /*
>>>> + =A0 =A0 =A0 =A0* Ugly hack to get flush_dcache_page() work on ARM.
>>>> + =A0 =A0 =A0 =A0* page_mapping(page) =3D=3D NULL after clearing this =
swap cache flag.
>>>> + =A0 =A0 =A0 =A0* Without clearing this flag, flush_dcache_page() wil=
l simply set
>>>> + =A0 =A0 =A0 =A0* "PG_dcache_dirty" bit and return.
>>>> + =A0 =A0 =A0 =A0*/
>>>> + =A0 =A0 =A0 if (PageSwapCache(page)) {
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 flag =3D 1;
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageSwapCache(page);
>>>> + =A0 =A0 =A0 }
>>>> +#endif
>>>> + =A0 =A0 =A0 flush_dcache_page(page);
>>>> +#ifdef CONFIG_ARM
>>>> + =A0 =A0 =A0 if (flag)
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageSwapCache(page);
>>>> +#endif
>>>> +}
>>>
>>> The above CONFIG_ARM magic really has no place in drivers/block.
>>>
>>
>> Please read the comment above this hack to see why its needed. Also,
>> for details see this mail:
>> http://www.linux-mips.org/archives/linux-mips/2008-11/msg00038.html
>>
>> No one replied to above mail. So, I though just to temporarily introduce=
 this
>> hack while someone makes a proper fix for ARM (I will probably ping ARM/=
MIPS
>> folks again for this).
>>
>> Without this hack, ramzswap simply won't work on ARM. See:
>> http://code.google.com/p/compcache/issues/detail?id=3D33
>>
>> So, its extremely difficult to wait for the _proper_ fix.
>
> Then make ramzswap depend on !CONFIG_ARM. In any case, CONFIG_ARM bits
> really don't belong into drivers/block.
>

ARM is an extremely important user of compcache -- Its currently being
tested (unofficially)
on Android, Nokia etc.


>>>> +
>>>> + =A0 =A0 =A0 trace_mark(ramzswap_lock_wait, "ramzswap_lock_wait");
>>>> + =A0 =A0 =A0 mutex_lock(&rzs->lock);
>>>> + =A0 =A0 =A0 trace_mark(ramzswap_lock_acquired, "ramzswap_lock_acquir=
ed");
>>>
>>> Hmm? What's this? I don't think you should be doing ad hoc
>>> trace_mark() in driver code.
>>
>> This is not ad hoc. It is to see contention over this lock which I belie=
ve is a
>> major bottleneck even on dual-cores. I need to keep this to measure impr=
ovements
>> as I gradually make this locking more fine grained (using per-cpu buffer=
 etc).
>
> It is ad hoc. Talk to the ftrace folks how to do it properly. I'd keep
> those bits out-of-tree until the issue is resolved, really.
>

/me is speechless.


>>>> + =A0 =A0 =A0 rzs->compress_buffer =3D kzalloc(2 * PAGE_SIZE, GFP_KERN=
EL);
>>>
>>> Use alloc_pages(__GFP_ZERO) here?
>>
>> alloc pages then map them (i.e. vmalloc). What did we gain? With
>> vmalloc, pages might
>> not be physically contiguous which might hurt performance as
>> compressor runs over this buffer.
>>
>> So, use kzalloc().
>
> I don't know what you're talking about. kzalloc() calls
> __get_free_pages() directly for your allocation. You probably should
> use that directly.
>

What is wrong with kzalloc? I'm wholly totally stumped.
I respect your time reviewing the code but this really goes over my head.
We can continue arguing about get_pages vs kzalloc but I doubt if we will
gain anything out of it.


>>>> +/* Debugging and Stats */
>>>> +#define NOP =A0 =A0do { } while (0)
>>>
>>> Huh? Drop this.
>>
>> This is more of individual taste. This makes the code look cleaner to me=
.
>> I hope its not considered 'over decoration'.
>
> Hey, the kernel doesn't care about your or my individual taste. I'm
> pointing out things that I think fall in the category of "we don't do
> shit like this in the kernel", not things _I_ personally find
> annoying. If you want to ignore those comments, fine, that's your
> prerogative. However, people usually have better results in getting
> their code merged when they listen to kernel developers who take the
> time to review their code.
>

Yikes! no NOP. okay.


Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
