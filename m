Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC9D7C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:42:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96E6221743
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:42:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZpRGv8f/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96E6221743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DB3D6B0278; Thu,  8 Aug 2019 11:42:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28DE86B027A; Thu,  8 Aug 2019 11:42:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17BA26B027B; Thu,  8 Aug 2019 11:42:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE0766B0278
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:42:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h3so57940218pgc.19
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:42:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DWzNYvraQIYD6LapemoQ+wb9z56AA7KFDjghgkaZwFs=;
        b=R4G6Np7exyFziIFZE/X5Nf1O3m4Gkb2u3TEybT6FbcmY+c56fn4O+4STss8iIIrQ7K
         gXfoo6DmDLjheZM1bzEPl1vRL9oIKUjrkHR+ptN75yNulSIo9ooJ6JEgMkII7EUYMhNH
         6UI/2D/wHU0FBFxYq7K/opcMvx35S6piFbaBGbyMNTsiBuhUfThNGftwBOAZY1kejhO8
         Q3uPXV8RF+G9rOyNx1mqZ4fTG17tI8JlbQdbDB6Gl+T62vTFQUn4A11Kz9suXbxW614e
         si3XB43RmeoQOxBDLi+e13nHIqwxgSX4GQixTo+9quhGOO7RD7AQVGV4jIMPbxDxW8TL
         JEAQ==
X-Gm-Message-State: APjAAAU+iu/VPrzYL8F6a2XKEg71K1IGp8IJLhoMOFZSyWHoaN2Rd82V
	WIYPNPyPU2lpWx4Gw9iL+j+exDT+UJIhmuyvNcgrGAuXWi1Z11a+LSVJT6UfqfI8pGpmwGDI/D6
	KB1d1KwLYi/WIVeN1MYC9iLlo2/iq5hN03EHdW4U0hGU7i/ZMdjoB0jawlaebelw=
X-Received: by 2002:a17:90a:ab01:: with SMTP id m1mr4514020pjq.69.1565278971469;
        Thu, 08 Aug 2019 08:42:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLCVXzCjcL4KbVtiYZJn+eVjLWOYzr6lPycN7yAT0R2076zsSJgzcoG8ZI0cQNWgv7IPiT
X-Received: by 2002:a17:90a:ab01:: with SMTP id m1mr4513955pjq.69.1565278970231;
        Thu, 08 Aug 2019 08:42:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278970; cv=none;
        d=google.com; s=arc-20160816;
        b=itR8L4J1GhaFrB0P6wks7zaeWEdiTw2mY9F3hRTE3d96LJfKJe+015dLRf6fHYEqqQ
         GpxcQxZ32Ahhtwhat9Y6CU/XcSZfZ5QY4pEA1khUliw8/O8tGLQTVbHxA/KRZeoxsJX7
         y3nL8mccE1wqteZiqXqZz7amTaSjzl5PDkZ2IRHnx0cTxCRVbdFmeK/m54yOEflfTNmA
         VpNtL2jjwebGEA55DCXmuEYRtQjY41w7SgwX8AJM/PoOi0VgWJgfQVz0qIoFtuSyQiXx
         wC9yupxTA8koRDICNCh4NoaH1V9BQKHGUOVtf/fENor2yXf/lhwunA5EWHXu1DFWgioy
         7UgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=DWzNYvraQIYD6LapemoQ+wb9z56AA7KFDjghgkaZwFs=;
        b=bAV5Q9m9JMmtEHjNlYCj2VTolIGBjkmHfUPwDyqCtvpyDQR7sR37Wj8bLSCmOq2XGF
         3G9oWvGsEvLmUg/6ZUByr3QAO5e8PmJ53RtCn3hcE+70Qwrwqs4f2B9exjMVe7hIwR+/
         h5/0SlY4+ScBbOzqGzvumGlFFZl6XbKm73r8vh5N423N6UKG2YIA8QpvX3lONQzbXeLB
         qAgV/ZkIB2wNZbD0YSveKZqtLM65SF3xqrETf1VpkA0HSqDod0TD7EQzStHpPjbkzbH5
         SV28/+1nmK6iVcRBdG1Hn50qa9r6POG3sl783TRcsOYYfW0RbZfHbeWXgdfB+Dyh5hLe
         L9jA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="ZpRGv8f/";
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b3si51759197pfa.89.2019.08.08.08.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:42:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="ZpRGv8f/";
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=DWzNYvraQIYD6LapemoQ+wb9z56AA7KFDjghgkaZwFs=; b=ZpRGv8f/dwRfzGqRVT+tOIYoas
	QRAEcvdbEGpzAosbKhyCRfU2phKGlVcJsBsXRONX0b39ya7MR9WqPuKmAwmlFvwm7hf2y4csRuS7p
	VVg1zQVUNWyEBbFm1nvRQqgMdM6Q0mCo7baRBWDk98l23myUokmNy7bTbLfjdjRTXvI2N9Z8+UDvf
	y2bqrh9wczc7nFSTTHYBklOoK9fP3s+2j2Azo8PNjnt6JRn1UKl/WYe5s5yKK1ci7bKo+jHxVIlRU
	tvOMDPT4eWuuqdDedn+OpVhi7gaWbRyoGIuKDfFDQs4Zt2mJcFwv5dCOiimtS10Zt+MXL8zipBUWh
	vT4w+X5g==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkYv-0008UU-01; Thu, 08 Aug 2019 15:42:45 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?Thomas=20Hellstr=C3=B6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/3] mm: split out a new pagewalk.h header from mm.h
