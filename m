Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3646B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 16:48:13 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e26so18957186pfi.15
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 13:48:13 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a30si6316093pgn.797.2017.12.21.13.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 13:48:12 -0800 (PST)
Date: Thu, 21 Dec 2017 14:48:10 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/2] Introduce __cond_lock_err
Message-ID: <20171221214810.GC9087@linux.intel.com>
References: <20171219165823.24243-1-willy@infradead.org>
 <20171219165823.24243-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219165823.24243-2-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Josh Triplett <josh@joshtriplett.org>, Matthew Wilcox <mawilcox@microsoft.com>

On Tue, Dec 19, 2017 at 08:58:23AM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The __cond_lock macro expects the function to return 'true' if the lock
> was acquired and 'false' if it wasn't.  We have another common calling
> convention in the kernel, which is returning 0 on success and an errno
> on failure.  It's hard to use the existing __cond_lock macro for those
> kinds of functions, so introduce __cond_lock_err() and convert the
> two existing users.

This is much cleaner!  One quick issue below.

> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/compiler_types.h | 2 ++
>  include/linux/mm.h             | 9 ++-------
>  mm/memory.c                    | 9 ++-------
>  3 files changed, 6 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/compiler_types.h b/include/linux/compiler_types.h
> index 6b79a9bba9a7..ff3c41c78efa 100644
> --- a/include/linux/compiler_types.h
> +++ b/include/linux/compiler_types.h
> @@ -16,6 +16,7 @@
>  # define __acquire(x)	__context__(x,1)
>  # define __release(x)	__context__(x,-1)
>  # define __cond_lock(x,c)	((c) ? ({ __acquire(x); 1; }) : 0)
> +# define __cond_lock_err(x,c)	((c) ? 1 : ({ __acquire(x); 0; }))
					       ^
I think we actually want this to return c here ^

The old code saved off the actual return value from __follow_pte_pmd() (say,
-EINVAL) in 'res', and that was what was returned on error from both
follow_pte_pmd() and follow_pte().  The value of 1 returned by __cond_lock()
was just discarded (after we cast it to void for some reason).

With this new code we actually return the value from __cond_lock_err(), which
means that instead of returning -EINVAL, we'll return 1 on error.

>  # define __percpu	__attribute__((noderef, address_space(3)))
>  # define __rcu		__attribute__((noderef, address_space(4)))
>  # define __private	__attribute__((noderef))
> @@ -42,6 +43,7 @@ extern void __chk_io_ptr(const volatile void __iomem *);
>  # define __acquire(x) (void)0
>  # define __release(x) (void)0
>  # define __cond_lock(x,c) (c)
> +# define __cond_lock_err(x,c) (c)
>  # define __percpu
>  # define __rcu
>  # define __private
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 94a9d2149bd6..2ccdc980296b 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1328,13 +1328,8 @@ static inline int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
>  			     unsigned long *start, unsigned long *end,
>  			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
>  {
> -	int res;
> -
> -	/* (void) is needed to make gcc happy */
> -	(void) __cond_lock(*ptlp,
> -			   !(res = __follow_pte_pmd(mm, address, start, end,
> -						    ptepp, pmdpp, ptlp)));
> -	return res;
> +	return __cond_lock_err(*ptlp, __follow_pte_pmd(mm, address, start, end,
> +						    ptepp, pmdpp, ptlp));
>  }
>  
>  static inline void unmap_shared_mapping_range(struct address_space *mapping,
> diff --git a/mm/memory.c b/mm/memory.c
> index cb433662af21..92d58309cf45 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4269,13 +4269,8 @@ int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
>  static inline int follow_pte(struct mm_struct *mm, unsigned long address,
>  			     pte_t **ptepp, spinlock_t **ptlp)
>  {
> -	int res;
> -
> -	/* (void) is needed to make gcc happy */
> -	(void) __cond_lock(*ptlp,
> -			   !(res = __follow_pte_pmd(mm, address, NULL, NULL,
> -						    ptepp, NULL, ptlp)));
> -	return res;
> +	return __cond_lock_err(*ptlp, __follow_pte_pmd(mm, address, NULL, NULL,
> +						    ptepp, NULL, ptlp));
>  }
>  
>  /**
> -- 
> 2.15.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
