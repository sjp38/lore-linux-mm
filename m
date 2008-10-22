Date: Tue, 21 Oct 2008 18:37:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][BUGFIX] memcg: fix page_cgroup allocation
Message-Id: <20081021183738.d3c995b9.akpm@linux-foundation.org>
In-Reply-To: <20081022102404.e1f3565a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081022102404.e1f3565a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "mingo@elte.hu" <mingo@elte.hu>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008 10:24:04 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Andrew, this is a fix to "x86 cannot boot if memcg is enabled" problem in Linus's git-tree,0
> fix to "memcg: allocate all page_cgroup at boot" patch.
> 
> Thank you for all helps!
> (*) I and Balbir tested this. other testers are welcome :)
> -Kame
> ==
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
> (*) maybe this is not very clean but
>     - cgroup_init_early() is too early
>     - in cgroup_init(), we have to use vmalloc instead of alloc_bootmem().
>     use of vmalloc area in x86-32 is important and we should avoid very large
>     vmalloc() in x86-32. So, we want to use alloc_bootmem() and added page_cgroup_init()
>     directly to init/main.c
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Tested-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  init/main.c      |    2 ++
>  mm/memcontrol.c  |    1 -
>  mm/page_cgroup.c |   35 ++++++++++++++++++++++++++++-------
>  3 files changed, 30 insertions(+), 8 deletions(-)
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

no no bad! evil! unclean!

Didn't the linux/cgroup.h -> linux/cgroup_subsys..h inclusion already
declare this for us?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