Date: Thu,  8 Aug 2019 18:42:38 +0300
Message-Id: <20190808154240.9384-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808154240.9384-1-hch@lst.de>
References: <20190808154240.9384-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a new header for the two handful of users of the walk_page_range /
walk_page_vma interface instead of polluting all users of mm.h with it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/openrisc/kernel/dma.c              |  1 +
 arch/powerpc/mm/book3s64/subpage_prot.c |  2 +-
 arch/s390/mm/gmap.c                     |  2 +-
 fs/proc/task_mmu.c                      |  2 +-
 include/linux/mm.h                      | 46 ---------------------
 include/linux/pagewalk.h                | 54 +++++++++++++++++++++++++
 mm/hmm.c                                |  2 +-
 mm/madvise.c                            |  1 +
 mm/memcontrol.c                         |  2 +-
 mm/mempolicy.c                          |  2 +-
 mm/migrate.c                            |  1 +
 mm/mincore.c                            |  2 +-
 mm/mprotect.c                           |  2 +-
 mm/pagewalk.c                           |  2 +-
 14 files changed, 66 insertions(+), 55 deletions(-)
 create mode 100644 include/linux/pagewalk.h

diff --git a/arch/openrisc/kernel/dma.c b/arch/openrisc/kernel/dma.c
index b41a79fcdbd9..c7812e6effa2 100644
--- a/arch/openrisc/kernel/dma.c
+++ b/arch/openrisc/kernel/dma.c
@@ -16,6 +16,7 @@
  */
 
 #include <linux/dma-noncoherent.h>
+#include <linux/pagewalk.h>
 
 #include <asm/cpuinfo.h>
 #include <asm/spr_defs.h>
diff --git a/arch/powerpc/mm/book3s64/subpage_prot.c b/arch/powerpc/mm/book3s64/subpage_prot.c
index 9ba07e55c489..236f0a861ecc 100644
--- a/arch/powerpc/mm/book3s64/subpage_prot.c
+++ b/arch/powerpc/mm/book3s64/subpage_prot.c
@@ -7,7 +7,7 @@
 #include <linux/kernel.h>
 #include <linux/gfp.h>
 #include <linux/types.h>
