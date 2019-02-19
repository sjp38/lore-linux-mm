Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23128C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA9922083B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="UKna5p+M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA9922083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55F888E0004; Tue, 19 Feb 2019 12:23:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 449908E0002; Tue, 19 Feb 2019 12:23:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EB1C8E0004; Tue, 19 Feb 2019 12:23:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id C79328E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:23:10 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id z13so5878922wrp.5
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:23:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=um9yCYwOJ1SkZMPifhMErWXIPjN8RMbQWLCsWKAg55E=;
        b=qWXSir8PMxQu3g3ABVOUEUvFpQRihSKklEApuzGEVTqW+y8WA7e1nVClDnhYGc8gwl
         +PXH8utP3nOtDoCGKK/fX9y7zXQGJjvITAPh5z46keoc1dqrWXwvK6RXC2c4j6JbQduA
         CZCcAz8/V0Dfox8ztOf4YM6SQjbcjQHut8mLnVObFPW3eIlJ556YQX8g/CNplJFpQ+YN
         V2/QyebhtchOUbpwOeMbxVnoB9viM+dVpw8nnJm6ghF6nI1QMM7PejtzOinD9KnfXx/Y
         Pm7QeRsxxlqAIkBzoKiw2hcihofTKB1QGNpR6Fy8wDozKKH+gcSWKiM2xa4srcJDYOr6
         1lwg==
X-Gm-Message-State: AHQUAuZdiVu4rt365wgt7qR/95y3k5FHzLBghgjuZLJ2AK2s0tdj9cdH
	yKTd/ccD9oiRK3eR74yVTouT02cIP8cAcwLjjvFQ43sWWZ4AudUQEx3MlKx67FWWhNHx4Mh+rn+
	lD+fyHOFHkq+ZvdfE3TpmY3csWRhOqTQJkkOw+p3n19gE1UZ1YxfBf7gEXYQMGYN1ww==
X-Received: by 2002:adf:9e47:: with SMTP id v7mr22268427wre.190.1550596990241;
        Tue, 19 Feb 2019 09:23:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IazzgEvSUQEtY7LL46gmQUoogRfF5jgplawqya5gu175ymsrKzul6qQ2riltZxGuOx0kTIW
X-Received: by 2002:adf:9e47:: with SMTP id v7mr22268384wre.190.1550596989306;
        Tue, 19 Feb 2019 09:23:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550596989; cv=none;
        d=google.com; s=arc-20160816;
        b=L2YqYRCKHdo83p0YIjvZe2qvNa/cwqXT2bMtRWhhve2w6AZ2cDDfthevYTI/fVCG85
         04/cAHrYGkW4WFw+MsnmS9hkguYxGfJrzbhEicjrfhKbHs6zfwydSUdifUFyqWGcjc3b
         RK4+nTyuWsXvH7xMSBdcKpZpikPMZSGzcJ997ZValbf07ojQnu+EvL/pYXd6PY2DxjQL
         V4wbpUFQ0BqPMAR8WJAunPXyjeG1v+OodLs05GRLcw7j4H9NbByF5TKqQ4xbjIjyB9l1
         +arHSUl6ljxVxXXQd9suwq6jcT86wLM6+0feytu8pH3cPECGRQ6eglOWL9v4xs7iWK6R
         anjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=um9yCYwOJ1SkZMPifhMErWXIPjN8RMbQWLCsWKAg55E=;
        b=Gls+37nI60yPOhjpz0jS/xoECsde8o3bs+yHVqU4cgRzdKUe2CDoBKYQQBFYkyC3fd
         Lc+gcMHOd0xFtTHVy+/xzy2cEyj2W53fmBD++dd6bDrBzvd4c6CZPNEUgYn/TqxE0r1h
         pUFEFqdaK5IMN5BqlvNPgqd+6dWxhQ0zvJwZ4vVhNxqMSu7x2nGluW3AI+RccPlEm0Ke
         OwZjrvmAVGyC10FJ9DtH9tkoGmYBIuIhsmO/2dbG+zKhRP4YTG0lv14Lz2HHx5RGxb0n
         qViskzWNGSdfehk/3fw9qxqkmIjVSK20rur+X81o1/+DSVXEFBKJQibOtZT3t90bsNws
         Itsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=UKna5p+M;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id n2si1800876wmi.149.2019.02.19.09.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:23:09 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=UKna5p+M;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 443ncq1Y0Rz9v4wh;
	Tue, 19 Feb 2019 18:23:07 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=UKna5p+M; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 5pShGomqr3uf; Tue, 19 Feb 2019 18:23:07 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 443ncq0LHYz9v4wf;
	Tue, 19 Feb 2019 18:23:07 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1550596987; bh=um9yCYwOJ1SkZMPifhMErWXIPjN8RMbQWLCsWKAg55E=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=UKna5p+MS8RXPp9xPoQwFfi6FnUmsVZC46q+/SXqCjiHhfWDEHY1fuAfUl10D5Bi3
	 /vXvh22F8XGovC16LyB47MF2/KhQyk/BnG0e5z35tqtbvHneQuT0HodSwxFoGqFEk5
	 PFurz5vgUBLmY4XfyoQ2buu8m06OuGyP+zBA0uEE=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A77F78B7FE;
	Tue, 19 Feb 2019 18:23:08 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id XNx_RUqqrE9o; Tue, 19 Feb 2019 18:23:08 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 743128B7F9;
	Tue, 19 Feb 2019 18:23:08 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5715C6E81D; Tue, 19 Feb 2019 17:23:08 +0000 (UTC)
