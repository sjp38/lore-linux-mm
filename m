Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id AA5006B0044
	for <linux-mm@kvack.org>; Sun, 12 Aug 2012 16:23:03 -0400 (EDT)
Date: Sun, 12 Aug 2012 21:22:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/5] Improve hugepage allocation success rates under
 load V3
Message-ID: <20120812202257.GA4177@suse.de>
References: <1344520165-24419-1-git-send-email-mgorman@suse.de>
 <5023FE83.4090200@sandia.gov>
 <20120809204630.GJ12690@suse.de>
 <50243BE0.9060007@sandia.gov>
 <20120810110225.GO12690@suse.de>
 <502542C7.8050306@sandia.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <502542C7.8050306@sandia.gov>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Schutt <jaschut@sandia.gov>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 10, 2012 at 11:20:07AM -0600, Jim Schutt wrote:
> On 08/10/2012 05:02 AM, Mel Gorman wrote:
> >On Thu, Aug 09, 2012 at 04:38:24PM -0600, Jim Schutt wrote:
> 
> >>>
> >>>Ok, this is an untested hack and I expect it would drop allocation success
> >>>rates again under load (but not as much). Can you test again and see what
> >>>effect, if any, it has please?
> >>>
> >>>---8<---
> >>>mm: compaction: back out if contended
> >>>
> >>>---
> >>
> >><snip>
> >>
> >>Initial testing with this patch looks very good from
> >>my perspective; CPU utilization stays reasonable,
> >>write-out rate stays high, no signs of stress.
> >>Here's an example after ~10 minutes under my test load:
> >>
> 
> Hmmm, I wonder if I should have tested this patch longer,
> in view of the trouble I ran into testing the new patch?
> See below.
> 

The two patches are quite different in what they do. I think it's
unlikely they would share a common bug.

> > <SNIP>
> >---8<---
> >mm: compaction: Abort async compaction if locks are contended or taking too long
> 
> 
> Hmmm, while testing this patch, a couple of my servers got
> stuck after ~30 minutes or so, like this:
> 
> [ 2515.869936] INFO: task ceph-osd:30375 blocked for more than 120 seconds.
> [ 2515.876630] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 2515.884447] ceph-osd        D 0000000000000000     0 30375      1 0x00000000
> [ 2515.891531]  ffff8802e1a99e38 0000000000000082 ffff88056b38e298 ffff8802e1a99fd8
> [ 2515.899013]  ffff8802e1a98010 ffff8802e1a98000 ffff8802e1a98000 ffff8802e1a98000
> [ 2515.906482]  ffff8802e1a99fd8 ffff8802e1a98000 ffff880697d31700 ffff8802e1a84500
> [ 2515.913968] Call Trace:
> [ 2515.916433]  [<ffffffff8147fded>] schedule+0x5d/0x60
> [ 2515.921417]  [<ffffffff81480b25>] rwsem_down_failed_common+0x105/0x140
> [ 2515.927938]  [<ffffffff81480b73>] rwsem_down_write_failed+0x13/0x20
> [ 2515.934195]  [<ffffffff8124bcd3>] call_rwsem_down_write_failed+0x13/0x20
> [ 2515.940934]  [<ffffffff8147edc5>] ? down_write+0x45/0x50
> [ 2515.946244]  [<ffffffff81127b62>] sys_mprotect+0xd2/0x240
> [ 2515.951640]  [<ffffffff81489412>] system_call_fastpath+0x16/0x1b
> <SNIP>
> 
> I tried to capture a perf trace while this was going on, but it
> never completed.  "ps" on this system reports lots of kernel threads
> and some user-space stuff, but hangs part way through - no ceph
> executables in the output, oddly.
> 

ps is probably locking up because it's trying to access a proc file for
a process that is not releasing the mmap_sem.

