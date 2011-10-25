Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 72AF16B002D
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 05:10:02 -0400 (EDT)
Date: Tue, 25 Oct 2011 11:09:56 +0200
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Message-ID: <20111025090956.GA10797@suse.de>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1319524789-22818-1-git-send-email-ccross@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Mon, Oct 24, 2011 at 11:39:49PM -0700, Colin Cross wrote:
> Under the following conditions, __alloc_pages_slowpath can loop
> forever:
> gfp_mask & __GFP_WAIT is true
> gfp_mask & __GFP_FS is false
> reclaim and compaction make no progress
> order <= PAGE_ALLOC_COSTLY_ORDER
> 
> These conditions happen very often during suspend and resume,
> when pm_restrict_gfp_mask() effectively converts all GFP_KERNEL
> allocations into __GFP_WAIT.
b> 
> The oom killer is not run because gfp_mask & __GFP_FS is false,
> but should_alloc_retry will always return true when order is less
> than PAGE_ALLOC_COSTLY_ORDER.
> 
> Fix __alloc_pages_slowpath to skip retrying when oom killer is
> not allowed by the GFP flags, the same way it would skip if the
> oom killer was allowed but disabled.
> 
> Signed-off-by: Colin Cross <ccross@android.com>

Hi Colin,

Your patch functionally seems fine. I see the problem and we certainly
do not want to have the OOM killer firing during suspend. I would prefer
that the IO devices would not be suspended until reclaim was completed
but I imagine that would be a lot harder.

That said, it will be difficult to remember why checking __GFP_NOFAIL in
this case is necessary and someone might "optimitise" it away later. It
would be preferable if it was self-documenting. Maybe something like
this? (This is totally untested)

 mm/page_alloc.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e8ecb6..ad8f376 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -127,6 +127,20 @@ void pm_restrict_gfp_mask(void)
 	saved_gfp_mask = gfp_allowed_mask;
 	gfp_allowed_mask &= ~GFP_IOFS;
 }
+
+static bool pm_suspending(void)
+{
+	if ((gfp_allowed_mask & GFP_IOFS) == GFP_IOFS)
+		return false;
+	return true;
+}
+
+#else
+
+static bool pm_suspending(void)
+{
+	return false;
+}
 #endif /* CONFIG_PM_SLEEP */
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
@@ -2207,6 +2221,14 @@ rebalance:
 
 			goto restart;
 		}
+
+		/*
+		 * Suspend converts GFP_KERNEL to __GFP_WAIT which can
+		 * prevent reclaim making forward progress without
+		 * invoking OOM. Bail if we are suspending
+		 */
+		if (pm_suspending())
+			goto nopage;
 	}
 
 	/* Check if we should retry the allocation */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
