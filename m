Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5D26B0005
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 07:12:57 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id tt10so8822157pab.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 04:12:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u79si9890198pfa.232.2016.04.05.04.12.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Apr 2016 04:12:55 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
Message-Id: <201604052012.IGJ69231.VFtMSHFJOOLOFQ@I-love.SAKURA.ne.jp>
Date: Tue, 5 Apr 2016 20:12:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

I did an OOM torture test using Linux 4.6-rc2 with kmallocwd patch
on xfs and ext4 filesystems using reproducer shown below.

---------- Reproducer start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <sys/prctl.h>
#include <signal.h>
#include <sys/mman.h>

static char buffer[4096] = { };

static int writer(void *unused)
{
	const int fd = open("/proc/self/exe", O_RDONLY);
	sleep(2);
	while (1) {
		void *ptr = mmap(NULL, 4096, PROT_READ, MAP_PRIVATE, fd, 0);
		munmap(ptr, 4096);
	}
	return 0;
}

static int file_io(void *unused)
{
	const int fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
	sleep(2);
	while (write(fd, buffer, sizeof(buffer)) > 0);
	close(fd);
	return 0;
}

int main(int argc, char *argv[])
{
	int i;
	if (chdir("/tmp"))
		return 1;
	for (i = 0; i < 64; i++)
		if (fork() == 0) {
			const int idx = i;
			char buffer2[64] = { };
			const int fd = open("/proc/self/oom_score_adj", O_WRONLY);
			write(fd, "1000", 4);
			close(fd);
			snprintf(buffer, sizeof(buffer), "file_io.%02u", idx);
			prctl(PR_SET_NAME, (unsigned long) buffer, 0, 0, 0);
			for (i = 0; i < 16; i++)
				clone(file_io, malloc(1024) + 1024, CLONE_VM, NULL);
			snprintf(buffer2, sizeof(buffer2), "writer.%02u", idx);
			prctl(PR_SET_NAME, (unsigned long) buffer2, 0, 0, 0);
			for (i = 0; i < 16; i++)
				clone(writer, malloc(1024) + 1024, CLONE_VM, NULL);
			while (1)
				pause();
		}
	{ /* A dummy process for invoking the OOM killer. */
		char *buf = NULL;
		unsigned long i;
		unsigned long size = 0;
		prctl(PR_SET_NAME, (unsigned long) "memeater", 0, 0, 0);
		for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
			char *cp = realloc(buf, size);
			if (!cp) {
				size >>= 1;
				break;
			}
			buf = cp;
		}
		sleep(4);
		for (i = 0; i < size; i += 4096)
			buf[i] = '\0'; /* Will cause OOM due to overcommit */
	}
	kill(-1, SIGKILL);
	return * (char *) NULL; /* Not reached. */
}
---------- Reproducer end ----------

What I can observe under OOM livelock condition is a three-way dependency loop.

  (1) An OOM victim (which has TIF_MEMDIE) is unable to make forward progress
      due to blocked at unkillable lock waiting for other thread's memory
      allocation.

  (2) A filesystem writeback work item is unable to make forward progress
      due to waiting for GFP_NOFS memory allocation to be satisfied because
      storage I/O is stalling.

  (3) A disk I/O work item is unable to make forward progress due to
      waiting for GFP_NOIO memory allocation to be satisfied because
      an OOM victim does not release memory but the OOM reaper does not
      unlock TIF_MEMDIE.

