Date: Thu, 12 Jun 2008 13:59:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
Message-Id: <20080612135949.6e2ab327.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080611162427.3ef63098.randy.dunlap@oracle.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	<20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
	<20080611162427.3ef63098.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 16:24:27 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:
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
> 
> For these non-static (non-private) functions, please use kernel-doc notation
> (see Documentation/kernel-doc-nano-HOWTO.txt and/or examples in other source files).
> Also, we prefer for the function documentation to be above its definition (implementation)
> rather than above its declaration, so the kernel-doc should be moved to .c files
> instead of living in .h files.
> 
Ah, sorry. I'll do so in the next version. Maybe I should move other comments
in res_counter.h to res_counter.c


> 
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
> 
>            seems to be?
> 
will fix.

Thank you for review!

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
