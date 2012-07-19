Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id F29B16B0095
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:37:03 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 26/34] vmscan: promote shared file mapped pages
Date: Thu, 19 Jul 2012 15:36:36 +0100
Message-Id: <1342708604-26540-27-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Konstantin Khlebnikov <khlebnikov@openvz.org>

commit 34dbc67a644f11ab3475d822d72e25409911e760 upstream.

Stable note: Not tracked in Bugzilla. There were reports of shared
	mapped pages being unfairly reclaimed in comparison to older kernels.
	This is being addressed over time. The specific workload being
	addressed here in described in paragraph four and while paragraph
	five says it did not help performance as such, it made a difference
	to major page faults. I'm aware of at least one bug for a large
	vendor that was due to increased major faults.

Commit 645747462435 ("vmscan: detect mapped file pages used only once")
greatly decreases lifetime of single-used mapped file pages.
Unfortunately it also decreases life time of all shared mapped file
pages.  Because after commit bf3f3bc5e7347 ("mm: don't mark_page_accessed
in fault path") page-fault handler does not mark page active or even
referenced.

Thus page_check_references() activates file page only if it was used twice
while it stays in inactive list, meanwhile it activates anon pages after
first access.  Inactive list can be small enough, this way reclaimer can
accidentally throw away any widely used page if it wasn't used twice in
short period.

After this patch page_check_references() also activate file mapped page at
first inactive list scan if this page is already used multiple times via
several ptes.

I found this while trying to fix degragation in rhel6 (~2.6.32) from rhel5
(~2.6.18).  There a complete mess with >100 web/mail/spam/ftp containers,
they share all their files but there a lot of anonymous pages: ~500mb
shared file mapped memory and 15-20Gb non-shared anonymous memory.  In
this situation major-pagefaults are very costly, because all containers
share the same page.  In my load kernel created a disproportionate
pressure on the file memory, compared with the anonymous, they equaled
only if I raise swappiness up to 150 =)

These patches actually wasn't helped a lot in my problem, but I saw
noticable (10-20 times) reduce in count and average time of
major-pagefault in file-mapped areas.

Actually both patches are fixes for commit v2.6.33-5448-g6457474, because
it was aimed at one scenario (singly used pages), but it breaks the logic
in other scenarios (shared and/or executable pages)

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Acked-by: Pekka Enberg <penberg@kernel.org>
Acked-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Shaohua Li <shaohua.li@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bc31f32..7edaaac 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -723,7 +723,7 @@ static enum page_references page_check_references(struct page *page,
 		 */
 		SetPageReferenced(page);
 
-		if (referenced_page)
+		if (referenced_page || referenced_ptes > 1)
 			return PAGEREF_ACTIVATE;
 
 		return PAGEREF_KEEP;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
