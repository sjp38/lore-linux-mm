Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5311A6B01EF
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:52:58 -0400 (EDT)
Date: Thu, 3 Jun 2010 02:52:52 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 02/17] xfs: skip writeback from reclaim context
Message-ID: <20100603065252.GA28592@infradead.org>
References: <20100531160727.842750532@bombadil.infradead.org> <20100531160859.184576507@bombadil.infradead.org> <20100602043957.GB7011@dastard> <20100602100812.GA25035@infradead.org> <20100602230209.GA27325@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100602230209.GA27325@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 03, 2010 at 09:02:09AM +1000, Dave Chinner wrote:
> Did you skip it unconditionally, or only when a transaction was
> required?

xfs_vm_releasepage is mostly a no-op if no transaction is required.
If we have neither delalloc nor unwritten buffer we do not actually
enter xfs_page_state_convert, and ->releasepage also doesn't touch
unampped buffers at all.

> The scary part is that I've seen stack traces (i.e. most stack used)
> through this reclaim path for delalloc conversion even for
> allocations that are GFP_NOFS and the only thing saving us from
> deadlocks is th PF_FSTRANS check. Even worse is that
> shrinker_page_list() will call try_to_release_pages() without
> checking whether it's allowed to enter the filesystem or not, so we
> can be doing block allocation in places we've specifically told the
> memory allocation subsystem not to....

s/shrinker_page_list/shrink_page_list/ and
s/try_to_release_pages/try_to_release_page/ above.

shrink_page_list takes the gfp_mask for try_to_release_page from
the scan_control structure passed to it from all the top of the long
callchain.  I can't find anobvious bug, but this could cause a lot
more harm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
