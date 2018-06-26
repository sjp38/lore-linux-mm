Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C86DF6B0003
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:22:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l2-v6so8875341pff.3
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:22:53 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l190-v6si1524248pgd.375.2018.06.26.07.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 07:22:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 02/18] mm/ksm: Do not merge pages with different KeyIDs
Date: Tue, 26 Jun 2018 17:22:29 +0300
Message-Id: <20180626142245.82850-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Pages encrypted with different encryption keys are not subject to KSM
merge. Otherwise it would cross security boundary.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 7 +++++++
 mm/ksm.c           | 3 +++
 2 files changed, 10 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ebf4bd8bd0bf..406a28cadfcf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1548,6 +1548,13 @@ static inline int vma_keyid(struct vm_area_struct *vma)
 }
 #endif
 
+#ifndef page_keyid
+static inline int page_keyid(struct page *page)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_SHMEM
 /*
  * The vma_is_shmem is not inline because it is used only by slow
diff --git a/mm/ksm.c b/mm/ksm.c
index a6d43cf9a982..1bd7b9710e29 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1214,6 +1214,9 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 	if (!PageAnon(page))
 		goto out;
 
+	if (page_keyid(page) != page_keyid(kpage))
+		goto out;
+
 	/*
 	 * We need the page lock to read a stable PageSwapCache in
 	 * write_protect_page().  We use trylock_page() instead of
-- 
2.18.0
