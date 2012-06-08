Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E231E6B0078
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 15:14:51 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wd18so3738633obb.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 12:14:51 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 05/10] mm: frontswap: split frontswap_shrink further to simplify locking
Date: Fri,  8 Jun 2012 21:15:14 +0200
Message-Id: <1339182919-11432-6-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
References: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Split frontswap_shrink to simplify the locking in the original code.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |   36 +++++++++++++++++++++---------------
 1 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 5d9ed36..1f1af0e 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -265,6 +265,24 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
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
@@ -275,10 +293,8 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
  */
 void frontswap_shrink(unsigned long target_pages)
 {
-	unsigned long total_pages = 0, total_pages_to_unuse;
 	unsigned long pages_to_unuse = 0;
 	int type, ret;
-	bool locked = false;
 
 	/*
 	 * we don't want to hold swap_lock while doing a very
@@ -286,20 +302,10 @@ void frontswap_shrink(unsigned long target_pages)
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
