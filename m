Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FF80C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF51A2089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="t+2vO2nF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF51A2089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73E896B0266; Mon, 24 Jun 2019 01:43:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A0658E0002; Mon, 24 Jun 2019 01:43:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53F9C8E0001; Mon, 24 Jun 2019 01:43:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D92C6B0266
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:49 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q14so7186477pff.8
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=skB+ZnavO/i7RNPtU2wJ23sFxTsqRf+NEErVUiBdRM8=;
        b=c6ZyxVjlTQkweNZ1Q2CPU6ibLt/yBq0MtrBby2eJPHC63SxkaJ9vU9S6xdcFpjnVud
         xWNj/PssM6b2C07Oc7tG3V2HGlaPBdqzCDCn3agqfiJzo/jhngX+A1m1w88vnCrloRAM
         UHLtNXL+GPVCrDOzQqgUno0XD/m2xW+0RrnsQlUz2DIvl2nplY8kgy3IbOmBkLIjjoXn
         xICOZKJCZIWYGG8JjGFPhsY/67dL8QpXoYwqjhfQGp7Mex/7qnsaRYWudr4KxZZjZbzz
         VuAQmlKVMoVksL+8GzOTdvAewLOD6/TJ1O6G+1nkj6pYwnNS2NRYqXsUZdS62ygLRipi
         iDxg==
X-Gm-Message-State: APjAAAWHDlh1ewE7ljyGfQM412HKLVRWlP4X6PFw6Q3pm/kxrK5QLtr4
	Pr0jaSTxRYfJE5IplcN4qFzvVD9LMF0xAE66O8Ctedbh4mYVNCbopLTaQouGTDHVIyuywBkf9bF
	clcjZ5z6+i6209VhC5t4odijGzq/iyDkw0oZHOVjSBMbZOOK8PI4zpfKbqOznoaA=
X-Received: by 2002:a63:9d82:: with SMTP id i124mr4220910pgd.155.1561355028728;
        Sun, 23 Jun 2019 22:43:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0n+nCoQdVtfyv30K/oUurfX3T2KNjS5MTekTy1tp+wsm5LJHud2U0f1clULsrWXbC6o/K
X-Received: by 2002:a63:9d82:: with SMTP id i124mr4220865pgd.155.1561355027862;
        Sun, 23 Jun 2019 22:43:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355027; cv=none;
        d=google.com; s=arc-20160816;
        b=E4yW1b+uWaNUJn0+1RAiZOYGck3XfQdGI9TEtCuax0BUlA1r6jw1KlYjcBPHxh4vo3
         Mr009jEl4S027WNC61tAn4sERezc4Xy8OU+xOqzvwq+0Z7DibruDH4/SGFRRhBGZxauV
         k/L3ftZZg2nzx8qdCxQ+dJDRs/1Id8LfTn91h7TsWtyUEkSt8gXpKfbtMk3Ir3H7vjTB
         7sSjEIurau3qbwJvHWtw9YwGWg3Es9FJGI7ucY5BPBPgccN50/U6FdPAJE28tPcGzbBM
         rmZVL+BMTbkyM5bc8B6/ORf/BP6zaGollFgG+1AxOAw4Azhd6N8g3PJi32m/cYrAA0Ge
         GWmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=skB+ZnavO/i7RNPtU2wJ23sFxTsqRf+NEErVUiBdRM8=;
        b=tDKykeFtSHj9BS4In/oaCr82c/lQMKG0iVQYiijZoRQXISyLM7LM4erW+GZ+tUh5B/
         QqeliVqbGIY2BstAOoIUgMw9Nz/TIKDnQHQTKgyXAGd78tzdh4XSbkk+eJ1DXxEO9eNi
         bg2TFdeO6oE7jtFbA///n+1rZqIaPy5SgL8gKSTA8E5fogkWmGxV/NowDtqpUDPbVv07
         vL5nkY17lrimLp2Hvp1LYwcz+RdHgidoY+H1fNzF43KcB0Z2GZDOAQVoyQaTRIbUWtRv
         Db+GQyoIdLfCsCbY74G58sXOrk13tS1rHl9dT6lE3iU91KMBJRtvj3CUoyZ/HYeFiWId
         3Z/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=t+2vO2nF;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l6si10225035pgl.444.2019.06.23.22.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=t+2vO2nF;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=skB+ZnavO/i7RNPtU2wJ23sFxTsqRf+NEErVUiBdRM8=; b=t+2vO2nFTl72dJHuKdBfsPVdXB
	PpN4mUwQTM7uVVMBYemMWRy7TO6gT0foijMGEEFeKV4uMpaJeS7qSaL5ucgqPVCxwZrtbPlPp19Da
	aqyr1nEhcizmT1bqw0YevN+FGcf0/OYne3Oepy6C+pN0QROZYbNapyQkwh5WhJpTkQZiTywAon4cA
	r85QDsSSL1jXX30Ue8PHJp9qgNOGx/Zwc7vrTgAy5NwVztpDW8OlKMsoqOwaUNpk5k8xj3sWraNC4
	RTk3jha4jQXHwplpwmyxVqldpftE7xCFg0DjpblKhPjvOPMSDLEZR4e+gDg/zk4OBHuakmfmsrQmz
	3x0/tFLw==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHlZ-0006UH-Uw; Mon, 24 Jun 2019 05:43:46 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 09/17] riscv: provide a flat entry loader
Date: Mon, 24 Jun 2019 07:43:03 +0200
Message-Id: <20190624054311.30256-10-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190624054311.30256-1-hch@lst.de>
References: <20190624054311.30256-1-hch@lst.de>
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

