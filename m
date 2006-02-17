From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback list initialization
Date: Fri, 17 Feb 2006 03:10:19 +0100
References: <200602170223.34031.ak@suse.de> <Pine.LNX.4.64.0602161749330.27091@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0602161749330.27091@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602170310.19731.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 17 February 2006 02:51, Christoph Lameter wrote:
> On Fri, 17 Feb 2006, Andi Kleen wrote:
> 
> > Empty nodes are not initialization, but the node number is still 
> > allocated. And then it would early except or even triple fault here  
> > because it would try to set  up a fallback list for a NULL pgdat. Oops.
> 
> Isnt this an issue with the arch code? Simply do not allocate an empty 
> node. 

The node is not allocated (in the pgdat sense), but the nodes are not 
renumbered when this happens.

> Is the mapping from linux Node id -> Hardware node id fixed on  
> x86_64? 

No, in theory not, but changing that would require considerable changes 
in the NUMA discovery code and I'm not planning to do that for 2.6.16 now.

Also I think the generic code ought to handle that anyways. Why should
we have node bitmaps if they can't have holes?

> ia64 has a lookup table. 

x86-64 too.
 
> These are empty nodes without processor? Or a processor without a node?

processor(s) without node
(it could be multiple processors in the multi core case)

On some systems it's even unavoidable because on cheaper motherboards
the vendors sometimes don't put DIMM slots to one of the CPUs.

> In that case the processor will have to be assigned a default node.

It will - it will get a nearby node.

In fact it has worked in the past (ok mostly  there were bugs in it too, but 
the last few releases were ok). But due to some changes there were regressions 
and people are hitting this now.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
