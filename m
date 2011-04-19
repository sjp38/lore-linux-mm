Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D337A8D0040
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 16:56:59 -0400 (EDT)
Date: Tue, 19 Apr 2011 15:56:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <1303242580.11237.10.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1104191530040.23077@router.home>
References: <20110415135144.GE8828@tiehlicka.suse.cz>  <alpine.LSU.2.00.1104171952040.22679@sister.anvils>  <20110418100131.GD8925@tiehlicka.suse.cz>  <20110418135637.5baac204.akpm@linux-foundation.org>  <20110419111004.GE21689@tiehlicka.suse.cz>
 <1303228009.3171.18.camel@mulgrave.site>  <BANLkTimYrD_Sby_u-fPSwn-RJJyEVavU5w@mail.gmail.com>  <1303233088.3171.26.camel@mulgrave.site>  <alpine.DEB.2.00.1104191213120.17888@router.home>  <1303235306.3171.33.camel@mulgrave.site>
 <alpine.DEB.2.00.1104191254300.19358@router.home>  <1303237217.3171.39.camel@mulgrave.site>  <alpine.DEB.2.00.1104191325470.19358@router.home> <1303242580.11237.10.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

On Tue, 19 Apr 2011, James Bottomley wrote:

> > > I told you ... I forced an allocation into the first discontiguous
> > > region.  That will return 1 for page_to_nid().
> >
> > How? The kernel has no concept of a node 1 without CONFIG_NUMA and so you
> > cannot tell the page allocator to allocate from node 1.
>
> Yes, it does, as I explained in the email.

Looked through it and canot find it. How would that be possible to do
with core kernel calls since the page allocator calls do not allow you to
specify a node under !NUMA.

> Don't be silly: alpha, ia64, m32r, m68k, mips, parisc, tile and even x86
> all use the discontigmem memory model in some configurations.

I guess DISCONTIGMEM is typically used together with NUMA. Otherwise we
would have run into this before.

> > > Not really.  The rest of the kernel uses the proper macros.  in
> > > DISCONTIGMEM but !NUMA configs, the numa macros expand correctly.
> > > You've cut across that with all the CONFIG_NUMA checks in slub.
> >
> > What are "the proper macros"? AFAICT page_to_nid() is the proper way to
> > access the node of a page. If page_to_nid() returns 1 then you have a zone
> > that the kernel knows of as being in node 0 having a page on a different
> > node.
>
> Well it depends what you want.  If you only want the actual NUMA node,
> then pfn_to_nid() probably isn't what you want, because in a
> DISCONTIGMEM model, there may be multiple nids per actual numa node.

Right yes you got it. The notion of a node is different(!!!!!). What
matters to the core kernel is the notion of a NUMA node. If DISCONTIGMEM
runs with !NUMA then the way that "node" is used in DISCONTIGMEM is
different from the core code and refers only to the memory blocks managed
by DISCONTIGMEM. The node should be irrelevant to the core then.

> > We can likely force page_to_nid to ignore the node information that have
> > been erroneously placed there but this looks like something deeper is
> > wrong here. The node field in struct page is not only used for the Linux
> > support of a NUMA node but also for blocks of memory. Those should be
> > separate things.
>
> Look, it's not wrong, it's by design.  The assumption that non-numa
> systems don't use nodes is the wrong one.

Depends on how you define the notion of a node. The way the core kernel
uses the term "node" means that there will be only one node and that is
node 0 if CONFIG_NUMA is off. Thus page_to_nid() must return 0 for !NUMA.

All sort of things in the core code will break in weird ways if you do
allow page_to_nid to return 1 under !NUMA. Just look at the usage of
page_to_nid(). Tried to use huge pages yet? And how will your version
of reality deal with the following checks in the page allocator? F.e.

              VM_BUG_ON(page_to_nid(page) != zone_to_nid(zone));

Enabled CONFIG_DEBUG_VM yet?


> > Index: linux-2.6/include/linux/mm.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/mm.h	2011-04-19 13:20:20.092521248 -0500
> > +++ linux-2.6/include/linux/mm.h	2011-04-19 13:21:05.962521196 -0500
> > @@ -665,6 +665,7 @@ static inline int zone_to_nid(struct zon
> >  #endif
> >  }
> >
> > +#ifdef CONFIG_NUMA
> >  #ifdef NODE_NOT_IN_PAGE_FLAGS
> >  extern int page_to_nid(struct page *page);
> >  #else
> > @@ -673,6 +674,9 @@ static inline int page_to_nid(struct pag
> >  	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
> >  }
> >  #endif
> > +#else
> > +#define page_to_nid(x) 0
> > +#endif
>
> Don't be silly ... that breaks asm-generic/memory_model.h

Well yeah looks like in order to be clean in the !NUMA case we would then
need a page_to_discontig_node_id() there that is different from the
page_to_nid() used for the core.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
