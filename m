Date: Mon, 23 Jun 2008 15:37:47 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 4/6] res_counter: basic hierarchy support
Message-Id: <20080623153747.e20a0485.randy.dunlap@oracle.com>
In-Reply-To: <20080613183402.4f31eb96.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com>
	<20080613183402.4f31eb96.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jun 2008 18:34:02 +0900 KAMEZAWA Hiroyuki wrote:

> Add a hierarhy support to res_counter. This patch itself just supports
> "No Hierarchy" hierarchy, as a default/basic hierarchy system.
> 
> Changelog: v3 -> v4.
>   - cut out from hardwall hierarchy patch set.
>   - just support "No hierarchy" model.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/controllers/resource_counter.txt |   27 +++++-
>  include/linux/res_counter.h                    |   15 +++
>  kernel/res_counter.c                           |  107 ++++++++++++++++++++-----
>  mm/memcontrol.c                                |    1 
>  4 files changed, 129 insertions(+), 21 deletions(-)
> 
> Index: linux-2.6.26-rc5-mm3/kernel/res_counter.c
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/kernel/res_counter.c
> +++ linux-2.6.26-rc5-mm3/kernel/res_counter.c
> +
>  
> +/**
> + * res_counter_set_ops() -- reset res->counter.ops to be passed ops.
> + * @coutner: a counter to be set ops.

typo:
    * @counter:

> + * @ops: res_counter_ops
> + *
> + * This operations is allowed only when there is no parent or parent's
> + * hierarchy_model == RES_CONT_NO_HIERARCHY. returns 0 at success.
> + */
> +
> +int res_counter_set_ops(struct res_counter *counter,
> +				struct res_counter_ops *ops)
> +{
> +	struct res_counter *parent;
> +	/*
> +	 * This operation is allowed only when parents's hierarchy
> +	 * is NO_HIERARCHY or this is ROOT.
> +	 */
> +	parent = counter->parent;
> +	if (parent && parent->ops.hierarchy_model != RES_CONT_NO_HIERARCHY)
> +		return -EINVAL;
> +
> +	counter->ops = *ops;
> +
> +	return 0;
> +}
> +
> +
>  int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
>  {
>  	if (counter->usage + val > counter->limit) {

> Index: linux-2.6.26-rc5-mm3/Documentation/controllers/resource_counter.txt
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/Documentation/controllers/resource_counter.txt
> +++ linux-2.6.26-rc5-mm3/Documentation/controllers/resource_counter.txt
> @@ -39,11 +39,14 @@ to work with it.
>   	The failcnt stands for "failures counter". This is the number of
>  	resource allocation attempts that failed.
>  
> - e. res_counter_ops.
> + e. parent
> +	parent of this res_counter under hierarchy.
> +
> + f. res_counter_ops.
>  	Callbacks for helping resource_counter per each subsystem.
>  	- shrink_usage() .... called at limit change (decrease).
>  
> - f. spinlock_t lock
> + g. spinlock_t lock
>  
>   	Protects changes of the above values.
>  
> @@ -157,7 +160,25 @@ counter fields. They are recommended to 
>       Returns 0 at success. Any error code is acceptable but -EBUSY will be
>       suitable to show "the kernel can't shrink usage."
>  
> -6. Usage example
> +6. Hierarchy
> +
> +   Groups of res_counter can be controlled under some tree (cgroup tree).
> +   Taking the tree into account, res_counter can be under some hierarchical
> +   control. THe res_counter itself supports hierarchy_model and calls

               The 

> +   registered callbacks at suitable events.
> +
> +   For keeping sanity of hierarchy, hierarchy_model of a res_counter can be
> +   changed when parent's hierarchy_model is RES_CONT_NO_HIERARCHY.
> +   res_counter doesn't count # of children by itself but some subysystem should
> +   be aware that it has no children if necessary.
> +   (don't want to fully duplicate cgroup's hierarchy. Cost of remembering parent
> +    is cheap.)
> +
> + a. Independent hierarchy (RES_CONT_NO_HIERARCHY) model
> +   This is no relationship between parent and children.
> +
> +
> +7. Usage example
>  
>   a. Declare a task group (take a look at cgroups subsystem for this) and
>      fold a res_counter into it


---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
