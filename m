Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2E5926B0047
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 02:54:51 -0500 (EST)
Date: Mon, 25 Jan 2010 18:54:45 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] xfs: use scalable vmap API
Message-ID: <20100125075445.GD19664@laptop>
References: <20081021082542.GA6974@wotan.suse.de>
 <20081021082735.GB6974@wotan.suse.de>
 <20081021120932.GB13348@infradead.org>
 <20081022093018.GD4359@wotan.suse.de>
 <20100119121505.GA9428@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100119121505.GA9428@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 19, 2010 at 07:15:05AM -0500, Christoph Hellwig wrote:
> Hi Nick,
> 
> I've looked into retesting and re-enabling the swithc to your
> scalabale vmap API (original commit 95f8e302c04c0b0c6de35ab399a5551605eeb006).
> 
> The good thing is that I can't reproduce the original regressions in
> xfstests I've seen.  The bad news is that starting from the second
> consequitive xfstests run we're not able to vmalloc the log buffers
> anymore.  It seems the use of this API introduces some leak of vmalloc
> space.  Any idea how to debug this further?

Hi Christoph,

OK, that's worrying. It's silly have all that vmap layer work in the
tree and no users, not surprised to have a bug there.

Is this on a 32-bit system with small vmalloc area?

Basically in the scalable API implementation, we allocate per-CPU vmap
chunks (struct vmap_block) from the normal global allocator, and then
subsequently do allocations from those chunks using the simple bitmap
allocator.

Now there is more room for fragmentation with this approach, and a few
problems that I should really fix: firstly, a chunk with say a 1 page
hole left in it that is never used will never get freed. So it will be
good to free those chunks. Secondly, one CPU should be able to steal
from others if it can't find more memory.

So if you have small vmalloc space, it could be just these issues making
vmalloc consumption worse. Otherwise yes there could be a real leak there
unrelated to fragmentation.

When the vmap allocation fails, it would be good to basically see the
alloc_map and dirty_map for each of the vmap_blocks. This is going to be
a lot of information. Basically for all blocks with
free+dirty == VMAP_BBMAP_BITS are ones that could be released and you
could try the alloc again.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
