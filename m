Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2EF6B0047
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 19:51:17 -0500 (EST)
Date: Fri, 5 Feb 2010 09:38:06 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 7/8] memcg: move charges of anonymous swap
Message-Id: <20100205093806.5699d406.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100204164441.d012f6fa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221143816.9794cd17.nishimura@mxp.nes.nec.co.jp>
	<20100203193127.fe5efa17.akpm@linux-foundation.org>
	<20100204140942.0ef6d7b1.nishimura@mxp.nes.nec.co.jp>
	<20100204142736.2a8bec26.kamezawa.hiroyu@jp.fujitsu.com>
	<20100204071840.GC5574@linux-sh.org>
	<20100204164441.d012f6fa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Feb 2010 16:44:41 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 4 Feb 2010 16:18:40 +0900
> Paul Mundt <lethal@linux-sh.org> wrote:
> 
> > On Thu, Feb 04, 2010 at 02:27:36PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> > > I think memcg should depends on CONIFG_MMU.
> > > 
> > > How do you think ?
> > > 
> > Unless there's a real technical reason to make it depend on CONFIG_MMU,
> > that's just papering over the problem, and means that some nommu person
> > will have to come back and fix it properly at a later point in time.
> > 
> I have no strong opinion this. It's ok to support as much as possible.
> My concern is that there is no !MMU architecture developper around memcg. So,
> error report will be delayed.
> 
I agree with you and Paul.

> 
> > CONFIG_SWAP itself is configurable even with CONFIG_MMU=y, so having
> > stubbed out helpers for the CONFIG_SWAP=n case would give the compiler a
> > chance to optimize things away in those cases, too. Embedded systems
> > especially will often have MMU=y and BLOCK=n, resulting in SWAP being
> > unset but swap cache encodings still defined.
> > 
> > How about just changing the is_swap_pte() definition to depend on SWAP
> > instead?
> > 
> I think the new feature as "move task charge" itself depends on CONFIG_MMU
> because it walks a process's page table. 
> 
> Then, how about this ? (sorry, I can't test this in valid way..)
> 
I agree to this direction of making "move charge" depend on CONFIG_MMU,
although I can't test !CONFIG_MMU case either.

Several comments are inlined.
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, "move charges at task move" feature depends on page tables. So,
> it doesn't work in !CONIFG_MMU enviroments.
> This patch moves "task move" codes under CONIFG_MMU.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memory.txt |    2 ++
>  mm/memcontrol.c                  |   39 ++++++++++++++++++++++++++++++++++++---
>  2 files changed, 38 insertions(+), 3 deletions(-)
> 
> Index: mmotm-2.6.33-Feb3/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-2.6.33-Feb3.orig/Documentation/cgroups/memory.txt
> +++ mmotm-2.6.33-Feb3/Documentation/cgroups/memory.txt
> @@ -420,6 +420,8 @@ NOTE2: It is recommended to set the soft
>  
>  Users can move charges associated with a task along with task migration, that
>  is, uncharge task's pages from the old cgroup and charge them to the new cgroup.
> +This feature is not supporetd in !CONFIG_MMU environmetns because of lack of
> +page tables.
>  
>  8.1 Interface
>  
> Index: mmotm-2.6.33-Feb3/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.33-Feb3.orig/mm/memcontrol.c
> +++ mmotm-2.6.33-Feb3/mm/memcontrol.c
> @@ -20,7 +20,6 @@
>   * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>   * GNU General Public License for more details.
>   */
> -
>  #include <linux/res_counter.h>
>  #include <linux/memcontrol.h>
>  #include <linux/cgroup.h>
Is this deletion necessary ? ;)

> @@ -2281,6 +2280,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
>  	rcu_read_unlock();
>  }
>  
> +#ifdef CONFIG_MMU /* this is used for task_move */
>  /**
>   * mem_cgroup_move_swap_account - move swap charge and swap_cgroup's record.
>   * @entry: swap entry to be moved
> @@ -2332,6 +2332,7 @@ static int mem_cgroup_move_swap_account(
>  	}
>  	return -EINVAL;
>  }
> +#endif
>  #else
>  static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
>  		struct mem_cgroup *from, struct mem_cgroup *to, bool need_fixup)
I think these ifdefs are inside CONFIG_CGROUP_MEM_RES_CTLR_SWAP, which depends
on CONFIG_SWAP, so they are not needed.

> @@ -3027,6 +3028,7 @@ static u64 mem_cgroup_move_charge_read(s
>  	return mem_cgroup_from_cont(cgrp)->move_charge_at_immigrate;
>  }
>  
> +#ifdef CONIFG_MMU
>  static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
>  					struct cftype *cft, u64 val)
>  {
> @@ -3045,7 +3047,13 @@ static int mem_cgroup_move_charge_write(
>  
>  	return 0;
>  }
> -
> +#else
> +static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
> +				struct cftype *cft, u64 val)
> +{
> +	return -EINVAL;
> +}
> +#endif
>  
>  /* For read statistics */
>  enum {
It's a good idea, but I'm not sure which we should return -EINVAL or -ENOSYS.

> @@ -3846,6 +3854,7 @@ static int mem_cgroup_populate(struct cg
>  	return ret;
>  }
>  
> +#ifdef CONFIG_MMU
>  /* Handlers for move charge at task migration. */
>  #define PRECHARGE_COUNT_AT_ONCE	256
>  static int mem_cgroup_do_precharge(unsigned long count)
> @@ -3901,7 +3910,6 @@ one_by_one:
>  	}
>  	return ret;
>  }
> -
>  /**
>   * is_target_pte_for_mc - check a pte whether it is valid for move charge
>   * @vma: the vma the pte to be checked belongs
> @@ -4243,6 +4251,31 @@ static void mem_cgroup_move_charge(struc
>  	}
>  	up_read(&mm->mmap_sem);
>  }
> +#else
> +
> +static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> +	struct cgroup *cgroup,
> +	struct task_struct *p,
> +	bool threadgroup)
> +{
> +	return 0;
> +}
> +
> +static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
> +		struct cgroup *cgroup,
> +		struct task_struct *p,
> +		bool threadgroup)
> +{
> +}
> +
> +static void mem_cgroup_move_charge(struct mm_struct *mm)
> +{
> +}
> +
> +static void mem_cgroup_clear_mc(void)
> +{
> +}
> +#endif
>  
>  static void mem_cgroup_move_task(struct cgroup_subsys *ss,
>  				struct cgroup *cont,
> 
Other parts look good to me.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
