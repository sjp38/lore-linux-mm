Subject: Re: [PATCH/RFC] Migrate-on-fault prototype 0/5 V0.1 - Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <Pine.LNX.4.64.0603091104280.17622@schroedinger.engr.sgi.com>
References: <1141928905.6393.10.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0603091104280.17622@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 09 Mar 2006 14:30:02 -0500
Message-Id: <1141932602.6393.68.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-03-09 at 11:12 -0800, Christoph Lameter wrote:
> On Thu, 9 Mar 2006, Lee Schermerhorn wrote:
> 
> > The basic idea is that when a fault handler [do_swap_page,
> > filemap_nopage,
> > ...] finds a cached page with zero mappings that is otherwise "stable"--
> > i.e., no writebacks--this is a good opportunity to check whether the 
> > page resides on the node indicated by the policy in the current context.
> 
> Note that this is only one of the types of use of memory policy. Policy is 
> typically used for placement and may be changed repeatedly for the same 
> memory area in order to get certain patterns of allocation. This approach 
> assumes that pages must follow policy. This is not the case for 
> applications that keep changing allocation policies. But we have a similar
> use with MPOL_MF_MOVE and MPOL_MF_MOVE_ALL. However, these need to be 
> enabled explicitly. We may not want this mechanism to be on by default 
> because it may destroy the arrangement of pages that an HPC application 
> has tried to obtain.

Yes, I am assuming that pages must [should, best effort, anyway] follow
policy.  When they don't, I assume it's because of current limitations
in the mechanism.  But, that's just me...  

I'm wondering if applications keep changing the policy as you describe
to "finesse" the system--e.g., because they don't have fine enough
control over the policies.  Perhaps I read it wrong, but it appears to
me that we can't set the policy for subranges of a vm area.  So maybe
applications have to set the policy for the [entire] vma, touch a few
pages to get them placed, change the policy for the [entire] vma, touch
a few more pages, ...   Of course, storing policies on subranges of vmas
takes more mechanism that we current have, and increases the cost of
node computation on each allocation.  Probably why we don't have it
currently.

Anyway, with the patches I sent, pages would only migrate on fault if
they had no mappings at the time of fault.  If an application had
explicitly placed them by touching them, they could only have zero map
count if something happened to pull them out of the task's pte.  I would
think that if they cared, they'd mlock them so that wouldn't happen?

> 
> > Note that when a page is NOT found in the cache, and the fault
> > handler has to allocate one and read it in, it will have zero
> > mappings, so check_migrate_misplaced_page() WILL call
> > mpol_misplaced() to see if it needs migration.  Of course, it
> > should have been allocated on the correct node, so no migration
> > should be necessary.  However, it's possible that the node 
> > indicated by the policy has no free pages so the newly 
> > allocated page may be on a different node.  In this case, I
> > guess check_migrate_misplaced_page() will attempt to migrate
> > it.  In either case, the "unnecessary" calls to mpol_misplaced()
> > and to migrate_misplaced_page(), if the original allocation
> > "overflowed", occur after an IO, so this is the slow path
> > anyway.  
> 
> There is a general issue with memory policies. vma vma policies are 
> currently not implemented for file backed pages. So if a page is read in 
> then it should be read into a node that follows vma policy.

I agree.  That should happen.  Might not be the first node specified.
Might have overflowed to another node/zone in the list [preferred or
bind with multiple nodes].

> 
> What you are  doing here is reading a page then checking if 
> it is on the correct node? I think you would need to fix the policy issue 
> with file backed pages first. Then the page will be placed on the correct 
> node after the read and you do not need to check the page afterwards.

Yes, that could happen.  That's what I was trying to explain.  I don't
LIKE that, but I haven't thought about how to distinguish a page that
just go read in and is likely on the right node [an acceptable one,
anyway] and one that has zero mappings because it hasn't been referenced
in a while.  Any ideas?

> 
> I'd be glad to have a a look at the pages when you get the issues with 
> the mailer fixed.

I just sent another one to myself, and got it just fine.  I copied you
in addition to the list.  Was that copy borked, too?  If so, I'll try
sending you copies with good ol' mail(1).

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
