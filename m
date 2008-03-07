Date: Fri, 7 Mar 2008 16:52:44 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [PATCH] 4/4 i_mmap_lock spinlock2rwsem (#v9 was 1/4)
Message-ID: <20080307155244.GF24114@v2.random>
References: <20080303213707.GA8091@v2.random> <20080303220502.GA5301@v2.random> <47CC9B57.5050402@qumranet.com> <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com> <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com> <20080304222030.GB8951@v2.random> <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com> <20080307151722.GD24114@v2.random> <20080307152328.GE24114@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080307152328.GE24114@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

This is a rediff of Christoph's plain i_mmap_lock2rwsem patch on top
of #v9 1/4 + 2/4 + 3/4 (hence this is called 4/4). This is mostly to
show that after 3/4, any patch that plugs on the EMM patchset will
plug nicely on top of my MMU notifer patchset too.

The patch trigger bug checks here in modprobe:

    BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);

kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 252k freed
------------[ cut here ]------------
kernel BUG at mm/mmap.c:2063!
invalid opcode: 0000 [1] SMP
CPU 0
Modules linked in:
Pid: 1123, comm: modprobe.sh Not tainted 2.6.25-rc3 #22
RIP: 0010:[<ffffffff80269368>]  [<ffffffff80269368>] exit_mmap+0xef/0xfa
RSP: 0000:ffff81003c79bed8  EFLAGS: 00010206
RAX: 0000000000000000 RBX: ffff810001004840 RCX: ffff81003c79bee0
RDX: 0000000000000000 RSI: ffff81003c5e8918 RDI: ffff81003d8048c0
RBP: 0000000000000000 R08: 0000000000000008 R09: ffff810002c00040
R10: 0000000000000002 R11: ffff810001009180 R12: ffff81003c57b800
R13: 0000000000000000 R14: 00000000005f0db0 R15: 00007fff3f2af234
FS:  00007f283714b6f0(0000) GS:ffffffff80694000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000458f40 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe.sh (pid: 1123, threadinfo ffff81003c79a000, task ffff81003cf9ca50)
Stack:  0000000000000091 ffff810001004840 ffff81003c57b800 ffff81003c57b880
 0000000000000000 ffffffff8022f7bf 0000000000000001 0000000000000001
 ffff81003cf9ca50 ffffffff802349b6 0000000000000292 ffffffff80354c63
Call Trace:
 [<ffffffff8022f7bf>] mmput+0x30/0x9d
 [<ffffffff802349b6>] do_exit+0x223/0x66c
 [<ffffffff80354c63>] __up_read+0x13/0x8a
 [<ffffffff80234e6e>] do_group_exit+0x6f/0x8a
 [<ffffffff8020bd3b>] system_call_after_swapgs+0x7b/0x80


Code: 7b 18 e8 4a 5c 00 00 c7 43 08 00 00 00 00 eb 0b 48 89 ef e8 d1 fe ff ff 48 89 c5 48 85 ed 75 f0 49 modprobe.sh[1114]: segfault at 0 ip 7f998d2e972b sp 7fff959d8ed0 error 4 in libc-2.6.1.so[7f998d27b000+136000]


I didn't look into this but it shows how it would be risky to make
this change in .25. It's a bit strange that the bugcheck triggers
given I've preempt disabled (I mean CONFIG_PREEMPT_VOLUNTARY=y, nobody
should turn off that config option) and so even if code depended on
the implicit preempt_disable in spin_lock, no race should happen. The
down_read sections at first glance didn't seem capable of altering
nr_ptes, but I didn't look seriously into the above. I rediffed it
just to be 100% on par with EMM sleep-capabilities (but while
retaining more features and cleaner code I hope).

------------------
From: Christoph Lameter <clameter@sgi.com>
Subject: Conversion of i_mmap_lock to semaphore

Not there but the system boots and is usable. Complains about atomic
contexts because the tlb functions use a get_cpu() and thus disable preempt.

Not sure yet what to do about the cond_resched_lock stuff etc.


Convert i_mmap_lock to i_mmap_sem

