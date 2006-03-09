Date: Thu, 9 Mar 2006 11:12:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] Migrate-on-fault prototype 0/5 V0.1 - Overview
In-Reply-To: <1141928905.6393.10.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0603091104280.17622@schroedinger.engr.sgi.com>
References: <1141928905.6393.10.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Mar 2006, Lee Schermerhorn wrote:

> The basic idea is that when a fault handler [do_swap_page,
> filemap_nopage,
> ...] finds a cached page with zero mappings that is otherwise "stable"--
> i.e., no writebacks--this is a good opportunity to check whether the 
> page resides on the node indicated by the policy in the current context.

Note that this is only one of the types of use of memory policy. Policy is 
typically used for placement and may be changed repeatedly for the same 
memory area in order to get certain patterns of allocation. This approach 
assumes that pages must follow policy. This is not the case for 
applications that keep changing allocation policies. But we have a similar
use with MPOL_MF_MOVE and MPOL_MF_MOVE_ALL. However, these need to be 
enabled explicitly. We may not want this mechanism to be on by default 
because it may destroy the arrangement of pages that an HPC application 
has tried to obtain.

> Note that when a page is NOT found in the cache, and the fault
> handler has to allocate one and read it in, it will have zero
> mappings, so check_migrate_misplaced_page() WILL call
> mpol_misplaced() to see if it needs migration.  Of course, it
> should have been allocated on the correct node, so no migration
> should be necessary.  However, it's possible that the node 
> indicated by the policy has no free pages so the newly 
> allocated page may be on a different node.  In this case, I
> guess check_migrate_misplaced_page() will attempt to migrate
> it.  In either case, the "unnecessary" calls to mpol_misplaced()
> and to migrate_misplaced_page(), if the original allocation
> "overflowed", occur after an IO, so this is the slow path
> anyway.  

There is a general issue with memory policies. vma vma policies are 
currently not implemented for file backed pages. So if a page is read in 
then it should be read into a node that follows vma policy.

What you are  doing here is reading a page then checking if 
it is on the correct node? I think you would need to fix the policy issue 
with file backed pages first. Then the page will be placed on the correct 
node after the read and you do not need to check the page afterwards.

I'd be glad to have a a look at the pages when you get the issues with 
the mailer fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
