Date: Sun, 14 Oct 2007 13:23:50 -0400
Message-Id: <200710141723.l9EHNowh015023@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-reply-to: Your message of "Sun, 14 Oct 2007 20:09:34 +0300."
             <84144f020710141009xbc5bb71w64e8288f364ab491@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Hugh Dickins <hugh@veritas.com>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, Erez Zadok <ezk@cs.sunysb.edu>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In message <84144f020710141009xbc5bb71w64e8288f364ab491@mail.gmail.com>, "Pekka Enberg" writes:
> Hi Hugh,
> 
> On Sat, 13 Oct 2007, Pekka Enberg wrote:
> > Doesn't msync(2) get to it via mm/page-writeback.c:write_cache_pages()
> > without unionfs even?
> 
> On 10/14/07, Hugh Dickins <hugh@veritas.com> wrote:
> > I believe not.  Please do double-check my assertions, I've always found
> > the _writepages paths rather twisty; but my belief (supported by the
> > fact that we've not hit shmem_writepage's BUG_ON(page_mapped(page))
> > in five years) is that tmpfs/shmem opts out of all of that with its
> >         .capabilities   = BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_WRITEBACK,
> > in shmem_backing_dev_info, which avoids all those _writepages avenues
> > (e.g. through bdi_cap_writeback_dirty tests), and write_cache_pages is
> > just a subfunction of the _writepages.
> 
> Thanks for the explanation, you're obviously correct.
> 
> However, I don't think the mapping_cap_writeback_dirty() check in
> __filemap_fdatawrite_range() works as expected when tmpfs is a lower
> mount for an unionfs mount. There's no BDI_CAP_NO_WRITEBACK capability
> for unionfs mappings so do_fsync() will call write_cache_pages() that
> unconditionally invokes shmem_writepage() via unionfs_writepage().
> Unless, of course, there's some other unionfs magic I am missing.
> 
>                                    Pekka

In unionfs_writepage() I tried to emulate as best possible what the lower
f/s will have returned to the VFS.  Since tmpfs's ->writepage can return
AOP_WRITEPAGE_ACTIVATE and re-mark its page as dirty, I did the same in
unionfs: mark again my page as dirty, and return AOP_WRITEPAGE_ACTIVATE.

Should I be doing something different when unionfs stacks on top of tmpfs?
(BTW, this is probably also relevant to ecryptfs.)

Thanks,
Erez.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
