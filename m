Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id A1B4682F69
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 02:22:15 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id l127so203622761iof.3
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 23:22:15 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m10si37377442igx.93.2016.02.22.23.22.14
        for <linux-mm@kvack.org>;
        Mon, 22 Feb 2016 23:22:15 -0800 (PST)
Date: Tue, 23 Feb 2016 16:23:27 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v1 8/8] mm: kasan: Initial memory quarantine
 implementation
Message-ID: <20160223072326.GA4148@js1304-P5Q-DELUXE>
References: <cover.1453918525.git.glider@google.com>
 <1cec06645310eeb495bcae7bed0807dbf2235f3a.1453918525.git.glider@google.com>
 <20160201024715.GC32125@js1304-P5Q-DELUXE>
 <CAG_fn=W2C=aOgPQgkCi6ntA1tCMOaiF0LjbKtuo1TCFbH58HEg@mail.gmail.com>
 <CAAmzW4McCyLahXw2TV=OHBNwLSg2gq1Bq2n3mmaa7gLFEVGZ+w@mail.gmail.com>
 <CACT4Y+Z60YxN6JKitsKLFfGFDFpVY3_rCPyz9m_3WtFeG+EbSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z60YxN6JKitsKLFfGFDFpVY3_rCPyz9m_3WtFeG+EbSQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Feb 19, 2016 at 10:19:48AM +0100, Dmitry Vyukov wrote:
