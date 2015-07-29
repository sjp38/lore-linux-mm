Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6326B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 02:34:14 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so205478590wic.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 23:34:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fu7si25168155wib.72.2015.07.28.23.34.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 23:34:12 -0700 (PDT)
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
 <1435826795-13777-2-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com>
 <55AE0AFE.8070200@suse.cz>
 <alpine.DEB.2.10.1507211549380.3833@chino.kir.corp.google.com>
 <55AFB569.90702@suse.cz>
 <alpine.DEB.2.10.1507221509520.24115@chino.kir.corp.google.com>
 <55B0B175.9090306@suse.cz>
 <alpine.DEB.2.10.1507231358470.31024@chino.kir.corp.google.com>
 <55B1DF11.8070100@suse.cz>
 <alpine.DEB.2.10.1507281711250.12378@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B873DE.2060800@suse.cz>
Date: Wed, 29 Jul 2015 08:34:06 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1507281711250.12378@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 07/29/2015 02:33 AM, David Rientjes wrote:
> On Fri, 24 Jul 2015, Vlastimil Babka wrote:
> 
>> > Two issues I want to bring up:
>> > 
>> >   (1) do non-thp configs benefit from periodic compaction?
>> > 
>> >       In my experience, no, but perhaps there are other use cases where
>> >       this has been a pain.  The primary candidates, in my opinion,
>> >       would be the networking stack and slub.  Joonsoo reports having to
>> >       workaround issues with high-order slub allocations being too
>> >       expensive.  I'm not sure that would be better served by periodic
>> >       compaction, but it seems like a candidate for background compaction.
>> 
>> Yes hopefully a proactive background compaction would serve them enough.
>> 
>> >       This is why my rfc tied periodic compaction to khugepaged, and we
>> >       have strong evidence that this helps thp and cpu utilization.  For
>> >       periodic compaction to be possible outside of thp, we'd need a use
>> >       case for it.
>> > 
>> >   (2) does kcompactd have to be per-node?
>> > 
>> >       I don't see the immediate benefit since direct compaction can
>> >       already scan remote memory and migrate it, khugepaged can do the
>> 
>> It can work remotely, but it's slower.
>> 
>> >       same.  Is there evidence that suggests that a per-node kcompactd
>> >       is significantly better than a single kthread?  I think others
>> >       would be more receptive of a single kthread addition.
>> 
>> I think it's simpler design wrt waking up the kthread for the desired node,
>> and self-tuning any sleeping depending on per-node pressure. It also matches
>> the design of kswapd. And IMHO machines with many memory nodes should
>> naturally have also many CPU's to cope with the threads, so it should all
>> scale well.
>> 
> 
> I see your "proactive background compaction" as my "periodic compaction" 
> :)  And I agree with your comment that we should be careful about defining 
> the API so it can be easily extended in the future.
> 
> I see the two mechanisms different enough that they need to be defined 
> separately: periodic compaction that would be done at certain intervals 
> regardless of fragmentation or allocation failures to keep fragmentation 
> low, and background compaction that would be done when a zone reaches a 
> certain fragmentation index for high orders, similar to extfrag_threshold, 
> or an allocation failure.

Is there a smart way to check the fragmentation index without doing it just
periodically, and without polluting the allocator fast paths?

Do you think we should still handle THP availability separately as this patchset
does, or not? I think it could still serve to reduce page fault latencies and
pointless khugepaged scanning when hugepages cannot be allocated.
Which implies, can the following be built on top of this patchset?

> Per-node kcompactd threads we agree would be optimal, so let's try to see 
> if we can make that work.
> 
> What do you think about the following?
> 
>  - add vm.compact_period_secs to define the number of seconds between
>    full compactions on each node.  This compaction would reset the
>    pageblock skip heuristic and be synchronous.  It would default to 900
>    based only on our evidence that 15m period compaction helps increase
>    our cpu utilization for khugepaged; it is arbitrary and I'd happily
>    change it if someone has a better suggestion.  Changing it to 0 would
>    disable periodic compaction (we don't anticipate anybody will ever
>    want kcompactd threads will take 100% of cpu on each node).  We can
>    stagger this over all nodes to avoid all kcompactd threads working at
>    the same time.

I guess more testing would be useful to see that it still improves things over
the background compaction?

>  - add vm.compact_background_extfrag_threshold to define the extfrag
>    threshold when kcompactd should start doing sync_light migration
>    in the background without resetting the pageblock skip heuristic.
>    The threshold is defined at PAGE_ALLOC_COSTLY_ORDER and is halved
>    for each order higher so that very high order allocations don't

I've pondered what exactly the fragmentation index calculates, and it's hard to
imagine how I'd set the threshold. Note that the equation already does
effectively a halving with each order increase, but probably in the opposite
direction that you want it to.

Michal Hocko suggested to me offline that we have tunables like
compact_min_order and compact_max_order, where (IIUC) compaction would trigger
when no pages of >=compact_min_order are available, and then compaction would
stop when pages of >=compact_max_order are available (i.e. a kind of
hysteresis). I'm not sure about this either, as the user would have to know
which order-allocations his particular drivers need (unless it's somehow
self-tuning).

What I have instead in mind is something like the current high-order watermark
checking (which may be going away soon, but anyway...) basically for each order
we say how many pages of "at least that order" should be available. This could
be calculated progressively for all orders from a single tunable and size of
zone. Or maybe two tunables meant as min/max, to triggest start and end of
background compaction.

>    trigger it.  To reduce overhead, this can be checked only in the
>    slowpath.

Hmm slowpath might be too late, but could be usable starting point.

> I'd also like to talk about compacting of mlocked memory and limit it to 
> only periodic compaction so that we aren't constantly incurring minor 
> faults when not expected.

Well, periodic compaction can be "expected" in the sense that period is known,
but how would the knowledge help the applications suffering from the minor faults?

> How does this sound?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
