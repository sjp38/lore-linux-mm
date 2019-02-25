Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21156C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:48:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D134C20842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:48:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="UzkSBnS+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D134C20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B0318E0012; Mon, 25 Feb 2019 08:48:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1758C8E0155; Mon, 25 Feb 2019 08:48:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E62D28E0012; Mon, 25 Feb 2019 08:48:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC078E011F
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:48:41 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id m7so4841591wrn.15
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 05:48:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
        b=iLXoe++LpfSUvqcYYiqGhOwnt7UpGCD6RPQAh5w5AHX9Xu3PnSuRENyPMU72E0PDIx
         BS7wGidzPDE9b9F9bEYkkhA+Svfm4z+672XBSzOO0tXWenNIMOmX1F2bqiSqClt5XlHi
         Hh4dNVDtcXykl46u4tzWeBhVyGZvZgyucQYQn8bizDcFPm8BqszCvzjOziWP6wEZIr7d
         XpFMco4CJ9TbK7xhMVZ/6tvHdbTiH3Bl3QUXH318T6Vdgqj2nSEwnFocwv50AcqxIs/t
         DvWl+R0QN5miBM/eoRpk3XnM7A/UdGGPq+/4tFrczFvQ/DMd0LHavFJMLnPTF6+H7oJH
         7qtg==
X-Gm-Message-State: AHQUAuaf1HCqa5E45v854xwfvkMXs2cLUdoVrwkymWSU+RMw2uM6Lt6E
	y/1E/7Cd/4Yw8tnv9qLBrftkWb+gSJ1F2lhME3NlPhFR0zuhuvef2m9CcbheNd3SkwCIkqqAWgo
	USv5dbDZeQoE4MI90clH7xVH8FuJxjPptom3vCPZXrXBhfE0QnJ43OvWUKYsbbW+Czw==
X-Received: by 2002:adf:f011:: with SMTP id j17mr12880495wro.166.1551102521130;
        Mon, 25 Feb 2019 05:48:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia/lxx+1JeZzYUXryv+LuRY9lhpeV5tKekDH8xNUV1Ze5GEJb6QoPGhzxutGFcByuw2gHwr
X-Received: by 2002:adf:f011:: with SMTP id j17mr12880454wro.166.1551102520304;
        Mon, 25 Feb 2019 05:48:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551102520; cv=none;
        d=google.com; s=arc-20160816;
        b=B04W7NyISqOxRnCmyt+2spDAOKh4fMjTmrjBEAvOYyOWvxQ12/CCNfK/OnT2jDeoIn
         wZCIAsHNVbJ9N9ECW3ZKwgcd+LKDBQve2a37D/SzHk3OMgR/8tGTb4/hvzp7XeylddK4
         Bpg9TDusJTwLVSCIKee8t1MD6a/xsMzosvEAg4VD0RGJr6eOI3YrD3lMq2aGVB2yN+4G
         R0J3j4REI+8xyFCrzIVWtSauJrF+bTdhP4tcBw3UyVYyC1uFwcZf6h4QT6jtWKTtHlpv
         R+X1CTvMuMybjdLdG6pOFz/AvMbYYcOV7QCJWNs3DSIk1ckrmn8+gRW8rXnD+6XnF0XG
         0uuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
        b=AMXlIsp9bdrbt3bJfqQ0daVOTOAMlbE0sS2ZQB9htc3lkhuk35+rbR7uwGPZU+DbB8
         LfwnSt/EraQlR1Y2RvemhRK8B2azzOZvmt5AvRSP2c8knSyYGGNsaFU3XO+B1uxSojxW
         1BUm9mJSeTFQinvzRXlodqRUPNE7BvpGXCvOzgGKTq5uL+ORmhQ2maMpZ+anUsAl/hoY
         Ap/HM8Qg0r1GSJwltOx6tRp82UyWUIV9TTPplppSj1Gf1SFI3B6D4sALBtGAM8lbHskj
         WQbz2cn//4JRP78eTjHYJ/zDhoxN3hcXknKJSjRKMnhYsCwQU9fd9YD8i6dg84TFufla
         jftQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=UzkSBnS+;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id x67si6065194wmb.146.2019.02.25.05.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 05:48:40 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=UzkSBnS+;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 447NZV5z3wzB09Zv;
	Mon, 25 Feb 2019 14:48:34 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=UzkSBnS+; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id hTlR81ImJoUe; Mon, 25 Feb 2019 14:48:34 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 447NZV4w2kzB09Zr;
	Mon, 25 Feb 2019 14:48:34 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551102514; bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=UzkSBnS+Z5+G8J5VD7TdE2eK6NIJPyTkS3M+LJmSylXmyqBTgWGwRp+kVOMuc3HMi
	 ctQJPSKxGzqpl6MwU8jVGxp2V7PCF+Xv0uoIWeuoHWdrmadjKwNqaEs/j0SzmGiwcQ
	 wcDy1+g50u+XFQYFZNriC0NaE+eKSGjGQ0MlmOP0=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 069058B845;
	Mon, 25 Feb 2019 14:48:39 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 9NJRGqyfSr0c; Mon, 25 Feb 2019 14:48:38 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id CEE168B81D;
	Mon, 25 Feb 2019 14:48:38 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 620FB6F20E; Mon, 25 Feb 2019 13:48:39 +0000 (UTC)
Message-Id: <0eb4945efb0475cc6d42a3f6ed5aa0f342d5fa22.1551098214.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551098214.git.christophe.leroy@c-s.fr>
References: <cover.1551098214.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v7 04/11] powerpc/mm: don't use direct assignation during
 early boot.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Mon, 25 Feb 2019 13:48:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In kernel/cputable.c, explicitly use memcpy() instead of *y = *x;
This will allow GCC to replace it with __memcpy() when KASAN is
selected.

Acked-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/cputable.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

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
-- 
2.13.3

