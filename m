Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD658C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:48:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D3D420842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:48:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="InB4Rtmw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D3D420842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A3038E0156; Mon, 25 Feb 2019 08:48:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42B258E011F; Mon, 25 Feb 2019 08:48:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3407A8E0156; Mon, 25 Feb 2019 08:48:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1A638E011F
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:48:42 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id s5so4757659wrp.17
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 05:48:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=x5Dwfe9pBn0jiYAytmPEco/+5u9wkUq+xY/xh4B++1o=;
        b=m/f5p6N/lFjEWzOdUgcaB9/2mrGydahbxMi0oeEEGqFBrmJ9O0B1ypIQsiu4uBwy41
         FMEovepkO7X52Nl/qzQQWquxFw5Udn+9fkCqtcvjgs+0Ss6mDnq24KsQlrHLMUMkxoy1
         srN8RUwlI/MKtvmO94+EsgdLZq19j2mpM/4tNDBO95FiW4nq4bgsBJse///e9hL1aWXf
         Oo33eAatOePXNQBn+wdaVBEkp/Ta48HDYOhj2lIzfQO1QwLFcYEter0HnLDkOhz6WW/f
         GUlsM0cFxf4rjC5v3JoAp5kOpmEj6Ca5by8D4o/tYTF0c3wdPuNmUuvf28dMEVAfU9BU
         Ucmw==
X-Gm-Message-State: AHQUAuYCrQF2K/0j2v3JiEiTCj+KEby8gN6SBoOo8oV4Sks5ZPe31SQ4
	cPe2XzLFIWDSzu9f7OWAm9RsBYaeq1ZNlRl0O6KiJO7BCyUbs6lFwVbY1Ja1YTa51TjF1/q/U5m
	3PssJwgr33UrtrDtdA0QHdr7RaMTnUxDTI7jDRJIrx0Z2RL7XNFJ0g620mBOkahV0Iw==
X-Received: by 2002:adf:c3c5:: with SMTP id d5mr12192470wrg.308.1551102522350;
        Mon, 25 Feb 2019 05:48:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYXN2ri3Rf891Em7SWT6ECyNvgxa4cRkaLeA/5XdmRtkyXTW+SlgxXfnbprjRnTlCgDcdpY
X-Received: by 2002:adf:c3c5:: with SMTP id d5mr12192432wrg.308.1551102521473;
        Mon, 25 Feb 2019 05:48:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551102521; cv=none;
        d=google.com; s=arc-20160816;
        b=K0pi1oBF8gPxDG/uBwAG1nGhGATZGhhfjUXL/qUaDxtCtdYweBX762waBxZq7WFiW+
         Lt+LOeqPHOzEJ63or+5FdnQa26NSPzqkO8YZrWBsajzUztRI6NrRO3xo1diSm1N/Bgly
         D9bCN7z2RIVbjAdJhvt7gAbdbr53yiPPeSh+OrjjtZkWK+Co0KV72jJO+cq3Hzxun5Rt
         1TpiLVaZFkZaagE+OzrzFRIJ5YIom7ORVvPfmFQJORqGTQJRyVNl8C3l8O6ECXexr6pm
         k/niKWRTWYDHcFcRGZECTdQjjedPsuarrOsIN78rJBSscmZ28Mt8WikHOn8/ws38EW87
         nMxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=x5Dwfe9pBn0jiYAytmPEco/+5u9wkUq+xY/xh4B++1o=;
        b=HYK0zlb0DlH/IMXejusc9zXSRsl2EB2Lb+jeJiHX4r782OaKo9SYWGEli0JFPzJMIr
         XNdM6YlKl9veUMfdTDE0Fw9av7P43gX+1+SoyZeP7Bj/5mzYaqY4HuNe4leRJ4YqetWJ
         wYvUVw03LqZLe27Uph0JnS7rq6OSIB61ZUdHpxmKi4kZIjsg9dmsEEiPWfvM29PtmoOP
         ydb9OoK/YRVnzGZHAIDcn4blViplEADJAAshOfq25MiClwk6xMnZfpnQMFNgMkMd0rd4
         3ELKTpB76wnAygQ6gFvBBphviGFQv8HzLRYKaLB6MmLuRrq6E6F+OFB+OisrRniTfiqn
         GwbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=InB4Rtmw;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id f17si3261647wmh.24.2019.02.25.05.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 05:48:41 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=InB4Rtmw;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 447NZW6sbhzB09Zx;
	Mon, 25 Feb 2019 14:48:35 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=InB4Rtmw; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id KITX66fVEf2E; Mon, 25 Feb 2019 14:48:35 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 447NZW5p8YzB09Zr;
	Mon, 25 Feb 2019 14:48:35 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551102515; bh=x5Dwfe9pBn0jiYAytmPEco/+5u9wkUq+xY/xh4B++1o=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=InB4RtmwYoK6LQaYlrN8w0doKaOvX/dKEXYejh8RpF/WfWvvN1AmsYBpLQeY0du5P
	 mHTbB12/X5l5xY+VNueAh7CFB1/SwNTNFtQdGnGXnLuESiXoeAUK33+mwiqOqM8RnU
	 C0HCq8V7Zb6ojSSYHw8fSFHia6p5TXhYZ5xCE+ss=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 110048B849;
	Mon, 25 Feb 2019 14:48:40 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id qbr4j7dF2fny; Mon, 25 Feb 2019 14:48:40 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id CD30F8B847;
	Mon, 25 Feb 2019 14:48:39 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 67C2A6F20E; Mon, 25 Feb 2019 13:48:40 +0000 (UTC)
Message-Id: <db6c87c67a3a1dc07ec6f9c304428ce156b278cd.1551098214.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551098214.git.christophe.leroy@c-s.fr>
References: <cover.1551098214.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v7 05/11] powerpc/32: use memset() instead of memset_io() to
 zero BSS
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Mon, 25 Feb 2019 13:48:40 +0000 (UTC)
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
 arch/powerpc/kernel/early_32.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/kernel/early_32.c b/arch/powerpc/kernel/early_32.c
index 99a3d82588e7..3482118ffe76 100644
--- a/arch/powerpc/kernel/early_32.c
+++ b/arch/powerpc/kernel/early_32.c
@@ -21,10 +21,8 @@ notrace unsigned long __init early_init(unsigned long dt_ptr)
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

