Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DAEEC32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:25:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA4D22087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:25:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="bHx/KWL8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA4D22087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D1C38E002A; Thu,  1 Aug 2019 11:24:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E45D8E0001; Thu,  1 Aug 2019 11:24:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60CBE8E002A; Thu,  1 Aug 2019 11:24:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35C728E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 11:24:55 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g30so64839983qtm.17
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 08:24:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=PLoutsvDOEBcLXmSwpW/VZGz7Lju4ED/guZL5+5aMWk=;
        b=lYiplMJ9BViQ97T+xlZ4u5qzw0vfyL3dHGAY86yfHSmcedkSsxXEsDAisjmysX6dPV
         lyvdw9Oo1dnW83TZ5je286e85yUmbWjyEcsVYQUPd+L4NYGH75gR7EFwgGIWH5PNjfUG
         lCzy233icexwJq1RZi3gVLIbE79CbzIJ1Q8uMsnG2eB2fMt8EryNiiXV2aBFJt3bWTM/
         DlKgfm+r68+Wx89uBe7zmzJ0K/lEW4+hJejUPM+OM5F0nALO9a9UZh9xbohqeA7qN2W0
         7gisBpCEX4SUEYJQoAGtqC/C0sqwYAe9Ig8OSsj9bffCTuI+vKzVzDCjXM5l3BtZctsF
         PsZg==
X-Gm-Message-State: APjAAAWOAedjL3NICYQkgRAjLxzOQt7aAnKVC1kCyawZnnLl2QYXk0jE
	Ue6Nsfd97O0spdecZt0KHpMK+wN69HRqOctFSOuU3nRVwUH/A28xOH3D+O/xNOFGSAwaJmT8BGX
	B0H+rVEm8wFyAFzS78+M5rz39rsQh4cxEpRZnoBMVRv0htFLqsYYbrUNZHCRT1uiIAg==
X-Received: by 2002:a05:620a:16d6:: with SMTP id a22mr86688431qkn.414.1564673094970;
        Thu, 01 Aug 2019 08:24:54 -0700 (PDT)
X-Received: by 2002:a05:620a:16d6:: with SMTP id a22mr86688307qkn.414.1564673093540;
        Thu, 01 Aug 2019 08:24:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564673093; cv=none;
        d=google.com; s=arc-20160816;
        b=l+2pCfki3WNWq9m3ols8OvSVnrJmT+d6027ybbHxLK8MzAF8UfFQ+y8pfQwdDU5CUZ
         fxtn7PdpPVh6WhuQ/MwymlmA+yj5xGcb3B0iJMiXpMNcaNtaCTqQlyjPCrluAe7TWLQV
         qnvDs7NfSH/nvfNseDCxqO7Y6tzqsy85fYt1ksyf2g77aa6kjvz7v89s02oJneD8sY7A
         psVoww93tMzcYKMC00hPur+I6v5zcX7mPTNc/26KOnFZdGUzj5Rr4jkfQku+4YREAA6M
         xEr4UpBvRd1HbbIFVuLOtr45I9R+vF1krn81cD3Tu1bSJ3NX/5z6pof5S82eG+kMDeSP
         /TaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=PLoutsvDOEBcLXmSwpW/VZGz7Lju4ED/guZL5+5aMWk=;
        b=xzCx9BmJ8osgVNt9CKg7wqnAIeFrfAMSVQkWd1BsC02VoWisRGXhbV4ez1ox6wuixW
         PTD6MBHO/tOpW9FzOvUpnDiy3zbrabIsdM+yVy7fbvs+1Oem1ZEBRxv6rS/C+hnR5llX
         PZELIG0M63yHR47NWM772Ao9MuokcpFXWM+0/Z6inHXovSxdCAra/3lXtdxEAVjZgLev
         OZJLXHCM9fwuuUK7dcTKMyLhlmZn+cAOD1+vBznCZdIJGuQw4DGpwGO+DEm0kVpsob9N
         NvZ4+sWh7qm7jk74YKmgJEN/tF2J69Dk7XRTzmhgm7VzHRSL0UnnOMRyVs4w5HkCk5+d
         X1RA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="bHx/KWL8";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g83sor40745408qkb.186.2019.08.01.08.24.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 08:24:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="bHx/KWL8";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PLoutsvDOEBcLXmSwpW/VZGz7Lju4ED/guZL5+5aMWk=;
        b=bHx/KWL8+n4rgdjRFcbGjEtrRWcEKSloAzai7HvQSjszByk74kWOBmHipCwjx6XwSx
         rE1+0hsLKEv3APKc686glCqfBg8FTWl35tThgBNaJYj5lRvT0EpEypNN4wX5pA5Zm69h
         GysDuc809eiUSe0zzbCwjvOyFu9/DKIKcNO46hWUOLkYfvK2MsoRRbwsnTtWJA00JfSU
         ePPjgGWAIRHMcODn/c2VeDQDZB+1MO+JKGtbt8Wrg/Lxv5x0KqN2gbCvsfvz4p9LFy87
         vnWndJXICcvUZQwKyLtEWVqdsqhjOEzXwWqAjnn3G2GV+9AJI5EQF4b/K8wknWR/1xMo
         WjFQ==
