Subject: [PATCH] fix to putback_lru_page()/unevictable page handling rework
	v3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080624184122.D838.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080621185408.E832.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080624184122.D838.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 24 Jun 2008 13:19:47 -0400
Message-Id: <1214327987.6563.22.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

PATCH fix to rework of putback_lru_page locking.

Against:  26-rc5-mm3 atop Kosaki Motohiro's v3 rework of Kamezawa
Hiroyuki's putback_lru_page rework patch.

'lru' was not being set to 'UNEVICTABLE when page was, in fact,
unevictable [really "nonreclaimable" :-)], so retry would never
happen, and culled pages never counted.

Also, redundant mem_cgroup_move_lists()--one with incorrect 'lru',
in the case of unevictable pages--messes up memcontroller tracking [I think].

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.26-rc5-mm3/mm/vmscan.c
===================================================================
--- linux-2.6.26-rc5-mm3.orig/mm/vmscan.c	2008-06-23 11:45:26.000000000 -0400
+++ linux-2.6.26-rc5-mm3/mm/vmscan.c	2008-06-24 12:45:15.000000000 -0400
@@ -514,8 +514,8 @@ redo:
 		 * Put unevictable pages directly on zone's unevictable
 		 * list.
 		 */
+		lru = LRU_UNEVICTABLE;
 		add_page_to_unevictable_list(page);
-		mem_cgroup_move_lists(page, LRU_UNEVICTABLE);
 	}
 
 	mem_cgroup_move_lists(page, lru);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
