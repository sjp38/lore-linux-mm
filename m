Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF7A56B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 23:13:54 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 4so6108700oip.7
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 20:13:54 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a4si2404020oii.359.2018.03.16.20.13.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Mar 2018 20:13:52 -0700 (PDT)
Subject: Re: KVM hang after OOM
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CABXGCsOv040dsCkQNYzROBmZtYbqqnqLdhfGnCjU==N_nYQCKw@mail.gmail.com>
	<b9ef3b5f-37c2-649a-2c90-8fbbf2bd3bed@i-love.sakura.ne.jp>
	<178719aa-b669-c443-bf87-5728b71557c0@i-love.sakura.ne.jp>
	<CABXGCsNecgRN7mn4OxZY2rqa2N4kVBw3f0s6XEvLob4uy3LOug@mail.gmail.com>
In-Reply-To: <CABXGCsNecgRN7mn4OxZY2rqa2N4kVBw3f0s6XEvLob4uy3LOug@mail.gmail.com>
Message-Id: <201803171213.BFF21361.OOSFVFHLJQOtFM@I-love.SAKURA.ne.jp>
Date: Sat, 17 Mar 2018 12:13:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikhail.v.gavrilov@gmail.com
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, kirill@shutemov.name, mhocko@suse.com

Mikhail Gavrilov wrote:
> Yes, I reproduced KVM hang with patch above.
> New dmesg is attached.
> But I don't know how SysRq-i helps in real life, because after SysRq-i
> system became unusable.

I use SysRq-i when the page allocator became defunctional due to so many
concurrent direct reclaim activities.

> Why memory couldn't be reclaimed after OOM without SysRq-i?

Indeed, since the OOM killer selected the biggest memory consumer and the OOM
reaper succeeded to reclaim all memory, there should be enough free memory.

