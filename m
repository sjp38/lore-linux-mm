Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4550B6B29A3
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:51:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l16-v6so2050676edq.18
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 03:51:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t4-v6si1150484eda.349.2018.08.23.03.50.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 03:50:59 -0700 (PDT)
Date: Thu, 23 Aug 2018 12:50:57 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180823105057.GA29735@dhcp22.suse.cz>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz>
 <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz>
 <20180822110737.GK29735@dhcp22.suse.cz>
 <20180822142446.GL13047@redhat.com>
 <20180822144517.GP29735@dhcp22.suse.cz>
 <20180822152402.GO13047@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822152402.GO13047@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed 22-08-18 11:24:02, Andrea Arcangeli wrote:
> On Wed, Aug 22, 2018 at 04:45:17PM +0200, Michal Hocko wrote:
> > Now I am confused. How can compaction help at all then? I mean  if the
> > node is full of GUP pins then you can hardly do anything but fallback to
> > other node. Or how come your new GFP flag makes any difference?
> 
> It helps until the node is full.
> 
> If you don't call compaction you will get zero THP even when you've
> plenty of free memory.
> 
> So the free memory goes down and down as more and more THP are
> generated y compaction until compaction then fails with
> COMPACT_SKIPPED, there's not enough free memory to relocate an "order
> 9" amount of physically contiguous PAGE_SIZEd fragments.
> 
> At that point the code calls reclaim to make space for a new
> compaction run. Then if that fails again it's not because there's no
> enough free memory.
> 
> Problem is if you ever call reclaim when compaction fails, what
> happens is you free an "order 9" and then it gets eaten up by the app
> so then next compaction call, calls COMPACT_SKIPPED again.
> 
> This is how compaction works since day zero it was introduced in
> kernel 2.6.x something, if you don't have crystal clear the inner
> workings of compaction you have an hard time to review this. So hope
> the above shed some light of how this plays out.
> 
> So in general calling reclaim is ok because compaction fails more
> often than not in such case because it can't compact memory not
> because there aren't at least 2m free in any node. However when you use
> __GFP_THISNODE combined with reclaim that changes the whole angle and
> behavior of compaction if reclaim is still active.
> 
> Not calling compaction in MADV_HUGEPAGE means you can drop
> MADV_HUGEPAGE as a whole. There's no point to ever set it unless we
> call compaction. And if you don't call at least once compaction you
> have near zero chances to get gigabytes of THP even if it's all
> compactable memory and there are gigabytes of free memory in the node,
> after some runtime that shakes the fragments in the buddy.
> 
> To make it even more clear why compaction has to run once at least
> when MADV_HUGEPAGE is set, just check the second last column of your
> /proc/buddyinfo before and after "echo 3 >/proc/sys/vm/drop_caches;
> echo >/proc/sys/vm/compact_memory". Try to allocate memory without
> MADV_HUGEPAGE and without running the "echo 3; echo" and see how much
> THP you'll get. I've plenty of workloads that use MADV_HUGEPAGE not
> just qemu and that totally benefit immediately from THP and there's no
> point to ever defer compaction to khugepaged when userland says "this
> is a long lived allocation".
> 
> Compaction is only potentially wasteful for short lived allocation, so
> MADV_HUGEPAGE has to call compaction.

I guess you have missed my point. I was not suggesting compaction is
pointless. I meant to say, how can be compaction useful in the scenario
you were suggesting when the node is full of pinned pages.

> > It would still try to reclaim easy target as compaction requires. If you
> > do not reclaim at all you can make the current implementation of the
> > compaction noop due to its own watermark checks IIRC.
> 
> That's the feature, if you don't make it a noop when watermark checks
> trigger, it'll end up wasting CPU and breaking vfio.
> 
> The point is that we want compaction to run when there's free memory
> and compaction keeps succeeding.
> 
> So when compaction fails, if it's because we finished all free memory
> in the node, we should just remove __GFP_THISNODE and allocate without
> it (i.e. the optimization). If compaction fails because the memory is
> fragmented but here's still free memory we should fail the allocation
> and trigger the THP fallback to PAGE_SIZE fault.
> 
> Overall removing __GFP_THISNODE unconditionally would simply
> prioritize THP over NUMA locality which is the point of this special
> logic for THP. I can't blame the logic because it certainly helps NUMA
> balancing a lot in letting the memory be in the right place from the
> start. This is why __GFP_COMPACT_ONLY makes sense, to be able to
> retain the logic but still preventing the corner case of such
> __GFP_THISNODE that breaks the VM with MADV_HUGEPAGE.

But __GFP_COMPACT_ONLY is a layering violation because you are
compaction does depend on the reclaim right now.
 
> > yeah, I agree about PAGE_ALLOC_COSTLY_ORDER being an arbitrary limit for
> > a different behavior. But we already do handle those specially so it
> > kind of makes sense to me to expand on that.
> 
> It's still a sign of one more place that needs magic for whatever
> reason. So unless it can be justified by some runtime tests I wouldn't
> make such change by just thinking about it. Reclaim is called if
> there's no free memory left anywhere for compaction to run (i.e. if
> __GFP_THISNODE is not set, if __GPF_THISNODE is set then the caller
> better use __GFP_COMPACT_ONLY).

I am not insisting on the hack I have proposed mostly for the sake of
discussion. But I _strongly_ believe that __GFP_COMPACT_ONLY is the
wrong way around the issue. We are revolving around __GFP_THISNODE
having negative side effect and that is exactly an example of a gfp flag
abuse for internal MM stuff which just happens to be a complete PITA for
a long time.
 
> Now we could also get away without __GFP_COMPACT_ONLY, we could check
> __GFP_THISNODE and make it behave exactly like __GFP_COMPACT_ONLY
> whenever __GFP_DIRECT_RECLAIM was also set in addition of
> __GFP_THISNODE, but then you couldn't use __GFP_THISNODE as a mbind
> anymore and it would have more obscure semantics than a new flag I
> think.

Or simply do not play tricks with __GFP_THISNODE.
-- 
Michal Hocko
SUSE Labs