> I can retest your earlier patch for a longer period, to
> see if it does the same thing, or I can do some other thing
> if you tell me what it is.
> 
> Also, FWIW I sorted a little through SysRq-T output from such
> a system; these bits looked interesting:
> 
> [ 3663.685097] INFO: rcu_sched self-detected stall on CPU { 17}  (t=60000 jiffies)
> [ 3663.685099] sending NMI to all CPUs:
> [ 3663.685101] NMI backtrace for cpu 0
> [ 3663.685102] CPU 0 Modules linked in: btrfs zlib_deflate ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa iw_cxgb4 dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath scsi_dh vhost_net macvtap macvlan tun uinput sg joydev sd_mod hid_generic coretemp hwmon kvm crc32c_intel ghash_clmulni_intel aesni_intel cryptd aes_x86_64 microcode serio_raw pcspkr ata_piix libata button mlx4_ib ib_mad ib_core mlx4_en mlx4_core mpt2sas scsi_transport_sas raid_class scsi_mod cxgb4 i2c_i801 i2c_core lpc_ich mfd_core ehci_hcd uhci_hcd i7core_edac edac_core dm_mod ioatdma nfs nfs_acl auth_rpcgss fscache lockd sunrpc broadcom tg3 bnx2 igb dca e1000 [last unloaded: scsi_wait_scan]
> [ 3663.685138]
> [ 3663.685140] Pid: 100027, comm: ceph-osd Not tainted 3.5.0-00019-g472719a #221 Supermicro X8DTH-i/6/iF/6F/X8DTH
> [ 3663.685142] RIP: 0010:[<ffffffff81480ed5>]  [<ffffffff81480ed5>] _raw_spin_lock_irqsave+0x45/0x60
> [ 3663.685148] RSP: 0018:ffff880a08191898  EFLAGS: 00000012
> [ 3663.685149] RAX: ffff88063fffcb00 RBX: ffff88063fffcb00 RCX: 00000000000000c5
> [ 3663.685149] RDX: 00000000000000bf RSI: 000000000000015a RDI: ffff88063fffcb00
> [ 3663.685150] RBP: ffff880a081918a8 R08: 0000000000000000 R09: 0000000000000000
> [ 3663.685151] R10: ffff88063fffcb98 R11: ffff88063fffcc38 R12: 0000000000000246
> [ 3663.685152] R13: ffff88063fffcba8 R14: ffff88063fffcb90 R15: ffff88063fffc680
> [ 3663.685153] FS:  00007fff90ae0700(0000) GS:ffff880627c00000(0000) knlGS:0000000000000000
> [ 3663.685154] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 3663.685155] CR2: ffffffffff600400 CR3: 00000002b8fbe000 CR4: 00000000000007f0
> [ 3663.685156] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 3663.685157] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 3663.685158] Process ceph-osd (pid: 100027, threadinfo ffff880a08190000, task ffff880a9a29ae00)
> [ 3663.685158] Stack:
> [ 3663.685159]  000000000000130a 0000000000000000 ffff880a08191948 ffffffff8111a760
> [ 3663.685162]  ffffffff81a13420 0000000000000009 ffffea000004c240 0000000000000000
> [ 3663.685165]  ffff88063fffcba0 000000003fffcb98 ffff880a08191a18 0000000000001600
> [ 3663.685168] Call Trace:
> [ 3663.685169]  [<ffffffff8111a760>] isolate_migratepages_range+0x150/0x4e0
> [ 3663.685173]  [<ffffffff8111a5b0>] ? isolate_freepages+0x330/0x330
> [ 3663.685175]  [<ffffffff8111af5b>] compact_zone+0x46b/0x4f0
> [ 3663.685178]  [<ffffffff8111b3f8>] compact_zone_order+0xe8/0x100
> [ 3663.685180]  [<ffffffff8111b4b6>] try_to_compact_pages+0xa6/0x110
> [ 3663.685182]  [<ffffffff81100339>] __alloc_pages_direct_compact+0xd9/0x250
> [ 3663.685187]  [<ffffffff81100883>] __alloc_pages_slowpath+0x3d3/0x750
> [ 3663.685190]  [<ffffffff81100d3e>] __alloc_pages_nodemask+0x13e/0x1d0
> [ 3663.685192]  [<ffffffff8113c894>] alloc_pages_vma+0x124/0x150
> [ 3663.685195]  [<ffffffff8114e065>] do_huge_pmd_anonymous_page+0xf5/0x1e0
> [ 3663.685199]  [<ffffffff81121bcd>] handle_mm_fault+0x21d/0x320
> [ 3663.685202]  [<ffffffff8124bca4>] ? call_rwsem_down_read_failed+0x14/0x30
> [ 3663.685205]  [<ffffffff81484e49>] do_page_fault+0x439/0x4a0
> [ 3663.685208]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
> [ 3663.685211]  [<ffffffff8148154f>] page_fault+0x1f/0x30

I went through the patch again but only found the following which is a
weak candidate. Still, can you retest with the following patch on top and
CONFIG_PROVE_LOCKING set please?

---8<---
diff --git a/mm/compaction.c b/mm/compaction.c
index 1827d9a..d4a51c6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -64,7 +64,7 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 {
 	if (need_resched() || spin_is_contended(lock)) {
 		if (locked) {
-			spin_unlock_irq(lock);
+			spin_unlock_irqrestore(lock, *flags);
 			locked = false;
 		}
 
@@ -276,8 +276,8 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 	list_for_each_entry(page, &cc->migratepages, lru)
 		count[!!page_is_file_cache(page)]++;
 
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
-	__mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
+	mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
+	mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
 }
 
 /* Similar to reclaim, but different enough that they don't share logic */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
