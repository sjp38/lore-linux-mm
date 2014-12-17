Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E55E76B006C
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 09:31:03 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so16572869pad.27
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 06:31:03 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id s12si5882069pdl.116.2014.12.17.06.31.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 17 Dec 2014 06:31:02 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NGQ007Z3DUDNK30@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 17 Dec 2014 14:35:01 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH 2/2] mm: hugetlb: fix type of hugetlb_treat_as_movable variable
Date: Wed, 17 Dec 2014 17:30:50 +0300
Message-id: <1418826650-10145-2-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1418826650-10145-1-git-send-email-a.ryabinin@samsung.com>
References: <548CA6B6.3060901@colorfullife.com>
 <1418826650-10145-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Manfred Spraul <manfred@colorfullife.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "nadia.derbey@bull.net" <Nadia.Derbey@bull.net>, aquini@redhat.com, Joe Perches <joe@perches.com>, avagin@openvz.org, LKML <linux-kernel@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <andreyknvl@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>, kasan-dev <kasan-dev@googlegroups.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org

hugetlb_treat_as_movable declared as unsigned long, but
proc_dointvec() used for parsing it:

static struct ctl_table vm_table[] = {
...
	{
		.procname	= "hugepages_treat_as_movable",
		.data		= &hugepages_treat_as_movable,
		.maxlen		= sizeof(int),
		.mode		= 0644,
		.proc_handler	= proc_dointvec,
	},

This seems harmless, but it's better to use int type here.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/hugetlb.h | 2 +-
 mm/hugetlb.c            | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 431b7fc..7d78563 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -86,7 +86,7 @@ void free_huge_page(struct page *page);
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
 #endif
 
-extern unsigned long hugepages_treat_as_movable;
+extern int hugepages_treat_as_movable;
 extern int sysctl_hugetlb_shm_group;
 extern struct list_head huge_boot_pages;
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 85032de..be0e5d0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -35,7 +35,7 @@
 #include <linux/node.h>
 #include "internal.h"
 
-unsigned long hugepages_treat_as_movable;
+int hugepages_treat_as_movable;
 
 int hugetlb_max_hstate __read_mostly;
 unsigned int default_hstate_idx;
-- 
2.2.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