X-Google-Smtp-Source: APXvYqyLP4m/prZZeaEuGTVGpHEWZftvDsvYZZGYTrMEi6rZbmxVJ00jQEh1G8oV3NUUEFulu1gceg==
X-Received: by 2002:a37:76c5:: with SMTP id r188mr85109323qkc.394.1564673093139;
        Thu, 01 Aug 2019 08:24:53 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o5sm30899952qkf.10.2019.08.01.08.24.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 08:24:52 -0700 (PDT)
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
Subject: [PATCH v1 8/8] arm64, kexec: enable MMU during kexec relocation
Date: Thu,  1 Aug 2019 11:24:39 -0400
Message-Id: <20190801152439.11363-9-pasha.tatashin@soleen.com>
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

Now, that we have transitional page tables configured, temporarily enable
MMU to allow faster relocation of segments to final destination.

The performance data: for a moderate size kernel + initramfs: 25M the
relocation was taking 0.382s, with enabled MMU it now takes
0.019s only or x20 improvement.

The time is proportional to the size of relocation, therefore if initramfs
is larger, 100M it could take over a second.

Also, remove reloc_arg->head, as it is not needed anymore once MMU is
enabled.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/kexec.h      |   2 -
 arch/arm64/kernel/asm-offsets.c     |   1 -
 arch/arm64/kernel/machine_kexec.c   |   1 -
 arch/arm64/kernel/relocate_kernel.S | 136 +++++++++++++++++-----------
 4 files changed, 84 insertions(+), 56 deletions(-)

