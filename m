Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0153C6B008A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 02:30:12 -0400 (EDT)
Subject: Re: [RFC PATCH 3/3] kmemleak: Remove alloc_bootmem annotations
 introduced in the past
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090706105200.16051.4972.stgit@pc1117.cambridge.arm.com>
References: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
	 <20090706105200.16051.4972.stgit@pc1117.cambridge.arm.com>
Date: Tue, 07 Jul 2009 10:12:52 +0300
Message-Id: <1246950772.24285.11.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-07-06 at 11:52 +0100, Catalin Marinas wrote:
> kmemleak_alloc() calls were added in some places where alloc_bootmem was
> called. Since now kmemleak tracks bootmem allocations, these explicit
> calls should be run.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ---
>  kernel/pid.c    |    7 -------
>  mm/page_alloc.c |   14 +++-----------
>  2 files changed, 3 insertions(+), 18 deletions(-)
> 
> diff --git a/kernel/pid.c b/kernel/pid.c
> index 5fa1db4..31310b5 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -36,7 +36,6 @@
>  #include <linux/pid_namespace.h>
>  #include <linux/init_task.h>
>  #include <linux/syscalls.h>
> -#include <linux/kmemleak.h>
>  
>  #define pid_hashfn(nr, ns)	\
>  	hash_long((unsigned long)nr + (unsigned long)ns, pidhash_shift)
> @@ -513,12 +512,6 @@ void __init pidhash_init(void)
>  	pid_hash = alloc_bootmem(pidhash_size *	sizeof(*(pid_hash)));
>  	if (!pid_hash)
>  		panic("Could not alloc pidhash!\n");
> -	/*
> -	 * pid_hash contains references to allocated struct pid objects and it
> -	 * must be scanned by kmemleak to avoid false positives.
> -	 */
> -	kmemleak_alloc(pid_hash, pidhash_size *	sizeof(*(pid_hash)), 0,
> -		       GFP_KERNEL);
>  	for (i = 0; i < pidhash_size; i++)
>  		INIT_HLIST_HEAD(&pid_hash[i]);
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e0f2cdf..202ef6b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4745,8 +4745,10 @@ void *__init alloc_large_system_hash(const char *tablename,
>  			 * some pages at the end of hash table which
>  			 * alloc_pages_exact() automatically does
>  			 */
> -			if (get_order(size) < MAX_ORDER)
> +			if (get_order(size) < MAX_ORDER) {
>  				table = alloc_pages_exact(size, GFP_ATOMIC);
> +				kmemleak_alloc(table, size, 1, GFP_ATOMIC);
> +			}
>  		}
>  	} while (!table && size > PAGE_SIZE && --log2qty);
>  
> @@ -4764,16 +4766,6 @@ void *__init alloc_large_system_hash(const char *tablename,
>  	if (_hash_mask)
>  		*_hash_mask = (1 << log2qty) - 1;
>  
> -	/*
> -	 * If hashdist is set, the table allocation is done with __vmalloc()
> -	 * which invokes the kmemleak_alloc() callback. This function may also
> -	 * be called before the slab and kmemleak are initialised when
> -	 * kmemleak simply buffers the request to be executed later
> -	 * (GFP_ATOMIC flag ignored in this case).
> -	 */
> -	if (!hashdist)
> -		kmemleak_alloc(table, size, 1, GFP_ATOMIC);
> -
>  	return table;
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
