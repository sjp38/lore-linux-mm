Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2038D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 08:58:09 -0400 (EDT)
Date: Tue, 22 Mar 2011 13:57:36 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] xfs: flush vmap aliases when mapping fails
Message-ID: <20110322125736.GZ2140@cmpxchg.org>
References: <1299713876-7747-1-git-send-email-david@fromorbit.com>
 <20110310073751.GB25374@infradead.org>
 <20110310224945.GA15097@dastard>
 <20110321122526.GX2140@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110321122526.GX2140@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, xfs@oss.sgi.com, linux-mm@kvack.org

On Mon, Mar 21, 2011 at 01:25:26PM +0100, Johannes Weiner wrote:
> On Fri, Mar 11, 2011 at 09:49:45AM +1100, Dave Chinner wrote:
> > FWIW, while the VM folk might be paying attention about vmap realted
> > stuff, this vmap BUG() also needs triage:
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=27002
> 
> I stared at this bug and the XFS code for a while over the weekend.
> What you are doing in there is really scary!
> 
> So xfs_buf_free() does vm_unmap_ram if the buffer has the XBF_MAPPED
> flag set and spans multiple pages (b_page_count > 1).
> 
> In xlog_sync() you have that split case where you do XFS_BUF_SET_PTR
> on that in-core log's l_xbuf which changes that buffer to, as far as I
> could understand, linear kernel memory.  Later in xlog_dealloc_log you
> call xfs_buf_free() on that buffer.
> 
> I was unable to determine if this can ever be more than one page in
> the buffer for the split case.  But if this is the case, you end up
> invoking vm_unmap_ram() on something you never vm_map_ram'd, which
> could explain why this triggers the BUG_ON() for the dirty area map.

Blech, that's bogus, please pardon my rashness.

I looked over the vmalloc side several times but could not spot
anything that would explain this crash.

However, when you switched from vunmap to vm_unmap_ram you had to add
the area size parameter.

I am guessing that the base address was always correct, vunmap would
have caught an error with it.  But the new size argument could be too
large and crash the kernel when it would reach into the next area that
had already been freed (and marked in the dirty bitmap).

I have given up on verifying that what xlog_sync() does to l_xbuf is
okay.  It would be good if you could confirm that it leaves the buffer
in a state so that its b_addr - b_offset, b_page_count are correctly
describing the exact vmap area.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
