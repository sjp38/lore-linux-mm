Return-Path: <linux-kernel-owner@vger.kernel.org>
From: guoxuenan <guoxuenan@huawei.com>
Subject: A kernel warning will be triggered,during copy a big file into zstd
 compressed btrfs filesystem
Message-ID: <c8fc1d4d-4537-f12b-30a5-a4be01f587be@huawei.com>
Date: Wed, 6 Dec 2017 14:54:19 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: linux-btrfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, clm@fb.com, jbacik@fb.com, dsterba@suse.com, linux-mm@kvack.org, miaoxie@huawei.com, houtao1@huawei.com, zhaohongjiang@huawei.com
List-ID: <linux-mm.kvack.org>

Hi all,

I have found a kernel warning of btrfs ,during run my  shell script in 
qemu qemu virtual machine.

Linux mainline version Linux 4.15-rc2 (ae64f9bd)


The script try to copy a big file(15G) into btrfs filesystem,when I 
login virtual machine,then run the script,A kernel warning will be 
triggered  within about ten file copies.
=========================================================
#!/bin/sh
function btrfs_test()
{
	umount /mnt/vdb
	mkfs.btrfs -f /dev/vdb
	mount -o compress=$1 /dev/vdb /mnt/vdb
	cp ../data.tar  /mnt/vdb
	sleep 10
	btrfs filesystem sync /mnt/vdb
}

function loop_test()
{

	for k in $( seq 1 100 )
	do
		btrfs_test zstd
	done
}
loop_test
==========================================================

Kernl Warning content:

[  291.809047] ============================================
[  291.809981] WARNING: possible recursive locking detected
[  291.810913] 4.15.0-rc2-327.58.59.16.x86_64.debug+ #8 Not tainted
[  291.811908] --------------------------------------------
[  291.812792] khugepaged/65 is trying to acquire lock:
[  291.813614]  (fs_reclaim){+.+.}, at: [<000000009263bd20>] 
fs_reclaim_acquire+0x12/0x40
[  291.814972]
[  291.814972] but task is already holding lock:
[  291.815912]  (fs_reclaim){+.+.}, at: [<000000009263bd20>] 
fs_reclaim_acquire+0x12/0x40
[  291.817263]
[  291.817263] other info that might help us debug this:
[  291.818355]  Possible unsafe locking scenario:
[  291.818355]
[  291.819348]        CPU0
[  291.819743]        ----
[  291.820121]   lock(fs_reclaim);
[  291.820689]   lock(fs_reclaim);
[  291.821223]
[  291.821223]  *** DEADLOCK ***
[  291.821223]
[  291.822224]  May be due to missing lock nesting notation
[  291.822224]
[  291.823411] 1 lock held by khugepaged/65:
[  291.824048]  #0:  (fs_reclaim){+.+.}, at: [<000000009263bd20>] 
fs_reclaim_acquire+0x12/0x40
[  291.825480]
[  291.825480] stack backtrace:
[  291.826155] CPU: 4 PID: 65 Comm: khugepaged Not tainted 
4.15.0-rc2-327.58.59.16.x86_64.debug+ #8
[  291.827696] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.9.3-1.fc25 04/01/2014
[  291.829111] Call Trace:
[  291.829560]  dump_stack+0x7c/0xbf
[  291.830072]  __lock_acquire+0x8d6/0x1220
[  291.830837]  lock_acquire+0xc9/0x220
[  291.831425]  ? fs_reclaim_acquire+0x12/0x40
[  291.832110]  ? alloc_extent_state+0x21/0x1c0
[  291.832824]  fs_reclaim_acquire+0x35/0x40
[  291.833476]  ? fs_reclaim_acquire+0x12/0x40
[  291.834114]  kmem_cache_alloc+0x29/0x320
[  291.834777]  alloc_extent_state+0x21/0x1c0
[  291.835390]  __clear_extent_bit+0x2a5/0x3b0
[  291.836079]  try_release_extent_mapping+0x17c/0x200
[  291.836868]  __btrfs_releasepage+0x30/0x90
[  291.837519]  shrink_page_list+0x80d/0xf20
[  291.838158]  shrink_inactive_list+0x250/0x710
[  291.838875]  ? rcu_read_lock_sched_held+0x9b/0xb0
[  291.839666]  shrink_node_memcg+0x358/0x790
[  291.840282]  ? mem_cgroup_iter+0x98/0x530
[  291.840872]  shrink_node+0xe5/0x310
[  291.841387]  do_try_to_free_pages+0xe8/0x390
[  291.842013]  try_to_free_pages+0x146/0x3d0
[  291.842620]  __alloc_pages_slowpath+0x3d1/0xce1
[  291.843290]  __alloc_pages_nodemask+0x411/0x450
[  291.843989]  khugepaged_alloc_page+0x39/0x80
[  291.844626]  collapse_huge_page+0x78/0x9a0
[  291.845381]  ? khugepaged_scan_mm_slot+0x932/0xfa0
[  291.846113]  khugepaged_scan_mm_slot+0x953/0xfa0
[  291.846838]  ? khugepaged+0x130/0x5a0
[  291.847388]  khugepaged+0x2e0/0x5a0
[  291.848019]  ? remove_wait_queue+0x60/0x60
[  291.848678]  kthread+0x141/0x180
[  291.849239]  ? khugepaged_scan_mm_slot+0xfa0/0xfa0
[  291.849938]  ? kthread_stop+0x300/0x300
[  291.850514]  ret_from_fork+0x24/0x30
