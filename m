Date: Mon, 14 Apr 2008 19:17:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] use vmalloc for mem_cgroup allocation. v2
Message-Id: <20080414191730.7d13e619.akpm@linux-foundation.org>
In-Reply-To: <20080415111038.ffac0e12.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080415105434.3044afb6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080415111038.ffac0e12.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, lizf@cn.fujitsu.com, menage@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Apr 2008 11:10:38 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On ia64, this kmalloc() requires order-4 pages. But this is not
> necessary to be phisically contiguous. (and x86-32, which has
> small vmalloc area, has small mem_cgroup struct.)
> 
> For here, vmalloc is better.
> 
> Changelog: v1->v2
>  - added memset().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Index: mm-2.6.25-rc8-mm2/mm/memcontrol.c
> ===================================================================
> --- mm-2.6.25-rc8-mm2.orig/mm/memcontrol.c
> +++ mm-2.6.25-rc8-mm2/mm/memcontrol.c
> @@ -31,6 +31,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/fs.h>
>  #include <linux/seq_file.h>
> +#include <linux/vmalloc.h>
>  
>  #include <asm/uaccess.h>
>  
> @@ -992,8 +993,10 @@ mem_cgroup_create(struct cgroup_subsys *
>  	if (unlikely((cont->parent) == NULL)) {
>  		mem = &init_mem_cgroup;
>  		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
> -	} else
> -		mem = kzalloc(sizeof(struct mem_cgroup), GFP_KERNEL);
> +	} else {
> +		mem = vmalloc(sizeof(struct mem_cgroup));
> +		memset(mem, 0, sizeof(*mem));
> +	}
>  
>  	if (mem == NULL)
>  		return ERR_PTR(-ENOMEM);
> @@ -1011,7 +1014,7 @@ free_out:
>  	for_each_node_state(node, N_POSSIBLE)
>  		free_mem_cgroup_per_zone_info(mem, node);
>  	if (cont->parent != NULL)
> -		kfree(mem);
> +		vfree(mem);
>  	return ERR_PTR(-ENOMEM);
>  }
>  
> @@ -1031,7 +1034,7 @@ static void mem_cgroup_destroy(struct cg
>  	for_each_node_state(node, N_POSSIBLE)
>  		free_mem_cgroup_per_zone_info(mem, node);
>  
> -	kfree(mem_cgroup_from_cont(cont));
> +	vfree(mem_cgroup_from_cont(cont));
>  }
>  
>  static int mem_cgroup_populate(struct cgroup_subsys *ss,

Well...  vmalloced memory is of course a little slower to use - additional
TLB pressure.

Do you think the memcgroup is accessed frequently enough to use vmalloc()
only on those architectures which actually need it?

Because it'd be pretty simple to implement:

	if (sizeof(struct mem_group) > PAGE_SIZE)
		vmalloc()
	else
		kmalloc()

	...

	if (sizeof(struct mem_group) > PAGE_SIZE)
		vfree()
	else
		kfree()

the compiler will optimise away the `if'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
