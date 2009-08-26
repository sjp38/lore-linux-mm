Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C40456B004F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 16:46:40 -0400 (EDT)
Subject: Re: [PATCH 4/5] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.0908261239440.4511@chino.kir.corp.google.com>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain>
	 <20090824192902.10317.94512.sendpatchset@localhost.localdomain>
	 <20090825101906.GB4427@csn.ul.ie>
	 <1251233369.16229.1.camel@useless.americas.hpqcorp.net>
	 <20090826101122.GD10955@csn.ul.ie>
	 <1251309747.4409.45.camel@useless.americas.hpqcorp.net>
	 <alpine.DEB.2.00.0908261239440.4511@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Wed, 26 Aug 2009 16:46:43 -0400
Message-Id: <1251319603.4409.92.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 2009-08-26 at 12:47 -0700, David Rientjes wrote:
> On Wed, 26 Aug 2009, Lee Schermerhorn wrote:
> 
> > Against: 2.6.31-rc6-mmotm-090820-1918
> > 
> > Introduce nodemask macro to allocate a nodemask and 
> > initialize it to contain a single node, using existing
> > nodemask_of_node() macro.  Coded as a macro to avoid header
> > dependency hell.
> > 
> > This will be used to construct the huge pages "nodes_allowed"
> > nodemask for a single node when a persistent huge page
> > pool page count is modified via a per node sysfs attribute.
> > 
> > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> >  include/linux/nodemask.h |   10 ++++++++++
> >  1 file changed, 10 insertions(+)
> > 
> > Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/nodemask.h
> > ===================================================================
> > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/nodemask.h	2009-08-24 10:16:56.000000000 -0400
> > +++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/nodemask.h	2009-08-26 12:38:31.000000000 -0400
> > @@ -257,6 +257,16 @@ static inline int __next_node(int n, con
> >  	m;								\
> >  })
> >  
> > +#define alloc_nodemask_of_node(node)					\
> > +({									\
> > +	typeof(_unused_nodemask_arg_) *nmp;				\
> > +	nmp = kmalloc(sizeof(*nmp), GFP_KERNEL);			\
> > +	if (nmp)							\
> > +		*nmp = nodemask_of_node(node);				\
> > +	nmp;								\
> > +})
> > +
> > +
> >  #define first_unset_node(mask) __first_unset_node(&(mask))
> >  static inline int __first_unset_node(const nodemask_t *maskp)
> >  {
> 
> I think it would probably be better to use the generic NODEMASK_ALLOC() 
> interface by requiring it to pass the entire type (including "struct") as 
> part of the first parameter.  Then it automatically takes care of 
> dynamically allocating large nodemasks vs. allocating them on the stack.
> 
> Would it work by redefining NODEMASK_ALLOC() in the NODES_SHIFT > 8 case 
> to be this:
> 
> 	#define NODEMASK_ALLOC(x, m) x *m = kmalloc(sizeof(*m), GFP_KERNEL);
> 
> and converting NODEMASK_SCRATCH(x) to NODEMASK_ALLOC(struct 
> nodemask_scratch, x), and then doing this in your code:
> 
> 	NODEMASK_ALLOC(nodemask_t, nodes_allowed);
> 	if (nodes_allowed)
> 		*nodes_allowed = nodemask_of_node(node);
> 
> The NODEMASK_{ALLOC,SCRATCH}() interface is in its infancy so it can 
> probably be made more general to handle cases like this.

I just don't know what that would accomplish.  Heck, I'm not all that
happy with the alloc_nodemask_from_node() because it's allocating both a
hidden nodemask_t and a pointer thereto on the stack just to return a
pointer to a kmalloc()ed nodemask_t--which is what I want/need here.

One issue I have with NODEMASK_ALLOC() [and nodemask_of_node(), et al]
is that it declares the pointer variable as well as initializing it,
perhaps with kmalloc(), ...   Indeed, it's purpose is to replace on
stack nodemask declarations.

So, to use it at the start of, e.g., set_max_huge_pages() where I can
safely use it throughout the function, I'll end up allocating the
nodes_allowed mask on every call, whether or not a node is specified or
there is a non-default mempolicy.   If it turns out that no node was
specified and we have default policy, we need to free the mask and NULL
out nodes_allowed up front so that we get default behavior.  That seems
uglier to me that only allocating the nodemask when we know we need one.

I'm not opposed to using a generic function/macro where one exists that
suits my purposes.   I just don't see one.  I tried to create
one--alloc_nodemask_from_node(), and to keep Mel happy, I tried to reuse
nodemask_from_node() to initialize it.  I'm really not happy with the
results--because of those extra, hidden stack variables.  I could
eliminate those by creating a out of line function, but there's no good
place to put a generic nodemask function--no nodemask.c.  

I'm leaning towards going back to my original hugetlb-private
"nodes_allowed_from_node()" or such.  I can use nodemask_from_node to
initialize it, if that will make Mel happy, but trying to force fit an
existing "generic" function just because it's generic seems pointless.

So, I'm going to let this series rest until I hear back from you and Mel
on how to proceed with this. 

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
