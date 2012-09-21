Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 0494D6B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 15:14:56 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <15c1d12a-0e29-478f-97e0-ee4063e2cba5@default>
Date: Fri, 21 Sep 2012 12:14:39 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120921161252.GV11266@suse.de>
In-Reply-To: <20120921161252.GV11266@suse.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hi Mel --

Wow!  An incredibly wonderfully detailed response!  Thank you very
much for taking the time to read through all of zcache!

Your comments run the gamut from nit and code style, to design,
architecture and broad naming.  Until the choice-of-codebase issue
is resolved, I'll avoid the nits and codestyle comments and respond
to the higher level strategic and design questions.  Since a couple
of your questions are repeated and the specific code which provoked
your question is not isolated, I hope it is OK if I answer those
first out-of-context from your original comments in the code.
(This should also make this easier to read and to extract optimal
meaning, for you and for posterity.)

> That said, I worry that this has bounced around a lot and as Dan (the
> original author) has a rewrite. I'm wary of spending too much time on thi=
s
> at all. Is Dan's new code going to replace this or what? It'd be nice to
> find a definitive answer on that.

Replacing this code was my intent, but that was blocked.  IMHO zcache2
is _much_ better than the "demo version" of zcache (aka zcache1).
Hopefully a middle ground can be reached.  I've proposed one privately
offlist.

Seth, please feel free to augment or correct anything below, or
respond to anything I haven't commented on.

> Anyway, here goes

Repeated comments answered first out-of-context:

1) The interrupt context for zcache (and any tmem backend) is imposed
   by the frontend callers.  Cleancache_put [see naming comment below]
   is always called with interrupts disabled.  Cleancache_flush is
   sometimes called with interrupts disabled and sometimes not.
   Cleancache_get is never called in an atomic context.  (I think)
   frontswap_get/put/flush are never called in an atomic context but
   sometimes with the swap_lock held. Because it is dangerous (true?)
   for code to sometimes/not be called in atomic context, much of the
   code in zcache and tmem is forced into atomic context.  BUT Andrea
   observed that there are situations where asynchronicity would be
   preferable and, it turns out that cleancache_get and frontswap_get
   are never called in atomic context.  Zcache2/ramster takes advantage of
   that, and a future KVM backend may want to do so as well.  However,
   the interrupt/atomicity model and assumptions certainly does deserve
   better documentation.

2) The naming of the core tmem functions (put, get, flush) has been
   discussed endlessly, everyone has a different opinion, and the
   current state is a mess: cleancache, frontswap, and the various
   backends are horribly inconsistent.   IMHO, the use of "put"
   and "get" for reference counting is a historical accident, and
   the tmem ABI names were chosen well before I understood the historical
   precedence and the potential for confusion by kernel developers.
   So I don't have a good answer... I'd prefer the ABI-documented
   names, but if they are unacceptable, at least we need to agree
   on a consistent set of names and fix all references in all
   the various tmem parts (and possibly Xen and the kernel<->Xen
   ABI as well).

The rest of my comments/replies are in context.

> > +/*
> > + * A tmem host implementation must use this function to register
> > + * callbacks for a page-accessible memory (PAM) implementation
> > + */
> > +static struct tmem_pamops tmem_pamops;
> > +
> > +void tmem_register_pamops(struct tmem_pamops *m)
> > +{
> > +=09tmem_pamops =3D *m;
> > +}
> > +
>=20
> This implies that this can only host one client  at a time. I suppose
> that's ok to start with but is there ever an expectation that zcache +
> something else would be enabled at the same time?

