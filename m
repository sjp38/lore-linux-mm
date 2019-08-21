Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4F84C3A5A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7ADBF233FE
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="J2AQvhOU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ADBF233FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5C5B6B027C; Wed, 21 Aug 2019 14:32:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D96CD6B027E; Wed, 21 Aug 2019 14:32:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE9046B027F; Wed, 21 Aug 2019 14:32:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0079.hostedemail.com [216.40.44.79])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB596B027C
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:30 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4B1CCA2BD
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:30 +0000 (UTC)
X-FDA: 75847280460.18.cream63_32e6ae4328258
X-HE-Tag: cream63_32e6ae4328258
X-Filterd-Recvd-Size: 13206
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:29 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id y26so4271079qto.4
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uo7dFAJp+Jf6uJqlJ5MZe8NrB2vsaqpNGEJ2YJN9fuk=;
        b=J2AQvhOUZmG0B6JA2nXMnDAk/TVHeww6x57kCXvIXGabhntUC7Eqt/uG8abLhp36XG
         u11frHMoQAizwveAL9x1k+TDd0R/WI5/9TRhuIQuWchnVKPU5BavnotX/FZO0sfMLY1P
         lCmeQLaaMmVquUIbcUgvLkq0hImxQbM/WuA1HGuQRdjP7u1rlNatXDsfLDvd7ybnl6Da
         ChWQg/f8bcRQQz2tlSS3oTejS/4Yv1AayUqoU6JBGIYLv4LJtNLnoFOAgbvDFrrC2iLJ
         ikQHA4OqmiHFMkRteDHIy8+zzUxEyF9RMegyzzMeu/KQkgfco1Jt5S39AGbmyYyOqQsl
         U4Jw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=uo7dFAJp+Jf6uJqlJ5MZe8NrB2vsaqpNGEJ2YJN9fuk=;
        b=O6eP5/hgqIut6DLNXzTIuBkoFbvDGe+villPfq1jC0eOaictbJQUinCuOPeieF6mY6
         vuV33vZpFqlNFUlihBeKczVkiDmvJqTacp0tL6IX9/+1haww6LwMkcrs/vjSFEx6OptE
         iEEdLpsNaQl7ZovsPpKEn0XBRh1boDqqJw0ckuoqpRSVECOOdq/8YukYwiONuNLQ+qiA
         aDcC7tC1sThTkYF10IPVLZRz41HLB/P0K+IvQl4cmWW+DNDyOcmHXP+DzGIfjzOBo8se
         eO33vkhAJtevfZgpL/0FnUjRzrpWYx7iVb/0rHxiGcLfz7uEEMBTAmznAxlEy7PUTMN2
         /bXA==
X-Gm-Message-State: APjAAAW+LTT0ck4a+jTxh4FOpU1kKK+IdNYdlForRbSeJ5Do9qfWXeIa
	VMqi3GgLPQqn7sNsCwpkWfQGcA==
X-Google-Smtp-Source: APXvYqxDNLdRqf7UpAdgZaBjOuA5fECPVOYKg36Q5doL0aQySnhF25uzzv3FqJdFLzxx2Nu5SRmm2w==
X-Received: by 2002:aed:2f03:: with SMTP id l3mr33422412qtd.264.1566412349039;
        Wed, 21 Aug 2019 11:32:29 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:28 -0700 (PDT)
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
	linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: [PATCH v3 16/17] arm64, kexec: configure trans_pgd page table for kexec
Date: Wed, 21 Aug 2019 14:32:03 -0400
Message-Id: <20190821183204.23576-17-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190821183204.23576-1-pasha.tatashin@soleen.com>
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Configure a page table located in kexec-safe memory that has
the following mappings:

1. identity mapping for text of relocation function with executable
   permission.
2. identity mapping for argument for relocation function.
3. linear mappings for all source ranges
4. linear mappings for all destination ranges.

Also, configure el2_vector, that is used to jump to new kernel from EL2 o=
n
non-VHE kernels.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/kexec.h      |  32 +++++++
 arch/arm64/kernel/asm-offsets.c     |   6 ++
 arch/arm64/kernel/machine_kexec.c   | 129 ++++++++++++++++++++++++++--
 arch/arm64/kernel/relocate_kernel.S |  16 +++-
 4 files changed, 174 insertions(+), 9 deletions(-)

diff --git a/arch/arm64/include/asm/kexec.h b/arch/arm64/include/asm/kexe=
c.h
index d5b79d4c7fae..450d8440f597 100644
--- a/arch/arm64/include/asm/kexec.h
+++ b/arch/arm64/include/asm/kexec.h
@@ -90,6 +90,23 @@ static inline void crash_prepare_suspend(void) {}
 static inline void crash_post_resume(void) {}
 #endif
