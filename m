Subject: Re: Audit of "all uses of node_online()"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708021323390.9711@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070727194322.18614.68855.sendpatchset@localhost>
	 <20070731192241.380e93a0.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
	 <20070731200522.c19b3b95.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
	 <20070731203203.2691ca59.akpm@linux-foundation.org>
	 <1185977011.5059.36.camel@localhost>
	 <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
	 <1186085994.5040.98.camel@localhost>
	 <Pine.LNX.4.64.0708021323390.9711@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 08 Aug 2007 18:19:41 -0400
Message-Id: <1186611582.5055.95.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, ak@suse.de
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-02 at 13:26 -0700, Christoph Lameter wrote:
> On Thu, 2 Aug 2007, Lee Schermerhorn wrote:
Just getting back to this...

Andi: I added you to the To: list, as I have specific questions for you
below, regarding mbind() and cpuset constraints.

>  
> > Note that the list includes a lot of architectural dependent files.
> > Shall I do a separate patch for each arch, so that arch maintainer can
> > focus on that [I assume they'll want to review], or a single "jumbo
> > patch" to reduce traffic?
> 
> Separate arch patches would be good.

Yeah, that's what Andrew said.  I'm trying to wrap up the "generic"
patch now...

> 
> > include/linux/topology.h
> > mm/mempolicy.c
> > 	? should BIND nodes be limited to nodes with memory?
> 
> Or it could automatically limit to those by anding with N_HIGH_MEMORY?

That's what I meant.  the "ALL policies..." below is an extension of
this thought.

> 
> > 	? ALL policies in mpol_new()?
> > 	? should mpol_check_policy() require a subset of nodes with memory?
> 
> Yea difficult question. What would be impact be if we require that? A node 
> going down could cause the application to fail?

OK, 

First note that mpol_check_policy() is always called just before
mpol_new() [except in the case of share policy init which is covered by
the fix mentioned below in previous mail re: parsing mount options].
Now, looking at this more, I think mpol_check_policy() could [should?]
ensure that the argument nodemask is non-null after ANDing with the
N_HIGH_MEMORY mask--i.e., contains at least one node with memory.

However, it should first check and allow the special case[s] of an empty
nodemask with MPOL_PREFERRED meaning "local" allocation and, if my
"cpuset-independent" interleave policy is accepted, where an empty node
mask means all allowed nodes in cpuset where allocation occurs.

If mpol_check_policy() did that, we could just mask off nodes w/o memory
in mpol_new() knowing that we'd end up with at least one populated node.
The result of this change would be that we would now silently mask off
invalid nodes--i.e., nodes w/o memory, NOT nodes disallowed by
cpuset--instead of giving an error.  Note that this is the effect, for
interleave policy, of the memoryless node patch to fix interleave
behavior.

As far as effect of node "going down".  Currently, mpol_check_policy()
checks against online nodes.  If one "goes down", it's no longer
on-line, right?  So that check would fail.   I don't think changing it
to nodes with memory would change the user visible behavior. 

Andi:

Somewhat related:  In looking at these, I see that set_mempolicy() calls
contextualize_policy() which first ensures that the nodemask is a subset
of the current task's mems_allowed, returning EINVAL if not.  If the
mask IS a valid subset, it calls mpol_check_new() for additional sanity
checks, as discussed above.

However,  do_mbind() calls mpol_check_policy() directly.  Thus, is
doesn't seem to enforce the cpuset constraints for vma and shared
policy.  Is this intentional--e.g., so shmem policies can specify any
node in the system?  I think the cpuset constraint will be applied later
during page allocation, right?

> 
> > mm/shmem.c
> > 	fixed mount option parsing and superblock setup.

I see that we do inline validation of any policy specified in the mount
options.  Should we use common mpol_check() function?  Or is that too
application specific?

> > mm/page-writeback.c
> > 	fixed highmem_dirtyable_memory() to just look at N_MEMORY
> 
> N_HIGH_MEMORY right?

Yeah.  I hadn't upgraded to your latest patch set when I started this.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
