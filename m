Date: Mon, 9 Jun 2008 19:20:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
Message-Id: <20080609192002.b04354c4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <484CFC7F.20300@linux.vnet.ibm.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	<20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
	<484CFC7F.20300@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 09 Jun 2008 15:18:47 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > A simple hard-wall hierarhcy support for res_counter.
> > 
> > Changelog v2->v3
> >  - changed the name and arguments of functions.
> >  - rewrote to be read easily.
> >  - named as HardWall hierarchy.
> > 
> > This implements following model
> >  - A cgroup's tree means hierarchy of resource.
> >  - All child's resource is moved from its parents.
> >  - The resource moved to children is charged as parent's usage.
> >  - The resource moves when child->limit is changed.
> >  - The sum of resource for children and its own usage is limited by "limit".
> > 
> > This implies
> >  - No dynamic automatic hierarhcy balancing in the kernel.
> >  - Each resource is isolated completely.
> >  - The kernel just supports resource-move-at-change-in-limit.
> >  - The user (middle-ware) is responsible to make hierarhcy balanced well.
> 
> We'd definitely like to see a user level tool/application as a demo of how this
> can be achieved.
> 
I don't have one, now. I'll write one when I have time. Need now ?
Hmm...maybe I(we) need some more patches to implement useful statistics,
notifier to middlewares.



> >    Good balance can be achieved by changing limit from user land.
> > 
> > 
> > Background:
> >  Recently, there are popular resource isolation technique widely used,
> >  i.e. Hardware-Virtualization. We can do hierarchical resource isolation
> >  by using cgroup on it. But supporting hierarchy management in croups
> >  has some advantages of performance, unity and costs of management.
> > 
> >  There are good resource management in other OSs, they support some kind of
> >  hierarchical resource management. We wonder what kind of hierarchy policy
> >  is good for Linux. And there is an another point. Hierarchical system can be
> >  implemented by the kernel and user-land co-operation.  So, there are various
> >  choices to do in the kernel. Doing all in the kernel or export some proper
> >  interfaces to the user-land. Middle-wares are tend to be used for management.
> >  I hope there will be Open Source one.
> > 
> >  At supporting hierarchy in cgroup, several aspects of characteristics of
> >  policy of hierarchy can be considered. Some needs automatic balancing
> >  between several groups.
> > 
> >   - fairness    ... how fairness is kept under policy
> > 
> >   - performance ... should be _fast_. multi-level resource balancing tend
> >                  to use much amount of CPU and can cause soft lockup.
> > 
> >   - predictability ... resource management are usually used for resource
> >                  isolation. the kernel must not break the isolation and
> >                  predictability of users against application's progress.
> > 
> >   - flexibility ... some sophisticated dynamic resource balancing with
> >  		 soft-limit is welcomed when the user doesn't want strict
> > 		 resource isolation or when the user cannot estimate how much
> > 		 they want correctly.
> 
> Soft limits has been on my plate for a while now. I'll take a crack at it. At
> the moment the statistics is a bit of a worry, since users/administrators need
> good statistics to take further action.
> 
Yes, statistics is not enough now.



> > 
> > Hard Wall Hierarchy.
> > 
> >  This patch implements a hard-wall model of hierarchy for resources.
> >  Works well for users who want strict resource isolation.
> > 
> >  This model allows the move of resource only between a parent and its children.
> >  The resource is moved to a child when it declares the amount of resources to be
> >  used. (by limit)
> 
> The other reason for preferring a shares based approach is that, the it will be
> more in line with the CPU controllers interfaces.
> 

You have to think of the major difference of tha nature of CPU and Memory.
We have to reclaim the resource with some feedbacks among sevral cgroups.
But ok, if it's can be implemented in simple way.
I have no objections if cost is very low. My concern is only performance.
(and maintenance)


