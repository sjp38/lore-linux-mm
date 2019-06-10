Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02EACC4321A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B042F2086A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AFD8YxeS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B042F2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58EAE6B0275; Mon, 10 Jun 2019 18:16:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5179B6B0276; Mon, 10 Jun 2019 18:16:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3949F6B0277; Mon, 10 Jun 2019 18:16:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id F2C766B0275
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:16:54 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c3so6501583plr.16
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:16:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=skB+ZnavO/i7RNPtU2wJ23sFxTsqRf+NEErVUiBdRM8=;
        b=K0BaM0wIz2Je/gj33DlU8SRMOcnuHzKRtUBkWWsz6Mf08b3pdWIP/IGU16PQyxeROP
         dIFYPy3QAgj32k3VCk7xRZMa9Ll8ae8bOcVbdReB4yj+nO8moJI27vqInecC0P+6d6qc
         M9SXBCG+t0ogpb3Um5v/J9lkymO5S+nxgE6F5x8te6BirG3t2j7iil42Wx1/MwrrzTn9
         LQpRwLPIZYMJXTyIMCUr39w8MpVIwix3HQuzGrMnH4YqgvCdPMURaaY9SMU8IeTZDpXR
         wu2sLIUdMIcUf5VOwcZzvEX2U23RT+39NhCFKWIS5TdFP/H99wx6mZj46kLmK+HfTeyp
         ZFyw==
X-Gm-Message-State: APjAAAWvEN/S0Y7Ow2lHz1z75DI5vy2D/03eXL1nxMsRVx5oLKMD6x8F
	rGgZ18kfDzDVGTubKT+/dtFMDlzgym5C5apJZowoGtNqDe3Z5BKUMKDEO4sDPqVZNCfwp6BhAUV
	JMp1TOkEcd4+POHVFfKwTMZ8kWsLBBVvsRqjldzAy17T5J2/LqhIJnziCs6DJfAw=
X-Received: by 2002:a63:5457:: with SMTP id e23mr18079466pgm.307.1560205014557;
        Mon, 10 Jun 2019 15:16:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLkCshLtQOEYKbDWGgiU9mDtmBHF1kU8GtILaoTXqKR2vHLMDoMH4VdC+u39ExPM+bYs6Y
X-Received: by 2002:a63:5457:: with SMTP id e23mr18079400pgm.307.1560205013558;
        Mon, 10 Jun 2019 15:16:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560205013; cv=none;
        d=google.com; s=arc-20160816;
        b=gOchHMAQKM4AAsCu1+Eb/RE4JyL8i5QUPW5zdmI85TT8o7mTCvB5S+YWsp5VlMJPZx
         I1mxUNVrgjlf1NSajjfdEV66AhVrdBcs8Ojln1ZzmxSYNWPe8PK5TkMK+MexY3PBVI3T
         nAhi8voKELYPbQwuloJa0ohVgVbH91vTqCQMsZy+YFLO85dkDGpWMRWByCd8Bh6ozHFl
         dkrVfQzOu2G4lf7/nr9KbMv4Qgj+B5Tc4RFMjhAirmx/Z1IlVsll1fFINV85xXeFRrAS
         HT3pBoe9v1q1dqaVNguWv7hyUNUWNXVWvmySy1eJrr8nJkBOm+whhGRE5Ey1Vt5lK9Ml
         iJog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=skB+ZnavO/i7RNPtU2wJ23sFxTsqRf+NEErVUiBdRM8=;
        b=t1Q56WsjJFV8p05Dhqf7tYBQO1OAdbdse1fWyNrbdPNd1kCJCz0khs+6Lu2LZJAeuM
         ozqi5TDgh5x5ylLWZW4LF9R6LveAzBAOjt337wEoT0dXGj8y1YoyREpAQR6wLuQaI5n/
         fzrzgN21n+ZKJhbq8anYa/8PDo3YL90DEGyY6RGHD+0UELCxyfpoQaeH2C4ftXQM69hc
         gUEjPXXd4FW2QDtH/JskUFojFNtc/z+fnqBVLYL+VTB4IQu6sigBgRtwK6WCGpEmwyJC
         onZk8bJCWtKz8D+4juYiUbolquLaddQ96XofuuWoESIBHQ6Ye3H536EXIObzxBFvStAS
         2i3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AFD8YxeS;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m22si681537pjv.0.2019.06.10.15.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:16:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AFD8YxeS;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=skB+ZnavO/i7RNPtU2wJ23sFxTsqRf+NEErVUiBdRM8=; b=AFD8YxeSHzKPrhOrVzUrstkaZD
	+8OdqXAaOst5JO4QkLywitZN4dFaWbbARKg5GXO3RJm/VkYKGOqro+hPA7tnJnDE/YgvXaNEIH4bJ
	B9yzk/F+V/3RLSO7rH+msjmI2PUqVhmOU7DyeYEvezXbna6F+DZ4iGYT6Bgg67977t9h+kGYB8wNJ
	nxJEPQzgAYpEzCGNdbpj66ymR8md3w6p0aNP+0dvUcLDPlt7nYDZHhCbyCFlKWC6NFHVKI/d5E6iC
	U1WGag3M8zWwklrDgiyzWAacRtBfvNTwWIjcygHWUODgqtsQ6yd374bwQK7U2lOekGf28z1VcIp4K
	DI1BjtIA==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSaw-0003Rh-EJ; Mon, 10 Jun 2019 22:16:50 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 10/17] riscv: provide a flat entry loader
