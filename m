Date: Fri, 14 Apr 2006 11:48:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Implement lookup_swap_cache for migration entries
In-Reply-To: <20060414113104.72a5059b.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0604141143520.22475@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
 <20060413235416.15398.49978.sendpatchset@schroedinger.engr.sgi.com>
 <20060413171331.1752e21f.akpm@osdl.org> <Pine.LNX.4.64.0604131728150.15802@schroedinger.engr.sgi.com>
 <20060413174232.57d02343.akpm@osdl.org> <Pine.LNX.4.64.0604131743180.15965@schroedinger.engr.sgi.com>
 <20060413180159.0c01beb7.akpm@osdl.org> <Pine.LNX.4.64.0604131827210.16220@schroedinger.engr.sgi.com>
 <20060413222921.2834d897.akpm@osdl.org> <Pine.LNX.4.64.0604141025310.18575@schroedinger.engr.sgi.com>
 <20060414113104.72a5059b.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 14 Apr 2006, Andrew Morton wrote:

> > @@ -305,6 +306,12 @@ struct page * lookup_swap_cache(swp_entr
> >  {
> >  	struct page *page;
> >  
> > +	if (is_migration_entry(entry)) {
> > +		page = migration_entry_to_page(entry);
> > +		get_page(page);
> > +		return page;
> > +	}
> 
> What locking ensures that the state of `entry' remains unaltered across the
> is_migration_entry() and migration_entry_to_page() calls?

entry is a variable passed by value to the function.

> > +/*
> > + * Must use a macro for lookup_swap_cache since the functions
> > + * used are only available in certain contexts.
> > + */
> > +#define lookup_swap_cache(__swp)				\
> > +({	struct page *p = NULL;					\
> > +	if (is_migration_entry(__swp)) {			\
> > +		p = migration_entry_to_page(__swp);		\
> > +		get_page(p);					\
> > +	}							\
> > +	p;							\
> > +})
> 
> hm.  Can nommu do any of this?

If page migration is off (methinks nommu may not support numa) then
the fallback functions are used.

Fallback is

is_migration_entry() == 0 

therefore

#define lookup_swap_cache(__swp) NULL

like before.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