> > Index: temp-2.6.26-rc2-mm1/include/linux/res_counter.h
> > ===================================================================
> > --- temp-2.6.26-rc2-mm1.orig/include/linux/res_counter.h
> > +++ temp-2.6.26-rc2-mm1/include/linux/res_counter.h
> > @@ -38,6 +38,16 @@ struct res_counter {
> >  	 * the number of unsuccessful attempts to consume the resource
> >  	 */
> >  	unsigned long long failcnt;
> > +
> > +	/*
> > +	 * hierarchy support: the parent of this resource.
> > +	 */
> > +	struct res_counter *parent;
> > +	/*
> > +	 * the amount of resources assigned to children.
> > +	 */
> > +	unsigned long long for_children;
> > +
> 
> I would prefer to use a better name, lent_out? reserved_for_children?
> borrowed_by_children?
> 
ok. use other names.



> >  	/*
> >  	 * the lock to protect all of the above.
> >  	 * the routines below consider this to be IRQ-safe
> > @@ -63,9 +73,20 @@ u64 res_counter_read_u64(struct res_coun
> >  ssize_t res_counter_read(struct res_counter *counter, int member,
> >  		const char __user *buf, size_t nbytes, loff_t *pos,
> >  		int (*read_strategy)(unsigned long long val, char *s));
> > +
> > +/*
> > + * An interface for setting res_counter's member (ex. limit)
> > + * the new parameter is passed by *buf and translated by write_strategy().
> > + * Then, it is applied to member under the control of set_strategy().
> > + * If write_strategy() and set_strategy() can be NULL. see res_counter.c
> > + */
> > +
> >  ssize_t res_counter_write(struct res_counter *counter, int member,
> > -		const char __user *buf, size_t nbytes, loff_t *pos,
> > -		int (*write_strategy)(char *buf, unsigned long long *val));
> > +	const char __user *buf, size_t nbytes, loff_t *pos,
> > +        int (*write_strategy)(char *buf, unsigned long long *val),
> > +	int (*set_strategy)(struct res_counter *res, unsigned long long val,
> > +			    int what),
> > +	);
> > 
> >  /*
> >   * the field descriptors. one for each member of res_counter
> > @@ -76,15 +97,33 @@ enum {
> >  	RES_MAX_USAGE,
> >  	RES_LIMIT,
> >  	RES_FAILCNT,
> > +	RES_FOR_CHILDREN,
> 
> RES_BORROWED? RES_BORROWED_BY_CHILDREN?
> 
ok, again.

> >  };
> > 
> >  /*
> >   * helpers for accounting
> >   */
> > 
> > +/*
> > + * initialize res_counter.
> > + * @counter : the counter
> > + *
> > + * initialize res_counter and set default limit to very big value(unlimited)
> > + */
> > +
> >  void res_counter_init(struct res_counter *counter);
> > 
> >  /*
> > + * initialize res_counter under hierarchy.
> > + * @counter : the counter
> > + * @parent : the parent of the counter
> > + *
> > + * initialize res_counter and set default limit to 0. and set "parent".
> > + */
> > +void res_counter_init_hierarchy(struct res_counter *counter,
> > +				struct res_counter *parent);
> > +
> > +/*
> >   * charge - try to consume more resource.
> >   *
> >   * @counter: the counter
> > @@ -153,4 +192,51 @@ static inline void res_counter_reset_fai
> >  	cnt->failcnt = 0;
> >  	spin_unlock_irqrestore(&cnt->lock, flags);
> >  }
> > +
> > +/**
> > + * Move resources from a parent to a child.
> > + * At success,
> > + *           parent->usage += val.
> > + *           parent->for_children += val.
> > + *           child->limit += val.
> > + *
> > + * @child:    an entity to set res->limit. The parent is child->parent.
> > + * @val:      the amount of resource to be moved.
> > + * @callback: called when the parent's free resource is not enough to be moved.
> > + *            this can be NULL if no callback is necessary.
> > + * @retry:    limit for the number of trying to callback.
> > + *            -1 means infinite loop. At each retry, yield() is called.
> > + * Returns 0 at success, !0 at failure.
> > + *
> > + * The callback returns 0 at success, !0 at failure.
> > + *
> > + */
> > +
> > +int res_counter_move_resource(struct res_counter *child,
> > +	unsigned long long val,
> > +        int (*callback)(struct res_counter *res, unsigned long long val),
> > +	int retry);
> > +
> > +
> > +/**
> > + * Return resource to its parent.
> > + * At success,
> > + *           parent->usage  -= val.
> > + *           parent->for_children -= val.
> > + *           child->limit -= val.
> > + *
> > + * @child:   entry to resize. The parent is child->parent.
> > + * @val  :   How much does child repay to parent ? -1 means 'all'
> > + * @callback: A callback for decreasing resource usage of child before
> > + *            returning. If NULL, just deceases child's limit.
> > + * @retry:   # of retries at calling callback for freeing resource.
> > + *            -1 means infinite loop. At each retry, yield() is called.
> > + * Returns 0 at success.
> > + */
> > +
> > +int res_counter_return_resource(struct res_counter *child,
> > +	unsigned long long val,
> > +	int (*callback)(struct res_counter *res, unsigned long long val),
> > +	int retry);
> > +
> >  #endif
> > Index: temp-2.6.26-rc2-mm1/Documentation/controllers/resource_counter.txt
> > ===================================================================
> > --- temp-2.6.26-rc2-mm1.orig/Documentation/controllers/resource_counter.txt
> > +++ temp-2.6.26-rc2-mm1/Documentation/controllers/resource_counter.txt
> > @@ -44,6 +44,13 @@ to work with it.
> >   	Protects changes of the above values.
> > 
> > 
> > + f. struct res_counter *parent
> > +
> > +	Parent res_counter under hierarchy.
> > +
> > + g. unsigned long long for_children
> > +
> > +	Resources assigned to children. This is included in usage.
> > 
> >  2. Basic accounting routines
> > 
> > @@ -179,3 +186,37 @@ counter fields. They are recommended to 
> >      still can help with it).
> > 
> >   c. Compile and run :)
> > +
> > +
> > +6. Hierarchy
> > + a. No Hierarchy
> > +   each cgroup can use its own private resource.
> > +
> > + b. Hard-wall Hierarhcy
> > +   A simple hierarchical tree system for resource isolation.
> > +   Allows moving resources only between a parent and its children.
> > +   A parent can move its resource to children and remember the amount to
> > +   for_children member. A child can get new resource only from its parent.
> > +   Limit of a child is the amount of resource which is moved from its parent.
> > +
> 
> OK, after reading this I am totally sure I want a shares based interface. Limits
> are not shared like this.
> 
> A child and a parent should both be capable of having a limit of 1G, but they
> could use different shares factors to govern, how much each children will get.
> Doing it this way, breaks limit semantics.
> 
Not easy to use in my point of view. Can we use 'share' in proper way 
on no-swap machine ?


