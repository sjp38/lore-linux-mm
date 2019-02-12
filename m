Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 514D8C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:36:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BFA12184A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:36:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="HaMHkhYR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BFA12184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 383488E0013; Tue, 12 Feb 2019 08:36:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 333A08E0011; Tue, 12 Feb 2019 08:36:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 160ED8E0013; Tue, 12 Feb 2019 08:36:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B24A88E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:36:54 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id b8so1013327wru.10
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:36:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=um9yCYwOJ1SkZMPifhMErWXIPjN8RMbQWLCsWKAg55E=;
        b=ih4SsfgJ74rk4h863KVOAQ2eTqLDvaYpJqrm3j/Kovp6+FWcWGKcB/VdUXUq9xQUna
         BigqnCKoro6kR+uWBN6XJ7bOgBQjQ3Ez9TakkUO0o/2i4YNgNutXsmomji+9C79EanhC
         NhwRiHXDNazISuInZHnDUnaR8RcZsHchaYUI5xJ6xqD528ceYRUYZoin4okC7bsG7s6v
         NefhCOhVbjUMIHS+4Sv3p2+qTksUMDwvUSx2Zfe0oFoGqaBbe4A/6YKzHSy/eYv496BA
         JOUm8y12hkFqKkxIwgw1G20MZcmwNjqn1adS/5ExtCL7Bsg/PSDiAG09lftHcmiaAdjJ
         f5sA==
X-Gm-Message-State: AHQUAuZS3eWU9VnzsyCX4DZbFhCtSb70VZeQKHwjTHxCXumoAiuFZyU+
	b+329yEEQ3ziFYXZ2tcg2Fn5yBAv/q5hihTUIHy5pFxoJpw5Ds/TH1T9z2pQkInLX3DaWdNo2vR
	uTUJEp3sFzID5rUWgrB1LFZwo4XWRh0AA+jQRABGtfre99LE+Tndkpg1flSxqtvVyfg==
X-Received: by 2002:adf:ee8e:: with SMTP id b14mr2868016wro.71.1549978614245;
        Tue, 12 Feb 2019 05:36:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IakKs/LPb1/5fPWZlLmlD7LaJFyKbhs4O5PbnYhPqbrb8ST+0wlKaZHuva0BoZGuRveXPJH
X-Received: by 2002:adf:ee8e:: with SMTP id b14mr2867967wro.71.1549978613312;
        Tue, 12 Feb 2019 05:36:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549978613; cv=none;
        d=google.com; s=arc-20160816;
        b=PQaFVbHz+m7x8cP/ot0TkXmj5CNlbXLqwSdgRs253wtD5H2m9kXfmjUlgLSmr1UwNG
         1/hWr1J+7dxv247dDfYSB1vXO+OMu4nA70RvxogMr6slaH047SVSiCJwmc42igHUzTZd
         CRXh+xKak9NrK+zr7kuuon1uCLR5v8HQ1sHEnvjSCrXt8E2zQYYKZqqPjZeTJhIIRok+
         UIl1rDZDw5kSog+JCNFUxpQ+Dan74S/bFVO8BeJHyf2gctPsjN2JLHhygxf5ViGoZIp1
         cjoratdp2Xowzjx9gOlUy7QRCFdrSDoB4vjtX1AyOEPxMc7gISa5I3xkGQh1T1Rbj/bf
         u/hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=um9yCYwOJ1SkZMPifhMErWXIPjN8RMbQWLCsWKAg55E=;
        b=dbXgBTeSguQly1BvnSJD3UW2JuKhhn+53V1XABqSc1M07NK6mvBT9zYM4Iz4DCylMe
         PWJhj72yhZBtMv7P9l/9sB7uH4Snen5htpvz4g043dfCcjCKBqDhW6Jl+y7z6wi7gF2o
         meT+di3Oadh5IkPLp4t6AkNpiWTaW+6nh5qoHqH2ZsuWh3fGyLvwKR62ck+Nt0yn4lfF
         41VF8O/FZckfZBFNgPlNCxyt9LB4n5vLbwiCsBubKj26LjRA1HEplDH9QWi8pjWW3yew
         Tq9RGyOxWt+RrVKtteNnwD22oAFgIIZLm/EsTT05srHCeN60BFIZ9pZhYNGfMzL7wJ9R
         RxTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=HaMHkhYR;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id f15si1368243wrh.240.2019.02.12.05.36.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 05:36:53 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=HaMHkhYR;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43zNwz2k9qz9v1GC;
	Tue, 12 Feb 2019 14:36:51 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=HaMHkhYR; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id YAWdEZZZY065; Tue, 12 Feb 2019 14:36:51 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43zNwz1czTz9v1G9;
	Tue, 12 Feb 2019 14:36:51 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1549978611; bh=um9yCYwOJ1SkZMPifhMErWXIPjN8RMbQWLCsWKAg55E=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=HaMHkhYRpvv8PNS5nTJcvoPiEbwzUkYtZ1YJlQeRsrZ3caNGnSuRwaY0LJYuOAXzE
	 2FciwvVub4kOTbakUEBzhWbnbVv1D8kMEEz5M8nbt2EuXy5ZGn5XOpWm7Tid9gY4Sc
	 Y6S912uMyzP0QFiNDp+PCzx0Z5XA74jBEhehEzas=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 93DF08B7F9;
	Tue, 12 Feb 2019 14:36:52 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id XzRvIDk9t5pI; Tue, 12 Feb 2019 14:36:52 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 5FB3D8B7EB;
	Tue, 12 Feb 2019 14:36:52 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 4A7196899C; Tue, 12 Feb 2019 13:36:52 +0000 (UTC)
Message-Id: <4c121392c84d696738798e118f2c52192e2c792e.1549935250.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1549935247.git.christophe.leroy@c-s.fr>
References: <cover.1549935247.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v5 1/3] powerpc/mm: prepare kernel for KAsan on PPC32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Feb 2019 13:36:52 +0000 (UTC)
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

