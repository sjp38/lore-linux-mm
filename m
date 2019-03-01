Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F19CEC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:33:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD723206DD
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:33:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="nn5hog9F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD723206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC7658E0001; Fri,  1 Mar 2019 07:33:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADF1A8E0008; Fri,  1 Mar 2019 07:33:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86A5B8E0001; Fri,  1 Mar 2019 07:33:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 174008E0006
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:33:45 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id h65so11389903wrh.16
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:33:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
        b=SphO1/PPMIasVuSPIc826pl+smPxtGhCY78yPltpoasCy5wBZ7TTPY5UOv8i59ZtxJ
         9ER581Q/FHADYITm9k4tP5jGTCblq8S/zlrKa0+X3qODLp2dAlSWgkzS4jfIIzu+kGW9
         OSEnXWtJdbMbX5RTDk9TTqKrWGJCmbrmZGEKdmy0pkJ4/c786F9xWUBVuvCK7vXk6/XD
         LOEoX/qVKGcXlRQeFaCgqzwW6Fbps88VyA39qwJp/hbfkhl3E4rv3dCxsGizMajYSXYI
         0WN4WaBpo+rMATj0iEfJZsAJq7X/fqLMffLtI1xdy4oD4rIP3PbFxNxCzWssFp0nj0eD
         JkaA==
X-Gm-Message-State: APjAAAXX0dEugIbckZwbow06tBEMfsbruzkUs04+vIBfO6Y9xz0aHohI
	IQb2PEVVoLQ7U+htDY7kYFyjM+ePPZ0X6GYl+5/WLXZ06A0NEApJIGp2rlnsrmIb6u9HI6dzocu
	QtMXhsBpG6cQqJ3a7LVIfjeY7I5h4QJMmfFPB8LDs/qEfnAA+zgkxQs8WL8mQkZ8zpw==
X-Received: by 2002:adf:fc12:: with SMTP id i18mr3190806wrr.201.1551443624565;
        Fri, 01 Mar 2019 04:33:44 -0800 (PST)
X-Google-Smtp-Source: APXvYqxrTco2IhxtXCR7hUXfaTFkjV0b01dFXvW/HEXEpfn5U3NoPkeIGf2M0e3b1n7AuykYmnkq
X-Received: by 2002:adf:fc12:: with SMTP id i18mr3190746wrr.201.1551443623379;
        Fri, 01 Mar 2019 04:33:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443623; cv=none;
        d=google.com; s=arc-20160816;
        b=PHIEbrpxT734G2YqV/FRaUJnfW28faVJCsg3/03xYOehhYkUXkyhfR+LalWQgWKGiC
         TDZl7BjQxmGQQ/GQ4t4uhbP/MyAAlOGI7TNFn+1RAE2N0MVkvvu07iCT7lcNJo3zb0xT
         PLkSXsH9Wj/+Kkk6wrkrP3gZtPs7wh+jT04ILDGBDvlKHEyueidXuaW4xDd0/Xqbqevm
         OpN3PkP3HvnoUZSrC9o7oqOCo4+5XzNvKXCRqHDayEm5JtMVSbiaZje+g7TvPQibCfNE
         zqTmP/n8c/mNh1Y9l4oTBMLfECJLVbsYYKtKSYIbRipD+K3ujxQROn16zfYsyH9qjUjP
         ieWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
        b=hgOcC6I5nPbsNYZQ2O2g475a3rkAgJ5vd3cuQQ0DunOVKtXbgDzoS6bgb9b1nXyLVy
         D0xJFgXV6GiwPdxgSK6+g7/l1nA7OWy0vwah+Gl84I87g0PW35H2wa2h/hX8BpI5yWZ6
         r5ipvhB3Y5g/coCVnt/TzOTrst8hH3R06XdBrAPluH53VcJNji7Txmr3qhxss9hIq9o+
         RAWDZmxJASrwh8G4Oc5mo6bWhvBbkqVJTkC9xZHF0qTKBWUO9q2Kc+xQKI3tuqv/Nr85
         3s1H1s6tnRTjo1tGmr9imIlixKtZNTE9X7N2XMAulceiPNUWsVmFQe8icKEusL2hpz91
         ZDbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=nn5hog9F;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id n9si17596940wrg.78.2019.03.01.04.33.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:33:43 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=nn5hog9F;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 449pkF4Drhz9txrp;
	Fri,  1 Mar 2019 13:33:41 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=nn5hog9F; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id NhfshISpNCAD; Fri,  1 Mar 2019 13:33:41 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 449pkF33c0z9txrh;
	Fri,  1 Mar 2019 13:33:41 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551443621; bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=nn5hog9FmupqvIer8UZXuu5YWMe3YWuc/LU+tdF//9x0G3Miq3YDC3iu7tYfmPbY7
	 L5B8RPu9XRAWdlLNZcLYb683D/xU+ATOAz7Qqqj+2ul6EAVDFkI4o/FvtlH4TkzpHN
	 4rjYplkWt2HUg1ShZgb75mMpLyJJH6VF7Bug/2xY=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A36618BB8B;
	Fri,  1 Mar 2019 13:33:42 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 3wNDqyWP9Mo2; Fri,  1 Mar 2019 13:33:42 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 525E08BB73;
	Fri,  1 Mar 2019 13:33:42 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 36C5B6F89E; Fri,  1 Mar 2019 12:33:42 +0000 (UTC)
Message-Id: <7cd5cc904c0a77f573a0fe116b3464d4f38c7aea.1551443453.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551443452.git.christophe.leroy@c-s.fr>
References: <cover.1551443452.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v9 04/11] powerpc/mm: don't use direct assignation during
 early boot.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri,  1 Mar 2019 12:33:42 +0000 (UTC)
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

