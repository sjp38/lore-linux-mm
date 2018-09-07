Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 94A8C8E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 18:37:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q12-v6so7806544pgp.6
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 15:37:10 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f40-v6si9484448plb.504.2018.09.07.15.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 15:37:09 -0700 (PDT)
Date: Fri, 7 Sep 2018 15:37:51 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC 09/12] mm: Restrict memory encryption to anonymous VMA's
Message-ID: <f69e3d4f96504185054d951c7c85075ebf63e47a.1536356108.git.alison.schofield@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1536356108.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

Memory encryption is only supported for mappings that are ANONYMOUS.
Test the entire range of VMA's in an encrypt_mprotect() request to
make sure they all meet that requirement before encrypting any.

The encrypt_mprotect syscall will return -EINVAL and will not encrypt
any VMA's if this check fails.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
---
 mm/mprotect.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 6c2e1106525c..3384b755aad1 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -311,6 +311,24 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 	return pages;
 }
 
+/*
+ * Encrypted mprotect is only supported on anonymous mappings.
+ * All VMA's in the requested range must be anonymous. If this
+ * test fails on any single VMA, the entire mprotect request fails.
+ */
+bool mem_supports_encryption(struct vm_area_struct *vma, unsigned long end)
+{
+	struct vm_area_struct *test_vma = vma;
+
+	do {
+		if (!vma_is_anonymous(test_vma))
+			return false;
+
+		test_vma = test_vma->vm_next;
+	} while (test_vma && test_vma->vm_start < end);
+	return true;
+}
+
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	       unsigned long start, unsigned long end, unsigned long newflags,
@@ -491,6 +509,10 @@ static int do_mprotect_ext(unsigned long start, size_t len,
 				goto out;
 		}
 	}
+	if (keyid > 0 && !mem_supports_encryption(vma, end)) {
+		error = -EINVAL;
+		goto out;
+	}
 	if (start > vma->vm_start)
 		prev = vma;
 
-- 
2.14.1
