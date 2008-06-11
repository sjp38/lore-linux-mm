Date: Wed, 11 Jun 2008 16:24:27 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
Message-Id: <20080611162427.3ef63098.randy.dunlap@oracle.com>
In-Reply-To: <20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	<20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Jun 2008 14:01:53 +0900 KAMEZAWA Hiroyuki wrote:

> A simple hard-wall hierarhcy support for res_counter.
> 
> Changelog v2->v3
>  - changed the name and arguments of functions.
>  - rewrote to be read easily.
>  - named as HardWall hierarchy.

> ---
>  Documentation/controllers/resource_counter.txt |   41 +++++++++
>  include/linux/res_counter.h                    |   90 +++++++++++++++++++-
>  kernel/res_counter.c                           |  112 +++++++++++++++++++++++--
>  3 files changed, 235 insertions(+), 8 deletions(-)
> 
> Index: temp-2.6.26-rc2-mm1/include/linux/res_counter.h
> ===================================================================
> --- temp-2.6.26-rc2-mm1.orig/include/linux/res_counter.h
> +++ temp-2.6.26-rc2-mm1/include/linux/res_counter.h
> @@ -76,15 +97,33 @@ enum {
>  	RES_MAX_USAGE,
>  	RES_LIMIT,
>  	RES_FAILCNT,
> +	RES_FOR_CHILDREN,
>  };
>  
>  /*
>   * helpers for accounting
>   */
>  
> +/*
> + * initialize res_counter.
> + * @counter : the counter
> + *
> + * initialize res_counter and set default limit to very big value(unlimited)
> + */
> +
>  void res_counter_init(struct res_counter *counter);

For these non-static (non-private) functions, please use kernel-doc notation
(see Documentation/kernel-doc-nano-HOWTO.txt and/or examples in other source files).
Also, we prefer for the function documentation to be above its definition (implementation)
rather than above its declaration, so the kernel-doc should be moved to .c files
instead of living in .h files.


>  
>  /*
> + * initialize res_counter under hierarchy.
> + * @counter : the counter
> + * @parent : the parent of the counter
> + *
> + * initialize res_counter and set default limit to 0. and set "parent".
> + */
> +void res_counter_init_hierarchy(struct res_counter *counter,
> +				struct res_counter *parent);
> +
> +/*
>   * charge - try to consume more resource.
>   *
>   * @counter: the counter
> @@ -153,4 +192,51 @@ static inline void res_counter_reset_fai
>  	cnt->failcnt = 0;
>  	spin_unlock_irqrestore(&cnt->lock, flags);
>  }
> +
> +/**
> + * Move resources from a parent to a child.
> + * At success,
> + *           parent->usage += val.
> + *           parent->for_children += val.
> + *           child->limit += val.
> + *
> + * @child:    an entity to set res->limit. The parent is child->parent.
> + * @val:      the amount of resource to be moved.
> + * @callback: called when the parent's free resource is not enough to be moved.
> + *            this can be NULL if no callback is necessary.
> + * @retry:    limit for the number of trying to callback.
> + *            -1 means infinite loop. At each retry, yield() is called.
> + * Returns 0 at success, !0 at failure.
> + *
> + * The callback returns 0 at success, !0 at failure.
> + *
> + */
> +
> +int res_counter_move_resource(struct res_counter *child,
> +	unsigned long long val,
> +        int (*callback)(struct res_counter *res, unsigned long long val),
> +	int retry);
> +
> +
> +/**
> + * Return resource to its parent.
> + * At success,
> + *           parent->usage  -= val.
> + *           parent->for_children -= val.
> + *           child->limit -= val.
> + *
> + * @child:   entry to resize. The parent is child->parent.
> + * @val  :   How much does child repay to parent ? -1 means 'all'
> + * @callback: A callback for decreasing resource usage of child before
> + *            returning. If NULL, just deceases child's limit.
> + * @retry:   # of retries at calling callback for freeing resource.
> + *            -1 means infinite loop. At each retry, yield() is called.
> + * Returns 0 at success.
> + */
> +
> +int res_counter_return_resource(struct res_counter *child,
> +	unsigned long long val,
> +	int (*callback)(struct res_counter *res, unsigned long long val),
> +	int retry);
> +
>  #endif
> Index: temp-2.6.26-rc2-mm1/Documentation/controllers/resource_counter.txt
> ===================================================================
> --- temp-2.6.26-rc2-mm1.orig/Documentation/controllers/resource_counter.txt
> +++ temp-2.6.26-rc2-mm1/Documentation/controllers/resource_counter.txt
> @@ -179,3 +186,37 @@ counter fields. They are recommended to 
>      still can help with it).
>  
>   c. Compile and run :)
> +
> +
> +6. Hierarchy
> + a. No Hierarchy
> +   each cgroup can use its own private resource.
> +
> + b. Hard-wall Hierarhcy
> +   A simple hierarchical tree system for resource isolation.
> +   Allows moving resources only between a parent and its children.
> +   A parent can move its resource to children and remember the amount to
> +   for_children member. A child can get new resource only from its parent.
> +   Limit of a child is the amount of resource which is moved from its parent.
> +
> +   When add "val" to a child,
> +	parent->usage += val
> +	parent->for_children += val
> +	child->limit += val
> +   When a child returns its resource
> +	parent->usage -= val
> +	parent->for_children -= val
> +	child->limit -= val.
> +
> +   This implements resource isolation among each group. This works very well
> +   when you want to use strict resource isolation.
> +
> +   Usage Hint:
> +   This seems for static resource assignment but dynamic resource re-assignment

           seems to be?