=20
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
  * kern_reloc_arg is passed to kernel relocation function as an argument=
.
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
=20
 #define ARCH_HAS_KIMAGE_ARCH
diff --git a/arch/arm64/kernel/asm-offsets.c b/arch/arm64/kernel/asm-offs=
ets.c
index 900394907fd8..7c2ba09a8ceb 100644
--- a/arch/arm64/kernel/asm-offsets.c
+++ b/arch/arm64/kernel/asm-offsets.c
@@ -135,6 +135,12 @@ int main(void)
   DEFINE(KRELOC_KERN_ARG1,	offsetof(struct kern_reloc_arg, kern_arg1));
   DEFINE(KRELOC_KERN_ARG2,	offsetof(struct kern_reloc_arg, kern_arg2));
   DEFINE(KRELOC_KERN_ARG3,	offsetof(struct kern_reloc_arg, kern_arg3));
+  DEFINE(KRELOC_TRANS_TTBR0,	offsetof(struct kern_reloc_arg, trans_ttbr0=
));
+  DEFINE(KRELOC_TRANS_TTBR1,	offsetof(struct kern_reloc_arg, trans_ttbr1=
));
+  DEFINE(KRELOC_EL2_VECTOR,	offsetof(struct kern_reloc_arg, el2_vector))=
;
+  DEFINE(KRELOC_SRC_ADDR,	offsetof(struct kern_reloc_arg, src_addr));
+  DEFINE(KRELOC_DST_ADDR,	offsetof(struct kern_reloc_arg, dst_addr));
+  DEFINE(KRELOC_COPY_LEN,	offsetof(struct kern_reloc_arg, copy_len));
 #endif
   return 0;
 }
diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machin=
e_kexec.c
index d745ea2051df..235cf2a5f007 100644
--- a/arch/arm64/kernel/machine_kexec.c
+++ b/arch/arm64/kernel/machine_kexec.c
@@ -20,13 +20,10 @@
 #include <asm/mmu.h>
 #include <asm/mmu_context.h>
 #include <asm/page.h>
+#include <asm/trans_pgd.h>
=20
 #include "cpu-reset.h"
