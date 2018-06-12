Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 25B246B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:25 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q18-v6so9397921pll.3
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:25 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id w1-v6si242590pgp.10.2018.06.12.07.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:23 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 03/17] mm/ksm: Do not merge pages with different KeyIDs
Date: Tue, 12 Jun 2018 17:39:01 +0300
Message-Id: <20180612143915.68065-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
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
index 435b053c457c..ac1a8480284d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1506,6 +1506,13 @@ static inline int vma_keyid(struct vm_area_struct *vma)
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
index 7d6558f3bac9..db94bd45fe66 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1201,6 +1201,9 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 	if (!PageAnon(page))
 		goto out;
 
+	if (page_keyid(page) != page_keyid(kpage))
+		goto out;
+
 	/*
 	 * We need the page lock to read a stable PageSwapCache in
 	 * write_protect_page().  We use trylock_page() instead of
-- 
2.17.1