----------
[  961.096057] [ pid ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
[  961.097240] [ 7485]  1000  7485 21500884  7426177 169730048 13444297             0 Web Content
[  961.097301] Out of memory: Kill process 7485 (Web Content) score 887 or sacrifice child
[  961.097433] Killed process 7485 (Web Content) total-vm:86003536kB, anon-rss:29704708kB, file-rss:0kB, shmem-rss:0kB
[  968.779412] oom_reaper: reaped process 7485 (Web Content), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
----------

Maybe try SysRq-m for a few times after the OOM killer?

But

> 
> >
> > I tried to reproduce your problem using plain idle Fedora 27 guest (RAM 4GB + SWAP 4GB).
> > While the system apparently hang after OOM killer, the system seemed to be just under
> > swap memory thrashing situation, for heavy disk I/O had been observed from the host side.
> > Thus, my case might be different from your case.
> >
> 
> It's looks like you repeated my case correctly. Did you succeed to
> reproduce freeze virtual guest machine?
> After OOM heavy disk I/O must ended, but virtual machine in KVM wouldn't alive.
> Also some command cause freeze.
> For example on my machine impossible run `ps aux` because `ps aux`
> command freeze imminently after start.
> Also impossible open new tab in gnome-terminal.

I think you should debug

----------
[  713.331872] ============================================
[  713.331873] WARNING: possible recursive locking detected
[  713.331875] 4.16.0-rc1-amd-vega+ #8 Not tainted
[  713.331876] --------------------------------------------
[  713.331877] CPU 0/KVM/5886 is trying to acquire lock:
[  713.331878]  (&mm->mmap_sem){++++}, at: [<0000000033816a39>] get_user_pages_unlocked+0xe0/0x1d0
[  713.331884] 
               but task is already holding lock:
[  713.331886]  (&mm->mmap_sem){++++}, at: [<00000000ac6584cb>] get_user_pages_unlocked+0x5e/0x1d0
[  713.331889] 
               other info that might help us debug this:
[  713.331890]  Possible unsafe locking scenario:

[  713.331891]        CPU0
[  713.331892]        ----
[  713.331893]   lock(&mm->mmap_sem);
[  713.331894]   lock(&mm->mmap_sem);
[  713.331896] 
                *** DEADLOCK ***

[  713.331897]  May be due to missing lock nesting notation

[  713.331898] 3 locks held by CPU 0/KVM/5886:
[  713.331899]  #0:  (&vcpu->mutex){+.+.}, at: [<00000000bd620ae1>] kvm_vcpu_ioctl+0x81/0x6b0 [kvm]
[  713.331919]  #1:  (&kvm->srcu){....}, at: [<000000008888b6d6>] kvm_arch_vcpu_ioctl_run+0x752/0x1b90 [kvm]
[  713.331929]  #2:  (&mm->mmap_sem){++++}, at: [<00000000ac6584cb>] get_user_pages_unlocked+0x5e/0x1d0
[  713.331933] 
               stack backtrace:
[  713.331935] CPU: 0 PID: 5886 Comm: CPU 0/KVM Not tainted 4.16.0-rc1-amd-vega+ #8
[  713.331936] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[  713.331937] Call Trace:
[  713.331943]  dump_stack+0x85/0xbf
[  713.331946]  __lock_acquire+0x694/0x1340
[  713.331950]  ? lock_acquire+0x9f/0x200
[  713.331951]  ? __get_user_pages+0x1b3/0x760
[  713.331953]  lock_acquire+0x9f/0x200
[  713.331955]  ? get_user_pages_unlocked+0xe0/0x1d0
[  713.331958]  down_read+0x44/0xa0
[  713.331960]  ? get_user_pages_unlocked+0xe0/0x1d0
[  713.331962]  get_user_pages_unlocked+0xe0/0x1d0
[  713.331970]  __gfn_to_pfn_memslot+0x115/0x410 [kvm]
[  713.331980]  try_async_pf+0x67/0x3b0 [kvm]
[  713.331989]  tdp_page_fault+0x13e/0x290 [kvm]
[  713.331998]  kvm_mmu_page_fault+0x59/0x140 [kvm]
[  713.332006]  kvm_arch_vcpu_ioctl_run+0x7e7/0x1b90 [kvm]
[  713.332008]  ? __lock_acquire+0x2d4/0x1340
[  713.332011]  ? _copy_to_user+0x56/0x70
[  713.332018]  ? kvm_vcpu_ioctl+0x333/0x6b0 [kvm]
[  713.332024]  kvm_vcpu_ioctl+0x333/0x6b0 [kvm]
[  713.332026]  ? do_futex+0x463/0xb20
[  713.332029]  do_vfs_ioctl+0xa5/0x6e0
[  713.332032]  SyS_ioctl+0x74/0x80
[  713.332035]  do_syscall_64+0x7a/0x220
[  713.332037]  entry_SYSCALL_64_after_hwframe+0x26/0x9b
[  713.332039] RIP: 0033:0x7fecaaaa50f7
[  713.332040] RSP: 002b:00007fec9af44878 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[  713.332042] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 00007fecaaaa50f7
[  713.332043] RDX: 0000000000000000 RSI: 000000000000ae80 RDI: 0000000000000013
[  713.332044] RBP: 000055e07cadfe40 R08: 000055e07cafa1f0 R09: 00000000000000ff
[  713.332046] R10: 0000000000000001 R11: 0000000000000246 R12: 000055e07e80f5d6
[  713.332047] R13: 0000000000000000 R14: 00007fecb4172000 R15: 000055e07e80f540
[  713.332056] WARNING: CPU: 0 PID: 5886 at mm/gup.c:498 __get_user_pages+0x622/0x760
[  713.332058] Modules linked in: macvtap macvlan tap nls_utf8 isofs fuse nf_conntrack_netbios_ns nf_conntrack_broadcast xt_CT ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw iptable_security ebtable_filter ebtables ip6table_filter ip6_tables sunrpc xfs vfat fat libcrc32c intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm snd_hda_codec_realtek irqbypass snd_hda_codec_generic crct10dif_pclmul crc32_pclmul snd_hda_codec_hdmi ghash_clmulni_intel intel_cstate snd_hda_intel snd_hda_codec snd_usb_audio intel_uncore
[  713.332124]  iTCO_wdt gspca_zc3xx iTCO_vendor_support intel_rapl_perf snd_hda_core snd_usbmidi_lib gspca_main snd_rawmidi ppdev snd_hwdep v4l2_common snd_seq huawei_cdc_ncm videodev cdc_wdm snd_seq_device option cdc_ncm usb_wwan snd_pcm cdc_ether media pcspkr joydev usbnet mei_me snd_timer i2c_i801 snd mei lpc_ich shpchp parport_pc soundcore parport video binfmt_misc hid_logitech_hidpp hid_logitech_dj amdgpu uas usb_storage chash i2c_algo_bit gpu_sched drm_kms_helper ttm drm crc32c_intel r8169 mii
[  713.332177] CPU: 0 PID: 5886 Comm: CPU 0/KVM Not tainted 4.16.0-rc1-amd-vega+ #8
[  713.332179] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[  713.332182] RIP: 0010:__get_user_pages+0x622/0x760
[  713.332184] RSP: 0018:ffffaadc4ff6bac8 EFLAGS: 00010202
[  713.332186] RAX: 000000000000000c RBX: 0000000000000b26 RCX: ffffaadc4ff6ba0c
[  713.332188] RDX: 000000000000000c RSI: 00007fec4da99000 RDI: ffff8ab8f66cef30
[  713.332190] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000001
[  713.332192] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[  713.332194] R13: ffff8ab8b338be10 R14: 0000000000000b26 R15: ffff8ab8b3010000
[  713.332197] FS:  00007fec9af45700(0000) GS:ffff8aba7d600000(0000) knlGS:0000000000000000
[  713.332199] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  713.332201] CR2: 00000000ab3f0000 CR3: 00000005f33ac006 CR4: 00000000001626f0
[  713.332203] Call Trace:
[  713.332208]  get_user_pages_unlocked+0xff/0x1d0
[  713.332218]  __gfn_to_pfn_memslot+0x115/0x410 [kvm]
[  713.332229]  try_async_pf+0x67/0x3b0 [kvm]
[  713.332240]  tdp_page_fault+0x13e/0x290 [kvm]
[  713.332251]  kvm_mmu_page_fault+0x59/0x140 [kvm]
[  713.332260]  kvm_arch_vcpu_ioctl_run+0x7e7/0x1b90 [kvm]
[  713.332263]  ? __lock_acquire+0x2d4/0x1340
[  713.332267]  ? _copy_to_user+0x56/0x70
[  713.332276]  ? kvm_vcpu_ioctl+0x333/0x6b0 [kvm]
[  713.332283]  kvm_vcpu_ioctl+0x333/0x6b0 [kvm]
[  713.332286]  ? do_futex+0x463/0xb20
[  713.332291]  do_vfs_ioctl+0xa5/0x6e0
[  713.332296]  SyS_ioctl+0x74/0x80
[  713.332300]  do_syscall_64+0x7a/0x220
[  713.332303]  entry_SYSCALL_64_after_hwframe+0x26/0x9b
[  713.332306] RIP: 0033:0x7fecaaaa50f7
[  713.332308] RSP: 002b:00007fec9af44878 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[  713.332311] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 00007fecaaaa50f7
[  713.332312] RDX: 0000000000000000 RSI: 000000000000ae80 RDI: 0000000000000013
[  713.332314] RBP: 000055e07cadfe40 R08: 000055e07cafa1f0 R09: 00000000000000ff
[  713.332317] R10: 0000000000000001 R11: 0000000000000246 R12: 000055e07e80f5d6
[  713.332318] R13: 0000000000000000 R14: 00007fecb4172000 R15: 000055e07e80f540
[  713.332324] Code: ff ff 48 85 ed 48 c7 c0 00 fe ff ff 48 0f 44 e8 e9 d8 fb ff ff 48 8b 05 8d 2b 37 01 81 e2 ff 01 00 00 48 8d 04 d0 e9 c3 fc ff ff <0f> ff e9 7f fb ff ff 48 ba 00 00 00 c0 ff 3f 00 00 4c 21 ca e9 
[  713.332386] ---[ end trace 8c8d589eee083524 ]---
----------

