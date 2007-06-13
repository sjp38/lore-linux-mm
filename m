Date: Wed, 13 Jun 2007 18:50:33 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
Message-ID: <20070613095033.GA16647@linux-sh.org>
References: <20070613031203.GB15009@linux-sh.org> <466F6351.9040503@yahoo.com.au> <20070613033306.GA15169@linux-sh.org> <466F66E3.8020200@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <466F66E3.8020200@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 13, 2007 at 01:39:15PM +1000, Nick Piggin wrote:
> Paul Mundt wrote:
> >That's why I tossed in the node id matching in slob_alloc() for the
> >partial free page lookup. At the moment the logic obviously won't scale,
> >since we end up scanning the entire freelist looking for a page that
> >matches the node specifier. If we don't find one, we could rescan and
> >just grab a block from another node, but at the moment it just continues
> >on and tries to fetch a new page for the specified node.
> 
> Oh, I didn't notice that. OK, sorry that would work.
> 
> ... but that goes against Matt's direction of wanting to improve basic
> things like SMP scalability before NUMA awareness. I think once we had
> per-CPU lists in place for SMP scalability, NUMA come much more naturally
> and easily.
> 
I'm not sure that the two are at odds. With the SMP scaling work in
place, it's much easier to extend the NUMA support in to something that
scales more intelligently. And even in that case, most of this patch
remains unchanged, it's mostly just the logic in slob_alloc() that
will need a bit of rework.

The problem I'm trying to solve with the current patch is simplistic
management of small nodes on UP. Since the nodes are small, scanning the
global freelist is not a problem. Splitting out per-CPU or per-node
freelists and revamping the locking to be more fine grained is certainly
something that would be nice to move to, but I think that's an
incremental thing we can do once the SMP scalability work is done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
