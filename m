Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C2B8A6B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 07:37:56 -0400 (EDT)
Date: Fri, 8 May 2009 13:38:20 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 2/2] memcg fix stale swap cache account leak v6
Message-ID: <20090508113820.GL11596@elte.hu>
References: <20090508140528.c34ae712.kamezawa.hiroyu@jp.fujitsu.com> <20090508140910.bb07f5c6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090508140910.bb07f5c6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

x
* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> +struct swapio_check {
> +	spinlock_t	lock;
> +	void		*swap_bio_list;
> +	struct delayed_work work;
> +} stale_swap_check;

Small nit. It's nice that you lined up the first two fields, but it 
would be nice to line up the third one too:

struct swapio_check {
	spinlock_t		lock;
	void			*swap_bio_list;
	struct delayed_work	work;
} stale_swap_check;

> +	while (nr--) {
> +		cond_resched();
> +		spin_lock_irq(&sc->lock);
> +		bio = sc->swap_bio_list;

> @@ -66,6 +190,7 @@ static void end_swap_bio_write(struct bi
>  				(unsigned long long)bio->bi_sector);
>  		ClearPageReclaim(page);
>  	}
> +	mem_cgroup_swapio_check_again(bio, page);

Hm, this patch adds quite a bit of scanning overhead to 
end_swap_bio_write(), to work around artifacts of a global LRU not 
working well with a partitioned system's per-partition LRU needs.

Isnt the right solution to have a better LRU that is aware of this, 
instead of polling around in the hope of cleaning up stale entries?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
