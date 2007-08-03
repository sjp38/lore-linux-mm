Date: Thu, 2 Aug 2007 17:31:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC/WIP]  cpuset-independent interleave policy
In-Reply-To: <1186088655.5040.115.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708021728100.13270@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
 <20070727194322.18614.68855.sendpatchset@localhost>
 <20070731192241.380e93a0.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
 <20070731200522.c19b3b95.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
 <20070731203203.2691ca59.akpm@linux-foundation.org>  <1185977011.5059.36.camel@localhost>
  <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
 <1186085156.5040.83.camel@localhost>  <Pine.LNX.4.64.0708021326320.9795@schroedinger.engr.sgi.com>
 <1186088655.5040.115.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Aug 2007, Lee Schermerhorn wrote:

> > AFAICT we would need something like relative node numbers to make this 
> > work across all policy types?
> > 
> > Maybe treat the nodemask as a nodemask relative to the nodes of the cpuset
> > (or other constraint) if a certain flag is set? Nodes that go beyond the 
> > end of the allowed nodes in a certain context wrap around to the first 
> > again?
> 
> One could expose the "MPOL_CONTEXT" flag via the API, but then a task
> might have a mix of policy types.  Maybe a per cpuset control to enable
> relative node ids?  [see below re: translating policies...]

Maybe generally only use relative nodemasks in a cpuset?

> > to node 7. [0-2] would be referring to all. [0-7] would map to multiple 
> > nodes.
> > 
> > So you could specify a relative interleave policy on [0-MAX_NUMNODES] and 
> > it would disperse it evenly across the allowed nodes regardless of the 
> > cpuset that the policy is being used in?
> 
> Yeah, but if the # nodes in the node mask aren't a multiple of the # of
> memory nodes in the cpuset, you might get more pages on one or more
> nodes.

Ok so we may have to modify interleave to stop on the last relative node 
that has memory and then start over?

> You might still want to do the translation, but only in the
> current->mems_allowed mask.  If we had a per cpuset control [all
> policies have absolute or relative node ids], you wouldn't have to look
> at the task policy and all of the vma policies in the relative node id
> case, since basically, all node masks would be valid

Well maybe simply say all policies in a cpuset use relative numbering. 
period?

> > Doing so would fix one of the issues with "memory based" object policies. 
> > However, there will still be the case where the policy desired for one 
> > memory area be node local and or interleave depending on the cpuset.
> 
> Yeah, still got a ways to go, huh?  Anyway, I wanted to start folks
> thinking about it.

Relative node numbers are a great feature regardless. It would allow one 
to write scripts that can run in any cpuset or write applications that can 
set memory policies without worrying too much about where the nodes are 
located.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
