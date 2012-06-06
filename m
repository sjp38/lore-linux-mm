Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 598806B008C
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 06:54:24 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wd18so13312502obb.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 03:54:24 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 03/11] mm: frontswap: split out __frontswap_curr_pages
Date: Wed,  6 Jun 2012 12:55:07 +0200
Message-Id: <1338980115-2394-3-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, dan.magenheimer@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Code was duplicated in two functions, clean it up.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 844d6a6..52b9dab 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -195,6 +195,20 @@ void __frontswap_invalidate_area(unsigned type)
 }
 EXPORT_SYMBOL(__frontswap_invalidate_area);
 
+static unsigned long __frontswap_curr_pages(void)
+{
+	int type;
+	unsigned long totalpages = 0;
+	struct swap_info_struct *si = NULL;
+
+	lockdep_assert_held(&swap_lock);
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
@@ -219,11 +233,7 @@ void frontswap_shrink(unsigned long target_pages)
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
@@ -261,16 +271,12 @@ EXPORT_SYMBOL(frontswap_shrink);
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
