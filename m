Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6F52808B4
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 04:24:38 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id i50so84619156otd.3
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 01:24:38 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0102.outbound.protection.outlook.com. [104.47.2.102])
        by mx.google.com with ESMTPS id d69si2729318oig.248.2017.03.09.01.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 01:24:37 -0800 (PST)
Subject: Re: [PATCH] kasan: fix races in quarantine_remove_cache()
References: <20170308151532.5070-1-dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <1e8cde9e-919d-784c-298c-85efd6efd82c@virtuozzo.com>
Date: Thu, 9 Mar 2017 12:25:45 +0300
MIME-Version: 1.0
In-Reply-To: <20170308151532.5070-1-dvyukov@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, Greg Thelen <gthelen@google.com>

On 03/08/2017 06:15 PM, Dmitry Vyukov wrote:

> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 6f1ed1630873..075422c3cee3 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -27,6 +27,7 @@
>  #include <linux/slab.h>
>  #include <linux/string.h>
>  #include <linux/types.h>
> +#include <linux/srcu.h>
>  

Nit: keep alphabetical order please.


>  
>  void quarantine_reduce(void)
>  {
>  	size_t total_size, new_quarantine_size, percpu_quarantines;
>  	unsigned long flags;
> +	int srcu_idx;
>  	struct qlist_head to_free = QLIST_INIT;
>  
>  	if (likely(READ_ONCE(quarantine_size) <=
>  		   READ_ONCE(quarantine_max_size)))
>  		return;
>  
> +	/*
> +	 * srcu critical section ensures that quarantine_remove_cache()
> +	 * will not miss objects belonging to the cache while they are in our
> +	 * local to_free list. srcu is chosen because (1) it gives us private
> +	 * grace period domain that does not interfere with anything else,
> +	 * and (2) it allows synchronize_srcu() to return without waiting
> +	 * if there are no pending read critical sections (which is the
> +	 * expected case).
> +	 */
> +	srcu_idx = srcu_read_lock(&remove_cache_srcu);

I'm puzzled why is SRCU, why not RCU? Given that we take spin_lock in the next line
we certainly don't need ability to sleep in read-side critical section.

>  	spin_lock_irqsave(&quarantine_lock, flags);
>  
>  	/*
> @@ -237,6 +257,7 @@ void quarantine_reduce(void)
>  	spin_unlock_irqrestore(&quarantine_lock, flags);
>  
>  	qlist_free_all(&to_free, NULL);
> +	srcu_read_unlock(&remove_cache_srcu, srcu_idx);
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
