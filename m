Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 810B46B004F
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 01:21:43 -0500 (EST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 5 Jan 2012 23:21:42 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q066LOEQ127864
	for <linux-mm@kvack.org>; Thu, 5 Jan 2012 23:21:24 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q066LL12002224
	for <linux-mm@kvack.org>; Thu, 5 Jan 2012 23:21:24 -0700
Date: Fri, 6 Jan 2012 11:44:07 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v8 3.2.0-rc5 1/9] uprobes: Install and remove
 breakpoints.
Message-ID: <20120106061407.GC14946@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111216122756.2085.95791.sendpatchset@srdronam.in.ibm.com>
 <20111216122808.2085.76986.sendpatchset@srdronam.in.ibm.com>
 <1325695788.2697.3.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1325695788.2697.3.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

* Peter Zijlstra <peterz@infradead.org> [2012-01-04 17:49:48]:

> On Fri, 2011-12-16 at 17:58 +0530, Srikar Dronamraju wrote:
> > +static void __unregister_uprobe(struct uprobe *uprobe)
> > +{
> > +       if (!register_for_each_vma(uprobe, false))
> > +               delete_uprobe(uprobe);
> > +
> > +       /* TODO : cant unregister? schedule a worker thread */
> > +} 
> 
> I was about to suggest we merge it, but we really can't with a hole that
> size..
> 

On failure of unregister due to low memory condition:
	- uprobe is left in the rbtree.  So subsequent probe hits can
	  still refer the nodes.

	- UPROBES_RUN_HANDLER flag still gets reset unconditionally. So
	  handlers will not run on subsequent probe hits that correspond
	  to this uprobe.

	- consumers for the uprobe is NULL, so mmap_uprobe will not
	  insert new breakpoints which correspond to this uprobe until
	  or unless another consumer gets added for the same probe.

	- If a new consumer gets added for this probe, we reuse the
	  uprobe struct.
	
So in the highly unlikely case of uprobes not being able to unregister
cleanly because of low memory conditions, existing tasks that have this
probe in their address space will incur an extra cost of handling
exceptions.

However scheduling a kworker thread (or removing the underlying
breakpoint if we detect the probe doesnt have UPROBES_RUN_HANDLER flag
set) will reduce this overhead. 

Since we are looking at an extra overhead and no change in behaviour,
should this be a reason to stop merging this feature?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
