Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65650681021
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 20:34:10 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 145so46051577pfv.6
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 17:34:10 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id c9si8630964pge.126.2017.02.16.17.34.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 17:34:09 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id a123so617478pgc.3
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 17:34:09 -0800 (PST)
From: Seunghun Han <kkamagui@gmail.com>
Subject: [PATCH] x86: kernel: fix unused variable warning in vm86_32.c
Date: Fri, 17 Feb 2017 10:32:53 +0900
Message-Id: <1487295173-39828-1-git-send-email-kkamagui@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Seunghun Han <kkamagui@gmail.com>

If CONFIG_TRANSPARENT_HUGEPAGE is not set in kernel config, a warning is shown
in vm86_32.c.

The warning is as follows:
>arch/x86/kernel/vm86_32.c: In function a??mark_screen_rdonlya??:
>arch/x86/kernel/vm86_32.c:180:26: warning: unused variable a??vmaa?? [-Wunused-variable]
> struct vm_area_struct *vma = find_vma(mm, 0xA0000);

The vma variable is used to call split_huge_pmd() macro function, but
split_huge_pmd() is defined as a null macro when CONFIG_TRANSPARENT_HUGEPAGE is
not set in kernel config. Therefore, the compiler shows an unused variable
warning.

To remove this warning, I change the split_huge_pmd() macro function to static
inline function and static inline null function.
Inline function works like a macro function, therefore there is no impact on
Linux kernel working.

Signed-off-by: Seunghun Han <kkamagui@gmail.com>
---
 include/linux/huge_mm.h | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a3762d4..912a763 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -123,15 +123,12 @@ void deferred_split_huge_page(struct page *page);
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long address, bool freeze, struct page *page);
 
-#define split_huge_pmd(__vma, __pmd, __address)				\
-	do {								\
-		pmd_t *____pmd = (__pmd);				\
-		if (pmd_trans_huge(*____pmd)				\
-					|| pmd_devmap(*____pmd))	\
-			__split_huge_pmd(__vma, __pmd, __address,	\
-						false, NULL);		\
-	}  while (0)
-
+static inline void split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long address)
+{
+	if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
+		__split_huge_pmd(vma, pmd, address, false, NULL);
+}
 
 void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
 		bool freeze, struct page *page);
@@ -241,9 +238,8 @@ static inline int split_huge_page(struct page *page)
 	return 0;
 }
 static inline void deferred_split_huge_page(struct page *page) {}
-#define split_huge_pmd(__vma, __pmd, __address)	\
-	do { } while (0)
-
+static inline void split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long address) {}
 static inline void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long address, bool freeze, struct page *page) {}
 static inline void split_huge_pmd_address(struct vm_area_struct *vma,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
