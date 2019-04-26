Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F4F1C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5421B206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="CWKohPih"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5421B206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 235FD6B000D; Fri, 26 Apr 2019 12:23:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E8A06B000E; Fri, 26 Apr 2019 12:23:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05EC76B0010; Fri, 26 Apr 2019 12:23:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B064E6B000D
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:32 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id j22so3851028wre.12
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
        b=eUCvR67GJxMoANQ57yNWp2zCW6WjFve5QJ12rzvd6xx0oB7wiPBBT5mLjR5+udsdXh
         KDtVBCVzPzimjPOPfslzvcoL8ErvtWyNwnDzbvxzci2RbBro9u6v3iI/DJax1QfnvH+Y
         RCsBQ/b1IySOHNA8XonUBR6EwMCfdCDxiBf9p/bt3twDeQKI8nMu56F2ClzQjT0+7gkG
         0SBuM69nQtY12fKz0D1vE5ISkuRPsIUwiIN9EAVD3lPCWl/vfcwpcqiFLTk71sD4dOAu
         mtt5JEdi9V5vDbcGQgr7NZ6F1lglugW49AQsyJbZQnxSltKPVGn1x1pBnCLXT0bPVuLG
         Bpkg==
X-Gm-Message-State: APjAAAWZlQEiEtx3YlVA+rWyB0lggAuCild9roJggWPb5ZSaf/OVcTQm
	742gH+zzHt7QVzjLctnZND9VSlR0FZfgdXsB5E/GW2zo47tvsm4WO1LrA9uVk7UQz+4Jyt9FZu6
	Aasss2MInoF464SKGRJYgTftFj7/y6KOjtTk3szkpn0VvFS1CPzw7hNBZyctdWfN76Q==
X-Received: by 2002:a1c:6c19:: with SMTP id h25mr8124496wmc.119.1556295812258;
        Fri, 26 Apr 2019 09:23:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzO+CJnrysYuLVuzqvVDRjlp0cUU6UWAmFqKDcpB2cFJxMWR/1enGnF9v+/DV1GLIb1X4DD
X-Received: by 2002:a1c:6c19:: with SMTP id h25mr8124428wmc.119.1556295811247;
        Fri, 26 Apr 2019 09:23:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295811; cv=none;
        d=google.com; s=arc-20160816;
        b=N2UgIv99msfaOITYFiLpjsvB+lJ31li4gC14fWTAMgoTq5t+1wH2RkZ7eumSyeY2Ne
         jUkzOnUEjZEY2flgOsYrvw3Z/hrhshQb7YUlNJ4KqRfX/axoieTiZ5ayXrMNnVc5QqXV
         PDHvIi8y8EWjLstW9GZ0+8N9xNLp6YRHm8KhNiNb3KWR8QR+MMuomyfPVT8OQn9MAVAu
         U+LFSpbYZ1Z6ixAy8Eona4tUcpYyXXDnWSZzCKJfLZmkzD8QP2aJ0xakWXmUozCPmUEa
         KhDQsaV0cnEcOPUVwRyGNx/qH22azHJLClkiQz492O1cHzvhNidjlIcuvj72fWUE3UJo
         aN/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
        b=i2MeFJ1WFEstT3k69rgUYH+d3oIVBehbLJmVy2zahO4PmS/SYgdu/P/wJsh6Euehpk
         lIn3Nt/xUXqGPYscQLuGgYts5aWByBxrWq8ytaYpohIXZ7A5nGZ3sujKB4PeSr2LIW+0
         neVaFwVfM6c7E8cB5EZZoJozoA+kapIUFPQ7+Bz1uHZDV9THVbJtULdbsqzoeEiezSgP
         3XEUhqDDkw0T3Yxmb746TYT/FpViMrUObWvsVrTzt3mGiQLJEr3WAM7E6wOY/jJsm2ma
         LJOgjfS+2Pvlye/pKoFwRzuDc4q0UY7+GNK9zmB/HI+Cy6Xd1hrykbN+59nxC7RIc808
         VCcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=CWKohPih;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id t203si17874084wmt.200.2019.04.26.09.23.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=CWKohPih;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9Y0d6qz9v17r;
	Fri, 26 Apr 2019 18:23:29 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=CWKohPih; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id zvDUJSSKbulo; Fri, 26 Apr 2019 18:23:29 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9X6WYqz9v0yk;
	Fri, 26 Apr 2019 18:23:28 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295808; bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=CWKohPihsdb0jglNX43CKSEZX1O4lA7Kl//zCMT6EZI96CNrRow3BZOYL+ofDglXm
	 ZloFDW67U+LDBkFf/qcXQJpMKLyDfxulM1JYGM2aQpI40oF0xEWxo1F4IaesKwBdVP
	 zZCvDK+FH8+6jF1+z2NkSpFz4TJWz4Jljmk/dr5E=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 92ED48B950;
	Fri, 26 Apr 2019 18:23:30 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id AFBRwVLZioMP; Fri, 26 Apr 2019 18:23:30 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 7172C8B82F;
	Fri, 26 Apr 2019 18:23:30 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 61A7F666FE; Fri, 26 Apr 2019 16:23:30 +0000 (UTC)
Message-Id: <f8cf3904971fa6b0f90ff9f2c2c1551b0cab4f14.1556295460.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1556295459.git.christophe.leroy@c-s.fr>
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 06/13] powerpc/32: use memset() instead of memset_io() to
 zero BSS
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:30 +0000 (UTC)
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