problem first, for there are processes stuck at lock(&mm->mmap_sem)

----------
[  984.368330] INFO: task htop:3995 blocked for more than 120 seconds.
[  984.368337]       Tainted: G        W        4.16.0-rc1-amd-vega+ #8
[  984.368341] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  984.368345] htop            D11592  3995   3885 0x00000000
[  984.368354] Call Trace:
[  984.368366]  ? __schedule+0x2e9/0xba0
[  984.368374]  ? rwsem_down_read_failed+0x147/0x190
[  984.368381]  schedule+0x2f/0x90
[  984.368385]  rwsem_down_read_failed+0x118/0x190
[  984.368395]  ? call_rwsem_down_read_failed+0x14/0x30
[  984.368399]  call_rwsem_down_read_failed+0x14/0x30
[  984.368405]  down_read+0x97/0xa0
[  984.368411]  proc_pid_cmdline_read+0xd2/0x4a0
[  984.368417]  ? debug_check_no_obj_freed+0xda/0x244
[  984.368426]  ? __vfs_read+0x36/0x170
[  984.368430]  __vfs_read+0x36/0x170
[  984.368438]  vfs_read+0x9e/0x150
[  984.368443]  SyS_read+0x55/0xc0
[  984.368449]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  984.368454]  do_syscall_64+0x7a/0x220
[  984.368459]  entry_SYSCALL_64_after_hwframe+0x26/0x9b
----------

which would be the reason where programs which scan /proc/$pid/cmdline get stuck.
Can you reproduce this problem with 4.16.0-rc5 ?
