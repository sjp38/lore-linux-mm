Date: Sun, 7 Oct 2007 18:37:21 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 1/7] swapin_readahead: excise NUMA bogosity
Message-ID: <20071007183721.00b3a8ac@bree.surriel.com>
In-Reply-To: <20071007220529.GA11816@bingen.suse.de>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
	<20071007220529.GA11816@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Oct 2007 00:05:29 +0200
Andi Kleen <ak@suse.de> wrote:

> I suspect the real fix for this mess would be probably to never
> swap in smaller than 1-2MB blocks of continuous memory and then don't 
> do any readahead. That would likely fix the swap problems that were
> discussed at KS too.

I suspect internal fragmentation may make that idea worse.

Malloc and free really don't try to keep related data near
each other in virtual memory.  On the contrary, the anti
fragmentation code in malloc libraries tends to do something
like slab and have quite the opposite result.

Swapping in somewhat large chunks (128kB? 256kB?) is probably
a good idea, but we should probably not expect really large 
blocks to contain related userspace data.

Large readahead works for files because the data is related
and sequential access is common.  Doing something like readahead
(dynamic chunk sizes?) on anonymous memory should be possible
though - we just need to keep track of some things on a per
VMA basis.

After all, we can measure how many of the read-around pages
actually get used by the VMA and how many don't.  From that
data we can adjust the swapin chunk size on the fly.

For swapout we can simply look at which of the linearly nearby
pages from the VMA are also on the inactive list.  If we find
a bunch of pages on the inactive list while some others are on
the active list, we can probably assume that the pages still on
the active list are probably part of another access pattern.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
