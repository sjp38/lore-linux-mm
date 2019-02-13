Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 679C5C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:47:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A814222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:47:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tCEM6Wk7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A814222B1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E19B8E000A; Wed, 13 Feb 2019 12:46:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5924A8E0002; Wed, 13 Feb 2019 12:46:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A9EF8E000A; Wed, 13 Feb 2019 12:46:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD048E0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:46:58 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f3so2168341pgq.13
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:46:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PrNOrZHUtDO30vN/fIi9FDRbb/3B7XAAJkaxXZrg5oY=;
        b=HC1EwQ3wSawtKT/PdbjLv7vhuGNPwDzSScUJYv30Lx3xpYDHF8iYt983M+jTP+0Jy+
         K3zGAhm5o2YmZQLcdQPmLO5AhPlNtK6zUcIoZ0qJ9lC/6hcnYRMyFrFFIjQN2FtKPBb9
         EDE9PDZI/oJYYalkmOHtTA2517Zopbi1yC2bHfuhbcvu5zOPTXQ/HlM23Im51vS4pbRJ
         5uda+QLV/AjePhG7dnRX7C3GhWS6TUAIEgUfHaFOqhgPY4Ds3jbLxD6nN4Eb8jdFmvAf
         91w1jf9pHfQLqG+NwrsZCvFMvYjxdFQh3zDa5GdY4SuLZlpbCRYOICXVNup+nG+iAiol
         m7iw==
X-Gm-Message-State: AHQUAubVjOfcQ6SV8vYLCh+EU8dZI+40yqvnfBCAtSIZrJ72BuYi9v/7
	xPhnhxajlqaSgnAePATq+ZyaGG8tgYjW52wcZL3n8GjOcHRhZ32DSsdwefvu/O7YXPk3cRqVGQh
	gASvWhQPHm6ntWLEYgufP6diQ2ktoY+D/18EFgwecOROj7v2jdIzhfNeqfaTpttw=
X-Received: by 2002:a63:160d:: with SMTP id w13mr1470628pgl.85.1550080017701;
        Wed, 13 Feb 2019 09:46:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IagMQVHp1xmowyLotaWH+zYY9qcwep6qVJmBNZL6Ix7oU+MQqERHcs4vxC75KrmI09Yjpy+
X-Received: by 2002:a63:160d:: with SMTP id w13mr1470512pgl.85.1550080015849;
        Wed, 13 Feb 2019 09:46:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550080015; cv=none;
        d=google.com; s=arc-20160816;
        b=R+D6MK7piHaXulD/JZzPHCibedKEYzZdpQm9pGI01rJYCSjiRnFKqGu2o8+b6nfoOc
         ynQ+wTNMsE3GkCYJBeXh09OwJsUg067gz97kRJYyywmecEjtU1aSdoB4EG0ClUFuOaCd
         EwszBrMURtX27ckhdtN+4n74M1Q1TWpOeYXEivlOfMry3OI5wUJemYg4LV3zhW01V3OY
         vgLkBdxx0dvCNO20bk7tentbrphHuPqwfAC5Z2sAf2o4roehR/mt3tmer7x1RRnchlaF
         +0jKT2RYJpE5IdNiMZwB6eHUp/KMC8G1TgFl5kmqxkETyxG9LbfeJyvzlesbWs+x5/Pf
         75PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=PrNOrZHUtDO30vN/fIi9FDRbb/3B7XAAJkaxXZrg5oY=;
        b=M15ap++I8CEpCyG7QaeLrEjCQShi6SnyBI0yPWmQuVy0sWGv6zAnV++2bTyc0SB1AF
         4D1eqsb3aJiGXnpHgtAX9gjXY5wjzm4TAoXvjwYOkjK3E/EvZeEdpcopnCukW6TSHcXK
         lnerY3YV7fs/WF+F8ysJ1186WrjY5Mzdqv5qPLmj4eBgaMjis3S9vjLTj1EIWE3Y7aKn
         mRK1mwQmppz78qaCHylL8ZaGrfL0t2+nCI+rVc3YmtEfj3W/hzBDiWfjEqu9PJhROfvS
         UqlgnsofNEQd0u5DtsECdurXRyLareTW6gajj1sa9WDZNOCXwZuaCug/4bCbtpHU4H2F
         FdXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tCEM6Wk7;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x6si4491017pgp.367.2019.02.13.09.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 09:46:55 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tCEM6Wk7;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=PrNOrZHUtDO30vN/fIi9FDRbb/3B7XAAJkaxXZrg5oY=; b=tCEM6Wk7WB51JtayIYCq/rBjvK
	OFbhI9keM+O8AX5RSorJz8SBS7+tKzeF4xklxv5mV112Do5791tI2VCLZM9xV682E7ItQbcD6Ds8j
	G+0eORJMo+eyypbAMHb49J+6GbOWHOpLtddFl3OjSxJJSglh5FYCaozRhLkXT5lNmVmdTM9qW5yhO
	H9Gf9MLmIWYnMo+rqTcgAuJRI9i+xkSrgkOc41NY+D1MUGjhqvdgc4h8t8tc/7w4fZiKs6bEhAFKx
	xvy5VYVufLmchIF87QS3gm99ifTQYaIbu7H5ZYEcObgt6TeaNz1OTj0A/oQmDJe0E58XKCmNf/6IX
	0KfT+qAQ==;
