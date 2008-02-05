Date: Tue, 5 Feb 2008 11:56:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't
 works on memoryless node.
In-Reply-To: <20080205041755.3411b5cc.pj@sgi.com>
Message-ID: <alpine.DEB.0.9999.0802051146300.5854@chino.kir.corp.google.com>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080202090914.GA27723@one.firstfloor.org> <20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1202149243.5028.61.camel@localhost> <20080205041755.3411b5cc.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, clameter@sgi.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Paul Jackson wrote:

> But that discussion touched on some other long standing deficiencies
> in the way that I had originally glued cpusets and memory policies
> together.  The current mechanism doesn't handle changing cpusets very
> well, especially if the number of nodes in the cpuset increases.
> 

That's because of the nodemask remaps that are done for the various 
mempolicy cases when rebinding the policy.  I agree we cannot change that 
implementation now even though it is undocumented.

The more alarming result of these remaps is in the MPOL_BIND case, as 
we've talked about before.  The language in set_mempolicy(2):

	The MPOL_BIND policy is a strict policy that restricts memory
	allocation to the nodes specified in nodemask. There won't be
	allocations on other nodes.

makes it pretty clear that allocations will not be done on other nodes not 
provided in the set_mempolicy() nodemask if the task is not swapped out.  

But the current implementation allows that if the task is either moved to 
a different cpuset or its cpuset's mems change.  For example, consider a 
task that is allowed nodes 1-3 by its cpuset and asks for a MPOL_BIND 
mempolicy of node 2.  If that cpuset's mems change to 4-6, the mempolicy 
is now effectively a bind on node 5.

> The next two steps I need to take are:
>  1) propose this patch, with careful explanation (it's easy to lose
>     one's bearings in the mappings and remappings of node numberings)
>     to a wider audience, such as linux-mm or linux-kernel, and

Thanks.

>  2) carefully test this, especially on each code path I touched in
>     mm/mempolicy.c, where the changes were delicate, to ensure I
>     didn't break any existing code.
> 
> There were also some other, smaller patches proposed, by myself and
> others.  I was preferring to address a wider set of the long standing
> issues in this area, but the others above mostly preferred the smaller
> patches.  This needs to be discussed in a wider forum, and a concensus
> reached.
> 

I think if these MPOL_* flags that you're proposing are made as generic as 
possible for all possible mempolicies (current and future), it would be 
the optimal change.  It would prevent us from having to add new flags for 
corner-cases in the future and would allow us to keep the flag set as 
small as possible.  My suggestion of MPOL_F_STATIC_NODEMASK goes a long 
way to solve these issues both for MPOL_INTERLEAVE (in conjunction with 
storing the set_mempolicy() intent) and the MPOL_BIND discrepency I 
mentioned above.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