The conversion to a rwsemaphore allows callbacks during rmap traversal
for files in a non atomic context. A rw style lock allows concurrent
walking of the reverse map.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 arch/x86/mm/hugetlbpage.c |    4 ++--
 fs/hugetlbfs/inode.c      |    4 ++--
 fs/inode.c                |    2 +-
 include/linux/fs.h        |    2 +-
 include/linux/mm.h        |    2 +-
 kernel/fork.c             |    4 ++--
 mm/filemap.c              |    8 ++++----
 mm/filemap_xip.c          |    4 ++--
 mm/fremap.c               |    4 ++--
 mm/hugetlb.c              |   11 +++++------
 mm/memory.c               |   28 ++++++++--------------------
 mm/migrate.c              |    4 ++--
 mm/mmap.c                 |   16 ++++++++--------
 mm/mremap.c               |    4 ++--
 mm/rmap.c                 |   20 +++++++++-----------
 15 files changed, 51 insertions(+), 66 deletions(-)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -69,7 +69,7 @@ static void huge_pmd_share(struct mm_str
 	if (!vma_shareable(vma, addr))
 		return;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -94,7 +94,7 @@ static void huge_pmd_share(struct mm_str
 		put_page(virt_to_page(spte));
 	spin_unlock(&mm->page_table_lock);
 out:
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 }
 
 /*
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -454,10 +454,10 @@ static int hugetlb_vmtruncate(struct ino
 	pgoff = offset >> PAGE_SHIFT;
 
 	i_size_write(inode, offset);
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	if (!prio_tree_empty(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 	truncate_hugepages(inode, offset);
 	return 0;
 }
diff --git a/fs/inode.c b/fs/inode.c
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -210,7 +210,7 @@ void inode_init_once(struct inode *inode
 	INIT_LIST_HEAD(&inode->i_devices);
 	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
 	rwlock_init(&inode->i_data.tree_lock);
-	spin_lock_init(&inode->i_data.i_mmap_lock);
+	init_rwsem(&inode->i_data.i_mmap_sem);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
 	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
diff --git a/include/linux/fs.h b/include/linux/fs.h
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -503,7 +503,7 @@ struct address_space {
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
-	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
+	struct rw_semaphore	i_mmap_sem;	/* protect tree, count, list */
 	unsigned int		truncate_count;	/* Cover race condition with truncate */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -709,7 +709,7 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
-	spinlock_t *i_mmap_lock;		/* For unmap_mapping_range: */
+	struct rw_semaphore *i_mmap_sem;	/* For unmap_mapping_range: */
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
 };
 
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -274,12 +274,12 @@ static int dup_mmap(struct mm_struct *mm
 				atomic_dec(&inode->i_writecount);
 
 			/* insert tmp into the share list, just after mpnt */
-			spin_lock(&file->f_mapping->i_mmap_lock);
+			down_write(&file->f_mapping->i_mmap_sem);
 			tmp->vm_truncate_count = mpnt->vm_truncate_count;
 			flush_dcache_mmap_lock(file->f_mapping);
 			vma_prio_tree_add(tmp, mpnt);
 			flush_dcache_mmap_unlock(file->f_mapping);
-			spin_unlock(&file->f_mapping->i_mmap_lock);
+			up_write(&file->f_mapping->i_mmap_sem);
 		}
 
 		/*
diff --git a/mm/filemap.c b/mm/filemap.c
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -62,16 +62,16 @@ generic_file_direct_IO(int rw, struct ki
 /*
  * Lock ordering:
  *
- *  ->i_mmap_lock		(vmtruncate)
+ *  ->i_mmap_sem		(vmtruncate)
  *    ->private_lock		(__free_pte->__set_page_dirty_buffers)
  *      ->swap_lock		(exclusive_swap_page, others)
  *        ->mapping->tree_lock
  *
  *  ->i_mutex
- *    ->i_mmap_lock		(truncate->unmap_mapping_range)
+ *    ->i_mmap_sem		(truncate->unmap_mapping_range)
  *
  *  ->mmap_sem
- *    ->i_mmap_lock
+ *    ->i_mmap_sem
  *      ->page_table_lock or pte_lock	(various, mainly in memory.c)
  *        ->mapping->tree_lock	(arch-dependent flush_dcache_mmap_lock)
  *
@@ -88,7 +88,7 @@ generic_file_direct_IO(int rw, struct ki
  *    ->sb_lock			(fs/fs-writeback.c)
  *    ->mapping->tree_lock	(__sync_single_inode)
  *
- *  ->i_mmap_lock
+ *  ->i_mmap_sem
  *    ->anon_vma.lock		(vma_adjust)
  *
  *  ->anon_vma.lock
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -184,7 +184,7 @@ __xip_unmap (struct address_space * mapp
 	if (!page)
 		return;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;
 		address = vma->vm_start +
@@ -204,7 +204,7 @@ __xip_unmap (struct address_space * mapp
 			page_cache_release(page);
 		}
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 }
 
 /*
diff --git a/mm/fremap.c b/mm/fremap.c
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -206,13 +206,13 @@ asmlinkage long sys_remap_file_pages(uns
 			}
 			goto out;
 		}
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		flush_dcache_mmap_lock(mapping);
 		vma->vm_flags |= VM_NONLINEAR;
 		vma_prio_tree_remove(vma, &mapping->i_mmap);
 		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		flush_dcache_mmap_unlock(mapping);
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 	}
 
 	mmu_notifier_invalidate_range_begin(mm, start, start + size);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -746,7 +746,7 @@ void __unmap_hugepage_range(struct vm_ar
 	struct page *page;
 	struct page *tmp;
 	/*
-	 * A page gathering list, protected by per file i_mmap_lock. The
+	 * A page gathering list, protected by per file i_mmap_sem. The
 	 * lock is used to avoid list corruption from multiple unmapping
 	 * of the same page since we are using page->lru.
 	 */
