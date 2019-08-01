Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A374C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:25:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B548C2087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:25:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="VD36srcN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B548C2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE81F8E0029; Thu,  1 Aug 2019 11:24:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E71898E0001; Thu,  1 Aug 2019 11:24:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC3FA8E0029; Thu,  1 Aug 2019 11:24:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2ADF8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 11:24:53 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h47so64945006qtc.20
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 08:24:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=TI08pAABernsFaEO6re+49u61n7MA9mutB/2zYVl+eU=;
        b=r//ryuZM1pvZhyA38qJ9RjH4V8waa48lvDv2snCcvI6snKfhfbnFfOvIzGDnN9VjOX
         3bMcyroaQCNtGhxEOYj16au0JNSs1PCzCghNclezzogOmGN+OKHbvgon8lelADf33ypZ
         KzPv8qNcUGIavGl09/N/ReFr9ammHOxL/I1TjOMhQPXff1m5R4+RQsblVApqOaF/0eI8
         IetpAWHj1o5IGUPd8B12NJZwUtfu/53lTyOm6oEdK6jDNkVE3zr8YVgjZ87fiMNdKLgg
         0IjZdgEFISuB5//ef3T5w/uikni/yAb0wM1ZcaRSewiPUYsWVGCC/KK0sw9E2H2xpkAQ
         i6vw==
X-Gm-Message-State: APjAAAXffrEeow9K0fGKB2eBIJf3zbDm3B4101Xdu4TbIhz95u22qXsL
	MYIza1DXVaNgLIAe/VYk0yPovoSXl1ybCBRyCltvR4B6abUi5/G4Hxsds0nL+W4QgjE3YHBXEPy
	FPIDLzbN7YCmYGaJejK1P6ylJIPOrqYnt+jZLTxPawJuXeb2+o6hQi4Dx+0Lo0tfG2A==
X-Received: by 2002:a0c:d1e2:: with SMTP id k31mr94362375qvh.173.1564673093418;
        Thu, 01 Aug 2019 08:24:53 -0700 (PDT)
X-Received: by 2002:a0c:d1e2:: with SMTP id k31mr94362249qvh.173.1564673092081;
        Thu, 01 Aug 2019 08:24:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564673092; cv=none;
        d=google.com; s=arc-20160816;
        b=iOQNeQh6U1DoGb7ZTpB7vgRjXUaDFyrawwZ+zJ0JHAeTzlPRRvwOgf4fRCP2douXDs
         ETNQpujsFd1red3NOF8YOQ2Ah1NYmbkbksKVLiInmRXIZ9n2kXm+Rpw7TA3EK+oaBGCi
         2SpfLhYMX5MGZfuxdLUPKAo65BLVYd1r4Zw77u7Spe2cRH8Sk5BoF9tPkN2e3EcVlH3R
         uM4jPOs7vvGnz0OQaiLL27wTwcrSU/QV6GvBRMRRMJir3eze1lHQtO31P1oX47E63bmZ
         UdNRJz9nDjeKn/qYPfw/25GxcTeDJuhZwRWwLik7U3fkKTPhodOJK0xlX0kBvCsP2Z3m
         L09g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=TI08pAABernsFaEO6re+49u61n7MA9mutB/2zYVl+eU=;
        b=MOlGch5UrIsdlqB8D3QjHPKvM8EgfrkDNawX1HWZGEj1eIZTuyx/gtmZaBylFmpGPg
         FEpUlwymRz/G/8gi5/ZO1ssIemy/oJxbdWf4oBinlcX7xHeWZctlv96FZsFkThnUg5PG
         I/5xjOnRM44XYjY9XqxFWf7FyalefPNHvqSLhVMuZLGN/UBEdIV6i91lJxVtyzhTr48Z
         3hNAnYoEv7uZkNxBEUKCYJjCnv8g3w9AzYufyzW4zEvdDoyEjEKB+9tRPW+LXmY+1zjD
         LU/v0Qu1nyZjPPgdBWQiUsyOfGmNHB4FYIKJMboXqoc2KK1Zx/tbmegiD26wd0ATo4qr
         LqEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=VD36srcN;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z124sor40582853qkd.42.2019.08.01.08.24.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 08:24:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=VD36srcN;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TI08pAABernsFaEO6re+49u61n7MA9mutB/2zYVl+eU=;
        b=VD36srcNf2VUG8H3tSx+ZSf/luOHis+lT5h4LMWGsogWCUh0OA41faN9JHbv0Qzvlt
         hKnm0h6R7b+z8iTgMGEdw+uyGgZlTH3tCByd0zygw2SaMJuL6hMwWsz/RN92mbR9L+Xm
         sBhYnGz7raEQeCaTl5O+wCWpjjjR3winlFB2utMk7eyk6M8cZYxDTcOvJRULNxfnqfES
         YP1kYXRvw2yP1it5kKXkqVYH97Vi0FHWOaDE4cbo77aYv6cKu8pZarMzYscqw6MwHguG
         BDzb+C44k1RXpq59EP976ZVoHjYoyN/yiYCL7+typwtJLLBtVZef0PWkcZW38r5pRdVR
         r1aw==
