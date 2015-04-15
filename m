Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id ED4DD6B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 17:03:52 -0400 (EDT)
Received: by qku63 with SMTP id 63so104665032qku.3
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:03:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k134si5961615qhc.65.2015.04.15.14.03.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 14:03:20 -0700 (PDT)
Message-ID: <552ED214.3050105@redhat.com>
Date: Wed, 15 Apr 2015 17:03:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: Send a single IPI to TLB flush multiple pages
 when unmapping
References: <1429094576-5877-1-git-send-email-mgorman@suse.de> <1429094576-5877-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1429094576-5877-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2015 06:42 AM, Mel Gorman wrote:
> An IPI is sent to flush remote TLBs when a page is unmapped that was
> recently accessed by other CPUs. There are many circumstances where this
> happens but the obvious one is kswapd reclaiming pages belonging to a
> running process as kswapd and the task are likely running on separate CPUs.
> 
> On small machines, this is not a significant problem but as machine
> gets larger with more cores and more memory, the cost of these IPIs can
> be high. This patch uses a structure similar in principle to a pagevec
> to collect a list of PFNs and CPUs that require flushing. It then sends
> one IPI to flush the list of PFNs. A new TLB flush helper is required for
> this and one is added for x86. Other architectures will need to decide if
> batching like this is both safe and worth the memory overhead. Specifically
> the requirement is;
> 
> 	If a clean page is unmapped and not immediately flushed, the
> 	architecture must guarantee that a write to that page from a CPU
> 	with a cached TLB entry will trap a page fault.
> 
> This is essentially what the kernel already depends on but the window is
> much larger with this patch applied and is worth highlighting.

This means we already have a (hard to hit?) data corruption
issue in the kernel.  We can lose data if we unmap a writable
but not dirty pte from a file page, and the task writes before
we flush the TLB.

I can only see one way to completely close the window, and that
is to make the pte(s) read-only, and flush the TLB before unmapping
and then flushing the TLB again. Luckily this is only true for
ptes that are both writeable and clean.

This would of course not be acceptable overhead when flushing things
one page at a time, but if we are moving to batched TLB flushes
anyway, there may be a way around this...

1) Check whether the to-be-unmapped pte is read-only, or the page is
   already marked dirty, if either is true, we can go straight to (4).
2) Mark a larger number of ptes read-only in one go (one page table
   page worth of ptes perhaps?)
3) Flush the TLBs for the task(s) with recently turned read-only ptes.
4) Unmap PTEs like your patch series does.
5) Flush the TLBs like your patch series does.

This might require some protection in the page fault code, to ensure
do_wp_page does not mark the pte read-write again in-between (2) and
(4). Then again, do_wp_page does mark the page dirty so we may be ok.

As an aside, it may be worth just doing a global tlb flush if the number
of entries in a ubc exceeds a certain number.

It may also be worth moving try_to_unmap_flush() from shrink_lruvec()
to shrink_zone(), so it is called once per zone and not once per cgroup
inside the zone. I guess we do need to call it before we call
should_continue_reclaim(), though :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