@@ -796,9 +796,9 @@ void unmap_hugepage_range(struct vm_area
 	 * do nothing in this case.
 	 */
 	if (vma->vm_file) {
-		spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+		down_write(&vma->vm_file->f_mapping->i_mmap_sem);
 		__unmap_hugepage_range(vma, start, end);
-		spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+		up_write(&vma->vm_file->f_mapping->i_mmap_sem);
 	}
 }
 
@@ -1041,7 +1041,7 @@ void hugetlb_change_protection(struct vm
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+	down_read(&vma->vm_file->f_mapping->i_mmap_sem);
 	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -1056,7 +1056,7 @@ void hugetlb_change_protection(struct vm
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
-	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+	up_read(&vma->vm_file->f_mapping->i_mmap_sem);
 
 	flush_tlb_range(vma, start, end);
 }
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -832,7 +832,6 @@ unsigned long unmap_vmas(struct mmu_gath
 	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
 	int tlb_start_valid = 0;
 	unsigned long start = start_addr;
-	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	int fullmm = (*tlbp)->fullmm;
 
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
@@ -870,21 +869,11 @@ unsigned long unmap_vmas(struct mmu_gath
 
 			tlb_finish_mmu(*tlbp, tlb_start, start);
 
-			if (need_resched() ||
-				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
-				if (i_mmap_lock) {
-					*tlbp = NULL;
-					goto out;
-				}
-				cond_resched();
-			}
-
 			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
 			tlb_start_valid = 0;
 			zap_work = ZAP_BLOCK_SIZE;
 		}
 	}
-out:
 	return start;	/* which is now the end (or restart) address */
 }
 
@@ -1746,7 +1735,7 @@ unwritable_page:
 /*
  * Helper functions for unmap_mapping_range().
  *
- * __ Notes on dropping i_mmap_lock to reduce latency while unmapping __
+ * __ Notes on dropping i_mmap_sem to reduce latency while unmapping __
  *
  * We have to restart searching the prio_tree whenever we drop the lock,
  * since the iterator is only valid while the lock is held, and anyway
@@ -1765,7 +1754,7 @@ unwritable_page:
  * can't efficiently keep all vmas in step with mapping->truncate_count:
  * so instead reset them all whenever it wraps back to 0 (then go to 1).
  * mapping->truncate_count and vma->vm_truncate_count are protected by
- * i_mmap_lock.
+ * i_mmap_sem.
  *
  * In order to make forward progress despite repeatedly restarting some
  * large vma, note the restart_addr from unmap_vmas when it breaks out:
@@ -1815,7 +1804,7 @@ again:
 
 	restart_addr = zap_page_range(vma, start_addr,
 					end_addr - start_addr, details);
-	need_break = need_resched() || spin_needbreak(details->i_mmap_lock);
+	need_break = need_resched();
 
 	if (restart_addr >= end_addr) {
 		/* We have now completed this vma: mark it so */
@@ -1829,9 +1818,9 @@ again:
 			goto again;
 	}
 
-	spin_unlock(details->i_mmap_lock);
+	up_write(details->i_mmap_sem);
 	cond_resched();
-	spin_lock(details->i_mmap_lock);
+	down_write(details->i_mmap_sem);
 	return -EINTR;
 }
 
@@ -1925,9 +1914,9 @@ void unmap_mapping_range(struct address_
 	details.last_index = hba + hlen - 1;
 	if (details.last_index < details.first_index)
 		details.last_index = ULONG_MAX;
-	details.i_mmap_lock = &mapping->i_mmap_lock;
+	details.i_mmap_sem = &mapping->i_mmap_sem;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_write(&mapping->i_mmap_sem);
 
 	/* Protect against endless unmapping loops */
 	mapping->truncate_count++;
@@ -1942,7 +1931,7 @@ void unmap_mapping_range(struct address_
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
-	spin_unlock(&mapping->i_mmap_lock);
+	up_write(&mapping->i_mmap_sem);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
diff --git a/mm/migrate.c b/mm/migrate.c
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -202,12 +202,12 @@ static void remove_file_migration_ptes(s
 	if (!mapping)
 		return;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)
 		remove_migration_pte(vma, old, new);
 
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 }
 
 /*
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -187,7 +187,7 @@ error:
 }
 
 /*
- * Requires inode->i_mapping->i_mmap_lock
+ * Requires inode->i_mapping->i_mmap_sem
  */
 static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		struct file *file, struct address_space *mapping)
