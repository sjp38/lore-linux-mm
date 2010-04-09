Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4481C60037E
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 11:44:59 -0400 (EDT)
Date: Fri, 9 Apr 2010 17:43:21 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Transparent Hugepage Support #19
Message-ID: <20100409154321.GB5708@random.random>
References: <patchbomb.1270691443@v2.random>
 <20100409020521.GA5740@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100409020521.GA5740@random.random>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Ok the below bug (that triggered without memory compaction) gone away
in #19 after backing out the anon-vma changes.

Apr  8 10:10:30 duo kernel: ------------[ cut here ]------------
Apr  8 10:10:30 duo kernel: kernel BUG at mm/huge_memory.c:1284!
Apr  8 10:10:30 duo kernel: invalid opcode: 0000 [#1] SMP 
Apr  8 10:10:30 duo kernel: last sysfs file: /sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0A:00/power_supply/BAT0/charge_full
Apr  8 10:10:30 duo kernel: CPU 1 
Apr  8 10:10:30 duo kernel: Modules linked in: tun coretemp bridge stp llc bnep sco rfcomm l2cap snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss btusb bluetooth usbhid acpi_cpufreq uvcvideo videodev v4l1_compat v4l2_compat_ioctl32 arc4 ecb snd_hda_codec_intelhdmi iwlagn snd_hda_codec_idt uhci_hcd iwlcore mac80211 ehci_hcd snd_hda_intel usbcore snd_hda_codec snd_pcm snd_timer cfg80211 sdhci_pci sdhci rfkill snd tg3 mmc_core sg pcspkr soundcore snd_page_alloc psmouse libphy led_class i2c_i801 [last unloaded: microcode]
Apr  8 10:10:30 duo kernel: 
Apr  8 10:10:30 duo kernel: Pid: 8604, comm: javac Not tainted 2.6.34-rc3 #15 0N6705/XPS M1330                       
Apr  8 10:10:30 duo kernel: RIP: 0010:[<ffffffff810e5bc3>]  [<ffffffff810e5bc3>] split_huge_page+0x593/0x5e0
Apr  8 10:10:30 duo kernel: RSP: 0018:ffff8800bdc71d98  EFLAGS: 00010297
Apr  8 10:10:30 duo kernel: RAX: 0000000000000001 RBX: ffffea00003fe000 RCX: 0000000000000002
Apr  8 10:10:30 duo kernel: RDX: 0000000000000000 RSI: ffff8800a93e0870 RDI: ffffea00003fe000
Apr  8 10:10:30 duo kernel: RBP: ffff8800ade2ca98 R08: 0000000000000000 R09: 0000000000000000
Apr  8 10:10:30 duo kernel: R10: 00003ffffffff278 R11: 00007f8ca71fdfff R12: fffffffffffffff2
Apr  8 10:10:30 duo kernel: R13: ffff8800a93e0870 R14: 0000000000000120 R15: ffff8800ade2cab8
Apr  8 10:10:30 duo kernel: FS:  00007f8ca72fb910(0000) GS:ffff880001b00000(0000) knlGS:0000000000000000
Apr  8 10:10:30 duo kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Apr  8 10:10:30 duo kernel: CR2: 00007f8ca71fada8 CR3: 0000000084546000 CR4: 00000000000006e0
Apr  8 10:10:30 duo kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Apr  8 10:10:30 duo kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Apr  8 10:10:30 duo kernel: Process javac (pid: 8604, threadinfo ffff8800bdc70000, task ffff880051ead910)
Apr  8 10:10:30 duo kernel: Stack:
Apr  8 10:10:30 duo kernel: 00000000bc638180 0000000000000000 00007f8ca71fe000 0000000000000000
Apr  8 10:10:30 duo kernel: <0> 00007f8ca71fb000 00000007f8ca71fb 0000000000004000 ffff8800ade2cab8
Apr  8 10:10:30 duo kernel: <0> ffff8800a0bb7720 ffff8800ade2cab0 ffff8800bc638180 ffffea00003fe000
Apr  8 10:10:30 duo kernel: Call Trace:
Apr  8 10:10:30 duo kernel: [<ffffffff810e5c81>] ? __split_huge_page_pmd+0x71/0xc0
Apr  8 10:10:30 duo kernel: [<ffffffff810cc0d2>] ? mprotect_fixup+0x332/0x740
Apr  8 10:10:30 duo kernel: [<ffffffff810cc635>] ? sys_mprotect+0x155/0x240
Apr  8 10:10:30 duo kernel: [<ffffffff81002e2b>] ? system_call_fastpath+0x16/0x1b
Apr  8 10:10:30 duo kernel: Code: eb fe 48 89 44 24 20 4c 89 e6 e8 09 5b ff ff 48 8b 44 24 20 e9 79 fb ff ff 48 8b 54 24 28 4c 89 e6 e8 92 5a ff ff e9 87 fb ff ff <0f> 0b eb fe 48 8b 03 a9 00 00 00 01 90 0f 84 da fb ff ff f3 90 
Apr  8 10:10:30 duo kernel: RIP  [<ffffffff810e5bc3>] split_huge_page+0x593/0x5e0
Apr  8 10:10:30 duo kernel: RSP <ffff8800bdc71d98>
Apr  8 10:10:30 duo kernel: ---[ end trace fe3fb34de5cea3c2 ]---

The other bug in remove_migration_pte I reproduced in #19 too and this
time I tracked it down and fixed it.

diff --git a/mm/migrate.c b/mm/migrate.c
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -100,6 +100,13 @@ static int remove_migration_pte(struct p
 		goto out;
 
 	pmd = pmd_offset(pud, addr);
+	if (pmd_trans_huge(*pmd)) {
+		/* verify this pmd isn't mapping our old page */
+		BUG_ON(!pmd_present(*pmd));
+		BUG_ON(PageTransCompound(old));
+		BUG_ON(pmd_page(*pmd) == old);
+		goto out;
+	}
 	if (!pmd_present(*pmd))
 		goto out;
 

The hotfix is already applied in aa.git origin/master branch. So with
current aa.git 8707120d97e7052ffb45f9879efce8e7bd361711 we're totally
stable again even with memory compaction enabled by default in direct
reclaim of transparent hugepage page faults. Enjoy! ;). As usual with
rebased branches you can just "git fetch; git checkout -f origin/master".

Now that all stability issues are sorted out I'll add numa awareness
to alloc_hugepage, something I deferred doing until we were stable
(again). Then I'll release #20.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