There was some thought that zcache and Xen (or KVM) might somehow "chain"
the implementations.
=20
> > +/*
> > + * A tmem_obj contains a radix-tree-like tree in which the intermediat=
e
> > + * nodes are called tmem_objnodes.  (The kernel lib/radix-tree.c imple=
mentation
> > + * is very specialized and tuned for specific uses and is not particul=
arly
> > + * suited for use from this code, though some code from the core algor=
ithms has
>=20
> This is a bit vague. It asserts that lib/radix-tree is unsuitable but
> not why. I skipped over most of the implementation to be honest.

IIRC, lib/radix-tree is highly tuned for mm's needs.  Things like
tagging and rcu weren't a good fit for tmem, and new things like calling
a different allocator needed to be added.  In the long run it might
be possible for the lib version to serve both needs, but the impediment
and aggravation of merging all necessary changes into lib seemed a high pri=
ce
to pay for a hundred lines of code implementing a variation of a widely
documented tree algorithm.

> > + * These "tmem core" operations are implemented in the following funct=
ions.
>=20
> More nits. As this defines a boundary between two major components it
> probably should have its own Documentation/ entry and the APIs should hav=
e
> kernel doc comments.

Agreed.

> > + * a corner case: What if a page with matching handle already exists i=
n
> > + * tmem?  To guarantee coherency, one of two actions is necessary: Eit=
her
> > + * the data for the page must be overwritten, or the page must be
> > + * "flushed" so that the data is not accessible to a subsequent "get".
> > + * Since these "duplicate puts" are relatively rare, this implementati=
on
> > + * always flushes for simplicity.
> > + */
>=20
> At first glance that sounds really dangerous. If two different users can =
have
> the same oid for different data, what prevents the wrong data being fetch=
ed?
> From this level I expect that it's something the layers above it have to
> manage and in practice they must be preventing duplicates ever happening
> but I'm guessing. At some point it would be nice if there was an example
> included here explaining why duplicates are not a bug.

VFS decides when to call cleancache and dups do happen.  Honestly, I don't
know why they happen (though Chris Mason, who wrote the cleancache hooks,
may know) they happen, but the above coherency rules for backend implementa=
tion
always work.  The same is true of frontswap.

> > +int tmem_replace(struct tmem_pool *pool, struct tmem_oid *oidp,
> > +=09=09=09uint32_t index, void *new_pampd)
> > +{
> > +=09struct tmem_obj *obj;
> > +=09int ret =3D -1;
> > +=09struct tmem_hashbucket *hb;
> > +
> > +=09hb =3D &pool->hashbucket[tmem_oid_hash(oidp)];
> > +=09spin_lock(&hb->lock);
> > +=09obj =3D tmem_obj_find(hb, oidp);
> > +=09if (obj =3D=3D NULL)
> > +=09=09goto out;
> > +=09new_pampd =3D tmem_pampd_replace_in_obj(obj, index, new_pampd);
> > +=09ret =3D (*tmem_pamops.replace_in_obj)(new_pampd, obj);
> > +out:
> > +=09spin_unlock(&hb->lock);
> > +=09return ret;
> > +}
> > +
>=20
> Nothin in this patch uses this. It looks like ramster would depend on it
> but at a glance, ramster seems to have its own copy of the code. I guess
> this is what Dan was referring to as the fork and at some point that need=
s
> to be resolved. Here, it looks like dead code.

Yep, this was a first step toward supporting ramster (and any other
future asynchronous-get tmem backends).

> > +static inline void tmem_oid_set_invalid(struct tmem_oid *oidp)
> > +
> > +static inline bool tmem_oid_valid(struct tmem_oid *oidp)
> > +
> > +static inline int tmem_oid_compare(struct tmem_oid *left,
> > +=09=09=09=09=09struct tmem_oid *right)
> > +{
> > +}
>=20
> Holy Branches Batman!
>=20
> Bit of a jumble but works at least. Nits: mixes ret =3D and returns
> mid-way. Could have been implemented with a while loop. Only has one
> caller and should have been in the C file that uses it. There was no need
> to explicitely mark it inline either with just one caller.

It was put here to group object operations together sort
of as if it is an abstract datatype.  No objections
to moving it.

> > +++ b/drivers/mm/zcache/zcache-main.c
> > + *
> > + * Zcache provides an in-kernel "host implementation" for transcendent=
 memory
> > + * and, thus indirectly, for cleancache and frontswap.  Zcache include=
s two
> > + * page-accessible memory [1] interfaces, both utilizing the crypto co=
mpression
> > + * API:
> > + * 1) "compression buddies" ("zbud") is used for ephemeral pages
> > + * 2) zsmalloc is used for persistent pages.
> > + * Xvmalloc (based on the TLSF allocator) has very low fragmentation
> > + * so maximizes space efficiency, while zbud allows pairs (and potenti=
ally,
> > + * in the future, more than a pair of) compressed pages to be closely =
linked
> > + * so that reclaiming can be done via the kernel's physical-page-orien=
ted
> > + * "shrinker" interface.
> > + *
>=20
> Doesn't actually explain why zbud is good for one and zsmalloc good for t=
he other.

