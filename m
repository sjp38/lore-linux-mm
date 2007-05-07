Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 07 May 2007 09:40:33 -0400
Message-Id: <1178545233.5079.10.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-04 at 14:27 -0700, Christoph Lameter wrote:
> On Fri, 4 May 2007, Lee Schermerhorn wrote:
> 
> > On Wed, 2007-05-02 at 21:21 -0500, Anton Blanchard wrote:
> > > An interesting bug was pointed out to me where we failed to allocate
> > > hugepages evenly. In the example below node 7 has no memory (it only has
> > > CPUs). Node 0 and 1 have plenty of free memory. After doing:
> > 
> > Here's my attempt to fix the problem [I see it on HP platforms as well],
> > without removing the population check in build_zonelists_node().  Seems
> > to work.
> 
> I think we need something like for_each_online_node for each node with
> memory otherwise we are going to replicate this all over the place for 
> memoryless nodes. Add a nodemap for populated nodes?
> 
> I.e.
> 
> for_each_mem_node?
> 
> Then you do not have to check the zone flags all the time. May avoid a lot 
> of mess?

>From a performance point of view, I don't think using the zone flags to
figure out which zone to be looking at should cause any noticable
overhead.  I hope no one is increasing [or decreasing] nr_hugepages all
that often.  I would expect it to happen at boot time, or soon
thereafter.  Much later and you run the risk of not being able to
allocate hugepages because of fragmentation [Hi, Mel!].

We'll still need to iterate over such a mask multiple times until the
requested number of hugepages has been allocated.  Of course, this as
well as the current method, assumes that all nodes have approximately
the same amount of memory.  I've considered precalculating the number of
hugepages per node based on the amount of memory in each node, but this
would require that hugetlb.c have even more knowledge of the zones...

Anyway, I hit the problem [imbalance in # of hugepages per node with
memory due to memoryless nodes] about the time that Anton posted his
fix.  I thought that adding 3 [non-commentary/non-whitespace] lines in a
non-performance path in order to avoid empty zones in the zonelists was
a good tradeoff.  Silly me ;-)!

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
