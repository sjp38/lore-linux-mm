Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E7E6A6B00B9
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 04:00:59 -0400 (EDT)
Date: Tue, 13 Oct 2009 16:00:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH][BUGFIX] vmscan: limit VM_EXEC protection to file pages
Message-ID: <20091013080054.GA20395@localhost>
References: <200910122244.19666.borntraeger@de.ibm.com> <20091013022650.GB7345@localhost> <4AD3E6C4.805@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AD3E6C4.805@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, stable@kernel.org
Cc: Rik van Riel <riel@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

It is possible to have !Anon but SwapBacked pages, and some apps could
create huge number of such pages with MAP_SHARED|MAP_ANONYMOUS. These
pages go into the ANON lru list, and hence shall not be protected: we
only care mapped executable files. Failing to do so may trigger OOM.

Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux.orig/mm/vmscan.c	2009-10-13 09:49:05.000000000 +0800
+++ linux/mm/vmscan.c	2009-10-13 09:49:37.000000000 +0800
@@ -1356,7 +1356,7 @@ static void shrink_active_list(unsigned 
 			 * IO, plus JVM can create lots of anon VM_EXEC pages,
 			 * so we ignore them here.
 			 */
-			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
+			if ((vm_flags & VM_EXEC) && page_is_file_cache(page)) {
 				list_add(&page->lru, &l_active);
 				continue;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
