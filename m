Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B83D8C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 07:16:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 672C9218A6
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 07:16:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="ClaBu1v6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 672C9218A6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12C998E0007; Wed, 31 Jul 2019 03:16:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08FF08E0001; Wed, 31 Jul 2019 03:16:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4ACE8E0007; Wed, 31 Jul 2019 03:16:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC2B98E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 03:16:10 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id j12so36919590pll.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 00:16:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UahEbtdXwZNAU+KwZPeJAGjgE2lYz0Dt6XczqvKwLUQ=;
        b=TqqdM4WM924SZEIXNxrBHcLq8oXZpcXZsqCO3pc3dXWqs5IXalW7Zx0wGuFcD0mWhg
         YsBUW4g4+TIzyug3SYtGhBv4Vwxsk8vez8aFX8gP2mwAc2IG8brIdrfwTm0poTTgYifW
         gMZf+Cdqkpk/SZ7N1ULcUTfpTjzU25bdsxB1uaxMTWBLPbyFCoyiiHiCvDM4u30oEVq+
         tRwmuqaCYmMhV/dr9vlbTNqJEQAxJ7fdPGLzHfuIgp7u7SlZeU5GIhcSsSCNNQMliqfH
         LcvCfYgj4/RGgewZZfurzy+yifVp4xFEu8HAuKJBuEtnJ3S0aVn2NFW9tDNV+yL+0hlH
         xoBg==
X-Gm-Message-State: APjAAAUtyQwaqp8Eh666aYkm5B/KmChpW7OCHJwtbKHRfyEkjtK7FinS
	+Vq6JZf7YVVJm6AupSKkgA4QT+f7wSSi7WI/UmNUVh+gmBj4Va06NKSy4D2pqC3rQzB3Jiho9UR
	yqWugVelWTebduRTjNg6HofdgTBL23h4tLk45xxul+ftMdKt4ESlNj4dRJtgUFQ/yNg==
X-Received: by 2002:a17:902:549:: with SMTP id 67mr118544521plf.86.1564557370369;
        Wed, 31 Jul 2019 00:16:10 -0700 (PDT)
X-Received: by 2002:a17:902:549:: with SMTP id 67mr118544446plf.86.1564557369159;
        Wed, 31 Jul 2019 00:16:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564557369; cv=none;
        d=google.com; s=arc-20160816;
        b=VqOrJrLQCFdyLsLhHqhWqD7cg7IZRbC0xvgpJW/4ksgvRpw6HXPEvzJg1T30MtdAj4
         ZTHxCXlsyLIxiWFYEbb3SpZeY7dsg2AKuWgUnVAazjXJqpRtrXvxhvZffbM5tfHYPNDs
         In56PUyWlW+/yn2i949oqP4/WAuu3LfLiekEfHvtUH3viXq86R5IGOHbwBZWgoBCWv4V
         z9UoH4yCFrTouvCaJKXeZPcpdXLxQOM4t0iMzG4T1O5kZ92UEkmZ8W4wbiV/aqgpHRXO
         LxnORV/+tHk/c7/rZO+nqT/WdIHFCkUYCjgcgFEf/MpZgMhENTNXOXDcRG8vlhJeNHtz
         EqIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UahEbtdXwZNAU+KwZPeJAGjgE2lYz0Dt6XczqvKwLUQ=;
        b=fQaRWDqJ06NWW2VvqJ4R7CJdvjV2O7R95g3c2N0DeadTAXXsqw8GCShFGr1Cv1ft2C
         4El0rNW/EvAj1eU8Cb/cOrFoumexLIjXyDWpbAjrgjZZXCD5h8OpkIUNeiIRvIiP7n4t
         jKCpddbHPJaQCMcNghyT+ROwQhe7r5H9eWhmHPQIK9iQYASYD9Yp0HU5VaJzTeDiJEDC
         X50eDKSY9Up/QvfXVL7/JuazPlPdJrS31+Uxav9qgkPa/awduaPTrqtY7celUyG/lN5k
         lPbxld8kY4mnKY1IPWS9K1twG4XkolBoD2+DD0orchUMqC344vZcVaZofC/E/RtROGIx
         Gu/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=ClaBu1v6;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor44345832pgp.54.2019.07.31.00.16.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 00:16:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=ClaBu1v6;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UahEbtdXwZNAU+KwZPeJAGjgE2lYz0Dt6XczqvKwLUQ=;
        b=ClaBu1v6WJ4WtUuG4BiRwFve0q7yeVjT3ieM+Bmxe0M/RaaIqHw2L2kaStQrsQQxvm
         SFh9kyie4gCs8EuO+wJTMeMSxCVDiM43VRfcY1z1mY4NGrA1ObPdQYQUQRETS8V9bGJZ
         4s/nbwxEGP4iyHoPO4NUWgW+BhSG8jTSAFgzY=
X-Google-Smtp-Source: APXvYqzREZaoD42yk5RfPOCAOs282MqhtyUaNihf4MOdto/t4vS1Yi0RCP7Z1XYHxt7MnHtN/9LsEQ==
X-Received: by 2002:a63:fd57:: with SMTP id m23mr47211876pgj.204.1564557368818;
        Wed, 31 Jul 2019 00:16:08 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id i14sm104075707pfk.0.2019.07.31.00.16.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 00:16:08 -0700 (PDT)
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
Subject: [PATCH v3 3/3] x86/kasan: support KASAN_VMALLOC
Date: Wed, 31 Jul 2019 17:15:50 +1000
Message-Id: <20190731071550.31814-4-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731071550.31814-1-dja@axtens.net>
References: <20190731071550.31814-1-dja@axtens.net>
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

