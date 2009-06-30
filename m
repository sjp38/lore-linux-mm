Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 551C56B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 02:24:35 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5U6PIgK027274
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Jun 2009 15:25:18 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E7CC45DD7B
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 15:25:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 510F545DD78
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 15:25:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 30BB4E08004
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 15:25:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DDB30E08001
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 15:25:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] Makes slab pages field in show_free_areas() separate two field
Message-Id: <20090630152324.A73A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Jun 2009 15:25:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] Makes slab pages field in show_free_areas() separate two field

if OOM happed, We really want to know the number of rest reclaimable pages.
Then, reclaimable slab and unreclaimable slab shouldn't be mixed displaing.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_alloc.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2119,7 +2119,8 @@ void show_free_areas(void)
 		" inactive_file:%lu"
 		" unevictable:%lu"
 		" dirty:%lu writeback:%lu unstable:%lu\n"
-		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n",
+		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
+		" mapped:%lu pagetables:%lu bounce:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_ACTIVE_FILE),
 		global_page_state(NR_INACTIVE_ANON),
@@ -2129,8 +2130,8 @@ void show_free_areas(void)
 		global_page_state(NR_WRITEBACK),
 		global_page_state(NR_UNSTABLE_NFS),
 		global_page_state(NR_FREE_PAGES),
-		global_page_state(NR_SLAB_RECLAIMABLE) +
-			global_page_state(NR_SLAB_UNRECLAIMABLE),
+		global_page_state(NR_SLAB_RECLAIMABLE),
+		global_page_state(NR_SLAB_UNRECLAIMABLE),
 		global_page_state(NR_FILE_MAPPED),
 		global_page_state(NR_PAGETABLE),
 		global_page_state(NR_BOUNCE));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