> 
> > +   When add "val" to a child,
> > +	parent->usage += val
> > +	parent->for_children += val
> > +	child->limit += val
> > +   When a child returns its resource
> > +	parent->usage -= val
> > +	parent->for_children -= val
> > +	child->limit -= val.
> > +
> > +   This implements resource isolation among each group. This works very well
> > +   when you want to use strict resource isolation.
> > +
> > +   Usage Hint:
> > +   This seems for static resource assignment but dynamic resource re-assignment
> > +   can be done by resetting "limit" of groups. When you consider "limit" as
> > +   the amount of allowed _current_ resource, a sophisticated resource management
> > +   system based on strict resource isolation can be implemented.
> > +
> > +c. Soft-wall Hierarchy
> > +   TBD.
> > +
> > Index: temp-2.6.26-rc2-mm1/kernel/res_counter.c
> > ===================================================================
> > --- temp-2.6.26-rc2-mm1.orig/kernel/res_counter.c
> > +++ temp-2.6.26-rc2-mm1/kernel/res_counter.c
> > @@ -20,6 +20,14 @@ void res_counter_init(struct res_counter
> >  	counter->limit = (unsigned long long)LLONG_MAX;
> >  }
> > 
> > +void res_counter_init_hierarchy(struct res_counter *counter,
> > +		struct res_counter *parent)
> > +{
> > +	spin_lock_init(&counter->lock);
> > +	counter->limit = 0;
> > +	counter->parent = parent;
> > +}
> > +
> >  int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
> >  {
> >  	if (counter->usage + val > counter->limit) {
> > @@ -74,6 +82,8 @@ res_counter_member(struct res_counter *c
> >  		return &counter->limit;
> >  	case RES_FAILCNT:
> >  		return &counter->failcnt;
> > +	case RES_FOR_CHILDREN:
> > +		return &counter->for_children;
> >  	};
> > 
> >  	BUG();
> > @@ -104,7 +114,9 @@ u64 res_counter_read_u64(struct res_coun
> > 
> >  ssize_t res_counter_write(struct res_counter *counter, int member,
> >  		const char __user *userbuf, size_t nbytes, loff_t *pos,
> > -		int (*write_strategy)(char *st_buf, unsigned long long *val))
> > +		int (*write_strategy)(char *st_buf, unsigned long long *val),
> > +		int (*set_strategy)(struct res_counter *res,
> > +			unsigned long long val, int what))
> >  {
> >  	int ret;
> >  	char *buf, *end;
> > @@ -133,13 +145,101 @@ ssize_t res_counter_write(struct res_cou
> >  		if (*end != '\0')
> >  			goto out_free;
> >  	}
> > -	spin_lock_irqsave(&counter->lock, flags);
> > -	val = res_counter_member(counter, member);
> > -	*val = tmp;
> > -	spin_unlock_irqrestore(&counter->lock, flags);
> > -	ret = nbytes;
> > +	if (set_strategy) {
> > +		ret = set_strategy(res, tmp, member);
> 
> 
> I'm afraid, I don't understand the set_strategy and it's purpose.
> 
Sorry. I'm now rewritten and removed this.



> > +		if (!ret)
> > +			ret = nbytes;
> > +	} else {
> > +		spin_lock_irqsave(&counter->lock, flags);
> > +		val = res_counter_member(counter, member);
> > +		*val = tmp;
> > +		spin_unlock_irqrestore(&counter->lock, flags);
> > +		ret = nbytes;
> > +	}
> >  out_free:
> >  	kfree(buf);
> >  out:
> >  	return ret;
> >  }
> > +
> > +
> > +int res_counter_move_resource(struct res_counter *child,
> > +				unsigned long long val,
> > +	int (*callback)(struct res_counter *res, unsigned long long val),
> > +	int retry)
> > +{
> > +	struct res_counter *parent = child->parent;
> > +	unsigned long flags;
> > +
> > +	BUG_ON(!parent);
> > +
> > +	while (1) {
> > +		spin_lock_irqsave(&parent->lock, flags);
> > +		if (parent->usage + val < parent->limit) {
> > +			parent->for_children += val;
> > +			parent->usage += val;
> > +			break;
> > +		}
> > +		spin_unlock_irqrestore(&parent->lock, flags);
> > +
> > +		if (!retry || !callback)
> > +			goto failed;
> > +		/* -1 means  infinite loop */
> > +		if (retry != -1)
> > +			--retry;
> 
> I don't like the idea of spinning in an infinite loop, I would prefer to fail
> things instead of burning CPU cycles.
> 
ok, will remove "-1" case.




> > +		yield();
> > +		callback(parent, val);
> 
> This code is not very understandable. Why do we yield before callback?
> 

yield() after callback() means that res_counter's state will be
far different from the state after callback.
So, we have to yield before call back and check res_coutner sooner.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