Complete log for xfs is at http://I-love.SAKURA.ne.jp/tmp/serial-20160404.txt.xz
----------
[   98.749616] Killed process 1424 (file_io.08) total-vm:4332kB, anon-rss:0kB, file-rss:4kB, shmem-rss:0kB
[  143.136457] MemAlloc-Info: stalling=2 dying=178 exiting=31 victim=1 oom_count=2324984/335679
[  143.143740] MemAlloc: kswapd0(49) flags=0xa40840 switches=466 uninterruptible
[  143.149661] kswapd0         D 0000000000000001     0    49      2 0x00000000
[  143.155312]  ffff88003689c6c0 ffff8800368a4000 ffff8800368a38b0 ffff88003c251c10
[  143.161566]  ffff88003c251c28 ffff8800368a39e8 0000000000000001 ffffffff81556fbc
[  143.167957]  ffff88003689c6c0 ffffffff81559108 0000000000000000 ffff88003c251c18
[  143.174116] Call Trace:
[  143.176643]  [<ffffffff81556fbc>] ? schedule+0x2c/0x80
[  143.180854]  [<ffffffff81559108>] ? rwsem_down_read_failed+0xf8/0x150
[  143.186358]  [<ffffffff810a20b0>] ? wait_woken+0x80/0x80
[  143.190572]  [<ffffffff8126d5e4>] ? call_rwsem_down_read_failed+0x14/0x30
[  143.196129]  [<ffffffff81558a67>] ? down_read+0x17/0x20
[  143.200356]  [<ffffffffa021c19e>] ? xfs_map_blocks+0x7e/0x150 [xfs]
[  143.205430]  [<ffffffffa021cffa>] ? xfs_do_writepage+0x16a/0x510 [xfs]
[  143.210701]  [<ffffffffa021d3d1>] ? xfs_vm_writepage+0x31/0x70 [xfs]
[  143.215819]  [<ffffffff811225f2>] ? pageout.isra.43+0x182/0x230
[  143.220678]  [<ffffffff811239eb>] ? shrink_page_list+0x84b/0xb20
[  143.225484]  [<ffffffff8112444b>] ? shrink_inactive_list+0x20b/0x490
[  143.230481]  [<ffffffff81125071>] ? shrink_zone_memcg+0x5d1/0x790
[  143.235430]  [<ffffffff8117553d>] ? mem_cgroup_iter+0x14d/0x2b0
[  143.240220]  [<ffffffff81125307>] ? shrink_zone+0xd7/0x2f0
[  143.244725]  [<ffffffff811261c6>] ? kswapd+0x406/0x7d0
[  143.248903]  [<ffffffff81125dc0>] ? mem_cgroup_shrink_node_zone+0xb0/0xb0
[  143.254293]  [<ffffffff81083b68>] ? kthread+0xc8/0xe0
[  143.258401]  [<ffffffff8155a502>] ? ret_from_fork+0x22/0x40
[  143.262846]  [<ffffffff81083aa0>] ? kthread_create_on_node+0x1a0/0x1a0
[  143.267956] MemAlloc: kworker/2:1(61) flags=0x4208860 switches=75880 seq=4 gfp=0x2400000(GFP_NOIO) order=0 delay=39526 uninterruptible
[  143.277844] kworker/2:1     R  running task        0    61      2 0x00000000
[  143.283598] Workqueue: events_freezable_power_ disk_events_workfn
[  143.288592]  ffff880036940880 ffff88000013c000 ffff88000013b768 ffff88003f64dfc0
[  143.295797]  ffff88000013b700 00000000fffd98ea 0000000000000017 ffffffff81556fbc
[  143.301706]  ffff88003f64dfc0 ffffffff8155965e 0000000000000000 0000000000000286
[  143.307659] Call Trace:
[  143.309941]  [<ffffffff81556fbc>] ? schedule+0x2c/0x80
[  143.314292]  [<ffffffff8155965e>] ? schedule_timeout+0x11e/0x1c0
[  143.319045]  [<ffffffff810c0270>] ? cascade+0x80/0x80
[  143.323122]  [<ffffffff8112e9f7>] ? wait_iff_congested+0xd7/0x120
[  143.327887]  [<ffffffff810a20b0>] ? wait_woken+0x80/0x80
[  143.332129]  [<ffffffff8112454f>] ? shrink_inactive_list+0x30f/0x490
[  143.337349]  [<ffffffff81125071>] ? shrink_zone_memcg+0x5d1/0x790
[  143.342071]  [<ffffffff8117553d>] ? mem_cgroup_iter+0x14d/0x2b0
[  143.346651]  [<ffffffff81125307>] ? shrink_zone+0xd7/0x2f0
[  143.350955]  [<ffffffff8112586a>] ? do_try_to_free_pages+0x15a/0x3e0
[  143.355829]  [<ffffffff81125b85>] ? try_to_free_pages+0x95/0xc0
[  143.360409]  [<ffffffff8111a38f>] ? __alloc_pages_nodemask+0x63f/0xc40
[  143.365433]  [<ffffffff8115dcef>] ? alloc_pages_current+0x7f/0x100
[  143.370275]  [<ffffffff8123456b>] ? bio_copy_kern+0xbb/0x170
[  143.374695]  [<ffffffff8123d53a>] ? blk_rq_map_kern+0x6a/0x120
[  143.379295]  [<ffffffff81237ca2>] ? blk_get_request+0x72/0xd0
[  143.383477]  [<ffffffff81388cf2>] ? scsi_execute+0x122/0x150
[  143.388023]  [<ffffffff81388df5>] ? scsi_execute_req_flags+0x85/0xf0
[  143.392883]  [<ffffffffa01dd719>] ? sr_check_events+0xb9/0x2b0 [sr_mod]
[  143.397909]  [<ffffffffa01d114f>] ? cdrom_check_events+0xf/0x30 [cdrom]
[  143.403016]  [<ffffffff8124772a>] ? disk_check_events+0x5a/0x140
[  143.407606]  [<ffffffff8107e484>] ? process_one_work+0x134/0x310
[  143.412245]  [<ffffffff8107e77d>] ? worker_thread+0x11d/0x4a0
[  143.416729]  [<ffffffff81556a51>] ? __schedule+0x271/0x7b0
[  143.421047]  [<ffffffff8107e660>] ? process_one_work+0x310/0x310
[  143.425624]  [<ffffffff81083b68>] ? kthread+0xc8/0xe0
[  143.429595]  [<ffffffff8155a502>] ? ret_from_fork+0x22/0x40
[  143.433897]  [<ffffffff81083aa0>] ? kthread_create_on_node+0x1a0/0x1a0
[  143.440187] MemAlloc: kworker/u128:2(270) flags=0x4a28860 switches=68907 seq=90 gfp=0x2400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=60000 uninterruptible
[  143.450674] kworker/u128:2  D 0000000000000017     0   270      2 0x00000000
[  143.456069] Workqueue: writeback wb_workfn (flush-8:0)
[  143.460752]  ffff880036034180 ffff880039ffc000 ffff880039ffae68 ffff88003f66dfc0
[  143.466560]  ffff880039ffae00 00000000fffd99b1 0000000000000017 ffffffff810c041f
[  143.472246]  ffff88003f66dfc0 ffffffff8155965e 0000000000000000 0000000000000286
[  143.478837] Call Trace:
[  143.481096]  [<ffffffff81556fbc>] ? schedule+0x2c/0x80
[  143.485192]  [<ffffffff8155965e>] ? schedule_timeout+0x11e/0x1c0
[  143.489958]  [<ffffffff810c0270>] ? cascade+0x80/0x80
[  143.494002]  [<ffffffff8112e9f7>] ? wait_iff_congested+0xd7/0x120
[  143.498750]  [<ffffffff810a20b0>] ? wait_woken+0x80/0x80
[  143.502968]  [<ffffffff8112454f>] ? shrink_inactive_list+0x30f/0x490
[  143.507907]  [<ffffffff81125071>] ? shrink_zone_memcg+0x5d1/0x790
[  143.512611]  [<ffffffff8117553d>] ? mem_cgroup_iter+0x14d/0x2b0
[  143.517315]  [<ffffffff81125307>] ? shrink_zone+0xd7/0x2f0
[  143.521575]  [<ffffffff8112586a>] ? do_try_to_free_pages+0x15a/0x3e0
[  143.526428]  [<ffffffff81125b85>] ? try_to_free_pages+0x95/0xc0
[  143.530957]  [<ffffffff8111a38f>] ? __alloc_pages_nodemask+0x63f/0xc40
[  143.536014]  [<ffffffff8115dcef>] ? alloc_pages_current+0x7f/0x100
[  143.541053]  [<ffffffffa02539c2>] ? xfs_buf_allocate_memory+0x16a/0x2a5 [xfs]
[  143.546614]  [<ffffffffa022251b>] ? xfs_buf_get_map+0xeb/0x140 [xfs]
[  143.551461]  [<ffffffffa0222a03>] ? xfs_buf_read_map+0x23/0xd0 [xfs]
[  143.556319]  [<ffffffffa024a827>] ? xfs_trans_read_buf_map+0x87/0x190 [xfs]
[  143.561610]  [<ffffffffa01fdc22>] ? xfs_btree_read_buf_block.constprop.29+0x72/0xc0 [xfs]
[  143.568068]  [<ffffffffa01fdce8>] ? xfs_btree_lookup_get_block+0x78/0xe0 [xfs]
[  143.573722]  [<ffffffffa0202262>] ? xfs_btree_lookup+0xc2/0x570 [xfs]
[  143.578671]  [<ffffffffa01e9712>] ? xfs_alloc_fixup_trees+0x282/0x350 [xfs]
[  143.583941]  [<ffffffffa01eb7af>] ? xfs_alloc_ag_vextent_near+0x55f/0x910 [xfs]
[  143.589444]  [<ffffffffa01ebc55>] ? xfs_alloc_ag_vextent+0xf5/0x120 [xfs]
[  143.594584]  [<ffffffffa01ec72b>] ? xfs_alloc_vextent+0x3bb/0x470 [xfs]
[  143.599674]  [<ffffffffa01f9de7>] ? xfs_bmap_btalloc+0x3d7/0x760 [xfs]
[  143.604422]  [<ffffffffa01fab34>] ? xfs_bmapi_write+0x474/0xa20 [xfs]
[  143.609329]  [<ffffffffa022de73>] ? xfs_iomap_write_allocate+0x163/0x380 [xfs]
[  143.614804]  [<ffffffffa021c255>] ? xfs_map_blocks+0x135/0x150 [xfs]
[  143.619661]  [<ffffffffa021cffa>] ? xfs_do_writepage+0x16a/0x510 [xfs]
[  143.624496]  [<ffffffff8111c9fe>] ? write_cache_pages+0x1ae/0x400
[  143.629218]  [<ffffffffa021ce90>] ? xfs_aops_discard_page+0x130/0x130 [xfs]
[  143.634413]  [<ffffffffa021ccbf>] ? xfs_vm_writepages+0x5f/0xa0 [xfs]
[  143.639403]  [<ffffffff811aa9fc>] ? __writeback_single_inode+0x2c/0x170
[  143.644474]  [<ffffffff811ab013>] ? writeback_sb_inodes+0x223/0x4e0
[  143.649194]  [<ffffffff811ab352>] ? __writeback_inodes_wb+0x82/0xb0
[  143.654019]  [<ffffffff811ab56c>] ? wb_writeback+0x1ec/0x220
[  143.658215]  [<ffffffff811aba5e>] ? wb_workfn+0xde/0x290
[  143.662373]  [<ffffffff8107e484>] ? process_one_work+0x134/0x310
[  143.667058]  [<ffffffff8107e77d>] ? worker_thread+0x11d/0x4a0
[  143.671623]  [<ffffffff81556a51>] ? __schedule+0x271/0x7b0
[  143.676393]  [<ffffffff8107e660>] ? process_one_work+0x310/0x310
[  143.681168]  [<ffffffff81083b68>] ? kthread+0xc8/0xe0
[  143.685169]  [<ffffffff8155a502>] ? ret_from_fork+0x22/0x40
[  143.689497]  [<ffffffff81083aa0>] ? kthread_create_on_node+0x1a0/0x1a0
(...snipped...)
[  143.791611] MemAlloc: file_io.08(1424) flags=0x400040 switches=1058 uninterruptible dying victim
[  143.798403] file_io.08      D ffff88003c285d98     0  1424      1 0x00100084
[  143.803820]  ffff88003d36e180 ffff88003d374000 ffff88003d373d80 ffff88003c285d94
[  143.809802]  ffff88003d36e180 00000000ffffffff ffff88003c285d98 ffffffff81556fbc
[  143.815638]  ffff88003c285d90 ffffffff81557255 ffffffff81558604 ffff88003d37fd30
[  143.821210] Call Trace:
[  143.823431]  [<ffffffff81556fbc>] ? schedule+0x2c/0x80
[  143.828700]  [<ffffffff81557255>] ? schedule_preempt_disabled+0x5/0x10
[  143.833661]  [<ffffffff81558604>] ? __mutex_lock_slowpath+0xb4/0x130
[  143.838552]  [<ffffffff81558696>] ? mutex_lock+0x16/0x25
[  143.842614]  [<ffffffffa022687c>] ? xfs_file_buffered_aio_write+0x5c/0x1e0 [xfs]
[  143.847945]  [<ffffffff810226ad>] ? __switch_to+0x20d/0x3f0
[  143.852188]  [<ffffffffa0226a86>] ? xfs_file_write_iter+0x86/0x140 [xfs]
[  143.857179]  [<ffffffff811838cb>] ? __vfs_write+0xcb/0x100
[  143.861441]  [<ffffffff81184478>] ? vfs_write+0x98/0x190
[  143.865629]  [<ffffffff81556a51>] ? __schedule+0x271/0x7b0
[  143.869902]  [<ffffffff8118583d>] ? SyS_write+0x4d/0xc0
[  143.874031]  [<ffffffff810034a7>] ? do_syscall_64+0x57/0xf0
[  143.878258]  [<ffffffff8155a3a1>] ? entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  165.512677] Mem-Info:
[  165.514925] active_anon:166683 inactive_anon:1640 isolated_anon:0
[  165.514925]  active_file:10870 inactive_file:49863 isolated_file:68
[  165.514925]  unevictable:0 dirty:49806 writeback:112 unstable:0
[  165.514925]  slab_reclaimable:3373 slab_unreclaimable:7156
[  165.514925]  mapped:10566 shmem:1703 pagetables:1606 bounce:0
[  165.514925]  free:1854 free_pcp:130 free_cma:0
[  165.541474] Node 0 DMA free:3932kB min:60kB low:72kB high:84kB active_anon:7596kB inactive_anon:176kB active_file:328kB inactive_file:976kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:976kB writeback:0kB mapped:404kB shmem:176kB slab_reclaimable:128kB slab_unreclaimable:488kB kernel_stack:144kB pagetables:140kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:8636 all_unreclaimable? yes
[  165.574685] lowmem_reserve[]: 0 968 968 968
[  165.578352] Node 0 DMA32 free:3484kB min:3812kB low:4804kB high:5796kB active_anon:659136kB inactive_anon:6384kB active_file:43152kB inactive_file:198476kB unevictable:0kB isolated(anon):0kB isolated(file):272kB present:1032064kB managed:996224kB mlocked:0kB dirty:198248kB writeback:448kB mapped:41860kB shmem:6636kB slab_reclaimable:13364kB slab_unreclaimable:28136kB kernel_stack:7792kB pagetables:6284kB unstable:0kB bounce:0kB free_pcp:520kB local_pcp:216kB free_cma:0kB writeback_tmp:0kB pages_scanned:201090336 all_unreclaimable? yes
[  165.612568] lowmem_reserve[]: 0 0 0 0
[  165.615805] Node 0 DMA: 23*4kB (UM) 30*8kB (UM) 21*16kB (U) 6*32kB (U) 4*64kB (U) 2*128kB (U) 0*256kB 3*512kB (UM) 1*1024kB (U) 0*2048kB 0*4096kB = 3932kB
[  165.626447] Node 0 DMA32: 759*4kB (UE) 54*8kB (U) 1*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3484kB
[  165.635697] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  165.642340] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  165.648792] 62515 total pagecache pages
[  165.652093] 0 pages in swap cache
[  165.655325] Swap cache stats: add 0, delete 0, find 0/0
[  165.659472] Free swap  = 0kB
[  165.662094] Total swap = 0kB
[  165.664813] 262013 pages RAM
[  165.667364] 0 pages HighMem/MovableOnly
[  165.670595] 8981 pages reserved
[  165.673400] 0 pages cma reserved
[  165.676333] 0 pages hwpoisoned
[  165.679103] Showing busy workqueues and worker pools:
[  165.683077] workqueue events: flags=0x0
[  165.686367]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  165.690779]     pending: vmpressure_work_fn
[  165.694084]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  165.698960]     pending: vmw_fb_dirty_flush [vmwgfx]
[  165.703112] workqueue events_freezable_power_: flags=0x84
[  165.707516]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  165.711938]     in-flight: 61:disk_events_workfn
[  165.715500] workqueue writeback: flags=0x4e
[  165.719068]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[  165.723890]     in-flight: 270:wb_workfn wb_workfn
[  165.728443] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 209 3311 23
[  165.734327] pool 128: cpus=0-63 flags=0x4 nice=0 hung=0s workers=5 idle: 6 51 277 276
[  165.740618] MemAlloc-Info: stalling=2 dying=178 exiting=31 victim=1 oom_count=3071760/430759
----------