Message-Id: <906bdd0dde64a05b7a1d399ee57a0c3a34a094b8.1550596242.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1550596242.git.christophe.leroy@c-s.fr>
References: <cover.1550596242.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v6 1/6] powerpc/mm: prepare kernel for KAsan on PPC32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 19 Feb 2019 17:23:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In kernel/cputable.c, explicitly use memcpy() in order
to allow GCC to replace it with __memcpy() when KASAN is
selected.

Since commit 400c47d81ca38 ("powerpc32: memset: only use dcbz once cache is
enabled"), memset() can be used before activation of the cache,
so no need to use memset_io() for zeroing the BSS.

Acked-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/cputable.c | 13 ++++++++++---
 arch/powerpc/kernel/setup_32.c |  6 ++----
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/kernel/cputable.c b/arch/powerpc/kernel/cputable.c
index 1eab54bc6ee9..cd12f362b61f 100644
--- a/arch/powerpc/kernel/cputable.c
+++ b/arch/powerpc/kernel/cputable.c
@@ -2147,7 +2147,11 @@ void __init set_cur_cpu_spec(struct cpu_spec *s)
 	struct cpu_spec *t = &the_cpu_spec;
 
 	t = PTRRELOC(t);
-	*t = *s;
+	/*
+	 * use memcpy() instead of *t = *s so that GCC replaces it
+	 * by __memcpy() when KASAN is active
+	 */
+	memcpy(t, s, sizeof(*t));
 
 	*PTRRELOC(&cur_cpu_spec) = &the_cpu_spec;
 }
@@ -2161,8 +2165,11 @@ static struct cpu_spec * __init setup_cpu_spec(unsigned long offset,
 	t = PTRRELOC(t);
 	old = *t;
 
-	/* Copy everything, then do fixups */
-	*t = *s;
+	/*
+	 * Copy everything, then do fixups. Use memcpy() instead of *t = *s
+	 * so that GCC replaces it by __memcpy() when KASAN is active
+	 */
+	memcpy(t, s, sizeof(*t));
 
 	/*
 	 * If we are overriding a previous value derived from the real
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 947f904688b0..5e761eb16a6d 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -73,10 +73,8 @@ notrace unsigned long __init early_init(unsigned long dt_ptr)
 {
 	unsigned long offset = reloc_offset();
 
-	/* First zero the BSS -- use memset_io, some platforms don't have
-	 * caches on yet */
-	memset_io((void __iomem *)PTRRELOC(&__bss_start), 0,
-			__bss_stop - __bss_start);
+	/* First zero the BSS */
+	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
 
 	/*
 	 * Identify the CPU type and fix up code sections
-- 
2.13.3

