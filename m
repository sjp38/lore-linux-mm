Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EDFB6600375
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:57:00 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 40 of 67] skip transhuge pages in ksm for now
Message-Id: <b604b2cdbcc37c12b9cd.1270691483@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:23 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Skip transhuge pages in ksm for now.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---

diff --git a/mm/ksm.c b/mm/ksm.c
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -449,7 +449,7 @@ static struct page *get_mergeable_page(s
 	page = follow_page(vma, addr, FOLL_GET);
 	if (!page)
 		goto out;
-	if (PageAnon(page)) {
+	if (PageAnon(page) && !PageTransCompound(page)) {
 		flush_anon_page(vma, page, addr);
 		flush_dcache_page(page);
 	} else {
@@ -1305,7 +1305,19 @@ next_mm:
 			if (ksm_test_exit(mm))
 				break;
 			*page = follow_page(vma, ksm_scan.address, FOLL_GET);
-			if (*page && PageAnon(*page)) {
+			if (!*page) {
+				ksm_scan.address += PAGE_SIZE;
+				cond_resched();
+				continue;
+			}
+			if (PageTransCompound(*page)) {
+				put_page(*page);
+				ksm_scan.address &= HPAGE_PMD_MASK;
+				ksm_scan.address += HPAGE_PMD_SIZE;
+				cond_resched();
+				continue;
+			}
+			if (PageAnon(*page)) {
 				flush_anon_page(vma, *page, ksm_scan.address);
 				flush_dcache_page(*page);
 				rmap_item = get_next_rmap_item(slot,
@@ -1319,8 +1331,7 @@ next_mm:
 				up_read(&mm->mmap_sem);
 				return rmap_item;
 			}
-			if (*page)
-				put_page(*page);
+			put_page(*page);
 			ksm_scan.address += PAGE_SIZE;
 			cond_resched();
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
