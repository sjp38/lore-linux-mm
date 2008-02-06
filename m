Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m16N36Pe007801
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:03:06 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m16N31gw041300
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 16:03:01 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m16N3012022576
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 16:03:01 -0700
Date: Wed, 6 Feb 2008 15:02:59 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] hugetlb: add locking for overcommit sysctl
Message-ID: <20080206230259.GD3477@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: agl@us.ibm.com
Cc: wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When I replaced hugetlb_dynamic_pool with nr_overcommit_hugepages I used
proc_doulongvec_minmax() directly. However, hugetlb.c's locking rules
require that all counter modifications occur under the hugetlb_lock. Add
a callback into the hugetlb code similar to the one for nr_hugepages.
Grab the lock around the manipulation of nr_overcommit_hugepages in
proc_doulongvec_minmax().

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
I noticed that the nr_hugepages sysctl uses a helper variable,
max_huge_pages to do the same thing. Is that because of locking
requirements (undocmented) for proc_doulongvec_minmax() or because of
the more complicated manipulation of the pool state for that sysctl? If
the former, I will need to modify this patch.

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 30d606a..7ca198b 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -17,6 +17,7 @@ static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 }
 
 int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
+int hugetlb_overcommit_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int hugetlb_treat_movable_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int, int);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 5e2ad5b..92fef8d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -973,7 +973,7 @@ static struct ctl_table vm_table[] = {
 		.data		= &nr_overcommit_huge_pages,
 		.maxlen		= sizeof(nr_overcommit_huge_pages),
 		.mode		= 0644,
-		.proc_handler	= &proc_doulongvec_minmax,
+		.proc_handler	= &hugetlb_overcommit_handler,
 	},
 #endif
 	{
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1a56420..d9a3803 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -605,6 +605,16 @@ int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
 	return 0;
 }
 
+int hugetlb_overcommit_handler(struct ctl_table *table, int write,
+			struct file *file, void __user *buffer,
+			size_t *length, loff_t *ppos)
+{
+	spin_lock(&hugetlb_lock);
+	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+	spin_unlock(&hugetlb_lock);
+	return 0;
+}
+
 #endif /* CONFIG_SYSCTL */
 
 int hugetlb_report_meminfo(char *buf)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
