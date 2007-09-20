Date: Thu, 20 Sep 2007 11:44:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/8] oom: only kill tasks that share zones with zonelist
In-Reply-To: <alpine.DEB.0.9999.0709201135180.14644@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709201142560.9132@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190351140.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190351290.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190351460.23538@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709191156480.2241@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709192245070.22371@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709201056280.8626@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709201135180.14644@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007, David Rientjes wrote:

> On Thu, 20 Sep 2007, Christoph Lameter wrote:
> 
> > > Setting the CONSTRAINT_MEMORY_POLICY case aside for a moment, what stops 
> > > us from getting rid of taking callback_mutex and simply relying on the 
> > > following to filter for candidate tasks:
> > > 
> > > 	do_each_thread(g, p) {
> > > 		...
> > > 		/*
> > > 		 * Check if it will do any good to kill this task based
> > > 		 * on where it is allowed to allocate.
> > > 		 */
> > > 		if (!nodes_intersects(current->mems_allowed,
> > > 				      p->mems_allowed))
> > > 			continue;
> > > 		...
> > > 	} while_each_thread(g, p);
> > 
> > A global scan over all processes is expensive and may take a long time if 
> > you have a 100000 or so of them.
> > 
> 
> Yeah, I understand that.  Paul and I talked about it a while ago and 
> decided that a per-cpuset file 'oom_kill_asking_task' could be implemented 
> to determine whether the OOM killer would simply kill current or go 
> through select_bad_process() in the CONSTRAINT_CPUSET case to address that 
> problem.  Let me know if that doesn't seem good enough.

There are still allocations that are not constrained to a cpuset. If the 
has an OOM condition on an allocation that is not constrained then the 
above may still cause more troubles.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
