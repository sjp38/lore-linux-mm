Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 2F3FD6B006E
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 06:50:07 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm19so3841575bkc.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 03:50:06 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 03/10] mm: frontswap: split out __frontswap_curr_pages
Date: Sun, 10 Jun 2012 12:51:01 +0200
Message-Id: <1339325468-30614-4-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Code was duplicated in two functions, clean it up.

Also, assert that the deduplicated code runs under the swap spinlock.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 7ec53d5..5faf840 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -216,6 +216,20 @@ void __frontswap_invalidate_area(unsigned type)
 }
 EXPORT_SYMBOL(__frontswap_invalidate_area);
 
+static unsigned long __frontswap_curr_pages(void)
+{
+	int type;
+	unsigned long totalpages = 0;
+	struct swap_info_struct *si = NULL;
+
+	assert_spin_locked(&swap_lock);
+	for (type = swap_list.head; type >= 0; type = si->next) {
+		si = swap_info[type];
+		totalpages += atomic_read(&si->frontswap_pages);
+	}
+	return totalpages;
+}
+
 /*
  * Frontswap, like a true swap device, may unnecessarily retain pages
  * under certain circumstances; "shrink" frontswap is essentially a
@@ -240,11 +254,7 @@ void frontswap_shrink(unsigned long target_pages)
 	 */
 	spin_lock(&swap_lock);
 	locked = true;
-	total_pages = 0;
-	for (type = swap_list.head; type >= 0; type = si->next) {
-		si = swap_info[type];
-		total_pages += atomic_read(&si->frontswap_pages);
-	}
+	total_pages = __frontswap_curr_pages();
 	if (total_pages <= target_pages)
 		goto out;
 	total_pages_to_unuse = total_pages - target_pages;
@@ -282,16 +292,12 @@ EXPORT_SYMBOL(frontswap_shrink);
  */
 unsigned long frontswap_curr_pages(void)
 {
-	int type;
 	unsigned long totalpages = 0;
-	struct swap_info_struct *si = NULL;
 
 	spin_lock(&swap_lock);
-	for (type = swap_list.head; type >= 0; type = si->next) {
-		si = swap_info[type];
-		totalpages += atomic_read(&si->frontswap_pages);
-	}
+	totalpages = __frontswap_curr_pages();
 	spin_unlock(&swap_lock);
+
 	return totalpages;
 }
 EXPORT_SYMBOL(frontswap_curr_pages);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
