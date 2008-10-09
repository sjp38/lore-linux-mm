Date: Thu, 9 Oct 2008 15:21:32 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 6/6] memcg: lazy lru addition
Message-Id: <20081009152132.df6e54c4.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081001170119.80a617b7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com>
	<20081001170119.80a617b7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Oct 2008 17:01:19 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Delaying add_to_lru() and do it in batched manner like page_vec.
> For doing that 2 flags PCG_USED and PCG_LRU.
> 
> Because __set_page_cgroup_lru() itself doesn't take lock_page_cgroup(),
> we need a sanity check inside lru_lock().
> 
> And this delaying make css_put()/get() complicated. 
> To make it clear,
>  * css_get() is called from mem_cgroup_add_list().
>  * css_put() is called from mem_cgroup_remove_list().
>  * css_get()->css_put() is called while try_charge()->commit/cancel sequence.
> is newly added.
> 

I like this new policy, but

> @@ -710,17 +774,18 @@ static void __mem_cgroup_commit_charge(s

===
                if (PageCgroupLRU(pc)) {
                        ClearPageCgroupLRU(pc);
                        __mem_cgroup_remove_list(mz, pc);
                        css_put(&pc->mem_cgroup->css);
                }
                spin_unlock_irqrestore(&mz->lru_lock, flags);
        }
===

Is this css_put needed yet?

>  	/* Here, PCG_LRU bit is cleared */
>  	pc->mem_cgroup = mem;
>  	/*
> +	 * We have to set pc->mem_cgroup before set USED bit for avoiding
> +	 * race with (delayed) __set_page_cgroup_lru() in other cpu.
> +	 */
> +	smp_wmb();
> +	/*
>  	 * below pcg_default_flags includes PCG_LOCK bit.
>  	 */
>  	pc->flags = pcg_default_flags[ctype];
>  	unlock_page_cgroup(pc);
>  
> -	mz = page_cgroup_zoneinfo(pc);
> -
> -	spin_lock_irqsave(&mz->lru_lock, flags);
> -	__mem_cgroup_add_list(mz, pc, true);
> -	SetPageCgroupLRU(pc);
> -	spin_unlock_irqrestore(&mz->lru_lock, flags);
> +	set_page_cgroup_lru(pc);
> +	css_put(&mem->css);
>  }
>  
>  /**


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
