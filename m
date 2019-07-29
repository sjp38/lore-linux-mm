Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3E5FC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:21:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 607B3217D4
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:21:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="fzL9e9NG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 607B3217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F135D8E0008; Mon, 29 Jul 2019 10:21:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC3478E0002; Mon, 29 Jul 2019 10:21:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB21E8E0008; Mon, 29 Jul 2019 10:21:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A66EE8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:21:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e25so38600831pfn.5
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:21:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UahEbtdXwZNAU+KwZPeJAGjgE2lYz0Dt6XczqvKwLUQ=;
        b=Ah4T/QcQu7v0H/kxiWOz65Csl3Vr5DKsu5ghXMSbEcTIs3GMOYBa1KLpneX9Pgks94
         zGh9F7J2T2NAE7kZm2jmtWRqhlzyEPkiAMbNWbkwN3Pi/ZwxnPRMvOx9+jrB1p4qmNTG
         Res9c2Viyeqf1OxMcqFemqLxlFKNsvtCtku8nmQNkEHx39vTW2DdOoEZ98pzJNeZDM3h
         kIeNkqZBMGah1m4GhwwjlQTVhTAadbWsX7hvneiB7r5oZiq8jXKQSKvsRCciXMC/2lG+
         or/ZcVmBrZ+gfsVi+bopk0pp2Gl8SsJD/wH/FCQMe/48iH87hrPi/+FMukLdxtXDzqhp
         b5fg==
X-Gm-Message-State: APjAAAVk0KNE5NNDPWYMYBg0E0LXg2pyHZMIHOYzDyhO+EyQkjExJ+pn
	4ppafNc9GXWpj25UlMS+T01D6Z8fNTkbwDCbRpXxad9lgxF2Uxj1EZ7jEEm1ApQw51G/2gSU94t
	DJhLW9Gh4D4jxvf5W5R7Lkb/ZsvV836ROU3HpwPInWTy+1ZQCyTwkum1AWaGGyvxlGw==
X-Received: by 2002:a17:902:968d:: with SMTP id n13mr63179961plp.257.1564410091348;
        Mon, 29 Jul 2019 07:21:31 -0700 (PDT)
X-Received: by 2002:a17:902:968d:: with SMTP id n13mr63179903plp.257.1564410090499;
        Mon, 29 Jul 2019 07:21:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410090; cv=none;
        d=google.com; s=arc-20160816;
        b=QRKlZp2JcyOE+dAfCgvg1tHxwc98pyh1FVcBSmiXBbktSnqs2EuVobGYvv8QtzoKin
         43zs6abyCyheHDmIAKuremyPrxdzaAFBATRv99jgGTjLYYVXJK5LnQ8zf3+AsFMhWeWc
         vGXE8jtEUQmi6MZJ738fHsiVFUSWcsoOnljfH4CP/36xJPeUoC7wCHrbut+IPzSalGVg
         1a7KpmcrcApv3fvSj6c3VF7W9VeRSzs/SoJoBPgA+EYAf2ykSJ+YlPGc8Cw+cbw8Bi/H
         bO5VVAtZp+UJ7pFJu6dwbX5ol9EDwquBtz8UTp5SmGt9U2tIdaw5pNZKHtmb9zqNc7hT
         6ICg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UahEbtdXwZNAU+KwZPeJAGjgE2lYz0Dt6XczqvKwLUQ=;
        b=gR7xirBoGajf2YJ7pRkwyhjZma8wzARksbsFnhnEybO6l8QR8VvgD3s9Rwje0RR/cY
         HkyRPeCLNI86eOLwlUaHFduv8KOyZRNCPFXQDj0dt4bAGLbKwi9XUBToaPXobysVN81d
         /a8u3oTA+5l7BnUNS4EfzHlSPSWwuSoyUzScLwQuXJbYAHn2dCeAYQWA68ZHXpojBWMN
         UGJ3wDKGY1yMBcqZ8ZnsiVeZZxtcaYQ4iHyJ2XbiPNS/0IAeG895DMHza3tNx65UfJrw
         wL2ANl8rFczpj3BLbicUIFM5vtLfenTxCXZocz16oZb7VZ6ammCIwOhbJ1RqviMz3Lnn
         WrIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=fzL9e9NG;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n3sor28700942pgn.56.2019.07.29.07.21.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 07:21:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=fzL9e9NG;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UahEbtdXwZNAU+KwZPeJAGjgE2lYz0Dt6XczqvKwLUQ=;
        b=fzL9e9NGg4Qjr2J3UpWztGNQR57AulF/3UQEiR1a9Md80VZwZTIn9TRRubWlaS/Hl4
         LOCeBjBaUrIgk2w0oLdXnYFC/x89KdBH/EUp4SGo0wf7qML0Q1zbmstYKKVoAfXixnvH
         1UwH3wAFUDqMh2FnvB0ouTVLkQFq2ybEtsObY=
