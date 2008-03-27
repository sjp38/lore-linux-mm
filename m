Message-ID: <47EB4A7E.6060505@openvz.org>
Date: Thu, 27 Mar 2008 10:19:26 +0300
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC][2/3] Account and control virtual address space allocations
 (v2)
References: <20080326184954.9465.19379.sendpatchset@localhost.localdomain> <20080326185017.9465.29950.sendpatchset@localhost.localdomain>
In-Reply-To: <20080326185017.9465.29950.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Changelog v2
> ------------
> Change the accounting to what is already present in the kernel. Split
> the address space accounting into mem_cgroup_charge_as and
> mem_cgroup_uncharge_as. At the time of VM expansion, call
> mem_cgroup_cannot_expand_as to check if the new allocation will push
> us over the limit
> 
> This patch implements accounting and control of virtual address space.
> Accounting is done when the virtual address space of any task/mm_struct
> belonging to the cgroup is incremented or decremented. This patch
> fails the expansion if the cgroup goes over its limit.
> 
> TODOs
> 
> 1. Only when CONFIG_MMU is enabled, is the virtual address space control
>    enabled. Should we do this for nommu cases as well? My suspicion is
>    that we don't have to.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  arch/ia64/kernel/perfmon.c  |    2 +
>  arch/x86/kernel/ptrace.c    |    7 +++
>  fs/exec.c                   |    2 +
>  include/linux/memcontrol.h  |   26 +++++++++++++
>  include/linux/res_counter.h |   19 ++++++++--
>  init/Kconfig                |    2 -
>  kernel/fork.c               |   17 +++++++--
>  mm/memcontrol.c             |   83 ++++++++++++++++++++++++++++++++++++++++++++
>  mm/mmap.c                   |   11 +++++
>  mm/mremap.c                 |    2 +
>  10 files changed, 163 insertions(+), 8 deletions(-)
> 
> diff -puN mm/memcontrol.c~memory-controller-virtual-address-space-accounting-and-control mm/memcontrol.c
> --- linux-2.6.25-rc5/mm/memcontrol.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 16:27:59.000000000 +0530
> +++ linux-2.6.25-rc5-balbir/mm/memcontrol.c	2008-03-27 00:18:16.000000000 +0530
> @@ -526,6 +526,76 @@ unsigned long mem_cgroup_isolate_pages(u
>  	return nr_taken;
>  }
>  
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_AS
> +/*
> + * Charge the address space usage for cgroup. This routine is most
> + * likely to be called from places that expand the total_vm of a mm_struct.
> + */
> +void mem_cgroup_charge_as(struct mm_struct *mm, long nr_pages)
> +{
> +	struct mem_cgroup *mem;
> +
> +	if (mem_cgroup_subsys.disabled)
> +		return;
> +
> +	rcu_read_lock();
> +	mem = rcu_dereference(mm->mem_cgroup);
> +	css_get(&mem->css);
> +	rcu_read_unlock();
> +
> +	res_counter_charge(&mem->as_res, (nr_pages * PAGE_SIZE));
> +	css_put(&mem->css);

Why don't you check whether the counter is charged? This is
bad for two reasons:
1. you allow for some growth above the limit (e.g. in expand_stack)
2. you will undercharge it in the future when uncharging the
   vme, whose charge was failed and thus unaccounted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