Received: from 089144210182.atnat0019.highway.a1.net ([89.144.210.182] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtycI-0006qw-Pn; Wed, 13 Feb 2019 17:46:39 +0000
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
Subject: [PATCH 7/8] initramfs: proide a generic free_initrd_mem implementation
Date: Wed, 13 Feb 2019 18:46:20 +0100
Message-Id: <20190213174621.29297-8-hch@lst.de>
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

For most architectures free_initrd_mem just expands to the same
free_reserved_area call.  Provide that as a generic implementation
marked __weak.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/mm/init.c      | 8 --------
 arch/arc/mm/init.c        | 7 -------
 arch/c6x/mm/init.c        | 7 -------
 arch/h8300/mm/init.c      | 8 --------
 arch/m68k/mm/init.c       | 7 -------
 arch/microblaze/mm/init.c | 7 -------
 arch/nds32/mm/init.c      | 7 -------
 arch/nios2/mm/init.c      | 7 -------
 arch/openrisc/mm/init.c   | 7 -------
 arch/parisc/mm/init.c     | 7 -------
 arch/powerpc/mm/mem.c     | 7 -------
 arch/sh/mm/init.c         | 7 -------
 arch/um/kernel/mem.c      | 7 -------
 arch/unicore32/mm/init.c  | 7 -------
 init/initramfs.c          | 5 +++++
 15 files changed, 5 insertions(+), 100 deletions(-)

diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index a42fc5c4db89..97f4940f11e3 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -291,11 +291,3 @@ free_initmem(void)
 {
 	free_initmem_default(-1);
 }
-
-#ifdef CONFIG_BLK_DEV_INITRD
-void
-free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index e1ab2d7f1d64..c357a3bd1532 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -214,10 +214,3 @@ void __ref free_initmem(void)
 {
 	free_initmem_default(-1);
 }
-
-#ifdef CONFIG_BLK_DEV_INITRD
-void __init free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index af5ada0520be..5504b71254f6 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -67,13 +67,6 @@ void __init mem_init(void)
 	mem_init_print_info(NULL);
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void __init free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
-
 void __init free_initmem(void)
 {
 	free_initmem_default(-1);
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index 6519252ac4db..2eff00de2b78 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -101,14 +101,6 @@ void __init mem_init(void)
 	mem_init_print_info(NULL);
 }
 
-
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
-
 void
 free_initmem(void)
 {
diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index 933c33e76a48..c62e41563bb9 100644
--- a/arch/m68k/mm/init.c
+++ b/arch/m68k/mm/init.c
@@ -144,10 +144,3 @@ void __init mem_init(void)
 	init_pointer_tables();
 	mem_init_print_info(NULL);
 }
-
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index b17fd8aafd64..3bd32de46abb 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -186,13 +186,6 @@ void __init setup_memory(void)
 	paging_init();
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
-
 void free_initmem(void)
 {
 	free_initmem_default(-1);
diff --git a/arch/nds32/mm/init.c b/arch/nds32/mm/init.c
index 253f79fc7196..c02e10ac5e76 100644
--- a/arch/nds32/mm/init.c
+++ b/arch/nds32/mm/init.c
@@ -249,13 +249,6 @@ void free_initmem(void)
 	free_initmem_default(-1);
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
-
 void __set_fixmap(enum fixed_addresses idx,
 			       phys_addr_t phys, pgprot_t flags)
 {
diff --git a/arch/nios2/mm/init.c b/arch/nios2/mm/init.c
index 16cea5776b87..60736a725883 100644
--- a/arch/nios2/mm/init.c
+++ b/arch/nios2/mm/init.c
@@ -82,13 +82,6 @@ void __init mmu_init(void)
 	flush_tlb_all();
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void __init free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
-
 void __ref free_initmem(void)
 {
 	free_initmem_default(-1);
diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index d157310eb377..d0d94a4391d4 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -221,13 +221,6 @@ void __init mem_init(void)
 	return;
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
-
 void free_initmem(void)
 {
 	free_initmem_default(-1);
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 059187a3ded7..1b445e206ca8 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -935,10 +935,3 @@ void flush_tlb_all(void)
 	spin_unlock(&sid_lock);
 }
 #endif
-
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 33cc6f676fa6..976c706a64e2 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -388,13 +388,6 @@ void free_initmem(void)
 	free_initmem_default(POISON_FREE_INITMEM);
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void __init free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
-
 /*
  * This is called when a page has been modified by the kernel.
  * It just marks the page as not i-cache clean.  We do the i-cache
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index a8e5c0e00fca..2fa824336ec2 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -410,13 +410,6 @@ void free_initmem(void)
 	free_initmem_default(-1);
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
-
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 		bool want_memblock)
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 799b571a8f88..48b24b63b10d 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -172,13 +172,6 @@ void free_initmem(void)
 {
 }
 
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
-
 /* Allocate and free page tables. */
 
 pgd_t *pgd_alloc(struct mm_struct *mm)
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index e3f4f791e10a..01271ce52ef9 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -316,10 +316,3 @@ void free_initmem(void)
 {
 	free_initmem_default(-1);
 }
-
-#ifdef CONFIG_BLK_DEV_INITRD
-void free_initrd_mem(unsigned long start, unsigned long end)
-{
-	free_reserved_area((void *)start, (void *)end, -1, "initrd");
-}
-#endif
diff --git a/init/initramfs.c b/init/initramfs.c
index cf8bf014873f..f3aaa58ac63d 100644
--- a/init/initramfs.c
+++ b/init/initramfs.c
@@ -527,6 +527,11 @@ extern unsigned long __initramfs_size;
 #include <linux/initrd.h>
 #include <linux/kexec.h>
 
+void __weak free_initrd_mem(unsigned long start, unsigned long end)
+{
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
+}
+
 #ifdef CONFIG_KEXEC_CORE
 static bool kexec_free_initrd(void)
 {
-- 
2.20.1