-#include <linux/mm.h>
+#include <linux/pagewalk.h>
 #include <linux/hugetlb.h>
 #include <linux/syscalls.h>
 
diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
index 39c3a6e3d262..cf80feae970d 100644
--- a/arch/s390/mm/gmap.c
+++ b/arch/s390/mm/gmap.c
@@ -9,7 +9,7 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/mm.h>
+#include <linux/pagewalk.h>
 #include <linux/swap.h>
 #include <linux/smp.h>
 #include <linux/spinlock.h>
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 731642e0f5a0..8857da830b86 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: GPL-2.0
-#include <linux/mm.h>
+#include <linux/pagewalk.h>
 #include <linux/vmacache.h>
 #include <linux/hugetlb.h>
 #include <linux/huge_mm.h>
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..7cf955feb823 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1430,54 +1430,8 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long address,
 void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long start, unsigned long end);
 
-/**
- * mm_walk - callbacks for walk_page_range
- * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
- *	       this handler should only handle pud_trans_huge() puds.
- *	       the pmd_entry or pte_entry callbacks will be used for
- *	       regular PUDs.
- * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
- *	       this handler is required to be able to handle
- *	       pmd_trans_huge() pmds.  They may simply choose to
- *	       split_huge_page() instead of handling it explicitly.
- * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
- * @pte_hole: if set, called for each hole at all levels
- * @hugetlb_entry: if set, called for each hugetlb entry
- * @test_walk: caller specific callback function to determine whether
- *             we walk over the current vma or not. Returning 0
- *             value means "do page table walk over the current vma,"
- *             and a negative one means "abort current page table walk
- *             right now." 1 means "skip the current vma."
- * @mm:        mm_struct representing the target process of page table walk
- * @vma:       vma currently walked (NULL if walking outside vmas)
- * @private:   private data for callbacks' usage
- *
- * (see the comment on walk_page_range() for more details)
- */
-struct mm_walk {
-	int (*pud_entry)(pud_t *pud, unsigned long addr,
-			 unsigned long next, struct mm_walk *walk);
-	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
-			 unsigned long next, struct mm_walk *walk);
-	int (*pte_entry)(pte_t *pte, unsigned long addr,
-			 unsigned long next, struct mm_walk *walk);
-	int (*pte_hole)(unsigned long addr, unsigned long next,
-			struct mm_walk *walk);
-	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
-			     unsigned long addr, unsigned long next,
-			     struct mm_walk *walk);
-	int (*test_walk)(unsigned long addr, unsigned long next,
-			struct mm_walk *walk);
-	struct mm_struct *mm;
-	struct vm_area_struct *vma;
-	void *private;
-};
-
 struct mmu_notifier_range;
 
