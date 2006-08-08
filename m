Message-ID: <44D8818F.3080703@shadowen.org>
Date: Tue, 08 Aug 2006 13:20:31 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: linearly index zone->node_zonelists[]
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0608041654380.5573@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0608041656150.5573@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608041656150.5573@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> I wonder why we need this bitmask indexing into zone->node_zonelists[]?
> 
> We always start with the highest zone and then include all lower zones
> if we build zonelists.
> 
> Are there really cases where we need allocation from ZONE_DMA or
> ZONE_HIGHMEM but not ZONE_NORMAL? It seems that the current implementation
> of highest_zone() makes that already impossible.
> 
> If we go linear on the index then gfp_zone() == highest_zone() and a lot
> of definitions fall by the wayside.
> 
> We can now revert back to the use of gfp_zone() in mempolicy.c ;-)
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

We have had patches to do this very change before and they were 
rejected.  I can't of course find them to get the reasoning, but this is 
my memory.

The GFP_foo flags are modifiers specifying some property we require from 
an allocation.  Currently all modifiers are singletons, that is they are 
all specified in isolation.  However, the code base as it stands does 
not enforce this.  I could see use cases where we might want to specify 
more than one flag.  For example a GFP_NODE_LOCAL flags which could be 
specified with any of the 'zone selectors'.  This would naturally work 
with the current implementation.

Making the change you suggest here codifies the singleton status of 
these bits.  We should be sure we are not going to use this feature 
before its removed.  I am not sure I am comfortable saying there are no 
uses for it.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