@@ -215,9 +215,9 @@ void unlink_file_vma(struct vm_area_stru
 
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		__remove_shared_vm_struct(vma, file, mapping);
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 	}
 }
 
@@ -440,7 +440,7 @@ static void vma_link(struct mm_struct *m
 		mapping = vma->vm_file->f_mapping;
 
 	if (mapping) {
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		vma->vm_truncate_count = mapping->truncate_count;
 	}
 	anon_vma_lock(vma);
@@ -450,7 +450,7 @@ static void vma_link(struct mm_struct *m
 
 	anon_vma_unlock(vma);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 
 	mm->map_count++;
 	validate_mm(mm);
@@ -537,7 +537,7 @@ again:			remove_next = 1 + (end > next->
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR))
 			root = &mapping->i_mmap;
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		if (importer &&
 		    vma->vm_truncate_count != next->vm_truncate_count) {
 			/*
@@ -621,7 +621,7 @@ again:			remove_next = 1 + (end > next->
 	if (anon_vma)
 		spin_unlock(&anon_vma->lock);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 
 	if (remove_next) {
 		if (file)
@@ -2065,7 +2065,7 @@ void exit_mmap(struct mm_struct *mm)
 
 /* Insert vm structure into process list sorted by address
  * and into the inode's i_mmap tree.  If vm_file is non-NULL
- * then i_mmap_lock is taken here.
+ * then i_mmap_sem is taken here.
  */
 int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 {
diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -85,7 +85,7 @@ static void move_ptes(struct vm_area_str
 		 * and we propagate stale pages into the dst afterward.
 		 */
 		mapping = vma->vm_file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		if (new_vma->vm_truncate_count &&
 		    new_vma->vm_truncate_count != vma->vm_truncate_count)
 			new_vma->vm_truncate_count = 0;
@@ -121,7 +121,7 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_nested(new_pte - 1);
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -24,7 +24,7 @@
  *   inode->i_alloc_sem (vmtruncate_range)
  *   mm->mmap_sem
  *     page->flags PG_locked (lock_page)
- *       mapping->i_mmap_lock
+ *       mapping->i_mmap_sem
  *         anon_vma->lock
  *           mm->page_table_lock or pte_lock
  *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
@@ -372,14 +372,14 @@ static int page_referenced_file(struct p
 	 * The page lock not only makes sure that page->mapping cannot
 	 * suddenly be NULLified by truncation, it makes sure that the
 	 * structure at mapping cannot be freed and reused yet,
-	 * so we can safely take mapping->i_mmap_lock.
+	 * so we can safely take mapping->i_mmap_sem.
 	 */
 	BUG_ON(!PageLocked(page));
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 
 	/*
-	 * i_mmap_lock does not stabilize mapcount at all, but mapcount
+	 * i_mmap_sem does not stabilize mapcount at all, but mapcount
 	 * is more likely to be accurate if we note it after spinning.
 	 */
 	mapcount = page_mapcount(page);
@@ -402,7 +402,7 @@ static int page_referenced_file(struct p
 			break;
 	}
 
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 	return referenced;
 }
 
@@ -487,12 +487,12 @@ static int page_mkclean_file(struct addr
 
 	BUG_ON(PageAnon(page));
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED)
 			ret += page_mkclean_one(page, vma);
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 	return ret;
 }
 
@@ -924,7 +924,7 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
@@ -961,7 +961,6 @@ static int try_to_unmap_file(struct page
 	mapcount = page_mapcount(page);
 	if (!mapcount)
 		goto out;
-	cond_resched_lock(&mapping->i_mmap_lock);
 
 	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
 	if (max_nl_cursor == 0)
@@ -983,7 +982,6 @@ static int try_to_unmap_file(struct page
 			}
 			vma->vm_private_data = (void *) max_nl_cursor;
 		}
-		cond_resched_lock(&mapping->i_mmap_lock);
 		max_nl_cursor += CLUSTER_SIZE;
 	} while (max_nl_cursor <= max_nl_size);
 
@@ -995,7 +993,7 @@ static int try_to_unmap_file(struct page
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_private_data = NULL;
 out:
-	spin_unlock(&mapping->i_mmap_lock);
+	up_write(&mapping->i_mmap_sem);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
