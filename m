Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 47C076B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 22:57:43 -0400 (EDT)
Subject: [patch]vmscan: protect exectuable page from inactive list scan
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 29 Sep 2010 10:57:40 +0800
Message-ID: <1285729060.27440.14.camel@sli10-conroe.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: hannes@cmpxchg.org, riel@redhat.com, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

With commit 645747462435, pte referenced file page isn't activated in inactive
list scan. For VM_EXEC page, if it can't get a chance to active list, the
executable page protect loses its effect. We protect such page in inactive scan
here, now such page will be guaranteed cached in a full scan of active and
inactive list, which restores previous behavior.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c5dfabf..b973048 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -608,8 +608,15 @@ static enum page_references page_check_references(struct page *page,
 		 * quickly recovered.
 		 */
 		SetPageReferenced(page);
-
-		if (referenced_page)
+		/*
+		 * Identify pte referenced and file-backed pages and give them
+		 * one trip around the active list. So that executable code get
+		 * better chances to stay in memory under moderate memory
+		 * pressure. JVM can create lots of anon VM_EXEC pages, so we
+		 * ignore them here.
+		 */
+		if (referenced_page || ((vm_flags & VM_EXEC) &&
+		    page_is_file_cache(page)))
 			return PAGEREF_ACTIVATE;
 
 		return PAGEREF_KEEP;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
