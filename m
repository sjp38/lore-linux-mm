Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10D44C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:33:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C144620872
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:33:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C144620872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EBFC6B0008; Wed, 17 Apr 2019 01:33:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A2E46B0266; Wed, 17 Apr 2019 01:33:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4653F6B0269; Wed, 17 Apr 2019 01:33:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E518F6B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:33:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f42so6888463edd.0
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:33:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ofjbywuwMy7Hm0IDjqbFaAHELAPZEgqhyfFsdeTc4hk=;
        b=kq29CcfYePuCa/ZQKzSO/rZrimOauFhsJd6QgAvWEKw6CY+sJPelJ5pAQSSDnfnX7q
         9tAwbRPqYPuM6gnMbtIp1GlWSCUnVnAjhPrl6sUS52cEMIIktHJnJ47sn75LKB353IYV
         vQ2+Y1O3w7AFnWv1cWIh/tHH9dso4p92NLl2kFbqnDUjco07yuOqHwpLx3fNIjObY2Yl
         IUkKjHA8ais/K6XlS03kuZhbZNah1O0O4kjBi19L4DoKyWbBC1wPJ089RfnseYapfq0s
         bfiQULyNp/iuk+nhEHsUZnh4og6iAkeZSEsNdrXG5tQbBtPlsoHlGUjXvWBnlItvfzVo
         fIMA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXfWROXX5V/iXlEsOVtGqDcz3urciQcBRz1re3AnrFr5XslR7kd
	v3uXSM/ZmM0dsBuYFiHOJWyMV4yTcMGRUBkvxEjg54Hh+RWp6zgcqgyN1xNfcW0vCJxNKMztdJv
	YSd3KsAkPNCGEv9R/vXaOLdpGs8YZ2eOZVA6zPFxDRTXt31koeqelzZaK8Mzxn1I=
X-Received: by 2002:a17:906:6c0d:: with SMTP id j13mr46618982ejr.249.1555479230427;
        Tue, 16 Apr 2019 22:33:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/Nw7WZ8RwmACzwCPnI7PUpXOnBnTkVgyNy5WzbQ30DWDjlVxQ47WDvYyc9FJ02OV0sP8P
X-Received: by 2002:a17:906:6c0d:: with SMTP id j13mr46618938ejr.249.1555479229388;
        Tue, 16 Apr 2019 22:33:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555479229; cv=none;
        d=google.com; s=arc-20160816;
        b=RR5psYDKmRNYYYU1caRJsEzZb5bZ7eEYSARh3sjeXN6IhwGISWDTdrM/79bPxJOjv7
         Qa8Bf+7A4A3oWIpBJHkOa05qvrKlzr5m2jduKIUJSlFfSZM/b1d2AWEW/tRTrsQOK/Uw
         vUAg0sKMtPjrY7b+0NhqKonS2x5LZzWHTQ012BLgDz3z+fuIx4cLaN8SFdZ8eFpeqyCr
         fOfN6oSWW8A+sSwuW0v1/CQxjtLs+KpXIEM4sPZ/71iFyADWBWf2tHXZXXFDwAhirY8t
         h+b2/e9oP+vHT9bAT+j6RXwNMZ1s9AclvLUh5GDt/7G2JjG2o7bmaVYAgUB9kFtQ49rL
         dOxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ofjbywuwMy7Hm0IDjqbFaAHELAPZEgqhyfFsdeTc4hk=;
        b=04XkzONSp5eKOcuJmfUIx8nyV9SwE74A62X4FmsEGvnbi8e028Uo3WsJ53+HgzkUPl
         KbIv6Y+i4fscrbM2wgPvVN/MAJUUtOrvTx8qRDjXj5WWCRZWZuIcpRIXYV1HNjGxTzEw
         FskHC5+MgfMUvLdvFZOnxIQRxUh+CA/BMGrhmDT3u5qbvdMJKq7jEHMulESw8GpZG/dW
         yoL6V23QPQR1yyKQE2zlT6lRhV8zrBaU3r3GOm2pygzzX9fMLlN3OrBEgdfYNWiR5/W2
         IC+5tn/CQAjzcpyWFiDTggH7I1wvPn4I5eNW1rjcwgWfPkKNHvYGhBzOiGrm/GwESele
         MpnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id q23si2369413eda.221.2019.04.16.22.33.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 22:33:49 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 7D8861C0002;
	Wed, 17 Apr 2019 05:33:42 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v3 10/11] mips: Use generic mmap top-down layout
