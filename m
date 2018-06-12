Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD4B6B0007
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z5-v6so12019576pfz.6
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:25 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v40-v6si235817pgn.467.2018.06.12.07.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:24 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 02/17] mm/khugepaged: Do not collapse pages in encrypted VMAs
Date: Tue, 12 Jun 2018 17:39:00 +0300
Message-Id: <20180612143915.68065-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 1c3c15f37ed6..435b053c457c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1492,6 +1492,13 @@ static inline bool vma_is_anonymous(struct vm_area_struct *vma)
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
index d7b2a4bf8671..a03b40bef033 100644
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
2.17.1
