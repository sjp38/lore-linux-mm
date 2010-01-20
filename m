Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 539906B0078
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 01:06:06 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0K663U2005111
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 Jan 2010 15:06:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5272445DE57
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 15:06:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3094E45DE51
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 15:06:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 12F781DB803E
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 15:06:03 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BAE7C1DB803A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 15:06:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [cleanup][PATCH] Kill anon local variable from migrate_page_copy
Message-Id: <20100120150451.406A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Jan 2010 15:06:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


commit 01b1ae63c2 (memcg: simple migration handling) removed
mem_cgroup_uncharge_cache_page() call from migrate_page_copy.
Then, now anon variable is unused.

This patch remove it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/migrate.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index efddbf0..9e4a13f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -275,8 +275,6 @@ static int migrate_page_move_mapping(struct address_space *mapping,
  */
 static void migrate_page_copy(struct page *newpage, struct page *page)
 {
-	int anon;
-
 	copy_highpage(newpage, page);
 
 	if (PageError(page))
@@ -313,8 +311,6 @@ static void migrate_page_copy(struct page *newpage, struct page *page)
 	ClearPageSwapCache(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
-	/* page->mapping contains a flag for PageAnon() */
-	anon = PageAnon(page);
 	page->mapping = NULL;
 
 	/*
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
