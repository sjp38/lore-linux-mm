Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 262D86B0068
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 14:10:26 -0400 (EDT)
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q71IA7pI018408
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 1 Aug 2012 14:10:25 -0400
Date: Wed, 1 Aug 2012 13:34:15 -0400
From: Dave Jones <davej@redhat.com>
Subject: kernel BUG at include/linux/mm.h:277!
Message-ID: <20120801173415.GA8830@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: jglisse@redhat.com

We just had this report from a Fedora user.


kernel BUG at include/linux/mm.h:277!
invalid opcode: 0000 [#1] SMP 
Modules linked in: fuse ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter ip6_tables binfmt_misc snd_usb_audio snd_usbmidi_lib snd_hwdep snd_rawmidi arc4 snd_intel8x0 snd_intel8x0m uvcvideo snd_ac97_codec snd_seq_device videobuf2_vmalloc videobuf2_memops videobuf2_core videodev ath5k ath ac97_bus snd_pcm media mac80211 snd_page_alloc ppdev parport_pc snd_timer iTCO_wdt 3c59x dell_laptop mii parport cfg80211 snd rfkill soundcore iTCO_vendor_support dcdbas microcode yenta_socket video radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core [last unloaded: scsi_wait_scan]

Pid: 632, comm: Xorg Not tainted 3.4.6-2.fc17.i686.PAE #1 Dell Computer Corporation Latitude C640       
EIP: 0060:[<c0944a8d>] EFLAGS: 00213246 CPU: 0
EIP is at put_page_testzero.part.7+0x3/0x5
EAX: f6060140 EBX: f6060140 ECX: 00000002 EDX: 00000000
ESI: f6060140 EDI: b5648000 EBP: f3699e10 ESP: f3699e10
 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
CR0: 80050033 CR2: b55f1000 CR3: 36e20000 CR4: 000007f0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Process Xorg (pid: 632, ti=f3698000 task=f3613240 task.ti=f3698000)
Stack:
 f3699e18 c050449c f3699e24 c05292a2 f3699f0c f3699e34 c0518267 ec616240
 f6060140 f3699ec4 c0519689 0000a067 00000000 f3699f20 f8184d2a 00000001
 00000000 00000000 00100073 b5693fff b5694000 f6e20010 00000000 b5693fff
Call Trace:
 [<c050449c>] put_page+0x3c/0x50
 [<c05292a2>] free_page_and_swap_cache+0x22/0x50
 [<c0518267>] __tlb_remove_page+0x47/0xa0
 [<c0519689>] unmap_single_vma+0x419/0x700
 [<f8184d2a>]  ? drm_ioctl+0x3fa/0x480 [drm]
 [<c051a100>] unmap_vmas+0x50/0x90
 [<c051e7ed>] unmap_region+0x7d/0xf0
 [<c051f149>]  ?__split_vma+0xf9/0x1d0
 [<c051f71e>] do_munmap+0x20e/0x2c0
 [<c051f80d>] vm_munmap+0x3d/0x60
 [<c0520e2d>] sys_munmap+0x1d/0x20
 [<c095309f>] sysenter_do_call+0x12/0x28


That's the VM_BUG_ON(atomic_read(&page->_count) == 0); in put_page_testzero.

Radeon screwing up its refcounts maybe ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
