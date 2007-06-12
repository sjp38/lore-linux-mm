Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070612032055.GQ3798@us.ibm.com>
References: <20070611225213.GB14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com>
	 <20070611234155.GG14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com>
	 <20070612000705.GH14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
	 <20070612020257.GF3798@us.ibm.com>
	 <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com>
	 <20070612023209.GJ3798@us.ibm.com>
	 <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com>
	 <20070612032055.GQ3798@us.ibm.com>
Content-Type: text/plain
Date: Tue, 12 Jun 2007 11:06:22 -0400
Message-Id: <1181660782.5592.50.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-06-11 at 20:20 -0700, Nishanth Aravamudan wrote:
> On 11.06.2007 [19:54:13 -0700], Christoph Lameter wrote:
> > On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> > 
> > > On 11.06.2007 [19:20:58 -0700], Christoph Lameter wrote:
> > > > On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> > > > 
> > > > > [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
> > > > 
> > > > There is no point in compiling the interleave logic for !NUMA.
> > > > There needs to be some sort of !NUMA fallback in hugetlb. It would
> > > > be better to call a interleave function in mempolicy.c that
> > > > provides an appropriate shim for !NUMA.
> > > 
> > > Hrm, if !NUMA, is the nid of the only node guaranteed to be 0? If so, I
> > > can just
> > 
> > Yes.
> > 
> > > Make alloc_fresh_huge_page() and other generic variants call into
> > > the _node() versions with nid=0, if !NUMA.
> > > 
> > > Would that be ok?
> > 
> > I am not sure what you are up to. Just make sure that the changes are
> > minimal. Look in the source code for other examples on how !NUMA
> > situations were handled.
> 
> I swear I'm trying to make the code do the right thing, and understand
> the NUMA intricacies better. Sorry for the flood of e-mails and such. I
> asked about specific other cases because they are used in !NUMA
> situations too and I wasn't sure why node_populated_map should be
> different.
> 
> But ok, I will rely on the source to be correct and make my changelog
> indicate where I got the ideas from.

Nish:  when this all settles down, I still need to make sure it works on
our platforms with the funny DMA-only node.  What that comes down to is
that when alloc_fresh_huge_page() calls:

		page = alloc_pages_node(nid,
                               GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
                               HUGETLB_PAGE_ORDER);

I need to get a page that is on nid.  On our platform, GFP_HIGHUSER is
going to specify the zonelist for ZONE_NORMAL.  The first zone on this
list needs to be on-node for nid.  With the changes you've made to the
definition of populated map, I think this won't be the case.  I need to
test your latest patches and fix that, if it's broken.

I still think using policy zone is the "right way" to go, here.  After
all, only pages in the policy zone are controlled by policy, and that's
the goal of spreading out the huge pages across nodes--to make them
available to satisfy memory policy at allocation time.  But that would
need some adjustments for x86_64 systems that have some nodes that are
all/mostly DMA32 and other nodes that are populated in zones > DMA32, if
we want to allocate huge pages out of the DMA32 zone.   

As far as the static variable, and round-robin allocation:  the current
method "works" both for huge pages allocated at boot time and for huge
pages allocated at run-time vi the vm.nr_hugepages sysctl.  By "works",
I mean that it continues to spread the pages evenly across the
"populated" nodes.  If, however, you use the task local counter to
interleave fresh huge pages, each write to the nr_hugepages from a
different task ["echo NN >.../nr_hugepages"] will start at node zero or
the first populated node--assuming you're interleaving across populated
nodes and not on-line nodes.  That's probably OK if you always change
nr_hugepages by a multiple of the number of populated nodes.  And, if
things get out of balance, we'll have your per node attribute, I hope,
to adjust any individual node.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
