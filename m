Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2B08D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 15:21:01 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p2EJKx9U023275
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 12:21:00 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by kpbe19.cbf.corp.google.com with ESMTP id p2EJKf7E029563
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 12:20:58 -0700
Received: by qyk7 with SMTP id 7so1732732qyk.19
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 12:20:58 -0700 (PDT)
Date: Mon, 14 Mar 2011 12:20:52 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: ext4 deep stack with mark_page_dirty reclaim
Message-ID: <alpine.LSU.2.00.1103141156190.3220@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When testing something else on 2.6.38-rc8 last night,
I hit this x86_64 stack overflow.  I've never had one before,
it seems worth reporting.  kdb was in, I jotted it down by hand
(the notifier part of it will be notifying kdb of the fault).
CONFIG_DEBUG_STACK_OVERFLOW and DEBUG_STACK_USAGE were not set.

I should disclose that I have a hack in which may make my stack
frames slightly larger than they should be: check against yours.
So it may not be an overflow for anyone else, but still a trace
to worry about.

The faulting address has a stray 2 in it: presumably from when
the stack descended into the thread_info and got corrupted.

BUG: unable to handle kernel paging request at ffff88027a704060
IP: vprintk+0x100
Thread overran stack, or stack corrupted
ffff88007a7040a8 notifier_call_chain+0x40
ffff88007a704108 __atomic_notifier_call_chain+0x48
ffff88007a704148 __die+0x48
ffff88007a7041a8 die+0x50
ffff88007a7041e8 do_general_protection+0x168
ffff88007a704248 general_protection+0x1f
ffff88007a704338 schedule+0x25a
ffff88007a7044a8 io_schedule+0x35
ffff88007a7044c8 get_request_wait+0xc6
ffff88007a704568 __make_request+0x36d
ffff88007a7045d8 generic_make_request+0x2f2
ffff88007a7046a8 submit_bio+0xe1
ffff88007a704738 swap_writepage+0xa3
ffff88007a704788 pageout+0x151
ffff88007a704808 shrink_page_list+0x2db
ffff88007a7048b8 shrink_inactive_list+0x2d3
ffff88007a7049b8 shrink_zone+0x17d
ffff88007a704a98 shrink_zones+0x0xa3
ffff88007a704b18 do_try_to_free_pages+0x87
ffff88007a704ba8 try_to_free_mem_cgroup_pages+0x8e
ffff88007a704c18 mem_cgroup_hierarchical_reclaim+0x220
ffff88007a704cc8 mem_cgroup_do_charge+0xdc
ffff88007a704d48 __mem_cgroup_try_charge+0x19c
ffff88007a704dc8 mem_cgroup_charge_common+0xa8
ffff88007a704e48 mem_cgroup_cache_charge+0x19a
ffff88007a704ec8 add_to_page_cache_locked+0x57
ffff88007a704f28 add_to_page_cache_lru+0x3e
ffff88007a704f78 find_or_create_page+0x69
ffff88007a704fe8 grow_dev_page+0x4a
ffff88007a705048 grow_buffers+0x41
ffff88007a705088 __getblk_slow+0xd7
ffff88007a7050d8 __getblk+0x44
ffff88007a705128 __ext4_get_inode_loc+0x12c
ffff88007a7051d8 ext4_get_inode_loc+0x30
ffff88007a705208 ext4_reserve_inode_write+0x21
ffff88007a705258 ext4_mark_inode_dirty+0x3b
ffff88007a7052f8 ext4_dirty_inode+0x3e
ffff88007a705338 __mark_inode_dirty+0x32
linux/fs.h       mark_inode_dirty
linux/quotaops.h dquot_alloc_space
linux/quotaops.h dquot_alloc_block
ffff88007a705388 ext4_mb_new_blocks+0xc2
ffff88007a705418 ext4_alloc_blocks+0x189
ffff88007a7054e8 ext4_alloc_branch+0x73
ffff88007a7055b8 ext4_ind_map_blocks+0x148
ffff88007a7056c8 ext4_map_blocks+0x148
ffff88007a705738 ext4_getblk+0x5f
ffff88007a7057c8 ext4_bread+0x36
ffff88007a705828 ext4_append+0x52
ffff88007a705888 do_split+0x5b
ffff88007a705968 ext4_dx_add_entry+0x4b4
ffff88007a705a98 ext4_add_entry+0x7c
ffff88007a705b48 ext4_add_nondir+0x2e
ffff88007a705b98 ext4_create+0xf5
ffff88007a705c28 vfs_create+0x83
ffff88007a705c88 __open_namei_create+0x59
ffff88007a705ce8 do_last+0x13b
ffff88007a705d58 do_filp_open+0x2ae
ffff88007a705ed8 do_sys_open+0x72
ffff88007a705f58 sys_open+0x27

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
