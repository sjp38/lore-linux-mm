Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B049E6B0012
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 11:47:13 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p5BFlAQU008587
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 08:47:10 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by wpaz37.hot.corp.google.com with ESMTP id p5BFl4CX007590
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 08:47:08 -0700
Received: by pvc21 with SMTP id 21so2114439pvc.11
        for <linux-mm@kvack.org>; Sat, 11 Jun 2011 08:47:03 -0700 (PDT)
Date: Sat, 11 Jun 2011 08:46:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.0rc2 oops in mem_cgroup_from_task
In-Reply-To: <20110611081937.GB7042@tiehlicka.suse.cz>
Message-ID: <alpine.LSU.2.00.1106110839270.29336@sister.anvils>
References: <20110609212956.GA2319@redhat.com> <20110611081937.GB7042@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>

The discussion in https://lkml.org/lkml/2011/6/9/538
has continued in https://lkml.org/lkml/2011/6/10/2

On Sat, 11 Jun 2011, Michal Hocko wrote:

> [Let's add some more people to CC]
> 
> On Thu 09-06-11 17:29:57, Dave Jones wrote:
> > 
> > I just got the oops below while building a kernel.
> > When it oopsed, the kernel modesetting oops-on-framebuffer thing
> > happened, and the box wedged solid for about a minute.
> > Then it woke up, and I was able to ctrl-f1 back to my X session
> > to capture the dmesg.   The stuff that follows the oops looks 
> > quite disturbing, but I think it's from hanging with interrupts off
> > for a minute.
> > 
> > 	Dave
> > 
> > general protection fault: 0000 [#1] PREEMPT SMP 
> > CPU 1 
> > Modules linked in: nfs fscache fuse nfsd lockd nfs_acl auth_rpcgss sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables btusb bluetooth arc4 zaurus dell_wmi sparse_keymap snd_usb_audio cdc_ether usbnet cdc_wdm mii snd_usbmidi_lib snd_rawmidi snd_hda_codec_hdmi snd_hda_codec_idt cdc_acm dell_laptop uvcvideo snd_hda_intel snd_hda_codec dcdbas snd_hwdep videodev microcode v4l2_compat_ioctl32 snd_seq snd_seq_device snd_pcm joydev iTCO_wdt i2c_i801 iTCO_vendor_support iwlagn pcspkr snd_timer mac80211 snd soundcore snd_page_alloc cfg80211 tg3 rfkill wmi virtio_net kvm_intel kvm ipv6 xts gf128mul dm_crypt i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
> > 
> > Pid: 34, comm: khugepaged Not tainted 3.0.0-rc2+ #72 Dell Inc. Adamo 13   /0N70T0
> > RIP: 0010:[<ffffffff81138590>]  [<ffffffff81138590>] task_subsys_state.constprop.30+0x16/0x78
> > RSP: 0018:ffff880135c97bd0  EFLAGS: 00010286
> > RAX: 6b6b6b6b6b6b6b6b RBX: ffff880013c48000 RCX: 0000000000000000
> > RDX: 0000000000000246 RSI: ffffffff81a26610 RDI: ffff880013c48000
> > RBP: ffff880135c97be0 R08: 0000000000000001 R09: 0000000000000000
> > R10: ffff880135c97cf0 R11: 0000000005491edb R12: ffff880013c48000
> > R13: 0000000000000200 R14: ffff880135c97ce8 R15: 0000000000000200
> > FS:  0000000000000000(0000) GS:ffff88013fc00000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 000000338f21400a CR3: 000000004f64c000 CR4: 00000000000406e0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process khugepaged (pid: 34, threadinfo ffff880135c96000, task ffff880135c98000)
> > Stack:
> >  ffff880013c48000 0000000000000200 ffff880135c97bf0 ffffffff81139792
> >  ffff880135c97cc0 ffffffff8113a75a ffff880135c96000 ffff88013fc00000
> >  ffff880135c98000 ffff880135c97c78 ffff880135c98000 00000000001d2c40
> > Call Trace:
> >  [<ffffffff81139792>] mem_cgroup_from_task+0x15/0x17
> >  [<ffffffff8113a75a>] __mem_cgroup_try_charge+0x148/0x4b4
> >  [<ffffffff810493f3>] ? need_resched+0x23/0x2d
> >  [<ffffffff814cbf43>] ? preempt_schedule+0x46/0x4f
> >  [<ffffffff8113afe8>] mem_cgroup_charge_common+0x9a/0xce
> >  [<ffffffff8113b6d1>] mem_cgroup_newpage_charge+0x5d/0x5f
> >  [<ffffffff81134024>] khugepaged+0x5da/0xfaf
> >  [<ffffffff81078ea0>] ? __init_waitqueue_head+0x4b/0x4b
> >  [<ffffffff81133a4a>] ? add_mm_counter.constprop.5+0x13/0x13
> >  [<ffffffff81078625>] kthread+0xa8/0xb0
> >  [<ffffffff814d13e8>] ? sub_preempt_count+0xa1/0xb4
> >  [<ffffffff814d5664>] kernel_thread_helper+0x4/0x10
> >  [<ffffffff814ce858>] ? retint_restore_args+0x13/0x13
> >  [<ffffffff8107857d>] ? __init_kthread_worker+0x5a/0x5a
> >  [<ffffffff814d5660>] ? gs_change+0x13/0x13
> > Code: ff 84 c0 74 b5 eb 03 45 31 e4 5a 5b 4c 89 e0 41 5c 41 5d 5d c3 55 48 89 e5 41 54 53 66 66 66 66 90 48 8b 87 90 12 00 00 49 89 fc 
> >  8b 58 50 e8 b4 d8 f3 ff 85 c0 74 4d 80 3d 8c e5 6a 01 00 75 
> > RIP  [<ffffffff81138590>] task_subsys_state.constprop.30+0x16/0x78
> >  RSP <ffff880135c97bd0>
> > psmouse.c: TouchPad at isa0060/serio1/input0 lost synchronization, throwing 1 bytes away.
> > iwlagn 0000:04:00.0: Queue 4 stuck for 10000 ms.
> > iwlagn 0000:04:00.0: On demand firmware reload
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 db c6 48 00 00 18 00
> > end_request: I/O error, dev sda, sector 366724680
> > Buffer I/O error on device dm-3, logical block 44179657
> > Buffer I/O error on device dm-3, logical block 44179658
> > Buffer I/O error on device dm-3, logical block 44179659
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11031834 (offset 0 size 12288 starting block 44179657)
> > ieee80211 phy0: Hardware restart was requested
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 db c7 80 00 00 18 00
> > end_request: I/O error, dev sda, sector 366724992
> > Buffer I/O error on device dm-3, logical block 44179696
> > Buffer I/O error on device dm-3, logical block 44179697
> > Buffer I/O error on device dm-3, logical block 44179698
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11031834 (offset 12288 size 12288 starting block 44179696)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 db c7 b8 00 00 18 00
> > end_request: I/O error, dev sda, sector 366725048
> > Buffer I/O error on device dm-3, logical block 44179703
> > Buffer I/O error on device dm-3, logical block 44179704
> > Buffer I/O error on device dm-3, logical block 44179705
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11031834 (offset 24576 size 12288 starting block 44179703)
> > ---[ end trace 95e652595eaf01aa ]---
> > psmouse.c: resync failed, issuing reconnect request
> > BUG: sleeping function called from invalid context at kernel/mutex.c:271
> > in_atomic(): 0, irqs_disabled(): 0, pid: 34, name: khugepaged
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 17 ee a0 00 00 50 00
> > end_request: I/O error, dev sda, sector 353889952
> > Buffer I/O error on device dm-3, logical block 42575316
> > Buffer I/O error on device dm-3, logical block 42575317
> > Buffer I/O error on device dm-3, logical block 42575318
> > Buffer I/O error on device dm-3, logical block 42575319
> > Buffer I/O error on device dm-3, logical block 42575320
> > Buffer I/O error on device dm-3, logical block 42575321
> > Buffer I/O error on device dm-3, logical block 42575322
> > Buffer I/O error on device dm-3, logical block 42575323
> > Buffer I/O error on device dm-3, logical block 42575324
> > Buffer I/O error on device dm-3, logical block 42575325
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 10629148 (offset 0 size 40960 starting block 42575316)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 d3 f8 40 00 00 20 00
> > end_request: I/O error, dev sda, sector 366213184
> > Buffer I/O error on device dm-3, logical block 44115720
> > Buffer I/O error on device dm-3, logical block 44115721
> > Buffer I/O error on device dm-3, logical block 44115722
> > Buffer I/O error on device dm-3, logical block 44115723
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11031693 (offset 0 size 16384 starting block 44115720)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 cf 69 80 00 00 10 00
> > end_request: I/O error, dev sda, sector 365914496
> > Buffer I/O error on device dm-3, logical block 44078384
> > Buffer I/O error on device dm-3, logical block 44078385
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11031978 (offset 0 size 8192 starting block 44078384)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 12 d5 00 00 00 18 00
> > end_request: I/O error, dev sda, sector 353555712
> > Buffer I/O error on device dm-3, logical block 42533536
> > Buffer I/O error on device dm-3, logical block 42533537
> > Buffer I/O error on device dm-3, logical block 42533538
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 10628547 (offset 0 size 12288 starting block 42533536)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 d3 fb a0 00 00 20 00
> > end_request: I/O error, dev sda, sector 366214048
> > Buffer I/O error on device dm-3, logical block 44115828
> > Buffer I/O error on device dm-3, logical block 44115829
> > Buffer I/O error on device dm-3, logical block 44115830
> > Buffer I/O error on device dm-3, logical block 44115831
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11031956 (offset 0 size 16384 starting block 44115828)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 dd dd 80 00 00 28 00
> > end_request: I/O error, dev sda, sector 366861696
> > Buffer I/O error on device dm-3, logical block 44196784
> > Buffer I/O error on device dm-3, logical block 44196785
> > Buffer I/O error on device dm-3, logical block 44196786
> > Buffer I/O error on device dm-3, logical block 44196787
> > Buffer I/O error on device dm-3, logical block 44196788
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11031940 (offset 0 size 20480 starting block 44196784)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 93 f1 78 00 00 18 00
> > end_request: I/O error, dev sda, sector 362017144
> > Buffer I/O error on device dm-3, logical block 43591215
> > Buffer I/O error on device dm-3, logical block 43591216
> > Buffer I/O error on device dm-3, logical block 43591217
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 10887935 (offset 0 size 12288 starting block 43591215)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 92 dc 60 00 00 10 00
> > end_request: I/O error, dev sda, sector 361946208
> > Buffer I/O error on device dm-3, logical block 43582348
> > Buffer I/O error on device dm-3, logical block 43582349
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 10887935 (offset 12288 size 8192 starting block 43582348)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 dd dd a8 00 00 28 00
> > end_request: I/O error, dev sda, sector 366861736
> > Buffer I/O error on device dm-3, logical block 44196789
> > Buffer I/O error on device dm-3, logical block 44196790
> > Buffer I/O error on device dm-3, logical block 44196791
> > Buffer I/O error on device dm-3, logical block 44196792
> > Buffer I/O error on device dm-3, logical block 44196793
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11031841 (offset 0 size 20480 starting block 44196789)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 dd dd d0 00 00 48 00
> > end_request: I/O error, dev sda, sector 366861776
> > Buffer I/O error on device dm-3, logical block 44196794
> > Buffer I/O error on device dm-3, logical block 44196795
> > Buffer I/O error on device dm-3, logical block 44196796
> > Buffer I/O error on device dm-3, logical block 44196797
> > Buffer I/O error on device dm-3, logical block 44196798
> > Buffer I/O error on device dm-3, logical block 44196799
> > Buffer I/O error on device dm-3, logical block 44196800
> > Buffer I/O error on device dm-3, logical block 44196801
> > Buffer I/O error on device dm-3, logical block 44196802
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11031992 (offset 0 size 36864 starting block 44196794)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 17 ee f0 00 00 48 00
> > end_request: I/O error, dev sda, sector 353890032
> > Buffer I/O error on device dm-3, logical block 42575326
> > Buffer I/O error on device dm-3, logical block 42575327
> > Buffer I/O error on device dm-3, logical block 42575328
> > Buffer I/O error on device dm-3, logical block 42575329
> > Buffer I/O error on device dm-3, logical block 42575330
> > Buffer I/O error on device dm-3, logical block 42575331
> > Buffer I/O error on device dm-3, logical block 42575332
> > Buffer I/O error on device dm-3, logical block 42575333
> > Buffer I/O error on device dm-3, logical block 42575334
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 10629931 (offset 0 size 36864 starting block 42575326)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 d3 fd c0 00 00 20 00
> > end_request: I/O error, dev sda, sector 366214592
> > Buffer I/O error on device dm-3, logical block 44115896
> > Buffer I/O error on device dm-3, logical block 44115897
> > Buffer I/O error on device dm-3, logical block 44115898
> > Buffer I/O error on device dm-3, logical block 44115899
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11011057 (offset 0 size 16384 starting block 44115896)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 cf 24 50 00 00 08 00
> > end_request: I/O error, dev sda, sector 365896784
> > Buffer I/O error on device dm-3, logical block 44076170
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11032013 (offset 0 size 4096 starting block 44076170)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 16 cf dc 20 00 00 08 00
> > end_request: I/O error, dev sda, sector 382721056
> > Buffer I/O error on device dm-3, logical block 46179204
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11535009 (offset 16384 size 4096 starting block 46179204)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 16 cf dc 40 00 00 08 00
> > end_request: I/O error, dev sda, sector 382721088
> > Buffer I/O error on device dm-3, logical block 46179208
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11535009 (offset 32768 size 4096 starting block 46179208)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 16 cf dc 60 00 00 08 00
> > end_request: I/O error, dev sda, sector 382721120
> > Buffer I/O error on device dm-3, logical block 46179212
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11535009 (offset 49152 size 4096 starting block 46179212)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 16 cf dc 78 00 00 08 00
> > end_request: I/O error, dev sda, sector 382721144
> > Buffer I/O error on device dm-3, logical block 46179215
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11535009 (offset 61440 size 4096 starting block 46179215)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 16 cf dc 90 00 00 10 00
> > end_request: I/O error, dev sda, sector 382721168
> > Buffer I/O error on device dm-3, logical block 46179218
> > Buffer I/O error on device dm-3, logical block 46179219
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11535009 (offset 73728 size 8192 starting block 46179218)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 16 cf dc c8 00 00 08 00
> > end_request: I/O error, dev sda, sector 382721224
> > Buffer I/O error on device dm-3, logical block 46179225
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11535009 (offset 102400 size 4096 starting block 46179225)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 16 cf dc f8 00 00 08 00
> > end_request: I/O error, dev sda, sector 382721272
> > Buffer I/O error on device dm-3, logical block 46179231
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11535009 (offset 126976 size 4096 starting block 46179231)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 10 af 80 00 00 10 00
> > end_request: I/O error, dev sda, sector 353415040
> > Buffer I/O error on device dm-3, logical block 42515952
> > Buffer I/O error on device dm-3, logical block 42515953
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 10628554 (offset 0 size 8192 starting block 42515952)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 d3 fe e0 00 00 20 00
> > end_request: I/O error, dev sda, sector 366214880
> > Buffer I/O error on device dm-3, logical block 44115932
> > Buffer I/O error on device dm-3, logical block 44115933
> > Buffer I/O error on device dm-3, logical block 44115934
> > Buffer I/O error on device dm-3, logical block 44115935
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11031999 (offset 0 size 16384 starting block 44115932)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 91 6e f0 00 00 10 00
> > end_request: I/O error, dev sda, sector 361852656
> > Buffer I/O error on device dm-3, logical block 43570654
> > Buffer I/O error on device dm-3, logical block 43570655
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 10896269 (offset 0 size 8192 starting block 43570654)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 10 b2 20 00 00 10 00
> > end_request: I/O error, dev sda, sector 353415712
> > Buffer I/O error on device dm-3, logical block 42516036
> > Buffer I/O error on device dm-3, logical block 42516037
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 10629161 (offset 0 size 8192 starting block 42516036)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 92 00 60 00 00 20 00
> > end_request: I/O error, dev sda, sector 361889888
> > Buffer I/O error on device dm-3, logical block 43575308
> > Buffer I/O error on device dm-3, logical block 43575309
> > Buffer I/O error on device dm-3, logical block 43575310
> > Buffer I/O error on device dm-3, logical block 43575311
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 10896254 (offset 0 size 16384 starting block 43575308)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  INFO: lockdep is turned off.
> > Pid: 34, comm: khugepaged Tainted: G      D     3.0.0-rc2+ #72
> > Call Trace:
> >  [<ffffffff8104d276>] __might_sleep+0x112/0x117
> >  [<ffffffff814cca48>] mutex_lock_nested+0x25/0x40
> >  [<ffffffff810ee9b7>] perf_event_exit_task+0x2d/0x1cd
> >  [<ffffffff8105ea1f>] do_exit+0x353/0x7fa
> >  [<ffffffff8105c569>] ? kmsg_dump+0x89/0x13c
> >  [<ffffffff814cf78d>] oops_end+0xbc/0xc5
> >  [<ffffffff8100d087>] die+0x5a/0x63
> >  [<ffffffff814cf18f>] do_general_protection+0x128/0x131
> >  [<ffffffff814cead5>] general_protection+0x25/0x30
> >  [<ffffffff81138590>] ? task_subsys_state.constprop.30+0x16/0x78
> >  [<ffffffff81139792>] mem_cgroup_from_task+0x15/0x17
> >  [<ffffffff8113a75a>] __mem_cgroup_try_charge+0x148/0x4b4
> >  [<ffffffff810493f3>] ? need_resched+0x23/0x2d
> >  [<ffffffff814cbf43>] ? preempt_schedule+0x46/0x4f
> >  [<ffffffff8113afe8>] mem_cgroup_charge_common+0x9a/0xce
> >  [<ffffffff8113b6d1>] mem_cgroup_newpage_charge+0x5d/0x5f
> >  [<ffffffff81134024>] khugepaged+0x5da/0xfaf
> >  [<ffffffff81078ea0>] ? __init_waitqueue_head+0x4b/0x4b
> >  [<ffffffff81133a4a>] ? add_mm_counter.constprop.5+0x13/0x13
> >  [<ffffffff81078625>] kthread+0xa8/0xb0
> >  [<ffffffff814d13e8>] ? sub_preempt_count+0xa1/0xb4
> >  [<ffffffff814d5664>] kernel_thread_helper+0x4/0x10
> >  [<ffffffff814ce858>] ? retint_restore_args+0x13/0x13
> >  [<ffffffff8107857d>] ? __init_kthread_worker+0x5a/0x5a
> >  [<ffffffff814d5660>] ? gs_change+0x13/0x13
> > Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 94 1b 40 00 00 18 00
> > end_request: I/O error, dev sda, sector 362027840
> > Buffer I/O error on device dm-3, logical block 43592552
> > Buffer I/O error on device dm-3, logical block 43592553
> > Buffer I/O error on device dm-3, logical block 43592554
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 10896287 (offset 0 size 12288 starting block 43592552)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 93 06 b0 00 00 10 00
> > end_request: I/O error, dev sda, sector 361957040
> > Buffer I/O error on device dm-3, logical block 43583702
> > Buffer I/O error on device dm-3, logical block 43583703
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 10896287 (offset 12288 size 8192 starting block 43583702)
> > sd 0:0:0:0: [sda] Unhandled error code
> > sd 0:0:0:0: [sda]  Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
> > sd 0:0:0:0: [sda] CDB: Write(10): 2a 00 15 d3 ff 40 00 00 20 00
> > end_request: I/O error, dev sda, sector 366214976
> > Buffer I/O error on device dm-3, logical block 44115944
> > Buffer I/O error on device dm-3, logical block 44115945
> > Buffer I/O error on device dm-3, logical block 44115946
> > Buffer I/O error on device dm-3, logical block 44115947
> > EXT4-fs warning (device dm-3): ext4_end_bio:242: I/O error writing to inode 11032040 (offset 0 size 16384 starting block 44115944)
> > JBD2: Detected IO errors while flushing file data on dm-3-8
> > --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
