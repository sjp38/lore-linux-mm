Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A59F78D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:23:35 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2IJ8FYp007516
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:08:15 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2IJNUvT100498
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:23:30 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2IJNSow027379
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:23:30 -0600
Date: Sat, 19 Mar 2011 00:46:48 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 17/20] 17: uprobes: filter chain
Message-ID: <20110318191648.GD31152@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133722.27435.55663.sendpatchset@localhost6.localdomain6>
 <20110315194914.GA24972@fibrous.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110315194914.GA24972@fibrous.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Stephen Wilson <wilsons@start.ca> [2011-03-15 15:49:14]:

> 
> 
> 
> On Mon, Mar 14, 2011 at 07:07:22PM +0530, Srikar Dronamraju wrote:
> > 
> > Loops through the filters callbacks of currently registered
> > consumers to see if any consumer is interested in tracing this task.
> 
> Should this be part of the series?  It is not currently used.
> 
> >  /* Acquires uprobe->consumer_rwsem */
> > +static bool filter_chain(struct uprobe *uprobe, struct task_struct *t)
> > +{
> > +	struct uprobe_consumer *consumer;
> > +	bool ret = false;
> > +
> > +	down_read(&uprobe->consumer_rwsem);
> > +	for (consumer = uprobe->consumers; consumer;
> > +					consumer = consumer->next) {
> > +		if (!consumer->filter || consumer->filter(consumer, t)) {
> 
> The implementation does not seem to match the changelog description.
> Should this not be:
> 
>                 if (consumer->filter && consumer->filter(consumer, t))
> 
>   ?

filter is optional; if filter is present, then it means that the
tracer is interested in a specific set of processes that maps this
inode. If there is no filter; it means that it is interested in all
processes that map this filter. 

filter_chain() should return true if any consumer is interested in
tracing this task.
if there is a consumer who hasnt defined a filter then we dont need to loop thro remaining consumers.

Hence 

if (!consumer->filter || consumer->filter(consumer, t)) {
 
seems better suited to me.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
