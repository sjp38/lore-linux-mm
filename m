Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1878D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:36:16 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1577721Ab1C1Jf7 (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 28 Mar 2011 11:35:59 +0200
Date: Mon, 28 Mar 2011 11:35:59 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 4/4] xen/balloon: Move dec_totalhigh_pages() from __balloon_append() to balloon_append()
Message-ID: <20110328093559.GI13826@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

git commit 9be4d4575906af9698de660e477f949a076c87e1 (xen: add
extra pages to balloon) splited balloon_append() into two functions
(balloon_append() and __balloon_append()) and left decrementation
of totalram_pages counter in __balloon_append(). In this situation
if __balloon_append() is called on i386 with highmem page referenced
then totalhigh_pages is decremented, however, it should not. This
patch corrects that issue and moves dec_totalhigh_pages() from
__balloon_append() to balloon_append(). Now totalram_pages and
totalhigh_pages are decremented simultaneously only when
balloon_append() is called.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 drivers/xen/balloon.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index a6d8e59..f54290b 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -114,7 +114,6 @@ static void __balloon_append(struct page *page)
 	if (PageHighMem(page)) {
 		list_add_tail(&page->lru, &ballooned_pages);
 		balloon_stats.balloon_high++;
-		dec_totalhigh_pages();
 	} else {
 		list_add(&page->lru, &ballooned_pages);
 		balloon_stats.balloon_low++;
@@ -124,6 +123,8 @@ static void __balloon_append(struct page *page)
 static void balloon_append(struct page *page)
 {
 	__balloon_append(page);
+	if (PageHighMem(page))
+		dec_totalhigh_pages();
 	totalram_pages--;
 }
 
@@ -462,7 +463,7 @@ static int __init balloon_init(void)
 	     pfn < extra_pfn_end;
 	     pfn++) {
 		page = pfn_to_page(pfn);
-		/* totalram_pages doesn't include the boot-time
+		/* totalram_pages and totalhigh_pages do not include the boot-time
 		   balloon extension, so don't subtract from it. */
 		__balloon_append(page);
 	}
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
