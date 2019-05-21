Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95BE2C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:43:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B548208C3
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:43:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B548208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF5296B0008; Tue, 21 May 2019 11:43:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD86F6B000A; Tue, 21 May 2019 11:43:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A6E36B000C; Tue, 21 May 2019 11:43:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 112526B0008
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:43:42 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id n14so3217371ljj.19
        for <linux-mm@kvack.org>; Tue, 21 May 2019 08:43:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=We2uypiPNmCU7rL3l9J/wgnfVgJk7qbDKDVJyLe1/Pk=;
        b=Et1ywclgZK/p6vTtJU4z4iMk4M+Vlr461sUVWkwzxuChP+zcrob3uLc7hdFAt34NLU
         pCet9ba/yXtDxTDbd4fdq7OG+2qhHa/M3a+czc6/ValZAgN/gISgTy/Svdf2nWnMnTQm
         DmOQinC+imnTKv3eKWDZNcBpFJDyDKzpBRyM1GrBDUxmTXPD7ZwPZOONbuI8pyneGnYh
         bnE6YtbePm84cMQDTnaJ7wkiLLBV+xhsOeeLtbsX7QV8O9MJFD073mnqHRU2+Koi41eX
         51gatma5wWVGfXA0/HKWJe4T0Dg5sq0gf/KUHcA8rHLsqxkhZpr/YMB4N5YUnlfGXgQe
         T8qg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVgmyC5iqO9gQeuNQFhiQ5AcqJBYa4rMejOW0oTlocGPQm6CphI
	w3OGsD7oZrauuMxHFKcUsrNCbvjX0jjamapL3xe3sIcp+tKHjrN0491UpsrUG5DTcxNVBbXfGSG
	fNvPcKU7C/wI55ac/FzvigYXWrrsmMc9LsqlvSmz+2TJYb0TK73z26P9tRtNAspVIAw==
X-Received: by 2002:a2e:2e04:: with SMTP id u4mr5719785lju.144.1558453421350;
        Tue, 21 May 2019 08:43:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHtL5Y7qkLo3SBtSu0OKQOmJa8zglLk6OnD4pGPJgTk4FZMJh2goJ32IjTooLjxha6bMXA
X-Received: by 2002:a2e:2e04:: with SMTP id u4mr5719743lju.144.1558453420543;
        Tue, 21 May 2019 08:43:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558453420; cv=none;
        d=google.com; s=arc-20160816;
        b=WuPAEDIl6GCiNjgPyLEs9g+j27uFIKGaBDJuWtxfoIxTwkgzuuwqjAKeYzzyerMH+Q
         x8N6zSHLw51ocE/rB06OJi/BywEJs72BFyPYkexkY50vs9Co+A+aWUngjkWFB8bczt+P
         MH3Pw6XCXwaxwZGE1qfe3vlit0hJv2YK7C8TQMiN9ma3UU3j4oPiDwIdLEcaUcI3DX0I
         Upxy/RF1SZ2rXAvsM+kDMPfPP52usZO5XERam+OXbXsDbeUUlxToO4wDDOv/jtMvdbPs
         l2mPsrPG4UT4pA+9hghdMRapDKStQJlO/DQ3tdAzxP6JrQ42iaK8rktLnzxmPSA3QocX
         NXow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=We2uypiPNmCU7rL3l9J/wgnfVgJk7qbDKDVJyLe1/Pk=;
        b=NjfoPzx9aJxTrJthkqbP7Rg4ktTLK0SVeqpCG+Md94Srv4Ga5zckxbiVTMIu7ZgxFd
         apSgEt4gbny/xJ+iHFPgMz3FOqTM55N9UB0DczeBFkkOpr8+reudbuy4sVhk9vf9AFAC
         l0y2Ws5JE0Ed8qIonanqGc+V8YhMwxwY2fzNfrso+eFymTbabyTTdLVkj/WjjzNTYMcw
         7R9PtFwxAM8/7iuo4VNw9CS6ZYGhP3O6BHGlaXTnw6envoUnq2mSDQ47nfjQrTWUg/2Z
         1j2+me8wahEltUGHkuc6tI+ChKyOGlAbM+wp062sRY9q/a3avmokmXtfJdJu7Li26XrL
         K+8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id i8si16499503ljg.115.2019.05.21.08.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 08:43:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hT6vS-00073c-UC; Tue, 21 May 2019 18:43:39 +0300
Subject: Re: [PATCH v2] mm/kasan: Print frame description for stack bugs
To: Marco Elver <elver@google.com>, dvyukov@google.com, glider@google.com,
 andreyknvl@google.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 kasan-dev@googlegroups.com
References: <20190520154751.84763-1-elver@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ebec4325-f91b-b392-55ed-95dbd36bbb8e@virtuozzo.com>
Date: Tue, 21 May 2019 18:43:54 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190520154751.84763-1-elver@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/20/19 6:47 PM, Marco Elver wrote:

> +static void print_decoded_frame_descr(const char *frame_descr)
> +{
> +	/*
> +	 * We need to parse the following string:
> +	 *    "n alloc_1 alloc_2 ... alloc_n"
> +	 * where alloc_i looks like
> +	 *    "offset size len name"
> +	 * or "offset size len name:line".
> +	 */
> +
> +	char token[64];
> +	unsigned long num_objects;
> +
> +	if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
> +				  &num_objects))
> +		return;
> +
> +	pr_err("\n");
> +	pr_err("this frame has %lu %s:\n", num_objects,
> +	       num_objects == 1 ? "object" : "objects");
> +
> +	while (num_objects--) {
> +		unsigned long offset;
> +		unsigned long size;
> +
> +		/* access offset */
> +		if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
> +					  &offset))
> +			return;
> +		/* access size */
> +		if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
> +					  &size))
> +			return;
> +		/* name length (unused) */
> +		if (!tokenize_frame_descr(&frame_descr, NULL, 0, NULL))
> +			return;
> +		/* object name */
> +		if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
> +					  NULL))
> +			return;
> +
> +		/* Strip line number, if it exists. */

   Why?

> +		strreplace(token, ':', '\0');
> +

...

> +
> +	aligned_addr = round_down((unsigned long)addr, sizeof(long));
> +	mem_ptr = round_down(aligned_addr, KASAN_SHADOW_SCALE_SIZE);
> +	shadow_ptr = kasan_mem_to_shadow((void *)aligned_addr);
> +	shadow_bottom = kasan_mem_to_shadow(end_of_stack(current));
> +
> +	while (shadow_ptr >= shadow_bottom && *shadow_ptr != KASAN_STACK_LEFT) {
> +		shadow_ptr--;
> +		mem_ptr -= KASAN_SHADOW_SCALE_SIZE;
> +	}
> +
> +	while (shadow_ptr >= shadow_bottom && *shadow_ptr == KASAN_STACK_LEFT) {
> +		shadow_ptr--;
> +		mem_ptr -= KASAN_SHADOW_SCALE_SIZE;
> +	}
> +

I suppose this won't work if stack grows up, which is fine because it grows up only on parisc arch.
But "BUILD_BUG_ON(IS_ENABLED(CONFIG_STACK_GROUWSUP))" somewhere wouldn't hurt.


