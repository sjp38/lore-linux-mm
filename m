Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD076B0023
	for <linux-mm@kvack.org>; Tue, 31 May 2011 20:37:43 -0400 (EDT)
Message-ID: <4DE589C5.8030600@fnarfbargle.com>
Date: Wed, 01 Jun 2011 08:37:25 +0800
From: Brad Campbell <lists2009@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <4DE44333.9000903@fnarfbargle.com> <20110531054729.GA16852@liondog.tnic> <4DE4B432.1090203@fnarfbargle.com> <20110531103808.GA6915@eferding.osrc.amd.com> <4DE4FA2B.2050504@fnarfbargle.com> <alpine.LSU.2.00.1105311517480.21107@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1105311517480.21107@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>

On 01/06/11 06:31, Hugh Dickins wrote:
> Brad, my suspicion is that in each case the top 16 bits of RDX have been
> mysteriously corrupted from ffff to 0000, causing the general protection
> faults.  I don't understand what that has to do with KSM.
>
> But it's only a suspicion, because I can't make sense of the "Code:"
> lines in your traces, they have more than the expected 64 bytes, and
> only one of them has a ">" (with no"<") to mark faulting instruction.
>
> I did try compiling the 2.6.39 kernel from your config, but of course
> we have different compilers, so although I got close, it wasn't exact.
>
> Would you mind mailing me privately (it's about 73MB) the "objdump -trd"
> output for your original vmlinux (with KSM on)?  (Those -trd options are
> the ones I'm used to typing, I bet not they're not all relevant.)
>
> Of course, it's only a tiny fraction of that output that I need,
> might be better to cut it down to remove_rmap_item_from_tree and
> dup_fd and ksm_scan_thread, if you have the time to do so.

Would you believe about 20 seconds after I pressed send the kernel oopsed.

http://www.fnarfbargle.com/private/003_kernel_oops/

oops reproduced here, but an un-munged version is in that directory 
alongside the kernel.

[36542.880228] general protection fault: 0000 [#1] SMP
[36542.880271] last sysfs file: 
/sys/devices/pci0000:00/0000:00:18.3/temp1_input
[36542.880290] CPU 4
[36542.880301] Modules linked in: xt_iprange xt_DSCP xt_length 
xt_CLASSIFY sch_sfq xt_CHECKSUM ipt_REJECT ipt_MASQUER
ADE ipt_REDIRECT xt_recent xt_state iptable_filter iptable_nat nf_nat 
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 x
t_TCPMSS xt_tcpmss xt_tcpudp iptable_mangle ip_tables x_tables pppoe 
pppox ppp_generic slhc cls_u32 sch_htb deflate z
lib_deflate des_generic cbc ecb crypto_blkcipher sha1_generic md5 hmac 
crypto_hash cryptomgr aead crypto_algapi af_ke
y fuse hwmon_vid netconsole configfs vhost_net powernow_k8 mperf kvm_amd 
kvm pl2303 usbserial xhci_hcd k10temp i2c_pi
ix4 ahci usb_storage usb_libusual ohci_hcd ehci_hcd r8169 libahci 
usbcore mii sata_mv megaraid_sas [last unloaded: sc
si_wait_scan]
[36542.880842]
[36542.880858] Pid: 13346, comm: bash Not tainted 2.6.38.7 #29 To Be 
Filled By O.E.M. To Be Filled By O.E.M./880G Ext
reme3
[36542.880911] RIP: 0010:[<ffffffff810cf0de>]  [<ffffffff810cf0de>] 
do_vfs_ioctl+0x5e/0x510
[36542.880948] RSP: 0018:ffff8802d25a1ec8  EFLAGS: 00010206
[36542.880965] RAX: fffffffffffffff7 RBX: 000088040eb12840 RCX: 
00007fff4fe4a4c0
[36542.880984] RDX: 0000000000005413 RSI: 0000000000005413 RDI: 
00000000000000ff
[36542.881002] RBP: 00000000000000ff R08: 00007fff4fe4a400 R09: 
0000000000000000
[36542.881020] R10: 00007fff4fe4a380 R11: 0000000000000246 R12: 
00007fff4fe4a4c0
[36542.881038] R13: 00007fff4fe4a4c0 R14: 0000000000000000 R15: 
0000000000000001
[36542.881058] FS:  00007f65f725b700(0000) GS:ffff8800dbd00000(0000) 
knlGS:0000000000000000
[36542.881081] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[36542.881098] CR2: 0000000001f01008 CR3: 00000002d25c3000 CR4: 
00000000000006e0
[36542.881116] DR0: 00000000000000a0 DR1: 0000000000000000 DR2: 
0000000000000003
[36542.881133] DR3: 00000000000000b0 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[36542.881152] Process bash (pid: 13346, threadinfo ffff8802d25a0000, 
task ffff88041df88000)
[36542.881172] Stack:
[36542.881183]  0000000000000000 ffff88041df88218 0000000000100000 
0000000000000001
[36542.881225]  0000000000000002 00007fff4fe4a2c0 00007fff4fe4a220 
0000000000000002
[36542.881268]  0000000000000000 ffffffff81046d6a 000088040eb12840 
00000000000000ff
[36542.881312] Call Trace:
[36542.881333]  [<ffffffff81046d6a>] ? sys_rt_sigaction+0x8a/0xc0
[36542.881351]  [<ffffffff810cf5d9>] ? sys_ioctl+0x49/0x80
[36542.881373]  [<ffffffff810023fb>] ? system_call_fastpath+0x16/0x1b
[36542.881389] Code: 76 7b 81 fa 77 58 04 c0 0f 84 77 01 00 00 0f 1f 80 
00 00 00 00 0f 87 a2 00 00 00 81 fa 60 54 00 00 0f 1f 40 00 0f 84 ba 01 
00 00 <48> 8b 43 18 48 8b 50 30 0f b7 02 25 00 f0 00 00 3d 00 80 00 00
[36542.881793] RIP  [<ffffffff810cf0de>] do_vfs_ioctl+0x5e/0x510
[36542.881818]  RSP <ffff8802d25a1ec8>
[36542.882082] ---[ end trace 1b8d730cd479e388 ]---
[36542.882126] Kernel panic - not syncing: Fatal exception
[36542.882175] Pid: 13346, comm: bash Tainted: G      D     2.6.38.7 #29
[36542.882222] Call Trace:
[36542.882269]  [<ffffffff813c7f42>] ? panic+0x92/0x18a
[36542.882318]  [<ffffffff81039a41>] ? kmsg_dump+0x41/0xf0
[36542.882366]  [<ffffffff810062bd>] ? oops_end+0x8d/0xa0
[36542.882414]  [<ffffffff813caeef>] ? general_protection+0x1f/0x30
[36542.882463]  [<ffffffff810cf0de>] ? do_vfs_ioctl+0x5e/0x510
[36542.882511]  [<ffffffff81046d6a>] ? sys_rt_sigaction+0x8a/0xc0
[36542.882560]  [<ffffffff810cf5d9>] ? sys_ioctl+0x49/0x80
[36542.882608]  [<ffffffff810023fb>] ? system_call_fastpath+0x16/0x1b
[36542.882688] Rebooting in 60 seconds..[   33.104725] fuse init (API 
version 7.16)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
