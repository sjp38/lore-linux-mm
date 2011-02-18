Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DAF198D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 07:29:41 -0500 (EST)
Date: Fri, 18 Feb 2011 13:29:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
Message-ID: <20110218122938.GB26779@tiehlicka.suse.cz>
References: <20110216185234.GA11636@tiehlicka.suse.cz>
 <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
 <20110217090910.GA3781@tiehlicka.suse.cz>
 <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
 <20110217163531.GF14168@elte.hu>
 <m1pqqqfpzh.fsf@fess.ebiederm.org>
 <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 17-02-11 11:11:51, Linus Torvalds wrote:
> On Thu, Feb 17, 2011 at 10:57 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
> >
> > fedora 14
> > ext4 on all filesystems
> 
> Your dmesg snippets had ext3 mentioned, though:
> 
>   <6>EXT3-fs (sda1): recovery required on readonly filesystem
>   <6>EXT3-fs (sda1): write access will be enabled during recovery
>   <6>EXT3-fs: barriers not enabled
>   ..
>   <6>EXT3-fs (sda1): recovery complete
>   <6>EXT3-fs (sda1): mounted filesystem with ordered data mode
>   <6>dracut: Mounted root filesystem /dev/sda1
> 
> not that I see that it should matter, but there's been some bigger
> ext3 changes too (like the batched discard).
> 
> I don't really think ext3 is the issue, though.
> 
> > I was about to say this happens with DEBUG_PAGEALLOC enabled but it
> > appears that options keeps eluding my fingers when I have a few minutes
> > to play with it. ?Perhaps this time will be the charm.
> 
> Please do. You seem to be much better at triggering it than anybody
> else. And do the DEBUG_LIST and DEBUG_SLUB_ON things too (even if the
> DEBUG_LIST thing won't catch list_move())

I was able to reproduce (now it fired into dcopserver) with the
following simple test case:

while true
do
	rmmod iwl3945 iwlcore mac80211 cfg80211
	sleep 2
	modprobe iwl3945
done

Now, I will try with the 2 patches patches in this thread. I will also
turn on DEBUG_LIST and DEBUG_PAGEALLOC.

---
[35951.911197] cfg80211: Calling CRDA to update world regulatory domain
[35951.957782] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, in-tree:ds
[35951.957787] iwl3945: Copyright(c) 2003-2010 Intel Corporation
[35951.957866] iwl3945 0000:05:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[35951.957889] iwl3945 0000:05:00.0: setting latency timer to 64
[35951.999336] iwl3945 0000:05:00.0: Tunable channels: 13 802.11bg, 23 802.11a channels
[35951.999342] iwl3945 0000:05:00.0: Detected Intel Wireless WiFi Link 3945ABG
[35951.999492] iwl3945 0000:05:00.0: irq 42 for MSI/MSI-X
[35951.999737] PM: Adding info for No Bus:phy0
[35951.999791] ieee80211 phy0: Selected rate control algorithm 'iwl-3945-rs'
[35951.999902] PM: Adding info for No Bus:wlan0

[35953.641528] BUG: Bad page map in process dcopserver  pte:c5b8fe68 pmd:05b8f067
[35953.641539] addr:b739a000 vm_flags:08000075 anon_vma:  (null) mapping:c7d25dfc index:119
[35953.641551] vma->vm_ops->fault: filemap_fault+0x0/0x33d
[35953.641559] vma->vm_file->f_op->mmap: generic_file_mmap+0x0/0x42
[35953.641567] Pid: 11720, comm: dcopserver Not tainted 2.6.38-rc4-page-alloc-00001-g07409af #97
[35953.641573] Call Trace:
[35953.641585]  [<c01a6f50>] ? print_bad_pte+0x14b/0x15d
[35953.641593]  [<c01a97be>] ? unmap_vmas+0x3d4/0x648
[35953.641604]  [<c01ab43c>] ? exit_mmap+0xae/0x145
[35953.641613]  [<c0133395>] ? mmput+0x3c/0xb0
[35953.641621]  [<c0136ba4>] ? exit_mm+0x101/0x109
[35953.641629]  [<c0138477>] ? do_exit+0x1ce/0x60f
[35953.641638]  [<c014f7bd>] ? hrtimer_interrupt+0x130/0x1e2
[35953.641647]  [<c013891f>] ? do_group_exit+0x67/0x8a
[35953.641654]  [<c013895a>] ? sys_exit_group+0x18/0x1c
[35953.641662]  [<c0102890>] ? sysenter_do_call+0x12/0x26
[35953.641668] Disabling lock debugging due to kernel taint
[35953.641674] BUG: Bad page map in process dcopserver  pte:c5b8fe68 pmd:05b8f067
[35953.641681] addr:b739b000 vm_flags:08000075 anon_vma:  (null) mapping:c7d25dfc index:11a
[35953.641688] vma->vm_ops->fault: filemap_fault+0x0/0x33d
[35953.641695] vma->vm_file->f_op->mmap: generic_file_mmap+0x0/0x42
[35953.641701] Pid: 11720, comm: dcopserver Tainted: G    B       2.6.38-rc4-page-alloc-00001-g07409af #97
[35953.641708] Call Trace:
[35953.641715]  [<c01a6f50>] ? print_bad_pte+0x14b/0x15d
[35953.641723]  [<c01a97be>] ? unmap_vmas+0x3d4/0x648
[35953.641734]  [<c01ab43c>] ? exit_mmap+0xae/0x145
[35953.641741]  [<c0133395>] ? mmput+0x3c/0xb0
[35953.641748]  [<c0136ba4>] ? exit_mm+0x101/0x109
[35953.641756]  [<c0138477>] ? do_exit+0x1ce/0x60f
[35953.641764]  [<c014f7bd>] ? hrtimer_interrupt+0x130/0x1e2
[35953.641772]  [<c013891f>] ? do_group_exit+0x67/0x8a
[35953.641780]  [<c013895a>] ? sys_exit_group+0x18/0x1c
[35953.641787]  [<c0102890>] ? sysenter_do_call+0x12/0x26

[35962.064991] PM: Removing info for No Bus:wlan0
[35962.092070] PM: Removing info for No Bus:phy0
[35962.092327] iwl3945 0000:05:00.0: PCI INT A disabled

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