Complete log for ext4 is at http://I-love.SAKURA.ne.jp/tmp/serial-20160405.txt.xz
----------
[  186.620979] Out of memory: Kill process 4458 (file_io.24) score 997 or sacrifice child
[  186.627897] Killed process 4458 (file_io.24) total-vm:4336kB, anon-rss:116kB, file-rss:1024kB, shmem-rss:0kB
[  186.688345] oom_reaper: reaped process 4458 (file_io.24), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  187.089562] Killed process 3499 (writer.26) total-vm:4344kB, anon-rss:80kB, file-rss:64kB, shmem-rss:0kB
[  242.174775] MemAlloc-Info: stalling=9 dying=31 exiting=0 victim=1 oom_count=752788/16556
[  242.183365] MemAlloc: kswapd0(49) flags=0xa40840 switches=994137
[  242.188759] kswapd0         R  running task        0    49      2 0x00000000
[  242.195022]  ffff88003af2fd20 ffff88003af30000 ffff88003af2fde8 ffff88003f62dfc0
[  242.201296]  ffff88003af2fd80 00000000ffff1d70 ffff88003ffde000 ffffffff81587dec
[  242.207771]  ffff88003f62dfc0 ffffffff8158a48e ffffffff811249c7 0000000000000286
[  242.213864] Call Trace:
[  242.216691]  [<ffffffff81587dec>] ? schedule+0x2c/0x80
[  242.221078]  [<ffffffff811249c7>] ? shrink_zone+0xd7/0x2f0
[  242.225342]  [<ffffffff810c00a0>] ? cascade+0x80/0x80
[  242.229333]  [<ffffffff81125b89>] ? kswapd+0x709/0x7d0
[  242.233452]  [<ffffffff810a1ee0>] ? wait_woken+0x80/0x80
[  242.237618]  [<ffffffff81125480>] ? mem_cgroup_shrink_node_zone+0xb0/0xb0
[  242.242602]  [<ffffffff81083b18>] ? kthread+0xc8/0xe0
[  242.246718]  [<ffffffff8158b342>] ? ret_from_fork+0x22/0x40
[  242.250939]  [<ffffffff81083a50>] ? kthread_create_on_node+0x1a0/0x1a0
[  242.257505] MemAlloc: kworker/u128:1(51) flags=0x4a08860 switches=80360 seq=18 gfp=0x2400040(GFP_NOFS) order=0 delay=60000 uninterruptible
[  242.266407] kworker/u128:1  D 0000000000000017     0    51      2 0x00000000
[  242.272485] Workqueue: writeback wb_workfn (flush-8:0)
[  242.276909]  ffff880036814740 ffff88003681c000 ffff88003681b278 ffff88003f64dfc0
[  242.282635]  00000000a6a32935 00000000ffff1d5e ffff88003681b278 ffffffff81587dec
[  242.288840]  ffff88003f64dfc0 ffffffff8158a496 0000000000000000 0000000000000286
[  242.294612] Call Trace:
[  242.297193]  [<ffffffff81587dec>] ? schedule+0x2c/0x80
[  242.301418]  [<ffffffff8158a48e>] ? schedule_timeout+0x11e/0x1c0
[  242.306184]  [<ffffffff810c00a0>] ? cascade+0x80/0x80
[  242.310356]  [<ffffffff8112df97>] ? wait_iff_congested+0xd7/0x120
[  242.314891]  [<ffffffff810a1ee0>] ? wait_woken+0x80/0x80
[  242.319372]  [<ffffffff81123c0f>] ? shrink_inactive_list+0x30f/0x490
[  242.324695]  [<ffffffff81124731>] ? shrink_zone_memcg+0x5d1/0x790
[  242.329526]  [<ffffffff81095f29>] ? check_preempt_wakeup+0x119/0x230
[  242.334118]  [<ffffffff81094d6f>] ? dequeue_entity+0x23f/0x8e0
[  242.339120]  [<ffffffff811249c7>] ? shrink_zone+0xd7/0x2f0
[  242.343704]  [<ffffffff81124f2a>] ? do_try_to_free_pages+0x15a/0x3e0
[  242.348572]  [<ffffffff81125245>] ? try_to_free_pages+0x95/0xc0
[  242.353213]  [<ffffffff81119a4f>] ? __alloc_pages_nodemask+0x63f/0xc40
[  242.358128]  [<ffffffff8115d2df>] ? alloc_pages_current+0x7f/0x100
[  242.362766]  [<ffffffff81110445>] ? pagecache_get_page+0x85/0x240
[  242.367679]  [<ffffffff81228fb7>] ? ext4_mb_load_buddy_gfp+0x357/0x440
[  242.372621]  [<ffffffff8122b599>] ? ext4_mb_regular_allocator+0x169/0x470
[  242.377834]  [<ffffffff81094d6f>] ? dequeue_entity+0x23f/0x8e0
[  242.382677]  [<ffffffff8122d059>] ? ext4_mb_new_blocks+0x369/0x440
[  242.387572]  [<ffffffff81222bc0>] ? ext4_ext_map_blocks+0x10c0/0x1770
[  242.392153]  [<ffffffff8111e373>] ? release_pages+0x243/0x350
[  242.396704]  [<ffffffff81110bb3>] ? find_get_pages_tag+0xd3/0x1b0
[  242.401379]  [<ffffffff81110099>] ? __lock_page+0x49/0xf0
[  242.405824]  [<ffffffff81201412>] ? ext4_map_blocks+0x122/0x510
[  242.410186]  [<ffffffff8120490c>] ? ext4_writepages+0x53c/0xb10
[  242.414687]  [<ffffffff811a968c>] ? __writeback_single_inode+0x2c/0x170
[  242.419531]  [<ffffffff811a9ca3>] ? writeback_sb_inodes+0x223/0x4e0
[  242.424284]  [<ffffffff811a9fe2>] ? __writeback_inodes_wb+0x82/0xb0
[  242.429196]  [<ffffffff811aa1fc>] ? wb_writeback+0x1ec/0x220
[  242.433267]  [<ffffffff811aa6ee>] ? wb_workfn+0xde/0x290
[  242.437275]  [<ffffffff8107e434>] ? process_one_work+0x134/0x310
[  242.441492]  [<ffffffff8107e72d>] ? worker_thread+0x11d/0x4a0
[  242.445781]  [<ffffffff8107e610>] ? process_one_work+0x310/0x310
[  242.450190]  [<ffffffff81083b18>] ? kthread+0xc8/0xe0
[  242.454366]  [<ffffffff8158b342>] ? ret_from_fork+0x22/0x40
[  242.458870]  [<ffffffff81083a50>] ? kthread_create_on_node+0x1a0/0x1a0
[  242.465699] MemAlloc: kworker/0:2(285) flags=0x4208860 switches=275666 seq=15 gfp=0x2400000(GFP_NOIO) order=0 delay=58093
[  242.474600] kworker/0:2     R  running task        0   285      2 0x00000000
[  242.479981] Workqueue: events_freezable_power_ disk_events_workfn
[  242.484669]  ffff8800396f8600 0000000000000286 ffff8800396ff768 ffff88003f60dfc0
[  242.490850]  ffff8800396ff700 ffff8800396ff700 0000000000000017 ffffffff81587dec
[  242.496493]  ffff88003f60dfc0 ffffffff8158a48e 0000000000000000 0000000000000286
[  242.502195] Call Trace:
[  242.504347]  [<ffffffff810c01dc>] ? try_to_del_timer_sync+0x4c/0x80
[  242.509164]  [<ffffffff81587dec>] ? schedule+0x2c/0x80
[  242.513106]  [<ffffffff8158a48e>] ? schedule_timeout+0x11e/0x1c0
[  242.517333]  [<ffffffff810c00a0>] ? cascade+0x80/0x80
[  242.521263]  [<ffffffff8112df6f>] ? wait_iff_congested+0xaf/0x120
[  242.525472]  [<ffffffff810a1ee0>] ? wait_woken+0x80/0x80
[  242.529443]  [<ffffffff81123c0f>] ? shrink_inactive_list+0x30f/0x490
[  242.534392]  [<ffffffff81124731>] ? shrink_zone_memcg+0x5d1/0x790
[  242.539076]  [<ffffffff81094910>] ? update_curr+0x90/0xd0
[  242.543052]  [<ffffffff81174b0d>] ? mem_cgroup_iter+0x14d/0x2b0
[  242.547529]  [<ffffffff811249c7>] ? shrink_zone+0xd7/0x2f0
[  242.551904]  [<ffffffff81124f2a>] ? do_try_to_free_pages+0x15a/0x3e0
[  242.556629]  [<ffffffff81125245>] ? try_to_free_pages+0x95/0xc0
[  242.561000]  [<ffffffff81119c77>] ? __alloc_pages_nodemask+0x867/0xc40
[  242.566133]  [<ffffffff8115d2df>] ? alloc_pages_current+0x7f/0x100
[  242.570852]  [<ffffffff81265b3b>] ? bio_copy_kern+0xbb/0x170
[  242.575036]  [<ffffffff8126eb0a>] ? blk_rq_map_kern+0x6a/0x120
[  242.579227]  [<ffffffff81269272>] ? blk_get_request+0x72/0xd0
[  242.583721]  [<ffffffff813ba2e2>] ? scsi_execute+0x122/0x150
[  242.588072]  [<ffffffff813ba3e5>] ? scsi_execute_req_flags+0x85/0xf0
[  242.592773]  [<ffffffffa01cf719>] ? sr_check_events+0xb9/0x2b0 [sr_mod]
[  242.597639]  [<ffffffffa01c314f>] ? cdrom_check_events+0xf/0x30 [cdrom]
[  242.602455]  [<ffffffff81278cfa>] ? disk_check_events+0x5a/0x140
[  242.606821]  [<ffffffff8107e434>] ? process_one_work+0x134/0x310
[  242.611191]  [<ffffffff8107e72d>] ? worker_thread+0x11d/0x4a0
[  242.615560]  [<ffffffff81587881>] ? __schedule+0x271/0x7b0
[  242.619988]  [<ffffffff8107e610>] ? process_one_work+0x310/0x310
[  242.624618]  [<ffffffff81083b18>] ? kthread+0xc8/0xe0
[  242.628245]  [<ffffffff8158b342>] ? ret_from_fork+0x22/0x40
[  242.632185]  [<ffffffff81083a50>] ? kthread_create_on_node+0x1a0/0x1a0
(...snipped...)
[  245.572082] MemAlloc: file_io.24(4715) flags=0x400040 switches=8650 uninterruptible dying victim
[  245.578876] file_io.24      D 0000000000000000     0  4715      1 0x00100084
[  245.584122]  ffff88002fd9c000 ffff88002fda4000 ffff880036221870 00000000000035a2
[  245.589618]  0000000000000000 ffff880036221870 0000000000000000 ffffffff81587dec
[  245.595428]  ffff880036221800 ffffffff8123b821 0000000000000000 ffff88002fd9c000
[  245.601370] Call Trace:
[  245.603428]  [<ffffffff81587dec>] ? schedule+0x2c/0x80
[  245.607680]  [<ffffffff8123b821>] ? wait_transaction_locked+0x81/0xc0
[  245.613586]  [<ffffffff810a1ee0>] ? wait_woken+0x80/0x80
[  245.618074]  [<ffffffff8123ba9a>] ? add_transaction_credits+0x21a/0x2a0
[  245.623497]  [<ffffffff81178abc>] ? mem_cgroup_commit_charge+0x7c/0xf0
[  245.628352]  [<ffffffff8123bceb>] ? start_this_handle+0x18b/0x400
[  245.632755]  [<ffffffff8110fb6e>] ? add_to_page_cache_lru+0x6e/0xd0
[  245.637274]  [<ffffffff8123c294>] ? jbd2__journal_start+0xf4/0x190
[  245.642298]  [<ffffffff81205ca4>] ? ext4_da_write_begin+0x114/0x360
[  245.647035]  [<ffffffff8111116e>] ? generic_perform_write+0xce/0x1d0
[  245.651651]  [<ffffffff8119c440>] ? file_update_time+0xc0/0x110
[  245.656166]  [<ffffffff81111f2d>] ? __generic_file_write_iter+0x16d/0x1c0
[  245.660835]  [<ffffffff811fbafa>] ? ext4_file_write_iter+0x12a/0x340
[  245.665292]  [<ffffffff810226ad>] ? __switch_to+0x20d/0x3f0
[  245.669604]  [<ffffffff81182ddb>] ? __vfs_write+0xcb/0x100
[  245.673904]  [<ffffffff81183968>] ? vfs_write+0x98/0x190
[  245.678174]  [<ffffffff81184d2d>] ? SyS_write+0x4d/0xc0
[  245.682376]  [<ffffffff810034a7>] ? do_syscall_64+0x57/0xf0
[  245.686845]  [<ffffffff8158b1e1>] ? entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  246.216363] Mem-Info:
[  246.218425] active_anon:183099 inactive_anon:2734 isolated_anon:0
[  246.218425]  active_file:2006 inactive_file:36363 isolated_file:0
[  246.218425]  unevictable:0 dirty:36369 writeback:0 unstable:0
[  246.218425]  slab_reclaimable:2055 slab_unreclaimable:9453
[  246.218425]  mapped:2266 shmem:3080 pagetables:1480 bounce:0
[  246.218425]  free:1814 free_pcp:197 free_cma:0
[  246.245998] Node 0 DMA free:3928kB min:60kB low:72kB high:84kB active_anon:7868kB inactive_anon:112kB active_file:188kB inactive_file:1504kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:1440kB writeback:0kB mapped:132kB shmem:120kB slab_reclaimable:184kB slab_unreclaimable:592kB kernel_stack:624kB pagetables:304kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:42274336 all_unreclaimable? yes
[  246.281121] lowmem_reserve[]: 0 968 968 968
[  246.284938] Node 0 DMA32 free:3328kB min:3812kB low:4804kB high:5796kB active_anon:724528kB inactive_anon:10824kB active_file:7836kB inactive_file:143948kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1032064kB managed:996008kB mlocked:0kB dirty:144036kB writeback:0kB mapped:8932kB shmem:12200kB slab_reclaimable:8036kB slab_unreclaimable:37220kB kernel_stack:23680kB pagetables:5616kB unstable:0kB bounce:0kB free_pcp:788kB local_pcp:116kB free_cma:0kB writeback_tmp:0kB pages_scanned:22926424 all_unreclaimable? yes
[  246.319945] lowmem_reserve[]: 0 0 0 0
[  246.323303] Node 0 DMA: 32*4kB (UME) 35*8kB (UME) 18*16kB (UE) 9*32kB (UE) 6*64kB (ME) 2*128kB (UE) 3*256kB (E) 3*512kB (UME) 0*1024kB 0*2048kB 0*4096kB = 3928kB
[  246.334695] Node 0 DMA32: 332*4kB (UE) 244*8kB (U) 3*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3328kB
[  246.344693] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  246.351599] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  246.357749] 41456 total pagecache pages
[  246.360874] 0 pages in swap cache
[  246.363717] Swap cache stats: add 0, delete 0, find 0/0
[  246.368022] Free swap  = 0kB
[  246.370769] Total swap = 0kB
[  246.373444] 262013 pages RAM
[  246.376115] 0 pages HighMem/MovableOnly
[  246.379669] 9035 pages reserved
[  246.382654] 0 pages cma reserved
[  246.385675] 0 pages hwpoisoned
[  246.388597] Showing busy workqueues and worker pools:
[  246.392477] workqueue events: flags=0x0
[  246.395797]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  246.400741]     pending: vmw_fb_dirty_flush [vmwgfx]
[  246.405129] workqueue events_freezable_power_: flags=0x84
[  246.409390]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  246.413910]     in-flight: 285:disk_events_workfn
[  246.417932] workqueue writeback: flags=0x4e
[  246.421660]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[  246.426158]     in-flight: 51:wb_workfn wb_workfn
[  246.430208] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 42 3280 4
[  246.435871] pool 128: cpus=0-63 flags=0x4 nice=0 hung=0s workers=4 idle: 260 6 259
[  246.441342] MemAlloc-Info: stalling=9 dying=31 exiting=0 victim=1 oom_count=783613/16904
----------

