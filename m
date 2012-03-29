Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 3F6246B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 00:01:47 -0400 (EDT)
Message-ID: <1332993706.3010.3.camel@pasglop>
Subject: Re: [PATCH] mm/memblock.c: Correctly check whether to trim a block
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 29 Mar 2012 15:01:46 +1100
In-Reply-To: <1332987958-10766-1-git-send-email-lauraa@codeaurora.org>
References: <1332987958-10766-1-git-send-email-lauraa@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: linux-mm@kvack.org, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

On Wed, 2012-03-28 at 19:25 -0700, Laura Abbott wrote:
> Currently in __memblock_remove, the check to trim the top of
> a block off only checks if the requested base is less than the
> memblock end. If the end of the requested region is equal to
> the start of a memblock, this will incorrectly try to remove
> the block, possibly causing an integer underflow:
> 
>    ---------------------------------------
>    |                    |                |
>    |                    |                |
>   base              end = rgn->base    rend
> 
> An additional check is needed to see if the end of the requested
> region is greater than the memblock region:

__memblock_remove() open coded logic is gone now, re-implemented
in term of memblock_isolate_range()... though I suppose your
patch might have value in -stable...

Cheers,
Ben.


>    ----------------------
>    |                     |
>    |                     |
>   rgn->base    base     rend      end
>                 |                  |
>                 |                  |
>                 --------------------
> 
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> ---
>  mm/memblock.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 5338237..e174ee0 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -459,7 +459,7 @@ static long __init_memblock __memblock_remove(struct memblock_type *type,
>  		}
>  
>  		/* And check if we need to trim the top of a block */
> -		if (base < rend)
> +		if (base < rend && end > rend)
>  			rgn->size -= rend - base;
>  
>  	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
