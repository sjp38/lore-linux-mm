Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CA1AC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8606F222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="c2lHRGx9";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="bfbHC/yF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8606F222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7E4C8E000A; Fri, 15 Feb 2019 17:09:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB5DE8E0009; Fri, 15 Feb 2019 17:09:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AA2E8E000A; Fri, 15 Feb 2019 17:09:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 387D68E0004
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:14 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id y31so10419895qty.9
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=3cA+2Qizqf7/apl9HV9mIsP7j8kj4eY2mH2wbR+KHig=;
        b=paVwNvKqwjQ9bxKWzb+P0aXMrRaB8UGJcZ1VASIuzs5QbWSgtYOS8PJqoMtH+FCZj2
         V43xIGs6/8vbcr4zx3Sh+yE6kygoxtqgdpZtTNVJTPvi2cF7tAswa0ipsPkQ+g/vbTTx
         cRpQYu+lfql/kbILx0Gp48WaGdYm6cyNALHiIejYI08NS1we+0Nuunz43REV+lr90x/B
         BXGCXBCIyOGuE+uoUM5Q9fS+IpdbTVhmXukvezzM35Su+waaWlVe7N43vqmTRIn6yB3Y
         Z6UjZqebSiL/iaHiDxGDrbXJPFD7LQ9+9OwMl7tDfoQfz010IvMYgb0FuURe80p35E3T
         o2gg==
X-Gm-Message-State: AHQUAubQ10wSV7SqlFo6Ug7aGo2Va6OZ86xRM1dzvejdmcOpsQ5Ko5LD
	qYsuYmnk8SSv355quK7chEjjAdY8oFM029+rZBpN86S/vLB49+A9Jh+bC3W9XufA1FDvveQFk77
	tiKNRjvzO47OlqRwvENLfhqUz0AKdSJPOtnfQpw1tNqdZIkjvhZKlmP0v/ndNh0b7ZA==
X-Received: by 2002:a05:620a:136d:: with SMTP id d13mr8861036qkl.256.1550268553755;
        Fri, 15 Feb 2019 14:09:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaSr1H6QLY3cRAaS3/2DFTBQm7YFQmRvjm18/3o4yCwJgFFHuwrwusy5BtuDhtEcfa+dxHF
X-Received: by 2002:a05:620a:136d:: with SMTP id d13mr8860831qkl.256.1550268549836;
        Fri, 15 Feb 2019 14:09:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268549; cv=none;
        d=google.com; s=arc-20160816;
        b=E9Jj/ZkTChITiFrhXqcfmE71bmSItfzLPelvkeRdLw83aDtxbfw6ifI+6xWEvlMdUt
         QS5wI5/1w/V/hEKmgayc00ceh7bc/1Pp132mSLQn12Et+7PJbUmHs26W+ccgOboa9ITg
         UzoZdiNMBVdOZ4U5FRlIH+Ztn4+gjC18rW5iUw8EHLYrPliddL3JvKVDPZZ3781IVU5N
         NBOCS6CoZjA+vF2dF5Q3+AUzVnSn5vETxEWMARs63LqHtwMiwUXWGxbYAYsDHtaN5T53
         BkgLm1QrAS3zyOK42HO5q4RvgJAqi4u6xLp7ocFQtfZHgz8YEU9UGM6EPlpcrJd3zLVn
         Wj3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=3cA+2Qizqf7/apl9HV9mIsP7j8kj4eY2mH2wbR+KHig=;
        b=LsmG8t9YGt7jacVAw6nTP08Ca3TEbKNTsjcgaJzGaBc6zoZgI5tkMl+AE36WyrTTbW
         f0qtEKQFdZHQHwuOegSz+7So3m7753nxVZI/cQlB/5P8mruJ9ODPJv+SzzPK8A/HWy3S
         PovhQWIByQD2LCxvT1YjY7bAFNrJrdZpCf7Njrao4AA0YOUP/C6n9lItNQkMjsK3+uCJ
         aZ6qSx7cN0HKDO3oehkSCL9C4yl1f+VGB1ewXj3w4ULg0Bp9rfdglaa8dbhtKC3OYXpC
         RgQWPnkQ8zQwmIDrSdESi50xdHoGg2snxiv1WDGNZVHqloMsJPsBm7sd4o5OHJrgKhdr
         AYyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=c2lHRGx9;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="bfbHC/yF";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id u10si834070qvm.104.2019.02.15.14.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:09 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=c2lHRGx9;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="bfbHC/yF";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id E13C1328F;
	Fri, 15 Feb 2019 17:09:07 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:08 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=3cA+2Qizqf7/a
	pl9HV9mIsP7j8kj4eY2mH2wbR+KHig=; b=c2lHRGx9Nz5W6H4kv5OG6D7lgiOiu
	La+zEdWorQy2nBfdlMBaTSY9rPOJXYKur7/xu1dxnOhTHupyecUoeee7+Ej+Giv8
	JATdqE7/qUHjwjqE7Xr+YQYyL4s98cz/LxqDxzHWTfnWc4lBc64OHU7HXwTuPjqQ
	8U4NsGyWjHia0eD9JoCO2kE0ov/TxNJ/YFcKoeHx+b6bISTU85z9al7gL4Fz9cCi
	DlXKtpvWimTcAfSeo6JFBOLJ6zLgsZb1pBgYD2PHMsjLByMjQwIt+ZKoGB+FkUxh
	pdDmeoi4U5cNb5KudMeDf85xEPkAt5Eza6h9uV5j1Hwzo/rTZ1Em+1SYw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=3cA+2Qizqf7/apl9HV9mIsP7j8kj4eY2mH2wbR+KHig=; b=bfbHC/yF
	HpNYqR8ocwDwAhvwUtJazb0JFtD8IYOjZhOy5rTdvNi8sWLbBgGs6oR5Um0AMaIx
	KSo0D0aE2ijTOmUBtqLUc5LOhOF8H4Cqu6zx8rnfvwXSDLZqmis0By5UYU6TN9pp
	TkSOMQ3GRxJ5BS50UzWbUuxO2A/qEs5aS+NcWBPHuatvpNQFjgLWJ9h40bpG+rNc
	IpJNCgaGTkM+4bANtTDS9xdTKNQVMd6vaKZD5YJdrz5mjuC1unouUgJ7NPrysLkx
	mlygnTYDKusRBzR9FpVnMAlxHeo84pgZLUOJkjy15hioRkqvrlNAzIjUmxOh+ZwH
	snyoT+4S7m613Q==
X-ME-Sender: <xms:gzhnXHL4m84yMEx1ouIQSgfA8WOvKGNoNELeKJIH7FW8PqAdjFe64g>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedu
X-ME-Proxy: <xmx:gzhnXI9gVS1L19SjaLP9HFTLiAKcixZt4fh6JvvGyN9ge1rORYYq5g>
    <xmx:gzhnXCAV5S52yer9Dxokn3q8gINVptG12-JNIyJhEn8VODD-BQ0reg>
    <xmx:gzhnXDnet5m_zpV-0ZkyyKTCumlfygc7BCTrrSOENya6volmyIv6BA>
    <xmx:gzhnXDn6t5GCfydL7p_kiVEzfSi2g-eK-0dx9TQkQXMlObn0m_c5eg>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 9ADDBE4597;
	Fri, 15 Feb 2019 17:09:05 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 04/31] mm: add mem_defrag functionality.
Date: Fri, 15 Feb 2019 14:08:29 -0800
Message-Id: <20190215220856.29749-5-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

Create contiguous physical memory regions by migrating/exchanging pages.

1. It scans all VMAs in one process and determines an anchor pair
(VPN, PFN) for each VMA.
2. Then, it migrates/exchanges pages in each VMA to make
them aligned with the anchor pair.

At the end of day, a physically contiguous region should be created for
each VMA in the physical address range [PFN, PFN + VMA size).

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/entry/syscalls/syscall_64.tbl |    1 +
 fs/exec.c                              |    4 +
 include/linux/mem_defrag.h             |   60 +
 include/linux/mm.h                     |   12 +
 include/linux/mm_types.h               |    4 +
 include/linux/sched/coredump.h         |    3 +
 include/linux/syscalls.h               |    3 +
 include/linux/vm_event_item.h          |   23 +
 include/uapi/asm-generic/mman-common.h |    3 +
 kernel/fork.c                          |    9 +
 kernel/sysctl.c                        |   79 +-
 mm/Makefile                            |    1 +
 mm/compaction.c                        |   17 +-
 mm/huge_memory.c                       |    4 +
 mm/internal.h                          |   28 +
 mm/khugepaged.c                        |    1 +
 mm/madvise.c                           |   15 +
 mm/mem_defrag.c                        | 1782 ++++++++++++++++++++++++
 mm/memory.c                            |    7 +
 mm/mmap.c                              |   29 +
 mm/page_alloc.c                        |    4 +-
 mm/vmstat.c                            |   21 +
 22 files changed, 2096 insertions(+), 14 deletions(-)
 create mode 100644 include/linux/mem_defrag.h
 create mode 100644 mm/mem_defrag.c

diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index f0b1709a5ffb..374c11e3cf80 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -343,6 +343,7 @@
 332	common	statx			__x64_sys_statx
 333	common	io_pgetevents		__x64_sys_io_pgetevents
 334	common	rseq			__x64_sys_rseq
+335	common	scan_process_memory		__x64_sys_scan_process_memory
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/exec.c b/fs/exec.c
index fb72d36f7823..b71b9d305d7d 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1010,7 +1010,11 @@ static int exec_mmap(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
 	struct mm_struct *old_mm, *active_mm;
+	int move_mem_defrag = current->mm ?
+		test_bit(MMF_VM_MEM_DEFRAG_ALL, &current->mm->flags):0;
 
+	if (move_mem_defrag && mm)
+		set_bit(MMF_VM_MEM_DEFRAG_ALL, &mm->flags);
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
 	old_mm = current->mm;
diff --git a/include/linux/mem_defrag.h b/include/linux/mem_defrag.h
new file mode 100644
index 000000000000..43954a316752
--- /dev/null
+++ b/include/linux/mem_defrag.h
@@ -0,0 +1,60 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * mem_defrag.h Memory defragmentation function.
+ *
+ * Copyright (C) 2019 Zi Yan <ziy@nvidia.com>
+ *
+ *
+ */
+#ifndef _LINUX_KMEM_DEFRAGD_H
+#define _LINUX_KMEM_DEFRAGD_H
+
+#include <linux/sched/coredump.h> /* MMF_VM_MEM_DEFRAG */
+
+#define MEM_DEFRAG_SCAN				0
+#define MEM_DEFRAG_MARK_SCAN_ALL	1
+#define MEM_DEFRAG_CLEAR_SCAN_ALL	2
+#define MEM_DEFRAG_DEFRAG			3
+#define MEM_DEFRAG_CONTIG_SCAN		5
+
+enum mem_defrag_action {
+	MEM_DEFRAG_FULL_STATS = 0,
+	MEM_DEFRAG_DO_DEFRAG,
+	MEM_DEFRAG_CONTIG_STATS,
+};
+
+extern int kmem_defragd_always;
+
+extern int __kmem_defragd_enter(struct mm_struct *mm);
+extern void __kmem_defragd_exit(struct mm_struct *mm);
+extern int memdefrag_madvise(struct vm_area_struct *vma,
+		     unsigned long *vm_flags, int advice);
+
+static inline int kmem_defragd_fork(struct mm_struct *mm,
+		struct mm_struct *oldmm)
+{
+	if (test_bit(MMF_VM_MEM_DEFRAG, &oldmm->flags))
+		return __kmem_defragd_enter(mm);
+	return 0;
+}
+
+static inline void kmem_defragd_exit(struct mm_struct *mm)
+{
+	if (test_bit(MMF_VM_MEM_DEFRAG, &mm->flags))
+		__kmem_defragd_exit(mm);
+}
+
+static inline int kmem_defragd_enter(struct vm_area_struct *vma,
+				   unsigned long vm_flags)
+{
+	if (!test_bit(MMF_VM_MEM_DEFRAG, &vma->vm_mm->flags))
+		if (((kmem_defragd_always ||
+		     ((vm_flags & VM_MEMDEFRAG))) &&
+		    !(vm_flags & VM_NOMEMDEFRAG)) ||
+			test_bit(MMF_VM_MEM_DEFRAG_ALL, &vma->vm_mm->flags))
+			if (__kmem_defragd_enter(vma->vm_mm))
+				return -ENOMEM;
+	return 0;
+}
+
+#endif /* _LINUX_KMEM_DEFRAGD_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..5bcc1b03372a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -251,13 +251,20 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_5	37	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_6	38	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
 #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
+#define VM_HIGH_ARCH_5	BIT(VM_HIGH_ARCH_BIT_5)
+#define VM_HIGH_ARCH_6	BIT(VM_HIGH_ARCH_BIT_6)
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
+#define VM_MEMDEFRAG	VM_HIGH_ARCH_5	/* memory defrag */
+#define VM_NOMEMDEFRAG	VM_HIGH_ARCH_6	/* no memory defrag */
+
 #ifdef CONFIG_ARCH_HAS_PKEYS
 # define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
 # define VM_PKEY_BIT0	VM_HIGH_ARCH_0	/* A protection key is a 4-bit value */
@@ -487,6 +494,9 @@ static inline void vma_init(struct vm_area_struct *vma, struct mm_struct *mm)
 	vma->vm_mm = mm;
 	vma->vm_ops = &dummy_vm_ops;
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
+	vma->anchor_page_rb = RB_ROOT_CACHED;
+	vma->vma_create_jiffies = jiffies;
+	vma->vma_defrag_jiffies = 0;
 }
 
 static inline void vma_set_anonymous(struct vm_area_struct *vma)
