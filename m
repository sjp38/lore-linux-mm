From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback list initialization
Date: Fri, 17 Feb 2006 19:07:38 +0100
References: <200602170223.34031.ak@suse.de> <Pine.LNX.4.64.0602170841190.916@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0602170841190.916@g5.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602171907.39236.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: akpm@osdl.org, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 17 February 2006 17:52, Linus Torvalds wrote:
> 
> On Fri, 17 Feb 2006, Andi Kleen wrote:
> > 
> > The new function to set up the node fallback lists didn't handle
> > holes in the node map. This happens e.g. on Opterons when 
> > the a CPU is missing memory, which is not that uncommon. 
> 
> That whole function is crap. Your changes don't seem to make it any less 
> crap, and depends on some insane and unreliable node ordering 
> characteristic, as far as I can tell. The thing is horrid.

Yes the algorithm is a bit strange anyways. Essentially it's a bogosort 
indexed on node_distance() with some additional tweaks.

Maybe it would be better to collect all data into an array and then do a 
normal sort.

 
> Think about it: because we do "for_each_online_node(i)", the "i" is _not_ 
> guaranteed to be contiguous, which means that "node + i" is not guaranteed 
> to be contiguous, which in turn means that you may be hopping over all the 
> valid nodes, and every time (because you do that stupid and undefined 
> "node + i" crap) you may hit something invalid or empty.

That is why I added the !NODE_DATA(...) continue check
It will just continue until it finds a usable node. 

But you're right it can miss valid nodes.


> NOTE! I've not tested (and thus not debugged) it. I don't even have NUMA 
> enabled, so I've not even compiled it. Somebody else please test it, and 
> send it back to me with a sign-off and a proper explanation, and I'll sign 
> off on it again and apply it.

I gave it a quick boot on the simulator with a missing node and it looks 
good. Will test it a bit more and then resubmit it.

Thanks,

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
