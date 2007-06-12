Date: Tue, 12 Jun 2007 12:48:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
In-Reply-To: <1181677473.5592.149.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
References: <20070611234155.GG14458@us.ibm.com>
 <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com>
 <20070612000705.GH14458@us.ibm.com>  <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
  <20070612020257.GF3798@us.ibm.com>  <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com>
  <20070612023209.GJ3798@us.ibm.com>  <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com>
  <20070612032055.GQ3798@us.ibm.com> <1181660782.5592.50.camel@localhost>
 <20070612172858.GV3798@us.ibm.com> <1181674081.5592.91.camel@localhost>
 <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
 <1181677473.5592.149.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Lee Schermerhorn wrote:

> I have been reading.  Might work as you say.  Not because you're testing
> the populated map in alloc_pages_node().  That can still pass an
> off-node zonelist to __alloc_pages().  However, I'm hoping that the test
> of the zone_pgdat in get_page_from_freelist() will do the right thing.
> I'm referring to:
> 
>                 
> 	if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
> 	    zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
> 		break;
> 
> But, I'm not convinced that zonelist->zones[0]->zone_pgdat always refers
> to the node specified the 'nid' argument of alloc_pages_node().  It was
> with my definition of the populated map, but I don't think so, now.

It does refer to the current node if the node has memory on its own. 
alloc_pages_node pickup the zonelist of the node. If the node has memory 
then the first zone will be the nodes zones.

Uhhh... Right there is another special case. The recently 
introduces zonelist swizzle makes the DMA zone come last and if a 
node had only a DMA zone then it may become swizzled to the end of 
the zonelist.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