If I apply
----------
diff --git a/block/bio.c b/block/bio.c
index f124a0a..03250e86 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1504,6 +1504,8 @@ struct bio *bio_copy_kern(struct request_queue *q, void *data, unsigned int len,
 	void *p = data;
 	int nr_pages = 0;

+	gfp_mask |= __GFP_HIGH;
+
 	/*
 	 * Overflow, abort
 	 */
----------
then disk_events_workfn stall is gone. If I also apply
----------
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 9a2191b..448f61e 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -55,7 +55,7 @@ static kmem_zone_t *xfs_buf_zone;
 #endif

 #define xb_to_gfp(flags) \
-	((((flags) & XBF_READ_AHEAD) ? __GFP_NORETRY : GFP_NOFS) | __GFP_NOWARN)
+	((((flags) & XBF_READ_AHEAD) ? __GFP_NORETRY : (GFP_NOFS | __GFP_HIGH)) | __GFP_NOWARN)


 static inline int
----------
then both disk_events_workfn stall and wb_workfn stall are gone
and I can no longer reproduce OOM livelock using this reproducer.

Therefore, I think that the root cause of OOM livelock is that

  (A) We use the same watermark for GFP_KERNEL / GFP_NOFS / GFP_NOIO
      allocation requests.

  (B) We allow GFP_KERNEL allocation requests to consume memory to
      min: watermark.

  (C) GFP_KERNEL allocation requests might depend on GFP_NOFS
      allocation requests, and GFP_NOFS allocation requests
      might depend on GFP_NOIO allocation requests.

  (D) TIF_MEMDIE thread might wait forever for other thread's
      GFP_NOFS / GFP_NOIO allocation requests.

There is no gfp flag that prevents GFP_KERNEL from consuming memory to min:
watermark. Thus, it is inevitable that GFP_KERNEL allocations consume
memory to min: watermark and invokes the OOM killer. But if we change
memory allocations which might block writeback operations to utilize
memory reserves, it is likely that allocations from workqueue items
will no longer stall, even without depending on mmap_sem which is a
weakness of the OOM reaper.

Of course, there is no guarantee that allowing such GFP_NOFS / GFP_NOIO
allocations to utilize memory reserves always avoids OOM livelock. But
at least we don't need to give up GFP_NOFS / GFP_NOIO allocations
immediately without trying to utilize memory reserves.
Therefore, I object this comment

Michal Hocko wrote:
> +		/*
> +		 * XXX: GFP_NOFS allocations should rather fail than rely on
> +		 * other request to make a forward progress.
> +		 * We are in an unfortunate situation where out_of_memory cannot
> +		 * do much for this context but let's try it to at least get
> +		 * access to memory reserved if the current task is killed (see
> +		 * out_of_memory). Once filesystems are ready to handle allocation
> +		 * failures more gracefully we should just bail out here.
> +		 */
> +

that try to make !__GFP_FS allocations fail.

It is possible that such GFP_NOFS / GFP_NOIO allocations need to select
next OOM victim. If we add a guaranteed unlocking mechanism (the simplest
way is timeout), such GFP_NOFS / GFP_NOIO allocations will succeed, and
we can avoid loss of reliability of async write operations.

(By the way, can swap in/out work even if GFP_NOIO fails?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