@@ -2837,6 +2847,8 @@ static inline bool debug_guardpage_enabled(void) { return false; }
 static inline bool page_is_guard(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
+void free_anchor_pages(struct vm_area_struct *vma);
+
 #if MAX_NUMNODES > 1
 void __init setup_nr_node_ids(void);
 #else
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c471a2c43fa..32549b255d25 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -328,6 +328,10 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
+	struct rb_root_cached anchor_page_rb;
+	unsigned long vma_create_jiffies; /* life time of the vma  */
+	unsigned long vma_modify_jiffies; /* being modified time of the vma */
+	unsigned long vma_defrag_jiffies; /* being defragged time of the vma */
 } __randomize_layout;
 
 struct core_thread {
diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
index ecdc6542070f..52ad71db6687 100644
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -76,5 +76,8 @@ static inline int get_dumpable(struct mm_struct *mm)
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
 				 MMF_DISABLE_THP_MASK)
+#define MMF_VM_MEM_DEFRAG	26	/* set mm is added to do mem defrag */
+#define MMF_VM_MEM_DEFRAG_ALL	27	/* all vmas in the mm will be mem defrag */
+
 
 #endif /* _LINUX_SCHED_COREDUMP_H */
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 257cccba3062..caa6f043b29a 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -926,6 +926,8 @@ asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
 			  unsigned mask, struct statx __user *buffer);
 asmlinkage long sys_rseq(struct rseq __user *rseq, uint32_t rseq_len,
 			 int flags, uint32_t sig);
+asmlinkage long sys_scan_process_memory(pid_t pid, char __user *out_buf,
+			int buf_len, int action);
 
 /*
  * Architecture-specific system calls
@@ -1315,4 +1317,5 @@ static inline unsigned int ksys_personality(unsigned int personality)
 	return old;
 }
 
+
 #endif
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 47a3441cf4c4..6b32c8243616 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -109,6 +109,29 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_SWAP
 		SWAP_RA,
 		SWAP_RA_HIT,
+#endif
+		/* MEM_DEFRAG STATS  */
+		MEM_DEFRAG_DEFRAG_NUM,
+		MEM_DEFRAG_SCAN_NUM,
+		MEM_DEFRAG_DST_FREE_PAGES,
+		MEM_DEFRAG_DST_ANON_PAGES,
+		MEM_DEFRAG_DST_FILE_PAGES,
+		MEM_DEFRAG_DST_NONLRU_PAGES,
+		MEM_DEFRAG_DST_FREE_PAGES_FAILED,
+		MEM_DEFRAG_DST_FREE_PAGES_OVERFLOW_FAILED,
+		MEM_DEFRAG_DST_ANON_PAGES_FAILED,
+		MEM_DEFRAG_DST_FILE_PAGES_FAILED,
+		MEM_DEFRAG_DST_NONLRU_PAGES_FAILED,
+		MEM_DEFRAG_SRC_ANON_PAGES_FAILED,
+		MEM_DEFRAG_SRC_COMP_PAGES_FAILED,
+		MEM_DEFRAG_DST_SPLIT_HUGEPAGES,
+#ifdef CONFIG_COMPACTION
+		/* memory compaction */
+		COMPACT_MIGRATE_PAGES,
+#endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		/* thp collapse */
+		THP_COLLAPSE_MIGRATE_PAGES,
 #endif
 		NR_VM_EVENT_ITEMS
 };
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index e7ee32861d51..d1ec94a1970d 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -66,6 +66,9 @@
 #define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
 #define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
 
+#define MADV_MEMDEFRAG	20		/* Worth backing with hugepages */
+#define MADV_NOMEMDEFRAG	21		/* Not worth backing with hugepages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/kernel/fork.c b/kernel/fork.c
index b69248e6f0e0..dcefa978c232 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -92,6 +92,7 @@
 #include <linux/livepatch.h>
 #include <linux/thread_info.h>
 #include <linux/stackleak.h>
+#include <linux/mem_defrag.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -343,12 +344,16 @@ struct vm_area_struct *vm_area_dup(struct vm_area_struct *orig)
 	if (new) {
 		*new = *orig;
 		INIT_LIST_HEAD(&new->anon_vma_chain);
+		new->anchor_page_rb = RB_ROOT_CACHED;
+		new->vma_create_jiffies = jiffies;
+		new->vma_defrag_jiffies = 0;
 	}
 	return new;
 }
 
 void vm_area_free(struct vm_area_struct *vma)
 {
+	free_anchor_pages(vma);
 	kmem_cache_free(vm_area_cachep, vma);
 }
 
@@ -496,6 +501,9 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	if (retval)
 		goto out;
 	retval = khugepaged_fork(mm, oldmm);
+	if (retval)
+		goto out;
+	retval = kmem_defragd_fork(mm, oldmm);
 	if (retval)
 		goto out;
 
@@ -1044,6 +1052,7 @@ static inline void __mmput(struct mm_struct *mm)
 	exit_aio(mm);
 	ksm_exit(mm);
 	khugepaged_exit(mm); /* must run before exit_mmap */
+	kmem_defragd_exit(mm);
 	exit_mmap(mm);
 	mm_put_huge_zero_page(mm);
 	set_mm_exe_file(mm, NULL);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ba4d9e85feb8..6bf0be1af7e0 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -115,6 +115,13 @@ extern unsigned int sysctl_nr_open_min, sysctl_nr_open_max;
 extern int sysctl_nr_trim_pages;
 #endif
 
+extern int kmem_defragd_always;
+extern int vma_scan_percentile;
+extern int vma_scan_threshold_type;
+extern int vma_no_repeat_defrag;
+extern int num_breakout_chunks;
+extern int defrag_size_threshold;
+
 /* Constants used for minimum and  maximum */
 #ifdef CONFIG_LOCKUP_DETECTOR
 static int sixty = 60;
