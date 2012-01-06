Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 6B2F16B004D
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 09:07:31 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so1393105wgb.26
        for <linux-mm@kvack.org>; Fri, 06 Jan 2012 06:07:29 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 6 Jan 2012 22:07:29 +0800
Message-ID: <CAJd=RBAMtT04n8p4ht4oCSOYKVcUcG0-hbSvmjrP-yhwBYhU1A@mail.gmail.com>
Subject: [PATCH] mm: vmscan: recompute page status when putting back
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, LKML <linux-kernel@vger.kernel.org>

If unlikely the given page is isolated from lru list again, its status is
recomputed before putting back to lru list, since the comment says page's
status can change while we move it among lru.


Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
+++ b/mm/vmscan.c	Fri Jan  6 21:31:56 2012
@@ -633,12 +633,14 @@ int remove_mapping(struct address_space
 void putback_lru_page(struct page *page)
 {
 	int lru;
-	int active = !!TestClearPageActive(page);
-	int was_unevictable = PageUnevictable(page);
+	int active;
+	int was_unevictable;

 	VM_BUG_ON(PageLRU(page));

 redo:
+	active = !!TestClearPageActive(page);
+	was_unevictable = PageUnevictable(page);
 	ClearPageUnevictable(page);

 	if (page_evictable(page, NULL)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
