Date: Wed, 13 Aug 2003 13:55:38 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] Add support for more than 256 zones
Message-Id: <20030813135538.19c96c67.akpm@osdl.org>
In-Reply-To: <3F3A9E46.6010803@sgi.com>
References: <3F3A9E46.6010803@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jay Lan <jlan@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jay Lan <jlan@sgi.com> wrote:
>
> This patch is to support more than 256 zones for large systems.
> The changes is to add #ifdef CONFIG_IA64 to mm.h to give different
> #define to ZONE_SHIFT.
> 
> Thanks,
>   - jay lan
> 
> 
> diff -urN a-2.5.75/include/linux/mm.h b-2.5.75/include/linux/mm.h
> --- a-2.5.75/include/linux/mm.h     Thu Jul 10 13:04:45 2003
> +++ b-2.5.75/include/linux/mm.h     Tue Aug 12 17:20:22 2003
> @@ -323,7 +323,11 @@
>    * sets it, so none of the operations on it need to be atomic.
>    */
>   #define NODE_SHIFT 4
> +#ifdef CONFIG_IA64
> +#define ZONE_SHIFT (BITS_PER_LONG - 10)
> +#else
>   #define ZONE_SHIFT (BITS_PER_LONG - 8)
> +#endif

Yes, this is good - it gives us five more page flags on 32-bit machines. 
Assuming that no 32 bit machiens will ever need more than three zones(?)

Please do it this way:

#ifndef ARCH_NR_ZONES_SHIFT
#define ARCH_NR_ZONES_SHIFT	3
#endif

#define ZONE_SHIFT (BITS_PER_LONG - ARCH_NR_ZONES_SHIFT)


and, in asm-ia64/page.h:

#define ARCH_NR_ZONES	10	/* 1024 zones */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
