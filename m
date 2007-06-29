Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070627234634.GI8604@linux.vnet.ibm.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	 <1182968078.4948.30.camel@localhost>
	 <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
	 <200706280001.16383.ak@suse.de>  <20070627234634.GI8604@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Fri, 29 Jun 2007 17:47:52 -0400
Message-Id: <1183153672.4988.22.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-27 at 16:46 -0700, Paul E. McKenney wrote:
> On Thu, Jun 28, 2007 at 12:01:16AM +0200, Andi Kleen wrote:
> > 
> > > The zonelist from MPOL_BIND is passed to __alloc_pages. As a result the 
> > > RCU lock must be held over the call into the page allocator with reclaim 
> > > etc etc. Note that the zonelist is part of the policy structure.
> > 
> > Yes I realized this at some point too. RCU doesn't work here because
> > __alloc_pages can sleep. Have to use the reference counts even though
> > it adds atomic operations.
> 
> Any reason SRCU wouldn't work here?  From a quick glance at the patch,
> it seems possible to me.

Does SRCU have a deferred version--i.e., a call_srcu()?  I didn't see
one.  I originally tried synchronize_rcu() in my patch, but hit a
"scheduling while atomic" bug, so I converted it to deferred reclaim.

For changing the task policy from outside the task--something that I
understand Christoph would like to do--we can use synchronize_srcu(), if
we can call it from outside any atomic context.

Or maybe synchronize_srcu() does attempt to reschedule nor call
"might_schedule()"?  [Sorry, haven't had time to look.]

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
