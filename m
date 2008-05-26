Date: Mon, 26 May 2008 09:57:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] swapcgroup: implement charge/uncharge
Message-Id: <20080526095706.c90a0afb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4836AFFD.3060605@mxp.nes.nec.co.jp>
References: <48350F15.9070007@mxp.nes.nec.co.jp>
	<48351095.3040009@mxp.nes.nec.co.jp>
	<20080522163748.74e9bd4f.kamezawa.hiroyu@jp.fujitsu.com>
	<4836AFFD.3060605@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Fri, 23 May 2008 20:52:29 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On 2008/05/22 16:37 +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 22 May 2008 15:20:05 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> >> +#ifdef CONFIG_CGROUP_SWAP_RES_CTLR
> >> +int swap_cgroup_charge(struct page *page,
> >> +			struct swap_info_struct *si,
> >> +			unsigned long offset)
> >> +{
> >> +	int ret;
> >> +	struct page_cgroup *pc;
> >> +	struct mem_cgroup *mem;
> >> +
> >> +	lock_page_cgroup(page);
> >> +	pc = page_get_page_cgroup(page);
> >> +	if (unlikely(!pc))
> >> +		mem = &init_mem_cgroup;
> >> +	else
> >> +		mem = pc->mem_cgroup;
> >> +	unlock_page_cgroup(page);
> > 
> > If !pc, the page is used before memory controller is available. But is it
> > good to be charged to init_mem_cgroup() ?
> I'm sorry, but I can't understand this situation.
> memory controller is initialized at kernel initialization,
> so aren't processes created after it is initialized?
> 
I think add_to_page_cache() may be called before late_init..I'll check again.
(Because I saw some panics related to it, but I noticed this is _swap_ controller
 ...)

> > How about returning 'failure' in this case ? I think returning 'failure' here
> > is not so bad.
> > 
> > 
> Which of below do you mean by 'failure'?
> 
> A. make it fail to get swap entry, so the page cannot be swapped out.
> B. don't charge this swap entry to any cgroup, but the page
>    would be swapped out.
means A.


> 
> I don't want to do B, because I don't want to make such
> not-charged-to-anywhere entries.
> And I've seen several times this condition(!pc) becomes true,
> so I charged to init_mem_cgroup.
> 
> 
> BTW, I noticed that almost all of functions I added by this patch set
> should check "mem_cgroup_subsys.disabled" first because it depend on
> memory cgroup.
> 
Ah, yes, please.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
