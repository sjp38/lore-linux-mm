Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 650CC8D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 08:27:25 -0400 (EDT)
Message-ID: <4D9EFF29.9030106@openvz.org>
Date: Fri, 8 Apr 2011 16:27:21 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] tmpfs: fix race between umount and writepage
References: <20110405103452.18737.28363.stgit@localhost6>
In-Reply-To: <20110405103452.18737.28363.stgit@localhost6>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Bug is easily reproduced by this script:

for i in {1..300} ; do
	mkdir $i
	while true ; do
		mount -t tmpfs none $i
		dd if=/dev/zero of=$i/test bs=1M count=$(($RANDOM % 100)) status=noxfer
		umount $i
	done &
done

At 6xCPU node with 8Gb RAM. Kernel is very unstable after this accident. =)
Kernel with this patch is working fine for at least an hour.

Kernel log:

[  584.544461] VFS: Busy inodes after unmount of tmpfs. Self-destruct in 5 seconds.  Have a nice day...
[  585.409221] ------------[ cut here ]------------
[  585.409268] WARNING: at lib/list_debug.c:53 __list_del_entry+0x8d/0x98()
[  585.409331] Hardware name: System Product Name
[  585.409372] list_del corruption. prev->next should be ffff880222fdaac8, but was           (null)
[  585.409928] Modules linked in: [last unloaded: scsi_wait_scan]
[  585.410279] Pid: 11222, comm: mount.tmpfs Not tainted 2.6.39-rc2+ #4
[  585.410540] Call Trace:
[  585.410819]  [<ffffffff8103b710>] warn_slowpath_common+0x80/0x98
[  585.411113]  [<ffffffff8103b7bc>] warn_slowpath_fmt+0x41/0x43
[  585.411377]  [<ffffffff81227145>] __list_del_entry+0x8d/0x98
[  585.411649]  [<ffffffff810f68af>] evict+0x50/0x113
[  585.411919]  [<ffffffff810f6ce6>] iput+0x138/0x141
[  585.412187]  [<ffffffff810bc2e7>] shmem_writepage+0x18b/0x1dc
[  585.412434]  [<ffffffff810b6f4a>] pageout+0x13c/0x24c
[  585.412677]  [<ffffffff810b7479>] shrink_page_list+0x28e/0x4be
[  585.412922]  [<ffffffff810b78c8>] shrink_inactive_list+0x21f/0x382
[  585.413173]  [<ffffffff810b7d85>] shrink_zone+0x35a/0x447
[  585.413417]  [<ffffffff810b7f50>] do_try_to_free_pages+0xde/0x3bc
[  585.413661]  [<ffffffff810b8373>] try_to_free_pages+0x9d/0xe2
[  585.413906]  [<ffffffff810b091a>] __alloc_pages_nodemask+0x45a/0x72b
[  585.414157]  [<ffffffff810d9005>] alloc_pages_current+0xaa/0xcd
[  585.414402]  [<ffffffff81028745>] pte_alloc_one+0x15/0x38
[  585.414647]  [<ffffffff810c4480>] __pte_alloc+0x1b/0xa0
[  585.414890]  [<ffffffff810c6dcf>] handle_mm_fault+0x11c/0x173
[  585.415138]  [<ffffffff81591cd1>] do_page_fault+0x348/0x36a
[  585.415383]  [<ffffffff8158f35f>] page_fault+0x1f/0x30
[  585.415627]  [<ffffffff812231ed>] ? __put_user_4+0x1d/0x30
[  585.415869]  [<ffffffff81038fb1>] ? schedule_tail+0x5c/0x60
[  585.416117]  [<ffffffff81595003>] ret_from_fork+0x13/0x80
[  585.416428] ---[ end trace 39cf2c656ee772fe ]---
[  585.416690] BUG: unable to handle kernel paging request at ffffffffffffffff
[  585.417001] IP: [<ffffffff810b946a>] shmem_free_blocks+0x18/0x4c
[  585.417001] PGD 1805067 PUD 1806067 PMD 0
[  585.417001] Oops: 0000 [#1] SMP
[  585.417839] last sysfs file: /sys/kernel/kexec_crash_size
[  585.418156] CPU 1
[  585.418156] Modules linked in: [last unloaded: scsi_wait_scan]
[  585.418851]
[  585.418851] Pid: 10422, comm: dd Tainted: G        W   2.6.39-rc2+ #4 System manufacturer System Product Name/Crosshair IV Formula
[  585.419541] RIP: 0010:[<ffffffff810b946a>]  [<ffffffff810b946a>] shmem_free_blocks+0x18/0x4c
[  585.419857] RSP: 0018:ffff880163e9f4b8  EFLAGS: 00010206
[  585.419857] RAX: ffff88021b513400 RBX: ffff880222fdaa40 RCX: 0000000000000020
[  585.419857] RDX: ffffffffffffffe0 RSI: 000000000000000e RDI: ffffffffffffffff
[  585.419857] RBP: ffff880163e9f4c8 R08: ffffea000653b090 R09: 0000000000014df0
[  585.419857] R10: 0000000000000028 R11: 000000000000002a R12: 000000000000000e
[  585.419857] R13: 000000000003cc76 R14: ffff880222fda970 R15: ffff880202b5d588
[  585.419857] FS:  00007f1c5b0cb700(0000) GS:ffff88024fc40000(0000) knlGS:0000000000000000
[  585.419857] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  585.419857] CR2: ffffffffffffffff CR3: 0000000187431000 CR4: 00000000000006e0
[  585.419857] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  585.419857] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  585.419857] Process dd (pid: 10422, threadinfo ffff880163e9e000, task ffff880098f65700)
[  585.419857] Stack:
[  585.419857]  ffff880222fdaa40 000000000000000e ffff880163e9f4e8 ffffffff810bac88
[  585.419857]  ffff880222fdaa40 ffffea000653b068 ffff880163e9f538 ffffffff810bc216
[  585.419857]  0000000000000000 ffff880163e9f548 0000000000000000 ffffea000653b068
[  585.419857] Call Trace:
[  585.419857]  [<ffffffff810bac88>] shmem_recalc_inode+0x61/0x66
[  585.419857]  [<ffffffff810bc216>] shmem_writepage+0xba/0x1dc
[  585.419857]  [<ffffffff810b6f4a>] pageout+0x13c/0x24c
[  585.419857]  [<ffffffff810b7479>] shrink_page_list+0x28e/0x4be
[  585.419857]  [<ffffffff810b78c8>] shrink_inactive_list+0x21f/0x382
[  585.419857]  [<ffffffff810b7d85>] shrink_zone+0x35a/0x447
[  585.419857]  [<ffffffff810b7f50>] do_try_to_free_pages+0xde/0x3bc
[  585.419857]  [<ffffffff810b8373>] try_to_free_pages+0x9d/0xe2
[  585.419857]  [<ffffffff810b091a>] __alloc_pages_nodemask+0x45a/0x72b
[  585.419857]  [<ffffffff810d9594>] alloc_pages_vma+0x117/0x133
[  585.419857]  [<ffffffff810b9448>] shmem_alloc_page+0x50/0x5a
[  585.419857]  [<ffffffff810317bf>] ? __dequeue_entity+0x2e/0x33
[  585.419857]  [<ffffffff810317e7>] ? set_next_entity+0x23/0x73
[  585.419857]  [<ffffffff810aa496>] ? find_get_page+0x23/0x69
[  585.419857]  [<ffffffff810aba4f>] ? find_lock_page+0x1e/0x5b
[  585.419857]  [<ffffffff810bad90>] shmem_getpage+0x103/0x644
[  585.419857]  [<ffffffff810bb35a>] shmem_write_begin+0x28/0x2a
[  585.419857]  [<ffffffff810a9cd0>] generic_file_buffered_write+0x100/0x24e
[  585.419857]  [<ffffffff810aaf2e>] __generic_file_aio_write+0x23a/0x26f
[  585.419857]  [<ffffffff810b5d41>] ? page_evictable+0x12/0x7d
[  585.419857]  [<ffffffff810b32c2>] ? lru_cache_add_lru+0x50/0x5e
[  585.419857]  [<ffffffff810aafc1>] generic_file_aio_write+0x5e/0xb3
[  585.419857]  [<ffffffff810e32c8>] do_sync_write+0xc6/0x103
[  585.419857]  [<ffffffff811e1a44>] ? security_file_permission+0x29/0x2e
[  585.419857]  [<ffffffff810e3c58>] vfs_write+0xa9/0x105
[  585.419857]  [<ffffffff810e3d6d>] sys_write+0x45/0x6c
[  585.419857]  [<ffffffff815950fb>] system_call_fastpath+0x16/0x1b
[  585.419857] Code: 88 e8 00 00 e8 35 00 02 00 48 81 c4 c8 00 00 00 5b c9 c3 55 48 89 e5 41 54 49 89 f4 53 48 8b 47 18 48 89 fb 48 8b b8 88 02 00 00
[  585.419857]  83 3f 00 74 29 8b 15 ba 8a 81 00 48 f7 de 48 83 c7 08 49 c1
[  585.419857] RIP  [<ffffffff810b946a>] shmem_free_blocks+0x18/0x4c
[  585.419857]  RSP <ffff880163e9f4b8>
[  585.419857] CR2: ffffffffffffffff
[  585.419857] ---[ end trace 39cf2c656ee772ff ]---
[  585.419857] ------------[ cut here ]------------
[  585.419857] WARNING: at kernel/exit.c:911 do_exit+0x71/0x794()
[  585.419857] Hardware name: System Product Name
[  585.419857] Modules linked in: [last unloaded: scsi_wait_scan]
[  585.419857] Pid: 10422, comm: dd Tainted: G      D W   2.6.39-rc2+ #4
[  585.419857] Call Trace:
[  585.419857]  [<ffffffff8103b710>] warn_slowpath_common+0x80/0x98
[  585.419857]  [<ffffffff8103b73d>] warn_slowpath_null+0x15/0x17
[  585.419857]  [<ffffffff8103ec3c>] do_exit+0x71/0x794
[  585.419857]  [<ffffffff8103bbf6>] ? kmsg_dump+0x44/0xea
[  585.419857]  [<ffffffff8158fde9>] oops_end+0xb1/0xb9
[  585.419857]  [<ffffffff810256f9>] no_context+0x1f7/0x206
[  585.419857]  [<ffffffff8102588a>] __bad_area_nosemaphore+0x182/0x1a5
[  585.419857]  [<ffffffff810258bb>] bad_area_nosemaphore+0xe/0x10
[  585.419857]  [<ffffffff81591b33>] do_page_fault+0x1aa/0x36a
[  585.419857]  [<ffffffff8120ab4a>] ? drive_stat_acct+0x105/0x140
[  585.419857]  [<ffffffff8120c3d5>] ? __make_request+0x23a/0x27c
[  585.419857]  [<ffffffff8120b007>] ? generic_make_request+0x2b6/0x31f
[  585.419857]  [<ffffffff8158f35f>] page_fault+0x1f/0x30
[  585.419857]  [<ffffffff810b946a>] ? shmem_free_blocks+0x18/0x4c
[  585.419857]  [<ffffffff810bac88>] shmem_recalc_inode+0x61/0x66
[  585.419857]  [<ffffffff810bc216>] shmem_writepage+0xba/0x1dc
[  585.419857]  [<ffffffff810b6f4a>] pageout+0x13c/0x24c
[  585.419857]  [<ffffffff810b7479>] shrink_page_list+0x28e/0x4be
[  585.419857]  [<ffffffff810b78c8>] shrink_inactive_list+0x21f/0x382
[  585.419857]  [<ffffffff810b7d85>] shrink_zone+0x35a/0x447
[  585.419857]  [<ffffffff810b7f50>] do_try_to_free_pages+0xde/0x3bc
[  585.419857]  [<ffffffff810b8373>] try_to_free_pages+0x9d/0xe2
[  585.419857]  [<ffffffff810b091a>] __alloc_pages_nodemask+0x45a/0x72b
[  585.419857]  [<ffffffff810d9594>] alloc_pages_vma+0x117/0x133
[  585.419857]  [<ffffffff810b9448>] shmem_alloc_page+0x50/0x5a
[  585.419857]  [<ffffffff810317bf>] ? __dequeue_entity+0x2e/0x33
[  585.419857]  [<ffffffff810317e7>] ? set_next_entity+0x23/0x73
[  585.419857]  [<ffffffff810aa496>] ? find_get_page+0x23/0x69
[  585.419857]  [<ffffffff810aba4f>] ? find_lock_page+0x1e/0x5b
[  585.419857]  [<ffffffff810bad90>] shmem_getpage+0x103/0x644
[  585.419857]  [<ffffffff810bb35a>] shmem_write_begin+0x28/0x2a
[  585.419857]  [<ffffffff810a9cd0>] generic_file_buffered_write+0x100/0x24e
[  585.419857]  [<ffffffff810aaf2e>] __generic_file_aio_write+0x23a/0x26f
[  585.419857]  [<ffffffff810b5d41>] ? page_evictable+0x12/0x7d
[  585.419857]  [<ffffffff810b32c2>] ? lru_cache_add_lru+0x50/0x5e
[  585.419857]  [<ffffffff810aafc1>] generic_file_aio_write+0x5e/0xb3
[  585.419857]  [<ffffffff810e32c8>] do_sync_write+0xc6/0x103
[  585.419857]  [<ffffffff811e1a44>] ? security_file_permission+0x29/0x2e
[  585.419857]  [<ffffffff810e3c58>] vfs_write+0xa9/0x105
[  585.419857]  [<ffffffff810e3d6d>] sys_write+0x45/0x6c
[  585.419857]  [<ffffffff815950fb>] system_call_fastpath+0x16/0x1b
[  585.419857] ---[ end trace 39cf2c656ee77300 ]---
[  585.419857] note: dd[10422] exited with preempt_count 1
[  585.419857] BUG: scheduling while atomic: dd/10422/0x10000001
[  585.419857] Modules linked in: [last unloaded: scsi_wait_scan]
[  585.419857] Pid: 10422, comm: dd Tainted: G      D W   2.6.39-rc2+ #4
[  585.419857] Call Trace:
[  585.419857]  [<ffffffff81035c4d>] __schedule_bug+0x57/0x5c
[  585.419857]  [<ffffffff8158d4c6>] schedule+0x95/0x655
[  585.419857]  [<ffffffff8158d19e>] ? printk+0x3c/0x3e
[  585.419857]  [<ffffffff81038d64>] __cond_resched+0x25/0x30
[  585.419857]  [<ffffffff8158dccc>] _cond_resched+0x27/0x32
[  585.419857]  [<ffffffff8158e73b>] down_read+0x11/0x23
[  585.419857]  [<ffffffff8107169f>] acct_collect+0x3f/0x177
[  585.419857]  [<ffffffff8103edf8>] do_exit+0x22d/0x794
[  585.419857]  [<ffffffff8103bbf6>] ? kmsg_dump+0x44/0xea
[  585.419857]  [<ffffffff8158fde9>] oops_end+0xb1/0xb9
[  585.419857]  [<ffffffff810256f9>] no_context+0x1f7/0x206
[  585.419857]  [<ffffffff8102588a>] __bad_area_nosemaphore+0x182/0x1a5
[  585.419857]  [<ffffffff810258bb>] bad_area_nosemaphore+0xe/0x10
[  585.419857]  [<ffffffff81591b33>] do_page_fault+0x1aa/0x36a
[  585.419857]  [<ffffffff8120ab4a>] ? drive_stat_acct+0x105/0x140
[  585.419857]  [<ffffffff8120c3d5>] ? __make_request+0x23a/0x27c
[  585.419857]  [<ffffffff8120b007>] ? generic_make_request+0x2b6/0x31f
[  585.419857]  [<ffffffff8158f35f>] page_fault+0x1f/0x30
[  585.419857]  [<ffffffff810b946a>] ? shmem_free_blocks+0x18/0x4c
[  585.419857]  [<ffffffff810bac88>] shmem_recalc_inode+0x61/0x66
[  585.419857]  [<ffffffff810bc216>] shmem_writepage+0xba/0x1dc
[  585.419857]  [<ffffffff810b6f4a>] pageout+0x13c/0x24c
[  585.419857]  [<ffffffff810b7479>] shrink_page_list+0x28e/0x4be
[  585.419857]  [<ffffffff810b78c8>] shrink_inactive_list+0x21f/0x382
[  585.419857]  [<ffffffff810b7d85>] shrink_zone+0x35a/0x447
[  585.419857]  [<ffffffff810b7f50>] do_try_to_free_pages+0xde/0x3bc
[  585.419857]  [<ffffffff810b8373>] try_to_free_pages+0x9d/0xe2
[  585.419857]  [<ffffffff810b091a>] __alloc_pages_nodemask+0x45a/0x72b
[  585.419857]  [<ffffffff810d9594>] alloc_pages_vma+0x117/0x133
[  585.419857]  [<ffffffff810b9448>] shmem_alloc_page+0x50/0x5a
[  585.419857]  [<ffffffff810317bf>] ? __dequeue_entity+0x2e/0x33
[  585.419857]  [<ffffffff810317e7>] ? set_next_entity+0x23/0x73
[  585.419857]  [<ffffffff810aa496>] ? find_get_page+0x23/0x69
[  585.419857]  [<ffffffff810aba4f>] ? find_lock_page+0x1e/0x5b
[  585.419857]  [<ffffffff810bad90>] shmem_getpage+0x103/0x644
[  585.419857]  [<ffffffff810bb35a>] shmem_write_begin+0x28/0x2a
[  585.419857]  [<ffffffff810a9cd0>] generic_file_buffered_write+0x100/0x24e
[  585.419857]  [<ffffffff810aaf2e>] __generic_file_aio_write+0x23a/0x26f
[  585.419857]  [<ffffffff810b5d41>] ? page_evictable+0x12/0x7d
[  585.419857]  [<ffffffff810b32c2>] ? lru_cache_add_lru+0x50/0x5e
[  585.419857]  [<ffffffff810aafc1>] generic_file_aio_write+0x5e/0xb3
[  585.419857]  [<ffffffff810e32c8>] do_sync_write+0xc6/0x103
[  585.419857]  [<ffffffff811e1a44>] ? security_file_permission+0x29/0x2e
[  585.419857]  [<ffffffff810e3c58>] vfs_write+0xa9/0x105
[  585.419857]  [<ffffffff810e3d6d>] sys_write+0x45/0x6c
[  585.419857]  [<ffffffff815950fb>] system_call_fastpath+0x16/0x1b
[  585.468858] dd used greatest stack depth: 2360 bytes left
[  585.650873] VFS: Busy inodes after unmount of tmpfs. Self-destruct in 5 seconds.  Have a nice day...
[  585.940034] VFS: Busy inodes after unmount of tmpfs. Self-destruct in 5 seconds.  Have a nice day...
[  586.336870] VFS: Busy inodes after unmount of tmpfs. Self-destruct in 5 seconds.  Have a nice day...

