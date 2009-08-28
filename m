Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EF1E26B00B2
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 08:56:47 -0400 (EDT)
Subject: Re: [PATCH 4/5] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.0908271228200.14815@chino.kir.corp.google.com>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain>
	 <20090824192902.10317.94512.sendpatchset@localhost.localdomain>
	 <20090825101906.GB4427@csn.ul.ie>
	 <1251233369.16229.1.camel@useless.americas.hpqcorp.net>
	 <20090826101122.GD10955@csn.ul.ie>
	 <1251309747.4409.45.camel@useless.americas.hpqcorp.net>
	 <alpine.DEB.2.00.0908261239440.4511@chino.kir.corp.google.com>
	 <1251319603.4409.92.camel@useless.americas.hpqcorp.net>
	 <alpine.DEB.2.00.0908271228200.14815@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Fri, 28 Aug 2009 08:56:52 -0400
Message-Id: <1251464212.9989.52.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-08-27 at 12:35 -0700, David Rientjes wrote:
> On Wed, 26 Aug 2009, Lee Schermerhorn wrote:
> 
> > > I think it would probably be better to use the generic NODEMASK_ALLOC() 
> > > interface by requiring it to pass the entire type (including "struct") as 
> > > part of the first parameter.  Then it automatically takes care of 
> > > dynamically allocating large nodemasks vs. allocating them on the stack.
> > > 
> > > Would it work by redefining NODEMASK_ALLOC() in the NODES_SHIFT > 8 case 
> > > to be this:
> > > 
> > > 	#define NODEMASK_ALLOC(x, m) x *m = kmalloc(sizeof(*m), GFP_KERNEL);
> > > 
> > > and converting NODEMASK_SCRATCH(x) to NODEMASK_ALLOC(struct 
> > > nodemask_scratch, x), and then doing this in your code:
> > > 
> > > 	NODEMASK_ALLOC(nodemask_t, nodes_allowed);
> > > 	if (nodes_allowed)
> > > 		*nodes_allowed = nodemask_of_node(node);
> > > 
> > > The NODEMASK_{ALLOC,SCRATCH}() interface is in its infancy so it can 
> > > probably be made more general to handle cases like this.
> > 
> > I just don't know what that would accomplish.  Heck, I'm not all that
> > happy with the alloc_nodemask_from_node() because it's allocating both a
> > hidden nodemask_t and a pointer thereto on the stack just to return a
> > pointer to a kmalloc()ed nodemask_t--which is what I want/need here.
> > 
> > One issue I have with NODEMASK_ALLOC() [and nodemask_of_node(), et al]
> > is that it declares the pointer variable as well as initializing it,
> > perhaps with kmalloc(), ...   Indeed, it's purpose is to replace on
> > stack nodemask declarations.
> > 
> 
> Right, which is why I suggest we only have one such interface to 
> dynamically allocate nodemasks when NODES_SHIFT > 8.  That's what defines 
> NODEMASK_ALLOC() as being special: it's taking NODES_SHIFT into 
> consideration just like CPUMASK_ALLOC() would take NR_CPUS into 
> consideration.  Your use case is the intended purpose of NODEMASK_ALLOC() 
> and I see no reason why your code can't use the same interface with some 
> modification and it's in the best interest of a maintainability to not 
> duplicate specialized cases where pre-existing interfaces can be used (or 
> improved, in this case).
> 
> > So, to use it at the start of, e.g., set_max_huge_pages() where I can
> > safely use it throughout the function, I'll end up allocating the
> > nodes_allowed mask on every call, whether or not a node is specified or
> > there is a non-default mempolicy.  If it turns out that no node was
> > specified and we have default policy, we need to free the mask and NULL
> > out nodes_allowed up front so that we get default behavior.  That seems
> > uglier to me that only allocating the nodemask when we know we need one.
> > 
> 
> Not with my suggested code of disabling local irqs, getting a reference to 
> the mempolicy so it can't be freed, reenabling, and then only using 
> NODEMASK_ALLOC() in the switch statement on mpol->mode for MPOL_PREFERRED.
> 
> > I'm not opposed to using a generic function/macro where one exists that
> > suits my purposes.   I just don't see one.  I tried to create
> > one--alloc_nodemask_from_node(), and to keep Mel happy, I tried to reuse
> > nodemask_from_node() to initialize it.  I'm really not happy with the
> > results--because of those extra, hidden stack variables.  I could
> > eliminate those by creating a out of line function, but there's no good
> > place to put a generic nodemask function--no nodemask.c.  
> > 
> 
> Using NODEMASK_ALLOC(nodes_allowed) wouldn't really be a hidden stack 
> variable, would it?  I think most developers would assume that it is 
> some automatic variable called `nodes_allowed' since it's later referenced 
> (and only needs to be in the case of MPOL_PREFERRED if my mpol_get() 
> solution with disabled local irqs is used).

David:  

I'm going to repost my series with the version of
alloc_nodemask_of_node() that I sent our yesterday.  My entire
implementation is based on nodes_allowed, in set_max_huge_pages() being
a pointer to a nodemask.  nodes_allowed must be NULL for default
behavior [NO_NODEID_SPECIFIED && default mempolicy].  It only gets
allocated when nid >0 or task has non-default memory policy.  This seems
to work fairly well for both the mempolicy based constraint and the per
node attributes.  Please take a look at this series.  If you want to
propose a patch to rework the nodes_allowed allocation, have at it.  I'm
satisfied with the current implementation.

Now, we have a couple of options:  Mel said he's willing to proceed with
the mempolicy based constraint and leave the per node attributes to a
follow up submit.  If you want to take over the per node attributes
feature and rework it, I can extract it from the series, including the
doc update and turn it over to you.  Or, we can try to submit the
current implementation and follow up with patches to rework the generic
nodemask support as you propose.

Let me know how you want to proceed.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
