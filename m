Date: Sat, 23 Feb 2008 00:06:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 15/28] netvm: network reserve infrastructure
Message-Id: <20080223000609.b64b5b36.akpm@linux-foundation.org>
In-Reply-To: <20080220150307.208040000@chello.nl>
References: <20080220144610.548202000@chello.nl>
	<20080220150307.208040000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 15:46:25 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Provide the basic infrastructure to reserve and charge/account network memory.
> 
> We provide the following reserve tree:
> 
> 1)  total network reserve
> 2)    network TX reserve
> 3)      protocol TX pages
> 4)    network RX reserve
> 5)      SKB data reserve
> 
> [1] is used to make all the network reserves a single subtree, for easy
> manipulation.
> 
> [2] and [4] are merely for eastetic reasons.
> 
> The TX pages reserve [3] is assumed bounded by it being the upper bound of
> memory that can be used for sending pages (not quite true, but good enough)
> 
> The SKB reserve [5] is an aggregate reserve, which is used to charge SKB data
> against in the fallback path.
> 
> The consumers for these reserves are sockets marked with:
>   SOCK_MEMALLOC
> 
> Such sockets are to be used to service the VM (iow. to swap over). They
> must be handled kernel side, exposing such a socket to user-space is a BUG.
> 
> +/**
> + *	sk_adjust_memalloc - adjust the global memalloc reserve for critical RX
> + *	@socks: number of new %SOCK_MEMALLOC sockets
> + *	@tx_resserve_pages: number of pages to (un)reserve for TX
> + *
> + *	This function adjusts the memalloc reserve based on system demand.
> + *	The RX reserve is a limit, and only added once, not for each socket.
> + *
> + *	NOTE:
> + *	   @tx_reserve_pages is an upper-bound of memory used for TX hence
> + *	   we need not account the pages like we do for RX pages.
> + */
> +int sk_adjust_memalloc(int socks, long tx_reserve_pages)
> +{
> +	int nr_socks;
> +	int err;
> +
> +	err = mem_reserve_pages_add(&net_tx_pages, tx_reserve_pages);
> +	if (err)
> +		return err;
> +
> +	nr_socks = atomic_read(&memalloc_socks);
> +	if (!nr_socks && socks > 0)
> +		err = mem_reserve_connect(&net_reserve, &mem_reserve_root);

This looks like it should have some locking?

> +	nr_socks = atomic_add_return(socks, &memalloc_socks);
> +	if (!nr_socks && socks)
> +		err = mem_reserve_disconnect(&net_reserve);

Or does that try to make up for it?  Still looks fishy.

> +	if (err)
> +		mem_reserve_pages_add(&net_tx_pages, -tx_reserve_pages);
> +
> +	return err;
> +}
> +
> +/**
> + *	sk_set_memalloc - sets %SOCK_MEMALLOC
> + *	@sk: socket to set it on
> + *
> + *	Set %SOCK_MEMALLOC on a socket and increase the memalloc reserve
> + *	accordingly.
> + */
> +int sk_set_memalloc(struct sock *sk)
> +{
> +	int set = sock_flag(sk, SOCK_MEMALLOC);
> +#ifndef CONFIG_NETVM
> +	BUG();
> +#endif

??  #error, maybe?

> +	if (!set) {
> +		int err = sk_adjust_memalloc(1, 0);
> +		if (err)
> +			return err;
> +
> +		sock_set_flag(sk, SOCK_MEMALLOC);
> +		sk->sk_allocation |= __GFP_MEMALLOC;
> +	}
> +	return !set;
> +}
> +EXPORT_SYMBOL_GPL(sk_set_memalloc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
