Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 947166B00A3
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 02:52:23 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id uz6so401120obc.41
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 23:52:23 -0800 (PST)
Received: from mail-oa0-x22e.google.com (mail-oa0-x22e.google.com [2607:f8b0:4003:c02::22e])
        by mx.google.com with ESMTPS id m2si141509obv.45.2014.02.25.23.52.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 23:52:22 -0800 (PST)
Received: by mail-oa0-f46.google.com with SMTP id l6so460513oag.5
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 23:52:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393387473.7655.28.camel@buesod1.americas.hpqcorp.net>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
	<CANN689HfCT8uHKBeMHF-2Xa_eW9y9=UY7WdD1gW2EetqpcVSMw@mail.gmail.com>
	<1393387473.7655.28.camel@buesod1.americas.hpqcorp.net>
Date: Tue, 25 Feb 2014 23:52:22 -0800
Message-ID: <CANN689GNfGLKkHAz9R6BC=E4b6ueMWcS0Ba_qZfCnW7NjnBs9A@mail.gmail.com>
Subject: Re: [PATCH v2] mm: per-thread vma caching
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 25, 2014 at 8:04 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> On Tue, 2014-02-25 at 18:04 -0800, Michel Lespinasse wrote:
>> On Tue, Feb 25, 2014 at 10:16 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>> > This patch is a continuation of efforts trying to optimize find_vma(),
>> > avoiding potentially expensive rbtree walks to locate a vma upon faults.
>> > The original approach (https://lkml.org/lkml/2013/11/1/410), where the
>> > largest vma was also cached, ended up being too specific and random, thus
>> > further comparison with other approaches were needed. There are two things
>> > to consider when dealing with this, the cache hit rate and the latency of
>> > find_vma(). Improving the hit-rate does not necessarily translate in finding
>> > the vma any faster, as the overhead of any fancy caching schemes can be too
>> > high to consider.
>>
>> Actually there is also the cost of keeping the cache up to date. I'm
>> not saying that it's an issue in your proposal - I like the proposal,
>> especially now that you are replacing the per-mm cache rather than
>> adding something on top - but it is a factor to consider.
>
> True, although numbers show that the cost of maintaining the cache is
> quite minimal. Invalidations are a free lunch (except in the rare event
> of a seqnum overflow), so the updating part would consume the most
> cycles, but then again, the hit rate is quite good so I'm not worried
> about that either.

Yes. I like your patch precisely because it keeps maintainance costs low.

>> > +void vmacache_invalidate_all(void)
>> > +{
>> > +       struct task_struct *g, *p;
>> > +
>> > +       rcu_read_lock();
>> > +       for_each_process_thread(g, p) {
>> > +               /*
>> > +                * Only flush the vmacache pointers as the
>> > +                * mm seqnum is already set and curr's will
>> > +                * be set upon invalidation when the next
>> > +                * lookup is done.
>> > +                */
>> > +               memset(p->vmacache, 0, sizeof(p->vmacache));
>> > +       }
>> > +       rcu_read_unlock();
>> > +}
>>
>> Two things:
>>
>> - I believe we only need to invalidate vma caches for threads that
>> share a given mm ? we should probably pass in that mm in order to
>> avoid over-invalidation
>
> I think you're right, since the overflows will always occur on
> mm->seqnum, tasks that do not share the mm shouldn't be affected.
>
> So the danger here is that when a lookup occurs, vmacache_valid() will
> return true, having:
>
> mm == curr->mm && mm->vmacache_seqnum == curr->vmacache_seqnum (both 0).
>
> Then we just iterate the cache and potentially return some bugus vma.
>
> However, since we're now going to reset the seqnum on every fork/clone
> (before it was just the oldmm->seqnum + 1 thing), I doubt we'll ever
> overflow.

I'm concerned about it *precisely* because it won't happen often, and
so it'd be hard to debug if we had a problem there. 64 bits would be
safe, but a 32-bit counter doesn't take that long to overflow, and I'm
sure it will happen once in a while in production.

Actually, I think there is a case for masking the seqnum with a
constant (all ones in production builds, but something shorter when
CONFIG_DEBUG_VM is enabled) so that this code is easier to exercise.

>> - My understanding is that the operation is safe because the caller
>> has the mm's mmap_sem held for write, and other threads accessing the
>> vma cache will have mmap_sem held at least for read, so we don't need
>> extra locking to maintain the vma cache.
>
> Yes, that's how I see things as well.
>
>> Please 1- confirm this is the
>> intention, 2- document this, and 3- only invalidate vma caches for
>> threads that match the caller's mm so that mmap_sem locking can
>> actually apply.
>
> Will do.

Thanks :)

