Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B308C4151A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3024F2190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IJwpSI/X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3024F2190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE8328E0009; Wed, 13 Feb 2019 12:46:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C995A8E0002; Wed, 13 Feb 2019 12:46:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B38578E0009; Wed, 13 Feb 2019 12:46:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 736578E0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:46:57 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so2404048pfi.21
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:46:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=scDNPfor2+o2sRXISwjXU4Ei4L2S2/i4alFAOpD2+h8=;
        b=tYRg09Z2Ac0qtu+D9I1seh6JP414Sl+7WVm3M8CdxT3+15Fs5nyoJmntyPC0lq8YUe
         rgnUkj+CGrIIPPVoSEPfNMJFV4wMM448Z+vqLsl2dMoXm2nmTLVwfFP4N5U2JYiANpxP
         TIfAkpsDrH6izZcC9M5ihVxRBdt7uyrsCbE/kHw6XdGwRzn+sibnC8YKF2HsD8RQYcBQ
         y1lmskzG9QrcxEIHnw2iUSlYzXXqNaW95sHU0LiS40s6VtDzhG1HZ7XJ+DDm0pe9O4/8
         n9C835/Lt48SdHQ3CrMQ1zzrNemeiKrvbD9xo1uUwp0zB9co0Vtj9NWJ/m4Oz3OT0YbJ
         a1Og==
X-Gm-Message-State: AHQUAuY1k+ckAwfg8f8onc/koKz6ONUPtU+bVQpIUXXK6xW7NI8KqvRm
	AH9y3njiK6l00y3IK1CmxZW7eqpyrgZP4uHWN+rEZN4+z+VTTdyS1F4/aQ9PwR5U/C6/T0KP0fG
	IqIjmhsBdjFBeJ3f6FIxDJ7kNrn2cLLhwfXpn5JWQbIt5nHMkGZHEMKLxIMXSZT0=
X-Received: by 2002:a63:ea06:: with SMTP id c6mr1521816pgi.162.1550080017116;
        Wed, 13 Feb 2019 09:46:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbZ+n1o4nvZySVQRNaFKTcDy4CcZJ7aHoQ1dqSB4BFiTkne7DIqJHBK5cy0B6awFXT3W5Ie
X-Received: by 2002:a63:ea06:: with SMTP id c6mr1521773pgi.162.1550080016336;
        Wed, 13 Feb 2019 09:46:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550080016; cv=none;
        d=google.com; s=arc-20160816;
        b=Zc9/Ykqitj/RnsgtWlwHCFWLFUtIG1kIbRw6QU8Q6m2bnSLjwsDppUk6CRE+RZ7WUM
         dlyhzXo3+pOwXexzs27tjrnUf/xCZloGguHnGuwAB8/fDUBsFqydPHoVxZ5tOAY73fmr
         ieXTx/52R6c1L7ZfeKssf0jcn8R+yw74Q8R9WEqGJvbZoykbNcgk1ws7HnYcpfdVZKKm
         mYkYpXa7SskjCqyQiHl9bHLBxsuo19T0rCn+aqV96LrGaD99m++mGQj7xpK/oDPWAI17
         s1wwQ0Nkcp+gno4sUIOdZu9cjzJ0TrCVksPo1wx7AZjsMx1eoqNjQhksuHIw3+6MjxdA
         hdzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=scDNPfor2+o2sRXISwjXU4Ei4L2S2/i4alFAOpD2+h8=;
        b=dVFZpifeXB8vJsPJyuGcyCTQwJv1Hf0umaRhtOdKNPa4EeWNC3rR8eajsG+8jy7VvR
         yhQWOveSw5V7StNn+FFonQRHvG9GUyg+9uYTAlgOBl6DcO/WEGsa5m/TaZ2MfqeY6aSB
         sZC9V5wyjheMmUVW/nMU7ATwfZ+BU7LUj7EleGUQOTJRPSkjPpwGsQS5jbDp9YzM2sTI
         abdJCd3KQ1u9zvp1eM2sGFW+5PdZX1CafSlN2X9H/TQqxMJCMg2KlsuerUQfgRojALi7
         hUMkRUcNQZ62AQonELUrKBU8AOHQYUfrAB3QU9Jt5ENiJEYhTgfVfLi1dwkNVNUAKIR+
         eNYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="IJwpSI/X";
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c11si15588823pgj.255.2019.02.13.09.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 09:46:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="IJwpSI/X";
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=scDNPfor2+o2sRXISwjXU4Ei4L2S2/i4alFAOpD2+h8=; b=IJwpSI/XRhEAwk7ZzJEGRkrw9d
	jGjt38pnhTVOHXpxC14ac+cB89UHoVWK5xl6vc120cHNKmjpAJe+WlWjQ4411nbOc6irZz0FSwmem
	4K7YXZvxLlhchihXJusyTq2KxOmh3Zire4J5JN9xn6Re3evnof3iJ9ozTK2DfNuGitsjCl4FEapYi
	jYEMJuAD4CvXUs/CjaxTOmI88L14bw049dP5+0t9rYM7cS+FnwGI9GlykHqqfk23Lorutp4E7xxym
	w0T8xV3/mfnDmG6FHmInh3GObANIk6lnQCvDs8uFmsghKNjU++Q/j5wo9Z4/gT6TVNzUcZIWiJK34
	fGtsADkA==;
