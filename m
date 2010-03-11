Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5524C6B00FA
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 18:41:56 -0500 (EST)
Date: Thu, 11 Mar 2010 15:41:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
 pressure
Message-Id: <20100311154124.e1e23900.akpm@linux-foundation.org>
In-Reply-To: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon,  8 Mar 2010 11:48:20 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> Under memory pressure, the page allocator and kswapd can go to sleep using
> congestion_wait(). In two of these cases, it may not be the appropriate
> action as congestion may not be the problem.

clear_bdi_congested() is called each time a write completes and the
queue is below the congestion threshold.

So if the page allocator or kswapd call congestion_wait() against a
non-congested queue, they'll wake up on the very next write completion.

Hence the above-quoted claim seems to me to be a significant mis-analysis and
perhaps explains why the patchset didn't seem to help anything?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
