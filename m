Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 25B006B00CE
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 20:15:50 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so1120310pdj.34
        for <linux-mm@kvack.org>; Wed, 17 Apr 2013 17:15:49 -0700 (PDT)
Message-ID: <516F3B30.30307@gmail.com>
Date: Thu, 18 Apr 2013 08:15:44 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: Remove unnecessary __builtin_constant_p()
References: <1366225776.8817.28.camel@pippen.local.home>
In-Reply-To: <1366225776.8817.28.camel@pippen.local.home>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Behan Webster <behanw@converseincode.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Steven,
On 04/18/2013 03:09 AM, Steven Rostedt wrote:
> The slab.c code has a size check macro that checks the size of the
> following structs:
>
> struct arraycache_init
> struct kmem_list3
>
> The index_of() function that takes the sizeof() of the above two structs
> and does an unnecessary __builtin_constant_p() on that. As sizeof() will
> always end up being a constant making this always be true. The code is
> not incorrect, but it just adds added complexity, and confuses users and
> wastes the time of reviewers of the code, who spends time trying to
> figure out why the builtin_constant_p() was used.

In normal case, builtin_constant_p() is used for what?

>
> This patch is just a clean up that makes the index_of() code a little
> bit less complex.
>
> Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 856e4a1..6047900 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -325,9 +325,7 @@ static void cache_reap(struct work_struct *unused);
>   static __always_inline int index_of(const size_t size)
>   {
>   	extern void __bad_size(void);
> -
> -	if (__builtin_constant_p(size)) {
> -		int i = 0;
> +	int i = 0;
>   
>   #define CACHE(x) \
>   	if (size <=x) \
> @@ -336,9 +334,7 @@ static __always_inline int index_of(const size_t size)
>   		i++;
>   #include <linux/kmalloc_sizes.h>
>   #undef CACHE
> -		__bad_size();
> -	} else
> -		__bad_size();
> +	__bad_size();
>   	return 0;
>   }
>   
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
