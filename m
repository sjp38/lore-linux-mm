Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 37AB06B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 19:25:29 -0400 (EDT)
Received: by iecvh10 with SMTP id vh10so145125525iec.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 16:25:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u12si776046iou.22.2015.07.07.16.25.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 16:25:28 -0700 (PDT)
Date: Tue, 7 Jul 2015 16:25:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: Increase SWAP_CLUSTER_MAX to batch TLB flushes
Message-Id: <20150707162526.c8a5e49db01a72a6dcdcf84f@linux-foundation.org>
In-Reply-To: <1436189996-7220-5-git-send-email-mgorman@suse.de>
References: <1436189996-7220-1-git-send-email-mgorman@suse.de>
	<1436189996-7220-5-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon,  6 Jul 2015 14:39:56 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Pages that are unmapped for reclaim must be flushed before being freed to
> avoid corruption due to a page being freed and reallocated while a stale
> TLB entry exists. When reclaiming mapped pages, the requires one IPI per
> SWAP_CLUSTER_MAX. This patch increases SWAP_CLUSTER_MAX to 256 so more
> pages can be flushed with a single IPI. This number was selected because
> it reduced IPIs for TLB shootdowns by 40% on a workload that is dominated
> by mapped pages.
> 
> Note that it is expected that doubling SWAP_CLUSTER_MAX would not always
> halve the IPIs as it is workload dependent. Reclaim efficiency was not 100%
> on this workload which was picked for being IPI-intensive and was closer to
> 35%. More importantly, reclaim does not always isolate in SWAP_CLUSTER_MAX
> pages. The LRU lists for a zone may be small, the priority can be low
> and even when reclaiming a lot of pages, the last isolation may not be
> exactly SWAP_CLUSTER_MAX.
> 
> There are a few potential issues with increasing SWAP_CLUSTER_MAX.
> 
> 1. LRU lock hold times increase slightly because more pages are being
>    isolated.
> 2. There are slight timing changes due to more pages having to be
>    processed before they are freed. There is a slight risk that more
>    pages than are necessary get reclaimed.
> 3. There is a risk that too_many_isolated checks will be easier to
>    trigger resulting in a HZ/10 stall.
> 4. The rotation rate of active->inactive is slightly faster but there
>    should be fewer rotations before the lists get balanced so it
>    shouldn't matter.
> 5. More pages are reclaimed in a single pass if zone_reclaim_mode is
>    active but that thing sucks hard when it's enabled no matter what
> 6. More pages are isolated for compaction so page hold times there
>    are longer while they are being copied
> 
> It's unlikely any of these will be problems but worth keeping in mind if
> there are any reclaim-related bug reports in the near future.

Yes, this may well cause small&subtle changes which will take some time
to be noticed.

What is the overall effect on the performance improvement if this patch
is omitted?

I wonder if we should leave small systems or !SMP systems or
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=n systems with
SWAP_CLUSTER_MAX=32.  If not, why didn't we change this years ago ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