Date: Wed, 17 Apr 2019 01:22:46 -0400
Message-Id: <20190417052247.17809-11-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417052247.17809-1-alex@ghiti.fr>
References: <20190417052247.17809-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mips uses a top-down layout by default that fits the generic functions.
At the same time, this commit allows to fix problem uncovered
and not fixed for mips here:
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/mips/Kconfig                 |  1 +
 arch/mips/include/asm/processor.h |  5 ---
 arch/mips/mm/mmap.c               | 67 -------------------------------
 3 files changed, 1 insertion(+), 72 deletions(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 4a5f5b0ee9a9..ec2f07561e4d 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -14,6 +14,7 @@ config MIPS
 	select ARCH_USE_CMPXCHG_LOCKREF if 64BIT
 	select ARCH_USE_QUEUED_RWLOCKS
 	select ARCH_USE_QUEUED_SPINLOCKS
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select BUILDTIME_EXTABLE_SORT
 	select CLONE_BACKWARDS
diff --git a/arch/mips/include/asm/processor.h b/arch/mips/include/asm/processor.h
index aca909bd7841..fba18d4a9190 100644
--- a/arch/mips/include/asm/processor.h
+++ b/arch/mips/include/asm/processor.h
@@ -29,11 +29,6 @@
 
 extern unsigned int vced_count, vcei_count;
 
-/*
- * MIPS does have an arch_pick_mmap_layout()
- */
-#define HAVE_ARCH_PICK_MMAP_LAYOUT 1
-
 #ifdef CONFIG_32BIT
 #ifdef CONFIG_KVM_GUEST
 /* User space process size is limited to 1GB in KVM Guest Mode */
diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index ffbe69f3a7d9..61e65a69bb09 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -20,43 +20,6 @@
 unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
 
-/* gap between mmap and stack */
-#define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((STACK_TOP)/6*5)
-#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
-
-static int mmap_is_legacy(struct rlimit *rlim_stack)
-{
-	if (current->personality & ADDR_COMPAT_LAYOUT)
-		return 1;
-
-	if (rlim_stack->rlim_cur == RLIM_INFINITY)
-		return 1;
-
-	return sysctl_legacy_va_layout;
-}
-
-static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
-{
-	unsigned long gap = rlim_stack->rlim_cur;
-	unsigned long pad = stack_guard_gap;
-
-	/* Account for stack randomization if necessary */
-	if (current->flags & PF_RANDOMIZE)
-		pad += (STACK_RND_MASK << PAGE_SHIFT);
-
-	/* Values close to RLIM_INFINITY can overflow. */
-	if (gap + pad > gap)
-		gap += pad;
-
-	if (gap < MIN_GAP)
-		gap = MIN_GAP;
-	else if (gap > MAX_GAP)
-		gap = MAX_GAP;
-
-	return PAGE_ALIGN(STACK_TOP - gap - rnd);
-}
-
 #define COLOUR_ALIGN(addr, pgoff)				\
 	((((addr) + shm_align_mask) & ~shm_align_mask) +	\
 	 (((pgoff) << PAGE_SHIFT) & shm_align_mask))
@@ -154,36 +117,6 @@ unsigned long arch_get_unmapped_area_topdown(struct file *filp,
 			addr0, len, pgoff, flags, DOWN);
 }
 
-unsigned long arch_mmap_rnd(void)
-{
-	unsigned long rnd;
-
-#ifdef CONFIG_COMPAT
-	if (TASK_IS_32BIT_ADDR)
-		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
-	else
-#endif /* CONFIG_COMPAT */
-		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
-
-	return rnd << PAGE_SHIFT;
-}
-
-void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
-{
-	unsigned long random_factor = 0UL;
-
-	if (current->flags & PF_RANDOMIZE)
-		random_factor = arch_mmap_rnd();
-
-	if (mmap_is_legacy(rlim_stack)) {
-		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
-		mm->get_unmapped_area = arch_get_unmapped_area;
-	} else {
-		mm->mmap_base = mmap_base(random_factor, rlim_stack);
-		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-	}
-}
-
 static inline unsigned long brk_rnd(void)
 {
 	unsigned long rnd = get_random_long();
-- 
2.20.1