There's been extensive discussion of that elsewhere and the
equivalent description in zcache2 is better, but I agree this
needs to be in Documentation/, once the zcache1/zcache2 discussion settles.

> > +#if 0
> > +/* this is more aggressive but may cause other problems? */
> > +#define ZCACHE_GFP_MASK=09(GFP_ATOMIC | __GFP_NORETRY | __GFP_NOWARN)
>=20
> Why is this "more agressive"? If anything it's less aggressive because it=
'll
> bail if there is no memory available. Get rid of this.

My understanding (from Jeremy Fitzhardinge I think) was that GFP_ATOMIC
would use a special reserve of pages which might lead to OOMs.
More experimentation may be warranted.

> > +#else
> > +#define ZCACHE_GFP_MASK \
> > +=09(__GFP_FS | __GFP_NORETRY | __GFP_NOWARN | __GFP_NOMEMALLOC)
> > +#endif
> > +
> > +#define MAX_CLIENTS 16
>=20
> Seems a bit arbitrary. Why 16?

Sasha Levin posted a patch to fix this but it was tied in to
the proposed KVM implementation, so was never merged.

> > +#define LOCAL_CLIENT ((uint16_t)-1)
> > +
> > +MODULE_LICENSE("GPL");
> > +
> > +struct zcache_client {
> > +=09struct idr tmem_pools;
> > +=09struct zs_pool *zspool;
> > +=09bool allocated;
> > +=09atomic_t refcount;
> > +};
>=20
> why is "allocated" needed. Is the refcount not enough to determine if thi=
s
> client is in use or not?

May be a historical accident.  Deserves a second look.

> > + * Compression buddies ("zbud") provides for packing two (or, possibly
> > + * in the future, more) compressed ephemeral pages into a single "raw"
> > + * (physical) page and tracking them with data structures so that
> > + * the raw pages can be easily reclaimed.
> > + *
>=20
> Ok, if I'm reading this right it implies that a page must at least compre=
ss
> by 50% before zcache even accepts the page.

NO! Zbud matches up pages that compress well with those that don't.
There's a lot more detailed description of this in zcache2.

> > +static atomic_t zcache_zbud_curr_raw_pages;
> > +static atomic_t zcache_zbud_curr_zpages;
>=20
> Should not have been necessary to make these atomics. Probably protected
> by zbpg_unused_list_spinlock or something similar.

Agreed, but it gets confusing when monitoring zcache
if certain key counters go negative.  Ideally this
should all be eventually tied to some runtime debug flag
but it's not clear yet what counters might be used
by future userland software.
=20
> > +static unsigned long zcache_zbud_curr_zbytes;
>=20
> Overkill, this is just
>=20
> zcache_zbud_curr_raw_pages << PAGE_SHIFT

No, it allows a measure of the average compression,
irrelevant of the number of pageframes required.
=20
> > +static unsigned long zcache_zbud_cumul_zpages;
> > +static unsigned long zcache_zbud_cumul_zbytes;
> > +static unsigned long zcache_compress_poor;
> > +static unsigned long zcache_mean_compress_poor;
>=20
> In general the stats keeping is going to suck on larger machines as these
> are all shared writable cache lines. You might be able to mitigate the
> impact in the future by moving these to vmstat. Maybe it doesn't matter
> as such - it all depends on what velocity pages enter and leave zcache.
> If that velocity is high, maybe the performance is shot anyway.

Agreed.  Velocity is on the order of the number of disk
pages read per second plus pswpin+pswpout per second.
It's not clear yet if that is high enough for the
stat counters to affect performance but it seems unlikely
except possibly on huge NUMA machines.

> > +static inline unsigned zbud_max_buddy_size(void)
> > +{
> > +=09return MAX_CHUNK << CHUNK_SHIFT;
> > +}
> > +
>=20
> Is the max size not half of MAX_CHUNK as the page is split into two buddi=
es?

No, see above.

