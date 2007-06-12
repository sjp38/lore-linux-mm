Date: Tue, 12 Jun 2007 11:41:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
In-Reply-To: <1181660782.5592.50.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706121140020.30754@schroedinger.engr.sgi.com>
References: <20070611225213.GB14458@us.ibm.com>
 <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com>
 <20070611234155.GG14458@us.ibm.com>  <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com>
  <20070612000705.GH14458@us.ibm.com>  <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
  <20070612020257.GF3798@us.ibm.com>  <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com>
  <20070612023209.GJ3798@us.ibm.com>  <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com>
  <20070612032055.GQ3798@us.ibm.com> <1181660782.5592.50.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Lee Schermerhorn wrote:

> 		page = alloc_pages_node(nid,
>                                GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
>                                HUGETLB_PAGE_ORDER);
> 
> I need to get a page that is on nid.  On our platform, GFP_HIGHUSER is
> going to specify the zonelist for ZONE_NORMAL.  The first zone on this
> list needs to be on-node for nid.  With the changes you've made to the
> definition of populated map, I think this won't be the case.  I need to
> test your latest patches and fix that, if it's broken.

Yes that is the intend of the fixes.

> I still think using policy zone is the "right way" to go, here.  After
> all, only pages in the policy zone are controlled by policy, and that's
> the goal of spreading out the huge pages across nodes--to make them
> available to satisfy memory policy at allocation time.  But that would
> need some adjustments for x86_64 systems that have some nodes that are
> all/mostly DMA32 and other nodes that are populated in zones > DMA32, if
> we want to allocate huge pages out of the DMA32 zone.   

GFP_THISNODE will work right for that case if we get the intended fix in.

> 
> As far as the static variable, and round-robin allocation:  the current
> method "works" both for huge pages allocated at boot time and for huge
> pages allocated at run-time vi the vm.nr_hugepages sysctl.  By "works",
> I mean that it continues to spread the pages evenly across the
> "populated" nodes.  If, however, you use the task local counter to
> interleave fresh huge pages, each write to the nr_hugepages from a
> different task ["echo NN >.../nr_hugepages"] will start at node zero or
> the first populated node--assuming you're interleaving across populated
> nodes and not on-line nodes.  That's probably OK if you always change

We may want to change that behavior. Interleave should start at the local 
node and then proceed from there. If there are just a few pages needed 
then they would be better placed local to the process.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
