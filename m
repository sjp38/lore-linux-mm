Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 34DB96B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 00:25:40 -0400 (EDT)
Date: Wed, 5 Aug 2009 10:40:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090805024058.GA8886@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Greetings,

Jeff Dike found that many KVM pages are being refaulted in 2.6.29:

"Lots of pages between discarded due to memory pressure only to be
faulted back in soon after. These pages are nearly all stack pages.
This is not consistent - sometimes there are relatively few such pages
and they are spread out between processes."

The refaults can be drastically reduced by the following patch, which
respects the referenced bit of all anonymous pages (including the KVM
pages).

However it risks reintroducing the problem addressed by commit 7e9cd4842
(fix reclaim scalability problem by ignoring the referenced bit,
mainly the pte young bit). I wonder if there are better solutions?

Thanks,
Fengguang

---
 mm/vmscan.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- linux.orig/mm/vmscan.c
+++ linux/mm/vmscan.c
@@ -1288,12 +1288,12 @@ static void shrink_active_list(unsigned 
 			 * Identify referenced, file-backed active pages and
 			 * give them one more trip around the active list. So
 			 * that executable code get better chances to stay in
-			 * memory under moderate memory pressure.  Anon pages
-			 * are not likely to be evicted by use-once streaming
-			 * IO, plus JVM can create lots of anon VM_EXEC pages,
-			 * so we ignore them here.
+			 * memory under moderate memory pressure.
+			 *
+			 * Also protect anon pages: swapping could be costly,
+			 * and KVM guest's referenced bit is helpful.
 			 */
-			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
+			if ((vm_flags & VM_EXEC) || PageAnon(page)) {
 				list_add(&page->lru, &l_active);
 				continue;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
