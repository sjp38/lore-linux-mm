Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EF33B8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 16:46:33 -0400 (EDT)
Date: Mon, 14 Mar 2011 16:46:27 -0400
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: ext4 deep stack with mark_page_dirty reclaim
Message-ID: <20110314204627.GB8120@thunk.org>
References: <alpine.LSU.2.00.1103141156190.3220@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1103141156190.3220@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 14, 2011 at 12:20:52PM -0700, Hugh Dickins wrote:
> When testing something else on 2.6.38-rc8 last night,
> I hit this x86_64 stack overflow.  I've never had one before,
> it seems worth reporting.  kdb was in, I jotted it down by hand
> (the notifier part of it will be notifying kdb of the fault).
> CONFIG_DEBUG_STACK_OVERFLOW and DEBUG_STACK_USAGE were not set.
> 
> I should disclose that I have a hack in which may make my stack
> frames slightly larger than they should be: check against yours.
> So it may not be an overflow for anyone else, but still a trace
> to worry about.

Here's the trace translated to the stack space used by each function.
There are a few piggy ext4 functions that we can try to shrink, but
the real problem is just how deep the whole stack is getting.

>From the syscall to the lowest-level ext4 function is 3712 bytes, and
everything from there to the schedule() which then triggered the GPF
was another 3728 of stack space....

				- Ted

 240 schedule+0x25a
 368 io_schedule+0x35
  32 get_request_wait+0xc6
 160 __make_request+0x36d
 112 generic_make_request+0x2f2
 208 submit_bio+0xe1
 144 swap_writepage+0xa3
  80 pageout+0x151
 128 shrink_page_list+0x2db
 176 shrink_inactive_list+0x2d3
 256 shrink_zone+0x17d
 224 shrink_zones+0x0xa3
 128 do_try_to_free_pages+0x87
 144 try_to_free_mem_cgroup_pages+0x8e
 112 mem_cgroup_hierarchical_reclaim+0x220
 176 mem_cgroup_do_charge+0xdc
 128 __mem_cgroup_try_charge+0x19c
 128 mem_cgroup_charge_common+0xa8
 128 mem_cgroup_cache_charge+0x19a
 128 add_to_page_cache_locked+0x57
  96 add_to_page_cache_lru+0x3e
  80 find_or_create_page+0x69
 112 grow_dev_page+0x4a
  96 grow_buffers+0x41
  64 __getblk_slow+0xd7
  80 __getblk+0x44
  80 __ext4_get_inode_loc+0x12c
 176 ext4_get_inode_loc+0x30
  48 ext4_reserve_inode_write+0x21
  80 ext4_mark_inode_dirty+0x3b
 160 ext4_dirty_inode+0x3e
  64 __mark_inode_dirty+0x32
  80 linux/fs.h       mark_inode_dirty
   0 linux/quotaops.h dquot_alloc_space
   0 linux/quotaops.h dquot_alloc_block
   0 ext4_mb_new_blocks+0xc2
 144 ext4_alloc_blocks+0x189
 208 ext4_alloc_branch+0x73
 208 ext4_ind_map_blocks+0x148
 272 ext4_map_blocks+0x148
 112 ext4_getblk+0x5f
 144 ext4_bread+0x36
  96 ext4_append+0x52
  96 do_split+0x5b
 224 ext4_dx_add_entry+0x4b4
 304 ext4_add_entry+0x7c
 176 ext4_add_nondir+0x2e
  80 ext4_create+0xf5
 144 vfs_create+0x83
  96 __open_namei_create+0x59
  96 do_last+0x13b
 112 do_filp_open+0x2ae
 384 do_sys_open+0x72
 128 sys_open+0x27

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
