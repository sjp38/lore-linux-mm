Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id EDF256B0092
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 06:54:28 -0400 (EDT)
Received: by yhr47 with SMTP id 47so6180655yhr.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 03:54:28 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 05/11] mm: frontswap: split frontswap_shrink further to eliminate locking games
Date: Wed,  6 Jun 2012 12:55:09 +0200
Message-Id: <1338980115-2394-5-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, dan.magenheimer@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Split frontswap_shrink to eliminate the locking issues in the original code.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |   36 +++++++++++++++++++++---------------
 1 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index a9b76cb..618ef91 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -244,6 +244,24 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
 	return ret;
 }
 
+static int __frontswap_shrink(unsigned long target_pages,
+				unsigned long *pages_to_unuse,
+				int *type)
+{
+	unsigned long total_pages = 0, total_pages_to_unuse;
+
+	lockdep_assert_held(&swap_lock);
+
+	total_pages = __frontswap_curr_pages();
+	if (total_pages <= target_pages) {
+		/* Nothing to do */
+		*pages_to_unuse = 0;
+		return 0;
+	}
+	total_pages_to_unuse = total_pages - target_pages;
+	return __frontswap_unuse_pages(total_pages_to_unuse, pages_to_unuse, type);
+}
+
 /*
  * Frontswap, like a true swap device, may unnecessarily retain pages
  * under certain circumstances; "shrink" frontswap is essentially a
@@ -254,10 +272,8 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
  */
 void frontswap_shrink(unsigned long target_pages)
 {
-	unsigned long total_pages = 0, total_pages_to_unuse;
 	unsigned long pages_to_unuse = 0;
 	int type, ret;
-	bool locked = false;
 
 	/*
 	 * we don't want to hold swap_lock while doing a very
@@ -265,20 +281,10 @@ void frontswap_shrink(unsigned long target_pages)
 	 * so restart scan from swap_list.head each time
 	 */
 	spin_lock(&swap_lock);
-	locked = true;
-	total_pages = __frontswap_curr_pages();
-	if (total_pages <= target_pages)
-		goto out;
-	total_pages_to_unuse = total_pages - target_pages;
-	ret = __frontswap_unuse_pages(total_pages_to_unuse, &pages_to_unuse, &type);
-	if (ret < 0)
-		goto out;
-	locked = false;
+	ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
 	spin_unlock(&swap_lock);
-	try_to_unuse(type, true, pages_to_unuse);
-out:
-	if (locked)
-		spin_unlock(&swap_lock);
+	if (ret == 0 && pages_to_unuse)
+		try_to_unuse(type, true, pages_to_unuse);
 	return;
 }
 EXPORT_SYMBOL(frontswap_shrink);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