-int walk_page_range(unsigned long addr, unsigned long end,
-		struct mm_walk *walk);
-int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
diff --git a/include/linux/pagewalk.h b/include/linux/pagewalk.h
new file mode 100644
index 000000000000..df278a94086d
--- /dev/null
+++ b/include/linux/pagewalk.h
@@ -0,0 +1,54 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _LINUX_PAGEWALK_H
+#define _LINUX_PAGEWALK_H
+
+#include <linux/mm.h>
+
+/**
+ * mm_walk - callbacks for walk_page_range
+ * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
+ *	       this handler should only handle pud_trans_huge() puds.
+ *	       the pmd_entry or pte_entry callbacks will be used for
+ *	       regular PUDs.
+ * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
+ *	       this handler is required to be able to handle
+ *	       pmd_trans_huge() pmds.  They may simply choose to
+ *	       split_huge_page() instead of handling it explicitly.
+ * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
+ * @pte_hole: if set, called for each hole at all levels
+ * @hugetlb_entry: if set, called for each hugetlb entry
+ * @test_walk: caller specific callback function to determine whether
+ *             we walk over the current vma or not. Returning 0
+ *             value means "do page table walk over the current vma,"
+ *             and a negative one means "abort current page table walk
+ *             right now." 1 means "skip the current vma."
+ * @mm:        mm_struct representing the target process of page table walk
+ * @vma:       vma currently walked (NULL if walking outside vmas)
+ * @private:   private data for callbacks' usage
+ *
+ * (see the comment on walk_page_range() for more details)
+ */
+struct mm_walk {
+	int (*pud_entry)(pud_t *pud, unsigned long addr,
+			 unsigned long next, struct mm_walk *walk);
+	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
+			 unsigned long next, struct mm_walk *walk);
+	int (*pte_entry)(pte_t *pte, unsigned long addr,
+			 unsigned long next, struct mm_walk *walk);
+	int (*pte_hole)(unsigned long addr, unsigned long next,
+			struct mm_walk *walk);
+	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
+			     unsigned long addr, unsigned long next,
+			     struct mm_walk *walk);
+	int (*test_walk)(unsigned long addr, unsigned long next,
+			struct mm_walk *walk);
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	void *private;
+};
+
+int walk_page_range(unsigned long addr, unsigned long end,
+		struct mm_walk *walk);
+int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
+
+#endif /* _LINUX_PAGEWALK_H */
diff --git a/mm/hmm.c b/mm/hmm.c
index 16b6731a34db..909b846c11d4 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -8,7 +8,7 @@
  * Refer to include/linux/hmm.h for information about heterogeneous memory
  * management or HMM for short.
  */
-#include <linux/mm.h>
+#include <linux/pagewalk.h>
 #include <linux/hmm.h>
 #include <linux/init.h>
 #include <linux/rmap.h>
diff --git a/mm/madvise.c b/mm/madvise.c
index 968df3aa069f..80a78bb16782 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -20,6 +20,7 @@
 #include <linux/file.h>
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
+#include <linux/pagewalk.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/shmem_fs.h>
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cdbb7a84cb6e..ee01175e56d4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -25,7 +25,7 @@
 #include <linux/page_counter.h>
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
-#include <linux/mm.h>
+#include <linux/pagewalk.h>
 #include <linux/sched/mm.h>
 #include <linux/shmem_fs.h>
 #include <linux/hugetlb.h>
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f48693f75b37..1ee6b6f49431 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -68,7 +68,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/mempolicy.h>
-#include <linux/mm.h>
+#include <linux/pagewalk.h>
 #include <linux/highmem.h>
 #include <linux/hugetlb.h>
 #include <linux/kernel.h>
diff --git a/mm/migrate.c b/mm/migrate.c
index a42858d8e00b..019c426c6ef7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -38,6 +38,7 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
+#include <linux/pagewalk.h>
 #include <linux/pfn_t.h>
 #include <linux/memremap.h>
 #include <linux/userfaultfd_k.h>
diff --git a/mm/mincore.c b/mm/mincore.c
index 4fe91d497436..3b051b6ab3fe 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -10,7 +10,7 @@
  */
 #include <linux/pagemap.h>
 #include <linux/gfp.h>
-#include <linux/mm.h>
+#include <linux/pagewalk.h>
 #include <linux/mman.h>
 #include <linux/syscalls.h>
 #include <linux/swap.h>
diff --git a/mm/mprotect.c b/mm/mprotect.c
index bf38dfbbb4b4..cc73318dbc25 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -9,7 +9,7 @@
  *  (C) Copyright 2002 Red Hat Inc, All Rights Reserved
  */
 
-#include <linux/mm.h>
+#include <linux/pagewalk.h>
 #include <linux/hugetlb.h>
 #include <linux/shm.h>
 #include <linux/mman.h>
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index c3084ff2569d..8a92a961a2ee 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: GPL-2.0
-#include <linux/mm.h>
+#include <linux/pagewalk.h>
 #include <linux/highmem.h>
 #include <linux/sched.h>
 #include <linux/hugetlb.h>
-- 
2.20.1

