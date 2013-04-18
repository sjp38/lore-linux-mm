Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id CA5E26B00CA
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 20:03:24 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id u11so1103452pdi.8
        for <linux-mm@kvack.org>; Wed, 17 Apr 2013 17:03:24 -0700 (PDT)
Date: Wed, 17 Apr 2013 17:03:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Remove unnecessary __builtin_constant_p()
In-Reply-To: <1366225776.8817.28.camel@pippen.local.home>
Message-ID: <alpine.DEB.2.02.1304171702380.24494@chino.kir.corp.google.com>
References: <1366225776.8817.28.camel@pippen.local.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Pekka Enberg <penberg@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Behan Webster <behanw@converseincode.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 17 Apr 2013, Steven Rostedt wrote:

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
> 
> This patch is just a clean up that makes the index_of() code a little
> bit less complex.
> 
> Signed-off-by: Steven Rostedt <rostedt@goodmis.org>

Acked-by: David Rientjes <rientjes@google.com>

Adding Pekka to the cc.

> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 856e4a1..6047900 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -325,9 +325,7 @@ static void cache_reap(struct work_struct *unused);
>  static __always_inline int index_of(const size_t size)
>  {
>  	extern void __bad_size(void);
> -
> -	if (__builtin_constant_p(size)) {
> -		int i = 0;
> +	int i = 0;
>  
>  #define CACHE(x) \
>  	if (size <=x) \
> @@ -336,9 +334,7 @@ static __always_inline int index_of(const size_t size)
>  		i++;
>  #include <linux/kmalloc_sizes.h>
>  #undef CACHE
> -		__bad_size();
> -	} else
> -		__bad_size();
> +	__bad_size();
>  	return 0;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
