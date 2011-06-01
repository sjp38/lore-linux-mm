Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 419866B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 22:03:33 -0400 (EDT)
Message-ID: <4DE59DE9.2050809@fnarfbargle.com>
Date: Wed, 01 Jun 2011 10:03:21 +0800
From: Brad Campbell <lists2009@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <4DE44333.9000903@fnarfbargle.com> <20110531054729.GA16852@liondog.tnic> <4DE4B432.1090203@fnarfbargle.com> <20110531103808.GA6915@eferding.osrc.amd.com> <4DE4FA2B.2050504@fnarfbargle.com> <alpine.LSU.2.00.1105311517480.21107@sister.anvils> <4DE589C5.8030600@fnarfbargle.com> <20110601011527.GN19505@random.random>
In-Reply-To: <20110601011527.GN19505@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Izik Eidus <ieidus@redhat.com>

On 01/06/11 09:15, Andrea Arcangeli wrote:
> Hello,
>
> On Wed, Jun 01, 2011 at 08:37:25AM +0800, Brad Campbell wrote:
>> On 01/06/11 06:31, Hugh Dickins wrote:
>>> Brad, my suspicion is that in each case the top 16 bits of RDX have been
>>> mysteriously corrupted from ffff to 0000, causing the general protection
>>> faults.  I don't understand what that has to do with KSM.
>>>
>>> But it's only a suspicion, because I can't make sense of the "Code:"
>>> lines in your traces, they have more than the expected 64 bytes, and
>>> only one of them has a ">" (with no"<") to mark faulting instruction.
>>>
>>> I did try compiling the 2.6.39 kernel from your config, but of course
>>> we have different compilers, so although I got close, it wasn't exact.
>>>
>>> Would you mind mailing me privately (it's about 73MB) the "objdump -trd"
>>> output for your original vmlinux (with KSM on)?  (Those -trd options are
>>> the ones I'm used to typing, I bet not they're not all relevant.)
>>>
>>> Of course, it's only a tiny fraction of that output that I need,
>>> might be better to cut it down to remove_rmap_item_from_tree and
>>> dup_fd and ksm_scan_thread, if you have the time to do so.
>>
>> Would you believe about 20 seconds after I pressed send the kernel oopsed.
>>
>> http://www.fnarfbargle.com/private/003_kernel_oops/
>>
>> oops reproduced here, but an un-munged version is in that directory
>> alongside the kernel.
>>
>> [36542.880228] general protection fault: 0000 [#1] SMP
>
> Reminds me of another oops that was reported on the kvm list for
> 2.6.38.1 with message id 4D8C6110.6090204. There the top 16 bits of
> rsi were flipped and it was a general protection too because of
> hitting on the not mappable virtual range.
>
> http://www.virtall.com/files/temp/kvm.txt
> http://www.virtall.com/files/temp/config-2.6.38.1
> http://virtall.com/files/temp/mmu-objdump.txt
>
> That oops happened in kvm_unmap_rmapp though, but it looked memory
> corruption (Avi suggested use after free) but it was a production
> system so we couldn't debug it further.
>
> I recommend next thing to reproduce again with 2.6.39 or
> 3.0.0-rc1. Let's fix your scsi trouble if needed but it's better you
> test with 2.6.39.
>
> We'd need chmod +r vmlinux on private/003_kernel_oops/

Ok, here we go then.

http://www.fnarfbargle.com/private/004_kernel_oops/

The permissions are right this time.
2.6.39 + KSM

[  694.227866] general protection fault: 0000 [#1] SMP
[  694.228001] last sysfs file: /sys/devices/platform/w83627ehf.656/cpu0_vid
[  694.228050] CPU 3
[  694.228091] Modules linked in: xt_iprange xt_DSCP xt_length 
xt_CLASSIFY sch_sfq xt_CHECKSUM ipt_REJECT ipt_MASQUERADE ipt_REDIRECT 
xt_recent xt_state iptable_filter iptable_nat nf_nat nf_conntrack_ipv4 
nf_conntrack nf_defrag_ipv4 xt_TCPMSS xt_tcpmss xt_tcpudp iptable_mangle 
ip_tables x_tables pppoe pppox ppp_generic slhc cls_u32 sch_htb deflate 
zlib_deflate des_generic cbc ecb crypto_blkcipher sha1_generic md5 hmac 
crypto_hash cryptomgr aead crypto_algapi af_key fuse w83627ehf hwmon_vid 
netconsole configfs vhost_net powernow_k8 mperf kvm_amd kvm pl2303 
usbserial i2c_piix4 k10temp xhci_hcd usb_storage usb_libusual ohci_hcd 
r8169 ehci_hcd ahci usbcore sata_mv mii libahci megaraid_sas [last 
unloaded: scsi_wait_scan]
[  694.230897]
[  694.230944] Pid: 11841, comm: keepalive Not tainted 2.6.39 #3 To Be 
Filled By O.E.M. To Be Filled By O.E.M./880G Extreme3
[  694.231111] RIP: 0010:[<ffffffff810db878>]  [<ffffffff810db878>] 
dup_fd+0x168/0x300
[  694.231210] RSP: 0018:ffff8802f524fdd0  EFLAGS: 00010206
[  694.231258] RAX: 00000000000007f8 RBX: ffff8802f5721b80 RCX: 
bfffffffffffffff
[  694.231308] RDX: 00008802f51cacc0 RSI: 00000000000000ff RDI: 
0000000000000800
[  694.231358] RBP: ffff8803bf419800 R08: ffff88030167f6c0 R09: 
0000000000000003
[  694.231407] R10: 0000000000000001 R11: 4000000000000000 R12: 
0000000000000100
[  694.231457] R13: ffff880417aa9800 R14: ffff88030167f440 R15: 
ffff8803bd8c1600
[  694.231507] FS:  00007f02cfc32700(0000) GS:ffff88041fcc0000(0000) 
knlGS:0000000000000000
[  694.231560] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  694.231609] CR2: 00007f02cf5d4810 CR3: 00000002f52c3000 CR4: 
00000000000006e0
[  694.231657] DR0: 0000000000000045 DR1: 0000000000000000 DR2: 
0000000000000000
[  694.231707] DR3: 0000000000000005 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[  694.231757] Process keepalive (pid: 11841, threadinfo 
ffff8802f524e000, task ffff8802f5143690)
[  694.231809] Stack:
[  694.231852]  ffff8802f5143690 0000000000000020 ffff8802f56badc0 
ffff8802f5721b90
[  694.232050]  ffff880417aa54e0 0000000001200011 ffff880417aa54e0 
0000000000000000
[  694.232248]  00007f02cfc329d0 ffff8802f5143690 0000000000000000 
ffffffff81037645
[  694.232448] Call Trace:
[  694.232499]  [<ffffffff81037645>] ? copy_process+0xa75/0xfd0
[  694.232549]  [<ffffffff81037c0d>] ? do_fork+0x6d/0x2b0
[  694.232599]  [<ffffffff810457a9>] ? sigprocmask+0x69/0x100
[  694.232651]  [<ffffffff813d0ca3>] ? stub_clone+0x13/0x20
[  694.232699]  [<ffffffff813d0a3b>] ? system_call_fastpath+0x16/0x1b
[  694.232745] Code: 4c 89 c2 e8 6b e5 0f 00 45 85 e4 74 78 41 8d 44 24 
ff 31 f6 41 ba 01 00 00 00 48 8d 3c c5 08 00 00 00 31 c0 eb 1a 0f 1f 44 
00 00 <f0> 48 ff 42 30 48 89 54 05 00 48 83 c0 08 ff c6 48 39 f8 74 3b
[  694.235190] RIP  [<ffffffff810db878>] dup_fd+0x168/0x300
[  694.235282]  RSP <ffff8802f524fdd0>
[  694.235379] ---[ end trace 949fad05591fcdb3 ]---
[  694.235428] Kernel panic - not syncing: Fatal exception
[  694.235478] Pid: 11841, comm: keepalive Tainted: G      D     2.6.39 #3
[  694.235525] Call Trace:
[  694.235573]  [<ffffffff813cd6f5>] ? panic+0x92/0x18a
[  694.235624]  [<ffffffff81038b61>] ? kmsg_dump+0x41/0xf0
[  694.235676]  [<ffffffff810050ad>] ? oops_end+0x8d/0xa0
[  694.235726]  [<ffffffff813d05ef>] ? general_protection+0x1f/0x30
[  694.235778]  [<ffffffff810db878>] ? dup_fd+0x168/0x300
[  694.235827]  [<ffffffff81037645>] ? copy_process+0xa75/0xfd0
[  694.235877]  [<ffffffff81037c0d>] ? do_fork+0x6d/0x2b0
[  694.235926]  [<ffffffff810457a9>] ? sigprocmask+0x69/0x100
[  694.235978]  [<ffffffff813d0ca3>] ? stub_clone+0x13/0x20
[  694.236028]  [<ffffffff813d0a3b>] ? system_call_fastpath+0x16/0x1b
[  694.236083] Rebooting in 60 seconds..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
