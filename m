Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CE4396B0088
	for <linux-mm@kvack.org>; Wed, 27 May 2009 00:12:18 -0400 (EDT)
Date: Wed, 27 May 2009 13:02:46 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 2/5] add SWAP_HAS_CACHE flag to swap_map
Message-Id: <20090527130246.95dadb2c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090526121547.ce866fe4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090526121547.ce866fe4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> @@ -1067,21 +1113,21 @@ static int try_to_unuse(unsigned int typ
>  		}
>  
>  		/*
> -		 * How could swap count reach 0x7fff when the maximum
> -		 * pid is 0x7fff, and there's no way to repeat a swap
> -		 * page within an mm (except in shmem, where it's the
> -		 * shared object which takes the reference count)?
> -		 * We believe SWAP_MAP_MAX cannot occur in Linux 2.4.
> -		 *
> +		 * How could swap count reach 0x7ffe ?
> +		 * There's no way to repeat a swap page within an mm
> +		 * (except in shmem, where it's the shared object which takes
> +		 * the reference count)?
> +		 * We believe SWAP_MAP_MAX cannot occur.(if occur, unsigned
> +		 * short is too small....)
>  		 * If that's wrong, then we should worry more about
>  		 * exit_mmap() and do_munmap() cases described above:
>  		 * we might be resetting SWAP_MAP_MAX too early here.
>  		 * We know "Undead"s can happen, they're okay, so don't
>  		 * report them; but do report if we reset SWAP_MAP_MAX.
>  		 */
> -		if (*swap_map == SWAP_MAP_MAX) {
> +		if (swap_count(*swap_map) == SWAP_MAP_MAX) {
>  			spin_lock(&swap_lock);
> -			*swap_map = 1;
> +			*swap_map = make_swap_count(0, 1);
Can we assume the entry has SWAP_HAS_CACHE here ?
Shouldn't we check PageSwapCache beforehand ?

>  			spin_unlock(&swap_lock);
>  			reset_overflow = 1;
>  		}


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
