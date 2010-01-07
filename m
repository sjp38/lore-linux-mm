Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F28226B00A1
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 22:03:18 -0500 (EST)
Date: Thu, 7 Jan 2010 11:59:01 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: mmotm 2010-01-06-14-34 uploaded (mm/memcontrol)
Message-Id: <20100107115901.594330d0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100107112150.2e585f1c.kamezawa.hiroyu@jp.fujitsu.com>
References: <201001062259.o06MxQrp023236@imap1.linux-foundation.org>
	<20100106171058.f1d6f393.randy.dunlap@oracle.com>
	<20100107111319.7d95fe86.nishimura@mxp.nes.nec.co.jp>
	<20100107112150.2e585f1c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Randy Dunlap <randy.dunlap@oracle.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thank you for your fix.

On Thu, 7 Jan 2010 11:21:50 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 7 Jan 2010 11:13:19 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Thank you for your report.
>  
> > > config attached.
> > > 
> > I'm sorry I missed the !CONFIG_SWAP or !CONFIG_CGROUP_MEM_RES_CTLR_SWAP case.
> > 
> > I'll prepare fixes.
> > 
> Nishimura-san, could you double check this ?
> 
It seems that this cannot fix the !CONFIG_SWAP case in my environment.

> Andrew, this is a fix onto Nishimura-san's memcg move account patch series.
> Maybe this -> patches/memcg-move-charges-of-anonymous-swap.patch
> 
I think both memcg-move-charges-of-anonymous-swap.patch and
memcg-improve-performance-in-moving-swap-charge.patch need to be fixed.

> mm/memcontrol.c: In function 'is_target_pte_for_mc':
> mm/memcontrol.c:3985: error: implicit declaration of function 'mem_cgroup_count_swap_user'
This derives from a bug of memcg-move-charges-of-anonymous-swap.patch,

and

> mm/memcontrol.c: In function 'mem_cgroup_move_charge_pte_range':
> mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
> mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
> mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
this derives from that of memcg-improve-performance-in-moving-swap-charge.patch.


I'm now testing my patch in some configs, and will post later.


Thanks,
Daisuke Nishimura.

> Thanks,
> -Kame
> ==
> 
> Build fix to following build error when CONFIG_CGROUP_MEM_RES_CTLR_SWAP is off.
> 
> mm/memcontrol.c: In function 'is_target_pte_for_mc':
> mm/memcontrol.c:3985: error: implicit declaration of function 'mem_cgroup_count_swap_user'
> mm/memcontrol.c: In function 'mem_cgroup_move_charge_pte_range':
> mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
> mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
> mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
> 
> CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: ref-mmotm/mm/memcontrol.c
> ===================================================================
> --- ref-mmotm.orig/mm/memcontrol.c
> +++ ref-mmotm/mm/memcontrol.c
> @@ -2369,7 +2369,7 @@ static int mem_cgroup_move_swap_account(
>  }
>  #else
>  static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
> -				struct mem_cgroup *from, struct mem_cgroup *to)
> +		struct mem_cgroup *from, struct mem_cgroup *to, bool need_fixup)
>  {
>  	return -EINVAL;
>  }
> @@ -3976,7 +3976,7 @@ static int is_target_pte_for_mc(struct v
>  
>  	if (!pte_present(ptent)) {
>  		/* TODO: handle swap of shmes/tmpfs */
> -		if (pte_none(ptent) || pte_file(ptent))
> +		if (pte_none(ptent) || pte_file(ptent) || !do_swap_account)
>  			return 0;
>  		else if (is_swap_pte(ptent)) {
>  			ent = pte_to_swp_entry(ptent);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
