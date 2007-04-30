Message-ID: <463537C2.5050804@google.com>
Date: Sun, 29 Apr 2007 17:26:42 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: NR_UNSTABLE_FS vs. NR_FILE_DIRTY: double counting pages?
References: <4632A1A6.90702@google.com> <1177878135.6400.37.camel@heimdal.trondhjem.org>
In-Reply-To: <1177878135.6400.37.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Trond Myklebust wrote:
> On Fri, 2007-04-27 at 18:21 -0700, Ethan Solomita wrote:
>> There are several places where we add together NR_UNSTABLE_FS and
>> NF_FILE_DIRTY:
>>
>> sync_inodes_sb()
>> balance_dirty_pages()
>> wakeup_pdflush()
>> wb_kupdate()
>> prefetch_suitable()
>>
>>     I can trace a standard codepath where it seems both of these are set
>> on the same page:
>>
>> nfs_file_aops.commit_write ->
>>     nfs_commit_write
>>     nfs_updatepages
>>     nfs_writepage_setup
>>     nfs_wb_page
>>     nfs_wb_page_priority
>>     nfs_writepage_locked
>>     nfs_flush_mapping
>>     nfs_flush_list
>>     nfs_flush_multi
>>     nfs_write_partial_ops.rpc_call_done
>>     nfs_writeback_done_partial
>>     nfs_writepage_release
>>     nfs_reschedule_unstable_write
>>     nfs_mark_request_commit
>>     incr NR_UNSTABLE_NFS
>>
>> nfs_file_aops.commit_write ->
>>     nfs_commit_write
>>     nfs_updatepage
>>     __set_page_dirty_nobuffers
>>     incr NF_FILE_DIRTY
>>
>>
>>     This is the standard code path that derives from sys_write(). Can
>> someone either show how this code sequence can't happen, or confirm for
>> me that there's a bug?
>>     -- Ethan
> 
> It should not happen. If the page is on the unstable list, then it will
> be committed before nfs_updatepage is allowed to redirty it. See the
> recent fixes in 2.6.21-rc7.

	Above I present a codepath called straight from sys_write() which seems 
to do what I say. I could be wrong, but can you address the code paths I 
show above which seem to set both?
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
