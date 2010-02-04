Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A2BA16B0071
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 00:31:09 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o145V6ll027437
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Feb 2010 14:31:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 426DE2E68C1
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 14:31:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 189361EF081
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 14:31:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 04698E18001
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 14:31:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 972361DB8043
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 14:31:05 +0900 (JST)
Date: Thu, 4 Feb 2010 14:27:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 7/8] memcg: move charges of anonymous swap
Message-Id: <20100204142736.2a8bec26.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100204140942.0ef6d7b1.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221143816.9794cd17.nishimura@mxp.nes.nec.co.jp>
	<20100203193127.fe5efa17.akpm@linux-foundation.org>
	<20100204140942.0ef6d7b1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Feb 2010 14:09:42 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 3 Feb 2010 19:31:27 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Mon, 21 Dec 2009 14:38:16 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > This patch is another core part of this move-charge-at-task-migration feature.
> > > It enables moving charges of anonymous swaps.
> > > 
> > > To move the charge of swap, we need to exchange swap_cgroup's record.
> > > 
> > > In current implementation, swap_cgroup's record is protected by:
> > > 
> > >   - page lock: if the entry is on swap cache.
> > >   - swap_lock: if the entry is not on swap cache.
> > > 
> > > This works well in usual swap-in/out activity.
> > > 
> > > But this behavior make the feature of moving swap charge check many conditions
> > > to exchange swap_cgroup's record safely.
> > > 
> > > So I changed modification of swap_cgroup's recored(swap_cgroup_record())
> > > to use xchg, and define a new function to cmpxchg swap_cgroup's record.
> > > 
> > > This patch also enables moving charge of non pte_present but not uncharged swap
> > > caches, which can be exist on swap-out path, by getting the target pages via
> > > find_get_page() as do_mincore() does.
> > > 
> > >
> > > ...
> > >
> > > +		else if (is_swap_pte(ptent)) {
> > 
> > is_swap_pte() isn't implemented for CONFIG_MMU=n, so the build breaks.
> Ah, you're right. I'm sorry I don't have any evironment to test !CONFIG_MMU.
> 
> Using #ifdef like below would be the simplest fix(SWAP is depend on MMU),
> but hmm, #ifdef is ugly.
> 
> I'll prepare another fix.
> 
Hmm..is there any user of memcg in !CONFIG_MMU environment ?
Maybe memcg can be used for controling amount of file cache (per cgroup)..
but..

I think memcg should depends on CONIFG_MMU.

How do you think ?

Thanks,
-Kame

> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> build fix in !CONFIG_MMU case.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 953b18b..85b48cb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3635,6 +3635,7 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
>  					&mc.to->move_charge_at_immigrate);
>  
>  	if (!pte_present(ptent)) {
> +#ifdef CONFIG_SWAP
>  		/* TODO: handle swap of shmes/tmpfs */
>  		if (pte_none(ptent) || pte_file(ptent))
>  			return 0;
> @@ -3644,6 +3645,7 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
>  				return 0;
>  			usage_count = mem_cgroup_count_swap_user(ent, &page);
>  		}
> +#endif
>  	} else {
>  		page = vm_normal_page(vma, addr, ptent);
>  		if (!page || !page_mapped(page))
> -- 
> 1.6.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
