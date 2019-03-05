Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82E39C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 16:13:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D3C620449
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 16:13:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D3C620449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14D468E0003; Tue,  5 Mar 2019 11:13:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FA7E8E0001; Tue,  5 Mar 2019 11:13:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2C338E0003; Tue,  5 Mar 2019 11:13:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80C598E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 11:13:49 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id d15so2013519ljg.3
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 08:13:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=/+iQ/NWnjHqdJA8QkOn4/7Qo1jgd18s0LYbRadum3cE=;
        b=Gkhw6aKUcPrwVFbn6UZDq+RprHbQWHIdi0ceUkAqeoFlNF0yeJNES2pZ4RmR9wtVZo
         yA1fjeOSDDGST35m1JJ6u+21LSt4LvJ/PWL9/muTGWBC0S0DCaHAK7ayUzOeyexw+YyL
         3qFrJTU6TxNLe1QZk5jtE8tP6OUMp9AWmJkV99+px2Tsu4kNxLc/ykdPbLfnbo+tQKOK
         mxyMmb/0gzlb6sXAeC/HwCabLsDmnXs0FQeu/fXfSx5Rjgl5XtMvNw11tM/TS03Ey9UC
         T9CSUBsdN6b2zbDAbUxzBAQrdGf0buSOnY/OzZxZCqGCUCHiyMhPKbSm15DcHzNBMH89
         LsMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUJ1pS/vzI++HS5XBOS03H51fW43XCz65D0trIBIuFNtBFR61yH
	x5fXm3OKRfHB2gJUT8FBsO6FL46uKOQgBtYV4BIfi5eRvj9Nxi6uAPR7qUZMnnu7HfOdY32eas2
	jxEvq0RQ+twNSjgrMu4D5B8lNgLHw10HquhZz0n3H//Kx0tr8CRBiaQY13JWOPa/n4A==
X-Received: by 2002:a2e:93cf:: with SMTP id p15mr14483054ljh.184.1551802428683;
        Tue, 05 Mar 2019 08:13:48 -0800 (PST)
X-Google-Smtp-Source: APXvYqzrAH1/lBNSaZdUPia8DJscyK6Obw0GTBkuYTbr8HCN8/XeWSgZrZFzDY1RISJ3P8VkkulM
X-Received: by 2002:a2e:93cf:: with SMTP id p15mr14482995ljh.184.1551802427423;
        Tue, 05 Mar 2019 08:13:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551802427; cv=none;
        d=google.com; s=arc-20160816;
        b=WyolH0TOVxHMbXSHa5SrCvYK/6IXmRec5VV48CorqaUNiPZNNXMmr+WL8ELufhqf1w
         RaefqA1jOeEyqF4/XKJ9BMCvdSkvk6RoJWA1H/aQ9lSSP68RHCs9yvMvY2wFTgehLvG5
         CpDmkN9gK67H6fFhfHIQ1egCmfvaQszJLiTIvLjqqTZQoVcNMA3E9eJ6RdSMUUt8zfih
         SYtmDuQC3mhoRljKLp5wT02Xtr1+YPxy6I2tWlzVzxwvYIVxnwfvHe7MGRjymuiB9g82
         ldwcnBmQZoHfK5XDLRzB2X3nuNvoJghi5WY948I1tufZvOxcKkpZ+7Xqjw47t9c1JcSO
         F7+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=/+iQ/NWnjHqdJA8QkOn4/7Qo1jgd18s0LYbRadum3cE=;
        b=Vz5ALinFBBjVooYxDAs1GLu60Lp9dGYHP2laCIG3ISNAc/hTAkNYthgnWjp3Xy4XEW
         r+n2D2lqDc+TQZxcns2L3wdVYk7GFdN996x3wGP7bnM2HyOXb8YbbFKcNMzXv3fL96cM
         xVIdlS4d/JPdfHRdedSTQ16WSVu0WYDnpU7Hv4juRC68DylQyM4vz9U1QL9xqys51wAM
         9LCCda2QeSBJObjpWRAzxi+dwiASVBOK8ft74s6yhOMKJS3Fm2SX2YwGxzDhDlOOredp
         0tZiRS/dwbo7enGgl0kX/JfT7uH6tkwmCTxH2t0bi4VqJwLEIxEDLpO4hErqSOivo0M5
         tsfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id n10si6030037lfe.43.2019.03.05.08.13.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 08:13:47 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1h1ChE-0006No-Bx; Tue, 05 Mar 2019 19:13:36 +0300
Subject: Re: [PATCH] kasan: fix coccinelle warnings in kasan_p*_table
To: Andrey Konovalov <andreyknvl@google.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 kasan-dev@googlegroups.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Kostya Serebryany <kcc@google.com>, kbuild test robot <lkp@intel.com>
References: <1fa6fadf644859e8a6a8ecce258444b49be8c7ee.1551716733.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <67536e1d-2819-553d-521c-bae21a51e0f7@virtuozzo.com>
Date: Tue, 5 Mar 2019 19:14:05 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <1fa6fadf644859e8a6a8ecce258444b49be8c7ee.1551716733.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/4/19 8:04 PM, Andrey Konovalov wrote:
> kasan_p4d_table, kasan_pmd_table and kasan_pud_table are declared as
> returning bool, but return 0 instead of false, which produces a coccinelle
> warning. Fix it.
> 
> Fixes: 0207df4fa1a8 ("kernel/memremap, kasan: make ZONE_DEVICE with work with KASAN")
> Reported-by: kbuild test robot <lkp@intel.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>


>  mm/kasan/init.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/kasan/init.c b/mm/kasan/init.c
> index 45a1b5e38e1e..fcaa1ca03175 100644
> --- a/mm/kasan/init.c
> +++ b/mm/kasan/init.c
> @@ -42,7 +42,7 @@ static inline bool kasan_p4d_table(pgd_t pgd)
>  #else
>  static inline bool kasan_p4d_table(pgd_t pgd)
>  {
> -	return 0;
> +	return false;
>  }
>  #endif
>  #if CONFIG_PGTABLE_LEVELS > 3
> @@ -54,7 +54,7 @@ static inline bool kasan_pud_table(p4d_t p4d)
>  #else
>  static inline bool kasan_pud_table(p4d_t p4d)
>  {
> -	return 0;
> +	return false;
>  }
>  #endif
>  #if CONFIG_PGTABLE_LEVELS > 2
> @@ -66,7 +66,7 @@ static inline bool kasan_pmd_table(pud_t pud)
>  #else
>  static inline bool kasan_pmd_table(pud_t pud)
>  {
> -	return 0;
> +	return false;
>  }
>  #endif
>  pte_t kasan_early_shadow_pte[PTRS_PER_PTE] __page_aligned_bss;
> 

