Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5880D600373
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 04:12:49 -0400 (EDT)
Date: Thu, 8 Apr 2010 17:08:58 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH v3.1 -mmotm 2/2] memcg: move charge of file pages
Message-Id: <20100408170858.d7249445.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100408154434.0f87bddf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100408140922.422b21b0.nishimura@mxp.nes.nec.co.jp>
	<20100408141131.6bf5fd1a.nishimura@mxp.nes.nec.co.jp>
	<20100408154434.0f87bddf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 2010 15:44:34 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 8 Apr 2010 14:11:31 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This patch adds support for moving charge of file pages, which include normal
> > file, tmpfs file and swaps of tmpfs file. It's enabled by setting bit 1 of
> > <target cgroup>/memory.move_charge_at_immigrate. Unlike the case of anonymous
> > pages, file pages(and swaps) in the range mmapped by the task will be moved even
> > if the task hasn't done page fault, i.e. they might not be the task's "RSS",
> > but other task's "RSS" that maps the same file. And mapcount of the page is
> > ignored(the page can be moved even if page_mapcount(page) > 1). So, conditions
> > that the page/swap should be met to be moved is that it must be in the range
> > mmapped by the target task and it must be charged to the old cgroup.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  Documentation/cgroups/memory.txt |   12 ++++++--
> >  include/linux/swap.h             |    5 +++
> >  mm/memcontrol.c                  |   55 +++++++++++++++++++++++++++++--------
> >  mm/shmem.c                       |   37 +++++++++++++++++++++++++
> >  4 files changed, 94 insertions(+), 15 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > index 1b5bd04..13d40e7 100644
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -461,14 +461,20 @@ charges should be moved.
> >     0  | A charge of an anonymous page(or swap of it) used by the target task.
> >        | Those pages and swaps must be used only by the target task. You must
> >        | enable Swap Extension(see 2.4) to enable move of swap charges.
> > + -----+------------------------------------------------------------------------
> > +   1  | A charge of file pages(normal file, tmpfs file(e.g. ipc shared memory)
> > +      | and swaps of tmpfs file) mmaped by the target task. Unlike the case of
> > +      | anonymous pages, file pages(and swaps) in the range mmapped by the task
> > +      | will be moved even if the task hasn't done page fault, i.e. they might
> > +      | not be the task's "RSS", but other task's "RSS" that maps the same file.
> > +      | And mapcount of the page is ignored(the page can be moved even if
> > +      | page_mapcount(page) > 1). You must enable Swap Extension(see 2.4) to
> > +      | enable move of swap charges.
> >  
> >  Note: Those pages and swaps must be charged to the old cgroup.
> > -Note: More type of pages(e.g. file cache, shmem,) will be supported by other
> > -      bits in future.
> >  
> 
> About both of documenataion for 0 and 1, I think following information is omitted.
> 
>  "An account of a page of task is moved only when it's under task's current memory cgroup."
> 
> Plz add somewhere easy-to-be-found.
> 
hmm, I intended to say it by "Note: Those pages and swaps must be charged
to the old cgroup.".
But okey, I updated the documentation. How about this ?

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

This patch adds support for moving charge of file pages, which include normal
file, tmpfs file and swaps of tmpfs file. It's enabled by setting bit 1 of
<target cgroup>/memory.move_charge_at_immigrate. Unlike the case of anonymous
pages, file pages(and swaps) in the range mmapped by the task will be moved even
if the task hasn't done page fault, i.e. they might not be the task's "RSS",
but other task's "RSS" that maps the same file. And mapcount of the page is
ignored(the page can be moved even if page_mapcount(page) > 1). So, conditions
that the page/swap should be met to be moved is that it must be in the range
mmapped by the target task and it must be charged to the old cgroup.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
v3->v3.1: updated documentation.

 Documentation/cgroups/memory.txt |   18 ++++++++----
 include/linux/swap.h             |    5 +++
 mm/memcontrol.c                  |   55 +++++++++++++++++++++++++++++--------
 mm/shmem.c                       |   37 +++++++++++++++++++++++++
 4 files changed, 97 insertions(+), 18 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 1b5bd04..374582c 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -454,21 +454,27 @@ And if you want disable it again:
 8.2 Type of charges which can be move
 
 Each bits of move_charge_at_immigrate has its own meaning about what type of
-charges should be moved.
+charges should be moved. But in any cases, it must be noted that an account of
+a page or a swap can be moved only when it is charged to the task's current(old)
+memory cgroup.
 
   bit | what type of charges would be moved ?
  -----+------------------------------------------------------------------------
    0  | A charge of an anonymous page(or swap of it) used by the target task.
       | Those pages and swaps must be used only by the target task. You must
       | enable Swap Extension(see 2.4) to enable move of swap charges.
-
-Note: Those pages and swaps must be charged to the old cgroup.
-Note: More type of pages(e.g. file cache, shmem,) will be supported by other
-      bits in future.
+ -----+------------------------------------------------------------------------
+   1  | A charge of file pages(normal file, tmpfs file(e.g. ipc shared memory)
+      | and swaps of tmpfs file) mmaped by the target task. Unlike the case of
+      | anonymous pages, file pages(and swaps) in the range mmapped by the task
+      | will be moved even if the task hasn't done page fault, i.e. they might
+      | not be the task's "RSS", but other task's "RSS" that maps the same file.
+      | And mapcount of the page is ignored(the page can be moved even if
+      | page_mapcount(page) > 1). You must enable Swap Extension(see 2.4) to
+      | enable move of swap charges.
 
 8.3 TODO
 
