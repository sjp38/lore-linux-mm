Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C372C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:44:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2B062089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:44:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DsBS4El+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2B062089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20D336B026B; Mon, 24 Jun 2019 01:43:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 196868E0002; Mon, 24 Jun 2019 01:43:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00FC78E0001; Mon, 24 Jun 2019 01:43:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC5C26B026B
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:58 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b10so8618303pgb.22
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QKrZKqm9xX7/gKntli3kjDV0bZW8VwVWFoBUswi6ZbI=;
        b=ZsHTxkSMKSS0UF6qALUW8Dx9obhaqtujRawY1rE4bGrlkJbc57sttXTckXbxNsZqyd
         e5fvC8vcYkYSEVON2nDC48XipLpPC+QrhQbBlMiN/IiPB+XEeNRvl6dJYlSAQRhVYjOB
         K2IJLnDMR1+uDGJVHd6SVgjLf0Nuv4NnnZ7VhitB6PsYKHnbm3ncgNjBT/d7/PK6RE3s
         DfqKezFTW6ohTI/LTwkq3HLB5OyaVedrkZeVWGwQOAdBYBoc7I73GwgrwGGmAcg1McTi
         cQsrrVLBOU1UopSSjTVfyfqTn+eCGFe2xPkNICUjwT98eCGUG71ybVuLiFA3C51i+MWz
         +mtQ==
X-Gm-Message-State: APjAAAVhNmlTpIesB9fKUceHTDofASKp+p2QLKE/tT+TXBhgZV5153EK
	QkJYFc/LU0BTQ+mT2sa5FfyTO+AjQ85JSNlty5xjbVnvhT/HxOO/IEZIFvsjhmOeucdNPtGvdPY
	pbIhVDGBQYXtiv40Ce9JUR+FxAsHD3M0tFHW0bsuW9PdUxZxlZFqdb65IxWkjsjE=
X-Received: by 2002:a17:90a:af8b:: with SMTP id w11mr22695336pjq.135.1561355038465;
        Sun, 23 Jun 2019 22:43:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLDD6S0gkc+LfrDuhRbsjGEYt4acfTkgeYfhcu+aaxIjwTVpeH2z5CgxegsedjAKFMYtB/
X-Received: by 2002:a17:90a:af8b:: with SMTP id w11mr22695289pjq.135.1561355037740;
        Sun, 23 Jun 2019 22:43:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355037; cv=none;
        d=google.com; s=arc-20160816;
        b=Ys2D/M8w2OLQC0uwXaNQqKnyHsRMsi5LoXYvwwbAN2yErY3aPNMPALLy04sKkxFwlt
         naBP+BvVODlrE4Oih/Ll54uoeQzTo/sakDJlRXMygEKCFF8HEeHzjgPPqiNZrbJFcheB
         bwI/p40PCfETJly7V886e/x41/NjsaBivKg4dQwlwwvJ7kYk9EEAPj3OmJIwgMuXTvFK
         x9AIVrWhK6/cu52B57OAphI46bFJ8tUzKpVa1RfZywml83lHcbf2v1RKnD1KHtzeAmCR
         nuH7eNp0BkEf8wQqcPn2zzWSp8TwVeyIPxhd333XML0ydhFLI+keiPj/tkgFmlpnNCe+
         BK3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QKrZKqm9xX7/gKntli3kjDV0bZW8VwVWFoBUswi6ZbI=;
        b=bG1BOzRU1Qp6id1gmuDNiZb2qJix1oczy/zafEKob/jJSBGP1TLQeGeQfCheFL6UCV
         bJgZH+ZnjamOGsYKttZUMJHqI8qI6V/46HdSXReZVK8959870FdeeXICEpu1bdQWJ9D9
         P7WBCIomVwETSdKMgIrF/gUNT1gOeqD3ppVpPz31E6kr3JQNiRb0w19GeJhsDv7X/usk
         p3w9IICyBSmv1XhIsoNb0j0/E3cxfWZIQHAXKrAIYneJUANt5MtylsBAWQAUlXpMAxd4
         x+EoRJm+zRhLSXAPUCaFUQBOgXW0Mwnip9b31UvjJqr+KQhDlWMbB0aGzQDWNeQtJqO5
         QZSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DsBS4El+;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z22si9120394pgh.458.2019.06.23.22.43.57
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DsBS4El+;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=QKrZKqm9xX7/gKntli3kjDV0bZW8VwVWFoBUswi6ZbI=; b=DsBS4El+mIDdDpYL3biKUdVRJ/
	gRsHj2wUwnw4hOCIz4900CEw/5hNBn83QXaN/N05RmdL9tzK/1lSSI2iqYVahKMo0XaXpwbjdtPKY
	6fusC2JxKNUi6Wcy0DXpKqNMuKP3VS4bgMDOkykPUY3EwbA92QOKfS/y0+A1ROpcg74mXxa1pHNsX
	9CDeIJ4QBgCUmvopkpBdjN2FiVF9Xk0wvrMzGPRniCqFcnTi6ht8NvrkQmjx+LMwEtdRQIot497Y4
	RLH6FazV3C/man5B6AAVTMf3gveCXvtw/C+Z1o9GZMvhIJFNTotzhkFBiUgBSrkjzl4YyRHeCmXX9
	6f7Z39Vg==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHlj-0006gQ-Me; Mon, 24 Jun 2019 05:43:56 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 12/17] riscv: implement remote sfence.i natively for M-mode
