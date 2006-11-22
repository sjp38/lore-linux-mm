Date: Tue, 21 Nov 2006 16:44:20 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH 1/11] Add __GFP_MOVABLE flag and update callers
In-Reply-To: <Pine.LNX.4.64.0611212340480.11982@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0611211637120.3338@woody.osdl.org>
References: <20061121225022.11710.72178.sendpatchset@skynet.skynet.ie>
 <20061121225042.11710.15200.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0611211529030.32283@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611212340480.11982@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Tue, 21 Nov 2006, Mel Gorman wrote:
>
> On Tue, 21 Nov 2006, Christoph Lameter wrote:
> 
> > Are GFP_HIGHUSER allocations always movable? It would reduce the size of
> > the patch if this would be added to GFP_HIGHUSER.
> > 
> 
> No, they aren't. Page tables allocated with HIGHPTE are currently not movable
> for example. A number of drivers (infiniband for example) also use
> __GFP_HIGHMEM that are not movable.

It might make sense to just use another GFP_HIGHxyzzy #define for the 
non-movable HIGHMEM users. There's probably much fewer of those, and their 
behaviour obviously is very different from the traditional GFP_HIGHUSER 
pages (ie page cache and anonymous user mappings).

So you could literally use "GFP_HIGHPTE" for the PTE mappings, and that 
would in fact even simplify some of the users (ie it would allow moving 
the #ifdef CONFIG_HIGHPTE check from the code to <linux/gfp.h>). Similarly 
for any other non-movable things, no?

So then we'd just make GFP_HIGHUSER implicitly mean "movable". It could be 
nice if GFP_USER would do the same, but I guess we have too many of those 
around to verify (although _most_ of those are probably kmalloc, and 
kmalloc would obviously better strip away the __GFP_MOVABLE bit anyway).

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
