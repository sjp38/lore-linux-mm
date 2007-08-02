Date: Thu, 2 Aug 2007 13:34:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC/WIP]  cpuset-independent interleave policy
In-Reply-To: <1186085156.5040.83.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708021326320.9795@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
 <20070727194322.18614.68855.sendpatchset@localhost>
 <20070731192241.380e93a0.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
 <20070731200522.c19b3b95.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
 <20070731203203.2691ca59.akpm@linux-foundation.org>  <1185977011.5059.36.camel@localhost>
  <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
 <1186085156.5040.83.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Aug 2007, Lee Schermerhorn wrote:

> This patch introduces a cpuset-independent interleave policy that will
> work in shared policies applied to shared memory segments attached by
> tasks in disjoint cpusets.  The cpuset-independent policy effectively
> says "interleave across all valid nodes in the context where page
> allocation occurs."

In order to make this work across policies you also need to have context 
indepedent MPOL_BIND right?

AFAICT we would need something like relative node numbers to make this 
work across all policy types?

Maybe treat the nodemask as a nodemask relative to the nodes of the cpuset
(or other constraint) if a certain flag is set? Nodes that go beyond the 
end of the allowed nodes in a certain context wrap around to the first 
again?


E.g. if you have a cpuset with nodes

 2 5 7

Then a relative nodemask [0] would refer to node 2. [1] to node 5 and [3] 
to node 7. [0-2] would be referring to all. [0-7] would map to multiple 
nodes.

So you could specify a relative interleave policy on [0-MAX_NUMNODES] and 
it would disperse it evenly across the allowed nodes regardless of the 
cpuset that the policy is being used in?

If we had this then we may be able to avoid translating memory policies 
while migrating processes from cpuset to cpuset. Paul and I talked about 
this a couple of times in the past.

Doing so would fix one of the issues with "memory based" object policies. 
However, there will still be the case where the policy desired for one 
memory area be node local and or interleave depending on the cpuset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