Date: Mon, 24 Jun 2019 07:43:06 +0200
Message-Id: <20190624054311.30256-13-hch@lst.de>
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

The RISC-V ISA only supports flushing the instruction cache for the local
CPU core.  For normal S-mode Linux remote flushing is offloaded to
machine mode using ecalls, but for M-mode Linux we'll have to do it
ourselves.  Use the same implementation as all the existing open source
SBI implementations by just doing an IPI to all remote cores to execute
th sfence.i instruction on every live core.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/mm/cacheflush.c | 31 +++++++++++++++++++++++++++----
 1 file changed, 27 insertions(+), 4 deletions(-)

diff --git a/arch/riscv/mm/cacheflush.c b/arch/riscv/mm/cacheflush.c
index 9ebcff8ba263..10875ea1065e 100644
--- a/arch/riscv/mm/cacheflush.c
+++ b/arch/riscv/mm/cacheflush.c
@@ -10,10 +10,35 @@
 
 #include <asm/sbi.h>
 
+#ifdef CONFIG_M_MODE
+static void ipi_remote_fence_i(void *info)
+{
+	return local_flush_icache_all();
+}
+
+void flush_icache_all(void)
+{
+	on_each_cpu(ipi_remote_fence_i, NULL, 1);
+}
+
+static void flush_icache_cpumask(const cpumask_t *mask)
+{
+	on_each_cpu_mask(mask, ipi_remote_fence_i, NULL, 1);
+}
+#else /* CONFIG_M_MODE */
 void flush_icache_all(void)
 {
 	sbi_remote_fence_i(NULL);
 }
+static void flush_icache_cpumask(const cpumask_t *mask)
+{
+	cpumask_t hmask;
+
+	cpumask_clear(&hmask);
+	riscv_cpuid_to_hartid_mask(mask, &hmask);
+	sbi_remote_fence_i(hmask.bits);
+}
+#endif /* CONFIG_M_MODE */
 
 /*
  * Performs an icache flush for the given MM context.  RISC-V has no direct
@@ -28,7 +53,7 @@ void flush_icache_all(void)
 void flush_icache_mm(struct mm_struct *mm, bool local)
 {
 	unsigned int cpu;
-	cpumask_t others, hmask, *mask;
+	cpumask_t others, *mask;
 
 	preempt_disable();
 
@@ -47,9 +72,7 @@ void flush_icache_mm(struct mm_struct *mm, bool local)
 	cpumask_andnot(&others, mm_cpumask(mm), cpumask_of(cpu));
 	local |= cpumask_empty(&others);
 	if (mm != current->active_mm || !local) {
-		cpumask_clear(&hmask);
-		riscv_cpuid_to_hartid_mask(&others, &hmask);
-		sbi_remote_fence_i(hmask.bits);
+		flush_icache_cpumask(&others);
 	} else {
 		/*
 		 * It's assumed that at least one strongly ordered operation is
-- 
2.20.1

