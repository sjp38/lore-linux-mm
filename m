Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1846E6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 18:54:44 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lj1so7593475pab.36
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 15:54:43 -0800 (PST)
Received: from psmtp.com ([74.125.245.190])
        by mx.google.com with SMTP id yl8si615539pab.176.2013.11.04.15.54.41
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 15:54:42 -0800 (PST)
Received: by mail-oa0-f48.google.com with SMTP id m17so7877261oag.21
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 15:54:40 -0800 (PST)
Date: Mon, 4 Nov 2013 17:54:29 -0600
From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: 3.10.16 general protection fault kmem_cache_alloc+0x67/0x170
Message-ID: <20131104235429.GA10994@sbohrermbp13-local.rgmadvisors.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org

I had a machine crash this weekend running a 3.10.16 kernel that
additionally has a few backported networking patches for performance
improvements.  At this point I can't rule out that the bug isn't from
those patches, and I haven't yet tried to see if I can reproduce the
crash.  I did happen to have kdump configured so I've got a crash dump
that I've been poking at but I'm not an expert here so hopefully
someone can provide some guidance on what I'm looking at and/or where
the bug might be.

Below is the more detailed info with some of my comments interspersed.
If anyone has any questions or suggestions I'd appreciate it.

[1448642.601229] general protection fault: 0000 [#1] SMP=20
[1448642.602448] Modules linked in: mpt2sas scsi_transport_sas raid_class m=
ptctl mptbase dell_rbu ipmi_devintf ipmi_si ipmi_msghandler lockd 8021q mrp=
 garp stp llc ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_c=
m ib_addr iw_cxgb3 mlx4_ib ib_sa ib_mad ib_core mlx4_en ext4 jbd2 mbcache j=
oydev fuse ses bnx2 coretemp mlx4_core cxgb3 hwmon mdio enclosure iTCO_wdt =
iTCO_vendor_support freq_table mperf wmi ehci_pci ehci_hcd dcdbas serio_raw=
 microcode lpc_ich mfd_core sunrpc ipv6 autofs4 crc32c_intel megaraid_sas u=
hci_hcd dm_mirror dm_region_hash dm_log dm_mod
[1448642.616810] CPU: 11 PID: 27807 Comm: primary_nic_is_ Not tainted 3.10.=
16-1.rgm.fc16.x86_64 #1
[1448642.618941] Hardware name: Dell Inc. PowerEdge R610/0XDN97, BIOS 6.3.0=
 07/24/2012
[1448642.620639] task: ffff8806628c3880 ti: ffff880604370000 task.ti: ffff8=
80604370000
[1448642.622335] RIP: 0010:[<ffffffff8112b117>]  [<ffffffff8112b117>] kmem_=
cache_alloc+0x67/0x170
[1448642.624286] RSP: 0018:ffff880604371d70  EFLAGS: 00010282
[1448642.625500] RAX: 0000000000000000 RBX: ffff8806628c3880 RCX: 000000007=
ecb996a
[1448642.627415] RDX: 000000007ecb9969 RSI: 00000000000000d0 RDI: 000000000=
0015900
[1448642.629077] RBP: ffff880604371dc0 R08: ffff880667d55900 R09: 000000000=
0000000
[1448642.630697] R10: 0000000000000000 R11: 0000000000015ea8 R12: ffff880c6=
7003800
[1448642.632316] R13: d17b94d6641aebfb R14: ffffffff81064d68 R15: 000000000=
00000d0
[1448642.633936] FS:  00007f8018827700(0000) GS:ffff880667d40000(0000) knlG=
S:0000000000000000
[1448642.635768] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[1448642.637497] CR2: 00000000006eded4 CR3: 000000066368b000 CR4: 000000000=
00007e0
[1448642.639230] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
[1448642.640849] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000=
0000400
[1448642.642468] Stack:
[1448642.642950]  00000000ffffff9c ffff8806628c3880 ffff8806628c3880 000000=
0000000002
[1448642.644780]  ffff8806628c3880 ffff8806628c3880 0000000000000000 000000=
0001200011
[1448642.646848]  0000000000000000 00007f80188279d0 ffff880604371de0 ffffff=
ff81064d68
[1448642.648987] Call Trace:
[1448642.649568]  [<ffffffff81064d68>] prepare_creds+0x28/0x160
[1448642.650822]  [<ffffffff81065436>] copy_creds+0x36/0x160
[1448642.652019]  [<ffffffff810393e0>] copy_process+0x310/0x14b0
[1448642.653295]  [<ffffffff811534f5>] ? __alloc_fd+0x45/0x110
[1448642.654529]  [<ffffffff8103a64c>] do_fork+0x9c/0x280
[1448642.655668]  [<ffffffff811535f0>] ? get_unused_fd_flags+0x30/0x40
[1448642.657473]  [<ffffffff8114147f>] ? __do_pipe_flags+0x7f/0xc0
[1448642.658808]  [<ffffffff8115362b>] ? __fd_install+0x2b/0x60
[1448642.660062]  [<ffffffff8103a8b6>] SyS_clone+0x16/0x20
[1448642.661222]  [<ffffffff814c2429>] stub_clone+0x69/0x90
[1448642.662399]  [<ffffffff814c2182>] ? system_call_fastpath+0x16/0x1b
[1448642.663807] Code: 00 49 8b 50 08 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 f=
7 00 00 00 48 85 c0 0f 84 ee 00 00 00 49 63 44 24 20 48 8d 4a 01 49 8b 3c 2=
4 <49> 8b 5c 05 00 4c 89 e8 65 48 0f c7 0f 0f 94 c0 84 c0 74 b5 49=20
[1448642.671081] RIP  [<ffffffff8112b117>] kmem_cache_alloc+0x67/0x170
[1448642.672508]  RSP <ffff880604371d70>
[1448642.673330] ---[ end trace fe4b503d6f77c801 ]---
[1448642.674408] general protection fault: 0000 [#2] SMP=20
[1448642.675623] Modules linked in: mpt2sas scsi_transport_sas raid_class m=
ptctl mptbase dell_rbu ipmi_devintf ipmi_si ipmi_msghandler lockd 8021q mrp=
 garp stp llc ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_c=
m ib_addr iw_cxgb3 mlx4_ib ib_sa ib_mad ib_core mlx4_en ext4 jbd2 mbcache j=
oydev fuse ses bnx2 coretemp mlx4_core cxgb3 hwmon mdio enclosure iTCO_wdt =
iTCO_vendor_support freq_table mperf wmi ehci_pci ehci_hcd dcdbas serio_raw=
 microcode lpc_ich mfd_core sunrpc ipv6 autofs4 crc32c_intel megaraid_sas u=
hci_hcd dm_mirror dm_region_hash dm_log dm_mod
[1448642.690185] CPU: 11 PID: 27807 Comm: primary_nic_is_ Tainted: G      D=
      3.10.16-1.rgm.fc16.x86_64 #1
[1448642.692328] Hardware name: Dell Inc. PowerEdge R610/0XDN97, BIOS 6.3.0=
 07/24/2012
[1448642.694027] task: ffff8806628c3880 ti: ffff880604370000 task.ti: ffff8=
80604370000
[1448642.695726] RIP: 0010:[<ffffffff8112b117>]  [<ffffffff8112b117>] kmem_=
cache_alloc+0x67/0x170
[1448642.698133] RSP: 0018:ffff880667d43ad0  EFLAGS: 00010282
[1448642.792981] RAX: 0000000000000000 RBX: ffffffff81a9c580 RCX: 000000007=
ecb996a
[1448642.889673] RDX: 000000007ecb9969 RSI: 0000000000000020 RDI: 000000000=
0015900
[1448642.994115] RBP: ffff880667d43b20 R08: ffff880667d55900 R09: ffffffff8=
1a9e5a0
[1448643.090682] R10: 00000000000043c7 R11: 000000003430080a R12: ffff880c6=
7003800
[1448643.188603] R13: d17b94d6641aebfb R14: ffffffff81412f2a R15: 000000000=
0000020
[1448643.285514] FS:  00007f8018827700(0000) GS:ffff880667d40000(0000) knlG=
S:0000000000000000
[1448643.383646] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[1448643.492593] CR2: 00000000006eded4 CR3: 000000066368b000 CR4: 000000000=
00007e0
[1448643.611447] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
[1448643.725885] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000=
0000400
[1448643.842044] Stack:
[1448643.951844]  ffff880c623d6300 0000000000000000 000000000000003c ffffff=
ff81ac3470
[1448644.064382]  0000000000000002 ffffffff81a9c580 ffff880664ba8800 000000=
0000000001
[1448644.172037]  00000000ffffffff 0000000000000011 ffff880667d43b70 ffffff=
ff81412f2a
[1448644.275773] Call Trace:
[1448644.381953]  <IRQ>=20
[1448644.382607]=20
[1448644.481603]  [<ffffffff81412f2a>] dst_alloc+0x5a/0x180
[1448644.582555]  [<ffffffff8143c08c>] rt_dst_alloc+0x4c/0x50
[1448644.682248]  [<ffffffff8143d6af>] ip_route_input_noref+0x58f/0x930
[1448644.780543]  [<ffffffff8146e28c>] ? udp_v4_early_demux+0x19c/0x400
[1448644.876777]  [<ffffffff8143f98a>] ip_rcv_finish+0x18a/0x320
[1448644.971530]  [<ffffffff814400cb>] ip_rcv+0x1fb/0x300
[1448645.065453]  [<ffffffff8140aee2>] __netif_receive_skb_core+0x622/0x7b0
[1448645.154238]  [<ffffffff8140b091>] __netif_receive_skb+0x21/0x70
[1448645.232660]  [<ffffffff8140b281>] netif_receive_skb+0x31/0xb0
[1448645.309863]  [<ffffffffa05ff6da>] mlx4_en_process_rx_cq+0x3aa/0x860 [m=
lx4_en]
[1448645.387368]  [<ffffffffa05ffc2f>] mlx4_en_poll_rx_cq+0x3f/0x80 [mlx4_e=
n]
[1448645.466734]  [<ffffffff8140b989>] net_rx_action+0x119/0x220
[1448645.545289]  [<ffffffff81043158>] __do_softirq+0xd8/0x280
[1448645.621214]  [<ffffffff8107e524>] ? tick_program_event+0x24/0x30
[1448645.696725]  [<ffffffff81062c31>] ? hrtimer_interrupt+0x141/0x240
[1448645.772942]  [<ffffffff814c333c>] call_softirq+0x1c/0x30
[1448645.849316]  [<ffffffff81004105>] do_softirq+0x55/0x90
[1448645.925047]  [<ffffffff81043435>] irq_exit+0x65/0x70
[1448646.004842]  [<ffffffff814c394e>] smp_apic_timer_interrupt+0x6e/0x99
[1448646.080536]  [<ffffffff814c2cca>] apic_timer_interrupt+0x6a/0x70
[1448646.155253]  <EOI>=20
[1448646.155756]=20
[1448646.230661]  [<ffffffff8103d8e6>] ? vprintk_emit+0x1d6/0x520
[1448646.304905]  [<ffffffff814b103a>] printk+0x4d/0x4f
[1448646.379754]  [<ffffffff8103b313>] print_oops_end_marker+0x23/0x30
[1448646.455985]  [<ffffffff8103b49f>] oops_exit+0x1f/0x30
[1448646.533918]  [<ffffffff814baceb>] oops_end+0x7b/0xf0
[1448646.608695]  [<ffffffff81005758>] die+0x58/0x90
[1448646.682638]  [<ffffffff81064d68>] ? prepare_creds+0x28/0x160
[1448646.757149]  [<ffffffff814ba80c>] do_general_protection+0xdc/0x160
[1448646.832144]  [<ffffffff814ba202>] general_protection+0x22/0x30
[1448646.908595]  [<ffffffff81064d68>] ? prepare_creds+0x28/0x160
[1448646.988953]  [<ffffffff8112b117>] ? kmem_cache_alloc+0x67/0x170
[1448647.065142]  [<ffffffff81064d68>] prepare_creds+0x28/0x160
[1448647.138887]  [<ffffffff81065436>] copy_creds+0x36/0x160
[1448647.211415]  [<ffffffff810393e0>] copy_process+0x310/0x14b0
[1448647.283149]  [<ffffffff811534f5>] ? __alloc_fd+0x45/0x110
[1448647.353624]  [<ffffffff8103a64c>] do_fork+0x9c/0x280
[1448647.423532]  [<ffffffff811535f0>] ? get_unused_fd_flags+0x30/0x40
[1448647.497069]  [<ffffffff8114147f>] ? __do_pipe_flags+0x7f/0xc0
[1448647.568373]  [<ffffffff8115362b>] ? __fd_install+0x2b/0x60
[1448647.633917]  [<ffffffff8103a8b6>] SyS_clone+0x16/0x20
[1448647.697775]  [<ffffffff814c2429>] stub_clone+0x69/0x90
[1448647.758626]  [<ffffffff814c2182>] ? system_call_fastpath+0x16/0x1b
[1448647.818728] Code: 00 49 8b 50 08 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 f=
7 00 00 00 48 85 c0 0f 84 ee 00 00 00 49 63 44 24 20 48 8d 4a 01 49 8b 3c 2=
4 <49> 8b 5c 05 00 4c 89 e8 65 48 0f c7 0f 0f 94 c0 84 c0 74 b5 49=20
[1448647.948966] RIP  [<ffffffff8112b117>] kmem_cache_alloc+0x67/0x170
[1448648.021914]  RSP <ffff880667d43ad0>

Here is the same backtrace from crash:

crash> bt
PID: 27807  TASK: ffff8806628c3880  CPU: 11  COMMAND: "primary_nic_is_"
 #0 [ffff880667d43870] machine_kexec at ffffffff81029c72
 #1 [ffff880667d438c0] crash_kexec at ffffffff8108cf98
 #2 [ffff880667d43990] oops_end at ffffffff814bad28
 #3 [ffff880667d439c0] die at ffffffff81005758
 #4 [ffff880667d439f0] do_general_protection at ffffffff814ba80c
 #5 [ffff880667d43a20] general_protection at ffffffff814ba202
    [exception RIP: kmem_cache_alloc+103]
    RIP: ffffffff8112b117  RSP: ffff880667d43ad0  RFLAGS: 00010282
    RAX: 0000000000000000  RBX: ffffffff81a9c580  RCX: 000000007ecb996a
    RDX: 000000007ecb9969  RSI: 0000000000000020  RDI: 0000000000015900
    RBP: ffff880667d43b20   R8: ffff880667d55900   R9: ffffffff81a9e5a0
    R10: 00000000000043c7  R11: 000000003430080a  R12: ffff880c67003800
    R13: d17b94d6641aebfb  R14: ffffffff81412f2a  R15: 0000000000000020
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #6 [ffff880667d43b28] dst_alloc at ffffffff81412f2a
 #7 [ffff880667d43b78] rt_dst_alloc at ffffffff8143c08c
 #8 [ffff880667d43b88] ip_route_input_noref at ffffffff8143d6af
 #9 [ffff880667d43c48] ip_rcv_finish at ffffffff8143f98a
#10 [ffff880667d43c78] ip_rcv at ffffffff814400cb
#11 [ffff880667d43cb8] __netif_receive_skb_core at ffffffff8140aee2
#12 [ffff880667d43d28] __netif_receive_skb at ffffffff8140b091
#13 [ffff880667d43d48] netif_receive_skb at ffffffff8140b281
#14 [ffff880667d43d78] mlx4_en_process_rx_cq at ffffffffa05ff6da [mlx4_en]
#15 [ffff880667d43e18] mlx4_en_poll_rx_cq at ffffffffa05ffc2f [mlx4_en]
#16 [ffff880667d43e58] net_rx_action at ffffffff8140b989
#17 [ffff880667d43ec8] __do_softirq at ffffffff81043158
#18 [ffff880667d43f48] call_softirq at ffffffff814c333c
#19 [ffff880667d43f60] do_softirq at ffffffff81004105
#20 [ffff880667d43f80] irq_exit at ffffffff81043435
#21 [ffff880667d43f90] smp_apic_timer_interrupt at ffffffff814c394e
#22 [ffff880667d43fb0] apic_timer_interrupt at ffffffff814c2cca
--- <IRQ stack> ---
#23 [ffff880604371a88] apic_timer_interrupt at ffffffff814c2cca
    [exception RIP: vprintk_emit+470]
    RIP: ffffffff8103d8e6  RSP: ffff880604371b38  RFLAGS: 00000246
    RAX: 0000000000000000  RBX: 0000000000000092  RCX: ffff880667d4e9e0
    RDX: 0000000000000000  RSI: ffff880667d4ce68  RDI: ffff880667d4ce60
    RBP: ffff880604371ba8   R8: 0000000000000000   R9: 0000000000000000
    R10: 00000000000003c7  R11: 0000000000000001  R12: 0000000000000004
    R13: 0000000000000001  R14: 0000000000000036  R15: ffffffff81abcf00
    ORIG_RAX: ffffffffffffff10  CS: 0010  SS: 0018
#24 [ffff880604371bb0] printk at ffffffff814b103a
#25 [ffff880604371c10] print_oops_end_marker at ffffffff8103b313
#26 [ffff880604371c20] oops_exit at ffffffff8103b49f
#27 [ffff880604371c30] oops_end at ffffffff814baceb
#28 [ffff880604371c60] die at ffffffff81005758
#29 [ffff880604371c90] do_general_protection at ffffffff814ba80c
#30 [ffff880604371cc0] general_protection at ffffffff814ba202
    [exception RIP: kmem_cache_alloc+103]
    RIP: ffffffff8112b117  RSP: ffff880604371d70  RFLAGS: 00010282
    RAX: 0000000000000000  RBX: ffff8806628c3880  RCX: 000000007ecb996a
    RDX: 000000007ecb9969  RSI: 00000000000000d0  RDI: 0000000000015900
    RBP: ffff880604371dc0   R8: ffff880667d55900   R9: 0000000000000000
    R10: 0000000000000000  R11: 0000000000015ea8  R12: ffff880c67003800
    R13: d17b94d6641aebfb  R14: ffffffff81064d68  R15: 00000000000000d0
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
#31 [ffff880604371dc8] prepare_creds at ffffffff81064d68
#32 [ffff880604371de8] copy_creds at ffffffff81065436
#33 [ffff880604371e28] copy_process at ffffffff810393e0
#34 [ffff880604371eb8] do_fork at ffffffff8103a64c
#35 [ffff880604371f38] sys_clone at ffffffff8103a8b6
#36 [ffff880604371f48] stub_clone at ffffffff814c2429
    RIP: 0000003ef6abd8a6  RSP: 00007fff494ae490  RFLAGS: 00000246
    RAX: 0000000000000038  RBX: 00007fff494ae490  RCX: ffffffffffffffff
    RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000001200011
    RBP: 00007fff494ae510   R8: 0000000000006c9f   R9: 00007f8018827700
    R10: 00007f80188279d0  R11: 0000000000000246  R12: 0000000000000000
    R13: 0000000000006c9f  R14: 0000003199954fe3  R15: 0000000000000001
    ORIG_RAX: 0000000000000038  CS: 0033  SS: 002b

So it looks to me like the first fault was in a clone system call
when prepare_creds() called kmem_cache_alloc(), then shortly afterward
I received a network packet and faulted again when dst_alloc() called
kmem_cache_alloc().  Both events happened on CPU 11.

Looking at the arguments passed into kmem_cache_alloc:

crash> print cred_jar
$13 =3D (struct kmem_cache *) 0xffff880c67003800
crash> print ipv4_dst_ops.kmem_cachep
$15 =3D (struct kmem_cache *) 0xffff880c67003800

Both are using the same kmem_cache pointer.

crash> struct kmem_cache 0xffff880c67003800
struct kmem_cache {
  cpu_slab =3D 0x15900,=20
  flags =3D 1073741824,=20
  min_partial =3D 5,=20
  size =3D 192,=20
  object_size =3D 192,=20
  offset =3D 0,=20
  cpu_partial =3D 30,=20
  oo =3D {
    x =3D 65578
  },=20
  max =3D {
    x =3D 65578
  },=20
  min =3D {
    x =3D 21
  },=20
  allocflags =3D 16384,=20
  refcount =3D 10,=20
  ctor =3D 0,=20
  inuse =3D 192,=20
  align =3D 8,=20
  reserved =3D 0,=20
  name =3D 0xffff880c67001010 "kmalloc-192",=20
  list =3D {
    next =3D 0xffff880c67003968,=20
    prev =3D 0xffff880c67003768
  },=20
  kobj =3D {
    name =3D 0xffff880662b84860 ":t-0000192",=20
    entry =3D {
      next =3D 0xffff880c67003980,=20
      prev =3D 0xffff880c67003780
    },=20
    parent =3D 0xffff880662b5f078,=20
    kset =3D 0xffff880662b5f060,=20
    ktype =3D 0xffffffff81a4fda0,=20
    sd =3D 0xffff880662b9f150,=20
    kref =3D {
      refcount =3D {
        counter =3D 1
      }
    },=20
    state_initialized =3D 1,=20
    state_in_sysfs =3D 1,=20
    state_add_uevent_sent =3D 1,=20
    state_remove_uevent_sent =3D 0,=20
    uevent_suppress =3D 0
  },=20
  remote_node_defrag_ratio =3D 1000,=20
  node =3D {0xffff880c67000f00, 0xffff880667800f00, 0x0, 0x0, 0x0, 0x0, 0x0=
, 0x0, 0x158e0, 0x40000000, 0x5, 0x8000000080, 0x1e00000000, 0x20, 0x20, 0x=
20, 0x700000000, 0x0, 0x800000080, 0x0, 0xffff880c67001060, 0xffff880c67003=
a68, 0xffff880c67003868, 0xffff880662b84890, 0xffff880c67003a80, 0xffff880c=
67003880, 0xffff880662b5f078, 0xffff880662b5f060, 0xffffffff81a4fda0, 0xfff=
f880662ba8000, 0x700000001, 0x3e8, 0xffff880c67000100, 0xffff880667800100, =
0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x158c0, 0x40000000, 0x5, 0x6000000060, 0x1e0=
0000000, 0x2a, 0x2a, 0x2a, 0x100000000, 0x0, 0x800000060, 0x0, 0xffff880c67=
001000, 0xffff880c67003b68, 0xffff880c67003968, 0xffff880662b848c0, 0xffff8=
80c67003b80, 0xffff880c67003980, 0xffff880662b5f078, 0xffff880662b5f060, 0x=
ffffffff81a4fda0, 0xffff880662ba8e70, 0x700000001, 0x3e8, 0xffff880c67000f4=
0, 0xffff880667800f40, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x158a0, 0x40000000, 0=
x5, 0x4000000040, 0x1e00000000, 0x40, 0x40, 0x40, 0xa00000000, 0x0, 0x80000=
0040, 0x0, 0xffff880c67001050, 0xffff880c67003c68, 0xffff880c67003a68, 0xff=
ff880662b848f0, 0xffff880c67003c80, 0xffff880c67003a80, 0xffff880662b5f078,=
 0xffff880662b5f060, 0xffffffff81a4fda0, 0xffff880662ba9d20, 0x700000001, 0=
x3e8, 0xffff880c670000c0, 0xffff8806678000c0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,=
 0x15880, 0x40000000, 0x5, 0x2000000020, 0x1e00000000, 0x80, 0x80, 0x80, 0x=
600000000, 0x0, 0x800000020, 0x0, 0xffff880c67001040, 0xffff880c67003d68, 0=
xffff880c67003b68, 0xffff880662b84920, 0xffff880c67003d80, 0xffff880c67003b=
80, 0xffff880662b5f078, 0xffff880662b5f060, 0xffffffff81a4fda0, 0xffff88066=
2baabd0, 0x700000001, 0x3e8, 0xffff880c67000f80, 0xffff880667800f80, 0x0, 0=
x0, 0x0, 0x0, 0x0, 0x0, 0x15860, 0x40000000, 0x5, 0x1000000010, 0x1e0000000=
0, 0x100, 0x100, 0x100, 0x100000000, 0x0, 0x800000010, 0x0, 0xffff880c67001=
030, 0xffff880c67003e68, 0xffff880c67003c68, 0xffff880662b84950, 0xffff880c=
67003e80, 0xffff880c67003c80, 0xffff880662b5f078, 0xffff880662b5f060, 0xfff=
fffff81a4fda0, 0xffff880662baba80, 0x700000001, 0x3e8, 0xffff880c67000080, =
0xffff880667800080, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x15840, 0x40000000, 0x5,=
 0x800000008, 0x1e00000000, 0x200, 0x200, 0x200, 0x100000000, 0x0, 0x800000=
008, 0x0, 0xffff880c67001020, 0xffff880c67003f68, 0xffff880c67003d68, 0xfff=
f880662b84980, 0xffff880c67003f80, 0xffff880c67003d80, 0xffff880662b5f078, =
0xffff880662b5f060, 0xffffffff81a4fda0, 0xffff880662bac930, 0x700000001, 0x=
3e8, 0xffff880c67000fc0, 0xffff880667800fc0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, =
0x15800, 0x40002000, 0x5, 0x4000000040, 0x1e00000000, 0x40, 0x40, 0x40, 0xf=
fffffff00000000, 0x0, 0x4000000040, 0x0, 0xffffffff817a9ba4, 0xffff880c6700=
2068, 0xffff880c67003e68, 0xffff880662b849b0, 0xffff880c67002080, 0xffff880=
c67003e80, 0xffff880662b5f078, 0xffff880662b5f060, 0xffffffff81a4fda0, 0xff=
ff880662bad7e0, 0x700000001, 0x3e8, 0xffff880c67000000, 0xffff880667800000,=
 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x6c616d6b2d616d64, 0x343230312d636f6c, 0x0,=
 0x0, 0x6c616d6b2d616d64, 0x383430322d636f6c, 0x0, 0x0, 0x6c616d6b2d616d64,=
 0x363930342d636f6c, 0x0, 0x0, 0x6c616d6b2d616d64, 0x323931382d636f6c, 0x0,=
 0x0, 0x705f646572616873, 0x6f6e5f7963696c6f, 0x6564, 0x0, 0x3000000000, 0x=
0, 0x0, 0x0...}
}

The cpu_slab pointer doesn't look valid to me and maybe that is the
problem.
crash> struct kmem_cache_cpu 0x15900
struct: invalid kernel virtual address: 0x15900

Here is the disassembly of the crash with source lines with should
match a stock 3.10.16:

crash> dis -lr kmem_cache_alloc+103
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
2406
0xffffffff8112b0b0 <kmem_cache_alloc>:  data32 data32 data32 xchg %ax,%ax
0xffffffff8112b0b5 <kmem_cache_alloc+5>:        push   %rbp
0xffffffff8112b0b6 <kmem_cache_alloc+6>:        mov    %rsp,%rbp
0xffffffff8112b0b9 <kmem_cache_alloc+9>:        push   %r15
0xffffffff8112b0bb <kmem_cache_alloc+11>:       mov    %esi,%r15d
0xffffffff8112b0be <kmem_cache_alloc+14>:       push   %r14
0xffffffff8112b0c0 <kmem_cache_alloc+16>:       push   %r13
0xffffffff8112b0c2 <kmem_cache_alloc+18>:       push   %r12
0xffffffff8112b0c4 <kmem_cache_alloc+20>:       mov    %rdi,%r12
0xffffffff8112b0c7 <kmem_cache_alloc+23>:       push   %rbx
0xffffffff8112b0c8 <kmem_cache_alloc+24>:       sub    $0x28,%rsp
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
924
0xffffffff8112b0cc <kmem_cache_alloc+28>:       mov    0x9930de(%rip),%eax =
       # 0xffffffff81abe1b0
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
2407
0xffffffff8112b0d2 <kmem_cache_alloc+34>:       mov    0x8(%rbp),%r14
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
924
0xffffffff8112b0d6 <kmem_cache_alloc+38>:       and    %esi,%eax
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
926
0xffffffff8112b0d8 <kmem_cache_alloc+40>:       test   $0x10,%al
0xffffffff8112b0da <kmem_cache_alloc+42>:       jne    0xffffffff8112b1e8 <=
kmem_cache_alloc+312>
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
2348
0xffffffff8112b0e0 <kmem_cache_alloc+48>:       mov    (%r12),%r8
0xffffffff8112b0e4 <kmem_cache_alloc+52>:       add    %gs:0xcc28,%r8
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
2356
0xffffffff8112b0ed <kmem_cache_alloc+61>:       mov    0x8(%r8),%rdx
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
2359
0xffffffff8112b0f1 <kmem_cache_alloc+65>:       mov    (%r8),%r13
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
2360
0xffffffff8112b0f4 <kmem_cache_alloc+68>:       mov    0x10(%r8),%rax
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
2361
0xffffffff8112b0f8 <kmem_cache_alloc+72>:       test   %r13,%r13
0xffffffff8112b0fb <kmem_cache_alloc+75>:       je     0xffffffff8112b1f8 <=
kmem_cache_alloc+328>
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
2046
0xffffffff8112b101 <kmem_cache_alloc+81>:       test   %rax,%rax
0xffffffff8112b104 <kmem_cache_alloc+84>:       je     0xffffffff8112b1f8 <=
kmem_cache_alloc+328>
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
251
0xffffffff8112b10a <kmem_cache_alloc+90>:       movslq 0x20(%r12),%rax
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
1683
0xffffffff8112b10f <kmem_cache_alloc+95>:       lea    0x1(%rdx),%rcx
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
2379
0xffffffff8112b113 <kmem_cache_alloc+99>:       mov    (%r12),%rdi
/usr/src/debug/kernel-3.10.fc16/linux-3.10.16-1.rgm.fc16.x86_64/mm/slub.c: =
251
0xffffffff8112b117 <kmem_cache_alloc+103>:      mov    0x0(%r13,%rax,1),%rbx

The crash utility also has some macros to analyze the SLAB caches but
the output doesn't mean much to me.  The only thing that stood out to
me was that CPU 11 appears that everything is allocated.  The full
output of that is below for the cache in question.  I'm guessing the
problem here was the bad cpu_slab pointer but beyond that I'm not
sure.

CACHE            NAME                 OBJSIZE  ALLOCATED     TOTAL  SLABS  =
SSIZE
ffff880c67003800 kmalloc-192              192       8867     14910    355  =
   8k
CPU 0 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea0031740e80  ffff880c5d03a000     0     40         40     0
  FREE / [ALLOCATED]
  [ffff880c5d03a000]
   ffff880c5d03a0c0  (cpu 0 cache)
   ffff880c5d03a180  (cpu 0 cache)
   ffff880c5d03a240  (cpu 0 cache)
  [ffff880c5d03a300]
  [ffff880c5d03a3c0]
   ffff880c5d03a480  (cpu 0 cache)
   ffff880c5d03a540  (cpu 0 cache)
  [ffff880c5d03a600]
   ffff880c5d03a6c0  (cpu 0 cache)
   ffff880c5d03a780  (cpu 0 cache)
   ffff880c5d03a840  (cpu 0 cache)
   ffff880c5d03a900  (cpu 0 cache)
   ffff880c5d03a9c0  (cpu 0 cache)
  [ffff880c5d03aa80]
   ffff880c5d03ab40  (cpu 0 cache)
  [ffff880c5d03ac00]
  [ffff880c5d03acc0]
  [ffff880c5d03ad80]
   ffff880c5d03ae40  (cpu 0 cache)
   ffff880c5d03af00  (cpu 0 cache)
   ffff880c5d03afc0  (cpu 0 cache)
  [ffff880c5d03b080]
   ffff880c5d03b140  (cpu 0 cache)
   ffff880c5d03b200  (cpu 0 cache)
   ffff880c5d03b2c0  (cpu 0 cache)
   ffff880c5d03b380  (cpu 0 cache)
   ffff880c5d03b440  (cpu 0 cache)
  [ffff880c5d03b500]
   ffff880c5d03b5c0  (cpu 0 cache)
   ffff880c5d03b680  (cpu 0 cache)
  [ffff880c5d03b740]
  [ffff880c5d03b800]
   ffff880c5d03b8c0  (cpu 0 cache)
   ffff880c5d03b980  (cpu 0 cache)
   ffff880c5d03ba40  (cpu 0 cache)
   ffff880c5d03bb00  (cpu 0 cache)
   ffff880c5d03bbc0  (cpu 0 cache)
  [ffff880c5d03bc80]
  [ffff880c5d03bd40]
CPU 1 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea001311d080  ffff8804c4742000     1     29         29     0
  FREE / [ALLOCATED]
  [ffff8804c4742000]
   ffff8804c47420c0  (cpu 1 cache)
   ffff8804c4742180  (cpu 1 cache)
  [ffff8804c4742240]
  [ffff8804c4742300]
  [ffff8804c47423c0]
  [ffff8804c4742480]
   ffff8804c4742540  (cpu 1 cache)
   ffff8804c4742600  (cpu 1 cache)
  [ffff8804c47426c0]
  [ffff8804c4742780]
   ffff8804c4742840  (cpu 1 cache)
   ffff8804c4742900  (cpu 1 cache)
  [ffff8804c47429c0]
   ffff8804c4742a80  (cpu 1 cache)
   ffff8804c4742b40  (cpu 1 cache)
   ffff8804c4742c00  (cpu 1 cache)
  [ffff8804c4742cc0]
   ffff8804c4742d80  (cpu 1 cache)
   ffff8804c4742e40  (cpu 1 cache)
  [ffff8804c4742f00]
  [ffff8804c4742fc0]
   ffff8804c4743080  (cpu 1 cache)
   ffff8804c4743140  (cpu 1 cache)
   ffff8804c4743200  (cpu 1 cache)
   ffff8804c47432c0  (cpu 1 cache)
   ffff8804c4743380  (cpu 1 cache)
  [ffff8804c4743440]
  [ffff8804c4743500]
CPU 2 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea003161b980  ffff880c586e6000     0     37         37     0
  FREE / [ALLOCATED]
  [ffff880c586e6000]
   ffff880c586e60c0  (cpu 2 cache)
   ffff880c586e6180  (cpu 2 cache)
  [ffff880c586e6240]
   ffff880c586e6300  (cpu 2 cache)
   ffff880c586e63c0  (cpu 2 cache)
   ffff880c586e6480  (cpu 2 cache)
  [ffff880c586e6540]
   ffff880c586e6600  (cpu 2 cache)
  [ffff880c586e66c0]
   ffff880c586e6780  (cpu 2 cache)
   ffff880c586e6840  (cpu 2 cache)
   ffff880c586e6900  (cpu 2 cache)
   ffff880c586e69c0  (cpu 2 cache)
  [ffff880c586e6a80]
   ffff880c586e6b40  (cpu 2 cache)
   ffff880c586e6c00  (cpu 2 cache)
   ffff880c586e6cc0  (cpu 2 cache)
   ffff880c586e6d80  (cpu 2 cache)
   ffff880c586e6e40  (cpu 2 cache)
   ffff880c586e6f00  (cpu 2 cache)
   ffff880c586e6fc0  (cpu 2 cache)
  [ffff880c586e7080]
  [ffff880c586e7140]
   ffff880c586e7200  (cpu 2 cache)
   ffff880c586e72c0  (cpu 2 cache)
   ffff880c586e7380  (cpu 2 cache)
   ffff880c586e7440  (cpu 2 cache)
   ffff880c586e7500  (cpu 2 cache)
   ffff880c586e75c0  (cpu 2 cache)
   ffff880c586e7680  (cpu 2 cache)
   ffff880c586e7740  (cpu 2 cache)
   ffff880c586e7800  (cpu 2 cache)
   ffff880c586e78c0  (cpu 2 cache)
   ffff880c586e7980  (cpu 2 cache)
   ffff880c586e7a40  (cpu 2 cache)
   ffff880c586e7b00  (cpu 2 cache)
CPU 3 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea001270b280  ffff88049c2ca000     1     16         16     0
  FREE / [ALLOCATED]
   ffff88049c2ca000  (cpu 3 cache)
  [ffff88049c2ca0c0]
  [ffff88049c2ca180]
  [ffff88049c2ca240]
   ffff88049c2ca300  (cpu 3 cache)
  [ffff88049c2ca3c0]
   ffff88049c2ca480  (cpu 3 cache)
  [ffff88049c2ca540]
  [ffff88049c2ca600]
  [ffff88049c2ca6c0]
   ffff88049c2ca780  (cpu 3 cache)
  [ffff88049c2ca840]
   ffff88049c2ca900  (cpu 3 cache)
  [ffff88049c2ca9c0]
  [ffff88049c2caa80]
   ffff88049c2cab40  (cpu 3 cache)
CPU 4 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea002f0ab780  ffff880bc2ade000     0      7          7     0
  FREE / [ALLOCATED]
  [ffff880bc2ade000]
  [ffff880bc2ade0c0]
  [ffff880bc2ade180]
  [ffff880bc2ade240]
  [ffff880bc2ade300]
  [ffff880bc2ade3c0]
   ffff880bc2ade480  (cpu 4 cache)
CPU 5 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea0012702780  ffff88049c09e000     1     12         12     0
  FREE / [ALLOCATED]
  [ffff88049c09e000]
  [ffff88049c09e0c0]
  [ffff88049c09e180]
   ffff88049c09e240  (cpu 5 cache)
  [ffff88049c09e300]
  [ffff88049c09e3c0]
  [ffff88049c09e480]
  [ffff88049c09e540]
  [ffff88049c09e600]
  [ffff88049c09e6c0]
   ffff88049c09e780  (cpu 5 cache)
   ffff88049c09e840  (cpu 5 cache)
CPU 6 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea0031728880  ffff880c5ca22000     0     31         31     0
  FREE / [ALLOCATED]
  [ffff880c5ca22000]
   ffff880c5ca220c0  (cpu 6 cache)
   ffff880c5ca22180  (cpu 6 cache)
   ffff880c5ca22240  (cpu 6 cache)
   ffff880c5ca22300  (cpu 6 cache)
   ffff880c5ca223c0  (cpu 6 cache)
   ffff880c5ca22480  (cpu 6 cache)
   ffff880c5ca22540  (cpu 6 cache)
   ffff880c5ca22600  (cpu 6 cache)
  [ffff880c5ca226c0]
   ffff880c5ca22780  (cpu 6 cache)
  [ffff880c5ca22840]
  [ffff880c5ca22900]
   ffff880c5ca229c0  (cpu 6 cache)
  [ffff880c5ca22a80]
   ffff880c5ca22b40  (cpu 6 cache)
   ffff880c5ca22c00  (cpu 6 cache)
   ffff880c5ca22cc0  (cpu 6 cache)
  [ffff880c5ca22d80]
   ffff880c5ca22e40  (cpu 6 cache)
  [ffff880c5ca22f00]
   ffff880c5ca22fc0  (cpu 6 cache)
  [ffff880c5ca23080]
  [ffff880c5ca23140]
   ffff880c5ca23200  (cpu 6 cache)
   ffff880c5ca232c0  (cpu 6 cache)
   ffff880c5ca23380  (cpu 6 cache)
   ffff880c5ca23440  (cpu 6 cache)
   ffff880c5ca23500  (cpu 6 cache)
   ffff880c5ca235c0  (cpu 6 cache)
   ffff880c5ca23680  (cpu 6 cache)
CPU 7 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea003184aa00  ffff880c612a8000     0     19         19     0
  FREE / [ALLOCATED]
  [ffff880c612a8000]
   ffff880c612a80c0  (cpu 7 cache)
  [ffff880c612a8180]
   ffff880c612a8240  (cpu 7 cache)
  [ffff880c612a8300]
  [ffff880c612a83c0]
  [ffff880c612a8480]
  [ffff880c612a8540]
   ffff880c612a8600  (cpu 7 cache)
   ffff880c612a86c0  (cpu 7 cache)
  [ffff880c612a8780]
  [ffff880c612a8840]
  [ffff880c612a8900]
  [ffff880c612a89c0]
  [ffff880c612a8a80]
  [ffff880c612a8b40]
   ffff880c612a8c00  (cpu 7 cache)
  [ffff880c612a8cc0]
   ffff880c612a8d80  (cpu 7 cache)
CPU 8 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea001812c880  ffff880604b22000     1     31         31     0
  FREE / [ALLOCATED]
  [ffff880604b22000]
   ffff880604b220c0  (cpu 8 cache)
   ffff880604b22180  (cpu 8 cache)
   ffff880604b22240  (cpu 8 cache)
   ffff880604b22300  (cpu 8 cache)
   ffff880604b223c0  (cpu 8 cache)
   ffff880604b22480  (cpu 8 cache)
  [ffff880604b22540]
   ffff880604b22600  (cpu 8 cache)
  [ffff880604b226c0]
  [ffff880604b22780]
  [ffff880604b22840]
  [ffff880604b22900]
   ffff880604b229c0  (cpu 8 cache)
  [ffff880604b22a80]
   ffff880604b22b40  (cpu 8 cache)
  [ffff880604b22c00]
   ffff880604b22cc0  (cpu 8 cache)
  [ffff880604b22d80]
  [ffff880604b22e40]
  [ffff880604b22f00]
   ffff880604b22fc0  (cpu 8 cache)
   ffff880604b23080  (cpu 8 cache)
   ffff880604b23140  (cpu 8 cache)
  [ffff880604b23200]
   ffff880604b232c0  (cpu 8 cache)
  [ffff880604b23380]
  [ffff880604b23440]
   ffff880604b23500  (cpu 8 cache)
   ffff880604b235c0  (cpu 8 cache)
   ffff880604b23680  (cpu 8 cache)
CPU 9 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea0015fa6700  ffff88057e99c000     1     26         26     0
  FREE / [ALLOCATED]
  [ffff88057e99c000]
  [ffff88057e99c0c0]
   ffff88057e99c180  (cpu 9 cache)
  [ffff88057e99c240]
  [ffff88057e99c300]
   ffff88057e99c3c0  (cpu 9 cache)
   ffff88057e99c480  (cpu 9 cache)
   ffff88057e99c540  (cpu 9 cache)
   ffff88057e99c600  (cpu 9 cache)
  [ffff88057e99c6c0]
   ffff88057e99c780  (cpu 9 cache)
   ffff88057e99c840  (cpu 9 cache)
  [ffff88057e99c900]
  [ffff88057e99c9c0]
   ffff88057e99ca80  (cpu 9 cache)
  [ffff88057e99cb40]
  [ffff88057e99cc00]
   ffff88057e99ccc0  (cpu 9 cache)
  [ffff88057e99cd80]
  [ffff88057e99ce40]
   ffff88057e99cf00  (cpu 9 cache)
  [ffff88057e99cfc0]
  [ffff88057e99d080]
   ffff88057e99d140  (cpu 9 cache)
   ffff88057e99d200  (cpu 9 cache)
  [ffff88057e99d2c0]
CPU 10 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea002fb1c480  ffff880bec712000     0     40         40     0
  FREE / [ALLOCATED]
   ffff880bec712000  (cpu 10 cache)
   ffff880bec7120c0  (cpu 10 cache)
   ffff880bec712180  (cpu 10 cache)
   ffff880bec712240  (cpu 10 cache)
   ffff880bec712300  (cpu 10 cache)
  [ffff880bec7123c0]
   ffff880bec712480  (cpu 10 cache)
   ffff880bec712540  (cpu 10 cache)
   ffff880bec712600  (cpu 10 cache)
  [ffff880bec7126c0]
   ffff880bec712780  (cpu 10 cache)
   ffff880bec712840  (cpu 10 cache)
   ffff880bec712900  (cpu 10 cache)
  [ffff880bec7129c0]
  [ffff880bec712a80]
  [ffff880bec712b40]
  [ffff880bec712c00]
   ffff880bec712cc0  (cpu 10 cache)
  [ffff880bec712d80]
   ffff880bec712e40  (cpu 10 cache)
  [ffff880bec712f00]
  [ffff880bec712fc0]
  [ffff880bec713080]
   ffff880bec713140  (cpu 10 cache)
  [ffff880bec713200]
   ffff880bec7132c0  (cpu 10 cache)
   ffff880bec713380  (cpu 10 cache)
  [ffff880bec713440]
   ffff880bec713500  (cpu 10 cache)
   ffff880bec7135c0  (cpu 10 cache)
   ffff880bec713680  (cpu 10 cache)
   ffff880bec713740  (cpu 10 cache)
   ffff880bec713800  (cpu 10 cache)
   ffff880bec7138c0  (cpu 10 cache)
   ffff880bec713980  (cpu 10 cache)
   ffff880bec713a40  (cpu 10 cache)
  [ffff880bec713b00]
   ffff880bec713bc0  (cpu 10 cache)
   ffff880bec713c80  (cpu 10 cache)
   ffff880bec713d40  (cpu 10 cache)
CPU 11 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea0029197f80  ffff880a465fe000     0     40         40     0
  FREE / [ALLOCATED]
  [ffff880a465fe000]
  [ffff880a465fe0c0]
  [ffff880a465fe180]
  [ffff880a465fe240]
  [ffff880a465fe300]
  [ffff880a465fe3c0]
  [ffff880a465fe480]
  [ffff880a465fe540]
  [ffff880a465fe600]
  [ffff880a465fe6c0]
  [ffff880a465fe780]
  [ffff880a465fe840]
  [ffff880a465fe900]
  [ffff880a465fe9c0]
  [ffff880a465fea80]
  [ffff880a465feb40]
  [ffff880a465fec00]
  [ffff880a465fecc0]
  [ffff880a465fed80]
  [ffff880a465fee40]
  [ffff880a465fef00]
  [ffff880a465fefc0]
  [ffff880a465ff080]
  [ffff880a465ff140]
  [ffff880a465ff200]
  [ffff880a465ff2c0]
  [ffff880a465ff380]
  [ffff880a465ff440]
  [ffff880a465ff500]
  [ffff880a465ff5c0]
  [ffff880a465ff680]
  [ffff880a465ff740]
  [ffff880a465ff800]
  [ffff880a465ff8c0]
  [ffff880a465ff980]
  [ffff880a465ffa40]
  [ffff880a465ffb00]
  [ffff880a465ffbc0]
  [ffff880a465ffc80]
  [ffff880a465ffd40]
CPU 12 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea0030443280  ffff880c110ca000     0     34         34     0
  FREE / [ALLOCATED]
   ffff880c110ca000  (cpu 12 cache)
   ffff880c110ca0c0  (cpu 12 cache)
  [ffff880c110ca180]
   ffff880c110ca240  (cpu 12 cache)
   ffff880c110ca300  (cpu 12 cache)
   ffff880c110ca3c0  (cpu 12 cache)
   ffff880c110ca480  (cpu 12 cache)
   ffff880c110ca540  (cpu 12 cache)
   ffff880c110ca600  (cpu 12 cache)
   ffff880c110ca6c0  (cpu 12 cache)
   ffff880c110ca780  (cpu 12 cache)
   ffff880c110ca840  (cpu 12 cache)
  [ffff880c110ca900]
  [ffff880c110ca9c0]
  [ffff880c110caa80]
  [ffff880c110cab40]
   ffff880c110cac00  (cpu 12 cache)
   ffff880c110cacc0  (cpu 12 cache)
   ffff880c110cad80  (cpu 12 cache)
   ffff880c110cae40  (cpu 12 cache)
   ffff880c110caf00  (cpu 12 cache)
  [ffff880c110cafc0]
   ffff880c110cb080  (cpu 12 cache)
   ffff880c110cb140  (cpu 12 cache)
  [ffff880c110cb200]
   ffff880c110cb2c0  (cpu 12 cache)
   ffff880c110cb380  (cpu 12 cache)
   ffff880c110cb440  (cpu 12 cache)
   ffff880c110cb500  (cpu 12 cache)
   ffff880c110cb5c0  (cpu 12 cache)
   ffff880c110cb680  (cpu 12 cache)
   ffff880c110cb740  (cpu 12 cache)
   ffff880c110cb800  (cpu 12 cache)
   ffff880c110cb8c0  (cpu 12 cache)
CPU 13 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea0018068100  ffff880601a04000     1     32         32     0
  FREE / [ALLOCATED]
  [ffff880601a04000]
   ffff880601a040c0  (cpu 13 cache)
  [ffff880601a04180]
  [ffff880601a04240]
   ffff880601a04300  (cpu 13 cache)
  [ffff880601a043c0]
  [ffff880601a04480]
  [ffff880601a04540]
  [ffff880601a04600]
  [ffff880601a046c0]
  [ffff880601a04780]
  [ffff880601a04840]
  [ffff880601a04900]
  [ffff880601a049c0]
  [ffff880601a04a80]
  [ffff880601a04b40]
  [ffff880601a04c00]
   ffff880601a04cc0  (cpu 13 cache)
  [ffff880601a04d80]
  [ffff880601a04e40]
  [ffff880601a04f00]
  [ffff880601a04fc0]
  [ffff880601a05080]
  [ffff880601a05140]
  [ffff880601a05200]
  [ffff880601a052c0]
  [ffff880601a05380]
   ffff880601a05440  (cpu 13 cache)
  [ffff880601a05500]
   ffff880601a055c0  (cpu 13 cache)
  [ffff880601a05680]
  [ffff880601a05740]
CPU 14 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea0031535c80  ffff880c54d72000     0     37         37     0
  FREE / [ALLOCATED]
   ffff880c54d72000  (cpu 14 cache)
   ffff880c54d720c0  (cpu 14 cache)
   ffff880c54d72180  (cpu 14 cache)
  [ffff880c54d72240]
   ffff880c54d72300  (cpu 14 cache)
   ffff880c54d723c0  (cpu 14 cache)
   ffff880c54d72480  (cpu 14 cache)
   ffff880c54d72540  (cpu 14 cache)
  [ffff880c54d72600]
   ffff880c54d726c0  (cpu 14 cache)
   ffff880c54d72780  (cpu 14 cache)
   ffff880c54d72840  (cpu 14 cache)
   ffff880c54d72900  (cpu 14 cache)
   ffff880c54d729c0  (cpu 14 cache)
   ffff880c54d72a80  (cpu 14 cache)
   ffff880c54d72b40  (cpu 14 cache)
   ffff880c54d72c00  (cpu 14 cache)
   ffff880c54d72cc0  (cpu 14 cache)
   ffff880c54d72d80  (cpu 14 cache)
   ffff880c54d72e40  (cpu 14 cache)
   ffff880c54d72f00  (cpu 14 cache)
   ffff880c54d72fc0  (cpu 14 cache)
   ffff880c54d73080  (cpu 14 cache)
   ffff880c54d73140  (cpu 14 cache)
   ffff880c54d73200  (cpu 14 cache)
   ffff880c54d732c0  (cpu 14 cache)
   ffff880c54d73380  (cpu 14 cache)
   ffff880c54d73440  (cpu 14 cache)
   ffff880c54d73500  (cpu 14 cache)
   ffff880c54d735c0  (cpu 14 cache)
   ffff880c54d73680  (cpu 14 cache)
   ffff880c54d73740  (cpu 14 cache)
   ffff880c54d73800  (cpu 14 cache)
   ffff880c54d738c0  (cpu 14 cache)
  [ffff880c54d73980]
   ffff880c54d73a40  (cpu 14 cache)
   ffff880c54d73b00  (cpu 14 cache)
CPU 15 SLAB:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea0018064800  ffff880601920000     1     17         17     0
  FREE / [ALLOCATED]
  [ffff880601920000]
   ffff8806019200c0  (cpu 15 cache)
  [ffff880601920180]
  [ffff880601920240]
  [ffff880601920300]
  [ffff8806019203c0]
  [ffff880601920480]
  [ffff880601920540]
  [ffff880601920600]
  [ffff8806019206c0]
  [ffff880601920780]
  [ffff880601920840]
  [ffff880601920900]
  [ffff8806019209c0]
  [ffff880601920a80]
  [ffff880601920b40]
  [ffff880601920c00]
KMEM_CACHE_NODE   NODE  SLABS  PARTIAL  PER-CPU
ffff880c67000f00     0    118       16        9
NODE 0 PARTIAL:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea0031611f80  ffff880c5847e000     0      2          2     0
  ffffea00295f5600  ffff880a57d58000     0     13         13     0
  ffffea00315b4a80  ffff880c56d2a000     0     37         37     0
  ffffea002d703080  ffff880b5c0c2000     0      1          1     0
  ffffea0031608c80  ffff880c58232000     0      1          1     0
  ffffea00318ab980  ffff880c62ae6000     0      9          9     0
  ffffea0031721800  ffff880c5c860000     0     12         12     0
  ffffea0031745d80  ffff880c5d176000     0      4          4     0
  ffffea003161ae80  ffff880c586ba000     0      4          4     0
  ffffea00318f8f00  ffff880c63e3c000     0      5          5     0
  ffffea003176c680  ffff880c5db1a000     0      1          1     0
  ffffea0031899e00  ffff880c62678000     0      5          5     0
  ffffea00318f6f00  ffff880c63dbc000     0     36         36     0
  ffffea0029196d00  ffff880a465b4000     0      2          2     0
  ffffea002f0a6c00  ffff880bc29b0000     0      2          2     0
  ffffea0029107f80  ffff880a441fe000     0      1          1     0
NODE 0 FULL:
  (not tracked)
KMEM_CACHE_NODE   NODE  SLABS  PARTIAL  PER-CPU
ffff880667800f00     1    237      140        7
NODE 1 PARTIAL:
  SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
  ffffea0011484c80  ffff880452132000     1      0          0     0
  ffffea0012727d80  ffff88049c9f6000     1      0          0     0
  ffffea000d770080  ffff88035dc02000     1      0          0     0
  ffffea00181c1b80  ffff88060706e000     1      0          0     0
  ffffea001311b880  ffff8804c46e2000     1     26         26     0
  ffffea0012632780  ffff880498c9e000     1      0          0     0
  ffffea00181ab880  ffff880606ae2000     1      1          1     0
  ffffea001825d380  ffff88060974e000     1     13         13     0
  ffffea00198ee080  ffff880663b82000     1      5          5     0
  ffffea0011485780  ffff88045215e000     1      1          1     0
  ffffea0018131800  ffff880604c60000     1      2          2     0
  ffffea000d8c9680  ffff88036325a000     1      2          2     0
  ffffea00180b9380  ffff880602e4e000     1      1          1     0
  ffffea0019878280  ffff880661e0a000     1      9          9     0
  ffffea0019926400  ffff880664990000     1     25         25     0
  ffffea00198b6780  ffff880662d9e000     1     40         40     0
  ffffea00198bfb00  ffff880662fec000     1     22         22     0
  ffffea001812a880  ffff880604aa2000     1      4          4     0
  ffffea00198eca00  ffff880663b28000     1     12         12     0
  ffffea000d3a7800  ffff88034e9e0000     1      1          1     0
  ffffea0019896180  ffff880662586000     1     11         11     0
  ffffea0019853200  ffff8806614c8000     1      2          2     0
  ffffea0011483200  ffff8804520c8000     1      2          2     0
  ffffea0019858000  ffff880661600000     1      3          3     0
  ffffea001148ff80  ffff8804523fe000     1     11         11     0
  ffffea000d3ac080  ffff88034eb02000     1      1          1     0
  ffffea0015fa8a80  ffff88057ea2a000     1      2          2     0
  ffffea0019851c80  ffff880661472000     1     32         32     0
  ffffea0018068880  ffff880601a22000     1      2          2     0
  ffffea0019901000  ffff880664040000     1     15         15     0
  ffffea0018167280  ffff8806059ca000     1      1          1     0
  ffffea001148bd80  ffff8804522f6000     1      2          2     0
  ffffea0019896d80  ffff8806625b6000     1      3          3     0
  ffffea0018094900  ffff880602524000     1      7          7     0
  ffffea00180bdd00  ffff880602f74000     1      2          2     0
  ffffea00181d6200  ffff880607588000     1     13         13     0
  ffffea0019925c80  ffff880664972000     1     34         34     0
  ffffea0012722600  ffff88049c898000     1      1          1     0
  ffffea001817cc80  ffff880605f32000     1      2          2     0
  ffffea0019852f00  ffff8806614bc000     1      2          2     0
  ffffea0018091000  ffff880602440000     1      1          1     0
  ffffea0012729e00  ffff88049ca78000     1      1          1     0
  ffffea001813df00  ffff880604f7c000     1      1          1     0
  ffffea001818e480  ffff880606392000     1      1          1     0
  ffffea001263d600  ffff880498f58000     1      1          1     0
  ffffea000d6e8c00  ffff88035ba30000     1      1          1     0
  ffffea001270fc80  ffff88049c3f2000     1      2          2     0
  ffffea0011f96700  ffff88047e59c000     1      1          1     0
  ffffea00180dd680  ffff88060375a000     1      1          1     0
  ffffea000d6e2600  ffff88035b898000     1      1          1     0
  ffffea00180ef080  ffff880603bc2000     1      1          1     0
  ffffea0018102000  ffff880604080000     1      2          2     0
  ffffea001810d900  ffff880604364000     1      1          1     0
  ffffea0011f98000  ffff88047e600000     1      1          1     0
  ffffea001812ca00  ffff880604b28000     1      2          2     0
  ffffea00067d7600  ffff88019f5d8000     1      2          2     0
  ffffea00180e9b00  ffff880603a6c000     1      2          2     0
  ffffea0018158f00  ffff88060563c000     1      1          1     0
  ffffea00181dc800  ffff880607720000     1      1          1     0
  ffffea00180e2e80  ffff8806038ba000     1      1          1     0
  ffffea00180b8080  ffff880602e02000     1      3          3     0
  ffffea0018118b00  ffff88060462c000     1      2          2     0
  ffffea0018193f00  ffff8806064fc000     1      1          1     0
  ffffea001270c500  ffff88049c314000     1      2          2     0
  ffffea001811d500  ffff880604754000     1      1          1     0
  ffffea001983e300  ffff880660f8c000     1     16         16     0
  ffffea0019901e80  ffff88066407a000     1     17         17     0
  ffffea0018060f00  ffff88060183c000     1      5          5     0
  ffffea000d3a5700  ffff88034e95c000     1      7          7     0
  ffffea00180b7400  ffff880602dd0000     1      2          2     0
  ffffea0012425400  ffff880490950000     1      1          1     0
  ffffea001806bb00  ffff880601aec000     1      1          1     0
  ffffea0018083b00  ffff8806020ec000     1      1          1     0
  ffffea00180f9400  ffff880603e50000     1      1          1     0
  ffffea0011484b80  ffff88045212e000     1      1          1     0
  ffffea00181a5b80  ffff88060696e000     1      1          1     0
  ffffea00181ec180  ffff880607b06000     1      1          1     0
  ffffea0019852780  ffff88066149e000     1      2          2     0
  ffffea00180dc180  ffff880603706000     1      1          1     0
  ffffea00067d5200  ffff88019f548000     1      1          1     0
  ffffea0015fa4100  ffff88057e904000     1      1          1     0
  ffffea00067d3180  ffff88019f4c6000     1      1          1     0
  ffffea0013fad680  ffff8804feb5a000     1      1          1     0
  ffffea0013fa0180  ffff8804fe806000     1      2          2     0
  ffffea0018064e80  ffff88060193a000     1      1          1     0
  ffffea0018176580  ffff880605d96000     1      1          1     0
  ffffea00067d5280  ffff88019f54a000     1      1          1     0
  ffffea0018107d80  ffff8806041f6000     1      1          1     0
  ffffea001311dc00  ffff8804c4770000     1      1          1     0
  ffffea000d779e00  ffff88035de78000     1      1          1     0
  ffffea001815e100  ffff880605784000     1      1          1     0
  ffffea0013faea00  ffff8804feba8000     1      1          1     0
  ffffea0018177d80  ffff880605df6000     1      1          1     0
  ffffea00067d3c00  ffff88019f4f0000     1      2          2     0
  ffffea001813c780  ffff880604f1e000     1      1          1     0
  ffffea0018084200  ffff880602108000     1      2          2     0
  ffffea0012635700  ffff880498d5c000     1      1          1     0
  ffffea0012717500  ffff88049c5d4000     1      1          1     0
  ffffea001242ea00  ffff880490ba8000     1      1          1     0
  ffffea000d6e7f00  ffff88035b9fc000     1      1          1     0
  ffffea001810d480  ffff880604352000     1      2          2     0
  ffffea001270eb00  ffff88049c3ac000     1      1          1     0
  ffffea001818db80  ffff88060636e000     1      1          1     0
  ffffea00067d6700  ffff88019f59c000     1      2          2     0
  ffffea0013fa0380  ffff8804fe80e000     1      2          2     0
  ffffea00181ad780  ffff880606b5e000     1      1          1     0
  ffffea0013fa6600  ffff8804fe998000     1      1          1     0
  ffffea000d3adc80  ffff88034eb72000     1      1          1     0
  ffffea0011f9cf80  ffff88047e73e000     1      3          3     0
  ffffea0012729100  ffff88049ca44000     1      1          1     0
  ffffea0013fae480  ffff8804feb92000     1      2          2     0
  ffffea00198d2e80  ffff8806634ba000     1      3          3     0
  ffffea0018194180  ffff880606506000     1      1          1     0
  ffffea0011f91a00  ffff88047e468000     1      1          1     0
  ffffea00180f7900  ffff880603de4000     1      1          1     0
  ffffea0018136280  ffff880604d8a000     1      1          1     0
  ffffea001987b500  ffff880661ed4000     1     18         18     0
  ffffea00181c7b80  ffff8806071ee000     1      2          2     0
  ffffea000d6e5000  ffff88035b940000     1      3          3     0
  ffffea0018172880  ffff880605ca2000     1     20         20     0
  ffffea0012632700  ffff880498c9c000     1      2          2     0
  ffffea0018151b80  ffff88060546e000     1      2          2     0
  ffffea0018119000  ffff880604640000     1      4          4     0
  ffffea00181aa600  ffff880606a98000     1      1          1     0
  ffffea00180f7f00  ffff880603dfc000     1      2          2     0
  ffffea00180dc200  ffff880603708000     1      1          1     0
  ffffea0018240800  ffff880609020000     1     18         18     0
  ffffea00198d5080  ffff880663542000     1      1          1     0
  ffffea00180cf080  ffff8806033c2000     1      1          1     0
  ffffea00198e3a80  ffff8806638ea000     1     17         17     0
  ffffea0018074380  ffff880601d0e000     1      1          1     0
  ffffea001807c900  ffff880601f24000     1      1          1     0
  ffffea0018144a00  ffff880605128000     1      2          2     0
  ffffea001148af80  ffff8804522be000     1      1          1     0
  ffffea0012422800  ffff8804908a0000     1     10         10     0
  ffffea000d8c7a80  ffff8803631ea000     1      1          1     0
  ffffea00180c5e00  ffff880603178000     1      2          2     0
  ffffea00180dcf80  ffff88060373e000     1      1          1     0
  ffffea001814ec80  ffff8806053b2000     1     32         32     0
  ffffea0019899e80  ffff88066267a000     1      4          4     0
NODE 1 FULL:
  (not tracked)

Thanks,
Shawn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
