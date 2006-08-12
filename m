Message-ID: <44640.81.207.0.53.1155403862.squirrel@81.207.0.53>
In-Reply-To: <20060812141445.30842.47336.sendpatchset@lappy>
References: <20060812141415.30842.78695.sendpatchset@lappy>
    <20060812141445.30842.47336.sendpatchset@lappy>
Date: Sat, 12 Aug 2006 19:31:02 +0200 (CEST)
Subject: Re: [RFC][PATCH 3/4] deadlock prevention core
From: "Indan Zupancic" <indan@nul.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Sat, August 12, 2006 16:14, Peter Zijlstra said:
> +struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask, int fclone)
> +{
> +	struct sk_buff *skb;
> +
> +	skb = ___alloc_skb(size, gfp_mask & ~__GFP_MEMALLOC, fclone);
> +
> +	if (!skb && (gfp_mask & __GFP_MEMALLOC) && memalloc_skbs_available())
> +		skb = ___alloc_skb(size, gfp_mask, fclone);
> +
> +	return skb;
> +}
> +

I'd drop the memalloc_skbs_available() check, as that's already done by
___alloc_skb.

> +static DEFINE_SPINLOCK(memalloc_lock);
> +static int memalloc_socks;
> +static unsigned long memalloc_reserve;

Why is this a long? adjust_memalloc_reserve() takes an int.
Is it needed at all, considering var_free_kbytes already exists?

Greetings,

Indan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
