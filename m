Subject: Re: [PATCH] Document Linux Memory Policy - V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707271148170.16415@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	 <20070725111646.GA9098@skynet.ie>
	 <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	 <20070726132336.GA18825@skynet.ie>
	 <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	 <20070726225920.GA10225@skynet.ie>
	 <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
	 <20070727082046.GA6301@skynet.ie> <20070727154519.GA21614@skynet.ie>
	 <Pine.LNX.4.64.0707271026040.15990@schroedinger.engr.sgi.com>
	 <1185559260.5069.40.camel@localhost>
	 <Pine.LNX.4.64.0707271148170.16415@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 15:24:33 -0400
Message-Id: <1185564273.5069.91.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, ak@suse.de, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com, Michael Kerrisk <mtk-manpages@gmx.net>, Randy Dunlap <randy.dunlap@oracle.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-27 at 11:55 -0700, Christoph Lameter wrote:
> On Fri, 27 Jul 2007, Lee Schermerhorn wrote:
> 
> > +    Shared Policy:  This policy applies to "memory objects" mapped shared into
> > +    one or more tasks' distinct address spaces.  Shared policies are applied
> > +    directly to the shared object.  Thus, all tasks that attach to the object
> > +    share the policy, and all pages allocated for the shared object, by any
> > +    task, will obey the shared policy.
> 
> This applies to shmem only not to shared memory. Shared memory can also 
> come about by mmapping a file etc. Its better to describe shmem 
> as an exceptional situation later and warn of the surprises coming with 
> the use of memory policies on shmem in a separate section.

I do explain that later in the doc.  I'll see if I can reword it to pull
that up here.

> 
> > +	MPOL_BIND:  This mode specifies that memory must come from the
> > +	set of nodes specified by the policy.  The kernel builds a custom
> > +	zonelist pointed to by the zonelist member of struct mempolicy,
> > +	containing just the nodes specified by the Bind policy.  If the kernel
> > +	is unable to allocate a page from the first node in the custom zonelist,
> > +	it moves on to the next, and so forth.  If it is unable to allocate a
> > +	page from any of the nodes in this list, the allocation will fail.
> 
> The implementation details may not be useful to explain here and may 
> change soon. Maybe just describe the effect?

I wanted to explain it to contrast to node zonelists and as context for
the next paragraph.  I think the notion of custom zonelists is important
in the current implementation.  And, I plan to keep this up to date with
the forth coming changes.  Maybe it'll change before this even get's
merged into Linus' tree.  But, if I could get this into -mm, I can
submit update patches making it clear what changed when.

> 
> > +	    The memory policy APIs do not specify an order in which the nodes
> > +	    will be searched.  However, unlike the per node zonelists mentioned
> > +	    above, the custom zonelist for the Bind policy do not consider the
> > +	    distance between the nodes.  Rather, the lists are built in order
> > +	    of numeric node id.
> 
> Yea another reson to get the nodemask as a parameter for alloc_pages().

OK.  Again, just wanted to make current behavior explicit.  Will update
when it changes.

> 
> > +2) when tasks in two cpusets share access to a memory region, such as shared
> > +   memory segments created by shmget() of mmap() with the MAP_ANONYMOUS and
> > +   MAP_SHARED flags, only nodes whose memories are allowed in both cpusets
> > +   may be used in the policies.  Again, obtaining this information requires
> > +   "stepping outside" the memory policy APIs to use the cpuset information.
> > +   Furthermore, if the cpusets' "allowed memory" sets are disjoint, "local"
> > +   allocation is the only valid policy.
> 
> In general this works fine with a shared mapping via mmap (which is much 
> more common). The problem exists if one uses shmem with the strange shared 
> semantics.

If the shared mapping is with MAP_ANONYMOUS, I believe that you get
"shmem"--same issues as with "shm" [SysV shared memory].  It works
"fine" [your definition, I guess] for shared, mmap()ed files because the
policy doesn't get applied to the object and the vma policy is ignored.
As far as the shared policy semantics being "strange", let's not restart
that, uh, "discussion" in this thread.  I've tried to avoid that topic
in this document, and just describe the concepts/design/behavior in the
interest of getting a baseline document.  That said, undoubtedly my bias
sneaks through in places.

As I mentioned to Randy, I'll make another pass after weekend.

Have a good one,
Lee  



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
