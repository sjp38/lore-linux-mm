Date: Fri, 8 Jun 2007 15:05:08 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
Message-ID: <20070608060508.GA13727@linux-sh.org>
References: <20070607011701.GA14211@linux-sh.org> <20070607180108.0eeca877.akpm@linux-foundation.org> <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com> <20070608032505.GA13227@linux-sh.org> <Pine.LNX.4.64.0706072027300.27295@schroedinger.engr.sgi.com> <20070608041303.GA13603@linux-sh.org> <Pine.LNX.4.64.0706072123560.27441@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706072123560.27441@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 07, 2007 at 09:27:01PM -0700, Christoph Lameter wrote:
> On Fri, 8 Jun 2007, Paul Mundt wrote:
> 
> > Node 1 SUnreclaim:          8 kB
> 
> > So at least that gets back the couple of slab pages!
> 
> Hmmmm.. is that worth it? The patch is not right btw. There is still the 
> case that new_slab can acquire a page on the wrong node and since we are 
> not setup to allow that node in SLUB we will crash.
> 
Well, every page we can get back is a win in this situation, since we're
talking about individual pages being used by applications. The other 56k
is a bit more problematic, but that's something I'd like to narrow down
as well. I don't mind giving up a chunk of the node as long as the
majority of it is usable for applications, but certainly every page we
can get back helps.

> This now gets a bit ugly. In order to avoid that situation we check
> first if the node is allowed. If not then we simply ask for an alloc on
> the first node.
> 
> But that may still make the page allocator fall back. If that happens then
> we redo the allocation with GFP_THISNODE to force an allocation on the 
> first node or fail.
> 
This patch works fine for the few cases I've tried at least.

> I think we could do better by constructing a custom zonelist but that will 
> be even more special casing.
> 
I don't know if a custom zonelist is worth the trouble. For the common
asymmetric case, you could at least infer that ZONE_NORMAL is the only
thing populated per node (well, small nodes other than node 0). If you
mean just creating the zonelist from the range of allowable SLUB nodes,
that could work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