> On Fri, Feb 19, 2016 at 3:11 AM, Joonsoo Kim <js1304@gmail.com> wrote:
> > 2016-02-18 23:06 GMT+09:00 Alexander Potapenko <glider@google.com>:
> >> On Mon, Feb 1, 2016 at 3:47 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> >>> On Wed, Jan 27, 2016 at 07:25:13PM +0100, Alexander Potapenko wrote:
> >>>> Quarantine isolates freed objects in a separate queue. The objects are
> >>>> returned to the allocator later, which helps to detect use-after-free
> >>>> errors.
> >>>>
> >>>> Freed objects are first added to per-cpu quarantine queues.
> >>>> When a cache is destroyed or memory shrinking is requested, the objects
> >>>> are moved into the global quarantine queue. Whenever a kmalloc call
> >>>> allows memory reclaiming, the oldest objects are popped out of the
> >>>> global queue until the total size of objects in quarantine is less than
> >>>> 3/4 of the maximum quarantine size (which is a fraction of installed
> >>>> physical memory).
> >>>
> >>> Just wondering why not using time based approach rather than size
> >>> based one. In heavy load condition, how much time do the object stay in
> >>> quarantine?
> >>>
> >>>>
> >>>> Right now quarantine support is only enabled in SLAB allocator.
> >>>> Unification of KASAN features in SLAB and SLUB will be done later.
> >>>>
> >>>> This patch is based on the "mm: kasan: quarantine" patch originally
> >>>> prepared by Dmitry Chernenkov.
> >>>>
> >>>> Signed-off-by: Alexander Potapenko <glider@google.com>
> >>>> ---
> >>>>  include/linux/kasan.h |  30 ++++--
> >>>>  lib/test_kasan.c      |  29 ++++++
> >>>>  mm/kasan/Makefile     |   2 +-
> >>>>  mm/kasan/kasan.c      |  68 +++++++++++-
> >>>>  mm/kasan/kasan.h      |  11 +-
> >>>>  mm/kasan/quarantine.c | 284 ++++++++++++++++++++++++++++++++++++++++++++++++++
> >>>>  mm/kasan/report.c     |   3 +-
> >>>>  mm/mempool.c          |   7 +-
> >>>>  mm/page_alloc.c       |   2 +-
> >>>>  mm/slab.c             |  12 ++-
> >>>>  mm/slab.h             |   4 +
> >>>>  mm/slab_common.c      |   2 +
> >>>>  mm/slub.c             |   4 +-
> >>>>  13 files changed, 435 insertions(+), 23 deletions(-)
> >>>>
> >>>
> >>> ...
> >>>
> >>>> +bool kasan_slab_free(struct kmem_cache *cache, void *object)
> >>>> +{
> >>>> +#ifdef CONFIG_SLAB
> >>>> +     /* RCU slabs could be legally used after free within the RCU period */
> >>>> +     if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
> >>>> +             return false;
> >>>> +
> >>>> +     if (likely(cache->flags & SLAB_KASAN)) {
> >>>> +             struct kasan_alloc_meta *alloc_info =
> >>>> +                     get_alloc_info(cache, object);
> >>>> +             struct kasan_free_meta *free_info =
> >>>> +                     get_free_info(cache, object);
> >>>> +
> >>>> +             switch (alloc_info->state) {
> >>>> +             case KASAN_STATE_ALLOC:
> >>>> +                     alloc_info->state = KASAN_STATE_QUARANTINE;
> >>>> +                     quarantine_put(free_info, cache);
> >>>
> >>> quarantine_put() can be called regardless of SLAB_DESTROY_BY_RCU,
> >>> although it's not much meaningful without poisoning. But, I have an
> >>> idea to poison object on SLAB_DESTROY_BY_RCU cache.
> >>>
> >>> quarantine_put() moves per cpu list to global queue when
> >>> list size reaches QUARANTINE_PERCPU_SIZE. If we call synchronize_rcu()
> >>> at that time, after then, we can poison objects. With appropriate size
> >>> setup, it would not be intrusive.
> >>>
> >> Won't this slow the quarantine down unpredictably (e.g. in the case
> >> there're no RCU slabs in quarantine we'll still be waiting for
> >> synchronize_rcu())?
> >
> > It could be handled by introducing one cpu variable.
> >
> >> Yet this is something worth looking into. Do you want RCU to be
> >> handled in this patch set?
> >
> > No. It would be future work.
> >
> >>>> +                     set_track(&free_info->track, GFP_NOWAIT);
> >>>
> >>> set_track() can be called regardless of SLAB_DESTROY_BY_RCU.
> >> Agreed, I can fix that if we decide to handle RCU in this patch
> >> (otherwise it will lead to confusion).
> >>
> >>>
> >>>> +                     kasan_poison_slab_free(cache, object);
> >>>> +                     return true;
> >>>> +             case KASAN_STATE_QUARANTINE:
> >>>> +             case KASAN_STATE_FREE:
> >>>> +                     pr_err("Double free");
> >>>> +                     dump_stack();
> >>>> +                     break;
> >>>> +             default:
> >>>> +                     break;
> >>>> +             }
> >>>> +     }
> >>>> +     return false;
> >>>> +#else
> >>>> +     kasan_poison_slab_free(cache, object);
> >>>> +     return false;
> >>>> +#endif
> >>>> +}
> >>>> +
> >>>
> >>> ...
> >>>
> >>>> +void quarantine_reduce(void)
> >>>> +{
> >>>> +     size_t new_quarantine_size;
> >>>> +     unsigned long flags;
> >>>> +     struct qlist to_free = QLIST_INIT;
> >>>> +     size_t size_to_free = 0;
> >>>> +     void **last;
> >>>> +
> >>>> +     if (likely(ACCESS_ONCE(global_quarantine.bytes) <=
> >>>> +                smp_load_acquire(&quarantine_size)))
> >>>> +             return;
> >>>> +
> >>>> +     spin_lock_irqsave(&quarantine_lock, flags);
> >>>> +
> >>>> +     /* Update quarantine size in case of hotplug. Allocate a fraction of
> >>>> +      * the installed memory to quarantine minus per-cpu queue limits.
> >>>> +      */
> >>>> +     new_quarantine_size = (ACCESS_ONCE(totalram_pages) << PAGE_SHIFT) /
> >>>> +             QUARANTINE_FRACTION;
> >>>> +     new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
> >>>> +     smp_store_release(&quarantine_size, new_quarantine_size);
> >>>> +
> >>>> +     last = global_quarantine.head;
> >>>> +     while (last) {
> >>>> +             struct kmem_cache *cache = qlink_to_cache(last);
> >>>> +
> >>>> +             size_to_free += cache->size;
> >>>> +             if (!*last || size_to_free >
> >>>> +                 global_quarantine.bytes - QUARANTINE_LOW_SIZE)
> >>>> +                     break;
> >>>> +             last = (void **) *last;
> >>>> +     }
> >>>> +     qlist_move(&global_quarantine, last, &to_free, size_to_free);
> >>>> +
> >>>> +     spin_unlock_irqrestore(&quarantine_lock, flags);
> >>>> +
> >>>> +     qlist_free_all(&to_free, NULL);
> >>>> +}
> >>>
> >>> Isn't it better to call quarantine_reduce() in shrink_slab()?
> >>> It will help to maximize quarantine time.
> >> This is true, however if we don't call quarantine_reduce() from
> >> kmalloc()/kfree() the size of the quarantine will be unpredictable.
> >> There's a tradeoff between efficiency and space here, and at least in
> >> some cases we may want to trade efficiency for space.
> >
> > size of the quarantine doesn't matter unless there is memory pressure.
> > If memory pressure, shrink_slab() would be called and we can reduce
> > size of quarantine. However, I don't think this is show stopper. We can
> > do it when needed.
> 
> 
> No, this does not work. We've tried.
> The problem is fragmentation. When all memory is occupied by slab,
> it's already too late to reclaim memory. Free objects are randomly
> scattered over memory, so if you have just 1% of live objects, the
> chances are that you won't be able to reclaim any single page.

Okay. Now, I got it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
