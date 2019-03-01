Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFAEFC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C477206DD
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="rybuktLB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C477206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58ABA8E000A; Fri,  1 Mar 2019 07:33:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49C758E0008; Fri,  1 Mar 2019 07:33:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2588F8E000B; Fri,  1 Mar 2019 07:33:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3CE98E0008
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:33:47 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id q24so5060554wmq.9
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:33:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
        b=VM2dFMt3vyMrzahBl5aywl3+jqDAwztgkh8EsvKbnH4sQgBM9gzYB04OYZH285TxFM
         Jbj/t94hz3Y/Yfk6HIyKxLXmEgqC6GJC314DXDzozLjq6UQJV7sB54LOzMWn5EhZ/rmi
         VgzFLl8QVeFMjMLfKu3nPhtxDxE6lqrWSX+HXAPaaQ6NxsafJt31MOR+V1RWAeSvlMmB
         NU//z4aoPn/HjbThnT1FJ72JFMxZR2FjYqqLRMSrzVq6QkFBOxfndgD8jAJ70AmZucI9
         9SEcWnBhUbKxV2cVIxC8hV6hhZ4gMgzLoNuagpvKyABtSgUIGe+LQ2VvQAZjZIvIKkj4
         kq4Q==
X-Gm-Message-State: AHQUAuZQY31DXAdWkLiIqsReChaxQp4UPgPCtrxh96omG0NPBVsgEJTS
	LZFz0cnaualxXwt2/fCYaC/CMuxTaqmGbmLhPS0gnszqpZawnHpowmpYIqRgtCl014DLzM/zQx1
	VP/sr5demlpIBf3pKUJXftbXVAZCiF1jNxS+0M/9ZqcKYX+hdMqg9rYFJG8mCwpL5mg==
X-Received: by 2002:a1c:44c3:: with SMTP id r186mr3109904wma.63.1551443627162;
        Fri, 01 Mar 2019 04:33:47 -0800 (PST)
X-Google-Smtp-Source: APXvYqxyHMd2oL3ls4UDwrP9EsIZX5pA/DDNOHqeeg0etScRLUGuB/xp+T5fSyfOEfZKBQCmGcvp
X-Received: by 2002:a1c:44c3:: with SMTP id r186mr3109783wma.63.1551443624252;
        Fri, 01 Mar 2019 04:33:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443624; cv=none;
        d=google.com; s=arc-20160816;
        b=d/fjMOnfIeXSi7qAuDqinOThbHpxoqYN4gmp9Xuf53bDeeFjGavgay1Ymn/fYXKSHY
         QnMPkDUFoMO8acZ8rGf/PRBpfUqjABEZ/QdjVXV/JSTd9oYQq9oFZZr1z0R5XcaPKw/t
         B8KiPji8w8jpVxiMozyUKsqfZJAyQn2AoI8IcMlgm2wpuLVIWlvX32GzPieccNK6mW/q
         3GMIB6vfGL3/WRLZ4Eyt/It4X1CC1jV8pK06OBtogHu32pSrWvkfp85hZnC3dYzhOamK
         8L5jfztHTF05sO5B4UHi8MKitZKbCmQFVV/tLpiZPClVr0pn6f7NkIpx+HVyicRql2Tc
         xAaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
        b=b7QAIE4nukOcT9AMCYOMZhi1lyUfOn32+9OC/RBtDgf1gcsnqHtw4zzEPn/qsbPWjG
         Ib2OWtngvZ3615e+I7744pLT5Yj9eYR+1eMa0osMJeLIvSqmHYldOyQSQcPD+9dTNm/g
         HoHVXV+n2GJaniXbwYWEdn2csP3SokHoQbms16bE0fygJyhAiSTfzpdd3db6+vZC9Hfx
         28reyBUo5JbX7pRgcZYFbX4W/xpDIKhcI723TFL8yoJJEUmG8Jt5iuiapUAdV6xl8EyE
         ker9AA00LwPEygbEL9qeuOOIq9nVoYLBxI9nKZ5fsawVDW73nbUKTQbc8kChsHCFwnqN
         xcOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=rybuktLB;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id q15si5119865wme.79.2019.03.01.04.33.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:33:44 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=rybuktLB;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 449pkG3qKmz9txrr;
	Fri,  1 Mar 2019 13:33:42 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=rybuktLB; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 7fh6xtct_1Ud; Fri,  1 Mar 2019 13:33:42 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 449pkG2lcbz9txrh;
	Fri,  1 Mar 2019 13:33:42 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551443622; bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=rybuktLBqTBbP5JYSCuz5k6KxvrQheL8FM5pOdWxhSLBzmveOkS1mAgRCBi8LKncy
	 UEH9iOedKdAZZOeqRlElTiI8SzAeztUUL1ZV5ANzdBw7+ZntaKX60Hsrk+OFy6IQ6S
	 CXjw07kftkLCuuK8z4kDMVfzlE99g0cNGBla9/Cg=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 9F9518BB73;
	Fri,  1 Mar 2019 13:33:43 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 7QyMtoFXDvp0; Fri,  1 Mar 2019 13:33:43 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 647948BB8B;
	Fri,  1 Mar 2019 13:33:43 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 3F9AD6F89E; Fri,  1 Mar 2019 12:33:43 +0000 (UTC)
Message-Id: <9718764d2702d89df6de6e9607e5e53256f766c1.1551443453.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551443452.git.christophe.leroy@c-s.fr>
References: <cover.1551443452.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v9 05/11] powerpc/32: use memset() instead of memset_io() to
 zero BSS
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri,  1 Mar 2019 12:33:43 +0000 (UTC)
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

