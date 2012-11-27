Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 28B836B0062
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 13:27:43 -0500 (EST)
Date: Tue, 27 Nov 2012 13:27:38 -0500
From: Dave Jones <davej@redhat.com>
Subject: BUG_ON(inode->i_blocks);
Message-ID: <20121127182738.GA13608@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Fedora Kernel Team <kernel-team@fedoraproject.org>

Hugh,

We had a user report hitting the BUG_ON at the end of shmem_evict_inode.
I see in 3.7 you changed this to a WARN instead.

Does the trace below match the one you described chasing in commit 0f3c42f522dc1ad7e27affc0a4aa8c790bce0a66 ?

Full report at https://bugzilla.redhat.com/show_bug.cgi?id=879422, though
there's not much more than the trace tbh.

	Dave


:kernel BUG at mm/shmem.c:657!
:invalid opcode: 0000 [#1] SMP 
:Modules linked in: udf hid_logitech_dj des_generic md4 cifs dns_resolver fscache nls_utf8 lockd sunrpc bnep bluetooth rfkill ip6t_REJECT nf_conntrack_ipv6 nf_conntrack_netbios_ns nf_conntrack_broadcast nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 ip6table_filter xt_state nf_conntrack ip6_tables fuse snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_seq snd_seq_device snd_hwdep snd_pcm snd_page_alloc snd_timer iTCO_wdt snd soundcore iTCO_vendor_support serio_raw atl1 mii lpc_ich mfd_core i2c_i801 asus_atk0110 coretemp kvm_intel kvm microcode uinput ata_generic pata_acpi firewire_ohci firewire_core crc_itu_t usb_storage pata_jmicron nouveau mxm_wmi wmi video i2c_algo_bit drm_kms_helper ttm drm i2c_core
:CPU 1 
:Pid: 1017, comm: kwin Not tainted 3.6.6-1.fc17.x86_64 #1 System manufacturer P5E-VM HDMI/P5E-VM HDMI
:RIP: 0010:[<ffffffff81145792>]  [<ffffffff81145792>] shmem_evict_inode+0x112/0x120
:RSP: 0018:ffff88012b94ddb8  EFLAGS: 00010282
:RAX: 0000000050aeab47 RBX: ffff880117a424a8 RCX: 0000000000000018
:RDX: 000000001fea11fd RSI: 0000000005537c1c RDI: ffffffff81f1d500
:RBP: ffff88012b94ddd8 R08: 0000000000000000 R09: 0000000000000000
:R10: 0000000000000000 R11: 0000000000000000 R12: ffff880117a424a8
:R13: ffff880117a424a8 R14: ffff880117a424b8 R15: ffff880139a79220
:FS:  00007fa606014880(0000) GS:ffff88013fc80000(0000) knlGS:0000000000000000
:CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
:CR2: 00007fa5f0021010 CR3: 000000012c2d0000 CR4: 00000000000007e0
:DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
:DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
:Process kwin (pid: 1017, threadinfo ffff88012b94c000, task ffff880134f30000)
:Stack:
: ffff880117a424b8 ffff880117a425b0 ffffffff81812f80 ffffffff81812f80
: ffff88012b94de08 ffffffff811a8da2 ffff88012b94dde8 ffff880117a424b8
: ffff880117a42540 ffff880139a34000 ffff88012b94de38 ffffffff811a8fa3
:Call Trace:
: [<ffffffff811a8da2>] evict+0xa2/0x1a0
: [<ffffffff811a8fa3>] iput+0x103/0x1f0
: [<ffffffff811a50e8>] d_kill+0xd8/0x110
: [<ffffffff811a5782>] dput+0xe2/0x1b0
: [<ffffffff811900d6>] __fput+0x166/0x240
: [<ffffffff811901be>] ____fput+0xe/0x10
: [<ffffffff8107beab>] task_work_run+0x6b/0x90
: [<ffffffff81013921>] do_notify_resume+0x71/0xb0
: [<ffffffff81625be2>] int_signal+0x12/0x17
:Code: c7 80 1c c4 81 e8 8f 5a 4d 00 48 89 df e8 77 80 1a 00 49 89 5e e0 49 89 5e e8 48 c7 c7 80 1c c4 81 e8 13 5a 4d 00 e9 1c ff ff ff <0f> 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 41 57 41 
:RIP  [<ffffffff81145792>] shmem_evict_inode+0x112/0x120
: RSP <ffff88012b94ddb8>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
