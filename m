Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id CD59E6B00B9
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:36:55 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id hm4so1298455wib.7
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 12:36:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v2si9028948wix.2.2014.02.25.12.36.53
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 12:36:54 -0800 (PST)
Message-ID: <530CFEDF.3060801@redhat.com>
Date: Tue, 25 Feb 2014 15:36:47 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/2] mm: page_alloc: reset aging cycle with GFP_THISNODE
References: <1393360022-22566-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1393360022-22566-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Stancek <jstancek@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/25/2014 03:27 PM, Johannes Weiner wrote:
> Jan Stancek reports manual page migration encountering allocation
> failures after some pages when there is still plenty of memory free,
> and bisected the problem down to 81c0a2bb515f ("mm: page_alloc: fair
> zone allocator policy").
> 
> The problem is that page migration uses GFP_THISNODE and this makes
> the page allocator bail out before entering the slowpath entirely,
> without resetting the zone round-robin batches.  A string of such
> allocations will fail long before the node's free memory is exhausted.
> 
> GFP_THISNODE is a special flag for callsites that implement their own
> clever node fallback and so no direct reclaim should be invoked.  But
> if the allocations fail, the fair allocation batches should still be
> reset, and if the node is full, it should be aged in the background.
> 
> Make GFP_THISNODE wake up kswapd and reset the zone batches, but bail
> out before entering direct reclaim to not stall the allocating task.
> 
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: <stable@kernel.org> # 3.12+

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
