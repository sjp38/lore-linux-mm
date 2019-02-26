Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0E49C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DFE621848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="mRdRp2Md"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DFE621848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6864E8E0008; Tue, 26 Feb 2019 12:22:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 598AF8E0003; Tue, 26 Feb 2019 12:22:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E8368E0008; Tue, 26 Feb 2019 12:22:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D41388E0003
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:22:48 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id t7so6495313wrw.8
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:22:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
        b=qXDrtvQjfWA5a2f4ZkpNzDmVZ1g1SwJhAniNijhrfL5GKwbiQPP+vMGhmJgE3cJCBA
         UsNiDnI9rVxEu+DdxmWaTvxdkHtiRAmGUO6qlNDXuqM1P7IPfrgXeOw2kbYMLUfCWDGb
         NiRV8nFv6LIAbfKl2QLMAqtNEgPC0240TosfqhjsC9z/5tAeqoeK2Rl/Cdi8twRn8cmm
         duueDkK+zqwSACpQNAHhxf82KQZGYfZ5+WI4EDA3Q2YoDmUrSj/T/QpMy8iupEO71jGd
         IC1nVzktDyX4K0eLN3G2ZERaWWWjE3BYtIBn6iuUlGj9STo6sAw5WUo4iTBwXAQUEtsN
         qPsg==
X-Gm-Message-State: AHQUAua8Vut/f2hZbL0jFV+0GHkkCf/lVvkh0orLK0jK1Wd67q/l9Qqx
	mKfY4t2OR0JAWKyg+UUSUJ5r1TSgcJ0Ah2iWhNqkSeUKVZbKfeIWdpZ+FMpabphWHceRY1RxQwP
	N7I+a0dwjppFgMReBcFNsJPfXEvdYW4QBHrwuaTSiNA4a+GzA/UYbqa6ZMMxW7FP/yQ==
X-Received: by 2002:a1c:47:: with SMTP id 68mr3220313wma.89.1551201768396;
        Tue, 26 Feb 2019 09:22:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaKRMfbxTfuLYQmkYSMPwDvoh7+8E1HDBvfAZcdm7U+FaFS4NJz0jv/4VwMNwZ6xiTkySSR
X-Received: by 2002:a1c:47:: with SMTP id 68mr3220261wma.89.1551201767329;
        Tue, 26 Feb 2019 09:22:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201767; cv=none;
        d=google.com; s=arc-20160816;
        b=ad16yKJmschM3qp4IZe8cPJVh7yHF7Nh+5OZCjrXSiO8T38yyW3BS7tO97yNZH1cS5
         RzLGcuM8a8xoY/voYZ0cEac9n4QFaTMw37d47pQS7t1EBTXUcLz1jtTlNZVfZs2eECTX
         EZLwXBb1bvtvSftOJFgvNNv3dGC5B5EULrDAL0TedrUC2QVQmiRoTD4Mck0Fj8ajJqwc
         WmBF5rGW/p3pNmwb3qIq8RolHWx9ydUmJwMnIgWXxR/42TRBtTwe3ztNqlxnoOR8ZgDB
         UMdid7MjqUpbljbruEsjtqSxUAgXCWyPh0zMQr7kbDVj/9nsO9EcwKsmbQi7iypowI8O
         raHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
        b=tEYpWJcF0YM2+MfuP6ASPdxr3mdfnG+vyZE1zq6TE1ELHLzz5+7xOpxnzo+gB4C+tz
         ICk+4L2am7s8e8hflP6zaKdTUW33j5Zv+yZTrkzV8NkmsHattmxrISL7nuwdNMY7cKO0
         LqqHGDG/CcoE+Peu6VJM99RFN9BG7T8EAOSPjLkPa2eavlwnElvN7AcEWeSZe5EFfCOh
         7Sxi3LsFzxOg+hCj0sMMgwq3wgjZTZ3n9yNwzJAOPhxhT5C+4IeIdpDIWeEGUQE5MjGK
         x8ixVmFo6938N44KuAQtE7O9E5AICJlS6VZqyhCkVln8AdXkYlt/XtT68CRNvc/Hy3tL
         JHvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=mRdRp2Md;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id h19si7411725wme.135.2019.02.26.09.22.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:22:47 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=mRdRp2Md;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4485H91FHmz9vJLg;
	Tue, 26 Feb 2019 18:22:45 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=mRdRp2Md; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id wa7NW71wC-7A; Tue, 26 Feb 2019 18:22:45 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4485H904tZz9vJLY;
	Tue, 26 Feb 2019 18:22:45 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551201765; bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=mRdRp2MdqDKy+WcWi0yf/hvgeunwSNaUNZRmJXDfhiptnSXfjnhPQlxjOufdkz95F
	 vXE+KzumvvSQSWGXsC65s/KS4xrg4UgiqBsMiU3Uk9SMp8doRCpGTtj1KdnBDZPkhy
	 RDiHK8KyftY40FwP1do3dfd6tUfQxPSR2z3WfXA4=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A47F08B97A;
	Tue, 26 Feb 2019 18:22:46 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id IgOg4aQV0MSY; Tue, 26 Feb 2019 18:22:46 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 741138B96A;
	Tue, 26 Feb 2019 18:22:46 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 52C196F7B5; Tue, 26 Feb 2019 17:22:46 +0000 (UTC)
Message-Id: <b8350c1e9ce7f47ddeb0f85a0fdeb3020e55a3a5.1551161392.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551161392.git.christophe.leroy@c-s.fr>
References: <cover.1551161392.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v8 05/11] powerpc/32: use memset() instead of memset_io() to
 zero BSS
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 26 Feb 2019 17:22:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit 400c47d81ca38 ("powerpc32: memset: only use dcbz once cache is
enabled"), memset() can be used before activation of the cache,
so no need to use memset_io() for zeroing the BSS.

Acked-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/early_32.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/kernel/early_32.c b/arch/powerpc/kernel/early_32.c
index cf3cdd81dc47..3482118ffe76 100644
--- a/arch/powerpc/kernel/early_32.c
+++ b/arch/powerpc/kernel/early_32.c
@@ -21,8 +21,8 @@ notrace unsigned long __init early_init(unsigned long dt_ptr)
 {
 	unsigned long offset = reloc_offset();
 
-	/* First zero the BSS -- use memset_io, some platforms don't have caches on yet */
-	memset_io((void __iomem *)PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
+	/* First zero the BSS */
+	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
 
 	/*
 	 * Identify the CPU type and fix up code sections
-- 
2.13.3

