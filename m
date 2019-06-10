Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59D1FC43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1043E208E3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:17:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HYzdqScq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1043E208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 763256B0278; Mon, 10 Jun 2019 18:17:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 714FA6B0279; Mon, 10 Jun 2019 18:17:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 518796B027A; Mon, 10 Jun 2019 18:17:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDD46B0278
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:17:04 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c17so8113861pfb.21
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:17:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QKrZKqm9xX7/gKntli3kjDV0bZW8VwVWFoBUswi6ZbI=;
        b=TRWqJHyzci54wVRYeI4/n/GEBmhdDqOHDiNuM8hgTWoWZjq6C198Vb5+jsUnZNZXWL
         JtQmXOg5pd/0HLUmxYj5JSUjUgJ04nzf+QajpqoAWfBTrME1mod8eF6XRSN6K4zj3754
         eTlfNyaFBRkWumIEQ0HMlA1oZaVook0RMTbKpj1bGiPNHMxdDjoZljzHcejXiLcgU7nN
         xzXigsUNca8IMm2xaujA4RTeEXa+NnhcpR10IQMz33H/K/Lz40P9yJsRLIXMKFx0RJpc
         TzspXLRXPD71U4Ly7qStkvlcI4xa+NC8wqi5rTV6/zSP4I6/GyUReEL7ZmKDtv1/G3Lx
         /2Sw==
X-Gm-Message-State: APjAAAV7vaxeRPnRa+JaqRckGpGz4hXDmiIxVJ5uO82t/AZ7a5rJ0Oqg
	J/lxmlhaO08V/gs0xs14GmpA+Rzdkt7S7YVTEVjKhWaTHe9VlZx66emvdlr5g3FBm7Y/JoI3gfy
	/f+SZWotLLLe559fMqIsQzWcWKYsAMyctOrJvQ3GUZyF9DS2VaV/sZuUV+ezckYA=
X-Received: by 2002:a62:cf07:: with SMTP id b7mr18915459pfg.217.1560205023722;
        Mon, 10 Jun 2019 15:17:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzK8MHzHJ3EctbOd8b0fnEQJApOnhFVC1bLhib35gCt4RrnsU/sVTgY1J1xTxW3Fk2zu86q
X-Received: by 2002:a62:cf07:: with SMTP id b7mr18915381pfg.217.1560205022949;
        Mon, 10 Jun 2019 15:17:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560205022; cv=none;
        d=google.com; s=arc-20160816;
        b=rtcpb3CWl5EF4zvqoePRwlJUOWk4uuHA/pSVkq7PSo3VRjfVmi5zc/7Pa/GMLqxdhl
         DtqsB0J069mbNqxveoigjI/qF8n+rq8lUzfKZoDhr0ailNW/wSmCO9sYpZz7cQk0wywU
         E82nTKJ1okO4RfKBBwkMGOUpeJfGJ4ypfP0VGtCiCMa9YYZ1bNOe5RFCum5BB6bU3QmF
         qfiAIRwOwbdPqtLm9s/fMWv6LfYiIDGSlEJlM252lkY3HlPmAHUU6bpUZFXNvQ/cb5ZK
         +xlnwQj8sQN2OAi8mxtMP2+qV/OPrkWS639V8liXPI9LFVcIqeTR4KAlv9Eubj6sAzyS
         U2cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QKrZKqm9xX7/gKntli3kjDV0bZW8VwVWFoBUswi6ZbI=;
        b=YIkkhgvEnMqtfuRiQZQIzwlqFkWelEZjQrhgqF2pTBUszG325Ai03OlR3opGI7hzmm
         h/SBU7Om8Si9MsSBhPK1bqT8J5epXDae1LLUn3zy50IjLR02OMg7HEuZvGEIHwtrYsdR
         UWDGSei0nO0vIPkudgMRiw6t0AcsX0Rm0XenLLBfKge0v9jvyaSuxcPvp0bflz9o26uu
         3ziCEx66C8mFBxRoXjM1tJ7gmw3P7efSiTrX/j0mhXOhrqsvKlzyMYExIFwWVDEwsIkp
         ZrVaoTXMCudGbcHkJwZSbhAT7EUHzQ5nWfx8IT/TbuG8g8Az/+p8VAnduKiOce4/dfgG
         naaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HYzdqScq;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y14si10121101plp.242.2019.06.10.15.17.02
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:17:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HYzdqScq;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=QKrZKqm9xX7/gKntli3kjDV0bZW8VwVWFoBUswi6ZbI=; b=HYzdqScqmkY7UiWle5zIbeTQxB
	xAaMr/ZfGK4+A4BsJ5aOUoSPqE28fsB+yMZOlybdB1UXrqELmw+bYb4UkDygioEZJLyLXzSwu5b9T
	RR3p1S0mfl5j4HUD5uC7CVBybbIA70S1ijnk2verWrm7Kv+GloqVOyxM0s6R8ttKoZ5gVXgqe+0GW
	G8CVSJ8/f8L3eNpcK7/RXE+2tTBTpjjHMSHnXuvHBrLtpcjJ3j0GVBhVwxnb2HU3xQpytpJg5wQ7i
	AgQEsDxj3AVOp2HN3Mx75AHv9Ot77lIpZcF79Vptpno7EtiUhExdJ63JzCYn/We9DAD4KLv90G55B
	M8X8Gapw==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSb4-0003fy-NB; Mon, 10 Jun 2019 22:16:59 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 13/17] riscv: implement remote sfence.i natively for M-mode
Date: Tue, 11 Jun 2019 00:16:17 +0200
Message-Id: <20190610221621.10938-14-hch@lst.de>
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

