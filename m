Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id B282E6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 17:54:22 -0400 (EDT)
Received: by ioii16 with SMTP id i16so35618303ioi.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 14:54:22 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id e2si17299357pde.90.2015.07.29.14.54.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 14:54:22 -0700 (PDT)
Received: by pabkd10 with SMTP id kd10so11933871pab.2
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 14:54:21 -0700 (PDT)
Date: Wed, 29 Jul 2015 14:54:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
In-Reply-To: <55B873DE.2060800@suse.cz>
Message-ID: <alpine.DEB.2.10.1507291419160.28357@chino.kir.corp.google.com>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz> <1435826795-13777-2-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com> <55AE0AFE.8070200@suse.cz> <alpine.DEB.2.10.1507211549380.3833@chino.kir.corp.google.com>
 <55AFB569.90702@suse.cz> <alpine.DEB.2.10.1507221509520.24115@chino.kir.corp.google.com> <55B0B175.9090306@suse.cz> <alpine.DEB.2.10.1507231358470.31024@chino.kir.corp.google.com> <55B1DF11.8070100@suse.cz> <alpine.DEB.2.10.1507281711250.12378@chino.kir.corp.google.com>
 <55B873DE.2060800@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 29 Jul 2015, Vlastimil Babka wrote:

> > I see the two mechanisms different enough that they need to be defined 
> > separately: periodic compaction that would be done at certain intervals 
> > regardless of fragmentation or allocation failures to keep fragmentation 
> > low, and background compaction that would be done when a zone reaches a 
> > certain fragmentation index for high orders, similar to extfrag_threshold, 
> > or an allocation failure.
> 
> Is there a smart way to check the fragmentation index without doing it just
> periodically, and without polluting the allocator fast paths?
> 

I struggled with that one and that led to my suggestion about checking the 
need for background compaction in the slowpath for high-order allocations, 
much like kicking kswapd.

We certainly don't want to add fastpath overhead for this in the page 
allocator nor in any compound page constructor.

The downside to doing it only in the slowpath, of course, is that the 
allocation has to initially fail.  I don't see that as being problematic, 
though, because there's a good chance that the initial MIGRATE_ASYNC 
direct compaction will be successful: I think we can easily check the 
fragmentation index here and then kick off background compaction if 
needed.

We can try to be clever not only about triggering background compaction at 
certain thresholds, but also how much compaction we want kcompactd to do 
in the background given the threshold.  I wouldn't try to fine tune those 
heuristics in an initially implementation, though

> Do you think we should still handle THP availability separately as this patchset
> does, or not? I think it could still serve to reduce page fault latencies and
> pointless khugepaged scanning when hugepages cannot be allocated.
> Which implies, can the following be built on top of this patchset?
> 

Seems like a different feature compared to implementing periodic and 
background compaction.  And since better compaction should yield better 
allocation success for khugepaged, it would probably make sense to 
evaluate the need for it after periodic and background compaction have 
been tried, it would add more weight to the justification.

I can certainly implement periodic compaction similar to the rfc but using 
per-node kcompactd threads and background compaction, and fold your 
kcompactd introduction into the patchset as a first step.  I was trying to 
see if there were any concerns about the proposal first.  I think it 
covers Joonsoo's usecase.

 > > > > What do you think about the following?
> > 
> >  - add vm.compact_period_secs to define the number of seconds between
> >    full compactions on each node.  This compaction would reset the
> >    pageblock skip heuristic and be synchronous.  It would default to 900
> >    based only on our evidence that 15m period compaction helps increase
> >    our cpu utilization for khugepaged; it is arbitrary and I'd happily
> >    change it if someone has a better suggestion.  Changing it to 0 would
> >    disable periodic compaction (we don't anticipate anybody will ever
> >    want kcompactd threads will take 100% of cpu on each node).  We can
> >    stagger this over all nodes to avoid all kcompactd threads working at
> >    the same time.
> 
> I guess more testing would be useful to see that it still improves things over
> the background compaction?
> 
> >  - add vm.compact_background_extfrag_threshold to define the extfrag
> >    threshold when kcompactd should start doing sync_light migration
> >    in the background without resetting the pageblock skip heuristic.
> >    The threshold is defined at PAGE_ALLOC_COSTLY_ORDER and is halved
> >    for each order higher so that very high order allocations don't
> 
> I've pondered what exactly the fragmentation index calculates, and it's hard to
> imagine how I'd set the threshold. Note that the equation already does
> effectively a halving with each order increase, but probably in the opposite
> direction that you want it to.
> 

I think we'd want to start with the default extfrag_threshold to determine 
whether compacting in the background would be worthwhile.

> What I have instead in mind is something like the current high-order watermark
> checking (which may be going away soon, but anyway...) basically for each order
> we say how many pages of "at least that order" should be available. This could
> be calculated progressively for all orders from a single tunable and size of
> zone. Or maybe two tunables meant as min/max, to triggest start and end of
> background compaction.
> 

We will want to kick off background compaction in the slowpath immediately 
jst like kswapd for the given order.  That background compaction should 
continue until the fragmentation index meets 
vm.compact_background_extfrag_threshold for that order, defaulting to 
the global extfrag_threshold.  Logically, that would make sense since 
otherwise compaction would be skipped for that zone anyway.  But it is 
inverted as you mentioned.

> > I'd also like to talk about compacting of mlocked memory and limit it to 
> > only periodic compaction so that we aren't constantly incurring minor 
> > faults when not expected.
> 
> Well, periodic compaction can be "expected" in the sense that period is known,
> but how would the knowledge help the applications suffering from the minor faults?
> 

There's been a lot of debate over the years of whether compaction should 
be able to migrate mlocked memory.  We have done it for years and recently 
upstream has moved in the same direction.  Since direct compaction is able 
to do it, I don't anticipate a problem with periodic compaction doing so, 
especially at our setting of 15m.  If that were substantially lower, 
however, I could imagine it would have an affect due to increased minor 
faults.  That means we should either limit direct compaction to a sane 
minimum or it will become more complex and we must re-add unevictable vs 
evictable behavior back into the migration scanner.  Or, the best option, 
we say if you really want to periodically compact so frequently that you 
accept the tradeoffs and leave it to the admin :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