Date: Tue, 11 Jun 2019 00:16:14 +0200
Message-Id: <20190610221621.10938-11-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190610221621.10938-1-hch@lst.de>
References: <20190610221621.10938-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This allows just loading the kernel at a pre-set address without
qemu going bonkers trying to map the ELF file.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/Makefile        | 13 +++++++++----
 arch/riscv/boot/Makefile   |  7 ++++++-
 arch/riscv/boot/loader.S   |  8 ++++++++
 arch/riscv/boot/loader.lds | 14 ++++++++++++++
 4 files changed, 37 insertions(+), 5 deletions(-)
 create mode 100644 arch/riscv/boot/loader.S
 create mode 100644 arch/riscv/boot/loader.lds

diff --git a/arch/riscv/Makefile b/arch/riscv/Makefile
index 6b0741c9f348..69dbb6cb72f3 100644
--- a/arch/riscv/Makefile
+++ b/arch/riscv/Makefile
@@ -84,13 +84,18 @@ PHONY += vdso_install
 vdso_install:
 	$(Q)$(MAKE) $(build)=arch/riscv/kernel/vdso $@
 
-all: Image.gz
+ifeq ($(CONFIG_M_MODE),y)
+KBUILD_IMAGE := $(boot)/loader
+else
+KBUILD_IMAGE := $(boot)/Image.gz
+endif
+BOOT_TARGETS := Image Image.gz loader
 
-Image: vmlinux
-	$(Q)$(MAKE) $(build)=$(boot) $(boot)/$@
+all:	$(notdir $(KBUILD_IMAGE))
 
-Image.%: Image
+$(BOOT_TARGETS): vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $(boot)/$@
+	@$(kecho) '  Kernel: $(boot)/$@ is ready'
 
 zinstall install:
 	$(Q)$(MAKE) $(build)=$(boot) $@
diff --git a/arch/riscv/boot/Makefile b/arch/riscv/boot/Makefile
index 0990a9fdbe5d..32d2addeddba 100644
--- a/arch/riscv/boot/Makefile
+++ b/arch/riscv/boot/Makefile
@@ -16,7 +16,7 @@
 
 OBJCOPYFLAGS_Image :=-O binary -R .note -R .note.gnu.build-id -R .comment -S
 
-targets := Image
+targets := Image loader
 
 $(obj)/Image: vmlinux FORCE
 	$(call if_changed,objcopy)
@@ -24,6 +24,11 @@ $(obj)/Image: vmlinux FORCE
 $(obj)/Image.gz: $(obj)/Image FORCE
 	$(call if_changed,gzip)
 
+loader.o: $(src)/loader.S $(obj)/Image
+
+$(obj)/loader: $(obj)/loader.o $(obj)/Image FORCE
+	$(Q)$(LD) -T $(src)/loader.lds -o $@ $(obj)/loader.o
+
 install:
 	$(CONFIG_SHELL) $(srctree)/$(src)/install.sh $(KERNELRELEASE) \
 	$(obj)/Image System.map "$(INSTALL_PATH)"
diff --git a/arch/riscv/boot/loader.S b/arch/riscv/boot/loader.S
new file mode 100644
index 000000000000..5586e2610dbb
--- /dev/null
+++ b/arch/riscv/boot/loader.S
@@ -0,0 +1,8 @@
+// SPDX-License-Identifier: GPL-2.0
+
+	.align 4
+	.section .payload, "ax", %progbits
+	.globl _start
+_start:
+	.incbin "arch/riscv/boot/Image"
+
diff --git a/arch/riscv/boot/loader.lds b/arch/riscv/boot/loader.lds
new file mode 100644
index 000000000000..da9efd57bf44
--- /dev/null
+++ b/arch/riscv/boot/loader.lds
@@ -0,0 +1,14 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+OUTPUT_ARCH(riscv)
+ENTRY(_start)
+
+SECTIONS
+{
+	. = 0x80000000;
+
+	.payload : {
+		*(.payload)
+		. = ALIGN(8);
+	}
+}
-- 
2.20.1

