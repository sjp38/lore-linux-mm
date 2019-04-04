Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AE38C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:56:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0408A20855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:56:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0408A20855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACBAB6B026C; Thu,  4 Apr 2019 01:56:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A52AB6B026D; Thu,  4 Apr 2019 01:56:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91BF36B026E; Thu,  4 Apr 2019 01:56:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 443916B026C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 01:56:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y17so768145edd.20
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 22:56:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=awYD9EzQwsHM4vOBJueyQeu5vHH60jnxNDLkfj3BPUs=;
        b=oOiOWWDU1ziJyWBoSzGejdkpQDv+fwnCkmKxxVmlBIl2z5pmoFiLjKTiRQeoT8YzNx
         +Wo+3vB3lAqNa2AaRHOSziyGhX32HY04n8kvx3q47csrZUIlRJAHvV/zadn98BT+g68B
         dCw1Vs8MFDj8ggc2otjF2fbiKWbOyr1vS5YgfLOgkfmhDWuBbVfq/RJI9xgIrrTMQ8OQ
         4lcSV8WSLxg2CGoPe9JMfidCJRv5L6qNx75B+pvYtSvS6wfbbHwZJPMmaNqfITlwosU8
         cZiauQ7p/P2TwuiYxAgnfcTustIm8ZftacU1YnxO4S5nCquj8Sxffp6N5FxXUgWnHEp0
         R6XQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVWjgVSs8njGXCNWXv0Zz49KcbqWzAn6HYUE3XFYG9uJgBcJ+HS
	0j2hCF14iVuOKxbyCDHo/DBmgOrmNWWjmhxp30/NHnvDN3NrOarsr/NT8WMOYjSWBPw9CY4wYAQ
	o0McRH6+D7bcYKFx3i2FrObujhPHAZv+F+tQErg8AE7t8+izTVE3yOrlp9sjS510=
X-Received: by 2002:aa7:dd0e:: with SMTP id i14mr2460480edv.172.1554357360791;
        Wed, 03 Apr 2019 22:56:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnRwUhiE5RCeAlW8Aa8aSbEthniUmw9URdjI/Qa+iquAOzfhDZsSMJE+bx9zDU2LdTB0Ek
X-Received: by 2002:aa7:dd0e:: with SMTP id i14mr2460437edv.172.1554357359896;
        Wed, 03 Apr 2019 22:55:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554357359; cv=none;
        d=google.com; s=arc-20160816;
        b=K007QDXlbL4+vD+TgnJARffNwTRrJOQVR1RUk/8h/KTw580avlISQUI8sq9XnjBOG9
         IZEu10V1BUyyyUOdm8upylbGIjph4H7lWosra1inoG5aghA2uwPnDYL1vYYCFSGijBsw
         OT+BlZaHQjvHWDOhXDl4VQHky3ZoEL6uy+meHaF5GJR0CrvOiEHOYqFOMXvUoQPLHHac
         oGjKR95VHKyWFaHrGudPTjJVyFf+ARCLoceAxyEPAjTQtoB6f18IySEfo0WkpOIYyBWL
         tqVF6Jtl0e5r3MXooZkSHOcZwzFMhr5MP7i5tnDThKAwDrcSAomF1Tg21D6k5uNkJgcO
         N+GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=awYD9EzQwsHM4vOBJueyQeu5vHH60jnxNDLkfj3BPUs=;
        b=HUG3uXZWb3wQ7Q3AK2VU1Uxb3kkIK22rXYqL10VHC04rWbqjJgTFz5mp4/cZDwg2iS
         IU5irvslMx0sSqxoJZ4qJnwGwnuCZxohidSq2hvr3hg1vvhuhiOB2IM5CxOiAqD4WALe
         TH/tgshKWhKnujqUEAeQNrWQ5FdrIHFZ9qEu6x7cKg3Lx39yiiFRe6QxLQStnjTwo2po
         imzyev//X2jmFxw/XeUqaX3D/G/nLHnhve1xTpaBazuxHivJ1Y8StMX7iOwTg+TRtIIK
         gMa2DZZAbZMrqu0dsb972VwV8qNIq/Y6THuXd9CtdQG0hv38oys/w0tMRauStGF1XQpM
         EqgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id q1si2299281ejs.275.2019.04.03.22.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 22:55:59 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id BB81F60007;
	Thu,  4 Apr 2019 05:55:55 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
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
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v2 4/5] mips: Use generic mmap top-down layout
Date: Thu,  4 Apr 2019 01:51:27 -0400
Message-Id: <20190404055128.24330-5-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404055128.24330-1-alex@ghiti.fr>
References: <20190404055128.24330-1-alex@ghiti.fr>
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
 arch/mips/mm/mmap.c               | 57 -------------------------------
 3 files changed, 1 insertion(+), 62 deletions(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 4a5f5b0ee9a9..c21aa6371eab 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -14,6 +14,7 @@ config MIPS
 	select ARCH_USE_CMPXCHG_LOCKREF if 64BIT
 	select ARCH_USE_QUEUED_RWLOCKS
 	select ARCH_USE_QUEUED_SPINLOCKS
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
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
index 2f616ebeb7e0..61e65a69bb09 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -20,33 +20,6 @@
 unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
 
-/* gap between mmap and stack */
-#define MIN_GAP (128*1024*1024UL)
-#define MAX_GAP ((TASK_SIZE)/6*5)
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
-
-	if (gap < MIN_GAP)
-		gap = MIN_GAP;
-	else if (gap > MAX_GAP)
-		gap = MAX_GAP;
-
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
-}
-
 #define COLOUR_ALIGN(addr, pgoff)				\
 	((((addr) + shm_align_mask) & ~shm_align_mask) +	\
 	 (((pgoff) << PAGE_SHIFT) & shm_align_mask))
@@ -144,36 +117,6 @@ unsigned long arch_get_unmapped_area_topdown(struct file *filp,
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

