Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 895806B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 20:32:21 -0400 (EDT)
Subject: Re: [PATCH] mm: mremap: validate input before taking lock
References: <1370000443-5906-1-git-send-email-linux@rasmusvillemoes.dk>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Thu, 06 Jun 2013 00:32:19 +0000
In-Reply-To: <1370000443-5906-1-git-send-email-linux@rasmusvillemoes.dk> (Rasmus
 Villemoes's message of "Fri, 31 May 2013 11:40:43 +0000")
Message-ID: <u0lk3m83wq4.fsf@orc02.imf.au.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Ping...

Rasmus Villemoes <linux@rasmusvillemoes.dk> writes:

> This patch is very similar to 84d96d897671: Perform some basic
> validation of the input to mremap() before taking the
> &current->mm->mmap_sem lock. This also makes the MREMAP_FIXED =>
> MREMAP_MAYMOVE dependency slightly more explicit.
>
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>  mm/mremap.c |   18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
>
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 463a257..00b6905 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -456,13 +456,14 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>  	unsigned long charged = 0;
>  	bool locked = false;
>  
> -	down_write(&current->mm->mmap_sem);
> -
>  	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
> -		goto out;
> +		return ret;
> +
> +	if (flags & MREMAP_FIXED && !(flags & MREMAP_MAYMOVE))
> +		return ret;
>  
>  	if (addr & ~PAGE_MASK)
> -		goto out;
> +		return ret;
>  
>  	old_len = PAGE_ALIGN(old_len);
>  	new_len = PAGE_ALIGN(new_len);
> @@ -473,12 +474,13 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>  	 * a zero new-len is nonsensical.
>  	 */
>  	if (!new_len)
> -		goto out;
> +		return ret;
> +
> +	down_write(&current->mm->mmap_sem);
>  
>  	if (flags & MREMAP_FIXED) {
> -		if (flags & MREMAP_MAYMOVE)
> -			ret = mremap_to(addr, old_len, new_addr, new_len,
> -					&locked);
> +		ret = mremap_to(addr, old_len, new_addr, new_len,
> +				&locked);
>  		goto out;
>  	}
>  
> -- 
> 1.7.9.5
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

-- 
Rasmus Villemoes
<http://rasmusvillemoes.dk/>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
