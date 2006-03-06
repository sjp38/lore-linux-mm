Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k26Mo4pw005081
	for <linux-mm@kvack.org>; Mon, 6 Mar 2006 17:50:04 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k26Mo3lL227668
	for <linux-mm@kvack.org>; Mon, 6 Mar 2006 17:50:05 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k26Mo2Su014199
	for <linux-mm@kvack.org>; Mon, 6 Mar 2006 17:50:02 -0500
Subject: [PATCH] hugetlb: remove sysctl zero and infinity values
From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 06 Mar 2006 14:49:54 -0800
Message-Id: <20060306224954.4400F11C@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

These appear pretty redundant to me.  The sysctl helper that
is used only deals with unsigned longs, so it doesn't make
much sense to try to deal with values less than zero here.
It is equally strange to try to impose a maximum of ~0UL.

There's also something a little bit fishy with putting
max_huge_pages in the sysctl table _and_ setting it manually
in the handler function.  But, I'll leave that for another day.

---

 work-dave/include/linux/hugetlb.h |    1 -
 work-dave/kernel/sysctl.c         |    2 --
 work-dave/mm/hugetlb.c            |    1 -
 3 files changed, 4 deletions(-)

diff -puN kernel/sysctl.c~hugetlb-sysctl-remove-zero-infinity kernel/sysctl.c
--- work/kernel/sysctl.c~hugetlb-sysctl-remove-zero-infinity	2006-03-06 12:28:55.000000000 -0800
+++ work-dave/kernel/sysctl.c	2006-03-06 12:33:45.000000000 -0800
@@ -755,8 +755,6 @@ static ctl_table vm_table[] = {
 		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
 		.proc_handler	= &hugetlb_sysctl_handler,
-		.extra1		= (void *)&hugetlb_zero,
-		.extra2		= (void *)&hugetlb_infinity,
 	 },
 	 {
 		.ctl_name	= VM_HUGETLB_GROUP,
diff -puN mm/hugetlb.c~hugetlb-sysctl-remove-zero-infinity mm/hugetlb.c
--- work/mm/hugetlb.c~hugetlb-sysctl-remove-zero-infinity	2006-03-06 12:28:55.000000000 -0800
+++ work-dave/mm/hugetlb.c	2006-03-06 12:28:55.000000000 -0800
@@ -19,7 +19,6 @@
 
 #include <linux/hugetlb.h>
 
-const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
 static unsigned long nr_huge_pages, free_huge_pages;
 unsigned long max_huge_pages;
 static struct list_head hugepage_freelists[MAX_NUMNODES];
diff -puN include/linux/hugetlb.h~hugetlb-sysctl-remove-zero-infinity include/linux/hugetlb.h
--- work/include/linux/hugetlb.h~hugetlb-sysctl-remove-zero-infinity	2006-03-06 12:28:55.000000000 -0800
+++ work-dave/include/linux/hugetlb.h	2006-03-06 12:28:55.000000000 -0800
@@ -28,7 +28,6 @@ int hugetlb_fault(struct mm_struct *mm, 
 			unsigned long address, int write_access);
 
 extern unsigned long max_huge_pages;
-extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
 
 /* arch callbacks */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
