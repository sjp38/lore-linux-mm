Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E2F8D6B0032
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 12:40:40 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id lb1so8518573pab.12
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 09:40:40 -0700 (PDT)
Received: by mail-vc0-f174.google.com with SMTP id gd11so5390523vcb.5
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 09:40:37 -0700 (PDT)
Message-ID: <5239D77E.7050403@gmail.com>
Date: Wed, 18 Sep 2013 12:40:30 -0400
From: Dan Merillat <dan.merillat@gmail.com>
MIME-Version: 1.0
Subject: Re: mm: gpf in find_vma
References: <522B9B5D.4010207@oracle.com>
In-Reply-To: <522B9B5D.4010207@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, walken@google.com, riel@redhat.com, hughd@google.com, khlebnikov@openvz.org, trinity@vger.kernel.org

Resent due to Thunderbird completely mangling it the first time around:
(Apologies if this is a third copy, gmail told me it didn't send)

On 09/07/2013 05:32 PM, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest, running latest
> -next kernel, I've
> stumbled on the following:
> 

> The disassembly is:
> 
>         /* Check the cache first. */
>         /* (Cache hit rate is typically around 35%.) */
>         vma = ACCESS_ONCE(mm->mmap_cache);
>      1f9:       48 8b 47 10             mov    0x10(%rdi),%rax
>         if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
>      1fd:       48 85 c0                test   %rax,%rax
>      200:       74 0b                   je     20d <find_vma+0x1d>
>      202:       48 39 70 08             cmp    %rsi,0x8(%rax)    <--- here
>      206:       76 05                   jbe    20d <find_vma+0x1d>
>      208:       48 3b 30                cmp    (%rax),%rsi
>      20b:       73 4d                   jae    25a <find_vma+0x6a>

I may have hit the same thing earlier this morning:
  191:       48 8b 47 08             mov    0x8(%rdi),%rax
  195:       31 d2                   xor    %edx,%edx
  197:       48 85 c0                test   %rax,%rax
  19a:       74 1c                   je     1b8 <find_vma+0x3f>
  19c:       48 39 70 e8             cmp    %rsi,-0x18(%rax)    <-- here
  1a0:       76 10                   jbe    1b2 <find_vma+0x39>
  1a2:       48 39 70 e0             cmp    %rsi,-0x20(%rax)
  1a6:       48 8d 50 e0             lea    -0x20(%rax),%rdx
  1aa:       76 14                   jbe    1c0 <find_vma+0x47>

Except I got there via munmap():

Sep 18 04:58:04 kernel: [563331.668961] general protection fault: 0000 [#1] PREEMPT SMP
Sep 18 04:58:04 kernel: [563331.669009] Modules linked in: sha1_generic cts powernow_k8 nfnetlink_queue nfnetlink_log binfmt_misc rpcsec_gss_krb5 fuse it87 hwmon_vid loop pl2303 usbserial vhost_net tun vhost kvm_amd kvm hid_generic snd_hda_codec_hdmi snd_hda_codec_realtek pcspkr rtc_cmos snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_seq snd_seq_device wmi snd_timer mperf radeon drm_kms_helper snd ttm drm backlight i2c_algo_bit i2c_piix4 k8temp soundcore i2c_core snd_page_alloc ohci_pci ohci_hcd ide_pci_generic firewire_ohci firewire_core ehci_pci atiixp ide_core pata_acpi ehci_hcd
Sep 18 04:58:04 kernel: [563331.669009] CPU: 0 PID: 3937 Comm: Xorg Not tainted 3.11.0-rc6-dan #1
Sep 18 04:58:04 kernel: [563331.669009] Hardware name: Gigabyte Technology Co., Ltd. GA-MA78GPM-DS2H/GA-MA78GPM-DS2H, BIOS F6h 12/25/2010
Sep 18 04:58:04 kernel: [563331.669009] task: ffff88021d8f9700 ti: ffff88021d66a000 task.ti: ffff88021d66a000
Sep 18 04:58:04 kernel: [563331.669009] RIP: 0010:[<ffffffff810e9305>]  [<ffffffff810e9305>] find_vma+0x23/0x50
Sep 18 04:58:04 kernel: [563331.669009] RSP: 0018:ffff88021d66bed0  EFLAGS: 00010206
Sep 18 04:58:04 kernel: [563331.669009] RAX: 00ff8801e8e00ba0 RBX: ffff880212a3f0c0 RCX: 0000000000000000
Sep 18 04:58:04 kernel: [563331.669009] RDX: ffff8801ae075f18 RSI: 00007feef8258000 RDI: ffff880212a3f0c0
Sep 18 04:58:04 kernel: [563331.669009] RBP: ffff88021d66bed0 R08: 0000000000000000 R09: 00000000000000d1
Sep 18 04:58:04 kernel: [563331.669009] R10: 0000000000000000 R11: 0000000000000206 R12: ffff880212a3f0c0
Sep 18 04:58:04 kernel: [563331.669009] R13: 00007feef8258000 R14: 0000000000001000 R15: 00007feef8258000
Sep 18 04:58:04 kernel: [563331.669009] FS:  00007feefe54b880(0000) GS:ffff880227c00000(0000) knlGS:00000000f2640980
Sep 18 04:58:04 kernel: [563331.669009] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Sep 18 04:58:04 kernel: [563331.669009] CR2: 00007feef7486000 CR3: 00000002113d3000 CR4: 00000000000007f0
Sep 18 04:58:04 kernel: [563331.669009] Stack:
Sep 18 04:58:04 kernel: [563331.669009]  ffff88021d66bf20 ffffffff810eace0 ffff88021e23a420 ffff88021b411600
Sep 18 04:58:04 kernel: [563331.669009]  00007feef8258000 ffff880212a3f110 ffff880212a3f0c0 00007feef8258000
Sep 18 04:58:04 kernel: [563331.669009]  0000000000001000 000000000000002f ffff88021d66bf58 ffffffff810eaf1e
Sep 18 04:58:04 kernel: [563331.669009] Call Trace:
Sep 18 04:58:04 kernel: [563331.669009]  [<ffffffff810eace0>] do_munmap+0xdd/0x2de
Sep 18 04:58:04 kernel: [563331.669009]  [<ffffffff810eaf1e>] vm_munmap+0x3d/0x56
Sep 18 04:58:04 kernel: [563331.669009]  [<ffffffff810eaf55>] SyS_munmap+0x1e/0x24
Sep 18 04:58:04 kernel: [563331.669009]  [<ffffffff81549e96>] system_call_fastpath+0x1a/0x1f
Sep 18 04:58:04 kernel: [563331.669009] Code: 85 c9 74 cb eb e4 5d c3 48 8b 47 10 55 48 89 e5 48 85 c0 74 0b 48 39 70 08 76 05 48 39 30 76 36 48 8b 47 08 31 d2 48 85 c0 74 1c <48> 39 70 e8 76 10 48 39 70 e0 48 8d 50 e0 76 14 48 8b 40 10 eb
Sep 18 04:58:04 kernel: [563331.669009] RIP  [<ffffffff810e9305>] find_vma+0x23/0x50
Sep 18 04:58:04 kernel: [563331.669009]  RSP <ffff88021d66bed0>
Sep 18 04:58:04 kernel: [563331.690510] ---[ end trace 0b78e99bd4849eb8 ]---

This is possibly related, same machine, same path, same origin (Xorg,
probably cookie clicker causing lots of allocation churn on both bugs)
but an older kernel:

Sep 11 13:17:33 kernel: [12808122.743464] general protection fault: 0000 [#3] PREEMPT SMP
Sep 11 13:17:33 kernel: [12808122.746610] Modules linked in: uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core videodev iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack ip_tables x_tables pl2303 usbserial nfnetlink_queue nfnetlink_log ntfs msdos reiserfs ext4 jbd2 ext3 jbd fuse arc4 ecb md4 sha256_generic nls_utf8 cifs fscache cdc_acm efivars nls_cp437 vfat fat sg usb_storage binfmt_misc rpcsec_gss_krb5 it87 hwmon_vid loop hid_generic snd_hda_codec_hdmi snd_hda_codec_realtek powernow_k8 kvm_amd kvm pcspkr k8temp snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_page_alloc snd_seq snd_seq_device snd_timer i2c_piix4 rtc_cmos radeon snd drm_kms_helper ehci_pci ttm drm backlight i2c_algo_bit i2c_core wmi soundcore ide_pci_generic atiixp ide_core firewire_ohci firewire_core pata_acpi ohci_hcd ehci_hcd
Sep 11 13:17:33 kernel: [12808122.751214] CPU 1
Sep 11 13:17:33 kernel: [12808122.751214] Pid: 5692, comm: Xorg Tainted: G      D      3.9.0-rc7-dan #6 Gigabyte Technology Co., Ltd. GA-MA78GPM-DS2H/GA-MA78GPM-DS2H
Sep 11 13:17:33 kernel: [12808122.751214] RIP: 0010:[<ffffffff812abc64>]  [<ffffffff812abc64>] __rb_erase_color+0x148/0x215
Sep 11 13:17:33 kernel: [12808122.751214] RSP: 0018:ffff880208529e58  EFLAGS: 00010206
Sep 11 13:17:33 kernel: [12808122.751214] RAX: 00ff88021df483b8 RBX: ffff88015c87d248 RCX: ffff88015c87d450
Sep 11 13:17:33 kernel: [12808122.751214] RDX: 0000000000000000 RSI: ffff8802080f5048 RDI: ffff88015c87d248
Sep 11 13:17:33 kernel: [12808122.751214] RBP: ffff880208529e80 R08: ffff88015c87d238 R09: 0000000000003bd0
Sep 11 13:17:33 kernel: [12808122.751214] R10: 0000000000000000 R11: 0000000000003206 R12: ffff88015c87d978
Sep 11 13:17:33 kernel: [12808122.751214] R13: ffff88015c87d450 R14: ffff8802080f5048 R15: ffffffff810de579
Sep 11 13:17:33 kernel: [12808122.751214] FS:  00007f7041814880(0000) GS:ffff880227d00000(0000) knlGS:00000000f4285980
Sep 11 13:17:33 kernel: [12808122.751214] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Sep 11 13:17:33 kernel: [12808122.751214] CR2: 00007f703b2c0000 CR3: 000000014db58000 CR4: 00000000000007e0
Sep 11 13:17:33 kernel: [12808122.751214] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Sep 11 13:17:33 kernel: [12808122.751214] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Sep 11 13:17:33 kernel: [12808122.751214] Process Xorg (pid: 5692, threadinfo ffff880208528000, task ffff880208079700)
Sep 11 13:17:33 kernel: [12808122.751214] Stack:
Sep 11 13:17:33 kernel: [12808122.751214]  ffff88015c87d248 ffff88015c87d248 ffff88015c87d450 00007f703b5b4000
Sep 11 13:17:33 kernel: [12808122.751214]  ffff88015c87d450 ffff880208529ec8 ffffffff810ded2f 0000000000000009
Sep 11 13:17:33 kernel: [12808122.751214]  ffff8802080f5048 ffff8802080f5040 ffff88015c87d228 ffff88015c87d450
Sep 11 13:17:33 kernel: [12808122.751214] Call Trace:
Sep 11 13:17:33 kernel: [12808122.751214]  [<ffffffff810ded2f>] vma_rb_erase+0x1b5/0x1c2
Sep 11 13:17:33 kernel: [12808122.751214]  [<ffffffff810e012c>] do_munmap+0x1f0/0x31d
Sep 11 13:17:33 kernel: [12808122.751214]  [<ffffffff810e0296>] vm_munmap+0x3d/0x56
Sep 11 13:17:33 kernel: [12808122.751214]  [<ffffffff810e02cd>] sys_munmap+0x1e/0x24
Sep 11 13:17:33 kernel: [12808122.751214]  [<ffffffff81527dd6>] system_call_fastpath+0x1a/0x1f
Sep 11 13:17:33 kernel: [12808122.751214] Code: 48 39 58 10 75 06 4c 89 60 10 eb 09 4c 89 60 08 eb 03 4d 89 26 4c 89 e6 4d 89 ec 48 89 df 41 ff d7 49 8b 44 24 10 48 85 c0 74 05 <f6> 00 01 74 66 4d 8b 6c 24 08 4d 85 ed 74 07 41 f6 45 00 01 74
Sep 11 13:17:33 kernel: [12808122.751214] RIP  [<ffffffff812abc64>] __rb_erase_color+0x148/0x215
Sep 11 13:17:33 kernel: [12808122.751214]  RSP <ffff880208529e58>
Sep 11 13:17:33 kernel: [12808122.920434] ---[ end trace 8913f036c5b4f342 ]---

Unfortunately I don't have the 3.9 build directory anymore, but here's a
reconstruction:

void __rb_erase_color(struct rb_node *parent, struct rb_root *root,
     void (*augment_rotate)(struct rb_node *old, struct rb_node *new))
...
/usr/src/3.9/lib/rbtree.c:322
                  if (!tmp1 || rb_is_black(tmp1)) {
 13a:   48 85 c0                test   %rax,%rax
 13d:   74 05                   je     144 <__rb_erase_color+0x144>
 13f:   f6 00 01                testb  $0x1,(%rax)

Both of mine look like current->mm is getting clobbered somewhere.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
