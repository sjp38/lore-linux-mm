Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED016B0006
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:25 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 31-v6so14147576plf.19
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:25 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id l5-v6si295495pls.360.2018.06.12.07.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:24 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 01/17] mm: Do no merge VMAs with different encryption KeyIDs
Date: Tue, 12 Jun 2018 17:38:59 +0300
Message-Id: <20180612143915.68065-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

VMAs with different KeyID do not mix together. Only VMAs with the same
KeyID are compatible.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 7 +++++++
 mm/mmap.c          | 3 ++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 02a616e2f17d..1c3c15f37ed6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1492,6 +1492,13 @@ static inline bool vma_is_anonymous(struct vm_area_struct *vma)
 	return !vma->vm_ops;
 }
 
+#ifndef vma_keyid
+static inline int vma_keyid(struct vm_area_struct *vma)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_SHMEM
 /*
  * The vma_is_shmem is not inline because it is used only by slow
diff --git a/mm/mmap.c b/mm/mmap.c
index d817764a9974..3ff89fc1752b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1217,7 +1217,8 @@ static int anon_vma_compatible(struct vm_area_struct *a, struct vm_area_struct *
 		mpol_equal(vma_policy(a), vma_policy(b)) &&
 		a->vm_file == b->vm_file &&
 		!((a->vm_flags ^ b->vm_flags) & ~(VM_READ|VM_WRITE|VM_EXEC|VM_SOFTDIRTY)) &&
-		b->vm_pgoff == a->vm_pgoff + ((b->vm_start - a->vm_start) >> PAGE_SHIFT);
+		b->vm_pgoff == a->vm_pgoff + ((b->vm_start - a->vm_start) >> PAGE_SHIFT) &&
+		vma_keyid(a) == vma_keyid(b);
 }
 
 /*
-- 
2.17.1
