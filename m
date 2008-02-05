Date: Tue, 5 Feb 2008 12:06:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't
 works on memoryless node.
In-Reply-To: <20080205131517.1189104f.pj@sgi.com>
Message-ID: <alpine.DEB.0.9999.0802051159310.5854@chino.kir.corp.google.com>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080202090914.GA27723@one.firstfloor.org> <20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1202149243.5028.61.camel@localhost> <20080205143149.GA4207@csn.ul.ie> <1202225017.5332.1.camel@localhost>
 <Pine.LNX.4.64.0802051011400.11705@schroedinger.engr.sgi.com> <1202236056.5332.17.camel@localhost> <Pine.LNX.4.64.0802051050300.12425@schroedinger.engr.sgi.com> <20080205131517.1189104f.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Lee.Schermerhorn@hp.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Paul Jackson wrote:

> Since any of those future patches only add optional modes
> with new flags, while preserving current behaviour if you
> don't use one of the new flags, therefore the current behavior
> has to work as best it can.
> 

There's a subtlety to this issue that allows it to be fixed and easily 
extended for two upcoming changes:

 - Paul Jackson's mempolicy and cpuset interactions change that will
   probably allow set_mempolicy() callers to specify with a MPOL_*
   flag whether they are referring to "dynamic" or "static" nodemasks[*],
   and

 - node hotplug (both add and remove) that will change the state of a
   node with an identical id.

Paul, with his patch, will need to preserve the "intent" of the mempolicy 
as the nodemask that was passed by the user and attempt on all successive 
rebinds to accomodate that intent as much as possible.

So at the time of rebind it is quite simple to intersect the set of system 
nodes that have memory with the intent of the mempolicy to yield the 
effected nodemask.  This nodemask is saved in the mempolicy (pol->v.nodes 
in this case for interleave) and only steps through the set of nodes that 
can allow interleaved allocations.

When the available nodes changes, either by cpuset change or node hotplug, 
the rebind is quite simple when the intent is preserved.  So we're going 
to need an additional nodemask_t added to struct mempolicy that saves this 
intent and modify contextualize_policy() to allow it.  This will basically 
make any set_mempolicy() call succeed even if the application does not 
have access to any of the mempolicy nodes because it is possible that they 
will become accessible in the future.  In that case the mempolicy is 
effectively MPOL_DEFAULT until the desired nodes become available and it 
is effected.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