-- Add support for other types of pages(e.g. file cache, shmem, etc.).
 - Implement madvise(2) to let users decide the vma to be moved or not to be
   moved.
 - All of moving charge operations are done under cgroup_mutex. It's not good
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1f59d93..94ec325 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -285,6 +285,11 @@ extern void kswapd_stop(int nid);
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 #endif /* CONFIG_MMU */
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+extern void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
+					struct page **pagep, swp_entry_t *ent);
+#endif
+
 extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
 
 #ifdef CONFIG_SWAP
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 95a1706..225a658 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -250,6 +250,7 @@ struct mem_cgroup {
  */
 enum move_type {
 	MOVE_CHARGE_TYPE_ANON,	/* private anonymous page and swap of it */
+	MOVE_CHARGE_TYPE_FILE,	/* file page(including tmpfs) and swap of it */
 	NR_MOVE_TYPE,
 };
 
@@ -271,6 +272,11 @@ static bool move_anon(void)
 	return test_bit(MOVE_CHARGE_TYPE_ANON,
 					&mc.to->move_charge_at_immigrate);
 }
+static bool move_file(void)
+{
+	return test_bit(MOVE_CHARGE_TYPE_FILE,
+					&mc.to->move_charge_at_immigrate);
+}
 
 /*
  * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
@@ -4199,11 +4205,8 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
 		/* we don't move shared anon */
 		if (!move_anon() || page_mapcount(page) > 2)
 			return NULL;
-	} else
-		/*
-		 * TODO: We don't move charges of file(including shmem/tmpfs)
-		 * pages for now.
-		 */
+	} else if (!move_file())
+		/* we ignore mapcount for file pages */
 		return NULL;
 	if (!get_page_unless_zero(page))
 		return NULL;
@@ -4232,6 +4235,39 @@ static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
 	return page;
 }
 
+static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
+			unsigned long addr, pte_t ptent, swp_entry_t *entry)
+{
+	struct page *page = NULL;
+	struct inode *inode;
+	struct address_space *mapping;
+	pgoff_t pgoff;
+
+	if (!vma->vm_file) /* anonymous vma */
+		return NULL;
+	if (!move_file())
+		return NULL;
+
+	inode = vma->vm_file->f_path.dentry->d_inode;
+	mapping = vma->vm_file->f_mapping;
+	if (pte_none(ptent))
+		pgoff = linear_page_index(vma, addr);
+	if (pte_file(ptent))
+		pgoff = pte_to_pgoff(ptent);
+
+	/* page is moved even if it's not RSS of this task(page-faulted). */
+	if (!mapping_cap_swap_backed(mapping)) { /* normal file */
+		page = find_get_page(mapping, pgoff);
+	} else { /* shmem/tmpfs file. we should take account of swap too. */
+		swp_entry_t ent;
+		mem_cgroup_get_shmem_target(inode, pgoff, &page, &ent);
+		if (do_swap_account)
+			entry->val = ent.val;
+	}
+
+	return page;
+}
+
 static int is_target_pte_for_mc(struct vm_area_struct *vma,
 		unsigned long addr, pte_t ptent, union mc_target *target)
 {
@@ -4244,7 +4280,8 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
 		page = mc_handle_present_pte(vma, addr, ptent);
 	else if (is_swap_pte(ptent))
 		page = mc_handle_swap_pte(vma, addr, ptent, &ent);
-	/* TODO: handle swap of shmes/tmpfs */
+	else if (pte_none(ptent) || pte_file(ptent))
+		page = mc_handle_file_pte(vma, addr, ptent, &ent);
 
 	if (!page && !ent.val)
 		return 0;
@@ -4307,9 +4344,6 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 		};
 		if (is_vm_hugetlb_page(vma))
 			continue;
-		/* TODO: We don't move charges of shmem/tmpfs pages for now. */
-		if (vma->vm_flags & VM_SHARED)
-			continue;
 		walk_page_range(vma->vm_start, vma->vm_end,
 					&mem_cgroup_count_precharge_walk);
 	}
@@ -4506,9 +4540,6 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
 		};
 		if (is_vm_hugetlb_page(vma))
 			continue;
-		/* TODO: We don't move charges of shmem/tmpfs pages for now. */
-		if (vma->vm_flags & VM_SHARED)
-			continue;
 		ret = walk_page_range(vma->vm_start, vma->vm_end,
 						&mem_cgroup_move_charge_walk);
 		if (ret)
diff --git a/mm/shmem.c b/mm/shmem.c
index dde4363..cb87365 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2701,3 +2701,40 @@ int shmem_zero_setup(struct vm_area_struct *vma)
 	vma->vm_ops = &shmem_vm_ops;
 	return 0;
 }
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/**
+ * mem_cgroup_get_shmem_target - find a page or entry assigned to the shmem file
+ * @inode: the inode to be searched
+ * @pgoff: the offset to be searched
+ * @pagep: the pointer for the found page to be stored
+ * @ent: the pointer for the found swap entry to be stored
+ *
+ * If a page is found, refcount of it is incremented. Callers should handle
+ * these refcount.
+ */
+void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
+					struct page **pagep, swp_entry_t *ent)
+{
+	swp_entry_t entry = { .val = 0 }, *ptr;
+	struct page *page = NULL;
+	struct shmem_inode_info *info = SHMEM_I(inode);
+
+	if ((pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
+		goto out;
+
+	spin_lock(&info->lock);
+	ptr = shmem_swp_entry(info, pgoff, NULL);
+	if (ptr && ptr->val) {
+		entry.val = ptr->val;
+		page = find_get_page(&swapper_space, entry.val);
+	} else
+		page = find_get_page(inode->i_mapping, pgoff);
+	if (ptr)
+		shmem_swp_unmap(ptr);
+	spin_unlock(&info->lock);
+out:
+	*pagep = page;
+	*ent = entry;
+}
+#endif
-- 
1.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
