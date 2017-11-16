Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 248A228027D
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 10:05:33 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d28so24228225pfe.1
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 07:05:33 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30113.outbound.protection.outlook.com. [40.107.3.113])
        by mx.google.com with ESMTPS id 26si1139751pfp.127.2017.11.16.07.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 07:05:31 -0800 (PST)
Subject: Re: [PATCH] lib/stackdepot: use a non-instrumented version of
 memcmp()
References: <20171115173445.37236-1-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <6f3b8fd2-d2c7-a37d-f79d-510e6cdf2ee9@virtuozzo.com>
Date: Thu, 16 Nov 2017 18:08:52 +0300
MIME-Version: 1.0
In-Reply-To: <20171115173445.37236-1-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, dvyukov@google.com, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 11/15/2017 08:34 PM, Alexander Potapenko wrote:
> stackdepot used to call memcmp(), which compiler tools normally
> instrument, therefore every lookup used to unnecessarily call
> instrumented code.
> This is somewhat ok in the case of KASAN, but under KMSAN a lot of time
> was spent in the instrumentation.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
>  lib/stackdepot.c | 21 ++++++++++++++++++---
>  1 file changed, 18 insertions(+), 3 deletions(-)
> 
> diff --git a/lib/stackdepot.c b/lib/stackdepot.c
> index f87d138e9672..d372101e8dc2 100644
> --- a/lib/stackdepot.c
> +++ b/lib/stackdepot.c
> @@ -163,6 +163,23 @@ static inline u32 hash_stack(unsigned long *entries, unsigned int size)
>  			       STACK_HASH_SEED);
>  }
>  
> +/* Use our own, non-instrumented version of memcmp().
> + *
> + * We actually don't care about the order, just the equality.
> + */
> +static inline
> +int stackdepot_memcmp(const void *s1, const void *s2, unsigned int n)
> +{

Why 'void *' types? The function treats s1, s2 as array of long, also 'n' is number of longs here.

> +	unsigned long *u1 = (unsigned long *)s1;
> +	unsigned long *u2 = (unsigned long *)s2;
> +
> +	for ( ; n-- ; u1++, u2++) {
> +		if (*u1 != *u2)
> +			return 1;
> +	}
> +	return 0;
> +}
> +
>  /* Find a stack that is equal to the one stored in entries in the hash */
>  static inline struct stack_record *find_stack(struct stack_record *bucket,
>  					     unsigned long *entries, int size,
> @@ -173,10 +190,8 @@ static inline struct stack_record *find_stack(struct stack_record *bucket,
>  	for (found = bucket; found; found = found->next) {
>  		if (found->hash == hash &&
>  		    found->size == size &&
> -		    !memcmp(entries, found->entries,
> -			    size * sizeof(unsigned long))) {
> +		    !stackdepot_memcmp(entries, found->entries, size))
>  			return found;
> -		}
>  	}
>  	return NULL;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