> > +=09if (zbpg =3D=3D NULL)
> > +=09=09/* none on zbpg list, try to get a kernel page */
> > +=09=09zbpg =3D zcache_get_free_page();
>=20
> So zcache_get_free_page() is getting a preloaded page from a per-cpu maga=
zine
> and that thing blows up if there is no page available. This implies that
> preemption must be disabled for the entire putting of a page into zcache!
>
> > +=09if (likely(zbpg !=3D NULL)) {
>=20
> It's not just likely, it's impossible because if it's NULL,
> zcache_get_free_page() will already have BUG().
>=20
> If it's the case that preemption is *not* disabled and the process gets
> scheduled to a CPU that has its magazine consumed then this will blow up
> in some cases.
>=20
> Scary.

This code is all redesigned/rewritten in zcache2.

> Ok, so if this thing fails to allocate a page then what prevents us getti=
ng into
> a situation where the zcache grows to a large size and we cannot take dec=
ompress
> anything in it because we cannot allocate a page here?
>=20
> It looks like this could potentially deadlock the system unless it was po=
ssible
> to either discard zcache data and reconstruct it from information on disk=
.
> It feels like something like a mempool needs to exist that is used to for=
cibly
> shrink the zcache somehow but I can't seem to find where something like t=
hat happens.
>=20
> Where is it or is there a risk of deadlock here?

I am fairly sure there is no risk of deadlock here.  The callers
to cleancache_get and frontswap_get always provide a struct page
for the decompression.  Cleancache pages in zcache can always
be discarded whenever required.

The risk for OOMs does exist when we start trying to force
frontswap-zcache zpages out to the swap disk.  This work
is currently in progress and I hope to have a patch for
review soon.

> > +=09BUG_ON(!irqs_disabled());
> > +=09if (unlikely(dmem =3D=3D NULL))
> > +=09=09goto out;  /* no buffer or no compressor so can't compress */
> > +=09*out_len =3D PAGE_SIZE << ZCACHE_DSTMEM_ORDER;
> > +=09from_va =3D kmap_atomic(from);
>=20
> Ok, so I am running out of beans here but this triggered alarm bells. Is
> zcache stored in lowmem? If so, then it might be a total no-go on 32-bit
> systems if pages from highmem cause increased low memory pressure to put
> the page into zcache.

Personally, I'm neither an expert nor an advocate of lowmem systems
but Seth said he has tested zcache ("demo version") there.

> > +=09mb();
>=20
> .... Why?

Historical accident...  I think this was required in the Xen version.
=20
> > +=09if (nr >=3D 0) {
> > +=09=09if (!(gfp_mask & __GFP_FS))
> > +=09=09=09/* does this case really need to be skipped? */
> > +=09=09=09goto out;
>=20
> Answer that question. It's not obvious at all why zcache cannot handle
> !__GFP_FS. You're not obviously recursing into a filesystem.

Yep, this is a remaining loose end.  The documentation
of this (in the shrinker code) was pretty vague so this
is "safety" code that probably should be removed after
a decent test proves it can be.

> > +static int zcache_get_page(int cli_id, int pool_id, struct tmem_oid *o=
idp,
> > +=09=09=09=09uint32_t index, struct page *page)
> > +{
> > +=09struct tmem_pool *pool;
> > +=09int ret =3D -1;
> > +=09unsigned long flags;
> > +=09size_t size =3D PAGE_SIZE;
> > +
> > +=09local_irq_save(flags);
>=20
> Why do interrupts have to be disabled?
>=20
> This makes the locking between tmem and zcache very confusing unfortunate=
ly
> because I cannot decide if tmem indirectly depends on disabled interrupts
> or not. It's also not clear why an interrupt handler would be trying to
> get/put pages in tmem.

Yes, irq disablement goes away for gets in zcache2.

> > +=09pool =3D zcache_get_pool_by_id(cli_id, pool_id);
> > +=09if (likely(pool !=3D NULL)) {
> > +=09=09if (atomic_read(&pool->obj_count) > 0)
> > +=09=09=09ret =3D tmem_get(pool, oidp, index, (char *)(page),
> > +=09=09=09=09=09&size, 0, is_ephemeral(pool));
>=20
> It looks like you are disabling interrupts to avoid racing on that atomic
> update.
>=20
> This feels very shaky and the layering is being violated. You should
> unconditionally call into tmem_get and not worry about the pool count at
> all. tmem_get should then check the count under the pool lock and make
> obj_count a normal counter instead of an atomic.
>=20
> The same comment applies to all the other obj_count locations.

This isn't the reason for irq disabling, see previous.
It's possible atomic obj_count can go away as it may
have only been necessary in a previous tmem locking design.

> > +=09/* wait for pool activity on other cpus to quiesce */
> > +=09while (atomic_read(&pool->refcount) !=3D 0)
> > +=09=09;
>=20
> There *HAS* to be a better way of waiting before destroying the pool
> than than a busy wait.

Most probably.  Pool destruction is relatively very rare (umount and
swapoff), so fixing/testing this has never bubbled up to the top
of the list.

> Feels like this should be in its own file with a clear interface to
> zcache-main.c . Minor point, at this point I'm fatigued reading the code
> and cranky.

Perhaps.  In zcache2, all the zbud code is moved to a separate
code module, so zcache-main.c is much shorter.

> > +static void zcache_cleancache_put_page(int pool_id,
> > +=09=09=09=09=09struct cleancache_filekey key,
> > +=09=09=09=09=09pgoff_t index, struct page *page)
> > +{
> > +=09u32 ind =3D (u32) index;
>=20
> This looks like an interesting limitation. How sure are you that index
> will never be larger than u32 and this start behaving badly? I guess it's
> because the index is going to be related to PFN and there are not that
> many 16TB machines lying around but this looks like something that could
> bite us on the ass one day.

The limitation is for a >16TB _file_ on a cleancache-aware filesystem.
And it's not a hard limitation:  Since the definition of tmem/cleancache
allows for it to ignore any put, pages above 16TB in a single file
can be rejected.  So, yes, it will still eventually bite us on
the ass, but not before huge parts of the kernel need to be rewritten too.

> > +/*
> > + * zcache initialization
> > + * NOTE FOR NOW zcache MUST BE PROVIDED AS A KERNEL BOOT PARAMETER OR
> > + * NOTHING HAPPENS!
> > + */
> > +
>=20
> ok..... why?
>=20
> superficially there does not appear to be anything obvious that stops it
> being turned on at runtime. Hardly a blocked, just odd.

The issue is that zcache must be active when a filesystem is mounted
(and at swapon time) or the filesystem will be ignored.

A patch has been posted by a University team to fix this but
it hasn't been merged yet.  I agree it should before zcache
should be widely used.

> > + * zsmalloc memory allocator
>=20
> Ok, I didn't read anything after this point.  It's another allocator that
> may or may not pack compressed pages better. The usual concerns about
> internal fragmentation and the like apply but I'm not going to mull over =
them
> now.
> The really interesting part was deciding if zcache was ready or not.
>=20
> So, on zcache, zbud and the underlying tmem thing;
>=20
> The locking is convulated, the interrupt disabling suspicious and there i=
s at
> least one place where it looks like we are depending on not being schedul=
ed
> on another CPU during a long operation. It may actually be that you are
> disabling interrupts to prevent that happening but it's not documented. E=
ven
> if it's the case, disabling interrupts to avoid CPU migration is overkill=
.

Explained above, but more work may be possible here.

> I'm also worried that there appears to be no control over how large
> the zcache can get

There is limited control in zcache1.  The policy is handled much better
in zcache2.  More work definitely remains.

> and am suspicious it can increase lowmem pressure on
> 32-bit machines.  If the lowmem pressure is real then zcache should not
> be available on machines with highmem at all. I'm *really* worried that
> it can deadlock if a page allocation fails before decompressing a page.

I've explicitly tested cases where page allocation fails in both versions
of zcache so I know it works, though I obviously can't guarantee it _always=
_
works.  In zcache2, when an alloc_page fails, a cleancache_put will
"eat its own tail" (i.e. reclaim and immediately reuse the LRU zpageframe)
and a frontswap_put will eat the LRU cleancache pageframe.  Zcache1
doesn't fail or deadlock, but just rejects all new frontswap puts when
zsmalloc becomes full.

> That said, my initial feeling still stands. I think that this needs to mo=
ve
> out of staging because it's in limbo where it is but Andrew may disagree
> because of the reservations. If my reservations are accurate then they
> should at least be *clearly* documented with a note saying that using
> this in production is ill-advised for now. If zcache is activated via the
> kernel parameter, it should print a big dirty warning that the feature is
> still experiemental and leave that warning there until all the issues are
> addressed. Right now I'm not convinced this is production ready but that
> the  issues could be fixed incrementally.

Sounds good... but begs the question whether to promote zcache1
or zcache2.  Or some compromise.

Thanks again, Mel, for taking the (obviously tons of) time to go
through the code and ask intelligent questions and point out the
many nits and minor issues due to my (and others) kernel newbieness!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