@@ -1303,7 +1310,7 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= overcommit_kbytes_handler,
 	},
 	{
-		.procname	= "page-cluster", 
+		.procname	= "page-cluster",
 		.data		= &page_cluster,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
@@ -1691,6 +1698,58 @@ static struct ctl_table vm_table[] = {
 		.extra2		= (void *)&mmap_rnd_compat_bits_max,
 	},
 #endif
+	{
+		.procname	= "kmem_defragd_always",
+		.data		= &kmem_defragd_always,
+		.maxlen		= sizeof(kmem_defragd_always),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+	{
+		.procname	= "vma_scan_percentile",
+		.data		= &vma_scan_percentile,
+		.maxlen		= sizeof(vma_scan_percentile),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
+	{
+		.procname	= "vma_scan_threshold_type",
+		.data		= &vma_scan_threshold_type,
+		.maxlen		= sizeof(vma_scan_threshold_type),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+	{
+		.procname	= "vma_no_repeat_defrag",
+		.data		= &vma_no_repeat_defrag,
+		.maxlen		= sizeof(vma_no_repeat_defrag),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+	{
+		.procname	= "num_breakout_chunks",
+		.data		= &num_breakout_chunks,
+		.maxlen		= sizeof(num_breakout_chunks),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+	},
+	{
+		.procname	= "defrag_size_threshold",
+		.data		= &defrag_size_threshold,
+		.maxlen		= sizeof(defrag_size_threshold),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+	},
 	{ }
 };
 
@@ -1807,7 +1866,7 @@ static struct ctl_table fs_table[] = {
 		.mode		= 0555,
 		.child		= inotify_table,
 	},
-#endif	
+#endif
 #ifdef CONFIG_EPOLL
 	{
 		.procname	= "epoll",
@@ -2252,12 +2311,12 @@ static int __do_proc_dointvec(void *tbl_data, struct ctl_table *table,
 	int *i, vleft, first = 1, err = 0;
 	size_t left;
 	char *kbuf = NULL, *p;
-	
+
 	if (!tbl_data || !table->maxlen || !*lenp || (*ppos && !write)) {
 		*lenp = 0;
 		return 0;
 	}
-	
+
 	i = (int *) tbl_data;
 	vleft = table->maxlen / sizeof(*i);
 	left = *lenp;
@@ -2483,7 +2542,7 @@ static int do_proc_douintvec(struct ctl_table *table, int write,
  * @ppos: file position
  *
  * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
- * values from/to the user buffer, treated as an ASCII string. 
+ * values from/to the user buffer, treated as an ASCII string.
  *
  * Returns 0 on success.
  */
@@ -2974,7 +3033,7 @@ static int do_proc_dointvec_ms_jiffies_conv(bool *negp, unsigned long *lvalp,
  * @ppos: file position
  *
  * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
- * values from/to the user buffer, treated as an ASCII string. 
+ * values from/to the user buffer, treated as an ASCII string.
  * The values read are assumed to be in seconds, and are converted into
  * jiffies.
  *
@@ -2996,8 +3055,8 @@ int proc_dointvec_jiffies(struct ctl_table *table, int write,
  * @ppos: pointer to the file position
  *
  * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
- * values from/to the user buffer, treated as an ASCII string. 
- * The values read are assumed to be in 1/USER_HZ seconds, and 
+ * values from/to the user buffer, treated as an ASCII string.
+ * The values read are assumed to be in 1/USER_HZ seconds, and
  * are converted into jiffies.
  *
  * Returns 0 on success.
@@ -3019,8 +3078,8 @@ int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write,
  * @ppos: the current position in the file
  *
  * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
- * values from/to the user buffer, treated as an ASCII string. 
- * The values read are assumed to be in 1/1000 seconds, and 
+ * values from/to the user buffer, treated as an ASCII string.
+ * The values read are assumed to be in 1/1000 seconds, and
  * are converted into jiffies.
  *
  * Returns 0 on success.
diff --git a/mm/Makefile b/mm/Makefile
index 1574ea5743e4..925f21c717db 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -44,6 +44,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 obj-y += init-mm.o
 obj-y += memblock.o
 obj-y += exchange.o
+obj-y += mem_defrag.o
 
 ifdef CONFIG_MMU
 	obj-$(CONFIG_ADVISE_SYSCALLS)	+= madvise.o
diff --git a/mm/compaction.c b/mm/compaction.c
index ef29490b0f46..54c4bfdbdbc3 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -50,7 +50,7 @@ static inline void count_compact_events(enum vm_event_item item, long delta)
 #define pageblock_start_pfn(pfn)	block_start_pfn(pfn, pageblock_order)
 #define pageblock_end_pfn(pfn)		block_end_pfn(pfn, pageblock_order)
 
-static unsigned long release_freepages(struct list_head *freelist)
+unsigned long release_freepages(struct list_head *freelist)
 {
 	struct page *page, *next;
 	unsigned long high_pfn = 0;
@@ -58,7 +58,10 @@ static unsigned long release_freepages(struct list_head *freelist)
 	list_for_each_entry_safe(page, next, freelist, lru) {
 		unsigned long pfn = page_to_pfn(page);
 		list_del(&page->lru);
-		__free_page(page);
+		if (PageCompound(page))
+			__free_pages(page, compound_order(page));
+		else
+			__free_page(page);
 		if (pfn > high_pfn)
 			high_pfn = pfn;
 	}
@@ -1593,6 +1596,8 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 
 	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
 		int err;
+		int num_migrated_pages = 0;
+		struct page *iter;
 
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
@@ -1611,6 +1616,9 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 			;
 		}
 
+		list_for_each_entry(iter, &cc->migratepages, lru)
+			num_migrated_pages++;
+
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
 				compaction_free, (unsigned long)cc, cc->mode,
 				MR_COMPACTION);
@@ -1618,6 +1626,11 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 		trace_mm_compaction_migratepages(cc->nr_migratepages, err,
 							&cc->migratepages);
 
+		list_for_each_entry(iter, &cc->migratepages, lru)
+			num_migrated_pages--;
+
+		count_vm_events(COMPACT_MIGRATE_PAGES, num_migrated_pages);
+
 		/* All pages were either migrated or will be released */
 		cc->nr_migratepages = 0;
 		if (err) {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index faf357eaf0ce..ffcae07a87d3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -33,6 +33,7 @@
 #include <linux/page_idle.h>
 #include <linux/shmem_fs.h>
 #include <linux/oom.h>
+#include <linux/mem_defrag.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -695,6 +696,9 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 		return VM_FAULT_OOM;
 	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
 		return VM_FAULT_OOM;
+	/* Make it defrag  */
+	if (unlikely(kmem_defragd_enter(vma, vma->vm_flags)))
+		return VM_FAULT_OOM;
 	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
 			!mm_forbids_zeropage(vma->vm_mm) &&
 			transparent_hugepage_use_zero_page()) {
diff --git a/mm/internal.h b/mm/internal.h
index 77e205c423ce..4fe8d1a4d7bb 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -15,6 +15,7 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/tracepoint-defs.h>
+#include <linux/interval_tree.h>
 
 /*
  * The set of flags that only affect watermark checking and reclaim
@@ -549,4 +550,31 @@ bool buffer_migrate_lock_buffers(struct buffer_head *head,
 int writeout(struct address_space *mapping, struct page *page);
 extern int exchange_two_pages(struct page *page1, struct page *page2);
 
+struct anchor_page_info {
+	struct list_head list;
+	struct page *anchor_page;
+	unsigned long vaddr;
+	unsigned long start;
+	unsigned long end;
+};
+
+struct anchor_page_node {
+	struct interval_tree_node node;
+	unsigned long anchor_pfn; /* struct page can be calculated from pfn_to_page()  */
+	unsigned long anchor_vpn;
+};
+
+unsigned long release_freepages(struct list_head *freelist);
+
+void free_anchor_pages(struct vm_area_struct *vma);
+
+extern int exchange_two_pages(struct page *page1, struct page *page2);
+
+void expand(struct zone *zone, struct page *page,
+	int low, int high, struct free_area *area,
+	int migratetype);
+
+void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
+							unsigned int alloc_flags);
+
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 4f017339ddb2..aedaa9f75806 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -660,6 +660,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 		} else {
 			src_page = pte_page(pteval);
 			copy_user_highpage(page, src_page, address, vma);
+			count_vm_event(THP_COLLAPSE_MIGRATE_PAGES);
 			VM_BUG_ON_PAGE(page_mapcount(src_page) != 1, src_page);
 			release_pte_page(src_page);
 			/*
diff --git a/mm/madvise.c b/mm/madvise.c
index 21a7881a2db4..9cef96d633e8 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -24,6 +24,7 @@
 #include <linux/swapops.h>
 #include <linux/shmem_fs.h>
 #include <linux/mmu_notifier.h>
+#include <linux/mem_defrag.h>
 
 #include <asm/tlb.h>
 
@@ -616,6 +617,13 @@ static long madvise_remove(struct vm_area_struct *vma,
 	return error;
 }
 
+static long madvise_memdefrag(struct vm_area_struct *vma,
+		     struct vm_area_struct **prev,
+		     unsigned long start, unsigned long end, int behavior)
+{
+	*prev = vma;
+	return memdefrag_madvise(vma, &vma->vm_flags, behavior);
+}
 #ifdef CONFIG_MEMORY_FAILURE
 /*
  * Error injection support for memory error handling.
@@ -697,6 +705,9 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	case MADV_FREE:
 	case MADV_DONTNEED:
 		return madvise_dontneed_free(vma, prev, start, end, behavior);
+	case MADV_MEMDEFRAG:
+	case MADV_NOMEMDEFRAG:
+		return madvise_memdefrag(vma, prev, start, end, behavior);
 	default:
 		return madvise_behavior(vma, prev, start, end, behavior);
 	}
@@ -731,6 +742,8 @@ madvise_behavior_valid(int behavior)
 	case MADV_SOFT_OFFLINE:
 	case MADV_HWPOISON:
 #endif
+	case MADV_MEMDEFRAG:
+	case MADV_NOMEMDEFRAG:
 		return true;
 
 	default:
@@ -785,6 +798,8 @@ madvise_behavior_valid(int behavior)
  *  MADV_DONTDUMP - the application wants to prevent pages in the given range
  *		from being included in its core dump.
  *  MADV_DODUMP - cancel MADV_DONTDUMP: no longer exclude from core dump.
+ *  MADV_MEMDEFRAG - allow mem defrag running on this region.
+ *  MADV_NOMEMDEFRAG - no mem defrag here.
  *
  * return values:
  *  zero    - success
diff --git a/mm/mem_defrag.c b/mm/mem_defrag.c
new file mode 100644
index 000000000000..414909e1c19c
--- /dev/null
+++ b/mm/mem_defrag.c
@@ -0,0 +1,1782 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Memory defragmentation.
+ *
+ * Copyright (C) 2019 Zi Yan <ziy@nvidia.com>
+ *
+ * Two lists:
+ *   1) a mm list, representing virtual address spaces
+ *   2) a anon_vma list, representing the physical address space.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/mm.h>
+#include <linux/sched/mm.h>
+#include <linux/mm_inline.h>
+#include <linux/rmap.h>
+#include <linux/swap.h>
+#include <linux/hashtable.h>
+#include <linux/mem_defrag.h>
+#include <linux/shmem_fs.h>
+#include <linux/syscalls.h>
+#include <linux/security.h>
+#include <linux/vmalloc.h>
+#include <linux/mman.h>
+#include <linux/vmstat.h>
+#include <linux/migrate.h>
+#include <linux/page-isolation.h>
+#include <linux/sort.h>
+
+#include <asm/tlb.h>
+#include <asm/pgalloc.h>
+#include "internal.h"
+
+
+struct contig_stats {
+	int err;
+	unsigned long contig_pages;
+	unsigned long first_vaddr_in_chunk;
+	unsigned long first_paddr_in_chunk;
+};
+
+struct defrag_result_stats {
+	unsigned long aligned;
+	unsigned long migrated;
+	unsigned long src_pte_thp_failed;
+	unsigned long src_thp_dst_not_failed;
+	unsigned long src_not_present;
+	unsigned long dst_out_of_bound_failed;
+	unsigned long dst_pte_thp_failed;
+	unsigned long dst_thp_src_not_failed;
+	unsigned long dst_isolate_free_failed;
+	unsigned long dst_migrate_free_failed;
+	unsigned long dst_anon_failed;
+	unsigned long dst_file_failed;
+	unsigned long dst_non_lru_failed;
+	unsigned long dst_non_moveable_failed;
+	unsigned long not_defrag_vpn;
+};
+
+enum {
+	VMA_THRESHOLD_TYPE_TIME = 0,
+	VMA_THRESHOLD_TYPE_SIZE,
+};
+
+int num_breakout_chunks;
+int vma_scan_percentile = 100;
+int vma_scan_threshold_type = VMA_THRESHOLD_TYPE_TIME;
+int vma_no_repeat_defrag;
+int kmem_defragd_always;
+int defrag_size_threshold = 5;
+static DEFINE_SPINLOCK(kmem_defragd_mm_lock);
+
+#define MM_SLOTS_HASH_BITS 10
+static __read_mostly DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
+
+static struct kmem_cache *mm_slot_cache __read_mostly;
+
+struct defrag_scan_control {
+	struct mm_struct *mm;
+	unsigned long scan_address;
+	char __user *out_buf;
+	int buf_len;
+	int used_len;
+	enum mem_defrag_action action;
+	bool scan_in_vma;
+	unsigned long vma_scan_threshold;
+};
+
+/**
+ * struct mm_slot - hash lookup from mm to mm_slot
+ * @hash: hash collision list
+ * @mm_node: kmem_defragd scan list headed in kmem_defragd_scan.mm_head
+ * @mm: the mm that this information is valid for
+ */
+struct mm_slot {
+	struct hlist_node hash;
+	struct list_head mm_node;
+	struct mm_struct *mm;
+};
+
+/**
+ * struct kmem_defragd_scan - cursor for scanning
+ * @mm_head: the head of the mm list to scan
+ * @mm_slot: the current mm_slot we are scanning
+ * @address: the next address inside that to be scanned
+ *
+ * There is only the one kmem_defragd_scan instance of this cursor structure.
+ */
+struct kmem_defragd_scan {
+	struct list_head mm_head;
+	struct mm_slot *mm_slot;
+	unsigned long address;
+};
+
+static struct kmem_defragd_scan kmem_defragd_scan = {
+	.mm_head = LIST_HEAD_INIT(kmem_defragd_scan.mm_head),
+};
+
+
+static inline struct mm_slot *alloc_mm_slot(void)
+{
+	if (!mm_slot_cache)	/* initialization failed */
+		return NULL;
+	return kmem_cache_zalloc(mm_slot_cache, GFP_KERNEL);
+}
+
+static inline void free_mm_slot(struct mm_slot *mm_slot)
+{
+	kmem_cache_free(mm_slot_cache, mm_slot);
+}
+
+static struct mm_slot *get_mm_slot(struct mm_struct *mm)
+{
+	struct mm_slot *mm_slot;
+
+	hash_for_each_possible(mm_slots_hash, mm_slot, hash, (unsigned long)mm)
+		if (mm == mm_slot->mm)
+			return mm_slot;
+
+	return NULL;
+}
+
+static void insert_to_mm_slots_hash(struct mm_struct *mm,
+				    struct mm_slot *mm_slot)
+{
+	mm_slot->mm = mm;
+	hash_add(mm_slots_hash, &mm_slot->hash, (long)mm);
+}
+
+static inline int kmem_defragd_test_exit(struct mm_struct *mm)
+{
+	return atomic_read(&mm->mm_users) == 0;
+}
+
+int __kmem_defragd_enter(struct mm_struct *mm)
+{
+	struct mm_slot *mm_slot;
+
+	mm_slot = alloc_mm_slot();
+	if (!mm_slot)
+		return -ENOMEM;
+
+	/* __kmem_defragd_exit() must not run from under us */
+	VM_BUG_ON_MM(kmem_defragd_test_exit(mm), mm);
+	if (unlikely(test_and_set_bit(MMF_VM_MEM_DEFRAG, &mm->flags))) {
+		free_mm_slot(mm_slot);
+		return 0;
+	}
+
+	spin_lock(&kmem_defragd_mm_lock);
+	insert_to_mm_slots_hash(mm, mm_slot);
+	/*
+	 * Insert just behind the scanning cursor, to let the area settle
+	 * down a little.
+	 */
+	list_add_tail(&mm_slot->mm_node, &kmem_defragd_scan.mm_head);
+	spin_unlock(&kmem_defragd_mm_lock);
+
+	atomic_inc(&mm->mm_count);
+
+	return 0;
+}
+
+void __kmem_defragd_exit(struct mm_struct *mm)
+{
+	struct mm_slot *mm_slot;
+	int free = 0;
+
+	spin_lock(&kmem_defragd_mm_lock);
+	mm_slot = get_mm_slot(mm);
+	if (mm_slot && kmem_defragd_scan.mm_slot != mm_slot) {
+		hash_del(&mm_slot->hash);
+		list_del(&mm_slot->mm_node);
+		free = 1;
+	}
+	spin_unlock(&kmem_defragd_mm_lock);
+
+	if (free) {
+		clear_bit(MMF_VM_MEM_DEFRAG, &mm->flags);
+		free_mm_slot(mm_slot);
+		mmdrop(mm);
+	} else if (mm_slot) {
+		/*
+		 * This is required to serialize against
+		 * kmem_defragd_test_exit() (which is guaranteed to run
+		 * under mmap sem read mode). Stop here (after we
+		 * return all pagetables will be destroyed) until
+		 * kmem_defragd has finished working on the pagetables
+		 * under the mmap_sem.
+		 */
+		down_write(&mm->mmap_sem);
+		up_write(&mm->mmap_sem);
+	}
+}
+
+static void collect_mm_slot(struct mm_slot *mm_slot)
+{
+	struct mm_struct *mm = mm_slot->mm;
+
+	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&kmem_defragd_mm_lock));
+
+	if (kmem_defragd_test_exit(mm)) {
+		/* free mm_slot */
+		hash_del(&mm_slot->hash);
+		list_del(&mm_slot->mm_node);
+
+		/*
+		 * Not strictly needed because the mm exited already.
+		 *
+		 * clear_bit(MMF_VM_HUGEPAGE, &mm->flags);
+		 */
+
+		/* kmem_defragd_mm_lock actually not necessary for the below */
+		free_mm_slot(mm_slot);
+		mmdrop(mm);
+	}
+}
+
+static bool mem_defrag_vma_check(struct vm_area_struct *vma)
+{
+	if ((!test_bit(MMF_VM_MEM_DEFRAG_ALL, &vma->vm_mm->flags) &&
+			!(vma->vm_flags & VM_MEMDEFRAG) && !kmem_defragd_always) ||
+			(vma->vm_flags & VM_NOMEMDEFRAG))
+			return false;
+	if (shmem_file(vma->vm_file)) {
+		if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
+			return false;
+		return IS_ALIGNED((vma->vm_start >> PAGE_SHIFT) - vma->vm_pgoff,
+				HPAGE_PMD_NR);
+	}
+	if (is_vm_hugetlb_page(vma))
+		return true;
+	if (!vma->anon_vma || vma->vm_ops)
+		return false;
+	if (is_vma_temporary_stack(vma))
+		return false;
+	return true;
+}
+
+static int do_vma_stat(struct mm_struct *mm, struct vm_area_struct *vma,
+		char *kernel_buf, int pos, int *remain_buf_len)
+{
+	int used_len;
+	int init_remain_len = *remain_buf_len;
+
+	if (!*remain_buf_len || !kernel_buf)
+		return -1;
+
+	used_len = scnprintf(kernel_buf + pos, *remain_buf_len, "%p, 0x%lx, 0x%lx, "
+						 "0x%lx, -1\n",
+						 mm, (unsigned long)vma+vma->vma_create_jiffies,
+						 vma->vm_start, vma->vm_end);
+
+	*remain_buf_len -= used_len;
+
+	if (*remain_buf_len == 1) {
+		*remain_buf_len = init_remain_len;
+		kernel_buf[pos] = '\0';
+		return -1;
+	}
+
+	return 0;
+}
+
+static inline int get_contig_page_size(struct page *page)
+{
+	int page_size = PAGE_SIZE;
+
+	if (PageCompound(page)) {
+		struct page *head_page = compound_head(page);
+		int compound_size = PAGE_SIZE<<compound_order(head_page);
+
+		if (head_page != page) {
+			VM_BUG_ON_PAGE(!PageTail(page), page);
+			page_size = compound_size - (page - head_page) * PAGE_SIZE;
+		} else
+			page_size = compound_size;
+	}
+
+	return page_size;
+}
+
+/*
+ * write one page stats to kernel_buf.
+ *
+ * If kernel_buf is not big enough, the page information will not be recorded
+ * at all.
+ *
+ */
+static int do_page_stat(struct mm_struct *mm, struct vm_area_struct *vma,
+		struct page *page, unsigned long vaddr,
+		char *kernel_buf, int pos, int *remain_buf_len,
+		enum mem_defrag_action action,
+		struct contig_stats *contig_stats,
+		bool scan_in_vma)
+{
+	int used_len;
+	struct anon_vma *anon_vma;
+	int init_remain_len = *remain_buf_len;
+	int end_note = -1;
+	unsigned long num_pages = page?(get_contig_page_size(page)/PAGE_SIZE):1;
+
+	if (!*remain_buf_len || !kernel_buf)
+		return -1;
+
+	if (action == MEM_DEFRAG_CONTIG_STATS) {
+		long long contig_pages;
+		unsigned long paddr = page?PFN_PHYS(page_to_pfn(page)):0;
+		bool last_entry = false;
+
+		if (!contig_stats->first_vaddr_in_chunk) {
+			contig_stats->first_vaddr_in_chunk = vaddr;
+			contig_stats->first_paddr_in_chunk = paddr;
+			contig_stats->contig_pages = 0;
+		}
+
+		/* scan_in_vma is set to true if buffer runs out while scanning a
+		 * vma. A corner case happens, when buffer runs out, then vma changes,
+		 * scan_address is reset to vm_start. Then, vma info is printed twice.
+		 */
+		if (vaddr == vma->vm_start && !scan_in_vma) {
+			used_len = scnprintf(kernel_buf + pos, *remain_buf_len,
+					"%p, 0x%lx, 0x%lx, 0x%lx, ",
+					mm, (unsigned long)vma+vma->vma_create_jiffies,
+					vma->vm_start, vma->vm_end);
+
+			*remain_buf_len -= used_len;
+
+			if (*remain_buf_len == 1) {
+				contig_stats->err = 1;
+				goto out_of_buf;
+			}
+			pos += used_len;
+		}
+
+		if (page) {
+			if (contig_stats->first_paddr_in_chunk) {
+				if (((long long)vaddr - contig_stats->first_vaddr_in_chunk) ==
+					((long long)paddr - contig_stats->first_paddr_in_chunk))
+					contig_stats->contig_pages += num_pages;
+				else {
+					/* output present contig chunk */
+					contig_pages = contig_stats->contig_pages;
+					goto output_contig_info;
+				}
+			} else { /* the previous chunk is not present pages */
+				/* output non-present contig chunk */
+				contig_pages = -(long long)contig_stats->contig_pages;
+				goto output_contig_info;
+			}
+		} else {
+			/* the previous chunk is not present pages */
+			if (!contig_stats->first_paddr_in_chunk) {
+				VM_BUG_ON(contig_stats->first_vaddr_in_chunk +
+						  contig_stats->contig_pages * PAGE_SIZE !=
+						  vaddr);
+				++contig_stats->contig_pages;
+			} else {
+				/* output present contig chunk */
+				contig_pages = contig_stats->contig_pages;
+
+				goto output_contig_info;
+			}
+		}
+
+check_last_entry:
+		/* if vaddr is the last page, we need to dump stats as well  */
+		if ((vaddr + num_pages * PAGE_SIZE) >= vma->vm_end) {
+			if (contig_stats->first_paddr_in_chunk)
+				contig_pages = contig_stats->contig_pages;
+			else
+				contig_pages = -(long long)contig_stats->contig_pages;
+			last_entry = true;
+		} else
+			return 0;
+output_contig_info:
+		if (last_entry)
+			used_len = scnprintf(kernel_buf + pos, *remain_buf_len,
+					"%lld, -1\n", contig_pages);
+		else
+			used_len = scnprintf(kernel_buf + pos, *remain_buf_len,
+					"%lld, ", contig_pages);
+
+		*remain_buf_len -= used_len;
+		if (*remain_buf_len == 1) {
+			contig_stats->err = 1;
+			goto out_of_buf;
+		} else {
+			pos += used_len;
+			if (last_entry) {
+				/* clear contig_stats  */
+				contig_stats->first_vaddr_in_chunk = 0;
+				contig_stats->first_paddr_in_chunk = 0;
+				contig_stats->contig_pages = 0;
+				return 0;
+			} else {
+				/* set new contig_stats  */
+				contig_stats->first_vaddr_in_chunk = vaddr;
+				contig_stats->first_paddr_in_chunk = paddr;
+				contig_stats->contig_pages = num_pages;
+				goto check_last_entry;
+			}
+		}
+		return 0;
+	}
+
+	used_len = scnprintf(kernel_buf + pos, *remain_buf_len,
+				"%p, %p, 0x%lx, 0x%lx, 0x%lx, 0x%llx",
+				 mm, vma, vma->vm_start, vma->vm_end,
+				 vaddr, page ? PFN_PHYS(page_to_pfn(page)) : 0);
+
+	*remain_buf_len -= used_len;
+	if (*remain_buf_len == 1)
+		goto out_of_buf;
+	pos += used_len;
+
+	if (page && PageAnon(page)) {
+		/* check page order  */
+		used_len = scnprintf(kernel_buf + pos, *remain_buf_len, ", %d",
+							 compound_order(page));
+		*remain_buf_len -= used_len;
+		if (*remain_buf_len == 1)
+			goto out_of_buf;
+		pos += used_len;
+
+		anon_vma = page_anon_vma(page);
+		if (!anon_vma)
+			goto end_of_stat;
+		anon_vma_lock_read(anon_vma);
+
+		do {
+			used_len = scnprintf(kernel_buf + pos, *remain_buf_len, ", %p",
+								 anon_vma);
+			*remain_buf_len -= used_len;
+			if (*remain_buf_len == 1) {
+				anon_vma_unlock_read(anon_vma);
+				goto out_of_buf;
+			}
+			pos += used_len;
+
+			anon_vma = anon_vma->parent;
+		} while (anon_vma != anon_vma->parent);
+
+		anon_vma_unlock_read(anon_vma);
+	}
+end_of_stat:
+	/* end of one page stat  */
+	used_len = scnprintf(kernel_buf + pos, *remain_buf_len, ", %d\n", end_note);
+	*remain_buf_len -= used_len;
+	if (*remain_buf_len == 1)
+		goto out_of_buf;
+
+	return 0;
+out_of_buf: /* revert incomplete data  */
+	*remain_buf_len = init_remain_len;
+	kernel_buf[pos] = '\0';
+	return -1;
+
+}
+
+static int isolate_free_page_no_wmark(struct page *page, unsigned int order)
+{
+	struct zone *zone;
+	int mt;
+
+	VM_BUG_ON(!PageBuddy(page));
+
+	zone = page_zone(page);
+	mt = get_pageblock_migratetype(page);
+
+
+	/* Remove page from free list */
+	list_del(&page->lru);
+	zone->free_area[order].nr_free--;
+	__ClearPageBuddy(page);
+	set_page_private(page, 0);
+
+	/*
+	 * Set the pageblock if the isolated page is at least half of a
+	 * pageblock
+	 */
+	if (order >= pageblock_order - 1) {
+		struct page *endpage = page + (1 << order) - 1;
+
+		for (; page < endpage; page += pageblock_nr_pages) {
+			int mt = get_pageblock_migratetype(page);
+
+			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)
+				&& mt != MIGRATE_HIGHATOMIC)
+				set_pageblock_migratetype(page,
+							  MIGRATE_MOVABLE);
+		}
+	}
+
+	return 1UL << order;
+}
+
+struct exchange_alloc_info {
+	struct list_head list;
+	struct page *src_page;
+	struct page *dst_page;
+};
+
+struct exchange_alloc_head {
+	struct list_head exchange_list;
+	struct list_head freelist;
+	struct list_head migratepage_list;
+	unsigned long num_freepages;
+};
+
+static int create_exchange_alloc_info(struct vm_area_struct *vma,
+		unsigned long scan_address, struct page *first_in_use_page,
+		int total_free_pages,
+		struct list_head *freelist,
+		struct list_head *exchange_list,
+		struct list_head *migratepage_list)
+{
+	struct page *in_use_page;
+	struct page *freepage;
+	struct exchange_alloc_info *one_pair;
+	int err;
+	int pagevec_flushed = 0;
+
+	down_read(&vma->vm_mm->mmap_sem);
+	in_use_page = follow_page(vma, scan_address,
+							FOLL_GET|FOLL_MIGRATION | FOLL_REMOTE);
+	up_read(&vma->vm_mm->mmap_sem);
+
+	freepage = list_first_entry_or_null(freelist, struct page, lru);
+
+	if (first_in_use_page != in_use_page ||
+		!freepage ||
+		PageCompound(in_use_page) != PageCompound(freepage) ||
+		compound_order(in_use_page) != compound_order(freepage)) {
+		if (in_use_page)
+			put_page(in_use_page);
+		return -EBUSY;
+	}
+	one_pair = kmalloc(sizeof(struct exchange_alloc_info),
+		GFP_KERNEL | __GFP_ZERO);
+
+	if (!one_pair) {
+		put_page(in_use_page);
+		return -ENOMEM;
+	}
+
+retry_isolate:
+	/* isolate in_use_page */
+	err = isolate_lru_page(in_use_page);
+	if (err) {
+		if (!pagevec_flushed) {
+			migrate_prep();
+			pagevec_flushed = 1;
+			goto retry_isolate;
+		}
+		put_page(in_use_page);
+		in_use_page = NULL;
+	}
+
+	if (in_use_page) {
+		put_page(in_use_page);
+		mod_node_page_state(page_pgdat(in_use_page),
+				NR_ISOLATED_ANON + page_is_file_cache(in_use_page),
+				hpage_nr_pages(in_use_page));
+		list_add_tail(&in_use_page->lru, migratepage_list);
+	}
+	/* fill info  */
+	one_pair->src_page = in_use_page;
+	one_pair->dst_page = freepage;
+	INIT_LIST_HEAD(&one_pair->list);
+
+	list_add_tail(&one_pair->list, exchange_list);
+
+	return 0;
+}
+
+static void free_alloc_info(struct list_head *alloc_info_list)
+{
+	struct exchange_alloc_info *item, *item2;
+
+	list_for_each_entry_safe(item, item2, alloc_info_list, list) {
+		list_del(&item->list);
+		kfree(item);
+	}
+}
+
+/*
+ * migrate callback: give a specific free page when it is called to guarantee
+ * contiguity after migration.
+ */
+static struct page *exchange_alloc(struct page *migratepage,
+				unsigned long data)
+{
+	struct exchange_alloc_head *head = (struct exchange_alloc_head *)data;
+	struct page *freepage = NULL;
+	struct exchange_alloc_info *info;
+
+	list_for_each_entry(info, &head->exchange_list, list) {
+		if (migratepage == info->src_page) {
+			freepage = info->dst_page;
+			/* remove it from freelist */
+			list_del(&freepage->lru);
+			if (PageTransHuge(freepage))
+				head->num_freepages -= HPAGE_PMD_NR;
+			else
+				head->num_freepages--;
+			break;
+		}
+	}
+
+	return freepage;
+}
+
+static void exchange_free(struct page *freepage, unsigned long data)
+{
+	struct exchange_alloc_head *head = (struct exchange_alloc_head *)data;
+
+	list_add_tail(&freepage->lru, &head->freelist);
+	if (PageTransHuge(freepage))
+		head->num_freepages += HPAGE_PMD_NR;
+	else
+		head->num_freepages++;
+}
+
+int defrag_address_range(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long start_addr, unsigned long end_addr,
+		struct page *anchor_page, unsigned long page_vaddr,
+		struct defrag_result_stats *defrag_stats)
+{
+	/*unsigned long va_pa_page_offset = (unsigned long)-1;*/
+	unsigned long scan_address;
+	unsigned long page_size = PAGE_SIZE;
+	int failed = 0;
+	int not_present = 0;
+	bool src_thp = false;
+
+	for (scan_address = start_addr; scan_address < end_addr;
+		 scan_address += page_size) {
+		struct page *scan_page;
+		unsigned long scan_phys_addr;
+		long long page_dist;
+
+		cond_resched();
+
+		down_read(&vma->vm_mm->mmap_sem);
+		scan_page = follow_page(vma, scan_address, FOLL_MIGRATION | FOLL_REMOTE);
+		up_read(&vma->vm_mm->mmap_sem);
+		scan_phys_addr = PFN_PHYS(scan_page ? page_to_pfn(scan_page) : 0);
+
+		page_size = PAGE_SIZE;
+
+		if (!scan_phys_addr) {
+			not_present++;
+			failed += 1;
+			defrag_stats->src_not_present += 1;
+			continue;
+		}
+
+		page_size = get_contig_page_size(scan_page);
+
+		/* PTE-mapped THP not allowed  */
+		if ((scan_page == compound_head(scan_page)) &&
+			PageTransHuge(scan_page) && !PageHuge(scan_page))
+			src_thp = true;
+
+		/* Allow THPs  */
+		if (PageCompound(scan_page) && !src_thp) {
+			count_vm_events(MEM_DEFRAG_SRC_COMP_PAGES_FAILED, page_size/PAGE_SIZE);
+			failed += (page_size/PAGE_SIZE);
+			defrag_stats->src_pte_thp_failed += (page_size/PAGE_SIZE);
+
+			defrag_stats->not_defrag_vpn = scan_address + page_size;
+			goto quit_defrag;
+			continue;
+		}
+
+		VM_BUG_ON(!anchor_page);
+
+		page_dist = ((long long)scan_address - page_vaddr) / PAGE_SIZE;
+
+		/* already in the contiguous pos  */
+		if (page_dist == (long long)(scan_page - anchor_page)) {
+			defrag_stats->aligned += (page_size/PAGE_SIZE);
+			continue;
+		} else { /* migrate pages according to the anchor pages in the vma.  */
+			struct page *dest_page = anchor_page + page_dist;
+			int page_drained = 0;
+			bool dst_thp = false;
+			int scan_page_order = src_thp?compound_order(scan_page):0;
+
+			if (!zone_spans_pfn(page_zone(anchor_page),
+					(page_to_pfn(anchor_page) + page_dist))) {
+				failed += 1;
+				defrag_stats->dst_out_of_bound_failed += 1;
+
+				defrag_stats->not_defrag_vpn = scan_address + page_size;
+				goto quit_defrag;
+				continue;
+			}
+
+retry_defrag:
+			/* migrate */
+			if (PageBuddy(dest_page)) {
+				struct zone *zone = page_zone(dest_page);
+				spinlock_t *zone_lock = &zone->lock;
+				unsigned long zone_lock_flags;
+				unsigned long free_page_order = 0;
+				int err = 0;
+				struct exchange_alloc_head exchange_alloc_head = {0};
+				int migratetype = get_pageblock_migratetype(dest_page);
+
+				INIT_LIST_HEAD(&exchange_alloc_head.exchange_list);
+				INIT_LIST_HEAD(&exchange_alloc_head.freelist);
+				INIT_LIST_HEAD(&exchange_alloc_head.migratepage_list);
+
+				count_vm_events(MEM_DEFRAG_DST_FREE_PAGES, 1<<scan_page_order);
+
+				/* lock page_zone(dest_page)->lock  */
+				spin_lock_irqsave(zone_lock, zone_lock_flags);
+
+				if (!PageBuddy(dest_page)) {
+					err = -EINVAL;
+					goto freepage_isolate_fail;
+				}
+
+				free_page_order = page_order(dest_page);
+
+				/* fail early if not enough free pages */
+				if (free_page_order < scan_page_order) {
+					err = -ENOMEM;
+					goto freepage_isolate_fail;
+				}
+
+				/* __isolate_free_page()  */
+				err = isolate_free_page_no_wmark(dest_page, free_page_order);
+				if (!err)
+					goto freepage_isolate_fail;
+
+				expand(zone, dest_page, scan_page_order, free_page_order,
+					&(zone->free_area[free_page_order]),
+					migratetype);
+
+				if (!is_migrate_isolate(migratetype))
+					__mod_zone_freepage_state(zone, -(1UL << scan_page_order),
+							migratetype);
+
+				prep_new_page(dest_page, scan_page_order,
+					__GFP_MOVABLE|(scan_page_order?__GFP_COMP:0), 0);
+
+				if (scan_page_order) {
+					VM_BUG_ON(!src_thp);
+					VM_BUG_ON(scan_page_order != HPAGE_PMD_ORDER);
+					prep_transhuge_page(dest_page);
+				}
+
+				list_add(&dest_page->lru, &exchange_alloc_head.freelist);
+
+freepage_isolate_fail:
+				spin_unlock_irqrestore(zone_lock, zone_lock_flags);
+
+				if (err < 0) {
+					failed += (page_size/PAGE_SIZE);
+					defrag_stats->dst_isolate_free_failed += (page_size/PAGE_SIZE);
+
+					defrag_stats->not_defrag_vpn = scan_address + page_size;
+					goto quit_defrag;
+					continue;
+				}
+
+				/* gather in-use pages
+				 * create a exchange_alloc_info structure, a list of
+				 * tuples, each like:
+				 * (in_use_page, free_page)
+				 *
+				 * so in exchange_alloc, the code needs to traverse the list
+				 * and find the tuple from in_use_page. Then return the
+				 * corresponding free page.
+				 *
+				 * This can guarantee the contiguity after migration.
+				 */
+
+				err = create_exchange_alloc_info(vma, scan_address, scan_page,
+							1<<free_page_order,
+							&exchange_alloc_head.freelist,
+							&exchange_alloc_head.exchange_list,
+							&exchange_alloc_head.migratepage_list);
+
+				if (err)
+					pr_debug("create_exchange_alloc_info error: %d\n", err);
+
+				exchange_alloc_head.num_freepages = 1<<scan_page_order;
+
+				/* migrate pags  */
+				err = migrate_pages(&exchange_alloc_head.migratepage_list,
+					exchange_alloc, exchange_free,
+					(unsigned long)&exchange_alloc_head,
+					MIGRATE_SYNC, MR_COMPACTION);
+
+				/* putback not migrated in_use_pagelist */
+				putback_movable_pages(&exchange_alloc_head.migratepage_list);
+
+				/* release free pages in freelist */
+				release_freepages(&exchange_alloc_head.freelist);
+
+				/* free allocated exchange info  */
+				free_alloc_info(&exchange_alloc_head.exchange_list);
+
+				count_vm_events(MEM_DEFRAG_DST_FREE_PAGES_FAILED,
+						exchange_alloc_head.num_freepages);
+
+				if (exchange_alloc_head.num_freepages) {
+					failed += exchange_alloc_head.num_freepages;
+					defrag_stats->dst_migrate_free_failed +=
+						exchange_alloc_head.num_freepages;
+				}
+				defrag_stats->migrated += ((1UL<<scan_page_order) -
+						exchange_alloc_head.num_freepages);
+
+			} else { /* exchange  */
+				int err = -EBUSY;
+
+				/* PTE-mapped THP not allowed  */
+				if ((dest_page == compound_head(dest_page)) &&
+					PageTransHuge(dest_page) && !PageHuge(dest_page))
+					dst_thp = true;
+
+				if (PageCompound(dest_page) && !dst_thp) {
+					failed += get_contig_page_size(dest_page);
+					defrag_stats->dst_pte_thp_failed += page_size/PAGE_SIZE;
+
+					defrag_stats->not_defrag_vpn = scan_address + page_size;
+					goto quit_defrag;
+				}
+
+				if (src_thp != dst_thp) {
+					failed += get_contig_page_size(scan_page);
+					if (src_thp && !dst_thp)
+						defrag_stats->src_thp_dst_not_failed +=
+							page_size/PAGE_SIZE;
+					else /* !src_thp && dst_thp */
+						defrag_stats->dst_thp_src_not_failed +=
+							page_size/PAGE_SIZE;
+
+					defrag_stats->not_defrag_vpn = scan_address + page_size;
+					goto quit_defrag;
+					/*continue;*/
+				}
+
+				/* free page on pcplist */
+				if (page_count(dest_page) == 0) {
+					/* not managed pages  */
+					if (!dest_page->flags) {
+						failed += 1;
+						defrag_stats->dst_out_of_bound_failed += 1;
+
+						defrag_stats->not_defrag_vpn = scan_address + page_size;
+						goto quit_defrag;
+					}
+					/* spill order-0 pages to buddy allocator from pcplist */
+					if (!page_drained) {
+						drain_all_pages(NULL);
+						page_drained = 1;
+						goto retry_defrag;
+					}
+				}
+
+				if (PageAnon(dest_page)) {
+					count_vm_events(MEM_DEFRAG_DST_ANON_PAGES,
+							1<<scan_page_order);
+
+					err = exchange_two_pages(scan_page, dest_page);
+					if (err) {
+						count_vm_events(MEM_DEFRAG_DST_ANON_PAGES_FAILED,
+								1<<scan_page_order);
+						failed += 1<<scan_page_order;
+						defrag_stats->dst_anon_failed += 1<<scan_page_order;
+					}
+				} else if (page_mapping(dest_page)) {
+					count_vm_events(MEM_DEFRAG_DST_FILE_PAGES,
+							1<<scan_page_order);
+
+					err = exchange_two_pages(scan_page, dest_page);
+					if (err) {
+						count_vm_events(MEM_DEFRAG_DST_FILE_PAGES_FAILED,
+								1<<scan_page_order);
+						failed += 1<<scan_page_order;
+						defrag_stats->dst_file_failed += 1<<scan_page_order;
+					}
+				} else if (!PageLRU(dest_page) && __PageMovable(dest_page)) {
+					err = -ENODEV;
+					count_vm_events(MEM_DEFRAG_DST_NONLRU_PAGES,
+							1<<scan_page_order);
+					failed += 1<<scan_page_order;
+					defrag_stats->dst_non_lru_failed += 1<<scan_page_order;
+					count_vm_events(MEM_DEFRAG_DST_NONLRU_PAGES_FAILED,
+							1<<scan_page_order);
+				} else {
+					err = -ENODEV;
+					failed += 1<<scan_page_order;
+					/* unmovable pages  */
+					defrag_stats->dst_non_moveable_failed += 1<<scan_page_order;
+				}
+
+				if (err == -EAGAIN)
+					goto retry_defrag;
+				if (!err)
+					defrag_stats->migrated += 1<<scan_page_order;
+				else {
+
+					defrag_stats->not_defrag_vpn = scan_address + page_size;
+					goto quit_defrag;
+				}
+
+			}
+		}
+	}
+quit_defrag:
+	return failed;
+}
+
+struct anchor_page_node *get_anchor_page_node_from_vma(struct vm_area_struct *vma,
+	unsigned long address)
+{
+	struct interval_tree_node *prev_vma_node;
+
+	prev_vma_node = interval_tree_iter_first(&vma->anchor_page_rb,
+		address, address);
+
+	if (!prev_vma_node)
+		return NULL;
+
+	return container_of(prev_vma_node, struct anchor_page_node, node);
+}
+
+unsigned long get_undefragged_area(struct zone *zone, struct vm_area_struct *vma,
+	unsigned long start_addr, unsigned long end_addr)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct vm_area_struct *scan_vma = NULL;
+	unsigned long vma_size = end_addr - start_addr;
+	bool first_vma = true;
+
+	for (scan_vma = mm->mmap; scan_vma; scan_vma = scan_vma->vm_next)
+		if (!RB_EMPTY_ROOT(&scan_vma->anchor_page_rb.rb_root))
+			break;
+	/* no defragged area */
+	if (!scan_vma)
+		return zone->zone_start_pfn;
+
+	scan_vma = mm->mmap;
+	while (scan_vma) {
+		if (!RB_EMPTY_ROOT(&scan_vma->anchor_page_rb.rb_root)) {
+			struct interval_tree_node *node = NULL, *next_node = NULL;
+			struct anchor_page_node *anchor_node, *next_anchor_node = NULL;
+			struct vm_area_struct *next_vma = scan_vma->vm_next;
+			unsigned long end_pfn;
+			/* each vma get one anchor range */
+			node = interval_tree_iter_first(&scan_vma->anchor_page_rb,
+				 scan_vma->vm_start, scan_vma->vm_end - 1);
+			if (!node) {
+				scan_vma = scan_vma->vm_next;
+				continue;
+			}
+
+			anchor_node = container_of(node, struct anchor_page_node, node);
+			end_pfn = (anchor_node->anchor_pfn +
+					((scan_vma->vm_end - scan_vma->vm_start)>>PAGE_SHIFT));
+
+			/* check space before first vma */
+			if (first_vma) {
+				first_vma = false;
+				if (zone->zone_start_pfn + vma_size < anchor_node->anchor_pfn)
+					return zone->zone_start_pfn;
+				/* remove existing anchor if new vma is much larger */
+				if (vma_size > (scan_vma->vm_end - scan_vma->vm_start)*2) {
+					first_vma = true;
+					interval_tree_remove(node, &scan_vma->anchor_page_rb);
+					kfree(anchor_node);
+					scan_vma = scan_vma->vm_next;
+					continue;
+				}
+			}
+
+			/* find next vma with anchor range */
+			for (next_vma = scan_vma->vm_next;
+				next_vma && RB_EMPTY_ROOT(&next_vma->anchor_page_rb.rb_root);
+				next_vma = next_vma->vm_next);
+
+			if (!next_vma)
+				return end_pfn;
+			else {
+				next_node = interval_tree_iter_first(&next_vma->anchor_page_rb,
+					 next_vma->vm_start, next_vma->vm_end - 1);
+				VM_BUG_ON(!next_node);
+				next_anchor_node = container_of(next_node,
+									struct anchor_page_node, node);
+				if (end_pfn + vma_size < next_anchor_node->anchor_pfn)
+					return end_pfn;
+			}
+			scan_vma = next_vma;
+		} else
+			scan_vma = scan_vma->vm_next;
+	}
+
+	return zone->zone_start_pfn;
+}
+
+/*
+ * anchor pages decide the va pa offset in each vma
+ *
+ */
+static int find_anchor_pages_in_vma(struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long start_addr)
+{
+	struct anchor_page_node *anchor_node;
+	unsigned long end_addr = vma->vm_end - PAGE_SIZE;
+	struct interval_tree_node *existing_anchor = NULL;
+	unsigned long scan_address = start_addr;
+	struct page *present_page = NULL;
+	struct zone *present_zone = NULL;
+	unsigned long alignment_size = PAGE_SIZE;
+
+	/* Out of range query  */
+	if (start_addr >= vma->vm_end || start_addr < vma->vm_start)
+		return -1;
+
+	/*
+	 * Clean up unrelated anchor infor
+	 *
+	 * VMA range can change and leave some anchor info out of range,
+	 * so clean it here.
+	 * It should be cleaned when vma is changed, but the code there
+	 * is too complicated.
+	 */
+	if (!RB_EMPTY_ROOT(&vma->anchor_page_rb.rb_root) &&
+		!interval_tree_iter_first(&vma->anchor_page_rb,
+		 vma->vm_start, vma->vm_end - 1)) {
+		struct interval_tree_node *node = NULL;
+
+		for (node = interval_tree_iter_first(&vma->anchor_page_rb,
+				0, (unsigned long)-1);
+			 node;) {
+			struct anchor_page_node *anchor_node = container_of(node,
+					struct anchor_page_node, node);
+			interval_tree_remove(node, &vma->anchor_page_rb);
+			node = interval_tree_iter_next(node, 0, (unsigned long)-1);
+			kfree(anchor_node);
+		}
+	}
+
+	/* no range at all  */
+	if (RB_EMPTY_ROOT(&vma->anchor_page_rb.rb_root))
+		goto insert_new_range;
+
+	/* look for first range has start_addr or after it */
+	existing_anchor = interval_tree_iter_first(&vma->anchor_page_rb,
+		start_addr, end_addr);
+
+	/* first range has start_addr or after it  */
+	if (existing_anchor) {
+		/* redundant range, do nothing */
+		if (existing_anchor->start == start_addr)
+			return 0;
+		else if (existing_anchor->start < start_addr &&
+				 existing_anchor->last >= start_addr){
+			return 0;
+		} else { /* a range after start_addr  */
+			struct anchor_page_node *existing_node = container_of(existing_anchor,
+				struct anchor_page_node, node);
+			VM_BUG_ON(!(existing_anchor->start > start_addr));
+			/* remove the existing range and insert a new one, since expanding
+			 * forward can make the range go beyond the zone limit
+			 */
+			interval_tree_remove(existing_anchor, &vma->anchor_page_rb);
+			kfree(existing_node);
+			VM_BUG_ON(!RB_EMPTY_ROOT(&vma->anchor_page_rb.rb_root));
+			goto insert_new_range;
+		}
+	} else {
+		struct interval_tree_node *prev_anchor = NULL, *cur_anchor;
+		/* there is a range before start_addr  */
+
+		/* find the range just before start_addr  */
+		for (cur_anchor = interval_tree_iter_first(&vma->anchor_page_rb,
+				vma->vm_start, start_addr - PAGE_SIZE);
+			 cur_anchor;
+			 prev_anchor = cur_anchor,
+			 cur_anchor = interval_tree_iter_next(cur_anchor,
+				vma->vm_start, start_addr - PAGE_SIZE));
+
+		interval_tree_remove(prev_anchor, &vma->anchor_page_rb);
+		prev_anchor->last = vma->vm_end;
+		interval_tree_insert(prev_anchor, &vma->anchor_page_rb);
+
+		goto out;
+	}
+
+insert_new_range: /* start_addr to end_addr  */
+	down_read(&vma->vm_mm->mmap_sem);
+	/* find the first present page and use it as the anchor page */
+	while (!present_page && scan_address < end_addr) {
+		present_page = follow_page(vma, scan_address,
+			FOLL_MIGRATION | FOLL_REMOTE);
+		scan_address += present_page?get_contig_page_size(present_page):PAGE_SIZE;
+	}
+	up_read(&vma->vm_mm->mmap_sem);
+
+	if (!present_page)
+		goto out;
+
+	anchor_node =
+			kmalloc(sizeof(struct anchor_page_node), GFP_KERNEL | __GFP_ZERO);
+	if (!anchor_node)
+		return -ENOMEM;
+
+	present_zone = page_zone(present_page);
+
+	anchor_node->node.start = start_addr;
+	anchor_node->node.last = end_addr;
+
+	anchor_node->anchor_vpn = start_addr>>PAGE_SHIFT;
+	anchor_node->anchor_pfn = get_undefragged_area(present_zone,
+			vma, start_addr, end_addr);
+
+	/* adjust VPN and PFN alignment according to VMA size */
+	if (vma->vm_end - vma->vm_start >= HPAGE_PUD_SIZE) {
+		if ((anchor_node->anchor_vpn & ((HPAGE_PUD_SIZE>>PAGE_SHIFT) - 1)) <
+			(anchor_node->anchor_pfn & ((HPAGE_PUD_SIZE>>PAGE_SHIFT) - 1)))
+			anchor_node->anchor_pfn += (HPAGE_PUD_SIZE>>PAGE_SHIFT);
+
+		anchor_node->anchor_pfn = (anchor_node->anchor_pfn & (PUD_MASK>>PAGE_SHIFT)) |
+			(anchor_node->anchor_vpn & ((HPAGE_PUD_SIZE>>PAGE_SHIFT) - 1));
+
+		alignment_size = HPAGE_PUD_SIZE;
+	} else if (vma->vm_end - vma->vm_start >= HPAGE_PMD_SIZE) {
+		if ((anchor_node->anchor_vpn & ((HPAGE_PMD_SIZE>>PAGE_SHIFT) - 1)) <
+			(anchor_node->anchor_pfn & ((HPAGE_PMD_SIZE>>PAGE_SHIFT) - 1)))
+			anchor_node->anchor_pfn += (HPAGE_PMD_SIZE>>PAGE_SHIFT);
+
+		anchor_node->anchor_pfn = (anchor_node->anchor_pfn & (PMD_MASK>>PAGE_SHIFT)) |
+			(anchor_node->anchor_vpn & ((HPAGE_PMD_SIZE>>PAGE_SHIFT) - 1));
+
+		alignment_size = HPAGE_PMD_SIZE;
+	} else
+		alignment_size = PAGE_SIZE;
+
+	/* move the range into the zone limit */
+	if (!(zone_spans_pfn(present_zone, anchor_node->anchor_pfn))) {
+		while (anchor_node->anchor_pfn >= zone_end_pfn(present_zone))
+			anchor_node->anchor_pfn -= alignment_size / PAGE_SHIFT;
+		while (anchor_node->anchor_pfn <  present_zone->zone_start_pfn)
+			anchor_node->anchor_pfn += alignment_size / PAGE_SHIFT;
+	}
+
+	interval_tree_insert(&anchor_node->node, &vma->anchor_page_rb);
+
+out:
+	return 0;
+}
+
+static inline bool is_stats_collection(enum mem_defrag_action action)
+{
+	switch (action) {
+	case MEM_DEFRAG_FULL_STATS:
+	case MEM_DEFRAG_CONTIG_STATS:
+		return true;
+	default:
+		return false;
+	}
+	return false;
+}
+
+/* comparator for sorting vma's lifetime */
+static int unsigned_long_cmp(const void *a, const void *b)
+{
+	const unsigned long *l = a, *r = b;
+
+	if (*l < *r)
+		return -1;
+	if (*l > *r)
+		return 1;
+	return 0;
+}
+
+/*
+ * scan all to-be-defragged VMA lifetime and calculate VMA defragmentation
+ * threshold.
+ */
+static void scan_all_vma_lifetime(struct defrag_scan_control *sc)
+{
+	struct mm_struct *mm = sc->mm;
+	struct vm_area_struct *vma = NULL;
+	unsigned long current_jiffies = jiffies; /* fix one jiffies  */
+	unsigned int num_vma = 0, index = 0;
+	unsigned long *vma_scan_list = NULL;
+
+	down_read(&mm->mmap_sem);
+	for (vma = find_vma(mm, 0); vma; vma = vma->vm_next)
+		/* only care about to-be-defragged vmas  */
+		if (mem_defrag_vma_check(vma))
+			++num_vma;
+
+	vma_scan_list = kmalloc(num_vma*sizeof(unsigned long),
+			GFP_KERNEL | __GFP_ZERO);
+
+	if (ZERO_OR_NULL_PTR(vma_scan_list)) {
+		sc->vma_scan_threshold = 1;
+		goto out;
+	}
+
+	for (vma = find_vma(mm, 0); vma; vma = vma->vm_next)
+		/* only care about to-be-defragged vmas  */
+		if (mem_defrag_vma_check(vma)) {
+			if (vma_scan_threshold_type == VMA_THRESHOLD_TYPE_TIME)
+				vma_scan_list[index] = current_jiffies - vma->vma_create_jiffies;
+			else if (vma_scan_threshold_type == VMA_THRESHOLD_TYPE_SIZE)
+				vma_scan_list[index] = vma->vm_end - vma->vm_start;
+			++index;
+			if (index >= num_vma)
+				break;
+		}
+
+	sort(vma_scan_list, num_vma, sizeof(unsigned long),
+		 unsigned_long_cmp, NULL);
+
+	index = (100 - vma_scan_percentile) * num_vma / 100;
+
+	sc->vma_scan_threshold = vma_scan_list[index];
+
+	kfree(vma_scan_list);
+out:
+	up_read(&mm->mmap_sem);
+}
+
+/*
+ * Scan single mm_struct.
+ * The function will down_read mmap_sem.
+ *
+ */
+static int kmem_defragd_scan_mm(struct defrag_scan_control *sc)
+{
+	struct mm_struct *mm = sc->mm;
+	struct vm_area_struct *vma = NULL;
+	unsigned long *scan_address = &sc->scan_address;
+	char *stats_buf = NULL;
+	int remain_buf_len = sc->buf_len;
+	int err = 0;
+	struct contig_stats contig_stats;
+
+
+	if (sc->out_buf &&
+		sc->buf_len) {
+		stats_buf = vzalloc(sc->buf_len);
+		if (!stats_buf)
+			goto breakouterloop;
+	}
+
+	/*down_read(&mm->mmap_sem);*/
+	if (unlikely(kmem_defragd_test_exit(mm)))
+		vma = NULL;
+	else {
+		/* get vma_scan_threshold  */
+		if (!sc->vma_scan_threshold)
+			scan_all_vma_lifetime(sc);
+
+		vma = find_vma(mm, *scan_address);
+	}
+
+	for (; vma; vma = vma->vm_next) {
+		unsigned long vstart, vend;
+		struct anchor_page_node *anchor_node = NULL;
+		int scanned_chunks = 0;
+
+
+		if (unlikely(kmem_defragd_test_exit(mm)))
+			break;
+		if (!mem_defrag_vma_check(vma)) {
+			/* collect contiguity stats for this VMA */
+			if (is_stats_collection(sc->action))
+				if (do_vma_stat(mm, vma, stats_buf, sc->buf_len - remain_buf_len,
+							&remain_buf_len))
+					goto breakouterloop;
+			*scan_address = vma->vm_end;
+			goto done_one_vma;
+		}
+
+
+		vstart = vma->vm_start;
+		vend = vma->vm_end;
+		if (vstart >= vend)
+			goto done_one_vma;
+		if (*scan_address > vend)
+			goto done_one_vma;
+		if (*scan_address < vstart)
+			*scan_address = vstart;
+
+		if (sc->action == MEM_DEFRAG_DO_DEFRAG) {
+			/* Check VMA size, skip if below the size threshold */
+			if (vma->vm_end - vma->vm_start <
+					defrag_size_threshold * HPAGE_PMD_SIZE)
+				goto done_one_vma;
+
+			/*
+			 * Check VMA lifetime or size, skip if below the lifetime/size
+			 * threshold derived from a percentile
+			 */
+			if (vma_scan_threshold_type == VMA_THRESHOLD_TYPE_TIME) {
+				if ((jiffies - vma->vma_create_jiffies) < sc->vma_scan_threshold)
+					goto done_one_vma;
+			} else if (vma_scan_threshold_type == VMA_THRESHOLD_TYPE_SIZE) {
+				if ((vma->vm_end - vma->vm_start) < sc->vma_scan_threshold)
+					goto done_one_vma;
+			}
+
+			/* Avoid repeated defrag if the vma has not been changed */
+			if (vma_no_repeat_defrag &&
+				vma->vma_defrag_jiffies > vma->vma_modify_jiffies)
+				goto done_one_vma;
+
+			/* vma contiguity stats collection */
+			if (remain_buf_len && stats_buf) {
+				int used_len;
+				int pos = sc->buf_len - remain_buf_len;
+
+				used_len = scnprintf(stats_buf + pos, remain_buf_len,
+							"vma: 0x%lx, 0x%lx, 0x%lx, -1\n",
+							(unsigned long)vma+vma->vma_create_jiffies,
+							vma->vm_start, vma->vm_end);
+
+				remain_buf_len -= used_len;
+
+				if (remain_buf_len == 1) {
+					stats_buf[pos] = '\0';
+					remain_buf_len = 0;
+				}
+			}
+
+			anchor_node = get_anchor_page_node_from_vma(vma, vma->vm_start);
+
+			if (!anchor_node) {
+				find_anchor_pages_in_vma(mm, vma, vma->vm_start);
+				anchor_node = get_anchor_page_node_from_vma(vma, vma->vm_start);
+
+				if (!anchor_node)
+					goto done_one_vma;
+			}
+		}
+
+		contig_stats = (struct contig_stats) {0};
+
+		while (*scan_address < vend) {
+			struct page *page;
+
+			cond_resched();
+
+			if (unlikely(kmem_defragd_test_exit(mm)))
+				goto breakouterloop;
+
+			if (is_stats_collection(sc->action)) {
+				down_read(&vma->vm_mm->mmap_sem);
+				page = follow_page(vma, *scan_address,
+						FOLL_MIGRATION | FOLL_REMOTE);
+
+				if (do_page_stat(mm, vma, page, *scan_address,
+							stats_buf, sc->buf_len - remain_buf_len,
+							&remain_buf_len, sc->action, &contig_stats,
+							sc->scan_in_vma)) {
+					/* reset scan_address to the beginning of the contig.
+					 * So next scan will get the whole contig.
+					 */
+					if (contig_stats.err) {
+						*scan_address = contig_stats.first_vaddr_in_chunk;
+						sc->scan_in_vma = true;
+					}
+					goto breakouterloop;
+				}
+				/* move to next address */
+				if (page)
+					*scan_address += get_contig_page_size(page);
+				else
+					*scan_address += PAGE_SIZE;
+				up_read(&vma->vm_mm->mmap_sem);
+			} else if (sc->action == MEM_DEFRAG_DO_DEFRAG) {
+				/* go to nearest 1GB aligned address  */
+				unsigned long defrag_end = min_t(unsigned long,
+							(*scan_address + HPAGE_PUD_SIZE) & HPAGE_PUD_MASK,
+							vend);
+				int defrag_result;
+
+				anchor_node = get_anchor_page_node_from_vma(vma, *scan_address);
+
+				/*  in case VMA size changes */
+				if (!anchor_node) {
+					find_anchor_pages_in_vma(mm, vma, *scan_address);
+					anchor_node = get_anchor_page_node_from_vma(vma, *scan_address);
+				}
+
+				if (!anchor_node)
+					goto done_one_vma;
+
+				/*
+				 * looping through the 1GB region and defrag 2MB range in each
+				 * iteration.
+				 */
+				while (*scan_address < defrag_end) {
+					unsigned long defrag_sub_chunk_end = min_t(unsigned long,
+							(*scan_address + HPAGE_PMD_SIZE) & HPAGE_PMD_MASK,
+							defrag_end);
+					struct defrag_result_stats defrag_stats = {0};
+continue_defrag:
+					if (!anchor_node) {
+						anchor_node = get_anchor_page_node_from_vma(vma,
+										*scan_address);
+						if (!anchor_node) {
+							find_anchor_pages_in_vma(mm, vma, *scan_address);
+							anchor_node = get_anchor_page_node_from_vma(vma,
+											*scan_address);
+						}
+						if (!anchor_node)
+							goto done_one_vma;
+					}
+
+					defrag_result = defrag_address_range(mm, vma, *scan_address,
+									defrag_sub_chunk_end,
+									pfn_to_page(anchor_node->anchor_pfn),
+									anchor_node->anchor_vpn<<PAGE_SHIFT,
+									&defrag_stats);
+
+					/*
+					 * collect defrag results to show the cause of page
+					 * migration/exchange failure
+					 */
+					if (remain_buf_len && stats_buf) {
+						int used_len;
+						int pos = sc->buf_len - remain_buf_len;
+
+						used_len = scnprintf(stats_buf + pos, remain_buf_len,
+							"[0x%lx, 0x%lx):%lu [alig:%lu, migrated:%lu, "
+							"src: not:%lu, src_thp_dst_not:%lu, src_pte_thp:%lu "
+							"dst: out_bound:%lu, dst_thp_src_not:%lu, "
+							"dst_pte_thp:%lu, isolate_free:%lu, "
+							"migrate_free:%lu, anon:%lu, file:%lu, "
+							"non-lru:%lu, non-moveable:%lu], "
+							"anchor: (%lx, %lx), range: [%lx, %lx], "
+							"vma: 0x%lx, not_defrag_vpn: %lx\n",
+							*scan_address, defrag_sub_chunk_end,
+							(defrag_sub_chunk_end - *scan_address)/PAGE_SIZE,
+							defrag_stats.aligned,
+							defrag_stats.migrated,
+							defrag_stats.src_not_present,
+							defrag_stats.src_thp_dst_not_failed,
+							defrag_stats.src_pte_thp_failed,
+							defrag_stats.dst_out_of_bound_failed,
+							defrag_stats.dst_thp_src_not_failed,
+							defrag_stats.dst_pte_thp_failed,
+							defrag_stats.dst_isolate_free_failed,
+							defrag_stats.dst_migrate_free_failed,
+							defrag_stats.dst_anon_failed,
+							defrag_stats.dst_file_failed,
+							defrag_stats.dst_non_lru_failed,
+							defrag_stats.dst_non_moveable_failed,
+							anchor_node->anchor_vpn,
+							anchor_node->anchor_pfn,
+							anchor_node->node.start,
+							anchor_node->node.last,
+							(unsigned long)vma+vma->vma_create_jiffies,
+							defrag_stats.not_defrag_vpn
+							);
+
+						remain_buf_len -= used_len;
+
+						if (remain_buf_len == 1) {
+							stats_buf[pos] = '\0';
+							remain_buf_len = 0;
+						}
+					}
+
+					/*
+					 * skip the page which cannot be defragged and restart
+					 * from the next page
+					 */
+					if (defrag_stats.not_defrag_vpn &&
+						defrag_stats.not_defrag_vpn < defrag_sub_chunk_end) {
+						VM_BUG_ON(defrag_sub_chunk_end != defrag_end &&
+							defrag_stats.not_defrag_vpn > defrag_sub_chunk_end);
+
+						*scan_address = defrag_stats.not_defrag_vpn;
+						defrag_stats.not_defrag_vpn = 0;
+						goto continue_defrag;
+					}
+
+					/* Done with current 2MB chunk */
+					*scan_address = defrag_sub_chunk_end;
+					scanned_chunks++;
+					/*
+					 * if the knob is set, break out of the defrag loop after
+					 * a preset number of 2MB chunks are defragged
+					 */
+					if (num_breakout_chunks && scanned_chunks >= num_breakout_chunks) {
+						scanned_chunks = 0;
+						goto breakouterloop;
+					}
+				}
+
+			}
+		}
+done_one_vma:
+		sc->scan_in_vma = false;
+		if (sc->action == MEM_DEFRAG_DO_DEFRAG)
+			vma->vma_defrag_jiffies = jiffies;
+	}
+breakouterloop:
+
+	/* copy stats to user space */
+	if (sc->out_buf &&
+		sc->buf_len) {
+		err = copy_to_user(sc->out_buf, stats_buf,
+				sc->buf_len - remain_buf_len);
+		sc->used_len = sc->buf_len - remain_buf_len;
+	}
+
+	if (stats_buf)
+		vfree(stats_buf);
+
+	/* 0: scan a vma complete, 1: scan a vma incomplete  */
+	return vma == NULL ? 0 : 1;
+}
+
+SYSCALL_DEFINE4(scan_process_memory, pid_t, pid, char __user *, out_buf,
+				int, buf_len, int, action)
+{
+	const struct cred *cred = current_cred(), *tcred;
+	struct task_struct *task;
+	struct mm_struct *mm;
+	int err = 0;
+	static struct defrag_scan_control defrag_scan_control = {0};
+
+	/* Find the mm_struct */
+	rcu_read_lock();
+	task = pid ? find_task_by_vpid(pid) : current;
+	if (!task) {
+		rcu_read_unlock();
+		return -ESRCH;
+	}
+	get_task_struct(task);
+
+	/*
+	 * Check if this process has the right to modify the specified
+	 * process. The right exists if the process has administrative
+	 * capabilities, superuser privileges or the same
+	 * userid as the target process.
+	 */
+	tcred = __task_cred(task);
+	if (!uid_eq(cred->euid, tcred->suid) && !uid_eq(cred->euid, tcred->uid) &&
+	    !uid_eq(cred->uid,  tcred->suid) && !uid_eq(cred->uid,  tcred->uid) &&
+	    !capable(CAP_SYS_NICE)) {
+		rcu_read_unlock();
+		err = -EPERM;
+		goto out;
+	}
+	rcu_read_unlock();
+
+	err = security_task_movememory(task);
+	if (err)
+		goto out;
+
+	mm = get_task_mm(task);
+	put_task_struct(task);
+
+	if (!mm)
+		return -EINVAL;
+
+	switch (action) {
+	case MEM_DEFRAG_SCAN:
+	case MEM_DEFRAG_CONTIG_SCAN:
+		count_vm_event(MEM_DEFRAG_SCAN_NUM);
+		/*
+		 * We allow scanning one process's address space for multiple
+		 * iterations. When we change the scanned process, reset
+		 * defrag_scan_control's mm_struct
+		 */
+		if (!defrag_scan_control.mm ||
+			defrag_scan_control.mm != mm) {
+			defrag_scan_control = (struct defrag_scan_control){0};
+			defrag_scan_control.mm = mm;
+		}
+		defrag_scan_control.out_buf = out_buf;
+		defrag_scan_control.buf_len = buf_len;
+		if (action == MEM_DEFRAG_SCAN)
+			defrag_scan_control.action = MEM_DEFRAG_FULL_STATS;
+		else if (action == MEM_DEFRAG_CONTIG_SCAN)
+			defrag_scan_control.action = MEM_DEFRAG_CONTIG_STATS;
+		else {
+			err = -EINVAL;
+			break;
+		}
+
+		defrag_scan_control.used_len = 0;
+
+		if (unlikely(!access_ok(out_buf, buf_len))) {
+			err = -EFAULT;
+			break;
+		}
+
+		/* clear mm once it is fully scanned  */
+		if (!kmem_defragd_scan_mm(&defrag_scan_control) &&
+			!defrag_scan_control.used_len)
+			defrag_scan_control.mm = NULL;
+
+		err = defrag_scan_control.used_len;
+		break;
+	case MEM_DEFRAG_MARK_SCAN_ALL:
+		set_bit(MMF_VM_MEM_DEFRAG_ALL, &mm->flags);
+		__kmem_defragd_enter(mm);
+		break;
+	case MEM_DEFRAG_CLEAR_SCAN_ALL:
+		clear_bit(MMF_VM_MEM_DEFRAG_ALL, &mm->flags);
+		break;
+	case MEM_DEFRAG_DEFRAG:
+		count_vm_event(MEM_DEFRAG_DEFRAG_NUM);
+
+		if (!defrag_scan_control.mm ||
+			defrag_scan_control.mm != mm) {
+			defrag_scan_control = (struct defrag_scan_control){0};
+			defrag_scan_control.mm = mm;
+		}
+		defrag_scan_control.action = MEM_DEFRAG_DO_DEFRAG;
+
+		defrag_scan_control.out_buf = out_buf;
+		defrag_scan_control.buf_len = buf_len;
+
+		/* clear mm once it is fully defragged */
+		if (buf_len) {
+			if (!kmem_defragd_scan_mm(&defrag_scan_control) &&
+				!defrag_scan_control.used_len) {
+				defrag_scan_control.mm = NULL;
+			}
+			err = defrag_scan_control.used_len;
+		} else {
+			err = kmem_defragd_scan_mm(&defrag_scan_control);
+			if (err == 0)
+				defrag_scan_control.mm = NULL;
+		}
+		break;
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+	mmput(mm);
+	return err;
+
+out:
+	put_task_struct(task);
+	return err;
+}
+
+static unsigned int kmem_defragd_scan_mm_slot(void)
+{
+	struct mm_slot *mm_slot;
+	int scan_status = 0;
+	struct defrag_scan_control defrag_scan_control = {0};
+
+	spin_lock(&kmem_defragd_mm_lock);
+	if (kmem_defragd_scan.mm_slot)
+		mm_slot = kmem_defragd_scan.mm_slot;
+	else {
+		mm_slot = list_entry(kmem_defragd_scan.mm_head.next,
+				     struct mm_slot, mm_node);
+		kmem_defragd_scan.address = 0;
+		kmem_defragd_scan.mm_slot = mm_slot;
+	}
+	spin_unlock(&kmem_defragd_mm_lock);
+
+	defrag_scan_control.mm = mm_slot->mm;
+	defrag_scan_control.scan_address = kmem_defragd_scan.address;
+	defrag_scan_control.action = MEM_DEFRAG_DO_DEFRAG;
+
+	scan_status = kmem_defragd_scan_mm(&defrag_scan_control);
+
+	kmem_defragd_scan.address = defrag_scan_control.scan_address;
+
+	spin_lock(&kmem_defragd_mm_lock);
+	VM_BUG_ON(kmem_defragd_scan.mm_slot != mm_slot);
+	/*
+	 * Release the current mm_slot if this mm is about to die, or
+	 * if we scanned all vmas of this mm.
+	 */
+	if (kmem_defragd_test_exit(mm_slot->mm) || !scan_status) {
+		/*
+		 * Make sure that if mm_users is reaching zero while
+		 * kmem_defragd runs here, kmem_defragd_exit will find
+		 * mm_slot not pointing to the exiting mm.
+		 */
+		if (mm_slot->mm_node.next != &kmem_defragd_scan.mm_head) {
+			kmem_defragd_scan.mm_slot = list_first_entry(
+				&mm_slot->mm_node,
+				struct mm_slot, mm_node);
+			kmem_defragd_scan.address = 0;
+		} else
+			kmem_defragd_scan.mm_slot = NULL;
+
+		if (kmem_defragd_test_exit(mm_slot->mm))
+			collect_mm_slot(mm_slot);
+		else if (!scan_status) {
+			list_del(&mm_slot->mm_node);
+			list_add_tail(&mm_slot->mm_node, &kmem_defragd_scan.mm_head);
+		}
+	}
+	spin_unlock(&kmem_defragd_mm_lock);
+
+	return 0;
+}
+
+int memdefrag_madvise(struct vm_area_struct *vma,
+		     unsigned long *vm_flags, int advice)
+{
+	switch (advice) {
+	case MADV_MEMDEFRAG:
+		*vm_flags &= ~VM_NOMEMDEFRAG;
+		*vm_flags |= VM_MEMDEFRAG;
+		/*
+		 * If the vma become good for kmem_defragd to scan,
+		 * register it here without waiting a page fault that
+		 * may not happen any time soon.
+		 */
+		if (kmem_defragd_enter(vma, *vm_flags))
+			return -ENOMEM;
+		break;
+	case MADV_NOMEMDEFRAG:
+		*vm_flags &= ~VM_MEMDEFRAG;
+		*vm_flags |= VM_NOMEMDEFRAG;
+		/*
+		 * Setting VM_NOMEMDEFRAG will prevent kmem_defragd from scanning
+		 * this vma even if we leave the mm registered in kmem_defragd if
+		 * it got registered before VM_NOMEMDEFRAG was set.
+		 */
+		break;
+	}
+
+	return 0;
+}
+
+
+void __init kmem_defragd_destroy(void)
+{
+	kmem_cache_destroy(mm_slot_cache);
+}
+
+int __init kmem_defragd_init(void)
+{
+	mm_slot_cache = kmem_cache_create("kmem_defragd_mm_slot",
+					  sizeof(struct mm_slot),
+					  __alignof__(struct mm_slot), 0, NULL);
+	if (!mm_slot_cache)
+		return -ENOMEM;
+
+	return 0;
+}
+
+subsys_initcall(kmem_defragd_init);
\ No newline at end of file
diff --git a/mm/memory.c b/mm/memory.c
index e11ca9dd823f..019036e87088 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -69,6 +69,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/dax.h>
 #include <linux/oom.h>
+#include <linux/mem_defrag.h>
 
 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -2926,6 +2927,9 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	/* Allocate our own private page. */
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
+	/* Make it defrag  */
+	if (unlikely(kmem_defragd_enter(vma, vma->vm_flags)))
+		goto oom;
 	page = alloc_zeroed_user_highpage_movable(vma, vmf->address);
 	if (!page)
 		goto oom;
@@ -3844,6 +3848,9 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
 	p4d_t *p4d;
 	vm_fault_t ret;
 
+	/* Zi: page faults modify vma */
+	vma->vma_modify_jiffies = jiffies;
+
 	pgd = pgd_offset(mm, address);
 	p4d = p4d_alloc(mm, pgd, address);
 	if (!p4d)
diff --git a/mm/mmap.c b/mm/mmap.c
index f901065c4c64..653dd99d5145 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -169,6 +169,28 @@ void unlink_file_vma(struct vm_area_struct *vma)
 	}
 }
 
+void free_anchor_pages(struct vm_area_struct *vma)
+{
+	struct interval_tree_node *node;
+
+	if (!vma)
+		return;
+
+	if (RB_EMPTY_ROOT(&vma->anchor_page_rb.rb_root))
+		return;
+
+	for (node = interval_tree_iter_first(&vma->anchor_page_rb,
+				0, (unsigned long)-1);
+		 node;) {
+		struct anchor_page_node *anchor_node = container_of(node,
+					struct anchor_page_node, node);
+		interval_tree_remove(node, &vma->anchor_page_rb);
+		node = interval_tree_iter_next(node, 0, (unsigned long)-1);
+		kfree(anchor_node);
+	}
+
+}
+
 /*
  * Close a vm structure and free it, returning the next.
  */
@@ -181,6 +203,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
 		fput(vma->vm_file);
+	free_anchor_pages(vma);
 	mpol_put(vma_policy(vma));
 	vm_area_free(vma);
 	return next;
@@ -725,10 +748,15 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	long adjust_next = 0;
 	int remove_next = 0;
 
+	/*free_anchor_pages(vma);*/
+
+	vma->vma_modify_jiffies = jiffies;
+
 	if (next && !insert) {
 		struct vm_area_struct *exporter = NULL, *importer = NULL;
 
 		if (end >= next->vm_end) {
+			/*free_anchor_pages(next);*/
 			/*
 			 * vma expands, overlapping all the next, and
 			 * perhaps the one after too (mprotect case 6).
@@ -775,6 +803,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 				exporter = next->vm_next;
 
 		} else if (end > next->vm_start) {
+			/*free_anchor_pages(next);*/
 			/*
 			 * vma expands, overlapping part of the next:
 			 * mprotect case 5 shifting the boundary up.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35fdde041f5c..a35605e0924a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1828,7 +1828,7 @@ void __init init_cma_reserved_pageblock(struct page *page)
  *
  * -- nyc
  */
-static inline void expand(struct zone *zone, struct page *page,
+inline void expand(struct zone *zone, struct page *page,
 	int low, int high, struct free_area *area,
 	int migratetype)
 {
@@ -1950,7 +1950,7 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 	set_page_owner(page, order, gfp_flags);
 }
 
-static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
+void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 							unsigned int alloc_flags)
 {
 	int i;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 83b30edc2f7f..c18a42250a5c 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1293,6 +1293,27 @@ const char * const vmstat_text[] = {
 	"swap_ra",
 	"swap_ra_hit",
 #endif
+	"memdefrag_defrag",
+	"memdefrag_scan",
+	"memdefrag_dest_free_pages",
+	"memdefrag_dest_anon_pages",
+	"memdefrag_dest_file_pages",
+	"memdefrag_dest_non_lru_pages",
+	"memdefrag_dest_free_pages_failed",
+	"memdefrag_dest_free_pages_overflow_failed",
+	"memdefrag_dest_anon_pages_failed",
+	"memdefrag_dest_file_pages_failed",
+	"memdefrag_dest_nonlru_pages_failed",
+	"memdefrag_src_anon_pages_failed",
+	"memdefrag_src_compound_pages_failed",
+	"memdefrag_dst_split_hugepage",
+#ifdef CONFIG_COMPACTION
+	"compact_migrate_pages",
+#endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	"thp_collapse_migrate_pages"
+#endif
+
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
 #endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */
-- 
2.20.1