Konstantin Khlebnikov wrote:
> shmem_writepage() call igrab() on the inode for the page which is came from
> reclaimer to add it later into shmem_swaplist for swap-unuse operation.
>
> This igrab() can race with super-block deactivating process:
>
> shrink_inactive_list()		deactivate_super()
> pageout()			tmpfs_fs_type->kill_sb()
> shmem_writepage()		kill_litter_super()
> 				generic_shutdown_super()
> 				 evict_inodes()
>   igrab()
> 				  atomic_read(&inode->i_count)
> 				   skip-inode
>   iput()
> 				 if (!list_empty(&sb->s_inodes))
> 					printk("VFS: Busy inodes after...
>
> To avoid this race after this patch shmem_writepage() also try grab sb->s_active.
>
> If sb->s_active == 0 adding to the shmem_swaplist not required, because
> super-block deactivation in progress and swap-entries will be released soon.
>
> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> ---
>   mm/shmem.c |    9 ++++++++-
>   1 files changed, 8 insertions(+), 1 deletions(-)
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 58da7c1..1f49c03 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1038,11 +1038,13 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
>   	struct address_space *mapping;
>   	unsigned long index;
>   	struct inode *inode;
> +	struct super_block *sb;
>
>   	BUG_ON(!PageLocked(page));
>   	mapping = page->mapping;
>   	index = page->index;
>   	inode = mapping->host;
> +	sb = inode->i_sb;
>   	info = SHMEM_I(inode);
>   	if (info->flags&  VM_LOCKED)
>   		goto redirty;
> @@ -1083,7 +1085,10 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
>   		delete_from_page_cache(page);
>   		shmem_swp_set(info, entry, swap.val);
>   		shmem_swp_unmap(entry);
> -		if (list_empty(&info->swaplist))
> +		if (!list_empty(&info->swaplist) ||
> +				!atomic_inc_not_zero(&sb->s_active))
> +			sb = NULL;
> +		if (sb)
>   			inode = igrab(inode);
>   		else
>   			inode = NULL;
> @@ -1098,6 +1103,8 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
>   			mutex_unlock(&shmem_swaplist_mutex);
>   			iput(inode);
>   		}
> +		if (sb)
> +			deactivate_super(sb);
>   		return 0;
>   	}
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
