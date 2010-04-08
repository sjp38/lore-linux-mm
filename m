Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5DA59600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 11:23:58 -0400 (EDT)
Date: Thu, 8 Apr 2010 17:23:02 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 67] Transparent Hugepage Support #18
Message-ID: <20100408152302.GA5749@random.random>
References: <patchbomb.1270691443@v2.random>
 <4BBDA43F.5030309@redhat.com>
 <4BBDC181.5040205@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BBDC181.5040205@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 08, 2010 at 02:44:01PM +0300, Avi Kivity wrote:
> Results here are less than stellar.  While khugepaged is pulling pages 
> together, something is breaking them apart.  Even after memory pressure 
> is removed, this behaviour continues.  Can it be that compaction is 
> tearing down huge pages?

migrate will split hugepages, but memory compaction shouldn't migrate
hugepages... If it does I agree it needs fixing.

At the moment the main problem I'm having is that only way to run
stable for me is to stop at patch 48 (included). So it's something
wrong with memory compaction or migrate.

It crashes in migration_entry_to_page() here:

   BUG_ON(!PageLocked(p));

because p == ffffea06ac000000 and segfaults in reading p->flags inside
Pagelocked.

I recommend to run my git tree (aa.git) on your systems to exercise
migration and memory compaction to the maximum extent in the hope to
reproduce the below. Without transparent hugepage support there is no
chance to ever reproduce bugs in memory compaction.

If you want to be 100% safe and still use transparent hugepage just
stop at patch 48 (included) or checkout commit
e9f16129c80468cfd551ffc9cf92c9c46304195a instead of origin/master.
Hopefully memory compaction or migration will be fixed soon enough.

Thanks,
Andrea