Received: from 089144210182.atnat0019.highway.a1.net ([89.144.210.182] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtycL-0006ux-DF; Wed, 13 Feb 2019 17:46:41 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Guan Xuetao <gxt@pku.edu.cn>,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 8/8] initramfs: poison freed initrd memory
Date: Wed, 13 Feb 2019 18:46:21 +0100
Message-Id: <20190213174621.29297-9-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190213174621.29297-1-hch@lst.de>
References: <20190213174621.29297-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Various architectures including x86 poison the freed initrd memory.
Do the same in the generic free_initrd_mem implementation and switch
a few more architectures that are identical to the generic code over
to it now.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/mips/mm/init.c     | 8 --------
 arch/s390/mm/init.c     | 8 --------
 arch/sparc/mm/init_32.c | 8 --------
 arch/sparc/mm/init_64.c | 8 --------
 init/initramfs.c        | 3 ++-
 5 files changed, 2 insertions(+), 33 deletions(-)

diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index b521d8e2d359..a9a977d75838 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -492,14 +492,6 @@ void free_init_pages(const char *what, unsigned long begin, unsigned long end)
 	printk(KERN_INFO "Freeing %s: %ldk freed\n", what, (end - begin) >> 10);
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
-			   "initrd");
-}
-#endif
-
 void (*free_init_pages_eva)(void *begin, void *end) = NULL;
 
 void __ref free_initmem(void)
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 3e82f66d5c61..25e3113091ea 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -154,14 +154,6 @@ void free_initmem(void)
 	free_initmem_default(POISON_FREE_INITMEM);
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void __init free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
-			   "initrd");
-}
-#endif
-
 unsigned long memory_block_size_bytes(void)
 {
 	/*
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index d900952bfc5f..f0dbc0bde70f 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -299,14 +299,6 @@ void free_initmem (void)
 	free_initmem_default(POISON_FREE_INITMEM);
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
-			   "initrd");
-}
-#endif
-
 void sparc_flush_page_to_ram(struct page *page)
 {
 	unsigned long vaddr = (unsigned long)page_address(page);
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index b4221d3727d0..4179f0e11fd5 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2602,14 +2602,6 @@ void free_initmem(void)
 	}
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
-			   "initrd");
-}
-#endif
-
 pgprot_t PAGE_KERNEL __read_mostly;
 EXPORT_SYMBOL(PAGE_KERNEL);
 
diff --git a/init/initramfs.c b/init/initramfs.c
index f3aaa58ac63d..4a42ff3a2bd1 100644
--- a/init/initramfs.c
+++ b/init/initramfs.c
@@ -529,7 +529,8 @@ extern unsigned long __initramfs_size;
 
 void __weak free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
+	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
+			"initrd");
 }
 
 #ifdef CONFIG_KEXEC_CORE
-- 
2.20.1

