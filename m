Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 01E0E6B002C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:51:09 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <1304006499.2598.5.camel@mulgrave.site>
References: <1303923000.2583.8.camel@mulgrave.site>
	 <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site>
	 <1303925374-sup-7968@think> <1303926637.2583.17.camel@mulgrave.site>
	 <1303934716.2583.22.camel@mulgrave.site> <1303990590.2081.9.camel@lenovo>
	 <20110428135228.GC1696@quack.suse.cz> <20110428140725.GX4658@suse.de>
	 <1304000714.2598.0.camel@mulgrave.site>  <20110428150827.GY4658@suse.de>
	 <1304006499.2598.5.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 11:50:37 -0500
Message-ID: <1304009438.2598.9.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

This is the output of perf record -g -a -f sleep 5

(hopefully the list won't choke)

James

---

# Events: 1K cycles
#
# Overhead      Command      Shared Object                                   Symbol
# ........  ...........  .................  .......................................
#
     9.03%          tar  [kernel.kallsyms]  [k] copy_user_generic_string
                    |
                    --- copy_user_generic_string
                       |          
                       |--60.55%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --39.45%-- generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     3.45%      swapper  [kernel.kallsyms]  [k] intel_idle
                |
                --- intel_idle
                    cpuidle_idle_call
                    cpu_idle
                   |          
                   |--76.47%-- rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --23.53%-- start_secondary

     3.39%          tar  [kernel.kallsyms]  [k] zero_user_segments
                    |
                    --- zero_user_segments
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     1.78%          tar  [kernel.kallsyms]  [k] add_preempt_count
                    |
                    --- add_preempt_count
                       |          
                       |--16.72%-- __percpu_counter_add
                       |          |          
                       |          |--59.73%-- __prop_inc_single
                       |          |          task_dirty_inc
                       |          |          account_page_dirtied
                       |          |          __set_page_dirty
                       |          |          mark_buffer_dirty
                       |          |          __block_commit_write
                       |          |          block_write_end
                       |          |          generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --40.27%-- ext4_claim_free_blocks
                       |                     ext4_da_get_block_prep
                       |                     __block_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--14.83%-- _raw_spin_lock_irq
                       |          |          
                       |          |--63.66%-- add_to_page_cache_locked
                       |          |          add_to_page_cache_lru
                       |          |          |          
                       |          |          |--51.51%-- mpage_readpages
                       |          |          |          ext4_readpages
                       |          |          |          __do_page_cache_readahead
                       |          |          |          ra_submit
                       |          |          |          ondemand_readahead
                       |          |          |          page_cache_async_readahead
                       |          |          |          generic_file_aio_read
                       |          |          |          do_sync_read
                       |          |          |          vfs_read
                       |          |          |          sys_read
                       |          |          |          system_call_fastpath
                       |          |          |          __GI___libc_read
                       |          |          |          
                       |          |           --48.49%-- grab_cache_page_write_begin
                       |          |                     ext4_da_write_begin
                       |          |                     generic_file_buffered_write
                       |          |                     __generic_file_aio_write
                       |          |                     generic_file_aio_write
                       |          |                     ext4_file_write
                       |          |                     do_sync_write
                       |          |                     vfs_write
                       |          |                     sys_write
                       |          |                     system_call_fastpath
                       |          |                     __GI___libc_write
                       |          |          
                       |           --36.34%-- blk_throtl_bio
                       |                     generic_make_request
                       |                     submit_bio
                       |                     mpage_readpages
                       |                     ext4_readpages
                       |                     __do_page_cache_readahead
                       |                     ra_submit
                       |                     ondemand_readahead
                       |                     page_cache_async_readahead
                       |                     generic_file_aio_read
                       |                     do_sync_read
                       |                     vfs_read
                       |                     sys_read
                       |                     system_call_fastpath
                       |                     __GI___libc_read
                       |          
                       |--13.85%-- bit_spin_lock
                       |          jbd2_journal_add_journal_head
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--12.19%-- __lru_cache_add
                       |          add_to_page_cache_lru
                       |          |          
                       |          |--70.86%-- grab_cache_page_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --29.14%-- mpage_readpages
                       |                     ext4_readpages
                       |                     __do_page_cache_readahead
                       |                     ra_submit
                       |                     ondemand_readahead
                       |                     page_cache_async_readahead
                       |                     generic_file_aio_read
                       |                     do_sync_read
                       |                     vfs_read
                       |                     sys_read
                       |                     system_call_fastpath
                       |                     __GI___libc_read
                       |          
                       |--8.30%-- bit_spin_lock
                       |          lock_page_cgroup
                       |          __mem_cgroup_commit_charge.constprop.28
                       |          __mem_cgroup_commit_charge_lrucare
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          |          
                       |          |--58.88%-- mpage_readpages
                       |          |          ext4_readpages
                       |          |          __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --41.12%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--7.17%-- generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--4.90%-- __srcu_read_lock
                       |          fsnotify
                       |          fsnotify_modify
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--4.61%-- __srcu_read_unlock
                       |          fsnotify
                       |          fsnotify_modify
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--4.14%-- _raw_read_lock_irqsave
                       |          dm_get_live_table
                       |          dm_merge_bvec
                       |          __bio_add_page.part.2
                       |          bio_add_page
                       |          do_mpage_readpage
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--3.81%-- _raw_read_lock
                       |          start_this_handle
                       |          jbd2__journal_start
                       |          jbd2_journal_start
                       |          ext4_journal_start_sb
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--3.77%-- balance_dirty_pages_ratelimited_nr
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--3.55%-- __add_bdi_stat
                       |          account_page_dirtied
                       |          __set_page_dirty
                       |          mark_buffer_dirty
                       |          __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --2.18%-- _raw_spin_lock
                                  ext4_da_get_block_prep
                                  __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     1.70%          tar  [kernel.kallsyms]  [k] __list_del_entry
                    |
                    --- __list_del_entry
                       |          
                       |--72.43%-- list_del
                       |          |          
                       |          |--76.01%-- __rmqueue
                       |          |          get_page_from_freelist
                       |          |          __alloc_pages_nodemask
                       |          |          alloc_pages_current
                       |          |          |          
                       |          |          |--92.23%-- __page_cache_alloc
                       |          |          |          |          
                       |          |          |          |--60.54%-- __do_page_cache_readahead
                       |          |          |          |          ra_submit
                       |          |          |          |          ondemand_readahead
                       |          |          |          |          page_cache_async_readahead
                       |          |          |          |          generic_file_aio_read
                       |          |          |          |          do_sync_read
                       |          |          |          |          vfs_read
                       |          |          |          |          sys_read
                       |          |          |          |          system_call_fastpath
                       |          |          |          |          __GI___libc_read
                       |          |          |          |          
                       |          |          |           --39.46%-- grab_cache_page_write_begin
                       |          |          |                     ext4_da_write_begin
                       |          |          |                     generic_file_buffered_write
                       |          |          |                     __generic_file_aio_write
                       |          |          |                     generic_file_aio_write
                       |          |          |                     ext4_file_write
                       |          |          |                     do_sync_write
                       |          |          |                     vfs_write
                       |          |          |                     sys_write
                       |          |          |                     system_call_fastpath
                       |          |          |                     __GI___libc_write
                       |          |          |          
                       |          |           --7.77%-- alloc_slab_page
                       |          |                     new_slab
                       |          |                     __slab_alloc
                       |          |                     kmem_cache_alloc
                       |          |                     alloc_buffer_head
                       |          |                     alloc_page_buffers
                       |          |                     create_empty_buffers
                       |          |                     __block_write_begin
                       |          |                     ext4_da_write_begin
                       |          |                     generic_file_buffered_write
                       |          |                     __generic_file_aio_write
                       |          |                     generic_file_aio_write
                       |          |                     ext4_file_write
                       |          |                     do_sync_write
                       |          |                     vfs_write
                       |          |                     sys_write
                       |          |                     system_call_fastpath
                       |          |                     __GI___libc_write
                       |          |          
                       |          |--18.55%-- get_page_from_freelist
                       |          |          __alloc_pages_nodemask
                       |          |          alloc_pages_current
                       |          |          __page_cache_alloc
                       |          |          |          
                       |          |          |--60.32%-- __do_page_cache_readahead
                       |          |          |          ra_submit
                       |          |          |          ondemand_readahead
                       |          |          |          page_cache_async_readahead
                       |          |          |          generic_file_aio_read
                       |          |          |          do_sync_read
                       |          |          |          vfs_read
                       |          |          |          sys_read
                       |          |          |          system_call_fastpath
                       |          |          |          __GI___libc_read
                       |          |          |          
                       |          |           --39.68%-- grab_cache_page_write_begin
                       |          |                     ext4_da_write_begin
                       |          |                     generic_file_buffered_write
                       |          |                     __generic_file_aio_write
                       |          |                     generic_file_aio_write
                       |          |                     ext4_file_write
                       |          |                     do_sync_write
                       |          |                     vfs_write
                       |          |                     sys_write
                       |          |                     system_call_fastpath
                       |          |                     __GI___libc_write
                       |          |          
                       |           --5.44%-- activate_page
                       |                     mark_page_accessed
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--17.37%-- __rmqueue
                       |          get_page_from_freelist
                       |          __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          |          
                       |          |--63.38%-- __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --36.62%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --10.20%-- get_page_from_freelist
                                  __alloc_pages_nodemask
                                  alloc_pages_current
                                  __page_cache_alloc
                                  |          
                                  |--65.70%-- __do_page_cache_readahead
                                  |          ra_submit
                                  |          ondemand_readahead
                                  |          page_cache_async_readahead
                                  |          generic_file_aio_read
                                  |          do_sync_read
                                  |          vfs_read
                                  |          sys_read
                                  |          system_call_fastpath
                                  |          __GI___libc_read
                                  |          
                                   --34.30%-- grab_cache_page_write_begin
                                             ext4_da_write_begin
                                             generic_file_buffered_write
                                             __generic_file_aio_write
                                             generic_file_aio_write
                                             ext4_file_write
                                             do_sync_write
                                             vfs_write
                                             sys_write
                                             system_call_fastpath
                                             __GI___libc_write

     1.53%          tar  tar                [.] 0x75ff          
                    |
                    --- 0x407546

                    |
                    --- 0x42a9c2

                    |
                    --- 0x40753f

                    |
                    --- 0x40e790

                    |
                    --- 0x407586

                    |
                    --- 0x40fe1a

                    |
                    --- 0x424b50

                    |
                    --- 0x412972

                    |
                    --- 0x407501

                    |
                    --- 0x433336

                    |
                    --- 0x4075ff

                    |
                    --- 0x403b40

                    |
                    --- 0x4055c7

                    |
                    --- 0x4332d9

                    |
                    --- 0x405efa

                    |
                    --- 0x42a9fe

                    |
                    --- 0x405a43

                    |
                    --- 0x4332d6

     1.44%          tar  [kernel.kallsyms]  [k] __ext4_get_inode_loc
                    |
                    --- __ext4_get_inode_loc
                        ext4_get_inode_loc
                       |          
                       |--62.07%-- ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          |          
                       |          |--94.67%-- generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --5.33%-- file_update_time
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --37.93%-- ext4_xattr_get
                                  ext4_xattr_security_get
                                  generic_getxattr
                                  cap_inode_need_killpriv
                                  security_inode_need_killpriv
                                  file_remove_suid
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     1.43%          tar  [kernel.kallsyms]  [k] kmem_cache_alloc
                    |
                    --- kmem_cache_alloc
                       |          
                       |--66.77%-- alloc_buffer_head
                       |          alloc_page_buffers
                       |          create_empty_buffers
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--22.22%-- jbd2__journal_start
                       |          jbd2_journal_start
                       |          ext4_journal_start_sb
                       |          |          
                       |          |--65.27%-- ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --34.73%-- ext4_dirty_inode
                       |                     __mark_inode_dirty
                       |                     file_update_time
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--6.29%-- radix_tree_preload
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --4.72%-- scsi_pool_alloc_command
                                  scsi_host_alloc_command
                                  __scsi_get_command
                                  scsi_get_command
                                  scsi_get_cmd_from_req
                                  scsi_setup_fs_cmnd
                                  sd_prep_fn
                                  blk_peek_request
                                  scsi_request_fn
                                  __blk_run_queue
                                  queue_unplugged
                                  blk_flush_plug_list
                                  io_schedule
                                  sleep_on_page_killable
                                  __wait_on_bit_lock
                                  __lock_page_killable
                                  lock_page_killable
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     1.25%          tar  [kernel.kallsyms]  [k] sub_preempt_count
                    |
                    --- sub_preempt_count
                       |          
                       |--24.47%-- _raw_spin_unlock_irqrestore
                       |          |          
                       |          |--30.14%-- scsi_get_command
                       |          |          scsi_get_cmd_from_req
                       |          |          scsi_setup_fs_cmnd
                       |          |          sd_prep_fn
                       |          |          blk_peek_request
                       |          |          scsi_request_fn
                       |          |          __blk_run_queue
                       |          |          queue_unplugged
                       |          |          blk_flush_plug_list
                       |          |          io_schedule
                       |          |          sleep_on_page_killable
                       |          |          __wait_on_bit_lock
                       |          |          __lock_page_killable
                       |          |          lock_page_killable
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |          |--28.74%-- prepare_to_wait_exclusive
                       |          |          __wait_on_bit_lock
                       |          |          __lock_page_killable
                       |          |          lock_page_killable
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |          |--23.48%-- __wake_up
                       |          |          jbd2_journal_stop
                       |          |          __ext4_journal_stop
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --17.65%-- blkiocg_update_dispatch_stats
                       |                     throtl_charge_bio
                       |                     blk_throtl_bio
                       |                     generic_make_request
                       |                     submit_bio
                       |                     mpage_readpages
                       |                     ext4_readpages
                       |                     __do_page_cache_readahead
                       |                     ra_submit
                       |                     ondemand_readahead
                       |                     page_cache_async_readahead
                       |                     generic_file_aio_read
                       |                     do_sync_read
                       |                     vfs_read
                       |                     sys_read
                       |                     system_call_fastpath
                       |                     __GI___libc_read
                       |          
                       |--12.68%-- radix_tree_preload_end
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--12.51%-- pagefault_enable
                       |          iov_iter_copy_from_user_atomic
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--10.90%-- _raw_spin_unlock_irq
                       |          |          
                       |          |--52.31%-- add_to_page_cache_locked
                       |          |          add_to_page_cache_lru
                       |          |          mpage_readpages
                       |          |          ext4_readpages
                       |          |          __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --47.69%-- __set_page_dirty
                       |                     mark_buffer_dirty
                       |                     __block_commit_write
                       |                     block_write_end
                       |                     generic_write_end
                       |                     ext4_da_write_end
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--10.37%-- mem_cgroup_charge_statistics
                       |          __mem_cgroup_commit_charge.constprop.28
                       |          __mem_cgroup_commit_charge_lrucare
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--9.99%-- _raw_spin_unlock
                       |          |          
                       |          |--60.73%-- inode_add_rsv_space
                       |          |          __dquot_alloc_space
                       |          |          ext4_da_get_block_prep
                       |          |          __block_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --39.27%-- ext4_ext_map_blocks
                       |                     ext4_map_blocks
                       |                     ext4_da_get_block_prep
                       |                     __block_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--5.89%-- __wake_up
                       |          jbd2_journal_stop
                       |          __ext4_journal_stop
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--4.86%-- balance_dirty_pages_ratelimited_nr
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--4.52%-- add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --3.81%-- avc_has_perm_noaudit
                                  task_has_capability
                                  selinux_capable
                                  security_capable
                                  ns_capable
                                  generic_permission
                                  inode_permission
                                  may_create
                                  vfs_create
                                  do_last
                                  path_openat
                                  do_filp_open
                                  do_sys_open
                                  sys_openat
                                  system_call_fastpath
                                  __GI___openat

     1.24%          tar  [kernel.kallsyms]  [k] bit_spin_lock
                    |
                    --- bit_spin_lock
                       |          
                       |--94.43%-- lock_page_cgroup
                       |          __mem_cgroup_commit_charge.constprop.28
                       |          __mem_cgroup_commit_charge_lrucare
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          |          
                       |          |--56.27%-- mpage_readpages
                       |          |          ext4_readpages
                       |          |          __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --43.73%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --5.57%-- __mem_cgroup_commit_charge.constprop.28
                                  __mem_cgroup_commit_charge_lrucare
                                  mem_cgroup_cache_charge
                                  add_to_page_cache_locked
                                  add_to_page_cache_lru
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     1.13%      swapper  [kernel.kallsyms]  [k] poll_idle
                |
                --- poll_idle
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     1.00%          tar  [kernel.kallsyms]  [k] ext4_da_get_block_prep
                    |
                    --- ext4_da_get_block_prep
                       |          
                       |--82.10%-- __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --17.90%-- ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.95%          tar  [kernel.kallsyms]  [k] __find_get_block
                    |
                    --- __find_get_block
                       |          
                       |--85.78%-- __getblk
                       |          __ext4_get_inode_loc
                       |          ext4_get_inode_loc
                       |          |          
                       |          |--84.94%-- ext4_reserve_inode_write
                       |          |          ext4_mark_inode_dirty
                       |          |          ext4_dirty_inode
                       |          |          __mark_inode_dirty
                       |          |          generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --15.06%-- ext4_xattr_get
                       |                     ext4_xattr_security_get
                       |                     generic_getxattr
                       |                     cap_inode_need_killpriv
                       |                     security_inode_need_killpriv
                       |                     file_remove_suid
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--7.86%-- ext4_ext_truncate
                       |          ext4_truncate
                       |          ext4_evict_inode
                       |          evict
                       |          iput
                       |          do_unlinkat
                       |          sys_unlinkat
                       |          system_call_fastpath
                       |          unlinkat
                       |          
                        --6.36%-- ext4_free_blocks
                                  ext4_ext_truncate
                                  ext4_truncate
                                  ext4_evict_inode
                                  evict
                                  iput
                                  do_unlinkat
                                  sys_unlinkat
                                  system_call_fastpath
                                  unlinkat

     0.92%          tar  [kernel.kallsyms]  [k] radix_tree_lookup_element
                    |
                    --- radix_tree_lookup_element
                       |          
                       |--79.19%-- radix_tree_lookup_slot
                       |          find_get_page
                       |          |          
                       |          |--39.67%-- __find_get_block_slow
                       |          |          unmap_underlying_metadata
                       |          |          __block_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |          |--37.78%-- generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --22.55%-- find_lock_page
                       |                     grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--13.79%-- radix_tree_lookup
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --7.02%-- __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.86%          tar  [kernel.kallsyms]  [k] ext4_mark_iloc_dirty
                    |
                    --- ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.84%          tar  [kernel.kallsyms]  [k] __alloc_pages_nodemask
                    |
                    --- __alloc_pages_nodemask
                       |          
                       |--88.77%-- alloc_pages_current
                       |          __page_cache_alloc
                       |          |          
                       |          |--53.12%-- __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --46.88%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --11.23%-- __page_cache_alloc
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.80%          tar  [kernel.kallsyms]  [k] get_parent_ip
                    |
                    --- get_parent_ip
                       |          
                       |--27.09%-- add_preempt_count
                       |          |          
                       |          |--44.58%-- jbd_lock_bh_state
                       |          |          do_get_write_access
                       |          |          jbd2_journal_get_write_access
                       |          |          __ext4_journal_get_write_access
                       |          |          ext4_reserve_inode_write
                       |          |          ext4_mark_inode_dirty
                       |          |          ext4_dirty_inode
                       |          |          __mark_inode_dirty
                       |          |          generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |          |--32.43%-- bit_spin_lock
                       |          |          lock_page_cgroup
                       |          |          __mem_cgroup_commit_charge.constprop.28
                       |          |          __mem_cgroup_commit_charge_lrucare
                       |          |          mem_cgroup_cache_charge
                       |          |          add_to_page_cache_locked
                       |          |          add_to_page_cache_lru
                       |          |          grab_cache_page_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --22.99%-- _raw_spin_lock_irqsave
                       |                     __wake_up
                       |                     jbd2_journal_stop
                       |                     __ext4_journal_stop
                       |                     ext4_da_write_end
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--26.54%-- sub_preempt_count
                       |          |          
                       |          |--43.60%-- __percpu_counter_add
                       |          |          ext4_claim_free_blocks
                       |          |          ext4_da_get_block_prep
                       |          |          __block_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |          |--29.86%-- bit_spin_unlock
                       |          |          unlock_page_cgroup
                       |          |          __mem_cgroup_commit_charge.constprop.28
                       |          |          __mem_cgroup_commit_charge_lrucare
                       |          |          mem_cgroup_cache_charge
                       |          |          add_to_page_cache_locked
                       |          |          add_to_page_cache_lru
                       |          |          mpage_readpages
                       |          |          ext4_readpages
                       |          |          __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --26.53%-- __lru_cache_add
                       |                     add_to_page_cache_lru
                       |                     mpage_readpages
                       |                     ext4_readpages
                       |                     __do_page_cache_readahead
                       |                     ra_submit
                       |                     ondemand_readahead
                       |                     page_cache_async_readahead
                       |                     generic_file_aio_read
                       |                     do_sync_read
                       |                     vfs_read
                       |                     sys_read
                       |                     system_call_fastpath
                       |                     __GI___libc_read
                       |          
                       |--13.83%-- radix_tree_preload
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--9.64%-- jbd_lock_bh_state
                       |          jbd2_journal_dirty_metadata
                       |          __ext4_handle_dirty_metadata
                       |          ext4_mark_iloc_dirty
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--8.02%-- bit_spin_unlock
                       |          jbd2_journal_add_journal_head
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--7.60%-- _raw_spin_lock
                       |          inode_add_rsv_space
                       |          __dquot_alloc_space
                       |          ext4_da_get_block_prep
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --7.27%-- balance_dirty_pages_ratelimited_nr
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.74%          tar  [kernel.kallsyms]  [k] do_raw_spin_lock
                    |
                    --- do_raw_spin_lock
                       |          
                       |--55.40%-- _raw_spin_lock_irq
                       |          |          
                       |          |--86.22%-- __set_page_dirty
                       |          |          mark_buffer_dirty
                       |          |          __block_commit_write
                       |          |          block_write_end
                       |          |          generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --13.78%-- blk_throtl_bio
                       |                     generic_make_request
                       |                     submit_bio
                       |                     mpage_readpages
                       |                     ext4_readpages
                       |                     __do_page_cache_readahead
                       |                     ra_submit
                       |                     ondemand_readahead
                       |                     page_cache_async_readahead
                       |                     generic_file_aio_read
                       |                     do_sync_read
                       |                     vfs_read
                       |                     sys_read
                       |                     system_call_fastpath
                       |                     __GI___libc_read
                       |          
                        --44.60%-- _raw_spin_lock
                                  |          
                                  |--76.80%-- inode_add_rsv_space
                                  |          __dquot_alloc_space
                                  |          ext4_da_get_block_prep
                                  |          __block_write_begin
                                  |          ext4_da_write_begin
                                  |          generic_file_buffered_write
                                  |          __generic_file_aio_write
                                  |          generic_file_aio_write
                                  |          ext4_file_write
                                  |          do_sync_write
                                  |          vfs_write
                                  |          sys_write
                                  |          system_call_fastpath
                                  |          __GI___libc_write
                                  |          
                                   --23.20%-- ext4_da_get_block_prep
                                             __block_write_begin
                                             ext4_da_write_begin
                                             generic_file_buffered_write
                                             __generic_file_aio_write
                                             generic_file_aio_write
                                             ext4_file_write
                                             do_sync_write
                                             vfs_write
                                             sys_write
                                             system_call_fastpath
                                             __GI___libc_write

     0.71%          tar  [kernel.kallsyms]  [k] put_page_testzero
                    |
                    --- put_page_testzero
                        put_page
                       |          
                       |--49.42%-- generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--26.92%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --23.66%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.69%          tar  [kernel.kallsyms]  [k] get_page_from_freelist
                    |
                    --- get_page_from_freelist
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                       |          
                       |--63.44%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --36.56%-- __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.67%          tar  [kernel.kallsyms]  [k] __wake_up_bit
                    |
                    --- __wake_up_bit
                       |          
                       |--90.71%-- unlock_page
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --9.29%-- wake_up_bit
                                  unlock_buffer
                                  do_get_write_access
                                  jbd2_journal_get_write_access
                                  __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.65%          tar  [kernel.kallsyms]  [k] put_mems_allowed
                    |
                    --- put_mems_allowed
                       |          
                       |--92.20%-- alloc_pages_current
                       |          __page_cache_alloc
                       |          |          
                       |          |--54.97%-- __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --45.03%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --7.80%-- __page_cache_alloc
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.65%          tar  [kernel.kallsyms]  [k] __rmqueue
                    |
                    --- __rmqueue
                        get_page_from_freelist
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                       |          
                       |--70.26%-- __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --29.74%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.62%          tar  [kernel.kallsyms]  [k] start_this_handle
                    |
                    --- start_this_handle
                        jbd2__journal_start
                        jbd2_journal_start
                        ext4_journal_start_sb
                       |          
                       |--71.12%-- ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --28.88%-- ext4_dirty_inode
                                  __mark_inode_dirty
                                  file_update_time
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.58%          tar  [kernel.kallsyms]  [k] __rcu_read_unlock
                    |
                    --- __rcu_read_unlock
                       |          
                       |--35.45%-- __prop_inc_single
                       |          task_dirty_inc
                       |          account_page_dirtied
                       |          __set_page_dirty
                       |          mark_buffer_dirty
                       |          __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--14.77%-- find_get_page
                       |          find_lock_page
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--11.81%-- __find_get_block_slow
                       |          __find_get_block
                       |          ext4_free_blocks
                       |          ext4_ext_truncate
                       |          ext4_truncate
                       |          ext4_evict_inode
                       |          evict
                       |          iput
                       |          do_unlinkat
                       |          sys_unlinkat
                       |          system_call_fastpath
                       |          unlinkat
                       |          
                       |--11.28%-- avc_has_perm_noaudit
                       |          avc_has_perm
                       |          inode_has_perm
                       |          selinux_inode_permission
                       |          security_inode_permission
                       |          inode_permission
                       |          may_delete
                       |          vfs_unlink
                       |          do_unlinkat
                       |          sys_unlinkat
                       |          system_call_fastpath
                       |          unlinkat
                       |          
                       |--10.21%-- __mem_cgroup_try_charge.constprop.27
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--8.34%-- generic_make_request
                       |          submit_bio
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --8.15%-- dm_request
                                  generic_make_request
                                  submit_bio
                                  mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.58%          tar  [kernel.kallsyms]  [k] __mark_inode_dirty
                    |
                    --- __mark_inode_dirty
                       |          
                       |--54.06%-- __set_page_dirty
                       |          mark_buffer_dirty
                       |          __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--33.43%-- generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --12.51%-- ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.55%          tar  [kernel.kallsyms]  [k] _raw_spin_unlock
                    |
                    --- _raw_spin_unlock
                       |          
                       |--55.58%-- ext4_da_get_block_prep
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --44.42%-- create_empty_buffers
                                  __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.53%          tar  [kernel.kallsyms]  [k] next_zones_zonelist
                    |
                    --- next_zones_zonelist
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                       |          
                       |--55.47%-- __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --44.53%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.52%          tar  [kernel.kallsyms]  [k] bit_spin_unlock
                    |
                    --- bit_spin_unlock
                       |          
                       |--55.87%-- jbd2_journal_put_journal_head
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          |          
                       |          |--71.83%-- ext4_dirty_inode
                       |          |          __mark_inode_dirty
                       |          |          |          
                       |          |          |--57.59%-- generic_write_end
                       |          |          |          ext4_da_write_end
                       |          |          |          generic_file_buffered_write
                       |          |          |          __generic_file_aio_write
                       |          |          |          generic_file_aio_write
                       |          |          |          ext4_file_write
                       |          |          |          do_sync_write
                       |          |          |          vfs_write
                       |          |          |          sys_write
                       |          |          |          system_call_fastpath
                       |          |          |          __GI___libc_write
                       |          |          |          
                       |          |           --42.41%-- file_update_time
                       |          |                     __generic_file_aio_write
                       |          |                     generic_file_aio_write
                       |          |                     ext4_file_write
                       |          |                     do_sync_write
                       |          |                     vfs_write
                       |          |                     sys_write
                       |          |                     system_call_fastpath
                       |          |                     __GI___libc_write
                       |          |          
                       |           --28.17%-- add_dirent_to_buf
                       |                     ext4_add_entry
                       |                     ext4_add_nondir
                       |                     ext4_create
                       |                     vfs_create
                       |                     do_last
                       |                     path_openat
                       |                     do_filp_open
                       |                     do_sys_open
                       |                     sys_openat
                       |                     system_call_fastpath
                       |                     __GI___openat
                       |          
                        --44.13%-- jbd2_journal_add_journal_head
                                  jbd2_journal_get_write_access
                                  __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.51%          tar  [kernel.kallsyms]  [k] jbd_unlock_bh_state
                    |
                    --- jbd_unlock_bh_state
                       |          
                       |--56.56%-- do_get_write_access
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          |          
                       |          |--85.42%-- ext4_reserve_inode_write
                       |          |          ext4_mark_inode_dirty
                       |          |          ext4_dirty_inode
                       |          |          __mark_inode_dirty
                       |          |          |          
                       |          |          |--77.84%-- generic_write_end
                       |          |          |          ext4_da_write_end
                       |          |          |          generic_file_buffered_write
                       |          |          |          __generic_file_aio_write
                       |          |          |          generic_file_aio_write
                       |          |          |          ext4_file_write
                       |          |          |          do_sync_write
                       |          |          |          vfs_write
                       |          |          |          sys_write
                       |          |          |          system_call_fastpath
                       |          |          |          __GI___libc_write
                       |          |          |          
                       |          |           --22.16%-- file_update_time
                       |          |                     __generic_file_aio_write
                       |          |                     generic_file_aio_write
                       |          |                     ext4_file_write
                       |          |                     do_sync_write
                       |          |                     vfs_write
                       |          |                     sys_write
                       |          |                     system_call_fastpath
                       |          |                     __GI___libc_write
                       |          |          
                       |           --14.58%-- ext4_free_inode
                       |                     ext4_evict_inode
                       |                     evict
                       |                     iput
                       |                     do_unlinkat
                       |                     sys_unlinkat
                       |                     system_call_fastpath
                       |                     unlinkat
                       |          
                        --43.44%-- jbd2_journal_dirty_metadata
                                  __ext4_handle_dirty_metadata
                                  |          
                                  |--53.02%-- ext4_free_inode
                                  |          ext4_evict_inode
                                  |          evict
                                  |          iput
                                  |          do_unlinkat
                                  |          sys_unlinkat
                                  |          system_call_fastpath
                                  |          unlinkat
                                  |          
                                   --46.98%-- ext4_mark_iloc_dirty
                                             ext4_mark_inode_dirty
                                             ext4_dirty_inode
                                             __mark_inode_dirty
                                             generic_write_end
                                             ext4_da_write_end
                                             generic_file_buffered_write
                                             __generic_file_aio_write
                                             generic_file_aio_write
                                             ext4_file_write
                                             do_sync_write
                                             vfs_write
                                             sys_write
                                             system_call_fastpath
                                             __GI___libc_write

     0.50%          tar  [kernel.kallsyms]  [k] __block_write_begin
                    |
                    --- __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.49%          tar  [kernel.kallsyms]  [k] __might_sleep
                    |
                    --- __might_sleep
                       |          
                       |--30.54%-- jbd2__journal_start
                       |          jbd2_journal_start
                       |          ext4_journal_start_sb
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--17.09%-- __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--14.20%-- __getblk
                       |          __ext4_get_inode_loc
                       |          ext4_get_inode_loc
                       |          ext4_xattr_get
                       |          ext4_xattr_security_get
                       |          generic_getxattr
                       |          cap_inode_need_killpriv
                       |          security_inode_need_killpriv
                       |          file_remove_suid
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--10.60%-- mutex_lock
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--10.58%-- kmem_cache_alloc
                       |          jbd2__journal_start
                       |          jbd2_journal_start
                       |          ext4_journal_start_sb
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--9.67%-- lock_buffer
                       |          do_get_write_access
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --7.31%-- ext4_map_blocks
                                  ext4_getblk
                                  ext4_bread
                                  dx_probe
                                  ext4_add_entry
                                  ext4_add_nondir
                                  ext4_create
                                  vfs_create
                                  do_last
                                  path_openat
                                  do_filp_open
                                  do_sys_open
                                  sys_openat
                                  system_call_fastpath
                                  __GI___openat

     0.49%          tar  [kernel.kallsyms]  [k] jbd2_journal_add_journal_head
                    |
                    --- jbd2_journal_add_journal_head
                       |          
                       |--69.06%-- __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          |          
                       |          |--77.62%-- generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --22.38%-- file_update_time
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --30.94%-- jbd2_journal_get_write_access
                                  __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.48%          tar  [kernel.kallsyms]  [k] __mem_cgroup_commit_charge.constprop.28
                    |
                    --- __mem_cgroup_commit_charge.constprop.28
                       |          
                       |--83.14%-- __mem_cgroup_commit_charge_lrucare
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          |          
                       |          |--56.52%-- mpage_readpages
                       |          |          ext4_readpages
                       |          |          __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --43.48%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --16.86%-- mem_cgroup_cache_charge
                                  add_to_page_cache_locked
                                  add_to_page_cache_lru
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.46%          tar  [kernel.kallsyms]  [k] __rcu_read_lock
                    |
                    --- __rcu_read_lock
                       |          
                       |--30.47%-- avc_has_perm_noaudit
                       |          |          
                       |          |--54.86%-- task_has_capability
                       |          |          selinux_capable
                       |          |          security_capable
                       |          |          ns_capable
                       |          |          exec_permission
                       |          |          link_path_walk
                       |          |          path_lookupat
                       |          |          do_path_lookup
                       |          |          user_path_parent
                       |          |          do_unlinkat
                       |          |          sys_unlinkat
                       |          |          system_call_fastpath
                       |          |          unlinkat
                       |          |          
                       |           --45.14%-- avc_has_perm
                       |                     may_create
                       |                     selinux_inode_create
                       |                     security_inode_create
                       |                     vfs_create
                       |                     do_last
                       |                     path_openat
                       |                     do_filp_open
                       |                     do_sys_open
                       |                     sys_openat
                       |                     system_call_fastpath
                       |                     __GI___openat
                       |          
                       |--20.91%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--18.25%-- find_get_page
                       |          find_lock_page
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--17.06%-- __account_system_time
                       |          irqtime_account_process_tick
                       |          account_process_tick
                       |          update_process_times
                       |          tick_sched_timer
                       |          __run_hrtimer
                       |          hrtimer_interrupt
                       |          smp_apic_timer_interrupt
                       |          apic_timer_interrupt
                       |          rw_verify_area
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --13.31%-- __prop_inc_single
                                  task_dirty_inc
                                  account_page_dirtied
                                  __set_page_dirty
                                  mark_buffer_dirty
                                  __block_commit_write
                                  block_write_end
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.44%          tar  [kernel.kallsyms]  [k] jbd2_journal_cancel_revoke
                    |
                    --- jbd2_journal_cancel_revoke
                        do_get_write_access
                        jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.44%          tar  [kernel.kallsyms]  [k] mark_page_accessed
                    |
                    --- mark_page_accessed
                       |          
                       |--56.95%-- generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--15.53%-- do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--14.54%-- __find_get_block
                       |          __getblk
                       |          __ext4_get_inode_loc
                       |          ext4_get_inode_loc
                       |          ext4_xattr_get
                       |          ext4_xattr_security_get
                       |          generic_getxattr
                       |          cap_inode_need_killpriv
                       |          security_inode_need_killpriv
                       |          file_remove_suid
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --12.98%-- generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.44%          tar  [kernel.kallsyms]  [k] put_mems_allowed
                    |
                    --- put_mems_allowed
                       |          
                       |--55.41%-- alloc_pages_current
                       |          __page_cache_alloc
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --44.59%-- __alloc_pages_nodemask
                                  alloc_pages_current
                                  __page_cache_alloc
                                  |          
                                  |--68.42%-- grab_cache_page_write_begin
                                  |          ext4_da_write_begin
                                  |          generic_file_buffered_write
                                  |          __generic_file_aio_write
                                  |          generic_file_aio_write
                                  |          ext4_file_write
                                  |          do_sync_write
                                  |          vfs_write
                                  |          sys_write
                                  |          system_call_fastpath
                                  |          __GI___libc_write
                                  |          
                                   --31.58%-- __do_page_cache_readahead
                                             ra_submit
                                             ondemand_readahead
                                             page_cache_async_readahead
                                             generic_file_aio_read
                                             do_sync_read
                                             vfs_read
                                             sys_read
                                             system_call_fastpath
                                             __GI___libc_read

     0.43%          tar  [kernel.kallsyms]  [k] in_lock_functions
                    |
                    --- in_lock_functions
                       |          
                       |--76.43%-- get_parent_ip
                       |          |          
                       |          |--80.00%-- add_preempt_count
                       |          |          |          
                       |          |          |--39.87%-- balance_dirty_pages_ratelimited_nr
                       |          |          |          generic_file_buffered_write
                       |          |          |          __generic_file_aio_write
                       |          |          |          generic_file_aio_write
                       |          |          |          ext4_file_write
                       |          |          |          do_sync_write
                       |          |          |          vfs_write
                       |          |          |          sys_write
                       |          |          |          system_call_fastpath
                       |          |          |          __GI___libc_write
                       |          |          |          
                       |          |          |--30.07%-- radix_tree_preload
                       |          |          |          add_to_page_cache_locked
                       |          |          |          add_to_page_cache_lru
                       |          |          |          grab_cache_page_write_begin
                       |          |          |          ext4_da_write_begin
                       |          |          |          generic_file_buffered_write
                       |          |          |          __generic_file_aio_write
                       |          |          |          generic_file_aio_write
                       |          |          |          ext4_file_write
                       |          |          |          do_sync_write
                       |          |          |          vfs_write
                       |          |          |          sys_write
                       |          |          |          system_call_fastpath
                       |          |          |          __GI___libc_write
                       |          |          |          
                       |          |           --30.07%-- _raw_read_lock
                       |          |                     start_this_handle
                       |          |                     jbd2__journal_start
                       |          |                     jbd2_journal_start
                       |          |                     ext4_journal_start_sb
                       |          |                     ext4_dirty_inode
                       |          |                     __mark_inode_dirty
                       |          |                     ext4_setattr
                       |          |                     notify_change
                       |          |                     chown_common
                       |          |                     sys_fchown
                       |          |                     system_call_fastpath
                       |          |                     __GI___fchown
                       |          |          
                       |           --20.00%-- sub_preempt_count
                       |                     avc_has_perm_noaudit
                       |                     avc_has_perm
                       |                     inode_has_perm
                       |                     dentry_has_perm
                       |                     selinux_inode_setattr
                       |                     security_inode_setattr
                       |                     notify_change
                       |                     chown_common
                       |                     sys_fchown
                       |                     system_call_fastpath
                       |                     __GI___fchown
                       |          
                       |--12.38%-- add_preempt_count
                       |          jbd_lock_bh_state
                       |          do_get_write_access
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --11.19%-- sub_preempt_count
                                  _raw_spin_unlock_irqrestore
                                  __wake_up
                                  jbd2_journal_stop
                                  __ext4_journal_stop
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.43%      swapper  [kernel.kallsyms]  [k] ext4_end_bio
                |
                --- ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.42%          tar  [kernel.kallsyms]  [k] ext4_get_group_desc
                    |
                    --- ext4_get_group_desc
                       |          
                       |--88.05%-- __ext4_get_inode_loc
                       |          ext4_get_inode_loc
                       |          |          
                       |          |--64.96%-- ext4_reserve_inode_write
                       |          |          ext4_mark_inode_dirty
                       |          |          ext4_dirty_inode
                       |          |          __mark_inode_dirty
                       |          |          generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --35.04%-- ext4_xattr_get
                       |                     ext4_xattr_security_get
                       |                     generic_getxattr
                       |                     cap_inode_need_killpriv
                       |                     security_inode_need_killpriv
                       |                     file_remove_suid
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --11.95%-- ext4_get_inode_loc
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.42%          tar  [kernel.kallsyms]  [k] __percpu_counter_add
                    |
                    --- __percpu_counter_add
                       |          
                       |--39.75%-- ext4_da_get_block_prep
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--25.32%-- ext4_claim_free_blocks
                       |          ext4_da_get_block_prep
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--19.28%-- ext4_free_inode
                       |          ext4_evict_inode
                       |          evict
                       |          iput
                       |          do_unlinkat
                       |          sys_unlinkat
                       |          system_call_fastpath
                       |          unlinkat
                       |          
                        --15.64%-- __add_bdi_stat
                                  account_page_dirtied
                                  __set_page_dirty
                                  mark_buffer_dirty
                                  __block_commit_write
                                  block_write_end
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.42%          tar  [kernel.kallsyms]  [k] do_get_write_access
                    |
                    --- do_get_write_access
                       |          
                       |--80.57%-- jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --19.43%-- __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.42%          tar  [kernel.kallsyms]  [k] generic_file_buffered_write
                    |
                    --- generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.41%          tar  [kernel.kallsyms]  [k] jbd2_journal_stop
                    |
                    --- jbd2_journal_stop
                        __ext4_journal_stop
                       |          
                       |--79.71%-- ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --20.29%-- ext4_unlink
                                  vfs_unlink
                                  do_unlinkat
                                  sys_unlinkat
                                  system_call_fastpath
                                  unlinkat

     0.41%          tar  [kernel.kallsyms]  [k] jbd2__journal_start
                    |
                    --- jbd2__journal_start
                       |          
                       |--82.99%-- jbd2_journal_start
                       |          ext4_journal_start_sb
                       |          |          
                       |          |--83.87%-- ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --16.13%-- ext4_dirty_inode
                       |                     __mark_inode_dirty
                       |                     generic_write_end
                       |                     ext4_da_write_end
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --17.01%-- ext4_journal_start_sb
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.40%          tar  [kernel.kallsyms]  [k] do_mpage_readpage
                    |
                    --- do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.39%          tar  [kernel.kallsyms]  [k] arch_local_save_flags
                    |
                    --- arch_local_save_flags
                        __might_sleep
                       |          
                       |--55.35%-- __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          |          
                       |          |--61.18%-- __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --38.82%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--28.25%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --16.40%-- __getblk
                                  __ext4_get_inode_loc
                                  ext4_get_inode_loc
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.38%          tar  [kernel.kallsyms]  [k] alloc_pages_current
                    |
                    --- alloc_pages_current
                       |          
                       |--82.52%-- __page_cache_alloc
                       |          |          
                       |          |--74.42%-- grab_cache_page_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --25.58%-- __do_page_cache_readahead
                       |                     ra_submit
                       |                     ondemand_readahead
                       |                     page_cache_async_readahead
                       |                     generic_file_aio_read
                       |                     do_sync_read
                       |                     vfs_read
                       |                     sys_read
                       |                     system_call_fastpath
                       |                     __GI___libc_read
                       |          
                        --17.48%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.37%          tar  [kernel.kallsyms]  [k] __nr_to_section
                    |
                    --- __nr_to_section
                        lookup_page_cgroup
                       |          
                       |--70.03%-- __mem_cgroup_commit_charge_lrucare
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--17.38%-- mem_cgroup_get_reclaim_stat_from_page
                       |          update_page_reclaim_stat
                       |          ____pagevec_lru_add_fn
                       |          pagevec_lru_move_fn
                       |          ____pagevec_lru_add
                       |          __lru_cache_add
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --12.60%-- mem_cgroup_del_lru_list
                                  activate_page
                                  mark_page_accessed
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.37%          tar  [kernel.kallsyms]  [k] arch_local_irq_restore
                    |
                    --- arch_local_irq_restore
                       |          
                       |--52.73%-- _raw_spin_unlock_irqrestore
                       |          |          
                       |          |--51.73%-- __wake_up
                       |          |          jbd2_journal_stop
                       |          |          __ext4_journal_stop
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --48.27%-- pagevec_lru_move_fn
                       |                     ____pagevec_lru_add
                       |                     __lru_cache_add
                       |                     add_to_page_cache_lru
                       |                     grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --47.27%-- __wake_up
                                  jbd2_journal_stop
                                  __ext4_journal_stop
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.36%          tar  [kernel.kallsyms]  [k] __mem_cgroup_try_charge.constprop.27
                    |
                    --- __mem_cgroup_try_charge.constprop.27
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--67.66%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --32.34%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.36%      swapper  [kernel.kallsyms]  [k] unlock_page
                |
                --- unlock_page
                   |          
                   |--85.03%-- mpage_end_io
                   |          bio_endio
                   |          dec_pending
                   |          clone_endio
                   |          bio_endio
                   |          req_bio_endio
                   |          blk_update_request
                   |          blk_update_bidi_request
                   |          blk_end_bidi_request
                   |          blk_end_request
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --14.97%-- bio_endio
                              dec_pending
                              clone_endio
                              bio_endio
                              req_bio_endio
                              blk_update_request
                              blk_update_bidi_request
                              blk_end_bidi_request
                              blk_end_request
                              scsi_io_completion
                              scsi_finish_command
                              scsi_softirq_done
                              blk_done_softirq
                              __do_softirq
                              call_softirq
                              do_softirq
                              irq_exit
                              do_IRQ
                              common_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.35%          tar  [kernel.kallsyms]  [k] ext4_xattr_get
                    |
                    --- ext4_xattr_get
                       |          
                       |--68.95%-- ext4_xattr_security_get
                       |          generic_getxattr
                       |          cap_inode_need_killpriv
                       |          security_inode_need_killpriv
                       |          file_remove_suid
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --31.05%-- generic_getxattr
                                  cap_inode_need_killpriv
                                  security_inode_need_killpriv
                                  file_remove_suid
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.35%         perf  [kernel.kallsyms]  [k] seq_puts
                   |
                   --- seq_puts
                       render_sigset_t
                       proc_pid_status
                       proc_single_show
                       seq_read
                       vfs_read
                       sys_read
                       system_call_fastpath
                       __GI___libc_read

     0.35%          tar  [kernel.kallsyms]  [k] grab_cache_page_write_begin
                    |
                    --- grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.34%          tar  [kernel.kallsyms]  [k] alloc_page_buffers
                    |
                    --- alloc_page_buffers
                       |          
                       |--72.20%-- create_empty_buffers
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --27.80%-- __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.34%          tar  [kernel.kallsyms]  [k] debug_smp_processor_id
                    |
                    --- debug_smp_processor_id
                       |          
                       |--58.75%-- get_page_from_freelist
                       |          __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          |          
                       |          |--70.45%-- __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --29.55%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --41.25%-- __lru_cache_add
                                  add_to_page_cache_lru
                                  |          
                                  |--61.47%-- mpage_readpages
                                  |          ext4_readpages
                                  |          __do_page_cache_readahead
                                  |          ra_submit
                                  |          ondemand_readahead
                                  |          page_cache_async_readahead
                                  |          generic_file_aio_read
                                  |          do_sync_read
                                  |          vfs_read
                                  |          sys_read
                                  |          system_call_fastpath
                                  |          __GI___libc_read
                                  |          
                                   --38.53%-- grab_cache_page_write_begin
                                             ext4_da_write_begin
                                             generic_file_buffered_write
                                             __generic_file_aio_write
                                             generic_file_aio_write
                                             ext4_file_write
                                             do_sync_write
                                             vfs_write
                                             sys_write
                                             system_call_fastpath
                                             __GI___libc_write

     0.34%         perf  [kernel.kallsyms]  [k] clear_page_c
                   |
                   --- clear_page_c
                       __alloc_pages_nodemask
                       perf_mmap_alloc_page
                       perf_mmap
                       mmap_region
                       do_mmap_pgoff
                       sys_mmap_pgoff
                       sys_mmap
                       system_call_fastpath
                       __mmap
                       0x418523
                       0x4191c6
                       0x40f7a9
                       0x40ef8c
                       __libc_start_main

     0.34%          tar  [kernel.kallsyms]  [k] iov_iter_copy_from_user_atomic
                    |
                    --- iov_iter_copy_from_user_atomic
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.33%          tar  [kernel.kallsyms]  [k] page_cache_get_speculative
                    |
                    --- page_cache_get_speculative
                        find_get_page
                       |          
                       |--84.05%-- find_lock_page
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --15.95%-- generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.33%          top  [kernel.kallsyms]  [k] follow_managed
                    |
                    --- follow_managed
                        walk_component
                        link_path_walk
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_open
                        system_call_fastpath
                        __GI___libc_open

     0.33%  flush-253:2  [kernel.kallsyms]  [k] ext4_num_dirty_pages
            |
            --- ext4_num_dirty_pages
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.32%      swapper  [kernel.kallsyms]  [k] do_timer
                |
                --- do_timer
                    tick_do_update_jiffies64
                   |          
                   |--61.57%-- tick_sched_timer
                   |          __run_hrtimer
                   |          hrtimer_interrupt
                   |          smp_apic_timer_interrupt
                   |          apic_timer_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --38.43%-- tick_check_idle
                              irq_enter
                              smp_apic_timer_interrupt
                              apic_timer_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.32%          tar  [kernel.kallsyms]  [k] __generic_file_aio_write
                    |
                    --- __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.32%          tar  [kernel.kallsyms]  [k] mem_cgroup_add_lru_list
                    |
                    --- mem_cgroup_add_lru_list
                        add_page_to_lru_list
                        ____pagevec_lru_add_fn
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                       |          
                       |--87.33%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --12.67%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.32%          tar  [kernel.kallsyms]  [k] ext4_da_write_end
                    |
                    --- ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.32%  flush-253:2  [kernel.kallsyms]  [k] ext4_bio_write_page
            |
            --- ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.32%      swapper  [kernel.kallsyms]  [k] tick_nohz_stop_sched_tick
                |
                --- tick_nohz_stop_sched_tick
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.31%          tar  [kernel.kallsyms]  [k] down_read
                    |
                    --- down_read
                       |          
                       |--78.35%-- ext4_map_blocks
                       |          ext4_da_get_block_prep
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --21.65%-- ext4_xattr_get
                                  ext4_xattr_security_get
                                  generic_getxattr
                                  cap_inode_need_killpriv
                                  security_inode_need_killpriv
                                  file_remove_suid
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.31%          tar  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave
                    |
                    --- _raw_spin_lock_irqsave
                       |          
                       |--83.21%-- __wake_up
                       |          jbd2_journal_stop
                       |          __ext4_journal_stop
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --16.79%-- force_qs_rnp
                                  force_quiescent_state
                                  __rcu_process_callbacks
                                  rcu_process_callbacks
                                  __do_softirq
                                  call_softirq
                                  do_softirq
                                  irq_exit
                                  smp_apic_timer_interrupt
                                  apic_timer_interrupt
                                  __mem_cgroup_commit_charge_lrucare
                                  mem_cgroup_cache_charge
                                  add_to_page_cache_locked
                                  add_to_page_cache_lru
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.30%          tar  [kernel.kallsyms]  [k] arch_local_irq_restore
                    |
                    --- arch_local_irq_restore
                        get_page_from_freelist
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                       |          
                       |--59.37%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --40.63%-- __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.30%         perf  [kernel.kallsyms]  [k] file_update_time
                   |
                   --- file_update_time
                       __generic_file_aio_write
                       generic_file_aio_write
                       ext4_file_write
                       do_sync_write
                       vfs_write
                       sys_write
                       system_call_fastpath
                       __write_nocancel

     0.30%          tar  [kernel.kallsyms]  [k] mark_buffer_dirty
                    |
                    --- mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.29%      swapper  [kernel.kallsyms]  [k] add_preempt_count
                |
                --- add_preempt_count
                   |          
                   |--54.58%-- _raw_spin_lock_irqsave
                   |          |          
                   |          |--57.58%-- scsi_device_unbusy
                   |          |          scsi_finish_command
                   |          |          scsi_softirq_done
                   |          |          blk_done_softirq
                   |          |          __do_softirq
                   |          |          call_softirq
                   |          |          do_softirq
                   |          |          irq_exit
                   |          |          do_IRQ
                   |          |          common_interrupt
                   |          |          cpuidle_idle_call
                   |          |          cpu_idle
                   |          |          rest_init
                   |          |          start_kernel
                   |          |          x86_64_start_reservations
                   |          |          x86_64_start_kernel
                   |          |          
                   |           --42.42%-- test_clear_page_writeback
                   |                     end_page_writeback
                   |                     put_io_page
                   |                     ext4_end_bio
                   |                     bio_endio
                   |                     dec_pending
                   |                     clone_endio
                   |                     bio_endio
                   |                     req_bio_endio
                   |                     blk_update_request
                   |                     blk_update_bidi_request
                   |                     blk_end_bidi_request
                   |                     blk_end_request
                   |                     scsi_io_completion
                   |                     scsi_finish_command
                   |                     scsi_softirq_done
                   |                     blk_done_softirq
                   |                     __do_softirq
                   |                     call_softirq
                   |                     do_softirq
                   |                     irq_exit
                   |                     do_IRQ
                   |                     common_interrupt
                   |                     cpuidle_idle_call
                   |                     cpu_idle
                   |                     rest_init
                   |                     start_kernel
                   |                     x86_64_start_reservations
                   |                     x86_64_start_kernel
                   |          
                   |--20.90%-- __percpu_counter_add
                   |          __add_bdi_stat
                   |          test_clear_page_writeback
                   |          end_page_writeback
                   |          put_io_page
                   |          ext4_end_bio
                   |          bio_endio
                   |          dec_pending
                   |          clone_endio
                   |          bio_endio
                   |          req_bio_endio
                   |          blk_update_request
                   |          blk_update_bidi_request
                   |          blk_end_bidi_request
                   |          blk_end_request
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                   |--15.95%-- irq_enter
                   |          smp_apic_timer_interrupt
                   |          apic_timer_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --8.56%-- scsi_device_unbusy
                              scsi_finish_command
                              scsi_softirq_done
                              blk_done_softirq
                              __do_softirq
                              call_softirq
                              do_softirq
                              irq_exit
                              do_IRQ
                              common_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.29%          tar  [kernel.kallsyms]  [k] mnt_want_write_file
                    |
                    --- mnt_want_write_file
                       |          
                       |--76.04%-- __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --23.96%-- system_call_fastpath
                                  __GI___fchown

     0.27%          tar  [kernel.kallsyms]  [k] find_busiest_group
                    |
                    --- find_busiest_group
                        load_balance
                        schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.26%         perf  [kernel.kallsyms]  [k] perf_event_mmap_output
                   |
                   --- perf_event_mmap_output
                       perf_event_mmap_ctx
                       perf_event_mmap
                       mmap_region
                       do_mmap_pgoff
                       sys_mmap_pgoff
                       sys_mmap
                       system_call_fastpath
                       __mmap

     0.26%      swapper  [kernel.kallsyms]  [k] kmem_cache_free
                |
                --- kmem_cache_free
                   |          
                   |--59.24%-- mempool_free
                   |          clone_endio
                   |          bio_endio
                   |          req_bio_endio
                   |          blk_update_request
                   |          blk_update_bidi_request
                   |          blk_end_bidi_request
                   |          blk_end_request
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --40.76%-- scsi_pool_free_command
                              __scsi_put_command
                              scsi_put_command
                              scsi_next_command
                              scsi_io_completion
                              scsi_finish_command
                              scsi_softirq_done
                              blk_done_softirq
                              __do_softirq
                              call_softirq
                              do_softirq
                              irq_exit
                              do_IRQ
                              common_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.26%         perf  [kernel.kallsyms]  [k] fsnotify
                   |
                   --- fsnotify
                       fsnotify_modify
                       vfs_write
                       sys_write
                       system_call_fastpath
                       __write_nocancel
                       0x4293b8
                       0x429c0a
                       0x418709
                       0x4191c6
                       0x40f7a9
                       0x40ef8c
                       __libc_start_main

     0.26%         perf  [kernel.kallsyms]  [k] put_bh
                   |
                   --- put_bh
                       ext4_mark_iloc_dirty
                       ext4_mark_inode_dirty
                       ext4_dirty_inode
                       __mark_inode_dirty
                       generic_write_end
                       ext4_da_write_end
                       generic_file_buffered_write
                       __generic_file_aio_write
                       generic_file_aio_write
                       ext4_file_write
                       do_sync_write
                       vfs_write
                       sys_write
                       system_call_fastpath
                       __write_nocancel
                       0x4293b8
                       0x429c0a
                       0x418709
                       0x4191c6
                       0x40f7a9
                       0x40ef8c
                       __libc_start_main

     0.26%         perf  [kernel.kallsyms]  [k] _raw_spin_lock
                   |
                   --- _raw_spin_lock
                       prepend_path
                       path_with_deleted
                       d_path
                       seq_path
                       show_map_vma
                       show_map
                       seq_read
                       vfs_read
                       sys_read
                       system_call_fastpath
                       __GI___libc_read

     0.26%          tar  [kernel.kallsyms]  [k] get_page
                    |
                    --- get_page
                        __lru_cache_add
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.26%          tar  [kernel.kallsyms]  [k] selinux_file_permission
                    |
                    --- selinux_file_permission
                        security_file_permission
                        rw_verify_area
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.26%          tar  [kernel.kallsyms]  [k] test_ti_thread_flag
                    |
                    --- test_ti_thread_flag
                        need_resched
                        should_resched
                        _cond_resched
                       |          
                       |--64.24%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --35.76%-- generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.26%         perf  [kernel.kallsyms]  [k] number
                   |
                   --- number
                       vsnprintf
                       seq_printf
                       show_map_vma
                       show_map
                       seq_read
                       vfs_read
                       sys_read
                       system_call_fastpath
                       __GI___libc_read

     0.25%          tar  libc-2.13.90.so    [.] __GI___libc_write
                    |
                    --- __GI___libc_write

     0.25%          tar  [kernel.kallsyms]  [k] test_and_set_bit
                    |
                    --- test_and_set_bit
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.25%         perf  [kernel.kallsyms]  [k] vsnprintf
                   |
                   --- vsnprintf
                       seq_printf
                       show_map_vma
                       show_map
                       seq_read
                       vfs_read
                       sys_read
                       system_call_fastpath
                       __GI___libc_read

     0.25%          tar  [kernel.kallsyms]  [k] run_timer_softirq
                    |
                    --- run_timer_softirq
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        get_page_from_freelist
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.25%         perf  [kernel.kallsyms]  [k] setup_object
                   |
                   --- setup_object
                       new_slab
                       __slab_alloc
                       kmem_cache_alloc
                       d_alloc
                       proc_fill_cache
                       proc_task_readdir
                       vfs_readdir
                       sys_getdents
                       system_call_fastpath
                       __getdents64
                       0x429beb
                       0x418709
                       0x4191c6
                       0x40f7a9
                       0x40ef8c
                       __libc_start_main

     0.24%      swapper  [kernel.kallsyms]  [k] sub_preempt_count
                |
                --- sub_preempt_count
                   |          
                   |--40.64%-- __bit_spin_unlock.constprop.24
                   |          __slab_free
                   |          kmem_cache_free
                   |          put_io_page
                   |          ext4_end_bio
                   |          bio_endio
                   |          dec_pending
                   |          clone_endio
                   |          bio_endio
                   |          req_bio_endio
                   |          blk_update_request
                   |          blk_update_bidi_request
                   |          blk_end_bidi_request
                   |          blk_end_request
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                   |--33.53%-- _raw_spin_unlock_irqrestore
                   |          rcu_report_qs_rnp
                   |          __rcu_process_callbacks
                   |          rcu_process_callbacks
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          smp_apic_timer_interrupt
                   |          apic_timer_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --25.82%-- __slab_free
                              kmem_cache_free
                              mempool_free_slab
                              mempool_free
                              bio_free
                              bio_fs_destructor
                              bio_put
                              ext4_end_bio
                              bio_endio
                              dec_pending
                              clone_endio
                              bio_endio
                              req_bio_endio
                              blk_update_request
                              blk_update_bidi_request
                              blk_end_bidi_request
                              blk_end_request
                              scsi_io_completion
                              scsi_finish_command
                              scsi_softirq_done
                              blk_done_softirq
                              __do_softirq
                              call_softirq
                              do_softirq
                              irq_exit
                              do_IRQ
                              common_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.24%          tar  [kernel.kallsyms]  [k] add_to_page_cache_locked
                    |
                    --- add_to_page_cache_locked
                       |          
                       |--64.11%-- add_to_page_cache_lru
                       |          |          
                       |          |--63.51%-- grab_cache_page_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --36.49%-- mpage_readpages
                       |                     ext4_readpages
                       |                     __do_page_cache_readahead
                       |                     ra_submit
                       |                     ondemand_readahead
                       |                     page_cache_async_readahead
                       |                     generic_file_aio_read
                       |                     do_sync_read
                       |                     vfs_read
                       |                     sys_read
                       |                     system_call_fastpath
                       |                     __GI___libc_read
                       |          
                        --35.89%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.24%          tar  [kernel.kallsyms]  [k] file_remove_suid
                    |
                    --- file_remove_suid
                       |          
                       |--81.19%-- __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --18.81%-- generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.24%          tar  [kernel.kallsyms]  [k] clear_bit_unlock
                    |
                    --- clear_bit_unlock
                       |          
                       |--71.97%-- unlock_buffer
                       |          do_get_write_access
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          |          
                       |          |--58.50%-- file_update_time
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --41.50%-- generic_write_end
                       |                     ext4_da_write_end
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --28.03%-- do_get_write_access
                                  jbd2_journal_get_write_access
                                  __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.23%          tar  [kernel.kallsyms]  [k] sys_write
                    |
                    --- sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.23%      swapper  [kernel.kallsyms]  [k] SetPageUptodate
                |
                --- SetPageUptodate
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.23%          tar  [kernel.kallsyms]  [k] __bio_add_page.part.2
                    |
                    --- __bio_add_page.part.2
                        bio_add_page
                        do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.23%      swapper  [kernel.kallsyms]  [k] rcu_irq_enter
                |
                --- rcu_irq_enter
                    irq_enter
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.23%          tar  [kernel.kallsyms]  [k] _raw_spin_unlock_irq
                    |
                    --- _raw_spin_unlock_irq
                       |          
                       |--45.40%-- generic_make_request
                       |          submit_bio
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--29.98%-- mark_buffer_dirty
                       |          __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --24.62%-- add_to_page_cache_locked
                                  add_to_page_cache_lru
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.23%          tar  [kernel.kallsyms]  [k] bit_spin_lock
                    |
                    --- bit_spin_lock
                       |          
                       |--51.02%-- jbd2_journal_put_journal_head
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --48.98%-- jbd2_journal_get_write_access
                                  __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.22%      swapper  [kernel.kallsyms]  [k] nr_iowait_cpu
                |
                --- nr_iowait_cpu
                    tick_nohz_stop_idle
                    tick_check_idle
                    irq_enter
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.22%  flush-253:2  [kernel.kallsyms]  [k] page_waitqueue
            |
            --- page_waitqueue
               |          
               |--51.36%-- unlock_page
               |          ext4_bio_write_page
               |          mpage_da_submit_io
               |          mpage_da_map_and_submit
               |          ext4_da_writepages
               |          do_writepages
               |          writeback_single_inode
               |          writeback_sb_inodes
               |          writeback_inodes_wb
               |          wb_writeback
               |          wb_do_writeback
               |          bdi_writeback_thread
               |          kthread
               |          kernel_thread_helper
               |          
                --48.64%-- ext4_num_dirty_pages
                          ext4_da_writepages
                          do_writepages
                          writeback_single_inode
                          writeback_sb_inodes
                          writeback_inodes_wb
                          wb_writeback
                          wb_do_writeback
                          bdi_writeback_thread
                          kthread
                          kernel_thread_helper

     0.22%          tar  [kernel.kallsyms]  [k] __jbd2_log_space_left
                    |
                    --- __jbd2_log_space_left
                        start_this_handle
                        jbd2__journal_start
                        jbd2_journal_start
                        ext4_journal_start_sb
                       |          
                       |--50.77%-- ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --49.23%-- ext4_dirty_inode
                                  __mark_inode_dirty
                                  file_update_time
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.22%          tar  [kernel.kallsyms]  [k] mb_test_bit
                    |
                    --- mb_test_bit
                        mb_free_blocks
                        ext4_free_blocks
                        ext4_ext_truncate
                        ext4_truncate
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.22%          tar  [kernel.kallsyms]  [k] __blk_recalc_rq_segments
                    |
                    --- __blk_recalc_rq_segments
                        blk_recount_segments
                        bio_phys_segments
                        blk_rq_bio_prep
                        init_request_from_bio
                        __make_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.22%          tar  [kernel.kallsyms]  [k] generic_write_end
                    |
                    --- generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.22%          tar  [kernel.kallsyms]  [k] jbd2_journal_dirty_metadata
                    |
                    --- jbd2_journal_dirty_metadata
                       |          
                       |--62.74%-- __ext4_handle_dirty_metadata
                       |          ext4_mark_iloc_dirty
                       |          ext4_mark_inode_dirty
                       |          |          
                       |          |--59.79%-- ext4_dirty_inode
                       |          |          __mark_inode_dirty
                       |          |          generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --40.21%-- ext4_unlink
                       |                     vfs_unlink
                       |                     do_unlinkat
                       |                     sys_unlinkat
                       |                     system_call_fastpath
                       |                     unlinkat
                       |          
                        --37.26%-- ext4_mark_iloc_dirty
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  file_update_time
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.22%          tar  [kernel.kallsyms]  [k] __mem_cgroup_threshold
                    |
                    --- __mem_cgroup_threshold
                        memcg_check_events
                        __mem_cgroup_commit_charge.constprop.28
                        __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.21%          tar  [kernel.kallsyms]  [k] kfree
                    |
                    --- kfree
                        start_this_handle
                        jbd2__journal_start
                        jbd2_journal_start
                        ext4_journal_start_sb
                       |          
                       |--79.14%-- ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --20.86%-- ext4_dirty_inode
                                  __mark_inode_dirty
                                  file_update_time
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.21%          tar  [kernel.kallsyms]  [k] ext4_get_inode_flags
                    |
                    --- ext4_get_inode_flags
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                       |          
                       |--63.71%-- file_update_time
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --36.29%-- generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.21%  flush-253:2  [kernel.kallsyms]  [k] put_page_testzero
            |
            --- put_page_testzero
                release_pages
                __pagevec_release
                pagevec_release
               |          
               |--57.93%-- ext4_num_dirty_pages
               |          ext4_da_writepages
               |          do_writepages
               |          writeback_single_inode
               |          writeback_sb_inodes
               |          writeback_inodes_wb
               |          wb_writeback
               |          wb_do_writeback
               |          bdi_writeback_thread
               |          kthread
               |          kernel_thread_helper
               |          
                --42.07%-- write_cache_pages_da
                          ext4_da_writepages
                          do_writepages
                          writeback_single_inode
                          writeback_sb_inodes
                          writeback_inodes_wb
                          wb_writeback
                          wb_do_writeback
                          bdi_writeback_thread
                          kthread
                          kernel_thread_helper

     0.21%  flush-253:2  [kernel.kallsyms]  [k] __rcu_read_unlock
            |
            --- __rcu_read_unlock
                __find_get_block_slow
                unmap_underlying_metadata
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.21%          tar  [kernel.kallsyms]  [k] avtab_search
                    |
                    --- avtab_search
                        security_compute_sid
                        security_transition_sid
                        may_create
                        selinux_inode_create
                        security_inode_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.21%          tar  [kernel.kallsyms]  [k] search_dirblock
                    |
                    --- search_dirblock
                        ext4_dx_find_entry
                        ext4_find_entry
                        ext4_unlink
                        vfs_unlink
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.21%          tar  [kernel.kallsyms]  [k] __sg_alloc_table
                    |
                    --- __sg_alloc_table
                        scsi_init_sgtable
                        scsi_init_io
                        scsi_setup_fs_cmnd
                        sd_prep_fn
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.21%          tar  [kernel.kallsyms]  [k] ext4_journal_start_sb
                    |
                    --- ext4_journal_start_sb
                        ext4_dirty_inode
                        __mark_inode_dirty
                        file_update_time
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.21%          top  libc-2.13.90.so    [.] __GI_____strtoll_l_internal
                    |
                    --- __GI_____strtoll_l_internal

     0.20%      swapper  [kernel.kallsyms]  [k] do_raw_spin_lock
                |
                --- do_raw_spin_lock
                    _raw_spin_lock
                   |          
                   |--57.86%-- handle_edge_irq
                   |          handle_irq
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --42.14%-- tick_do_update_jiffies64
                              tick_check_idle
                              irq_enter
                              smp_apic_timer_interrupt
                              apic_timer_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.20%          tar  [kernel.kallsyms]  [k] generic_write_sync
                    |
                    --- generic_write_sync
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.20%          tar  [kernel.kallsyms]  [k] put_page
                    |
                    --- put_page
                       |          
                       |--64.65%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --35.35%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.20%  flush-253:2  [kernel.kallsyms]  [k] tag_get
            |
            --- tag_get
               |          
               |--58.46%-- __lookup_tag
               |          radix_tree_gang_lookup_tag_slot
               |          find_get_pages_tag
               |          pagevec_lookup_tag
               |          ext4_num_dirty_pages
               |          ext4_da_writepages
               |          do_writepages
               |          writeback_single_inode
               |          writeback_sb_inodes
               |          writeback_inodes_wb
               |          wb_writeback
               |          wb_do_writeback
               |          bdi_writeback_thread
               |          kthread
               |          kernel_thread_helper
               |          
                --41.54%-- test_set_page_writeback
                          ext4_bio_write_page
                          mpage_da_submit_io
                          mpage_da_map_and_submit
                          ext4_da_writepages
                          do_writepages
                          writeback_single_inode
                          writeback_sb_inodes
                          writeback_inodes_wb
                          wb_writeback
                          wb_do_writeback
                          bdi_writeback_thread
                          kthread
                          kernel_thread_helper

     0.20%          tar  [kernel.kallsyms]  [k] dm_merge_bvec
                    |
                    --- dm_merge_bvec
                        __bio_add_page.part.2
                        bio_add_page
                        do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.19%          tar  [kernel.kallsyms]  [k] __ext4_handle_dirty_metadata
                    |
                    --- __ext4_handle_dirty_metadata
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.19%          tar  [kernel.kallsyms]  [k] __block_commit_write
                    |
                    --- __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.19%          tar  [kernel.kallsyms]  [k] _raw_spin_unlock_irqrestore
                    |
                    --- _raw_spin_unlock_irqrestore
                       |          
                       |--54.81%-- __wake_up
                       |          jbd2_journal_stop
                       |          __ext4_journal_stop
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --45.19%-- __delayacct_blkio_end
                                  delayacct_blkio_end
                                  io_schedule
                                  sleep_on_page_killable
                                  __wait_on_bit_lock
                                  __lock_page_killable
                                  lock_page_killable
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.19%          tar  [kernel.kallsyms]  [k] ext4_writepage_trans_blocks
                    |
                    --- ext4_writepage_trans_blocks
                        ext4_ext_truncate
                        ext4_truncate
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.19%          tar  [kernel.kallsyms]  [k] jbd_lock_bh_state
                    |
                    --- jbd_lock_bh_state
                       |          
                       |--62.13%-- do_get_write_access
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --37.87%-- jbd2_journal_dirty_metadata
                                  __ext4_handle_dirty_metadata
                                  ext4_mark_iloc_dirty
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.19%          tar  [kernel.kallsyms]  [k] __list_add
                    |
                    --- __list_add
                       |          
                       |--70.74%-- __make_request
                       |          generic_make_request
                       |          submit_bio
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --29.26%-- expand
                                  __rmqueue
                                  get_page_from_freelist
                                  __alloc_pages_nodemask
                                  alloc_pages_current
                                  __page_cache_alloc
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.19%          tar  [kernel.kallsyms]  [k] fsnotify_modify
                    |
                    --- fsnotify_modify
                       |          
                       |--74.13%-- vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --25.87%-- sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.19%  flush-253:2  [kernel.kallsyms]  [k] lock_page
            |
            --- lock_page
                write_cache_pages_da
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.19%  flush-253:2  [kernel.kallsyms]  [k] rb_next
            |
            --- rb_next
                set_next_entity
                pick_next_task_fair
                pick_next_task
                schedule
                preempt_schedule_irq
                retint_kernel
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.19%          tar  [kernel.kallsyms]  [k] ext4_ext_calc_metadata_amount
                    |
                    --- ext4_ext_calc_metadata_amount
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.18%      swapper  [kernel.kallsyms]  [k] __wake_up_bit
                |
                --- __wake_up_bit
                   |          
                   |--61.24%-- unlock_page
                   |          mpage_end_io
                   |          bio_endio
                   |          dec_pending
                   |          clone_endio
                   |          bio_endio
                   |          req_bio_endio
                   |          blk_update_request
                   |          blk_update_bidi_request
                   |          blk_end_bidi_request
                   |          blk_end_request
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --38.76%-- end_page_writeback
                              put_io_page
                              ext4_end_bio
                              bio_endio
                              dec_pending
                              clone_endio
                              bio_endio
                              req_bio_endio
                              blk_update_request
                              blk_update_bidi_request
                              blk_end_bidi_request
                              blk_end_request
                              scsi_io_completion
                              scsi_finish_command
                              scsi_softirq_done
                              blk_done_softirq
                              __do_softirq
                              call_softirq
                              do_softirq
                              irq_exit
                              do_IRQ
                              common_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.18%      swapper  [kernel.kallsyms]  [k] select_nohz_load_balancer
                |
                --- select_nohz_load_balancer
                   |          
                   |--75.59%-- tick_nohz_restart_sched_tick
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --24.41%-- tick_nohz_stop_sched_tick
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.18%      swapper  [kernel.kallsyms]  [k] menu_select
                |
                --- menu_select
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.18%  flush-253:2  [kernel.kallsyms]  [k] page_cache_get_speculative
            |
            --- page_cache_get_speculative
                find_get_pages
                pagevec_lookup
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.18%          tar  [kernel.kallsyms]  [k] generic_file_aio_read
                    |
                    --- generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.18%          tar  [kernel.kallsyms]  [k] __prop_inc_single
                    |
                    --- __prop_inc_single
                        task_dirty_inc
                        account_page_dirtied
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.18%      swapper  [kernel.kallsyms]  [k] page_index
                |
                --- page_index
                    test_clear_page_writeback
                    end_page_writeback
                    put_io_page
                    ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.17%          tar  [kernel.kallsyms]  [k] arch_read_lock
                    |
                    --- arch_read_lock
                        _raw_read_lock
                        start_this_handle
                        jbd2__journal_start
                        jbd2_journal_start
                        ext4_journal_start_sb
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.17%          tar  [kernel.kallsyms]  [k] mutex_unlock
                    |
                    --- mutex_unlock
                       |          
                       |--73.48%-- generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --26.52%-- do_last
                                  path_openat
                                  do_filp_open
                                  do_sys_open
                                  sys_openat
                                  system_call_fastpath
                                  __GI___openat

     0.17%          tar  [kernel.kallsyms]  [k] blk_rq_map_sg
                    |
                    --- blk_rq_map_sg
                        scsi_init_sgtable
                        scsi_init_io
                        scsi_setup_fs_cmnd
                        sd_prep_fn
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.17%          tar  [kernel.kallsyms]  [k] bit_waitqueue
                    |
                    --- bit_waitqueue
                       |          
                       |--51.20%-- wake_up_bit
                       |          unlock_buffer
                       |          do_get_write_access
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          file_update_time
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --48.80%-- unlock_buffer
                                  do_get_write_access
                                  jbd2_journal_get_write_access
                                  __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.17%          tar  [kernel.kallsyms]  [k] SetPageLRU
                    |
                    --- SetPageLRU
                        ____pagevec_lru_add_fn
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                       |          
                       |--71.47%-- mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --28.53%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.17%          tar  [kernel.kallsyms]  [k] test_ti_thread_flag.constprop.6
                    |
                    --- test_ti_thread_flag.constprop.6
                       |          
                       |--64.90%-- _raw_spin_unlock_irq
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --35.10%-- inode_add_rsv_space
                                  __dquot_alloc_space
                                  ext4_da_get_block_prep
                                  __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.17%          tar  [kernel.kallsyms]  [k] lookup_page_cgroup
                    |
                    --- lookup_page_cgroup
                       |          
                       |--58.52%-- __mem_cgroup_commit_charge_lrucare
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --41.48%-- mem_cgroup_cache_charge
                                  add_to_page_cache_locked
                                  add_to_page_cache_lru
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.17%          tar  [kernel.kallsyms]  [k] generic_make_request
                    |
                    --- generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.17%          tar  [kernel.kallsyms]  [k] lock_page_cgroup
                    |
                    --- lock_page_cgroup
                        __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.17%      swapper  [kernel.kallsyms]  [k] mempool_free
                |
                --- mempool_free
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.17%          tar  [kernel.kallsyms]  [k] put_prev_task_fair
                    |
                    --- put_prev_task_fair
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.17%          tar  [kernel.kallsyms]  [k] perf_event_task_tick
                    |
                    --- perf_event_task_tick
                        scheduler_tick
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                       |          
                       |--51.07%-- scsi_request_fn
                       |          __blk_run_queue
                       |          queue_unplugged
                       |          blk_flush_plug_list
                       |          io_schedule
                       |          sleep_on_page_killable
                       |          __wait_on_bit_lock
                       |          __lock_page_killable
                       |          lock_page_killable
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --48.93%-- _ext4_get_block
                                  ext4_get_block
                                  do_mpage_readpage
                                  mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.17%          tar  [kernel.kallsyms]  [k] arch_read_unlock
                    |
                    --- arch_read_unlock
                       |          
                       |--66.07%-- _raw_read_unlock
                       |          start_this_handle
                       |          jbd2__journal_start
                       |          jbd2_journal_start
                       |          ext4_journal_start_sb
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --33.93%-- _raw_read_unlock_irqrestore
                                  dm_get_live_table
                                  dm_merge_bvec
                                  __bio_add_page.part.2
                                  bio_add_page
                                  do_mpage_readpage
                                  mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.16%      swapper  [kernel.kallsyms]  [k] debug_smp_processor_id
                |
                --- debug_smp_processor_id
                   |          
                   |--38.89%-- __cycles_2_ns
                   |          native_sched_clock
                   |          sched_clock
                   |          sched_clock_cpu
                   |          account_system_vtime
                   |          irq_exit
                   |          smp_apic_timer_interrupt
                   |          apic_timer_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                   |--32.56%-- tick_check_idle
                   |          irq_enter
                   |          smp_apic_timer_interrupt
                   |          apic_timer_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                   |--14.27%-- account_idle_time
                   |          irqtime_account_process_tick
                   |          account_idle_ticks
                   |          tick_nohz_restart_sched_tick
                   |          cpu_idle
                   |          start_secondary
                   |          
                    --14.27%-- irqtime_account_process_tick
                              account_idle_ticks
                              tick_nohz_restart_sched_tick
                              cpu_idle
                              start_secondary

     0.16%          tar  [kernel.kallsyms]  [k] fget_light
                    |
                    --- fget_light
                       |          
                       |--51.07%-- sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --48.93%-- sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.16%          tar  [kernel.kallsyms]  [k] SetPageUptodate
                    |
                    --- SetPageUptodate
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.16%          tar  [kernel.kallsyms]  [k] __ext4_journal_stop
                    |
                    --- __ext4_journal_stop
                       |          
                       |--50.22%-- ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --49.78%-- ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.16%          tar  [kernel.kallsyms]  [k] ext4_clear_inode_state
                    |
                    --- ext4_clear_inode_state
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                       |          
                       |--51.89%-- file_update_time
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --48.11%-- generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.16%          tar  [kernel.kallsyms]  [k] mem_cgroup_cache_charge
                    |
                    --- mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--65.55%-- mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --34.45%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.16%          tar  [kernel.kallsyms]  [k] ext4_map_blocks
                    |
                    --- ext4_map_blocks
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.16%          tar  [kernel.kallsyms]  [k] ata_dev_enabled
                    |
                    --- ata_dev_enabled
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.16%          tar  [kernel.kallsyms]  [k] new_slab
                    |
                    --- new_slab
                        __slab_alloc
                        kmem_cache_alloc
                        alloc_buffer_head
                        alloc_page_buffers
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.16%      swapper  [kernel.kallsyms]  [k] hrtimer_cancel
                |
                --- hrtimer_cancel
                    tick_nohz_restart_sched_tick
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.15%          tar  [kernel.kallsyms]  [k] lock_buffer
                    |
                    --- lock_buffer
                        do_get_write_access
                        jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.15%          tar  [kernel.kallsyms]  [k] bit_spin_unlock
                    |
                    --- bit_spin_unlock
                        unlock_page_cgroup
                        __mem_cgroup_commit_charge.constprop.28
                        __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--72.67%-- mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --27.33%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.15%          tar  [kernel.kallsyms]  [k] up_read
                    |
                    --- up_read
                       |          
                       |--62.56%-- ext4_map_blocks
                       |          ext4_da_get_block_prep
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --37.44%-- ext4_xattr_get
                                  ext4_xattr_security_get
                                  generic_getxattr
                                  cap_inode_need_killpriv
                                  security_inode_need_killpriv
                                  file_remove_suid
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.15%          tar  [kernel.kallsyms]  [k] preempt_schedule
                    |
                    --- preempt_schedule
                        try_to_wake_up
                        wake_up_process
                        wake_up_worker
                        insert_work
                        __queue_work
                        delayed_work_timer_fn
                        run_timer_softirq
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        _raw_read_lock
                        start_this_handle
                        jbd2__journal_start
                        jbd2_journal_start
                        ext4_journal_start_sb
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.15%          tar  [kernel.kallsyms]  [k] fsnotify_access
                    |
                    --- fsnotify_access
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.15%      swapper  [kernel.kallsyms]  [k] native_read_tsc
                |
                --- native_read_tsc
                    paravirt_read_tsc
                    native_sched_clock
                    sched_clock
                    sched_clock_cpu
                    account_system_vtime
                    irq_enter
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.14%          tar  [kernel.kallsyms]  [k] dequeue_task_fair
                    |
                    --- dequeue_task_fair
                        dequeue_task
                        deactivate_task
                        schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.14%          tar  [kernel.kallsyms]  [k] ata_scsi_queuecmd
                    |
                    --- ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.14%          tar  [kernel.kallsyms]  [k] file_read_actor
                    |
                    --- file_read_actor
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.14%          tar  [kernel.kallsyms]  [k] _raw_spin_lock
                    |
                    --- _raw_spin_lock
                       |          
                       |--52.50%-- ext4_da_get_block_prep
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --47.50%-- ext4_ext_map_blocks
                                  ext4_map_blocks
                                  ext4_da_get_block_prep
                                  __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.14%          top  [kernel.kallsyms]  [k] add_preempt_count
                    |
                    --- add_preempt_count
                        _raw_spin_lock
                        nameidata_drop_rcu
                        link_path_walk
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_open
                        system_call_fastpath
                        __GI___libc_open

     0.14%          tar  [kernel.kallsyms]  [k] generic_file_aio_write
                    |
                    --- generic_file_aio_write
                       |          
                       |--52.11%-- do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --47.89%-- ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.14%          tar  [kernel.kallsyms]  [k] block_write_end
                    |
                    --- block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.14%          tar  [kernel.kallsyms]  [k] hrtimer_interrupt
                    |
                    --- hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                       |          
                       |--52.67%-- jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          file_update_time
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --47.33%-- string_to_context_struct
                                  security_context_to_sid_core
                                  security_context_to_sid_default
                                  inode_doinit_with_dentry
                                  selinux_d_instantiate
                                  security_d_instantiate
                                  d_instantiate
                                  d_splice_alias
                                  ext4_lookup
                                  d_alloc_and_lookup
                                  __lookup_hash.part.3
                                  lookup_hash
                                  do_last
                                  path_openat
                                  do_filp_open
                                  do_sys_open
                                  sys_openat
                                  system_call_fastpath
                                  __GI___openat

     0.14%  flush-253:2  [kernel.kallsyms]  [k] sub_preempt_count
            |
            --- sub_preempt_count
                __percpu_counter_add
                __add_bdi_stat
                clear_page_dirty_for_io
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.14%      swapper  [kernel.kallsyms]  [k] __rcu_read_lock
                |
                --- __rcu_read_lock
                   |          
                   |--50.04%-- __prop_inc_percpu_max
                   |          test_clear_page_writeback
                   |          end_page_writeback
                   |          put_io_page
                   |          ext4_end_bio
                   |          bio_endio
                   |          dec_pending
                   |          clone_endio
                   |          bio_endio
                   |          req_bio_endio
                   |          blk_update_request
                   |          blk_update_bidi_request
                   |          blk_end_bidi_request
                   |          blk_end_request
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --49.96%-- __atomic_notifier_call_chain
                              atomic_notifier_call_chain
                              exit_idle
                              do_IRQ
                              common_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.13%          tar  [kernel.kallsyms]  [k] ktime_get_ts
                    |
                    --- ktime_get_ts
                        __delayacct_blkio_end
                        delayacct_blkio_end
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.13%          tar  [kernel.kallsyms]  [k] page_zone
                    |
                    --- page_zone
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] __read_lock_failed
                    |
                    --- __read_lock_failed
                        _raw_read_lock
                        start_this_handle
                        jbd2__journal_start
                        jbd2_journal_start
                        ext4_journal_start_sb
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] prop_norm_single
                    |
                    --- prop_norm_single
                        __prop_inc_single
                        task_dirty_inc
                        account_page_dirtied
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] put_bh
                    |
                    --- put_bh
                        __brelse
                        brelse
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] radix_tree_insert
                    |
                    --- radix_tree_insert
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] policy_zonelist
                    |
                    --- policy_zonelist
                        alloc_pages_current
                        __page_cache_alloc
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.13%          tar  [kernel.kallsyms]  [k] atomic_inc
                    |
                    --- atomic_inc
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.13%      swapper  [kernel.kallsyms]  [k] irq_entries_start
                |
                --- irq_entries_start
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.13%          top  libproc-3.2.8.so   [.] 0x44c2          
                    |
                    --- 0x37d94044c2

     0.13%  flush-253:2  [kernel.kallsyms]  [k] attempt_back_merge
            |
            --- attempt_back_merge
                generic_make_request
                submit_bio
                ext4_io_submit
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.13%          tar  [kernel.kallsyms]  [k] virt_to_head_page
                    |
                    --- virt_to_head_page
                        kmem_cache_free
                        jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] mnt_clone_write
                    |
                    --- mnt_clone_write
                        mnt_want_write_file
                        file_update_time
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] rb_erase
                    |
                    --- rb_erase
                        deadline_remove_request
                        deadline_move_request
                        deadline_dispatch_requests
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.13%          tar  [kernel.kallsyms]  [k] __set_page_dirty
                    |
                    --- __set_page_dirty
                       |          
                       |--51.11%-- __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --48.89%-- mark_buffer_dirty
                                  __block_commit_write
                                  block_write_end
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] do_sync_write
                    |
                    --- do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] atomic_inc
                    |
                    --- atomic_inc
                        __find_get_block
                        __getblk
                        __ext4_get_inode_loc
                        ext4_get_inode_loc
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] arch_local_irq_disable
                    |
                    --- arch_local_irq_disable
                        _raw_spin_lock_irq
                       |          
                       |--55.62%-- add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --44.38%-- __set_page_dirty
                                  mark_buffer_dirty
                                  __block_commit_write
                                  block_write_end
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] kmem_cache_free
                    |
                    --- kmem_cache_free
                        jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.13%          tar  [kernel.kallsyms]  [k] ext4_da_write_begin
                    |
                    --- ext4_da_write_begin
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.12%      swapper  [kernel.kallsyms]  [k] arch_local_irq_restore
                |
                --- arch_local_irq_restore
                   |          
                   |--69.63%-- account_system_vtime
                   |          irq_exit
                   |          smp_apic_timer_interrupt
                   |          apic_timer_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --30.37%-- irqtime_account_process_tick
                              account_idle_ticks
                              tick_nohz_restart_sched_tick
                              cpu_idle
                              start_secondary

     0.12%  flush-253:2  [kernel.kallsyms]  [k] arch_local_irq_restore
            |
            --- arch_local_irq_restore
                test_set_page_writeback
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.12%          tar  [kernel.kallsyms]  [k] inode_reserved_space
                    |
                    --- inode_reserved_space
                        __dquot_alloc_space
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.12%      swapper  [kernel.kallsyms]  [k] update_cfs_shares
                |
                --- update_cfs_shares
                    enqueue_task_fair
                    enqueue_task
                    activate_task
                    try_to_wake_up
                    default_wake_function
                    autoremove_wake_function
                    wake_bit_function
                    __wake_up_common
                    __wake_up
                    __wake_up_bit
                    unlock_page
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.12%          tar  [kernel.kallsyms]  [k] schedule
                    |
                    --- schedule
                       |          
                       |--59.95%-- io_schedule
                       |          sleep_on_page_killable
                       |          __wait_on_bit_lock
                       |          __lock_page_killable
                       |          lock_page_killable
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --40.05%-- __GI___libc_read

     0.12%          tar  [kernel.kallsyms]  [k] security_sid_to_context_force
                    |
                    --- security_sid_to_context_force
                        security_inode_init_security
                        ext4_init_security
                        ext4_new_inode
                        ext4_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.12%          tar  [kernel.kallsyms]  [k] radix_tree_preload
                    |
                    --- radix_tree_preload
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--54.07%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --45.93%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.12%      swapper  [kernel.kallsyms]  [k] arch_local_save_flags
                |
                --- arch_local_save_flags
                    _local_bh_enable
                    irq_enter
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.12%  flush-253:2  [kernel.kallsyms]  [k] release_pages
            |
            --- release_pages
                __pagevec_release
                pagevec_release
                write_cache_pages_da
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.12%  flush-253:2  [kernel.kallsyms]  [k] page_mkclean
            |
            --- page_mkclean
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.12%          tar  [kernel.kallsyms]  [k] set_bh_page
                    |
                    --- set_bh_page
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.12%          tar  [kernel.kallsyms]  [k] account_entity_dequeue
                    |
                    --- account_entity_dequeue
                        dequeue_task
                        deactivate_task
                        schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.12%          tar  [kernel.kallsyms]  [k] ata_qc_issue
                    |
                    --- ata_qc_issue
                        __ata_scsi_queuecmd
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.12%          tar  libc-2.13.90.so    [.] __cfree
                    |
                    --- __cfree

     0.12%          tar  [kernel.kallsyms]  [k] radix_tree_lookup_slot
                    |
                    --- radix_tree_lookup_slot
                       |          
                       |--62.63%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --37.37%-- find_lock_page
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.12%          top  libc-2.13.90.so    [.] _IO_vfscanf_internal
                    |
                    --- _IO_vfscanf_internal
                        _IO_vsscanf
                        0x7fffef292b20

     0.12%          tar  [kernel.kallsyms]  [k] ext4_inode_table
                    |
                    --- ext4_inode_table
                        __ext4_get_inode_loc
                        ext4_get_inode_loc
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.12%          tar  [kernel.kallsyms]  [k] xattr_resolve_name
                    |
                    --- xattr_resolve_name
                        generic_getxattr
                        cap_inode_need_killpriv
                        security_inode_need_killpriv
                        file_remove_suid
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.12%          tar  [kernel.kallsyms]  [k] add_to_page_cache_lru
                    |
                    --- add_to_page_cache_lru
                       |          
                       |--67.10%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --32.90%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.12%  migration/0  [kernel.kallsyms]  [k] resched_task
            |
            --- resched_task
                check_preempt_curr
                __migrate_task
                migration_cpu_stop
                cpu_stopper_thread
                kthread
                kernel_thread_helper

     0.12%          tar  [kernel.kallsyms]  [k] __count_vm_events
                    |
                    --- __count_vm_events
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                       |          
                       |--50.90%-- __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --49.10%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.12%          tar  [kernel.kallsyms]  [k] system_call_fastpath
                    |
                    --- system_call_fastpath
                        __GI___libc_write

     0.11%  flush-253:2  [kernel.kallsyms]  [k] __percpu_counter_add
            |
            --- __percpu_counter_add
                __add_bdi_stat
                clear_page_dirty_for_io
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.11%      swapper  [kernel.kallsyms]  [k] page_waitqueue
                |
                --- page_waitqueue
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.11%  kworker/0:2  [kernel.kallsyms]  [k] worker_thread
            |
            --- worker_thread
                kthread
                kernel_thread_helper

     0.11%          tar  [kernel.kallsyms]  [k] fsnotify
                    |
                    --- fsnotify
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.11%          tar  [kernel.kallsyms]  [k] is_handle_aborted
                    |
                    --- is_handle_aborted
                        jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.11%          tar  [kernel.kallsyms]  [k] blk_finish_plug
                    |
                    --- blk_finish_plug
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.11%          tar  [kernel.kallsyms]  [k] arch_local_irq_save
                    |
                    --- arch_local_irq_save
                        task_dirty_inc
                        account_page_dirtied
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.11%          tar  [kernel.kallsyms]  [k] jbd2_journal_get_write_access
                    |
                    --- jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        file_update_time
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.11%          tar  [kernel.kallsyms]  [k] vfs_write
                    |
                    --- vfs_write
                        system_call_fastpath
                        __GI___libc_write

     0.11%      swapper  [kernel.kallsyms]  [k] irqtime_account_process_tick
                |
                --- irqtime_account_process_tick
                    update_process_times
                    tick_sched_timer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    start_secondary

     0.11%          tar  [kernel.kallsyms]  [k] blk_flush_plug_list
                    |
                    --- blk_flush_plug_list
                        blk_finish_plug
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.11%          tar  [kernel.kallsyms]  [k] deadline_remove_request
                    |
                    --- deadline_remove_request
                        deadline_dispatch_requests
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.11%          tar  [kernel.kallsyms]  [k] mb_find_buddy
                    |
                    --- mb_find_buddy
                        mb_free_blocks
                        ext4_free_blocks
                        ext4_ext_truncate
                        ext4_truncate
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.11%          tar  [kernel.kallsyms]  [k] sys_read
                    |
                    --- sys_read
                       |          
                       |--58.45%-- system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --41.55%-- __GI___libc_read

     0.11%  flush-253:2  [kernel.kallsyms]  [k] arch_read_unlock
            |
            --- arch_read_unlock
                _raw_read_unlock_irqrestore
                dm_get_live_table
                dm_merge_bvec
                __bio_add_page.part.2
                bio_add_page
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.11%      swapper  [kernel.kallsyms]  [k] __slab_free
                |
                --- __slab_free
                    kmem_cache_free
                    mempool_free_slab
                    mempool_free
                    scsi_sg_free
                    __sg_free_table
                    __scsi_release_buffers
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.11%          tar  [kernel.kallsyms]  [k] sidtab_search_core
                    |
                    --- sidtab_search_core
                        sidtab_search
                        security_compute_sid
                        security_transition_sid
                        may_create
                        selinux_inode_create
                        security_inode_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.11%      swapper  [kernel.kallsyms]  [k] switch_mm
                |
                --- switch_mm
                    schedule
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.11%  flush-253:2  [kernel.kallsyms]  [k] mpage_da_submit_io
            |
            --- mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.11%          tar  [kernel.kallsyms]  [k] mem_cgroup_charge_statistics
                    |
                    --- mem_cgroup_charge_statistics
                        __mem_cgroup_commit_charge.constprop.28
                        __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--56.66%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --43.34%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.11%          tar  [kernel.kallsyms]  [k] zone_watermark_ok
                    |
                    --- zone_watermark_ok
                       |          
                       |--50.80%-- __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --49.20%-- get_page_from_freelist
                                  __alloc_pages_nodemask
                                  alloc_pages_current
                                  __page_cache_alloc
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.11%          tar  [kernel.kallsyms]  [k] ext4_free_blocks
                    |
                    --- ext4_free_blocks
                        ext4_ext_truncate
                        ext4_truncate
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.11%          tar  [kernel.kallsyms]  [k] ext4_ext_map_blocks
                    |
                    --- ext4_ext_map_blocks
                        ext4_map_blocks
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.11%          tar  [kernel.kallsyms]  [k] page_waitqueue
                    |
                    --- page_waitqueue
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.11%          tar  [kernel.kallsyms]  [k] add_dirent_to_buf
                    |
                    --- add_dirent_to_buf
                        ext4_add_entry
                        ext4_add_nondir
                        ext4_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.11%          tar  [kernel.kallsyms]  [k] strcmp
                    |
                    --- strcmp
                        symcmp
                        hashtab_search
                        string_to_context_struct
                        security_context_to_sid_core
                        security_context_to_sid_default
                        inode_doinit_with_dentry
                        selinux_d_instantiate
                        security_d_instantiate
                        d_instantiate
                        d_splice_alias
                        ext4_lookup
                        d_alloc_and_lookup
                        __lookup_hash.part.3
                        lookup_hash
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.11%          tar  [kernel.kallsyms]  [k] select_idle_sibling
                    |
                    --- select_idle_sibling
                        select_task_rq_fair
                        select_task_rq
                        try_to_wake_up
                        wake_up_process
                        wake_up_worker
                        insert_work
                        __queue_work
                        delayed_work_timer_fn
                        run_timer_softirq
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.11%  flush-253:2  [kernel.kallsyms]  [k] __wake_up_bit
            |
            --- __wake_up_bit
                unlock_page
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.11%          tar  [kernel.kallsyms]  [k] radix_tree_node_alloc
                    |
                    --- radix_tree_node_alloc
                        radix_tree_insert
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--60.14%-- mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --39.86%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.10%      swapper  [kernel.kallsyms]  [k] rcu_irq_exit
                |
                --- rcu_irq_exit
                   |          
                   |--54.97%-- smp_apic_timer_interrupt
                   |          apic_timer_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --45.03%-- irq_exit
                              do_IRQ
                              common_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.10%          tar  [kernel.kallsyms]  [k] radix_tree_tag_set
                    |
                    --- radix_tree_tag_set
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.10%          tar  [kernel.kallsyms]  [k] check_irqs_on
                    |
                    --- check_irqs_on
                        __getblk
                        __ext4_get_inode_loc
                        ext4_get_inode_loc
                        ext4_xattr_get
                        ext4_xattr_security_get
                        generic_getxattr
                        cap_inode_need_killpriv
                        security_inode_need_killpriv
                        file_remove_suid
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.10%  flush-253:2  [kernel.kallsyms]  [k] add_preempt_count
            |
            --- add_preempt_count
                __add_bdi_stat
                test_set_page_writeback
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.10%  flush-253:2  [kernel.kallsyms]  [k] arch_local_save_flags
            |
            --- arch_local_save_flags
                __might_sleep
                unmap_underlying_metadata
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.10%          tar  [kernel.kallsyms]  [k] irqtime_account_process_tick
                    |
                    --- irqtime_account_process_tick
                        account_process_tick
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        get_page_from_freelist
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.10%          tar  [kernel.kallsyms]  [k] alloc_buffer_head
                    |
                    --- alloc_buffer_head
                        alloc_page_buffers
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.10%          tar  [kernel.kallsyms]  [k] jiffies_to_timeval
                    |
                    --- jiffies_to_timeval
                        __account_system_time
                        irqtime_account_process_tick
                        account_process_tick
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        __find_get_block
                        __getblk
                        __ext4_get_inode_loc
                        ext4_get_inode_loc
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_unlink
                        vfs_unlink
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.10%          tar  [kernel.kallsyms]  [k] ext4_get_reserved_space
                    |
                    --- ext4_get_reserved_space
                        inode_add_rsv_space
                        __dquot_alloc_space
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.10%      swapper  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave
                |
                --- _raw_spin_lock_irqsave
                    scsi_next_command
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.10%          tar  [kernel.kallsyms]  [k] blk_start_plug
                    |
                    --- blk_start_plug
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.10%  flush-253:2  [kernel.kallsyms]  [k] sg_init_table
            |
            --- sg_init_table
                scsi_alloc_sgtable
                scsi_init_sgtable
                scsi_init_io
                scsi_setup_fs_cmnd
                sd_prep_fn
                blk_peek_request
                scsi_request_fn
                __blk_run_queue
                __make_request
                generic_make_request
                submit_bio
                ext4_io_submit
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.10%          tar  [kernel.kallsyms]  [k] ata_qc_new_init
                    |
                    --- ata_qc_new_init
                       |          
                       |--51.58%-- ata_scsi_queuecmd
                       |          scsi_dispatch_cmd
                       |          scsi_request_fn
                       |          __blk_run_queue
                       |          queue_unplugged
                       |          blk_flush_plug_list
                       |          io_schedule
                       |          sleep_on_page_killable
                       |          __wait_on_bit_lock
                       |          __lock_page_killable
                       |          lock_page_killable
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --48.42%-- __ata_scsi_queuecmd
                                  ata_scsi_queuecmd
                                  scsi_dispatch_cmd
                                  scsi_request_fn
                                  __blk_run_queue
                                  queue_unplugged
                                  blk_flush_plug_list
                                  io_schedule
                                  sleep_on_page_killable
                                  __wait_on_bit_lock
                                  __lock_page_killable
                                  lock_page_killable
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.10%          tar  [kernel.kallsyms]  [k] arch_local_save_flags
                    |
                    --- arch_local_save_flags
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        _raw_spin_unlock_irq
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.10%  flush-253:2  [kernel.kallsyms]  [k] inc_zone_page_state
            |
            --- inc_zone_page_state
                account_page_writeback
                test_set_page_writeback
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.10%          tar  [kernel.kallsyms]  [k] system_call
                    |
                    --- system_call
                        __GI___libc_write

     0.10%  flush-253:2  [kernel.kallsyms]  [k] __bio_clone
            |
            --- __bio_clone
                clone_bio
                __split_and_process_bio
                dm_request
                generic_make_request
                submit_bio
                ext4_io_submit
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.10%  flush-253:2  [kernel.kallsyms]  [k] mod_state
            |
            --- mod_state
                inc_zone_page_state
                account_page_writeback
                test_set_page_writeback
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.10%          tar  [kernel.kallsyms]  [k] arch_local_irq_save
                    |
                    --- arch_local_irq_save
                        _raw_spin_lock_irqsave
                        __wake_up
                        jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.10%          tar  [kernel.kallsyms]  [k] bio_get_nr_vecs
                    |
                    --- bio_get_nr_vecs
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.10%  flush-253:2  [kernel.kallsyms]  [k] radix_tree_tag_set
            |
            --- radix_tree_tag_set
                test_set_page_writeback
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.10%          tar  [kernel.kallsyms]  [k] test_ti_thread_flag
                    |
                    --- test_ti_thread_flag
                        __mem_cgroup_try_charge.constprop.27
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.10%  flush-253:2  [kernel.kallsyms]  [k] bit_spin_lock
            |
            --- bit_spin_lock
                jbd2_journal_add_journal_head
                jbd2_journal_get_write_access
                __ext4_journal_get_write_access
                ext4_reserve_inode_write
                ext4_mark_inode_dirty
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.09%          tar  [kernel.kallsyms]  [k] inode_init_once
                    |
                    --- inode_init_once
                        init_once
                        setup_object
                        new_slab
                        __slab_alloc
                        kmem_cache_alloc
                        ext4_alloc_inode
                        alloc_inode
                        new_inode
                        ext4_new_inode
                        ext4_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.09%  jbd2/dm-2-8  [kernel.kallsyms]  [k] add_preempt_count
            |
            --- add_preempt_count
               |          
               |--61.31%-- _raw_spin_lock
               |          jbd2_journal_file_buffer
               |          jbd2_journal_write_metadata_buffer
               |          jbd2_journal_commit_transaction
               |          kjournald2
               |          kthread
               |          kernel_thread_helper
               |          
                --38.69%-- jbd_trylock_bh_state
                          journal_clean_one_cp_list
                          __jbd2_journal_clean_checkpoint_list
                          jbd2_journal_commit_transaction
                          kjournald2
                          kthread
                          kernel_thread_helper

     0.09%      swapper  [kernel.kallsyms]  [k] kobject_put
                |
                --- kobject_put
                    __scsi_put_command
                    scsi_put_command
                    scsi_next_command
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.09%  flush-253:2  [kernel.kallsyms]  [k] __elv_add_request
            |
            --- __elv_add_request
                __make_request
                generic_make_request
                submit_bio
                ext4_io_submit
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.09%      swapper  [kernel.kallsyms]  [k] arch_local_irq_restore
                |
                --- arch_local_irq_restore
                    rcu_process_gp_end
                    __rcu_process_callbacks
                    rcu_process_callbacks
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.09%          tar  [kernel.kallsyms]  [k] round_jiffies_up
                    |
                    --- round_jiffies_up
                        blk_start_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.09%          tar  [kernel.kallsyms]  [k] attach_page_buffers
                    |
                    --- attach_page_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.09%          tar  [kernel.kallsyms]  [k] hrtick_update
                    |
                    --- hrtick_update
                        dequeue_task
                        deactivate_task
                        schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.09%          tar  [kernel.kallsyms]  [k] ext4_clear_inode_flag
                    |
                    --- ext4_clear_inode_flag
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.09%  jbd2/dm-2-8  [kernel.kallsyms]  [k] do_raw_spin_lock
            |
            --- do_raw_spin_lock
                _raw_spin_lock_irq
                blk_throtl_bio
                generic_make_request
                submit_bio
                submit_bh
                jbd2_journal_commit_transaction
                kjournald2
                kthread
                kernel_thread_helper

     0.09%          top  [kernel.kallsyms]  [k] __rcu_read_lock
                    |
                    --- __rcu_read_lock
                        __d_lookup
                        walk_component
                        link_path_walk
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_open
                        system_call_fastpath
                        __GI___libc_open

     0.09%          tar  [kernel.kallsyms]  [k] __brelse
                    |
                    --- __brelse
                        brelse
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.09%  flush-253:2  [kernel.kallsyms]  [k] page_zone
            |
            --- page_zone
                inc_zone_page_state
                account_page_writeback
                test_set_page_writeback
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.09%          tar  [kernel.kallsyms]  [k] bio_integrity_enabled
                    |
                    --- bio_integrity_enabled
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.09%          tar  [kernel.kallsyms]  [k] dm_table_find_target
                    |
                    --- dm_table_find_target
                        __bio_add_page.part.2
                        bio_add_page
                        do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.09%          tar  [kernel.kallsyms]  [k] __mod_zone_page_state
                    |
                    --- __mod_zone_page_state
                        add_page_to_lru_list
                        ____pagevec_lru_add_fn
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.09%          tar  [kernel.kallsyms]  [k] ahci_fill_cmd_slot
                    |
                    --- ahci_fill_cmd_slot
                        ahci_qc_prep
                        ata_qc_issue
                        __ata_scsi_queuecmd
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.09%      swapper  [kernel.kallsyms]  [k] blk_unprep_request
                |
                --- blk_unprep_request
                    blk_finish_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.09%          top  libc-2.13.90.so    [.] __GI___close
                    |
                    --- __GI___close

     0.09%          tar  [kernel.kallsyms]  [k] put_bh
                    |
                    --- put_bh
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.09%      swapper  [kernel.kallsyms]  [k] finish_task_switch
                |
                --- finish_task_switch
                    schedule
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.09%  flush-253:2  [kernel.kallsyms]  [k] page_mapping
            |
            --- page_mapping
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.09%          tar  [kernel.kallsyms]  [k] alloc_tio
                    |
                    --- alloc_tio
                        dm_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.08%  flush-253:2  [kernel.kallsyms]  [k] radix_tree_tag_clear
            |
            --- radix_tree_tag_clear
                test_set_page_writeback
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.08%          tar  [kernel.kallsyms]  [k] timespec_trunc
                    |
                    --- timespec_trunc
                        touch_atime
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.08%          tar  [kernel.kallsyms]  [k] ext4_claim_free_blocks
                    |
                    --- ext4_claim_free_blocks
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.08%          tar  libc-2.13.90.so    [.] __GI___errno_location
                    |
                    --- __GI___errno_location

     0.08%          tar  [kernel.kallsyms]  [k] path_to_nameidata
                    |
                    --- path_to_nameidata
                        walk_component
                        link_path_walk
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.08%          tar  [kernel.kallsyms]  [k] current_sid
                    |
                    --- current_sid
                        selinux_file_permission
                        security_file_permission
                        rw_verify_area
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.08%          top  [kernel.kallsyms]  [k] path_openat
                    |
                    --- path_openat
                        do_filp_open
                        do_sys_open
                        sys_open
                        system_call_fastpath
                        __GI___libc_open

     0.08%          tar  [kernel.kallsyms]  [k] __do_page_cache_readahead
                    |
                    --- __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.08%          tar  [kernel.kallsyms]  [k] _cond_resched
                    |
                    --- _cond_resched
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.08%      swapper  [kernel.kallsyms]  [k] run_timer_softirq
                |
                --- run_timer_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.08%      swapper  [kernel.kallsyms]  [k] note_interrupt
                |
                --- note_interrupt
                    handle_irq_event_percpu
                    handle_irq_event
                    handle_edge_irq
                    handle_irq
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.08%          tar  [kernel.kallsyms]  [k] arch_local_irq_restore
                    |
                    --- arch_local_irq_restore
                        account_page_dirtied
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.08%      swapper  [kernel.kallsyms]  [k] native_apic_mem_write
                |
                --- native_apic_mem_write
                    apic_write
                    ack_APIC_irq
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    start_secondary

     0.08%          tar  [kernel.kallsyms]  [k] bio_data
                    |
                    --- bio_data
                        init_request_from_bio
                        __make_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.08%          tar  [kernel.kallsyms]  [k] string_to_context_struct
                    |
                    --- string_to_context_struct
                        security_context_to_sid_core
                        security_context_to_sid_default
                        inode_doinit_with_dentry
                        selinux_d_instantiate
                        security_d_instantiate
                        d_instantiate
                        d_splice_alias
                        ext4_lookup
                        d_alloc_and_lookup
                        __lookup_hash.part.3
                        lookup_hash
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.08%          tar  [kernel.kallsyms]  [k] mb_clear_bit
                    |
                    --- mb_clear_bit
                        mb_clear_bits
                        ext4_free_blocks
                        ext4_ext_truncate
                        ext4_truncate
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.08%          tar  [kernel.kallsyms]  [k] ext4_mb_load_buddy
                    |
                    --- ext4_mb_load_buddy
                        ext4_free_blocks
                        ext4_ext_truncate
                        ext4_truncate
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.08%          top  [kernel.kallsyms]  [k] __fsnotify_parent
                    |
                    --- __fsnotify_parent
                        fsnotify_perm
                        security_file_permission
                        rw_verify_area
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.08%        sleep  [kernel.kallsyms]  [k] do_raw_spin_lock
                   |
                   --- do_raw_spin_lock
                       _raw_spin_lock
                      |          
                      |--60.83%-- __do_fault
                      |          handle_pte_fault
                      |          handle_mm_fault
                      |          do_page_fault
                      |          page_fault
                      |          0x37d9082b80
                      |          
                       --39.17%-- deny_write_access
                                 mmap_region
                                 do_mmap_pgoff
                                 do_mmap
                                 elf_map
                                 load_elf_binary
                                 search_binary_handler
                                 do_execve
                                 sys_execve
                                 stub_execve
                                 0x37d90ae097

     0.08%      swapper  [kernel.kallsyms]  [k] ahci_interrupt
                |
                --- ahci_interrupt
                    handle_irq_event_percpu
                    handle_irq_event
                    handle_edge_irq
                    handle_irq
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.08%          tar  [kernel.kallsyms]  [k] __srcu_read_unlock
                    |
                    --- __srcu_read_unlock
                        fsnotify_modify
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.08%          tar  [kernel.kallsyms]  [k] signal_pending
                    |
                    --- signal_pending
                        fatal_signal_pending
                        __mem_cgroup_try_charge.constprop.27
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.08%          tar  [kernel.kallsyms]  [k] __read_seqcount_begin
                    |
                    --- __read_seqcount_begin
                        path_init
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.08%          tar  [kernel.kallsyms]  [k] test_ti_thread_flag
                    |
                    --- test_ti_thread_flag
                        mnt_clone_write
                        mnt_want_write_file
                        file_update_time
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.08%          tar  [kernel.kallsyms]  [k] jbd2_journal_start
                    |
                    --- jbd2_journal_start
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%          tar  [kernel.kallsyms]  [k] __srcu_read_lock
                    |
                    --- __srcu_read_lock
                        fsnotify
                        fsnotify_modify
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%      swapper  [kernel.kallsyms]  [k] handle_irq
                |
                --- handle_irq
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.07%      swapper  [kernel.kallsyms]  [k] __ata_scsi_queuecmd
                |
                --- __ata_scsi_queuecmd
                    scsi_dispatch_cmd
                    scsi_request_fn
                    __blk_run_queue
                    blk_run_queue
                    scsi_run_queue
                    scsi_next_command
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.07%          tar  [kernel.kallsyms]  [k] atomic_inc
                    |
                    --- atomic_inc
                        drive_stat_acct
                        __make_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] __switch_to
                    |
                    --- __switch_to
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] ext4_file_write
                    |
                    --- ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%      swapper  [kernel.kallsyms]  [k] wake_bit_function
                |
                --- wake_bit_function
                    __wake_up
                    __wake_up_bit
                    unlock_page
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.07%          tar  [kernel.kallsyms]  [k] _raw_spin_lock_irq
                    |
                    --- _raw_spin_lock_irq
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%          tar  [kernel.kallsyms]  [k] drive_stat_acct
                    |
                    --- drive_stat_acct
                        __make_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] test_ti_thread_flag.constprop.22
                    |
                    --- test_ti_thread_flag.constprop.22
                        zero_user_segments
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%          tar  [kernel.kallsyms]  [k] sd_prep_fn
                    |
                    --- sd_prep_fn
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          top  libc-2.13.90.so    [.] __strchrnul
                    |
                    --- __strchrnul
                        ___vsnprintf_chk
                        0x39335b1b6d5b1b42

     0.07%      swapper  [kernel.kallsyms]  [k] sd_prep_fn
                |
                --- sd_prep_fn
                    blk_peek_request
                    scsi_request_fn
                    __blk_run_queue
                    blk_run_queue
                    scsi_run_queue
                    scsi_next_command
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.07%          tar  [kernel.kallsyms]  [k] try_to_wake_up
                    |
                    --- try_to_wake_up
                        wake_up_process
                        wake_up_worker
                        insert_work
                        __queue_work
                        delayed_work_timer_fn
                        run_timer_softirq
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        _raw_spin_unlock_irqrestore
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] __bio_clone
                    |
                    --- __bio_clone
                        clone_bio
                        __split_and_process_bio
                        dm_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] __zone_watermark_ok
                    |
                    --- __zone_watermark_ok
                        zone_watermark_ok
                        get_page_from_freelist
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%      swapper  [kernel.kallsyms]  [k] __remove_hrtimer
                |
                --- __remove_hrtimer
                    remove_hrtimer.part.4
                    hrtimer_try_to_cancel
                    hrtimer_cancel
                    tick_nohz_restart_sched_tick
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.07%      swapper  [kernel.kallsyms]  [k] scsi_device_unbusy
                |
                --- scsi_device_unbusy
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.07%          tar  [kernel.kallsyms]  [k] scsi_prep_return
                    |
                    --- scsi_prep_return
                        sd_prep_fn
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] prepare_to_wait_exclusive
                    |
                    --- prepare_to_wait_exclusive
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] set_buffer_uptodate
                    |
                    --- set_buffer_uptodate
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%          tar  [kernel.kallsyms]  [k] ata_get_xlat_func
                    |
                    --- ata_get_xlat_func
                        __ata_scsi_queuecmd
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] __find_get_block_slow
                    |
                    --- __find_get_block_slow
                        __find_get_block
                        ext4_free_blocks
                        ext4_ext_truncate
                        ext4_truncate
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.07%          tar  [kernel.kallsyms]  [k] generic_getxattr
                    |
                    --- generic_getxattr
                        security_inode_need_killpriv
                        file_remove_suid
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%      swapper  [kernel.kallsyms]  [k] bit_spin_lock.constprop.22
                |
                --- bit_spin_lock.constprop.22
                    __slab_free
                    kmem_cache_free
                    put_io_page
                    ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.07%      swapper  [kernel.kallsyms]  [k] is_swiotlb_buffer
                |
                --- is_swiotlb_buffer
                    unmap_single
                    swiotlb_unmap_sg_attrs
                    ata_sg_clean
                    __ata_qc_complete
                    ata_qc_complete
                    ata_qc_complete_multiple
                    ahci_interrupt
                    handle_irq_event_percpu
                    handle_irq_event
                    handle_edge_irq
                    handle_irq
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.07%          tar  [kernel.kallsyms]  [k] native_read_tsc
                    |
                    --- native_read_tsc
                        paravirt_read_tsc
                        native_sched_clock
                        sched_clock
                        blk_rq_init
                        get_request
                        get_request_wait
                        __make_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] ext4_has_free_blocks
                    |
                    --- ext4_has_free_blocks
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%          tar  libc-2.13.90.so    [.] __GI___fxstat64
                    |
                    --- __GI___fxstat64

     0.07%      swapper  [kernel.kallsyms]  [k] perf_pmu_disable
                |
                --- perf_pmu_disable
                    scheduler_tick
                    update_process_times
                    tick_sched_timer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.07%          tar  [kernel.kallsyms]  [k] sidtab_context_to_sid
                    |
                    --- sidtab_context_to_sid
                        security_context_to_sid_core
                        security_context_to_sid_default
                        inode_doinit_with_dentry
                        selinux_d_instantiate
                        security_d_instantiate
                        d_instantiate
                        d_splice_alias
                        ext4_lookup
                        d_alloc_and_lookup
                        __lookup_hash.part.3
                        lookup_hash
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.07%          tar  [kernel.kallsyms]  [k] scsi_pool_alloc_command
                    |
                    --- scsi_pool_alloc_command
                        scsi_host_alloc_command
                        __scsi_get_command
                        scsi_get_command
                        scsi_get_cmd_from_req
                        scsi_setup_fs_cmnd
                        sd_prep_fn
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] list_del
                    |
                    --- list_del
                        activate_page
                        mark_page_accessed
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%          tar  [kernel.kallsyms]  [k] pagefault_enable
                    |
                    --- pagefault_enable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] security_file_permission
                    |
                    --- security_file_permission
                        rw_verify_area
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%      swapper  [kernel.kallsyms]  [k] scsi_next_command
                |
                --- scsi_next_command
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.07%          tar  [kernel.kallsyms]  [k] __phys_addr
                    |
                    --- __phys_addr
                        virt_to_head_page
                        kmem_cache_free
                        jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%          tar  [kernel.kallsyms]  [k] page_cache_async_readahead
                    |
                    --- page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.07%          tar  [kernel.kallsyms]  [k] truncate_inode_pages_range
                    |
                    --- truncate_inode_pages_range
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.07%          tar  [kernel.kallsyms]  [k] mem_cgroup_del_lru_list
                    |
                    --- mem_cgroup_del_lru_list
                        activate_page
                        mark_page_accessed
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%          tar  [kernel.kallsyms]  [k] ext4_xattr_check_names
                    |
                    --- ext4_xattr_check_names
                        ext4_xattr_get
                        ext4_xattr_security_get
                        generic_getxattr
                        cap_inode_need_killpriv
                        security_inode_need_killpriv
                        file_remove_suid
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%          tar  [kernel.kallsyms]  [k] arch_local_irq_enable
                    |
                    --- arch_local_irq_enable
                        __find_get_block
                        __getblk
                        __ext4_get_inode_loc
                        ext4_get_inode_loc
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.07%          tar  [kernel.kallsyms]  [k] get_request
                    |
                    --- get_request
                        get_request_wait
                        __make_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%          tar  [kernel.kallsyms]  [k] swiotlb_map_sg_attrs
                    |
                    --- swiotlb_map_sg_attrs
                        ata_qc_issue
                        __ata_scsi_queuecmd
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%          tar  [kernel.kallsyms]  [k] dm_get_live_table
                    |
                    --- dm_get_live_table
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%          tar  [kernel.kallsyms]  [k] mem_cgroup_get_reclaim_stat_from_page
                    |
                    --- mem_cgroup_get_reclaim_stat_from_page
                        update_page_reclaim_stat
                        ____pagevec_lru_add_fn
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%      swapper  [kernel.kallsyms]  [k] check_preempt_curr
                |
                --- check_preempt_curr
                    ttwu_post_activation
                    try_to_wake_up
                    default_wake_function
                    autoremove_wake_function
                    wake_bit_function
                    __wake_up_common
                    __wake_up
                    __wake_up_bit
                    unlock_page
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%          tar  [kernel.kallsyms]  [k] atomic_long_add
                    |
                    --- atomic_long_add
                        zone_page_state_add
                        __mod_zone_page_state
                        add_page_to_lru_list
                        ____pagevec_lru_add_fn
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%      swapper  [kernel.kallsyms]  [k] pm_qos_request
                |
                --- pm_qos_request
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%          tar  [kernel.kallsyms]  [k] __kmalloc
                    |
                    --- __kmalloc
                        kzalloc.constprop.9
                        ext4_ext_find_extent
                        ext4_ext_map_blocks
                        ext4_map_blocks
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%      swapper  [kernel.kallsyms]  [k] rcu_bh_qs
                |
                --- rcu_bh_qs
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%      swapper  [kernel.kallsyms]  [k] __blk_complete_request
                |
                --- __blk_complete_request
                    scsi_done
                    ata_scsi_qc_complete
                    __ata_qc_complete
                    ata_qc_complete
                    ata_qc_complete_multiple
                    ahci_interrupt
                    handle_irq_event_percpu
                    handle_irq_event
                    handle_edge_irq
                    handle_irq
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%          tar  [kernel.kallsyms]  [k] __d_lookup
                    |
                    --- __d_lookup
                        walk_component
                        link_path_walk
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.06%          tar  [kernel.kallsyms]  [k] context_struct_to_string
                    |
                    --- context_struct_to_string
                        security_sid_to_context_core
                        security_sid_to_context_force
                        selinux_inode_init_security
                        security_inode_init_security
                        ext4_init_security
                        ext4_new_inode
                        ext4_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.06%      swapper  [kernel.kallsyms]  [k] tick_nohz_restart_sched_tick
                |
                --- tick_nohz_restart_sched_tick
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%          tar  [kernel.kallsyms]  [k] max_sane_readahead
                    |
                    --- max_sane_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%          tar  [kernel.kallsyms]  [k] rw_verify_area
                    |
                    --- rw_verify_area
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%          tar  [kernel.kallsyms]  [k] ahci_qc_prep
                    |
                    --- ahci_qc_prep
                        ata_qc_issue
                        __ata_scsi_queuecmd
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%          tar  [kernel.kallsyms]  [k] linear_map
                    |
                    --- linear_map
                        __split_and_process_bio
                        dm_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%      swapper  [kernel.kallsyms]  [k] sched_clock
                |
                --- sched_clock
                    account_system_vtime
                    irq_enter
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%          tar  [kernel.kallsyms]  [k] fput_light
                    |
                    --- fput_light
                        system_call_fastpath
                        __GI___libc_write

     0.06%          tar  [kernel.kallsyms]  [k] iov_iter_advance
                    |
                    --- iov_iter_advance
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%          tar  [kernel.kallsyms]  [k] __queue_work
                    |
                    --- __queue_work
                        delayed_work_timer_fn
                        run_timer_softirq
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        lock_page_cgroup
                        __mem_cgroup_commit_charge.constprop.28
                        __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%      swapper  [kernel.kallsyms]  [k] scsi_io_completion
                |
                --- scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%          tar  [kernel.kallsyms]  [k] activate_page
                    |
                    --- activate_page
                        mark_page_accessed
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%          tar  [kernel.kallsyms]  [k] touch_atime
                    |
                    --- touch_atime
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%          tar  [kernel.kallsyms]  [k] atomic_sub
                    |
                    --- atomic_sub
                        jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%          tar  [kernel.kallsyms]  [k] __inc_zone_page_state
                    |
                    --- __inc_zone_page_state
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%          tar  [kernel.kallsyms]  [k] ext4_test_inode_state
                    |
                    --- ext4_test_inode_state
                        ext4_get_inode_loc
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%          tar  [kernel.kallsyms]  [k] ext4_xattr_find_entry
                    |
                    --- ext4_xattr_find_entry
                        ext4_xattr_get
                        ext4_xattr_security_get
                        generic_getxattr
                        cap_inode_need_killpriv
                        security_inode_need_killpriv
                        file_remove_suid
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%      swapper  [kernel.kallsyms]  [k] deadline_dispatch_requests
                |
                --- deadline_dispatch_requests
                    blk_peek_request
                    scsi_request_fn
                    __blk_run_queue
                    blk_run_queue
                    scsi_run_queue
                    scsi_next_command
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%      swapper  [kernel.kallsyms]  [k] hrtick_update
                |
                --- hrtick_update
                    enqueue_task_fair
                    enqueue_task
                    activate_task
                    try_to_wake_up
                    default_wake_function
                    autoremove_wake_function
                    wake_bit_function
                    __wake_up_common
                    __wake_up
                    __wake_up_bit
                    unlock_page
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%      swapper  [kernel.kallsyms]  [k] try_to_wake_up
                |
                --- try_to_wake_up
                    default_wake_function
                    autoremove_wake_function
                    wake_bit_function
                    __wake_up_common
                    __wake_up
                    __wake_up_bit
                    unlock_page
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%      swapper  [kernel.kallsyms]  [k] pick_next_task_fair
                |
                --- pick_next_task_fair
                    schedule
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%          tar  [kernel.kallsyms]  [k] pick_next_task_idle
                    |
                    --- pick_next_task_idle
                        schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%      swapper  [kernel.kallsyms]  [k] ktime_get
                |
                --- ktime_get
                    tick_check_idle
                    irq_enter
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%          tar  [kernel.kallsyms]  [k] balance_dirty_pages_ratelimited_nr
                    |
                    --- balance_dirty_pages_ratelimited_nr
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%      swapper  [kernel.kallsyms]  [k] mpage_end_io
                |
                --- mpage_end_io
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.06%          tar  [kernel.kallsyms]  [k] radix_tree_preload_end
                    |
                    --- radix_tree_preload_end
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.06%          tar  [kernel.kallsyms]  [k] submit_bio
                    |
                    --- submit_bio
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%          tar  [kernel.kallsyms]  [k] __ata_scsi_queuecmd
                    |
                    --- __ata_scsi_queuecmd
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%          tar  [kernel.kallsyms]  [k] dm_table_put
                    |
                    --- dm_table_put
                        dm_merge_bvec
                        __bio_add_page.part.2
                        bio_add_page
                        do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.06%        sleep  [kernel.kallsyms]  [k] __ext4_journal_get_write_access
                   |
                   --- __ext4_journal_get_write_access
                       ext4_reserve_inode_write
                       ext4_mark_inode_dirty
                       ext4_dirty_inode
                       __mark_inode_dirty
                       touch_atime
                       ext4_file_mmap
                       mmap_region
                       do_mmap_pgoff
                       sys_mmap_pgoff
                       sys_mmap
                       system_call_fastpath
                       __mmap
                       _nl_find_locale
                       __GI_setlocale
                       0x40124c

     0.05%          tar  [kernel.kallsyms]  [k] sysret_check
                    |
                    --- sysret_check
                        __GI___libc_read

     0.05%      swapper  [kernel.kallsyms]  [k] clockevents_program_event
                |
                --- clockevents_program_event
                    tick_dev_program_event
                    tick_program_event
                    __hrtimer_start_range_ns
                    hrtimer_start_range_ns
                    hrtimer_start_expires.constprop.1
                    tick_nohz_restart_sched_tick
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.05%          tar  [kernel.kallsyms]  [k] pick_next_task_rt
                    |
                    --- pick_next_task_rt
                        pick_next_task
                        schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.05%      swapper  [kernel.kallsyms]  [k] account_entity_enqueue
                |
                --- account_entity_enqueue
                    enqueue_task
                    activate_task
                    try_to_wake_up
                    default_wake_function
                    autoremove_wake_function
                    wake_bit_function
                    __wake_up_common
                    __wake_up
                    __wake_up_bit
                    unlock_page
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.05%          tar  [kernel.kallsyms]  [k] need_resched
                    |
                    --- need_resched
                        _cond_resched
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.05%          tar  [kernel.kallsyms]  [k] find_lock_page
                    |
                    --- find_lock_page
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.05%          tar  [kernel.kallsyms]  [k] memcmp
                    |
                    --- memcmp
                        search_dirblock
                        ext4_dx_find_entry
                        ext4_find_entry
                        ext4_unlink
                        vfs_unlink
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.05%          tar  [kernel.kallsyms]  [k] generic_segment_checks
                    |
                    --- generic_segment_checks
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.05%          tar  [kernel.kallsyms]  [k] update_vsyscall
                    |
                    --- update_vsyscall
                        do_timer
                        tick_do_update_jiffies64
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        _raw_spin_lock
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.05%      swapper  [kernel.kallsyms]  [k] hrtimer_start_expires.constprop.1
                |
                --- hrtimer_start_expires.constprop.1
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.05%          tar  [kernel.kallsyms]  [k] __page_cache_alloc
                    |
                    --- __page_cache_alloc
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.05%          tar  [kernel.kallsyms]  [k] avc_has_perm_noaudit
                    |
                    --- avc_has_perm_noaudit
                        avc_has_perm
                        inode_has_perm
                        selinux_inode_permission
                        security_inode_exec_permission
                        exec_permission
                        link_path_walk
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.05%          tar  [kernel.kallsyms]  [k] deactivate_slab
                    |
                    --- deactivate_slab
                        __slab_alloc
                        kmem_cache_alloc
                        alloc_buffer_head
                        alloc_page_buffers
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.05%      swapper  [kernel.kallsyms]  [k] bio_free
                |
                --- bio_free
                    bio_fs_destructor
                    bio_put
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.05%          tar  libc-2.13.90.so    [.] __GI___libc_read
                    |
                    --- __GI___libc_read

     0.05%          tar  [kernel.kallsyms]  [k] selinux_capable
                    |
                    --- selinux_capable
                        ns_capable
                        capable
                        inode_change_ok
                        ext4_setattr
                        notify_change
                        chown_common
                        sys_fchown
                        system_call_fastpath
                        __GI___fchown

     0.05%          tar  [kernel.kallsyms]  [k] _raw_read_lock_irqsave
                    |
                    --- _raw_read_lock_irqsave
                        dm_get_live_table
                        dm_merge_bvec
                        __bio_add_page.part.2
                        bio_add_page
                        do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.05%      swapper  [kernel.kallsyms]  [k] scsi_handle_queue_ramp_up
                |
                --- scsi_handle_queue_ramp_up
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.05%          tar  [kernel.kallsyms]  [k] dm_table_any_congested
                    |
                    --- dm_table_any_congested
                        dm_any_congested
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.05%          tar  [kernel.kallsyms]  [k] __wake_up_common
                    |
                    --- __wake_up_common
                        __wake_up
                        jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.05%          tar  [kernel.kallsyms]  [k] acct_update_integrals
                    |
                    --- acct_update_integrals
                        __account_system_time
                        irqtime_account_process_tick
                        account_process_tick
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        blk_finish_plug
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.05%      swapper  [kernel.kallsyms]  [k] ns_to_timespec
                |
                --- ns_to_timespec
                    intel_idle
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.05%          tar  [kernel.kallsyms]  [k] _raw_read_unlock_irqrestore
                    |
                    --- _raw_read_unlock_irqrestore
                        dm_get_live_table
                        dm_merge_bvec
                        __bio_add_page.part.2
                        bio_add_page
                        do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.05%          tar  [kernel.kallsyms]  [k] __add_bdi_stat
                    |
                    --- __add_bdi_stat
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.05%          tar  [kernel.kallsyms]  [k] sg_init_table
                    |
                    --- sg_init_table
                        scsi_alloc_sgtable
                        scsi_init_sgtable
                        scsi_init_io
                        scsi_setup_fs_cmnd
                        sd_prep_fn
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.05%      swapper  [kernel.kallsyms]  [k] getnstimeofday
                |
                --- getnstimeofday
                    ktime_get_real
                    intel_idle
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.04%          tar  [kernel.kallsyms]  [k] get_page
                    |
                    --- get_page
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.04%          tar  [kernel.kallsyms]  [k] timekeeping_get_ns
                    |
                    --- timekeeping_get_ns
                        delayacct_end
                        __delayacct_blkio_end
                        delayacct_blkio_end
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.04%          tar  [kernel.kallsyms]  [k] trylock_page
                    |
                    --- trylock_page
                        lock_page
                        find_lock_page
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.04%      swapper  [kernel.kallsyms]  [k] native_sched_clock
                |
                --- native_sched_clock
                    sched_clock_cpu
                    account_system_vtime
                    irq_exit
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    start_secondary

     0.04%          tar  [kernel.kallsyms]  [k] native_load_tls
                    |
                    --- native_load_tls
                        __GI___libc_read

     0.04%          tar  [kernel.kallsyms]  [k] files_lglock_local_unlock_cpu
                    |
                    --- files_lglock_local_unlock_cpu
                        file_sb_list_del
                        fput
                        filp_close
                        sys_close
                        system_call_fastpath
                        __GI___close

     0.04%          tar  [kernel.kallsyms]  [k] release_pages
                    |
                    --- release_pages
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.04%  jbd2/dm-2-8  [kernel.kallsyms]  [k] bit_spin_lock.constprop.22
            |
            --- bit_spin_lock.constprop.22
                __slab_free
                kmem_cache_free
                __journal_remove_journal_head
                jbd2_journal_remove_journal_head
                journal_clean_one_cp_list
                __jbd2_journal_clean_checkpoint_list
                jbd2_journal_commit_transaction
                kjournald2
                kthread
                kernel_thread_helper

     0.04%          tar  [kernel.kallsyms]  [k] pick_next_task_fair
                    |
                    --- pick_next_task_fair
                        schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.04%      swapper  [kernel.kallsyms]  [k] ktime_get_real
                |
                --- ktime_get_real
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.04%          tar  [kernel.kallsyms]  [k] tick_do_update_jiffies64
                    |
                    --- tick_do_update_jiffies64
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.03%      swapper  [kernel.kallsyms]  [k] arch_local_save_flags
                |
                --- arch_local_save_flags
                    arch_local_irq_save
                    irqtime_account_process_tick
                    account_idle_ticks
                    tick_nohz_restart_sched_tick
                    cpu_idle
                    start_secondary

     0.03%        sleep  [kernel.kallsyms]  [k] mem_cgroup_uncharge_start
                   |
                   --- mem_cgroup_uncharge_start
                       exit_mmap
                       mmput
                       flush_old_exec
                       load_elf_binary
                       search_binary_handler
                       do_execve
                       sys_execve
                       stub_execve
                       __execve

     0.02%      swapper  [kernel.kallsyms]  [k] irq_enter
                |
                --- irq_enter
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    start_secondary



#
# (For a higher level overview, try: perf report --sort comm,dso)
#


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