Apr  8 08:02:57 v2 kernel: BUG: unable to handle kernel paging request at ffffea06ac000000
Apr  8 08:02:57 v2 kernel: IP: [<ffffffff810dc73d>] remove_migration_pte+0x19d/0x240
Apr  8 08:02:57 v2 kernel: PGD 20c9067 PUD 0 
Apr  8 08:02:57 v2 kernel: Oops: 0000 [#1] SMP 
Apr  8 08:02:57 v2 kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:12.0/host1/uevent
Apr  8 08:02:57 v2 kernel: CPU 1 
Apr  8 08:02:57 v2 kernel: Modules linked in: twofish twofish_common tun bridge stp llc bnep sco rfcomm l2cap bluetooth snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss usbhid gspca_pac207 gspca_main videodev v4l1_compat v4l2_compat_ioctl32 ohci_hcd snd_hda_codec_realtek ehci_hcd usbcore sr_mod pcspkr sg psmouse snd_hda_intel snd_hda_codec snd_pcm snd_timer snd snd_page_alloc
Apr  8 08:02:57 v2 kernel: 
Apr  8 08:02:57 v2 kernel: Pid: 18001, comm: python2.6 Not tainted 2.6.34-rc3 #6 M2A-VM/System Product Name
Apr  8 08:02:57 v2 kernel: RIP: 0010:[<ffffffff810dc73d>]  [<ffffffff810dc73d>] remove_migration_pte+0x19d/0x240
Apr  8 08:02:57 v2 kernel: RSP: 0000:ffff8800c55a79a8  EFLAGS: 00010206
Apr  8 08:02:57 v2 kernel: RAX: 000000000000001f RBX: ffffea0002487ba0 RCX: ffffea0000372658
Apr  8 08:02:57 v2 kernel: RDX: 000000000541d000 RSI: ffff8800d1ed4528 RDI: ffffea06ac000000
Apr  8 08:02:57 v2 kernel: RBP: ffffea0000532000 R08: 00000006ac000000 R09: 0000000000000000
Apr  8 08:02:57 v2 kernel: R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000000
Apr  8 08:02:57 v2 kernel: R13: ffff880017c000e8 R14: ffff88011ee5e470 R15: ffff88011ee5e468
Apr  8 08:02:57 v2 kernel: FS:  00007fc8f93136f0(0000) GS:ffff880001a80000(0000) knlGS:0000000055702bd0
Apr  8 08:02:57 v2 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Apr  8 08:02:57 v2 kernel: CR2: ffffea06ac000000 CR3: 000000000977a000 CR4: 00000000000006e0
Apr  8 08:02:57 v2 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Apr  8 08:02:57 v2 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Apr  8 08:02:57 v2 kernel: Process python2.6 (pid: 18001, threadinfo ffff8800c55a6000, task ffff8800096e32d0)
Apr  8 08:02:57 v2 kernel: Stack:
Apr  8 08:02:57 v2 kernel: ffff88011ddeb380 ffffea0000372658 000000000541d000 ffff8800d1ed4528
Apr  8 08:02:57 v2 kernel: <0> ffff8800d58f8d08 ffff8800d58d2f18 ffffea0002487ba0 ffffffff810dc5a0
Apr  8 08:02:57 v2 kernel: <0> ffffea0000372658 ffffffff810ca155 ffffffff81797580 ffff88011dd77618
Apr  8 08:02:57 v2 kernel: Call Trace:
Apr  8 08:02:57 v2 kernel: [<ffffffff810dc5a0>] ? remove_migration_pte+0x0/0x240
Apr  8 08:02:57 v2 kernel: [<ffffffff810ca155>] ? rmap_walk+0x135/0x180
Apr  8 08:02:57 v2 kernel: [<ffffffff810dcbe9>] ? migrate_page_copy+0xe9/0x190
Apr  8 08:02:57 v2 kernel: [<ffffffff810dd141>] ? migrate_pages+0x471/0x660
Apr  8 08:02:57 v2 kernel: [<ffffffff810dda40>] ? compaction_alloc+0x0/0x360
Apr  8 08:02:57 v2 kernel: [<ffffffff8100368e>] ? apic_timer_interrupt+0xe/0x20
Apr  8 08:02:57 v2 kernel: [<ffffffff810dd876>] ? compact_zone+0x406/0x500
Apr  8 08:02:57 v2 kernel: [<ffffffff810dde1b>] ? compact_zone_order+0x7b/0xb0
Apr  8 08:02:57 v2 kernel: [<ffffffff810ddf4d>] ? try_to_compact_pages+0xfd/0x170
Apr  8 08:02:57 v2 kernel: [<ffffffff810acc12>] ? __alloc_pages_nodemask+0x512/0x850
Apr  8 08:02:57 v2 kernel: [<ffffffff810e2808>] ? do_huge_pmd_wp_page+0x4b8/0x6e0
Apr  8 08:02:57 v2 kernel: [<ffffffff810c14a2>] ? handle_mm_fault+0x132/0x350
Apr  8 08:02:57 v2 kernel: [<ffffffff814f81ed>] ? do_page_fault+0x13d/0x420
Apr  8 08:02:57 v2 kernel: [<ffffffff814f52df>] ? page_fault+0x1f/0x30
Apr  8 08:02:57 v2 kernel: [<ffffffff812692dd>] ? __put_user_4+0x1d/0x30
Apr  8 08:02:57 v2 kernel: [<ffffffff814f52df>] ? page_fault+0x1f/0x30
Apr  8 08:02:57 v2 kernel: Code: 24 38 4c 8b 6c 24 40 48 83 c4 48 c3 49 b8 ff ff ff ff ff ff ff 07 4c 21 c7 4c 6b c7 38 48 bf 00 00 00 00 00 ea ff ff 49 8d 3c 38 <f6> 07 01 0f 84 8c 00 00 00 48 39 f9 75 ac f0 ff 43 08 66 83 3b 
Apr  8 08:02:57 v2 kernel: RIP  [<ffffffff810dc73d>] remove_migration_pte+0x19d/0x240
Apr  8 08:02:57 v2 kernel: RSP <ffff8800c55a79a8>
Apr  8 08:02:57 v2 kernel: CR2: ffffea06ac000000
Apr  8 08:02:57 v2 kernel: ---[ end trace 9bc19f8bd2737926 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
