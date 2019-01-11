Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2178E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:45:05 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id x2so1082581lfg.16
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:45:05 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id o11-v6si17478148ljg.213.2019.01.11.10.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 10:45:03 -0800 (PST)
Subject: Re: [PATCH] page_poison: plays nicely with KASAN
References: <20190107223636.80593-1-cai@lca.pw>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <2e46c139-70d3-dc86-28c9-a9f263651b57@virtuozzo.com>
Date: Fri, 11 Jan 2019 21:45:25 +0300
MIME-Version: 1.0
In-Reply-To: <20190107223636.80593-1-cai@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/8/19 1:36 AM, Qian Cai wrote:

>  
> diff --git a/mm/page_poison.c b/mm/page_poison.c
> index f0c15e9017c0..e546b70e592a 100644
> --- a/mm/page_poison.c
> +++ b/mm/page_poison.c
> @@ -6,6 +6,7 @@
>  #include <linux/page_ext.h>
>  #include <linux/poison.h>
>  #include <linux/ratelimit.h>
> +#include <linux/kasan.h>
>  
>  static bool want_page_poisoning __read_mostly;
>  
> @@ -40,6 +41,7 @@ static void poison_page(struct page *page)
>  {
>  	void *addr = kmap_atomic(page);
>  
> +	kasan_unpoison_shadow(addr, PAGE_SIZE);
>  	memset(addr, PAGE_POISON, PAGE_SIZE);

kasan_disable/enable_current() should be slightly more efficient for this case.

>  	kunmap_atomic(addr);
>  }
> 
