Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 36DC76B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:32:41 -0400 (EDT)
Date: Fri, 22 Oct 2010 11:32:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
In-Reply-To: <20101022155513.GA26790@infradead.org>
Message-ID: <alpine.DEB.2.00.1010221121550.22051@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <alpine.DEB.2.00.1010211259360.24115@router.home> <20101021235854.GD3270@amd> <20101022155513.GA26790@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@kernel.dk>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 2010, Christoph Hellwig wrote:
>
> I think making shrinking decision per-zone is fine.  But do we need to
> duplicate all the lru lists and infrastructure per-zone for that instead
> of simply per-zone?   Even with per-node lists we can easily skip over
> items from the wrong zone.
>
> Given that we have up to 6 zones per node currently, and we would mostly
> use one with a few fallbacks that seems like a lot of overkill.

Zones can also cause asymmetry in reclaim if per zone reclaim is done.

Look at the following zone setup of a Dell R910:

grep "^Node" /proc/zoneinfo
Node 0, zone      DMA
Node 0, zone    DMA32
Node 0, zone   Normal
Node 1, zone   Normal
Node 2, zone   Normal
Node 3, zone   Normal

A reclaim that does per zone reclaim (but in reality reclaims all objects
in a node (or worse as most shrinkers do today in the whole system) will
put 3x the pressure on node 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