diff --git a/arch/arm64/include/asm/kexec.h b/arch/arm64/include/asm/kexec.h
index 450d8440f597..ad81ed3e5751 100644
--- a/arch/arm64/include/asm/kexec.h
+++ b/arch/arm64/include/asm/kexec.h
@@ -109,7 +109,6 @@ extern const unsigned long kexec_el1_sync_size;
 			((UL(0xffffffffffffffff) - PAGE_OFFSET) >> 1) + 1)
 /*
  * kern_reloc_arg is passed to kernel relocation function as an argument.
- * head		kimage->head, allows to traverse through relocation segments.
  * entry_addr	kimage->start, where to jump from relocation function (new
  *		kernel, or purgatory entry address).
  * kern_arg0	first argument to kernel is its dtb address. The other
@@ -125,7 +124,6 @@ extern const unsigned long kexec_el1_sync_size;
  * copy_len	Number of bytes that need to be copied
  */
 struct kern_reloc_arg {
-	unsigned long	head;
 	unsigned long	entry_addr;
 	unsigned long	kern_arg0;
 	unsigned long	kern_arg1;
diff --git a/arch/arm64/kernel/asm-offsets.c b/arch/arm64/kernel/asm-offsets.c
index 7c2ba09a8ceb..13ad00b1b90f 100644
--- a/arch/arm64/kernel/asm-offsets.c
+++ b/arch/arm64/kernel/asm-offsets.c
@@ -129,7 +129,6 @@ int main(void)
   DEFINE(SDEI_EVENT_PRIORITY,	offsetof(struct sdei_registered_event, priority));
 #endif
 #ifdef CONFIG_KEXEC_CORE
-  DEFINE(KRELOC_HEAD,		offsetof(struct kern_reloc_arg, head));
   DEFINE(KRELOC_ENTRY_ADDR,	offsetof(struct kern_reloc_arg, entry_addr));
   DEFINE(KRELOC_KERN_ARG0,	offsetof(struct kern_reloc_arg, kern_arg0));
   DEFINE(KRELOC_KERN_ARG1,	offsetof(struct kern_reloc_arg, kern_arg1));
diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machine_kexec.c
index 16f761fc50c8..b5ff5fdb4777 100644
--- a/arch/arm64/kernel/machine_kexec.c
+++ b/arch/arm64/kernel/machine_kexec.c
@@ -199,7 +199,6 @@ int machine_kexec_post_load(struct kimage *kimage)
 	kimage->arch.kern_reloc = kern_reloc;
 	kimage->arch.kern_reloc_arg = __pa(kern_reloc_arg);
 
-	kern_reloc_arg->head = kimage->head;
 	kern_reloc_arg->entry_addr = kimage->start;
 	kern_reloc_arg->el2_vector = el2_vector;
 	kern_reloc_arg->kern_arg0 = kimage->arch.dtb_mem;
diff --git a/arch/arm64/kernel/relocate_kernel.S b/arch/arm64/kernel/relocate_kernel.S
index 14243a678277..96ff6760bd9c 100644
--- a/arch/arm64/kernel/relocate_kernel.S
+++ b/arch/arm64/kernel/relocate_kernel.S
@@ -4,6 +4,8 @@
  *
  * Copyright (C) Linaro.
  * Copyright (C) Huawei Futurewei Technologies.
+ * Copyright (c) 2019, Microsoft Corporation.
+ * Pavel Tatashin <patatash@linux.microsoft.com>
  */
 
 #include <linux/kexec.h>
@@ -14,6 +16,49 @@
 #include <asm/page.h>
 #include <asm/sysreg.h>
 
+/* Invalidae TLB */
+.macro tlb_invalidate
+	dsb	sy
+	dsb	ish
+	tlbi	vmalle1
+	dsb	ish
+	isb
+.endm
+
+/* Turn-off mmu at level specified by sctlr */
+.macro turn_off_mmu sctlr, tmp1, tmp2
+	mrs	\tmp1, \sctlr
+	ldr	\tmp2, =SCTLR_ELx_FLAGS
+	bic	\tmp1, \tmp1, \tmp2
+	pre_disable_mmu_workaround
+	msr	\sctlr, \tmp1
+	isb
+.endm
+
+/* Turn-on mmu at level specified by sctlr */
+.macro turn_on_mmu sctlr, tmp1, tmp2
+	mrs	\tmp1, \sctlr
+	ldr	\tmp2, =SCTLR_ELx_FLAGS
+	orr	\tmp1, \tmp1, \tmp2
+	msr	\sctlr, \tmp1
+	ic	iallu
+	dsb	nsh
+	isb
+.endm
+
+/*
+ * Set ttbr0 and ttbr1, called while MMU is disabled, so no need to temporarily
+ * set zero_page table. Invalidate TLB after new tables are set.
+ */
+.macro set_ttbr arg, tmp
+	ldr	\tmp, [\arg, #KRELOC_TRANS_TTBR0]
+	msr	ttbr0_el1, \tmp
+	ldr	\tmp, [\arg, #KRELOC_TRANS_TTBR1]
+	offset_ttbr1 \tmp
+	msr	ttbr1_el1, \tmp
+	isb
+.endm
+
 /*
  * arm64_relocate_new_kernel - Put a 2nd stage image in place and boot it.
  *
@@ -24,65 +69,52 @@
  * symbols arm64_relocate_new_kernel and arm64_relocate_new_kernel_end.  The
  * machine_kexec() routine will copy arm64_relocate_new_kernel to the kexec
  * safe memory that has been set up to be preserved during the copy operation.
+ *
+ * This function temporarily enables MMU if kernel relocation is needed.
+ * Also, if we enter this function at EL2 on non-VHE kernel, we temporarily go
+ * to EL1 to enable MMU, and escalate back to EL2 at the end to do the jump to
+ * the new kernel. This is determined by presence of el2_vector.
  */
 ENTRY(arm64_relocate_new_kernel)
-	/* Clear the sctlr_el2 flags. */
-	mrs	x2, CurrentEL
-	cmp	x2, #CurrentEL_EL2
+	mrs	x1, CurrentEL
+	cmp	x1, #CurrentEL_EL2
 	b.ne	1f
-	mrs	x2, sctlr_el2
-	ldr	x1, =SCTLR_ELx_FLAGS
-	bic	x2, x2, x1
-	pre_disable_mmu_workaround
-	msr	sctlr_el2, x2
-	isb
-1:	/* Check if the new image needs relocation. */
-	ldr	x16, [x0, #KRELOC_HEAD]		/* x16 = kimage_head */
-	tbnz	x16, IND_DONE_BIT, .Ldone
-	raw_dcache_line_size x15, x1		/* x15 = dcache line size */
-.Lloop:
-	and	x12, x16, PAGE_MASK		/* x12 = addr */
-	/* Test the entry flags. */
-.Ltest_source:
-	tbz	x16, IND_SOURCE_BIT, .Ltest_indirection
-
-	/* Invalidate dest page to PoC. */
-	mov     x2, x13
-	add     x20, x2, #PAGE_SIZE
-	sub     x1, x15, #1
-	bic     x2, x2, x1
-2:	dc      ivac, x2
-	add     x2, x2, x15
-	cmp     x2, x20
-	b.lo    2b
-	dsb     sy
-
-	copy_page x13, x12, x1, x2, x3, x4, x5, x6, x7, x8
-	b	.Lnext
-.Ltest_indirection:
-	tbz	x16, IND_INDIRECTION_BIT, .Ltest_destination
-	mov	x14, x12			/* ptr = addr */
-	b	.Lnext
-.Ltest_destination:
-	tbz	x16, IND_DESTINATION_BIT, .Lnext
-	mov	x13, x12			/* dest = addr */
-.Lnext:
-	ldr	x16, [x14], #8			/* entry = *ptr++ */
-	tbz	x16, IND_DONE_BIT, .Lloop	/* while (!(entry & DONE)) */
-.Ldone:
-	/* wait for writes from copy_page to finish */
-	dsb	nsh
-	ic	iallu
-	dsb	nsh
-	isb
-
-	/* Start new image. */
-	ldr	x4, [x0, #KRELOC_ENTRY_ADDR]	/* x4 = kimage_start */
+	turn_off_mmu sctlr_el2, x1, x2		/* Turn off MMU at EL2 */
+1:	mov	x20, xzr			/* x20 will hold vector value */
+	ldr	x11, [x0, #KRELOC_COPY_LEN]
+	cbz	x11, 5f				/* Check if need to relocate */
+	ldr	x20, [x0, #KRELOC_EL2_VECTOR]
+	cbz	x20, 2f				/* need to reduce to EL1? */
+	msr	vbar_el2, x20			/* el2_vector present, means */
+	adr	x1, 2f				/* we will do copy in el1 but */
+	msr	elr_el2, x1			/* do final jump from el2 */
+	eret					/* Reduce to EL1 */
+2:	set_ttbr x0, x1				/* Set our page tables */
+	tlb_invalidate
+	turn_on_mmu sctlr_el1, x1, x2		/* Turn MMU back on */
+	ldr	x1, [x0, #KRELOC_DST_ADDR];
+	ldr	x2, [x0, #KRELOC_SRC_ADDR];
+	mov	x12, x1				/* x12 dst backup */
+3:	copy_page x1, x2, x3, x4, x5, x6, x7, x8, x9, x10
+	sub	x11, x11, #PAGE_SIZE
+	cbnz	x11, 3b				/* page copy loop */
+	raw_dcache_line_size x2, x3		/* x2 = dcache line size */
+	sub	x3, x2, #1			/* x3 = dcache_size - 1 */
+	bic	x12, x12, x3
+4:	dc	cvau, x12			/* Flush D-cache */
+	add	x12, x12, x2
+	cmp	x12, x1				/* Compare to dst + len */
+	b.ne	4b				/* D-cache flush loop */
+	turn_off_mmu sctlr_el1, x1, x2		/* Turn off MMU */
+	tlb_invalidate				/* Invalidate TLB */
+5:	ldr	x4, [x0, #KRELOC_ENTRY_ADDR]	/* x4 = kimage_start */
 	ldr	x3, [x0, #KRELOC_KERN_ARG3]
 	ldr	x2, [x0, #KRELOC_KERN_ARG2]
 	ldr	x1, [x0, #KRELOC_KERN_ARG1]
 	ldr	x0, [x0, #KRELOC_KERN_ARG0]	/* x0 = dtb address */
-	br	x4
+	cbnz	x20, 6f				/* need to escalate to el2? */
+	br	x4				/* Jump to new world */
+6:	hvc	#0				/* enters kexec_el1_sync */
 .ltorg
 .Larm64_relocate_new_kernel_end:
 END(arm64_relocate_new_kernel)
-- 
2.22.0

