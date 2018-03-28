Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3A3A6B005C
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:55:50 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 1-v6so2112309plv.6
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:55:50 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id x10si2625159pgo.58.2018.03.28.09.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 09:55:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 05/14] mm/khugepaged: Do not collapse pages in encrypted VMAs
Date: Wed, 28 Mar 2018 19:55:31 +0300
Message-Id: <20180328165540.648-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Pages for encrypted VMAs have to be allocated in a special way:
we would need to propagate down not only desired NUMA node but also
whether the page is encrypted.

It complicates not-so-trivial routine of huge page allocation in
khugepaged even more. It also puts more pressure on page allocator:
we cannot re-use pages allocated for encrypted VMA to collapse
page in unencrypted one or vice versa.

I think for now it worth skipping encrypted VMAs. We can return
to this topic later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 7 +++++++
 mm/khugepaged.c    | 2 ++
 2 files changed, 9 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6c50f77c75d5..b6a72eb82f4b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1479,6 +1479,13 @@ static inline bool vma_is_anonymous(struct vm_area_struct *vma)
 	return !vma->vm_ops;
 }
 
+#ifndef vma_is_encrypted
+static inline bool vma_is_encrypted(struct vm_area_struct *vma)
+{
+	return false;
+}
+#endif
+
 #ifndef vma_keyid
 static inline int vma_keyid(struct vm_area_struct *vma)
 {
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index e42568284e06..42f33fd526a0 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -835,6 +835,8 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
+	if (vma_is_encrypted(vma))
+		return false;
 	return !(vma->vm_flags & VM_NO_KHUGEPAGED);
 }
 
-- 
2.16.2
