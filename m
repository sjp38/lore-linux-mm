Date: Fri, 17 Feb 2006 09:12:32 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] 0/4 Migration Cache Overview
In-Reply-To: <1140195598.5219.77.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0602170906030.31408@schroedinger.engr.sgi.com>
References: <1140190593.5219.22.camel@localhost.localdomain>
 <Pine.LNX.4.64.0602170816530.30999@schroedinger.engr.sgi.com>
 <1140195598.5219.77.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Feb 2006, Lee Schermerhorn wrote:

> > Could add a justification of this feature? What is the benefit of having a 
> > migration cache instead of using swap pte (current migration is not really 
> > using swap space per se)?
> 
> I think Marcello covered that in his original posts, which I linked.  
> I can go back and extract his arguments.  My primary interest is for
> "lazy page migration" where anon pages can hang around the the cache
> until the task faults them in [possibly migrating] or exits, if ever.
> I think the desire to avoid using swap for this case is even stronger.

I am bit confused. A task faults in a page from the migration cache? Isnt 
this swap behavior? I thought the migration cache was just to avoid using
swap page numbers for the intermediate pte values during migration?

You are moving the page when it is faulted in?

Including Marcelo's rationale may help understanding here. I read it a 
while back but I do not remember the details. Please give us an overview.

> > Yes there is since handle_mm_fault accesses the pte without locking.
> > do_swap_page acquires the lock and will then recheck if the pte is the 
> > same. If anything happened in between it should redo the page fault.
> I thought so, but hadn't thought of an efficient check for the fault
> handlers.  I'm thinking that if the fault handler doesn't find the 
> page in the cache and the page's private data doesn't match the pte
> [after appropriate conversion],  the handler could return -EAGAIN
> causing handle_mm_fault to refetch the pte.  I guess if the handler
> doesn't find the page in the cache, this is the slow path anyway,
> so maybe efficiency isn't such a concern.  It will require converion
> of the pte to swp_entry or vice versa, right?

If the migration cache is only used for intermediary pte values then the
fault handler should wait until the migration of the page is complete.
do_swap_page acquired the page lock after checking the pte. Thus the 
process should block until migration is complete.

It seems to me that what you are trying to accomplish here is already 
provided for by the current swap based code. You just need to control the 
swap in behavior in order to make lazy migration work right. But then I 
guess I am missing something.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