>> > +struct vm_area_struct *vmacache_find(struct mm_struct *mm,
>> > +                                    unsigned long addr)
>> > +
>> > +{
>> > +       int i;
>> > +
>> > +       if (!vmacache_valid(mm))
>> > +               return NULL;
>> > +
>> > +       for (i = 0; i < VMACACHE_SIZE; i++) {
>> > +               struct vm_area_struct *vma = current->vmacache[i];
>> > +
>> > +               if (vma && vma->vm_start <= addr && vma->vm_end > addr)
>> > +                       return vma;
>> > +       }
>> > +
>> > +       return NULL;
>> > +}
>> > +
>> > +void vmacache_update(struct mm_struct *mm, unsigned long addr,
>> > +                    struct vm_area_struct *newvma)
>> > +{
>> > +       /*
>> > +        * Hash based on the page number. Provides a good
>> > +        * hit rate for workloads with good locality and
>> > +        * those with random accesses as well.
>> > +        */
>> > +       int idx = (addr >> PAGE_SHIFT) & 3;
>> > +       current->vmacache[idx] = newvma;
>> > +}
>>
>> I did read the previous discussion about how to compute idx here. I
>> did not at the time realize that you are searching all 4 vmacache
>> entries on lookup - that is, we are only talking about eviction policy
>> here, not a lookup hash policy.
>
> Right.
>
>> My understanding is that the reason both your current and your
>> previous idx computations work, is that a random eviction policy would
>> work too. Basically, what you do is pick some address bits that are
>> 'random enough' to use as an eviction policy.
>
> What do you mean by random enough? I assume that would be something like
> my original scheme were I used the last X bits of the offset within the
> page.

What I mean is that if you used a per-thread random number generator
to compute idx, such as prandom_u32_state() for example, you'd get
nice enough results already - after all, random eviction is not that
bad. So, my hunch is that the particular way you compute idx based on
the address works not because it catches on some particular property
of the access patterns, but just because the sequence of indexes it
ends up generating is as good as a random one.

>> This is more of a question for Linus, but I am very surprised that I
>> can't find an existing LRU eviction policy scheme in Linux. What I
>> have in mind is to keep track of the order the cache entries have last
>> been used. With 4 entries, there are 4! = 24 possible orders, which
>> can be represented with an integer between 0 and 23. When
>> vmacache_find suceeds, that integer is updated using a table lookup
>> (table takes 24*4 = 96 bytes). In vmacache_update, the lru value
>> module 4 indicates which cache way to evict (i.e. it's the one that's
>> been least recently used).
>
> While not completely related, I did play with a mod 4 hashing scheme
> before I got to the one I'm proposing now. It was just not as effective.

I believe you mean using idx = addr % 4 ? I can see that this wouldn't
work well, because index 0 would be chosen way too often (i.e. any
time the address is aligned, or the first access into a given page is
from reading a byte stream that crosses into it, etc).

But, what I propose above is entirely different, it is just picking
whatever cache index was least recently used for lookups. In this
context, the 'modulo 4' is only an implementation detail of how I
propose we track LRU order between the 4 cache slots.

By the way, I'm happy enough with your patch going in with your
proposed eviction scheme; LRU eviction is a refinement that is best
done as a separate patch. It just came up because I think it would be
applicable here.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
