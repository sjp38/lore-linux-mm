Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8E76B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 20:46:38 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id at20so28914iec.4
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:46:38 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id d3si13920659igx.10.2014.06.30.17.46.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 17:46:37 -0700 (PDT)
Received: by mail-ie0-f170.google.com with SMTP id tr6so7617195ieb.15
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:46:37 -0700 (PDT)
Date: Mon, 30 Jun 2014 17:46:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, hugetlb: remove hugetlb_zero and hugetlb_infinity
In-Reply-To: <alpine.DEB.2.02.1406301655480.27587@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1406301745200.7070@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1406301655480.27587@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

They are unnecessary: "zero" can be used in place of "hugetlb_zero" and 
passing extra2 == NULL is equivalent to infinity.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/hugetlb.h | 1 -
 kernel/sysctl.c         | 9 +++------
 mm/hugetlb.c            | 1 -
 3 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -86,7 +86,6 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
 #endif
 
 extern unsigned long hugepages_treat_as_movable;
-extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
 extern struct list_head huge_boot_pages;
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1240,8 +1240,7 @@ static struct ctl_table vm_table[] = {
 		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
 		.proc_handler	= hugetlb_sysctl_handler,
-		.extra1		= (void *)&hugetlb_zero,
-		.extra2		= (void *)&hugetlb_infinity,
+		.extra1		= &zero,
 	},
 #ifdef CONFIG_NUMA
 	{
@@ -1250,8 +1249,7 @@ static struct ctl_table vm_table[] = {
 		.maxlen         = sizeof(unsigned long),
 		.mode           = 0644,
 		.proc_handler   = &hugetlb_mempolicy_sysctl_handler,
-		.extra1		= (void *)&hugetlb_zero,
-		.extra2		= (void *)&hugetlb_infinity,
+		.extra1		= &zero,
 	},
 #endif
 	 {
@@ -1274,8 +1272,7 @@ static struct ctl_table vm_table[] = {
 		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
 		.proc_handler	= hugetlb_overcommit_handler,
-		.extra1		= (void *)&hugetlb_zero,
-		.extra2		= (void *)&hugetlb_infinity,
+		.extra1		= &zero,
 	},
 #endif
 	{
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -35,7 +35,6 @@
 #include <linux/node.h>
 #include "internal.h"
 
-const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
 unsigned long hugepages_treat_as_movable;
 
 int hugetlb_max_hstate __read_mostly;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
