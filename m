Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 746906B0071
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 04:49:10 -0500 (EST)
Date: Wed, 20 Jan 2010 09:48:56 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/7] Add /proc trigger for memory compaction
Message-ID: <20100120094856.GD5154@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-6-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1001071352100.23894@chino.kir.corp.google.com> <alpine.DEB.2.00.1001131518240.10201@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001131518240.10201@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 13, 2010 at 03:23:44PM -0800, David Rientjes wrote:
> On Thu, 7 Jan 2010, David Rientjes wrote:
> 
> > > diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> > > index 6201371..5965ef2 100644
> > > --- a/include/linux/compaction.h
> > > +++ b/include/linux/compaction.h
> > > @@ -5,4 +5,9 @@
> > >  #define COMPACT_INCOMPLETE	0
> > >  #define COMPACT_COMPLETE	1
> > >  
> > > +#ifdef CONFIG_MIGRATION
> > > +extern int sysctl_compaction_handler(struct ctl_table *table, int write,
> > > +			void __user *buffer, size_t *length, loff_t *ppos);
> > > +#endif /* CONFIG_MIGRATION */
> > > +
> > >  #endif /* _LINUX_COMPACTION_H */
> 
> This should be CONFIG_COMPACTION since mm/compaction.c won't be compiled 
> without it; the later additions to this ifdef, fragmentation_index() and 
> try_to_compact_pages(), can also be under CONFIG_COMPACTION since neither 
> are used outside of the compaction core directly (__fragmentation_index() 
> from vmstat uses its wrapped function at file scope).
> 

True. It's corrected now.

> > > diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> > > index 8a68b24..6202e95 100644
> > > --- a/kernel/sysctl.c
> > > +++ b/kernel/sysctl.c
> > > @@ -50,6 +50,7 @@
> > >  #include <linux/ftrace.h>
> > >  #include <linux/slow-work.h>
> > >  #include <linux/perf_event.h>
> > > +#include <linux/compaction.h>
> > >  
> > >  #include <asm/uaccess.h>
> > >  #include <asm/processor.h>
> > > @@ -80,6 +81,7 @@ extern int pid_max;
> > >  extern int min_free_kbytes;
> > >  extern int pid_max_min, pid_max_max;
> > >  extern int sysctl_drop_caches;
> > > +extern int sysctl_compact_node;
> > >  extern int percpu_pagelist_fraction;
> > >  extern int compat_log;
> > >  extern int latencytop_enabled;
> > > @@ -1109,6 +1111,15 @@ static struct ctl_table vm_table[] = {
> > >  		.mode		= 0644,
> > >  		.proc_handler	= drop_caches_sysctl_handler,
> > >  	},
> > > +#ifdef CONFIG_MIGRATION
> > > +	{
> > > +		.procname	= "compact_node",
> > > +		.data		= &sysctl_compact_node,
> > > +		.maxlen		= sizeof(int),
> > > +		.mode		= 0644,
> > 
> > This should only need 0200?
> > 
> 
> This needs to be CONFIG_COMPACTION as well, we won't have the handler 
> without mm/compaction.c.
> 

Both corrected.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
