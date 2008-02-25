Date: Mon, 25 Feb 2008 23:38:02 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 04/15] memcg: when do_swap's do_wp_page fails
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252337110.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Don't uncharge when do_swap_page's call to do_wp_page fails: the page which
was charged for is there in the pagetable, and will be correctly uncharged
when that area is unmapped - it was only its COWing which failed.

And while we're here, remove earlier XXX comment: yes, OR in do_wp_page's
return value (maybe VM_FAULT_WRITE) with do_swap_page's there; but if it
fails, mask out success bits, which might confuse some arches e.g. sparc.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memory.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

--- memcg03/mm/memory.c	2008-02-25 14:05:43.000000000 +0000
+++ memcg04/mm/memory.c	2008-02-25 14:05:47.000000000 +0000
@@ -2093,12 +2093,9 @@ static int do_swap_page(struct mm_struct
 	unlock_page(page);
 
 	if (write_access) {
-		/* XXX: We could OR the do_wp_page code with this one? */
-		if (do_wp_page(mm, vma, address,
-				page_table, pmd, ptl, pte) & VM_FAULT_OOM) {
-			mem_cgroup_uncharge_page(page);
-			ret = VM_FAULT_OOM;
-		}
+		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
+		if (ret & VM_FAULT_ERROR)
+			ret &= VM_FAULT_ERROR;
 		goto out;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
