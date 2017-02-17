Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 929534405FD
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:17 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id c25so38732432qtg.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:17 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id 31si7636591qtm.333.2017.02.17.07.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:09 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 11/14] mm: migrate: Add exchange_pages syscall to exchange two page lists.
Date: Fri, 17 Feb 2017 10:05:48 -0500
Message-Id: <20170217150551.117028-12-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

This can save calling two move_pages().

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/entry/syscalls/syscall_64.tbl |   2 +
 include/linux/syscalls.h               |   5 +
 mm/exchange.c                          | 369 +++++++++++++++++++++++++++++++++
 3 files changed, 376 insertions(+)

diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index e93ef0b38db8..944f94781f18 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -339,6 +339,8 @@
 330	common	pkey_alloc		sys_pkey_alloc
 331	common	pkey_free		sys_pkey_free
 
+330	64	exchange_pages		sys_exchange_pages
+
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
 # for native 64-bit operation.
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 91a740f6b884..c87310440228 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -736,6 +736,11 @@ asmlinkage long sys_move_pages(pid_t pid, unsigned long nr_pages,
 				const int __user *nodes,
 				int __user *status,
 				int flags);
+asmlinkage long sys_exchange_pages(pid_t pid, unsigned long nr_pages,
+				const void __user * __user *from_pages,
+				const void __user * __user *to_pages,
+				int __user *status,
+				int flags);
 asmlinkage long sys_mbind(unsigned long start, unsigned long len,
 				unsigned long mode,
 				const unsigned long __user *nmask,
diff --git a/mm/exchange.c b/mm/exchange.c
index dfed26ebff47..c513fb502725 100644
--- a/mm/exchange.c
+++ b/mm/exchange.c
@@ -886,3 +886,372 @@ static int exchange_pages_concur(struct list_head *exchange_list,
 
 	return nr_failed?-EFAULT:0;
 }
+
+/*
+ * Move a set of pages as indicated in the pm array. The addr
+ * field must be set to the virtual address of the page to be moved
+ * and the node number must contain a valid target node.
+ * The pm array ends with node = MAX_NUMNODES.
+ */
+static int do_exchange_page_array(struct mm_struct *mm,
+				      struct pages_to_node *pm,
+					  int migrate_all,
+					  int migrate_use_mt,
+					  int migrate_batch)
+{
+	int err;
+	struct pages_to_node *pp;
+	LIST_HEAD(err_page_list);
+	LIST_HEAD(exchange_page_list);
+	enum migrate_mode mode = MIGRATE_SYNC;
+
+	if (migrate_use_mt)
+		mode |= MIGRATE_MT;
+
+
+	down_read(&mm->mmap_sem);
+
+	/*
+	 * Build a list of pages to migrate
+	 */
+	for (pp = pm; pp->from_addr != 0 && pp->to_addr != 0; pp++) {
+		struct vm_area_struct *from_vma, *to_vma;
+		struct page *from_page, *to_page;
+		unsigned int follflags;
+		bool isolated = false;
+
+		err = -EFAULT;
+		from_vma = find_vma(mm, pp->from_addr);
+		if (!from_vma || 
+			pp->from_addr < from_vma->vm_start || 
+			!vma_migratable(from_vma))
+			goto set_from_status;
+
+		/* FOLL_DUMP to ignore special (like zero) pages */
+		follflags = FOLL_GET | FOLL_SPLIT | FOLL_DUMP;
+		if (thp_migration_supported())
+			follflags &= ~FOLL_SPLIT;
+		from_page = follow_page(from_vma, pp->from_addr, follflags);
+
+		err = PTR_ERR(from_page);
+		if (IS_ERR(from_page))
+			goto set_from_status;
+
+		err = -ENOENT;
+		if (!from_page)
+			goto set_from_status;
+
+		err = -EACCES;
+		if (page_mapcount(from_page) > 1 &&
+				!migrate_all)
+			goto put_and_set_from_page;
+
+		if (PageHuge(from_page)) {
+			if (PageHead(from_page)) 
+				if (isolate_huge_page(from_page, &err_page_list)) {
+					err = 0;
+					isolated = true;
+				}
+			goto put_and_set_from_page;
+		} else if (PageTransCompound(from_page)) {
+			if (PageTail(from_page)) {
+				err = -EACCES;
+				goto put_and_set_from_page;
+			}
+		}
+
+		err = isolate_lru_page(from_page);
+		if (!err) {
+			list_add_tail(&from_page->lru, &err_page_list);
+			inc_zone_page_state(from_page, NR_ISOLATED_ANON +
+					    page_is_file_cache(from_page));
+			isolated = true;
+		}
+put_and_set_from_page:
+		/*
+		 * Either remove the duplicate refcount from
+		 * isolate_lru_page() or drop the page ref if it was
+		 * not isolated.
+		 *
+		 * Since FOLL_GET calls get_page(), and isolate_lru_page()
+		 * also calls get_page()
+		 */
+		put_page(from_page);
+set_from_status:
+		pp->from_status = err;
+
+		if (err)
+			continue;
+
+		/* to pages  */
+		isolated = false;
+		err = -EFAULT;
+		to_vma = find_vma(mm, pp->to_addr);
+		if (!to_vma || 
+			pp->to_addr < to_vma->vm_start || 
+			!vma_migratable(to_vma))
+			goto set_to_status;
+
+		/* FOLL_DUMP to ignore special (like zero) pages */
+		follflags = FOLL_GET | FOLL_SPLIT | FOLL_DUMP;
+		if (thp_migration_supported())
+			follflags &= ~FOLL_SPLIT;
+		to_page = follow_page(to_vma, pp->to_addr, follflags);
+
+		err = PTR_ERR(to_page);
+		if (IS_ERR(to_page))
+			goto set_to_status;
+
+		err = -ENOENT;
+		if (!to_page)
+			goto set_to_status;
+
+		err = -EACCES;
+		if (page_mapcount(to_page) > 1 &&
+				!migrate_all)
+			goto put_and_set_to_page;
+
+		if (PageHuge(to_page)) {
+			if (PageHead(to_page)) 
+				if (isolate_huge_page(to_page, &err_page_list)) {
+					err = 0;
+					isolated = true;
+				}
+			goto put_and_set_to_page;
+		} else if (PageTransCompound(to_page)) {
+			if (PageTail(to_page)) {
+				err = -EACCES;
+				goto put_and_set_to_page;
+			}
+		}
+
+		err = isolate_lru_page(to_page);
+		if (!err) {
+			list_add_tail(&to_page->lru, &err_page_list);
+			inc_zone_page_state(to_page, NR_ISOLATED_ANON +
+					    page_is_file_cache(to_page));
+			isolated = true;
+		}
+put_and_set_to_page:
+		/*
+		 * Either remove the duplicate refcount from
+		 * isolate_lru_page() or drop the page ref if it was
+		 * not isolated.
+		 *
+		 * Since FOLL_GET calls get_page(), and isolate_lru_page()
+		 * also calls get_page()
+		 */
+		put_page(to_page);
+set_to_status:
+		pp->to_status = err;
+
+
+		if (!err) {
+			if ((PageHuge(from_page) != PageHuge(to_page)) ||
+				(PageTransHuge(from_page) != PageTransHuge(to_page))) {
+				pp->to_status = -EFAULT;
+				continue;
+			} else {
+				struct exchange_page_info *one_pair = 
+					kzalloc(sizeof(struct exchange_page_info), GFP_ATOMIC);
+				if (!one_pair) {
+					err = -ENOMEM;
+					break;
+				}
+
+
+				list_del(&from_page->lru);
+				list_del(&to_page->lru);
+
+				one_pair->from_page = from_page;
+				one_pair->to_page = to_page;
+
+				list_add_tail(&one_pair->list, &exchange_page_list);
+			}
+		}
+
+	}
+
+	/* 
+	 * Put back previous isolated pages back
+	 *
+	 * For those not isolated, put_page() should take care of them.
+	 *
+	 * */
+	if (!list_empty(&err_page_list)) {
+		putback_movable_pages(&err_page_list);
+	}
+
+	err = 0;
+	if (!list_empty(&exchange_page_list)) {
+		if (migrate_batch) 
+			err = exchange_pages_concur(&exchange_page_list, mode, MR_SYSCALL);
+		else
+			err = exchange_pages(&exchange_page_list, mode, MR_SYSCALL);
+	}
+
+	while (!list_empty(&exchange_page_list)) {
+		struct exchange_page_info *one_pair = 
+			list_first_entry(&exchange_page_list, 
+							 struct exchange_page_info, list);
+
+		list_del(&one_pair->list);
+		kfree(one_pair);
+	}
+
+	up_read(&mm->mmap_sem);
+
+	return err;
+}
+/*
+ * Migrate an array of page address onto an array of nodes and fill
+ * the corresponding array of status.
+ */
+static int do_pages_exchange(struct mm_struct *mm, nodemask_t task_nodes,
+			 unsigned long nr_pages,
+			 const void __user * __user *from_pages,
+			 const void __user * __user *to_pages,
+			 int __user *status, int flags)
+{
+	struct pages_to_node *pm;
+	unsigned long chunk_nr_pages;
+	unsigned long chunk_start;
+	int err;
+
+	err = -ENOMEM;
+	pm = (struct pages_to_node *)__get_free_page(GFP_KERNEL);
+	if (!pm)
+		goto out;
+
+	migrate_prep();
+
+	/*
+	 * Store a chunk of pages_to_node array in a page,
+	 * but keep the last one as a marker
+	 */
+	chunk_nr_pages = (PAGE_SIZE / sizeof(struct pages_to_node)) - 1;
+
+	for (chunk_start = 0;
+	     chunk_start < nr_pages;
+	     chunk_start += chunk_nr_pages) {
+		int j;
+
+		if (chunk_start + chunk_nr_pages > nr_pages)
+			chunk_nr_pages = nr_pages - chunk_start;
+
+		/* fill the chunk pm with addrs and nodes from user-space */
+		for (j = 0; j < chunk_nr_pages; j++) {
+			const void __user *p;
+
+			err = -EFAULT;
+			if (get_user(p, from_pages + j + chunk_start))
+				goto out_pm;
+			pm[j].from_addr = (unsigned long) p;
+
+			if (get_user(p, to_pages + j + chunk_start))
+				goto out_pm;
+			pm[j].to_addr = (unsigned long) p;
+
+		}
+
+
+		/* End marker for this chunk */
+		pm[chunk_nr_pages].from_addr = pm[chunk_nr_pages].to_addr = 0;
+
+		/* Migrate this chunk */
+		err = do_exchange_page_array(mm, pm,
+						 flags & MPOL_MF_MOVE_ALL,
+						 flags & MPOL_MF_MOVE_MT,
+						 flags & MPOL_MF_MOVE_CONCUR);
+		if (err < 0)
+			goto out_pm;
+
+		/* Return status information */
+		for (j = 0; j < chunk_nr_pages; j++)
+			if (put_user(pm[j].to_status, status + j + chunk_start)) {
+				err = -EFAULT;
+				goto out_pm;
+			}
+	}
+	err = 0;
+
+out_pm:
+	free_page((unsigned long)pm);
+
+out:
+	return err;
+}
+
+
+
+
+SYSCALL_DEFINE6(exchange_pages, pid_t, pid, unsigned long, nr_pages,
+		const void __user * __user *, from_pages,
+		const void __user * __user *, to_pages,
+		int __user *, status, int, flags)
+{
+	const struct cred *cred = current_cred(), *tcred;
+	struct task_struct *task;
+	struct mm_struct *mm;
+	int err;
+	nodemask_t task_nodes;
+
+	/* Check flags */
+	if (flags & ~(MPOL_MF_MOVE|
+				  MPOL_MF_MOVE_ALL|
+				  MPOL_MF_MOVE_MT|
+				  MPOL_MF_MOVE_CONCUR))
+		return -EINVAL;
+
+	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
+		return -EPERM;
+
+	/* Find the mm_struct */
+	rcu_read_lock();
+	task = pid ? find_task_by_vpid(pid) : current;
+	if (!task) {
+		rcu_read_unlock();
+		return -ESRCH;
+	}
+	get_task_struct(task);
+
+	/*
+	 * Check if this process has the right to modify the specified
+	 * process. The right exists if the process has administrative
+	 * capabilities, superuser privileges or the same
+	 * userid as the target process.
+	 */
+	tcred = __task_cred(task);
+	if (!uid_eq(cred->euid, tcred->suid) && !uid_eq(cred->euid, tcred->uid) &&
+	    !uid_eq(cred->uid,  tcred->suid) && !uid_eq(cred->uid,  tcred->uid) &&
+	    !capable(CAP_SYS_NICE)) {
+		rcu_read_unlock();
+		err = -EPERM;
+		goto out;
+	}
+	rcu_read_unlock();
+
+ 	err = security_task_movememory(task);
+ 	if (err)
+		goto out;
+
+	task_nodes = cpuset_mems_allowed(task);
+	mm = get_task_mm(task);
+	put_task_struct(task);
+
+	if (!mm)
+		return -EINVAL;
+
+
+	err = do_pages_exchange(mm, task_nodes, nr_pages, from_pages,
+				    to_pages, status, flags);
+
+	mmput(mm);
+
+	return err;
+
+out:
+	put_task_struct(task);
+
+	return err;
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