X-Google-Smtp-Source: APXvYqzsTWziV3uGfQSZhld3lbCm5Hl80o2+zdoas9rkn9wivbK+frNOV0FOh9c9mgtrfH4egyHamQ==
X-Received: by 2002:a63:2026:: with SMTP id g38mr98776818pgg.172.1564410090185;
        Mon, 29 Jul 2019 07:21:30 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id s66sm65997285pfs.8.2019.07.29.07.21.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:21:29 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	linux-kernel@vger.kernel.org,
	mark.rutland@arm.com,
	dvyukov@google.com
Cc: Daniel Axtens <dja@axtens.net>
Subject: [PATCH v2 3/3] x86/kasan: support KASAN_VMALLOC
Date: Tue, 30 Jul 2019 00:21:08 +1000
Message-Id: <20190729142108.23343-4-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190729142108.23343-1-dja@axtens.net>
References: <20190729142108.23343-1-dja@axtens.net>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the case where KASAN directly allocates memory to back vmalloc
space, don't map the early shadow page over it.

We prepopulate pgds/p4ds for the range that would otherwise be empty.
This is required to get it synced to hardware on boot, allowing the
lower levels of the page tables to be filled dynamically.

Acked-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Daniel Axtens <dja@axtens.net>

---

v2: move from faulting in shadow pgds to prepopulating
---
 arch/x86/Kconfig            |  1 +
 arch/x86/mm/kasan_init_64.c | 61 +++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 222855cc0158..40562cc3771f 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -134,6 +134,7 @@ config X86
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_JUMP_LABEL_RELATIVE
 	select HAVE_ARCH_KASAN			if X86_64
+	select HAVE_ARCH_KASAN_VMALLOC		if X86_64
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS		if MMU
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if MMU && COMPAT
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 296da58f3013..2f57c4ddff61 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -245,6 +245,52 @@ static void __init kasan_map_early_shadow(pgd_t *pgd)
 	} while (pgd++, addr = next, addr != end);
 }
 
+static void __init kasan_shallow_populate_p4ds(pgd_t *pgd,
+		unsigned long addr,
+		unsigned long end,
+		int nid)
+{
+	p4d_t *p4d;
+	unsigned long next;
+	void *p;
+
+	p4d = p4d_offset(pgd, addr);
+	do {
+		next = p4d_addr_end(addr, end);
+
+		if (p4d_none(*p4d)) {
+			p = early_alloc(PAGE_SIZE, nid, true);
+			p4d_populate(&init_mm, p4d, p);
+		}
+	} while (p4d++, addr = next, addr != end);
+}
+
+static void __init kasan_shallow_populate_pgds(void *start, void *end)
+{
+	unsigned long addr, next;
+	pgd_t *pgd;
+	void *p;
+	int nid = early_pfn_to_nid((unsigned long)start);
+
+	addr = (unsigned long)start;
+	pgd = pgd_offset_k(addr);
+	do {
+		next = pgd_addr_end(addr, (unsigned long)end);
+
+		if (pgd_none(*pgd)) {
+			p = early_alloc(PAGE_SIZE, nid, true);
+			pgd_populate(&init_mm, pgd, p);
+		}
+
+		/*
+		 * we need to populate p4ds to be synced when running in
+		 * four level mode - see sync_global_pgds_l4()
+		 */
+		kasan_shallow_populate_p4ds(pgd, addr, next, nid);
+	} while (pgd++, addr = next, addr != (unsigned long)end);
+}
+
+
 #ifdef CONFIG_KASAN_INLINE
 static int kasan_die_handler(struct notifier_block *self,
 			     unsigned long val,
@@ -352,9 +398,24 @@ void __init kasan_init(void)
 	shadow_cpu_entry_end = (void *)round_up(
 			(unsigned long)shadow_cpu_entry_end, PAGE_SIZE);
 
+	/*
+	 * If we're in full vmalloc mode, don't back vmalloc space with early
+	 * shadow pages. Instead, prepopulate pgds/p4ds so they are synced to
+	 * the global table and we can populate the lower levels on demand.
+	 */
+#ifdef CONFIG_KASAN_VMALLOC
+	kasan_shallow_populate_pgds(
+		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
+		kasan_mem_to_shadow((void *)VMALLOC_END));
+
+	kasan_populate_early_shadow(
+		kasan_mem_to_shadow((void *)VMALLOC_END + 1),
+		shadow_cpu_entry_begin);
+#else
 	kasan_populate_early_shadow(
 		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
 		shadow_cpu_entry_begin);
+#endif
 
 	kasan_populate_shadow((unsigned long)shadow_cpu_entry_begin,
 			      (unsigned long)shadow_cpu_entry_end, 0);
-- 
2.20.1

