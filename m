Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1E49D6B0085
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 02:29:35 -0400 (EDT)
Subject: Re: [RFC PATCH 1/3] kmemleak: Allow partial freeing of memory
 blocks
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090706105149.16051.99106.stgit@pc1117.cambridge.arm.com>
References: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
	 <20090706105149.16051.99106.stgit@pc1117.cambridge.arm.com>
Date: Tue, 07 Jul 2009 10:12:13 +0300
Message-Id: <1246950733.24285.10.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-07-06 at 11:51 +0100, Catalin Marinas wrote:
> @@ -552,8 +558,29 @@ static void delete_object(unsigned long ptr)
>  	 */
>  	spin_lock_irqsave(&object->lock, flags);
>  	object->flags &= ~OBJECT_ALLOCATED;
> +	start = object->pointer;
> +	end = object->pointer + object->size;
> +	min_count = object->min_count;
>  	spin_unlock_irqrestore(&object->lock, flags);
>  	put_object(object);
> +
> +	if (!size)
> +		return;
> +
> +	/*
> +	 * Partial freeing. Just create one or two objects that may result
> +	 * from the memory block split.
> +	 */
> +	if (in_atomic())
> +		gfp_flags = GFP_ATOMIC;
> +	else
> +		gfp_flags = GFP_KERNEL;

Are you sure we can do this? There's a big fat comment on top of
in_atomic() that suggest this is not safe. Why do we need to create the
object here anyway and not in the _alloc_ paths where gfp flags are
explicitly passed?

> +
> +	if (ptr > start)
> +		create_object(start, ptr - start, min_count, gfp_flags);
> +	if (ptr + size < end)
> +		create_object(ptr + size, end - ptr - size, min_count,
> +			      gfp_flags);
>  }
>  
>  /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
