Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id B72316B0062
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 06:21:55 -0400 (EDT)
Date: Tue, 23 Oct 2012 12:21:53 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
Message-ID: <20121023102153.GD3064@quack.suse.cz>
References: <1350918406-11369-1-git-send-email-jack@suse.cz>
 <20121022123852.a4bd5f2a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121022123852.a4bd5f2a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Mon 22-10-12 12:38:52, Andrew Morton wrote:
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
  Well, XFS will crash starting from 2.6.36 kernel where the assertion was
added. Previously XFS just silently added buffers (as other filesystems do
it) and wrote / redirtied the page (unnecessarily). So looking into
maintained -stable branches I think pushing the patch to -stable from 3.0
on should be enough.

> > diff --git a/mm/rmap.c b/mm/rmap.c
> 
> It's a bit surprising that none of the added comments mention the s390
> pte-dirtying oddity.  I don't see an obvious place to mention this, but
> I for one didn't know about this and it would be good if we could
> capture the info _somewhere_?
  As Hugh says, the comment before page_test_and_clear_dirty() is somewhat
updated. But do you mean recording somewhere the catch that s390 HW dirty
bit gets set also whenever we write to a page from kernel? I guess we could
add that also to the comment before page_test_and_clear_dirty() in
page_remove_rmap() and also before definition of
page_test_and_clear_dirty(). So most people that will add / remove these
calls will be warned. OK?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
