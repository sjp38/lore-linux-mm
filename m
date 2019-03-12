Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EF94C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2493213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="N2TM9CNF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2493213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D74A8E000E; Tue, 12 Mar 2019 18:16:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6402C8E0011; Tue, 12 Mar 2019 18:16:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 445D18E000E; Tue, 12 Mar 2019 18:16:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id D730D8E0011
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:22 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id n12so1032387wmc.2
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=3EkWwfm1J9eIRyBAvVT+4ioqJyrfykTcLJkz42zJae0=;
        b=H4nSBunyH0WGcWb9WOMAm9XGHn4m3NQm96dNU9rVyK4uo9TrmJZVbbZ/8ZdCViaOae
         FSH7fn9Z+asO2XaBavF1AfVAECj9LwLNuaCYui/3JtIMAStKjEhrsPWxXLb5+q23nzUw
         WJ8UzjAi/IcYEgNcBSf81KyLxhHCR9f+psJHYBg78oMHJ76zn0X0GVkLXh5PccVrxWPA
         yTDZ+BkEE1fDSb/FDRYxdWgT11Q4VIOcuYWDl8M5f+1bD3dlvRPyceGHBnVe/1QLE5UF
         L0dMXXGSWjn1AO4CylaAo29tcCqQwdTj+LQtBDylkYuaue6C+7dESUhYjG2hmUZPpl75
         LlTw==
X-Gm-Message-State: APjAAAVU1OTy7e6WLHNmnND+juOdq/c5F12SY7nVJ/rvXn3oknZuFKTd
	yh9jQ7oraOuRuTq2gOUawhBxyeAZx0kXE9AB1bwCLYkOt/zg4ur0I2L+uqm4WcRyu9wbKPX6v74
	9lXEXuDMV9Tt+tdmYoMugiwubZHpTeBSkDGsq6GIVTHGRp47NLR5vUai9xetfr8NR+A==
X-Received: by 2002:adf:b211:: with SMTP id u17mr27005522wra.322.1552428982289;
        Tue, 12 Mar 2019 15:16:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7G3kYMpt2jBJyd0UWYJcD53hOh6m94BUFBCQiMyZ14Ignb+cVJ8VGRuSggX/axUu5AIvw
X-Received: by 2002:adf:b211:: with SMTP id u17mr27005482wra.322.1552428981031;
        Tue, 12 Mar 2019 15:16:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428981; cv=none;
        d=google.com; s=arc-20160816;
        b=eLYREyTKUYEVXKCN0N+yXBO58XocxVMeB1GSBsA+eHBZeQRL6beC4oStI3TOQby1mu
         8Cps9VCWWoNWk5r72jZ82NkutECW9+chzpqFCVgRmr+2sivTuCJEwlmcSHAqzqSCzIix
         fNuk7NVB15kitTMh44TiIiDCssoxaKttPpo7gFY09hgmNNdTvkT4QaRKiRVkgUGuDJ/o
         XpzXqlmV80daMzTQWsAPHUz0pIbgqjJkSr8yD2+fnlzXsBlF9UaQDRy/DGjUIHq0nC0R
         C3qorY34dcqQqmsLN1SmSYCf6Pa0D/wsC2c6Eg2UKCtstRWonB/D8lBktLt52FTBVmND
         kQ7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=3EkWwfm1J9eIRyBAvVT+4ioqJyrfykTcLJkz42zJae0=;
        b=gkk58grF3zegHLLJDZ2Pq044vVhRAphB/qP1rLqbSiKQiF7XEarzS6c1EEuRjwp5Ol
         +aPi8IZPQsaFyMBnpQVklXGROchFA+oN9NnI7EBlLxzosW0CtfZ9DW3DwCXzNcPjjmmS
         8Mx3ui6ZZXnyh+BxnU3xWqIBIdZXuUUahtc0GQCpFPnjtkZ3ia0WHahkvqslf26EmEci
         7aSmX3W/26b9WhgHKENNHi7rQ6ouwtVxxMp11DMcQZ06uUBInCU147TNrjV/ZmC//aQo
         ZjTXrGOnpoaRDd3FaVpxkVc35QcxuWKWYRPTndIfUrMfrflgWOLcSfFkZ6a0M06jVyOQ
         vFpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=N2TM9CNF;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id x10si18308wmj.95.2019.03.12.15.16.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=N2TM9CNF;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7S2kbMz9tyln;
	Tue, 12 Mar 2019 23:16:20 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=N2TM9CNF; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id qTzJ1ppy2_Hj; Tue, 12 Mar 2019 23:16:20 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7S1Z5Wz9tyll;
	Tue, 12 Mar 2019 23:16:20 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428980; bh=3EkWwfm1J9eIRyBAvVT+4ioqJyrfykTcLJkz42zJae0=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=N2TM9CNFJJZcGDGQgUrPK4MYpe/al6eQHIrgQrWJWcmO2YuKobOm5OK7m9EZlK0xG
	 B6uP41oS5KK5Jzh2rvnrRFvwrgHFS7B2fPk83j6E4FGdrrsJp5+yXVRo5lW+ecBbLf
	 qaXPTXztGHCEFMxvL91DA/r2eFRyTqWevkyabkZU=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 6F1D48B8B1;
	Tue, 12 Mar 2019 23:16:20 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id Q5Qbh1RmwQXX; Tue, 12 Mar 2019 23:16:20 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 46EAC8B8A7;
	Tue, 12 Mar 2019 23:16:20 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 0AB216FA15; Tue, 12 Mar 2019 22:16:19 +0000 (UTC)
Message-Id: <053c7aa774fe73402e690c47f432c9d3279dfc30.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 14/18] powerpc/32s: map kasan zero shadow with
 PAGE_READONLY instead of PAGE_KERNEL_RO
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For hash32, the zero shadow page gets mapped with PAGE_READONLY instead
of PAGE_KERNEL_RO, because the PP bits don't provide a RO kernel, so
PAGE_KERNEL_RO is equivalent to PAGE_KERNEL. By using PAGE_READONLY,
the page is RO for both kernel and user, but this is not a security issue
as it contains only zeroes.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/mm/kasan/kasan_init_32.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/kasan/kasan_init_32.c b/arch/powerpc/mm/kasan/kasan_init_32.c
index ba8361487075..0d62be3cba47 100644
--- a/arch/powerpc/mm/kasan/kasan_init_32.c
+++ b/arch/powerpc/mm/kasan/kasan_init_32.c
@@ -39,7 +39,10 @@ static int kasan_init_shadow_page_tables(unsigned long k_start, unsigned long k_
 
 		if (!new)
 			return -ENOMEM;
-		kasan_populate_pte(new, PAGE_KERNEL_RO);
+		if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+			kasan_populate_pte(new, PAGE_READONLY);
+		else
+			kasan_populate_pte(new, PAGE_KERNEL_RO);
 		pmd_populate_kernel(&init_mm, pmd, new);
 	}
 	return 0;
@@ -84,7 +87,10 @@ static int __ref kasan_init_region(void *start, size_t size)
 
 static void __init kasan_remap_early_shadow_ro(void)
 {
-	kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL_RO);
+	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+		kasan_populate_pte(kasan_early_shadow_pte, PAGE_READONLY);
+	else
+		kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL_RO);
 
 	flush_tlb_kernel_range(KASAN_SHADOW_START, KASAN_SHADOW_END);
 }
-- 
2.13.3

