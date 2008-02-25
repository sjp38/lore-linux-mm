Date: Mon, 25 Feb 2008 23:39:23 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 05/15] memcg: fix VM_BUG_ON from page migration
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252338080.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Page migration gave me free_hot_cold_page's VM_BUG_ON page->page_cgroup.
remove_migration_pte was calling mem_cgroup_charge on the new page whenever
it found a swap pte, before it had determined it to be a migration entry.
That left a surplus reference count on the page_cgroup, so it was still
attached when the page was later freed.

Move that mem_cgroup_charge down to where we're sure it's a migration entry.
We were already under i_mmap_lock or anon_vma->lock, so its GFP_KERNEL was
already inappropriate: change that to GFP_ATOMIC.

It's essential that remove_migration_pte removes all the migration entries,
other crashes follow if not.  So proceed even when the charge fails: normally
it cannot, but after a mem_cgroup_force_empty it might - comment in the code.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/migrate.c |   19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

--- memcg04/mm/migrate.c	2008-02-11 07:18:12.000000000 +0000
+++ memcg05/mm/migrate.c	2008-02-25 14:05:50.000000000 +0000
@@ -153,11 +153,6 @@ static void remove_migration_pte(struct 
  		return;
  	}
 
-	if (mem_cgroup_charge(new, mm, GFP_KERNEL)) {
-		pte_unmap(ptep);
-		return;
-	}
-
  	ptl = pte_lockptr(mm, pmd);
  	spin_lock(ptl);
 	pte = *ptep;
@@ -169,6 +164,20 @@ static void remove_migration_pte(struct 
 	if (!is_migration_entry(entry) || migration_entry_to_page(entry) != old)
 		goto out;
 
+	/*
+	 * Yes, ignore the return value from a GFP_ATOMIC mem_cgroup_charge.
+	 * Failure is not an option here: we're now expected to remove every
+	 * migration pte, and will cause crashes otherwise.  Normally this
+	 * is not an issue: mem_cgroup_prepare_migration bumped up the old
+	 * page_cgroup count for safety, that's now attached to the new page,
+	 * so this charge should just be another incrementation of the count,
+	 * to keep in balance with rmap.c's mem_cgroup_uncharging.  But if
+	 * there's been a force_empty, those reference counts may no longer
+	 * be reliable, and this charge can actually fail: oh well, we don't
+	 * make the situation any worse by proceeding as if it had succeeded.
+	 */
+	mem_cgroup_charge(new, mm, GFP_ATOMIC);
+
 	get_page(new);
 	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
 	if (is_write_migration_entry(entry))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
