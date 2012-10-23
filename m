Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 591366B0070
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 00:40:28 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so5898063ied.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 21:40:27 -0700 (PDT)
Date: Mon, 22 Oct 2012 21:40:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
In-Reply-To: <20121022123852.a4bd5f2a.akpm@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1210222121270.1136@eggly.anvils>
References: <1350918406-11369-1-git-send-email-jack@suse.cz> <20121022123852.a4bd5f2a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org

On Mon, 22 Oct 2012, Andrew Morton wrote:
> On Mon, 22 Oct 2012 17:06:46 +0200
> Jan Kara <jack@suse.cz> wrote:
> 
> > On s390 any write to a page (even from kernel itself) sets architecture
> > specific page dirty bit. Thus when a page is written to via buffered write, HW
> > dirty bit gets set and when we later map and unmap the page, page_remove_rmap()
> > finds the dirty bit and calls set_page_dirty().
> > 
> > Dirtying of a page which shouldn't be dirty can cause all sorts of problems to
> > filesystems. The bug we observed in practice is that buffers from the page get
> > freed, so when the page gets later marked as dirty and writeback writes it, XFS
> > crashes due to an assertion BUG_ON(!PagePrivate(page)) in page_buffers() called
> > from xfs_count_page_state().
> > 
> > Similar problem can also happen when zero_user_segment() call from
> > xfs_vm_writepage() (or block_write_full_page() for that matter) set the
> > hardware dirty bit during writeback, later buffers get freed, and then page
> > unmapped.
> > 
> > Fix the issue by ignoring s390 HW dirty bit for page cache pages of mappings
> > with mapping_cap_account_dirty(). This is safe because for such mappings when a
> > page gets marked as writeable in PTE it is also marked dirty in do_wp_page() or
> > do_page_fault(). When the dirty bit is cleared by clear_page_dirty_for_io(),
> > the page gets writeprotected in page_mkclean(). So pagecache page is writeable
> > if and only if it is dirty.
> > 
> > Thanks to Hugh Dickins <hughd@google.com> for pointing out mapping has to have
> > mapping_cap_account_dirty() for things to work and proposing a cleaned up
> > variant of the patch.
> > 
> > The patch has survived about two hours of running fsx-linux on tmpfs while
> > heavily swapping and several days of running on out build machines where the
> > original problem was triggered.
> 
> That seems a fairly serious problem.  To which kernel version(s) should
> we apply the fix?

That I'll leave Jan and/or Martin to answer.

> 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> 
> It's a bit surprising that none of the added comments mention the s390
> pte-dirtying oddity.  I don't see an obvious place to mention this, but
> I for one didn't know about this and it would be good if we could
> capture the info _somewhere_?

I think it's okay: the comment you can see in Jan's patch is extending
this existing comment in page_remove_rmap(), that I added sometime in
the past (largely because "page_test_and_clear_dirty" sounds so
magisterially generic, when in actuality it's specific to s390):

	/*
	 * Now that the last pte has gone, s390 must transfer dirty
	 * flag from storage key to struct page.  We can usually skip
	 * this if the page is anon, so about to be freed; but perhaps
	 * not if it's in swapcache - there might be another pte slot
	 * containing the swap entry, but page not yet written to swap.
	 */

And one of the delights of Jan's patch is that it removes the other
callsite completely.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
