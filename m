Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 9CC626B0033
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 05:11:51 -0400 (EDT)
Date: Thu, 6 Jun 2013 10:11:48 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/7] mm: compaction: don't depend on kswapd to invoke
 reset_isolation_suitable
Message-ID: <20130606091148.GE1936@suse.de>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-4-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1370445037-24144-4-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, Jun 05, 2013 at 05:10:33PM +0200, Andrea Arcangeli wrote:
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

That was part of a series that addressed a problem where processes
stalled for prolonged periods of time in compaction. I see your point
and I do not have a better suggestion at this time but I'll keep an eye
out for regressions in that area.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
