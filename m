Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id B54DE6B009A
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 23:04:37 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id l6so273557oag.5
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 20:04:37 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id kb7si18701048oeb.24.2014.02.25.20.04.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 20:04:37 -0800 (PST)
Message-ID: <1393387473.7655.28.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v2] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 25 Feb 2014 20:04:33 -0800
In-Reply-To: <CANN689HfCT8uHKBeMHF-2Xa_eW9y9=UY7WdD1gW2EetqpcVSMw@mail.gmail.com>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
	 <CANN689HfCT8uHKBeMHF-2Xa_eW9y9=UY7WdD1gW2EetqpcVSMw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2014-02-25 at 18:04 -0800, Michel Lespinasse wrote:
> On Tue, Feb 25, 2014 at 10:16 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > This patch is a continuation of efforts trying to optimize find_vma(),
> > avoiding potentially expensive rbtree walks to locate a vma upon faults.
> > The original approach (https://lkml.org/lkml/2013/11/1/410), where the
> > largest vma was also cached, ended up being too specific and random, thus
> > further comparison with other approaches were needed. There are two things
> > to consider when dealing with this, the cache hit rate and the latency of
> > find_vma(). Improving the hit-rate does not necessarily translate in finding
> > the vma any faster, as the overhead of any fancy caching schemes can be too
> > high to consider.
> 
> Actually there is also the cost of keeping the cache up to date. I'm
> not saying that it's an issue in your proposal - I like the proposal,
> especially now that you are replacing the per-mm cache rather than
> adding something on top - but it is a factor to consider.

True, although numbers show that the cost of maintaining the cache is
quite minimal. Invalidations are a free lunch (except in the rare event
of a seqnum overflow), so the updating part would consume the most
cycles, but then again, the hit rate is quite good so I'm not worried
about that either.

> 
> > +static inline void __vmacache_invalidate(struct mm_struct *mm)
> > +{
> > +#ifdef CONFIG_MMU
> > +       vmacache_invalidate(mm);
> > +#else
> > +       mm->vmacache = NULL;
> > +#endif
> > +}
> 
> Is there any reason why we can't use your proposal for !CONFIG_MMU as well ?
> (I'm assuming that we could reduce preprocessor checks by doing so)

Based on Linus' feedback today, I'm getting rid of this ugliness and
trying to have per-thread caches for both configs.

> > +void vmacache_invalidate_all(void)
> > +{
> > +       struct task_struct *g, *p;
> > +
> > +       rcu_read_lock();
> > +       for_each_process_thread(g, p) {
> > +               /*
> > +                * Only flush the vmacache pointers as the
> > +                * mm seqnum is already set and curr's will
> > +                * be set upon invalidation when the next
> > +                * lookup is done.
> > +                */
> > +               memset(p->vmacache, 0, sizeof(p->vmacache));
> > +       }
> > +       rcu_read_unlock();
> > +}
> 
> Two things:
> 
> - I believe we only need to invalidate vma caches for threads that
> share a given mm ? we should probably pass in that mm in order to
> avoid over-invalidation

I think you're right, since the overflows will always occur on
mm->seqnum, tasks that do not share the mm shouldn't be affected.

So the danger here is that when a lookup occurs, vmacache_valid() will
return true, having:

mm == curr->mm && mm->vmacache_seqnum == curr->vmacache_seqnum (both 0).

Then we just iterate the cache and potentially return some bugus vma.

However, since we're now going to reset the seqnum on every fork/clone
(before it was just the oldmm->seqnum + 1 thing), I doubt we'll ever
overflow.

> - My understanding is that the operation is safe because the caller
> has the mm's mmap_sem held for write, and other threads accessing the
> vma cache will have mmap_sem held at least for read, so we don't need
> extra locking to maintain the vma cache. 

Yes, that's how I see things as well.

> Please 1- confirm this is the
> intention, 2- document this, and 3- only invalidate vma caches for
> threads that match the caller's mm so that mmap_sem locking can
> actually apply.

Will do.

> > +struct vm_area_struct *vmacache_find(struct mm_struct *mm,
> > +                                    unsigned long addr)
> > +
> > +{
> > +       int i;
> > +
> > +       if (!vmacache_valid(mm))
> > +               return NULL;
> > +
> > +       for (i = 0; i < VMACACHE_SIZE; i++) {
> > +               struct vm_area_struct *vma = current->vmacache[i];
> > +
> > +               if (vma && vma->vm_start <= addr && vma->vm_end > addr)
> > +                       return vma;
> > +       }
> > +
> > +       return NULL;
> > +}
> > +
> > +void vmacache_update(struct mm_struct *mm, unsigned long addr,
> > +                    struct vm_area_struct *newvma)
> > +{
> > +       /*
> > +        * Hash based on the page number. Provides a good
> > +        * hit rate for workloads with good locality and
> > +        * those with random accesses as well.
> > +        */
> > +       int idx = (addr >> PAGE_SHIFT) & 3;
> > +       current->vmacache[idx] = newvma;
> > +}
> 
> I did read the previous discussion about how to compute idx here. I
> did not at the time realize that you are searching all 4 vmacache
> entries on lookup - that is, we are only talking about eviction policy
> here, not a lookup hash policy.

Right.

> My understanding is that the reason both your current and your
> previous idx computations work, is that a random eviction policy would
> work too. Basically, what you do is pick some address bits that are
> 'random enough' to use as an eviction policy.

What do you mean by random enough? I assume that would be something like
my original scheme were I used the last X bits of the offset within the
page.

> 
> This is more of a question for Linus, but I am very surprised that I
> can't find an existing LRU eviction policy scheme in Linux. What I
> have in mind is to keep track of the order the cache entries have last
> been used. With 4 entries, there are 4! = 24 possible orders, which
> can be represented with an integer between 0 and 23. When
> vmacache_find suceeds, that integer is updated using a table lookup
> (table takes 24*4 = 96 bytes). In vmacache_update, the lru value
> module 4 indicates which cache way to evict (i.e. it's the one that's
> been least recently used).

While not completely related, I did play with a mod 4 hashing scheme
before I got to the one I'm proposing now. It was just not as effective.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
