Date: Tue, 6 Mar 2007 09:12:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] [PATCH] Power Managed memory base enabling
In-Reply-To: <20070306164722.GB22725@linux.intel.com>
Message-ID: <Pine.LNX.4.64.0703060904380.27341@chino.kir.corp.google.com>
References: <20070305181826.GA21515@linux.intel.com>
 <Pine.LNX.4.64.0703051941310.18703@chino.kir.corp.google.com>
 <20070306164722.GB22725@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Gross <mgross@linux.intel.com>
Cc: linux-mm@kvack.org, linux-pm@lists.osdl.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, mark.gross@intel.com, neelam.chandwani@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, Mark Gross wrote:

> For the initial version of HW that can do this we are stuck with
> allocation based decisions where a complete solution needs page
> migration.
> 
> Yes, a sysfs interface is being looked at to export the control to a
> user mode daemon doing running some kind of policy manager, and if/when
> page migration happens it will be hooked up to this interface.
> 

Is do_migrate_pages() currently unsatisfactory for this?

> > > diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/mm/memory.c linux-2.6.20-mm2-monroe/mm/memory.c
> > > --- linux-2.6.20-mm2/mm/memory.c	2007-02-23 11:20:40.000000000 -0800
> > > +++ linux-2.6.20-mm2-monroe/mm/memory.c	2007-03-02 15:15:53.000000000 -0800
> > > @@ -2882,3 +2882,29 @@
> > >  	return buf - old_buf;
> > >  }
> > >  EXPORT_SYMBOL_GPL(access_process_vm);
> > > +
> > > +#ifdef __x86_64__
> > > +extern int __power_managed_memory_present(void);
> > > +extern int __power_managed_node(int srat_node);
> > > +extern int __find_closest_non_pm_node(int nodeid);
> > > +#else
> > > +inline int __power_managed_memory_present(void) { return 0};
> > > +inline int __power_managed_node(int srat_node) { return 0};
> > > +inline int __find_closest_non_pm_node(int nodeid) { return nodeid};
> > > +#endif
> > > +
> > > +int power_managed_memory_present(void)
> > > +{
> > > +	return __power_managed_memory_present();
> > > +}
> > > +
> > > +int power_managed_node(int srat_node)
> > > +{
> > > +	return __power_managed_node(srat_node);
> > > +}
> > > +
> > > +int find_closest_non_pm_node(int nodeid)
> > > +{
> > > +	return __find_closest_non_pm_node(nodeid);
> > > +}
> > > +
> > 
> > Probably should reconsider extern declarations in .c files.
> >
> 
> Yeah, but I couldn't think of a better place to put this code or how to
> make it portable to non x86_64 architectures.  Recommendations gratefully
> accepted.
> 

I would add this to include/asm-x86_64/topology.h:

	extern int __power_managed_memory_present(void);
	extern int __power_managed_node(int);
	extern int __find_closest_non_pm_node(int);
	#define power_managed_memory_present()	__power_managed_memory_present()
	#define power_managed_node(nid)		__power_managed_node(nid)
	#define find_closest_non_pm_node(nid)	__find_closest_non_pm_node(nid)

and then put the actual functions in arch/x86_64/numa.c.  Then something 
like this in include/linux/topology.h would probably suffice:

	#ifndef find_closest_non_pm_node
	#define find_closest_non_pm_node(nid)	do {} while(0)
	#endif

etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
