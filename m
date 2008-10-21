Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m9LDY7aN028780
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 00:34:07 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9LDZ391130090
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 00:35:04 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9LDZ25j020895
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 00:35:03 +1100
Message-ID: <48FDDA81.5040606@linux.vnet.ibm.com>
Date: Tue, 21 Oct 2008 19:04:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
References: <20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com> <48FD82E3.9050502@cn.fujitsu.com> <20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com> <48FD943D.5090709@cn.fujitsu.com> <20081021175735.0c3d3534.kamezawa.hiroyu@jp.fujitsu.com> <48FD9D30.2030500@cn.fujitsu.com> <20081021182551.0158a47b.kamezawa.hiroyu@jp.fujitsu.com> <48FDA6D4.3090809@cn.fujitsu.com> <20081021191417.02ab97cc.kamezawa.hiroyu@jp.fujitsu.com> <48FDB584.7080608@cn.fujitsu.com> <20081021111951.GB4476@elte.hu> <20081021202325.938678c0.kamezawa.hiroyu@jp.fujitsu.com> <48FDBD18.6090100@linux.vnet.ibm.com> <20081021210015.02c8cacc.kamezawa.hiroyu@jp.fujitsu.com> <48FDC7B0.6040704@linux.vnet.ibm.com> <20081021220927.97df17fa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021220927.97df17fa.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 21 Oct 2008 17:44:40 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>> I got an idea and maybe can send a patch soon. I'm now finding x86-32 box..
>> Please send it to me, I am able to reproduce the problem with my kvm setup on my
>> 32 bit system. I can do a quick test/verification for you.
>>
> Thanks. how about this ? test on x86-64 is done.
> -Kame
> ==
> 
> 
> 
> page_cgroup_init() is called from mem_cgroup_init(). But at this
> point, we cannot call alloc_bootmem().
> (and this caused panic at boot.)
> 
> This patch moves page_cgroup_init() to init/main.c.
> 
> Time table is following:
> ==
>   parse_args(). # we can trust mem_cgroup_subsys.disabled bit after this.
>   ....
>   cgroup_init_early()  # "early" init of cgroup.
>   ....
>   setup_arch()         # memmap is allocated.
>   ...
>   page_cgroup_init();
>   mem_init();   # we cannot call alloc_bootmem after this.
>   ....
>   cgroup_init() # mem_cgroup is initialized.
> ==
> 
> Before page_cgroup_init(), mem_map must be initialized. So, 
> I added page_cgroup_init() to init/main.c directly.
> 
> (*) maybe this is not very clean but cgroup_init_early() is too early
>     and we have to use vmalloc instead of alloc_bootmem() in cgroup_init().
>     usage of vmalloc area in x86-32 is important and we should avoid
>     vmalloc() in x86-32. So, we want to use alloc_bootmem() from
>     sutaible place.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  include/linux/page_cgroup.h |    1 +
>  init/main.c                 |    2 ++
>  mm/memcontrol.c             |    1 -
>  mm/page_cgroup.c            |   35 ++++++++++++++++++++++++++++-------
>  4 files changed, 31 insertions(+), 8 deletions(-)
> 
> Index: linux-2.6/init/main.c
> ===================================================================
> --- linux-2.6.orig/init/main.c
> +++ linux-2.6/init/main.c
> @@ -62,6 +62,7 @@
>  #include <linux/signal.h>
>  #include <linux/idr.h>
>  #include <linux/ftrace.h>
> +#include <linux/page_cgroup.h>
> 
>  #include <asm/io.h>
>  #include <asm/bugs.h>
> @@ -647,6 +648,7 @@ asmlinkage void __init start_kernel(void
>  	vmalloc_init();
>  	vfs_caches_init_early();
>  	cpuset_init_early();
> +	page_cgroup_init();
>  	mem_init();
>  	enable_debug_pagealloc();
>  	cpu_hotplug_init();
> Index: linux-2.6/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.orig/mm/memcontrol.c
> +++ linux-2.6/mm/memcontrol.c
> @@ -1088,7 +1088,6 @@ mem_cgroup_create(struct cgroup_subsys *
>  	int node;
> 
>  	if (unlikely((cont->parent) == NULL)) {
> -		page_cgroup_init();
>  		mem = &init_mem_cgroup;
>  	} else {
>  		mem = mem_cgroup_alloc();
> Index: linux-2.6/include/linux/page_cgroup.h
> ===================================================================
> --- linux-2.6.orig/include/linux/page_cgroup.h
> +++ linux-2.6/include/linux/page_cgroup.h
> @@ -3,6 +3,7 @@
> 
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  #include <linux/bit_spinlock.h>
> +
>  /*
>   * Page Cgroup can be considered as an extended mem_map.
>   * A page_cgroup page is associated with every page descriptor. The
> Index: linux-2.6/mm/page_cgroup.c
> ===================================================================
> --- linux-2.6.orig/mm/page_cgroup.c
> +++ linux-2.6/mm/page_cgroup.c
> @@ -4,7 +4,12 @@
>  #include <linux/bit_spinlock.h>
>  #include <linux/page_cgroup.h>
>  #include <linux/hash.h>
> +#include <linux/slab.h>
>  #include <linux/memory.h>
> +#include <linux/cgroup.h>
> +
> +extern struct cgroup_subsys	mem_cgroup_subsys;
> +
> 
>  static void __meminit
>  __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
> @@ -66,6 +71,9 @@ void __init page_cgroup_init(void)
> 
>  	int nid, fail;
> 
> +	if (mem_cgroup_subsys.disabled)
> +		return;
> +
>  	for_each_online_node(nid)  {
>  		fail = alloc_node_page_cgroup(nid);
>  		if (fail)
> @@ -106,9 +114,14 @@ int __meminit init_section_page_cgroup(u
>  	nid = page_to_nid(pfn_to_page(pfn));
> 
>  	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
> -	base = kmalloc_node(table_size, GFP_KERNEL, nid);
> -	if (!base)
> -		base = vmalloc_node(table_size, nid);
> +	if (slab_is_available()) {
> +		base = kmalloc_node(table_size, GFP_KERNEL, nid);
> +		if (!base)
> +			base = vmalloc_node(table_size, nid);
> +	} else {
> +		base = __alloc_bootmem_node_nopanic(NODE_DATA(nid), table_size,
> +				PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
> +	}
> 
>  	if (!base) {
>  		printk(KERN_ERR "page cgroup allocation failure\n");
> @@ -135,11 +148,16 @@ void __free_page_cgroup(unsigned long pf
>  	if (!ms || !ms->page_cgroup)
>  		return;
>  	base = ms->page_cgroup + pfn;
> -	ms->page_cgroup = NULL;
> -	if (is_vmalloc_addr(base))
> +	if (is_vmalloc_addr(base)) {
>  		vfree(base);
> -	else
> -		kfree(base);
> +		ms->page_cgroup = NULL;
> +	} else {
> +		struct page *page = virt_to_page(base);
> +		if (!PageReserved(page)) { /* Is bootmem ? */
> +			kfree(base);
> +			ms->page_cgroup = NULL;
> +		}
> +	}
>  }
> 
>  int online_page_cgroup(unsigned long start_pfn,
> @@ -213,6 +231,9 @@ void __init page_cgroup_init(void)
>  	unsigned long pfn;
>  	int fail = 0;
> 
> +	if (mem_cgroup_subsys.disabled)
> +		return;
> +
>  	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
>  		if (!pfn_present(pfn))
>  			continue;

Booted on x86_32 for me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Tested-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