> +   can be done by resetting "limit" of groups. When you consider "limit" as
> +   the amount of allowed _current_ resource, a sophisticated resource management
> +   system based on strict resource isolation can be implemented.
> +
> +c. Soft-wall Hierarchy
> +   TBD.
> +
> Index: temp-2.6.26-rc2-mm1/kernel/res_counter.c
> ===================================================================
> --- temp-2.6.26-rc2-mm1.orig/kernel/res_counter.c
> +++ temp-2.6.26-rc2-mm1/kernel/res_counter.c
> @@ -20,6 +20,14 @@ void res_counter_init(struct res_counter
>  	counter->limit = (unsigned long long)LLONG_MAX;
>  }
>  
> +void res_counter_init_hierarchy(struct res_counter *counter,
> +		struct res_counter *parent)
> +{
> +	spin_lock_init(&counter->lock);
> +	counter->limit = 0;
> +	counter->parent = parent;
> +}
> +
>  int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
>  {
>  	if (counter->usage + val > counter->limit) {
> @@ -74,6 +82,8 @@ res_counter_member(struct res_counter *c
>  		return &counter->limit;
>  	case RES_FAILCNT:
>  		return &counter->failcnt;
> +	case RES_FOR_CHILDREN:
> +		return &counter->for_children;
>  	};
>  
>  	BUG();
> @@ -104,7 +114,9 @@ u64 res_counter_read_u64(struct res_coun
>  
>  ssize_t res_counter_write(struct res_counter *counter, int member,
>  		const char __user *userbuf, size_t nbytes, loff_t *pos,
> -		int (*write_strategy)(char *st_buf, unsigned long long *val))
> +		int (*write_strategy)(char *st_buf, unsigned long long *val),
> +		int (*set_strategy)(struct res_counter *res,
> +			unsigned long long val, int what))
>  {
>  	int ret;
>  	char *buf, *end;
> @@ -133,13 +145,101 @@ ssize_t res_counter_write(struct res_cou
>  		if (*end != '\0')
>  			goto out_free;
>  	}
> -	spin_lock_irqsave(&counter->lock, flags);
> -	val = res_counter_member(counter, member);
> -	*val = tmp;
> -	spin_unlock_irqrestore(&counter->lock, flags);
> -	ret = nbytes;
> +	if (set_strategy) {
> +		ret = set_strategy(res, tmp, member);
> +		if (!ret)
> +			ret = nbytes;
> +	} else {
> +		spin_lock_irqsave(&counter->lock, flags);
> +		val = res_counter_member(counter, member);
> +		*val = tmp;
> +		spin_unlock_irqrestore(&counter->lock, flags);
> +		ret = nbytes;
> +	}
>  out_free:
>  	kfree(buf);
>  out:
>  	return ret;
>  }
> +
> +
> +int res_counter_move_resource(struct res_counter *child,
> +				unsigned long long val,
> +	int (*callback)(struct res_counter *res, unsigned long long val),
> +	int retry)
> +{
> +	struct res_counter *parent = child->parent;
> +	unsigned long flags;
> +
> +	BUG_ON(!parent);
> +
> +	while (1) {
> +		spin_lock_irqsave(&parent->lock, flags);
> +		if (parent->usage + val < parent->limit) {
> +			parent->for_children += val;
> +			parent->usage += val;
> +			break;
> +		}
> +		spin_unlock_irqrestore(&parent->lock, flags);
> +
> +		if (!retry || !callback)
> +			goto failed;
> +		/* -1 means  infinite loop */
> +		if (retry != -1)
> +			--retry;
> +		yield();
> +		callback(parent, val);
> +	}
> +	spin_unlock_irqrestore(&parent->lock, flags);
> +
> +	spin_lock_irqsave(&child->lock, flags);
> +	child->limit += val;
> +	spin_unlock_irqrestore(&child->lock, flags);
> +	return 0;
> +fail:
> +	return 1;
> +}
> +
> +
> +int res_counter_return_resource(struct res_counter *child,
> +				unsigned long long val,
> +	int (*callback)(struct res_counter *res, unsigned long long val),
> +	int retry)
> +{
> +	unsigned long flags;
> +	struct res_counter *parent = child->parent;
> +
> +	BUG_ON(!parent);
> +
> +	while (1) {
> +		spin_lock_irqsave(&child->lock, flags);
> +		if (val == (unsigned long long) -1) {
> +			val = child->limit;
> +			child->limit = 0;
> +			break;
> +		} else if (child->usage <= child->limit - val) {
> +			child->limit -= val;
> +			break;
> +		}
> +		spin_unlock_irqrestore(&child->lock, flags);
> +
> +		if (!retry)
> +			goto fail;
> +		/* -1 means infinite loop */
> +		if (retry != -1)
> +			--retry;
> +		yield();
> +		callback(parent, val);
> +	}
> +	spin_unlock_irqrestore(&child->lock, flags);
> +
> +	spin_lock_irqsave(&parent->lock, flags);
> +	BUG_ON(parent->for_children < val);
> +	BUG_ON(parent->usage < val);
> +	parent->for_children -= val;
> +	parent->usage -= val;
> +	spin_unlock_irqrestore(&parent->lock, flags);
> +	return 0;
> +fail:
> +	return 1;
> +}
> --


---
~Randy
'"Daemon' is an old piece of jargon from the UNIX operating system,
where it referred to a piece of low-level utility software, a
fundamental part of the operating system."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
