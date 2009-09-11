Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 60E0A6B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 09:11:25 -0400 (EDT)
Subject: Re: [PATCH 3/6] hugetlb:  introduce alloc_nodemask_of_node
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090910160541.9f902126.akpm@linux-foundation.org>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
	 <20090909163146.12963.79545.sendpatchset@localhost.localdomain>
	 <20090910160541.9f902126.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 11 Sep 2009 09:11:24 -0400
Message-Id: <1252674684.4392.222.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, mel@csn.ul.ie, randy.dunlap@oracle.com, nacc@us.ibm.com, rientjes@google.com, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-09-10 at 16:05 -0700, Andrew Morton wrote:
> On Wed, 09 Sep 2009 12:31:46 -0400
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > [PATCH 3/6] - hugetlb:  introduce alloc_nodemask_of_node()
> > 
> > Against:  2.6.31-rc7-mmotm-090827-1651
> > 
> > New in V5 of series
> > 
> > V6: + rename 'init_nodemask_of_nodes()' to 'init_nodemask_of_node()'
> >     + redefine init_nodemask_of_node() as static inline fcn
> >     + move this patch back 1 in series
> > 
> > Introduce nodemask macro to allocate a nodemask and 
> > initialize it to contain a single node, using the macro
> > init_nodemask_of_node() factored out of the nodemask_of_node()
> > macro.
> > 
> > alloc_nodemask_of_node() coded as a macro to avoid header
> > dependency hell.
> > 
> > This will be used to construct the huge pages "nodes_allowed"
> > nodemask for a single node when basing nodes_allowed on a
> > preferred/local mempolicy or when a persistent huge page
> > pool page count is modified via a per node sysfs attribute.
> > 
> > ...
> >
> > +/*
> > + * returns pointer to kmalloc()'d nodemask initialized to contain the
> > + * specified node.  Caller must free with kfree().
> > + */
> > +#define alloc_nodemask_of_node(node)					\
> > +({									\
> > +	typeof(_unused_nodemask_arg_) *nmp;				\
> > +	nmp = kmalloc(sizeof(*nmp), GFP_KERNEL);			\
> > +	if (nmp)							\
> > +		init_nodemask_of_node(nmp, (node));			\
> > +	nmp;								\
> > +})
> 
> All right, I give up.  What's with this `typeof(_unused_nodemask_arg_)'
> stuff?

You got me.  I would have used a bar nodemask_t, but I was following the
style of the nodemask_of_node() in the same header.

> 
> 
> Was there a reason why this had to be implemented as a macro.

> One
> which evaluates its arg either one or zero times, btw?

Well, one, unless the alloc fails.  

> 
> hm.  "to avoid header dependency hell".  What hell?  Self-inflicted?

Well, I tried to make it a static inline function, but nodemask.h gets
included, indirectly, in various places where, e.g., kmalloc() is not
defined.  I tried including slab.h, but that had problems with other
missing definitions.  I didn't want to end up with the entire
include/linux directory included in nodemask.h.

I would have put it in a .c file, but there is no, e.g., nodemask.c.
Guess I could have created alloc_bitmap_of_bit() in bitmap.c with a
wrapper in nodemask.h.  Would that be preferable?

> 
> alloc_nodemask_of_node() has no callers, so I can think of a good fix
> for these problems.  If it _did_ have a caller then I might ask "can't
> we fix this by moving alloc_nodemask_of_node() into the .c file".  But
> it doesn't so I can't.

This patch was a later addition.  The function is used by the following
patch.   Originally, I had a private function in hugetlb.c that
kmalloc()'d and initialized the nodes_allowed mask.  Mel suggested that
I use the generic nodemask_of_node().  That didn't have the semantics I
wanted, so I created this variant.

> 
> It's a bit rude to assume that the caller wanted to use GFP_KERNEL.

I can add a gfp_t parameter to the macro, but I'll still need to select
value in the caller.  Do you have a suggested alternative to GFP_KERNEL
[for both here and in alloc_nodemask_of_mempolicy()]?  We certainly
don't want to loop forever, killing off tasks, as David mentioned.
Silently failing is OK.  We handle that.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
