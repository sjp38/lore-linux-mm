Subject: Re: NR_UNSTABLE_FS vs. NR_FILE_DIRTY: double counting pages?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <4632A1A6.90702@google.com>
References: <4632A1A6.90702@google.com>
Content-Type: text/plain
Date: Sun, 29 Apr 2007 16:22:15 -0400
Message-Id: <1177878135.6400.37.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-04-27 at 18:21 -0700, Ethan Solomita wrote:
> There are several places where we add together NR_UNSTABLE_FS and
> NF_FILE_DIRTY:
> 
> sync_inodes_sb()
> balance_dirty_pages()
> wakeup_pdflush()
> wb_kupdate()
> prefetch_suitable()
> 
>     I can trace a standard codepath where it seems both of these are set
> on the same page:
> 
> nfs_file_aops.commit_write ->
>     nfs_commit_write
>     nfs_updatepages
>     nfs_writepage_setup
>     nfs_wb_page
>     nfs_wb_page_priority
>     nfs_writepage_locked
>     nfs_flush_mapping
>     nfs_flush_list
>     nfs_flush_multi
>     nfs_write_partial_ops.rpc_call_done
>     nfs_writeback_done_partial
>     nfs_writepage_release
>     nfs_reschedule_unstable_write
>     nfs_mark_request_commit
>     incr NR_UNSTABLE_NFS
> 
> nfs_file_aops.commit_write ->
>     nfs_commit_write
>     nfs_updatepage
>     __set_page_dirty_nobuffers
>     incr NF_FILE_DIRTY
> 
> 
>     This is the standard code path that derives from sys_write(). Can
> someone either show how this code sequence can't happen, or confirm for
> me that there's a bug?
>     -- Ethan

It should not happen. If the page is on the unstable list, then it will
be committed before nfs_updatepage is allowed to redirty it. See the
recent fixes in 2.6.21-rc7.

Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
