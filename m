Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8596B0103
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 15:47:10 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ro12so2631130pbb.27
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 12:47:09 -0800 (PST)
Received: from psmtp.com ([74.125.245.146])
        by mx.google.com with SMTP id ll9si17283910pab.66.2013.11.11.12.47.07
        for <linux-mm@kvack.org>;
        Mon, 11 Nov 2013 12:47:08 -0800 (PST)
Received: by mail-ea0-f179.google.com with SMTP id r15so917834ead.38
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 12:47:05 -0800 (PST)
Date: Mon, 11 Nov 2013 21:47:02 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131111204702.GD18886@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <CA+55aFwrtOaFtwGc6xyZH6-1j3f--AG1JS-iZM8-pZPnwRHBow@mail.gmail.com>
 <1383537862.2373.14.camel@buesod1.americas.hpqcorp.net>
 <20131104073640.GF13030@gmail.com>
 <1384143129.6940.32.camel@buesod1.americas.hpqcorp.net>
 <20131111120116.GA21291@gmail.com>
 <1384194271.6940.40.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384194271.6940.40.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>


* Davidlohr Bueso <davidlohr@hp.com> wrote:

> On Mon, 2013-11-11 at 13:01 +0100, Ingo Molnar wrote:
> > * Davidlohr Bueso <davidlohr@hp.com> wrote:
> > 
> > > Hi Ingo,
> > > 
> > > On Mon, 2013-11-04 at 08:36 +0100, Ingo Molnar wrote:
> > > > * Davidlohr Bueso <davidlohr@hp.com> wrote:
> > > > 
> > > > > I will look into doing the vma cache per thread instead of mm (I hadn't 
> > > > > really looked at the problem like this) as well as Ingo's suggestion on 
> > > > > the weighted LRU approach. However, having seen that we can cheaply and 
> > > > > easily reach around ~70% hit rate in a lot of workloads, makes me wonder 
> > > > > how good is good enough?
> > > > 
> > > > So I think it all really depends on the hit/miss cost difference. It makes 
> > > > little sense to add a more complex scheme if it washes out most of the 
> > > > benefits!
> > > > 
> > > > Also note the historic context: the _original_ mmap_cache, that I 
> > > > implemented 16 years ago, was a front-line cache to a linear list walk 
> > > > over all vmas (!).
> > > > 
> > > > This is the relevant 2.1.37pre1 code in include/linux/mm.h:
> > > > 
> > > > /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
> > > > static inline struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr)
> > > > {
> > > >         struct vm_area_struct *vma = NULL;
> > > > 
> > > >         if (mm) {
> > > >                 /* Check the cache first. */
> > > >                 vma = mm->mmap_cache;
> > > >                 if(!vma || (vma->vm_end <= addr) || (vma->vm_start > addr)) {
> > > >                         vma = mm->mmap;
> > > >                         while(vma && vma->vm_end <= addr)
> > > >                                 vma = vma->vm_next;
> > > >                         mm->mmap_cache = vma;
> > > >                 }
> > > >         }
> > > >         return vma;
> > > > }
> > > > 
> > > > See that vma->vm_next iteration? It was awful - but back then most of us 
> > > > had at most a couple of megs of RAM with just a few vmas. No RAM, no SMP, 
> > > > no worries - the mm was really simple back then.
> > > > 
> > > > Today we have the vma rbtree, which is self-balancing and a lot faster 
> > > > than your typical linear list walk search ;-)
> > > > 
> > > > So I'd _really_ suggest to first examine the assumptions behind the cache, 
> > > > it being named 'cache' and it having a hit rate does in itself not 
> > > > guarantee that it gives us any worthwile cost savings when put in front of 
> > > > an rbtree ...
> > > 
> > > So having mmap_cache around, in whatever form, is an important
> > > optimization for find_vma() - even to this day. It can save us at least
> > > 50% cycles that correspond to this function. [...]
> > 
> > I'm glad it still helps! :-)
> > 
> > > [...] I ran a variety of mmap_cache alternatives over two workloads that 
> > > are heavy on page faults (as opposed to Java based ones I had tried 
> > > previously, which really don't trigger enough for it to be worthwhile).  
> > > So we now have a comparison of 5 different caching schemes -- note that 
> > > the 4 element hash table is quite similar to two elements, with a hash 
> > > function of (addr % hash_size).
> > > 
> > > 1) Kernel build
> > > +------------------------+----------+------------------+---------+
> > > |    mmap_cache type     | hit-rate | cycles (billion) | stddev  |
> > > +------------------------+----------+------------------+---------+
> > > | no mmap_cache          | -        | 15.85            | 0.10066 |
> > > | current mmap_cache     | 72.32%   | 11.03            | 0.01155 |
> > > | mmap_cache+largest VMA | 84.55%   |  9.91            | 0.01414 |
> > > | 4 element hash table   | 78.38%   | 10.52            | 0.01155 |
> > > | per-thread mmap_cache  | 78.84%   | 10.69            | 0.01325 |
> > > +------------------------+----------+------------------+---------+
> > > 
> > > In this particular workload the proposed patch benefits the most and 
> > > current alternatives, while they do help some, aren't really worth 
> > > bothering with as the current implementation already does a nice enough 
> > > job.
> > 
> > Interesting.
> > 
> > > 2) Oracle Data mining (4K pages)
> > > +------------------------+----------+------------------+---------+
> > > |    mmap_cache type     | hit-rate | cycles (billion) | stddev  |
> > > +------------------------+----------+------------------+---------+
> > > | no mmap_cache          | -        | 63.35            | 0.20207 |
> > > | current mmap_cache     | 65.66%   | 19.55            | 0.35019 |
> > > | mmap_cache+largest VMA | 71.53%   | 15.84            | 0.26764 |
> > > | 4 element hash table   | 70.75%   | 15.90            | 0.25586 |
> > > | per-thread mmap_cache  | 86.42%   | 11.57            | 0.29462 |
> > > +------------------------+----------+------------------+---------+
> > > 
> > > This workload sure makes the point of how much we can benefit of caching 
> > > the vma, otherwise find_vma() can cost more than 220% extra cycles. We 
> > > clearly win here by having a per-thread cache instead of per address 
> > > space. I also tried the same workload with 2Mb hugepages and the results 
> > > are much more closer to the kernel build, but with the per-thread vma 
> > > still winning over the rest of the alternatives.
> > 
> > That's also very interesting, and it's exactly the kind of data we need to 
> > judge such matters. Kernel builds and DB loads are two very different, yet 
> > important workloads, so if we improve both cases then the probability that 
> > we improve all other workloads as well increases substantially.
> > 
> > Do you have any data on the number of find_vma() calls performed in these 
> > two cases, so that we can know the per function call average cost?
> > 
> 
> For the kernel build we get around 140 million calls to find_vma(), and 
> for Oracle around 27 million. So the function ends up costing 
> significantly more for the DB workload.

Hm, mind tabulating that into per function call (cycles) and such, for an 
easier overview?

I do think the Oracle case might be pinpointing a separate 
bug/problem/property: unless it's using an obscene number of vmas its 
rbtree should have a manageable depth, what is the average (accessed) 
depth of the rbtree, and is it properly balanced?

Or is access to varied in the Oracle case that it's missing the cache all 
the time, because the rbtree causes many cachemisses as the separate nodes 
are accessed during an rb-walk?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
