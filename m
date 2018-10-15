Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id A402F6B000E
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 12:43:01 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id y22so15026331oty.3
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 09:43:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y17si4648178otg.75.2018.10.15.09.43.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 09:43:00 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9FGeikN014865
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 12:43:00 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2n4w9suyhb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 12:42:59 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 15 Oct 2018 17:42:57 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 1/3] mm: introduce mm_[p4d|pud|pmd]_folded
Date: Mon, 15 Oct 2018 18:42:37 +0200
In-Reply-To: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
Message-Id: <1539621759-5967-2-git-send-email-schwidefsky@de.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Add three architecture overrideable function to test if the
p4d, pud, or pmd layer of a page table is folded or not.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 include/linux/mm.h | 40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0416a7204be3..d1029972541c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -105,6 +105,46 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #define mm_zero_struct_page(pp)  ((void)memset((pp), 0, sizeof(struct page)))
 #endif
 
+/*
+ * On some architectures it depends on the mm if the p4d/pud or pmd
+ * layer of the page table hierarchy is folded or not.
+ */
+#ifndef mm_p4d_folded
+#define mm_p4d_folded(mm) mm_p4d_folded(mm)
+static inline bool mm_p4d_folded(struct mm_struct *mm)
+{
+#ifdef __PAGETABLE_P4D_FOLDED
+	return 1;
+#else
+	return 0;
+#endif
+}
+#endif
+
+#ifndef mm_pud_folded
+#define mm_pud_folded(mm) mm_pud_folded(mm)
+static inline bool mm_pud_folded(struct mm_struct *mm)
+{
+#ifdef __PAGETABLE_PUD_FOLDED
+	return 1;
+#else
+	return 0;
+#endif
+}
+#endif
+
+#ifndef mm_pmd_folded
+#define mm_pmd_folded(mm) mm_pmd_folded(mm)
+static inline bool mm_pmd_folded(struct mm_struct *mm)
+{
+#ifdef __PAGETABLE_PMD_FOLDED
+	return 1;
+#else
+	return 0;
+#endif
+}
+#endif
+
 /*
  * Default maximum number of active map areas, this limits the number of vmas
  * per mm struct. Users can overwrite this number by sysctl but there is a
-- 
2.16.4