=20
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
=20
+/*
+ * Map source segments starting from KEXEC_SRC_START, and map destinatio=
n
+ * segments starting from KEXEC_DST_START, and return size of copy in
+ * *copy_len argument.
+ * Relocation function essentially needs to do:
+ * memcpy(KEXEC_DST_START, KEXEC_SRC_START, copy_len);
+ */
+static int map_segments(struct kimage *kimage, pgd_t *pgdp,
+			struct trans_pgd_info *info,
+			unsigned long *copy_len)
+{
+	unsigned long *ptr =3D 0;
+	unsigned long dest =3D 0;
+	unsigned long src_va =3D KEXEC_SRC_START;
+	unsigned long dst_va =3D KEXEC_DST_START;
+	unsigned long len =3D 0;
+	unsigned long entry, addr;
+	int rc;
+
+	for (entry =3D kimage->head; !(entry & IND_DONE); entry =3D *ptr++) {
+		addr =3D entry & PAGE_MASK;
+
+		switch (entry & IND_FLAGS) {
+		case IND_DESTINATION:
+			dest =3D addr;
+			break;
+		case IND_INDIRECTION:
+			ptr =3D __va(addr);
+			if (rc)
+				return rc;
+			break;
+		case IND_SOURCE:
+			rc =3D trans_pgd_map_page(info, pgdp, __va(addr),
+						src_va, PAGE_KERNEL);
+			if (rc)
+				return rc;
+			rc =3D trans_pgd_map_page(info, pgdp, __va(dest),
+						dst_va, PAGE_KERNEL);
+			if (rc)
+				return rc;
+			dest +=3D PAGE_SIZE;
+			src_va +=3D PAGE_SIZE;
+			dst_va +=3D PAGE_SIZE;
+			len +=3D PAGE_SIZE;
+		}
+	}
+	*copy_len =3D len;
+
+	return 0;
+}
+
+static int mmu_relocate_setup(struct kimage *kimage, unsigned long kern_=
reloc,
+			      struct kern_reloc_arg *kern_reloc_arg)
+{
+	struct trans_pgd_info info =3D {
+		.trans_alloc_page	=3D kexec_page_alloc,
+		.trans_alloc_arg	=3D kimage,
+		.trans_flags		=3D 0,
+	};
+	pgd_t *trans_ttbr0, *trans_ttbr1;
+	int rc;
+
+	rc =3D trans_pgd_create_empty(&info, &trans_ttbr0);
+	if (rc)
+		return rc;
+
+	rc =3D trans_pgd_create_empty(&info, &trans_ttbr1);
+	if (rc)
+		return rc;
+
+	rc =3D map_segments(kimage, trans_ttbr1, &info,
+			  &kern_reloc_arg->copy_len);
+	if (rc)
+		return rc;
+
+	/* Map relocation function va =3D=3D pa */
+	rc =3D trans_pgd_map_page(&info, trans_ttbr0,  __va(kern_reloc),
+				kern_reloc, PAGE_KERNEL_EXEC);
+	if (rc)
+		return rc;
+
+	/* Map relocation function argument va =3D=3D pa */
+	rc =3D trans_pgd_map_page(&info, trans_ttbr0, kern_reloc_arg,
+				__pa(kern_reloc_arg), PAGE_KERNEL);
+	if (rc)
+		return rc;
+
+	kern_reloc_arg->trans_ttbr0 =3D phys_to_ttbr(__pa(trans_ttbr0));
+	kern_reloc_arg->trans_ttbr1 =3D phys_to_ttbr(__pa(trans_ttbr1));
+	kern_reloc_arg->src_addr =3D KEXEC_SRC_START;
+	kern_reloc_arg->dst_addr =3D KEXEC_DST_START;
+
+	return 0;
+}
+
 int machine_kexec_post_load(struct kimage *kimage)
 {
+	unsigned long el2_vector =3D 0;
 	unsigned long kern_reloc;
 	struct kern_reloc_arg *kern_reloc_arg;
+	int rc =3D 0;
+
+	/*
+	 * Sanity check that relocation function + el2_vector fit into one
+	 * page.
+	 */
+	if (arm64_relocate_new_kernel_size > KEXEC_EL2_VECTOR_TABLE_SIZE) {
+		pr_err("can't fit relocation function and el2_vector in one page");
+		return -ENOMEM;
+	}
=20
 	kern_reloc =3D page_to_phys(kimage->control_code_page);
 	memcpy(__va(kern_reloc), arm64_relocate_new_kernel,
 	       arm64_relocate_new_kernel_size);
=20
+	/* Setup vector table only when EL2 is available, but no VHE */
+	if (is_hyp_mode_available() && !is_kernel_in_hyp_mode()) {
+		el2_vector =3D kern_reloc + KEXEC_EL2_VECTOR_TABLE_SIZE;
+		memcpy(__va(el2_vector + KEXEC_EL2_SYNC_OFFSET), kexec_el1_sync,
+		       kexec_el1_sync_size);
+	}
+
 	kern_reloc_arg =3D kexec_page_alloc(kimage);
 	if (!kern_reloc_arg)
 		return -ENOMEM;
@@ -91,10 +201,19 @@ int machine_kexec_post_load(struct kimage *kimage)
=20
 	kern_reloc_arg->head =3D kimage->head;
 	kern_reloc_arg->entry_addr =3D kimage->start;
+	kern_reloc_arg->el2_vector =3D el2_vector;
 	kern_reloc_arg->kern_arg0 =3D kimage->arch.dtb_mem;
=20
+	/*
+	 * If relocation is not needed, we do not need to enable MMU in
+	 * relocation routine, therefore do not create page tables for
+	 * scenarios such as crash kernel
+	 */
+	if (!(kimage->head & IND_DONE))
+		rc =3D mmu_relocate_setup(kimage, kern_reloc, kern_reloc_arg);
+
 	kexec_image_info(kimage);
-	return 0;
+	return rc;
 }
=20
 /**
diff --git a/arch/arm64/kernel/relocate_kernel.S b/arch/arm64/kernel/relo=
cate_kernel.S
index d352faf7cbe6..14243a678277 100644
--- a/arch/arm64/kernel/relocate_kernel.S
+++ b/arch/arm64/kernel/relocate_kernel.S
@@ -83,17 +83,25 @@ ENTRY(arm64_relocate_new_kernel)
 	ldr	x1, [x0, #KRELOC_KERN_ARG1]
 	ldr	x0, [x0, #KRELOC_KERN_ARG0]	/* x0 =3D dtb address */
 	br	x4
+.ltorg
+.Larm64_relocate_new_kernel_end:
 END(arm64_relocate_new_kernel)
=20
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
--=20
2.23.0


