Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D840C6B004A
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 19:35:03 -0500 (EST)
Date: Wed, 24 Nov 2010 19:35:01 -0500
From: Dean Nelson <dnelson@redhat.com>
Message-Id: <20101125003501.4884.70261.send-patch@localhost6.localdomain6>
Subject: [PATCH] Conditionally call unlock_page() in hugetlb_fault()
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Have hugetlb_fault() call unlock_page(page) only if it had previously called
lock_page(page).

Signed-off-by: Dean Nelson <dnelson@redhat.com>
CC: stable@kernel.org

---

Setting CONFIG_DEBUG_VM=y and then running the libhugetlbfs test suite,
resulted in the tripping of VM_BUG_ON(!PageLocked(page)) in unlock_page()
having been called by hugetlb_fault() when page == pagecache_page.
This patch remedied the problem.

 mm/hugetlb.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c4a3558..8585524 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2738,7 +2738,8 @@ out_page_table_lock:
 		unlock_page(pagecache_page);
 		put_page(pagecache_page);
 	}
-	unlock_page(page);
+	if (page != pagecache_page)
+		unlock_page(page);
 
 out_mutex:
 	mutex_unlock(&hugetlb_instantiation_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
