Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D23FCC04AAC
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 08:52:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 759432075E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 08:52:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 759432075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D33E46B0003; Thu, 23 May 2019 04:52:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE5056B0006; Thu, 23 May 2019 04:52:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD2816B0007; Thu, 23 May 2019 04:52:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A28A6B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 04:52:51 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id h132so636637lfh.23
        for <linux-mm@kvack.org>; Thu, 23 May 2019 01:52:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=sz4UZ+kS7GmFLyBvXVIykzQAS9lKB4VP6bT/MciVzPw=;
        b=o6JDPZ4tSQHAky/GiqFWDxZKmILmKQx6bHEt5PaqYyOOQpEFWZGTaYktJaWmawSNQ/
         xQbX/hdxOKATlHJUOYZDSb0aEHtDy3LjaEQd+hRmEL9nc0Hs1d26k6WbTXV+iX1i8reU
         /gL5C9eJij62geyqEzbBv/1V0noG8d/xfYzlaDXE8rVWkVZOudrbNrqEqChxDGM4/+cR
         tlB3lqFliLgseAYfBWTGB9xZi7hSscJ2qBm95C0bmE6+ZNhuC+juiy53RwjhG9l5SB7Z
         Z1n6qxgZ/pe5kKOLdUqEUtGs1vtmHKD6TOdJA4ASttAku85anlNhJ5yLMBG+yM7YleOf
         t7gA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWBi9bP82Euer4I7WZJtZO8Pmkfq4E0WDu+I+zomKdtlSsp2PnD
	JnW8rW8jvP2D/mah7izwoBre0i0iPusYWjTpKopmUIW3atpgODy1CrFgqZFo+AZaL3zphCU2tpT
	TqAvPBrB1KBCNqSLFAZ/zh00bpnceQTgZiBRV5bn7mH8yX7EQm8yi2+2N00PJ+VAf8A==
X-Received: by 2002:ac2:4c1c:: with SMTP id t28mr4722216lfq.69.1558601570614;
        Thu, 23 May 2019 01:52:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5wOAh+1AOnTBtqj16IpoqK+fmotALqDgBPJIgVWUcgGImcHoBGYK2gF7Hnaczi8tGO7Io
X-Received: by 2002:ac2:4c1c:: with SMTP id t28mr4722171lfq.69.1558601569659;
        Thu, 23 May 2019 01:52:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558601569; cv=none;
        d=google.com; s=arc-20160816;
        b=ljQyxArtaV4k7mjuCeaMe3MOKmd5CtK2kL4DocLT12IBQOTTlafhmO7T4szLysiQx4
         AOeKMsJdkkz5/vGvA1qQp0Yqj6MX2o+0lS6fNucm+bxkj+LNHWDxZ5Pkosc0S197+iUA
         tnKoFd0eUIm1yEedq9PwqvUtNzvjwM5In09tWOLNbrmv2LKKHYTij/ySRW+uVqGGrJkK
         iJdAoeV8sQDsGcj8o/UWYfUa7pev1uWxqR4BP7mQxB5i57NvAHr1ZHS1fEc3PjUbHSXh
         891cYi/podsOzQTkLiXunZrZY95I57JLFdjIGAlrIbwO+oADVb70YNCQngiIPG6p6Rii
         jzJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=sz4UZ+kS7GmFLyBvXVIykzQAS9lKB4VP6bT/MciVzPw=;
        b=AcKUnLBdxZcuKf2X/z9w0jn1e1LA3PEVlr09hTl5ZNdPZNOnA5n7u1RTZw7n0TYDQV
         nQ5kE37oCTCRa9h++14e/orKjSJz32zrtayaVRv5VwNbWTP3sqw32TYw2tv96R+jrXMa
         8I7SFHGwcjfv4yLsyr9/sIuABApWE6Qr/sDkcMRE8fffobaylnSU+RFVhjTCI49Wukc6
         0eVbkXvN6Pt0oN7WJc0ZCrl+8pSF+M0bEft8RAaInWl6NAepMDg2QnGF8mJvz25im4WD
         jNIHLoO14tj6wrb0Rgcaz5dYyNBTt8mWQPApNEM4YNrdLIb0ucSmyhU0qJkxYixNycvA
         RbTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id e3si22117627ljg.124.2019.05.23.01.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 01:52:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hTjSu-0000Q9-Mk; Thu, 23 May 2019 11:52:44 +0300
Subject: Re: [PATCH v2] kasan: Initialize tag to 0xff in __kasan_kmalloc
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Chancellor <natechancellor@gmail.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 kasan-dev@googlegroups.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Nick Desaulniers <ndesaulniers@google.com>,
 clang-built-linux@googlegroups.com
References: <20190502153538.2326-1-natechancellor@gmail.com>
 <20190502163057.6603-1-natechancellor@gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <126d5884-b906-f85b-e893-a6a30ac0082c@virtuozzo.com>
Date: Thu, 23 May 2019 11:53:02 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190502163057.6603-1-natechancellor@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/2/19 7:30 PM, Nathan Chancellor wrote:
> When building with -Wuninitialized and CONFIG_KASAN_SW_TAGS unset, Clang
> warns:
> 
> mm/kasan/common.c:484:40: warning: variable 'tag' is uninitialized when
> used here [-Wuninitialized]
>         kasan_unpoison_shadow(set_tag(object, tag), size);
>                                               ^~~
> 
> set_tag ignores tag in this configuration but clang doesn't realize it
> at this point in its pipeline, as it points to arch_kasan_set_tag as
> being the point where it is used, which will later be expanded to
> (void *)(object) without a use of tag. Initialize tag to 0xff, as it
> removes this warning and doesn't change the meaning of the code.
> 
> Link: https://github.com/ClangBuiltLinux/linux/issues/465
> Signed-off-by: Nathan Chancellor <natechancellor@gmail.com>

Fixes: 7f94ffbc4c6a ("kasan: add hooks implementation for tag-based mode")
Cc: <stable@vger.kernel.org>
Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

> ---
> 
> v1 -> v2:
> 
> * Initialize tag to 0xff at Andrey's request
> 
>  mm/kasan/common.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 36afcf64e016..242fdc01aaa9 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -464,7 +464,7 @@ static void *__kasan_kmalloc(struct kmem_cache *cache, const void *object,
>  {
>  	unsigned long redzone_start;
>  	unsigned long redzone_end;
> -	u8 tag;
> +	u8 tag = 0xff;
>  
>  	if (gfpflags_allow_blocking(flags))
>  		quarantine_reduce();
> 