X-Google-Smtp-Source: APXvYqyVNeMV2pthJyVhFt1LEnqNY+v0Wh9vD1Cowy4owrD/G6PrQhPZwpyYWSndx4BtQo2MC72i4Q==
X-Received: by 2002:ae9:e608:: with SMTP id z8mr84955133qkf.182.1564673091741;
        Thu, 01 Aug 2019 08:24:51 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o5sm30899952qkf.10.2019.08.01.08.24.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 08:24:51 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org
Subject: [PATCH v1 7/8] arm64, kexec: configure transitional page table for kexec
Date: Thu,  1 Aug 2019 11:24:38 -0400
Message-Id: <20190801152439.11363-8-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801152439.11363-1-pasha.tatashin@soleen.com>
References: <20190801152439.11363-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Configure a page table located in kexec-safe memory that has
the following mappings:

1. identity mapping for text of relocation function with executable permission.
2. identity mapping for argument for relocation function.
3. linear mappings for all source ranges
4. linear mappings for all destination ranges.

Also, configure el2_vector, that is used to jump to new kernel from EL2 on
non-VHE kernels.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/kexec.h      |  32 +++++++
 arch/arm64/kernel/asm-offsets.c     |   6 ++
 arch/arm64/kernel/machine_kexec.c   | 129 ++++++++++++++++++++++++++--
 arch/arm64/kernel/relocate_kernel.S |  16 +++-
 4 files changed, 174 insertions(+), 9 deletions(-)

diff --git a/arch/arm64/include/asm/kexec.h b/arch/arm64/include/asm/kexec.h
index d5b79d4c7fae..450d8440f597 100644
--- a/arch/arm64/include/asm/kexec.h
+++ b/arch/arm64/include/asm/kexec.h
@@ -90,6 +90,23 @@ static inline void crash_prepare_suspend(void) {}
 static inline void crash_post_resume(void) {}
 #endif
 
+#if defined(CONFIG_KEXEC_CORE)
+/* Global variables for the arm64_relocate_new_kernel routine. */
+extern const unsigned char arm64_relocate_new_kernel[];
+extern const unsigned long arm64_relocate_new_kernel_size;
+
+/* Body of the vector for escalating to EL2 from relocation routine */
+extern const unsigned char kexec_el1_sync[];
+extern const unsigned long kexec_el1_sync_size;
+
+#define KEXEC_EL2_VECTOR_TABLE_SIZE	2048
+#define KEXEC_EL2_SYNC_OFFSET		(KEXEC_EL2_VECTOR_TABLE_SIZE / 2)
+
+#endif
+
+#define KEXEC_SRC_START	PAGE_OFFSET
+#define KEXEC_DST_START	(PAGE_OFFSET + \
+			((UL(0xffffffffffffffff) - PAGE_OFFSET) >> 1) + 1)
 /*
  * kern_reloc_arg is passed to kernel relocation function as an argument.
  * head		kimage->head, allows to traverse through relocation segments.
@@ -97,6 +114,15 @@ static inline void crash_post_resume(void) {}
  *		kernel, or purgatory entry address).
  * kern_arg0	first argument to kernel is its dtb address. The other
  *		arguments are currently unused, and must be set to 0
+ * trans_ttbr0	idmap for relocation function and its argument
+ * trans_ttbr1	linear map for source/destination addresses.
+ * el2_vector	If present means that relocation routine will go to EL1
+ *		from EL2 to do the copy, and then back to EL2 to do the jump
+ *		to new world. This vector contains only the final jump
+ *		instruction at KEXEC_EL2_SYNC_OFFSET.
+ * src_addr	linear map for source pages.
+ * dst_addr	linear map for destination pages.
+ * copy_len	Number of bytes that need to be copied
  */
 struct kern_reloc_arg {
 	unsigned long	head;
@@ -105,6 +131,12 @@ struct kern_reloc_arg {
 	unsigned long	kern_arg1;
 	unsigned long	kern_arg2;
 	unsigned long	kern_arg3;
+	unsigned long	trans_ttbr0;
+	unsigned long	trans_ttbr1;
+	unsigned long	el2_vector;
+	unsigned long	src_addr;
+	unsigned long	dst_addr;
+	unsigned long	copy_len;
 };
 
 #define ARCH_HAS_KIMAGE_ARCH
diff --git a/arch/arm64/kernel/asm-offsets.c b/arch/arm64/kernel/asm-offsets.c
index 900394907fd8..7c2ba09a8ceb 100644
--- a/arch/arm64/kernel/asm-offsets.c
+++ b/arch/arm64/kernel/asm-offsets.c
@@ -135,6 +135,12 @@ int main(void)
   DEFINE(KRELOC_KERN_ARG1,	offsetof(struct kern_reloc_arg, kern_arg1));
   DEFINE(KRELOC_KERN_ARG2,	offsetof(struct kern_reloc_arg, kern_arg2));
   DEFINE(KRELOC_KERN_ARG3,	offsetof(struct kern_reloc_arg, kern_arg3));
+  DEFINE(KRELOC_TRANS_TTBR0,	offsetof(struct kern_reloc_arg, trans_ttbr0));
+  DEFINE(KRELOC_TRANS_TTBR1,	offsetof(struct kern_reloc_arg, trans_ttbr1));
+  DEFINE(KRELOC_EL2_VECTOR,	offsetof(struct kern_reloc_arg, el2_vector));
+  DEFINE(KRELOC_SRC_ADDR,	offsetof(struct kern_reloc_arg, src_addr));
+  DEFINE(KRELOC_DST_ADDR,	offsetof(struct kern_reloc_arg, dst_addr));
+  DEFINE(KRELOC_COPY_LEN,	offsetof(struct kern_reloc_arg, copy_len));
 #endif
   return 0;
 }
diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machine_kexec.c
index d745ea2051df..16f761fc50c8 100644
--- a/arch/arm64/kernel/machine_kexec.c
+++ b/arch/arm64/kernel/machine_kexec.c
@@ -20,13 +20,10 @@
 #include <asm/mmu.h>
 #include <asm/mmu_context.h>
 #include <asm/page.h>
+#include <asm/trans_table.h>
 
 #include "cpu-reset.h"
 
-/* Global variables for the arm64_relocate_new_kernel routine. */
-extern const unsigned char arm64_relocate_new_kernel[];
-extern const unsigned long arm64_relocate_new_kernel_size;
-
 /**
  * kexec_image_info - For debugging output.
  */
@@ -72,15 +69,128 @@ static void *kexec_page_alloc(void *arg)
 	return page_address(page);
 }
 
+/*
+ * Map source segments starting from KEXEC_SRC_START, and map destination
+ * segments starting from KEXEC_DST_START, and return size of copy in
+ * *copy_len argument.
+ * Relocation function essentially needs to do:
+ * memcpy(KEXEC_DST_START, KEXEC_SRC_START, copy_len);
+ */
+static int map_segments(struct kimage *kimage, pgd_t *pgdp,
+			struct trans_table_info *info,
+			unsigned long *copy_len)
+{
+	unsigned long *ptr = 0;
+	unsigned long dest = 0;
+	unsigned long src_va = KEXEC_SRC_START;
+	unsigned long dst_va = KEXEC_DST_START;
+	unsigned long len = 0;
+	unsigned long entry, addr;
+	int rc;
+
+	for (entry = kimage->head; !(entry & IND_DONE); entry = *ptr++) {
+		addr = entry & PAGE_MASK;
+
+		switch (entry & IND_FLAGS) {
+		case IND_DESTINATION:
+			dest = addr;
+			break;
+		case IND_INDIRECTION:
+			ptr = __va(addr);
+			if (rc)
+				return rc;
+			break;
+		case IND_SOURCE:
+			rc = trans_table_map_page(info, pgdp, __va(addr),
+						  src_va, PAGE_KERNEL);
+			if (rc)
+				return rc;
+			rc = trans_table_map_page(info, pgdp, __va(dest),
+						  dst_va, PAGE_KERNEL);
+			if (rc)
+				return rc;
+			dest += PAGE_SIZE;
+			src_va += PAGE_SIZE;
+			dst_va += PAGE_SIZE;
+			len += PAGE_SIZE;
+		}
+	}
+	*copy_len = len;
+
+	return 0;
+}
+
+static int mmu_relocate_setup(struct kimage *kimage, unsigned long kern_reloc,
+			      struct kern_reloc_arg *kern_reloc_arg)
+{
+	struct trans_table_info info = {
+		.trans_alloc_page	= kexec_page_alloc,
+		.trans_alloc_arg	= kimage,
+		.trans_flags		= 0,
+	};
+	pgd_t *trans_ttbr0, *trans_ttbr1;
+	int rc;
+
+	rc = trans_table_create_empty(&info, &trans_ttbr0);
+	if (rc)
+		return rc;
+
+	rc = trans_table_create_empty(&info, &trans_ttbr1);
+	if (rc)
+		return rc;
+
+	rc = map_segments(kimage, trans_ttbr1, &info,
+			  &kern_reloc_arg->copy_len);
+	if (rc)
+		return rc;
+
+	/* Map relocation function va == pa */
+	rc = trans_table_map_page(&info, trans_ttbr0,  __va(kern_reloc),
+				  kern_reloc, PAGE_KERNEL_EXEC);
+	if (rc)
+		return rc;
+
+	/* Map relocation function argument va == pa */
+	rc = trans_table_map_page(&info, trans_ttbr0, kern_reloc_arg,
+				  __pa(kern_reloc_arg), PAGE_KERNEL);
+	if (rc)
+		return rc;
+
+	kern_reloc_arg->trans_ttbr0 = phys_to_ttbr(__pa(trans_ttbr0));
+	kern_reloc_arg->trans_ttbr1 = phys_to_ttbr(__pa(trans_ttbr1));
+	kern_reloc_arg->src_addr = KEXEC_SRC_START;
+	kern_reloc_arg->dst_addr = KEXEC_DST_START;
+
+	return 0;
+}
+
 int machine_kexec_post_load(struct kimage *kimage)
 {
+	unsigned long el2_vector = 0;
 	unsigned long kern_reloc;
 	struct kern_reloc_arg *kern_reloc_arg;
+	int rc = 0;
+
+	/*
+	 * Sanity check that relocation function + el2_vector fit into one
+	 * page.
+	 */
+	if (arm64_relocate_new_kernel_size > KEXEC_EL2_VECTOR_TABLE_SIZE) {
+		pr_err("can't fit relocation function and el2_vector in one page");
+		return -ENOMEM;
+	}
 
 	kern_reloc = page_to_phys(kimage->control_code_page);
 	memcpy(__va(kern_reloc), arm64_relocate_new_kernel,
 	       arm64_relocate_new_kernel_size);
 
+	/* Setup vector table only when EL2 is available, but no VHE */
+	if (is_hyp_mode_available() && !is_kernel_in_hyp_mode()) {
+		el2_vector = kern_reloc + KEXEC_EL2_VECTOR_TABLE_SIZE;
+		memcpy(__va(el2_vector + KEXEC_EL2_SYNC_OFFSET), kexec_el1_sync,
+		       kexec_el1_sync_size);
+	}
+
 	kern_reloc_arg = kexec_page_alloc(kimage);
 	if (!kern_reloc_arg)
 		return -ENOMEM;
@@ -91,10 +201,19 @@ int machine_kexec_post_load(struct kimage *kimage)
 
 	kern_reloc_arg->head = kimage->head;
 	kern_reloc_arg->entry_addr = kimage->start;
+	kern_reloc_arg->el2_vector = el2_vector;
 	kern_reloc_arg->kern_arg0 = kimage->arch.dtb_mem;
 
+	/*
+	 * If relocation is not needed, we do not need to enable MMU in
+	 * relocation routine, therefore do not create page tables for
+	 * scenarios such as crash kernel
+	 */
+	if (!(kimage->head & IND_DONE))
+		rc = mmu_relocate_setup(kimage, kern_reloc, kern_reloc_arg);
+
 	kexec_image_info(kimage);
-	return 0;
+	return rc;
 }
 
 /**
diff --git a/arch/arm64/kernel/relocate_kernel.S b/arch/arm64/kernel/relocate_kernel.S
index d352faf7cbe6..14243a678277 100644
--- a/arch/arm64/kernel/relocate_kernel.S
+++ b/arch/arm64/kernel/relocate_kernel.S
@@ -83,17 +83,25 @@ ENTRY(arm64_relocate_new_kernel)
 	ldr	x1, [x0, #KRELOC_KERN_ARG1]
 	ldr	x0, [x0, #KRELOC_KERN_ARG0]	/* x0 = dtb address */
 	br	x4
+.ltorg
+.Larm64_relocate_new_kernel_end:
 END(arm64_relocate_new_kernel)
 
-.ltorg
+ENTRY(kexec_el1_sync)
+	br	x4				/* Jump to new world from el2 */
+.Lkexec_el1_sync_end:
+END(kexec_el1_sync)
+
 .align 3	/* To keep the 64-bit values below naturally aligned. */
-.Lcopy_end:
 .org	KEXEC_CONTROL_PAGE_SIZE
-
 /*
  * arm64_relocate_new_kernel_size - Number of bytes to copy to the
  * control_code_page.
  */
 .globl arm64_relocate_new_kernel_size
 arm64_relocate_new_kernel_size:
-	.quad	.Lcopy_end - arm64_relocate_new_kernel
+	.quad	.Larm64_relocate_new_kernel_end - arm64_relocate_new_kernel
+
+.globl kexec_el1_sync_size
+kexec_el1_sync_size:
+	.quad	.Lkexec_el1_sync_end - kexec_el1_sync
-- 
2.22.0

