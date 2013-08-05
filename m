Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id CB6366B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 15:32:20 -0400 (EDT)
Date: Mon, 5 Aug 2013 15:32:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/9] mm: zone_reclaim: compaction: don't depend on kswapd
 to invoke reset_isolation_suitable
Message-ID: <20130805193213.GC1845@cmpxchg.org>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-4-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375459596-30061-4-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Fri, Aug 02, 2013 at 06:06:30PM +0200, Andrea Arcangeli wrote:
> If kswapd never need to run (only __GFP_NO_KSWAPD allocations and
> plenty of free memory) compaction is otherwise crippled down and stops
> running for a while after the free/isolation cursor meets. After that
> allocation can fail for a full cycle of compaction_deferred, until
> compaction_restarting finally reset it again.
> 
> Stopping compaction for a full cycle after the cursor meets, even if
> it never failed and it's not going to fail, doesn't make sense.
> 
> We already throttle compaction CPU utilization using
> defer_compaction. We shouldn't prevent compaction to run after each
> pass completes when the cursor meets, unless it failed.
> 
> This makes direct compaction functional again. The throttling of
> direct compaction is still controlled by the defer_compaction
> logic.
> 
> kswapd still won't risk to reset compaction, and it will wait direct
> compaction to do so. Not sure if this is ideal but it at least
> decreases the risk of kswapd doing too much work. kswapd will only run
> one pass of compaction until some allocation invokes compaction again.
> 
> This decreased reliability of compaction was introduced in commit
> 62997027ca5b3d4618198ed8b1aba40b61b1137b .
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: Rafael Aquini <aquini@redhat.com>
> Acked-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
