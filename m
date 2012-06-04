Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 3DAA46B005D
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 13:13:52 -0400 (EDT)
Date: Tue, 5 Jun 2012 01:13:48 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: kvm segfaults and bad page state in 3.4.0
Message-ID: <20120604171348.GA5993@localhost>
References: <20120604114603.GA6988@localhost>
 <20120604115650.GH23670@redhat.com>
 <20120604123530.GA7262@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120604123530.GA7262@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 04, 2012 at 08:35:30PM +0800, Fengguang Wu wrote:
> Hi Gleb,
> 
> On Mon, Jun 04, 2012 at 02:56:50PM +0300, Gleb Natapov wrote:
> > On Mon, Jun 04, 2012 at 07:46:03PM +0800, Fengguang Wu wrote:
> > > Hi,
> > > 
> > > I'm running lots of kvm instances for doing kernel boot tests.
> > > Unfortunately the test system itself is not stable enough, I got scary
> > > errors in both kvm and the host kernel. Like this. 
> > > 
> > What do you mean by "in both kvm and the host kernel". Do you have
> 
> I mean the host side's kvm user space process and kernel seem to have problems.
> 
> > similar Oopses inside your guests? If yes can you post one?
> 
> There are all kinds of problems in the guest kernel, too. Probably I
> built in too many modules (take a debian config and s/=m/=y/) and
> enabled too many debug options. Many of the bugs I ran into have
> already been reported by others in LKML. Here are more weird things.

Two more boot errors..

storvsc device driver (from Microsoft..) bug:

[  108.445777] hv_vmbus: registering driver storvsc
[  108.498750] ------------[ cut here ]------------
[  108.502649] kernel BUG at /c/kernel-tests/intel/drivers/base/driver.c:227!
[  108.502649] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  108.502649] CPU 0 
[  108.502649] Modules linked in:
[  108.502649] 
[  108.502649] Pid: 1, comm: swapper/0 Not tainted 3.2.0-rt13+ #1 Bochs Bochs
[  108.502649] RIP: 0010:[<ffffffff8197f395>]  [<ffffffff8197f395>] driver_register+0x24/0x116
[  108.502649] RSP: 0018:ffff8800162c5e60  EFLAGS: 00010246
[  108.502649] RAX: ffffffff84131c40 RBX: ffffffff8411e580 RCX: 0000000025232522
[  108.502649] RDX: 0000000000000000 RSI: ffffffff82dac59f RDI: ffffffff8411e580
[  108.502649] RBP: ffff8800162c5ea0 R08: 0000000000000002 R09: ffffffff84f32270
[  108.502649] R10: 00000000ffffffff R11: 00000000ffffffff R12: 0000000000000000
[  108.502649] R13: ffffffff83aeeeff R14: 0000000000000000 R15: 0000000000000000
[  108.502649] FS:  0000000000000000(0000) GS:ffff880017400000(0000) knlGS:0000000000000000
[  108.502649] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  108.502649] CR2: 0000000000000000 CR3: 0000000003e12000 CR4: 00000000000006f0
[  108.502649] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  108.502649] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  108.502649] Process swapper/0 (pid: 1, threadinfo ffff8800162c4000, task ffff8800162c0040)
[  108.502649] Stack:
[  108.502649]  ffff8800162c5eb0 ffff8800162c5e70 ffff8800162c5e80 ffffffff8411e560
[  108.502649]  0000000000000000 ffffffff83aeeeff 0000000000000000 0000000000000000
[  108.502649]  ffff8800162c5ed0 ffffffff827e3b18 ffffffff83e6eda8 ffffffff845d6460
[  108.502649] Call Trace:
[  108.502649]  [<ffffffff827e3b18>] __vmbus_driver_register+0x4a/0x5c
[  108.502649]  [<ffffffff8445fcc4>] ? rtsx_init+0x29/0x29
[  108.502649]  [<ffffffff8445fcf9>] storvsc_drv_init+0x35/0x3f
[  108.502649]  [<ffffffff81002099>] do_one_initcall+0x7f/0x13a
[  108.502649]  [<ffffffff843e4caa>] kernel_init+0xce/0x148
[  108.502649]  [<ffffffff82db5604>] kernel_thread_helper+0x4/0x10
[  108.502649]  [<ffffffff82dac9b4>] ? retint_restore_args+0x13/0x13
[  108.502649]  [<ffffffff843e4bdc>] ? start_kernel+0x412/0x412
[  108.502649]  [<ffffffff82db5600>] ? gs_change+0x13/0x13
[  108.502649] Code: 5c 41 5d 41 5e 5d c3 55 48 89 e5 41 57 41 56 41 55 41 54 53 48 83 ec 18 66 66 66 66 90 48 8b 47 08 48 89 fb 48 83 78 68 00 75 02 <0f> 0b 48 83 78 30 00 74 07 48 83 7f 30 00 75 1c 48 83 78 38 00 
[  108.502649] RIP  [<ffffffff8197f395>] driver_register+0x24/0x116
[  108.502649]  RSP <ffff8800162c5e60>
[  110.913751] ---[ end trace 184c66c6768bd651 ]---
[  110.967270] swapper/0 used greatest stack depth: 3688 bytes left
[  111.021415] Kernel panic - not syncing: Attempted to kill init!
[  111.075053] Pid: 1, comm: swapper/0 Tainted: G      D      3.2.0-rt13+ #1
[  111.130699] Call Trace:
[  111.185972]  [<ffffffff82d5d34d>] panic+0xa0/0x1b3
[  111.241642]  [<ffffffff82dabdda>] ? _raw_write_unlock_irq+0x2e/0x47
[  111.294939]  [<ffffffff810a55f8>] do_exit+0x9b/0x7b7
[  111.349523]  [<ffffffff810a31cd>] ? kmsg_dump+0x82/0x135
[  111.402315]  [<ffffffff82dad653>] oops_end+0xaf/0xb8
[  111.454034]  [<ffffffff8104beb4>] die+0x5a/0x66
[  111.505217]  [<ffffffff82dad181>] do_trap+0x11a/0x129
[  111.555117]  [<ffffffff81049b4a>] do_invalid_op+0x98/0xa1
[  111.603546]  [<ffffffff8197f395>] ? driver_register+0x24/0x116
[  111.651247]  [<ffffffff810d2423>] ? trace_hardirqs_off_caller+0x3f/0x9e
[  111.700511]  [<ffffffff816a457d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  111.748561]  [<ffffffff82dac9e4>] ? restore_args+0x30/0x30
[  111.796413]  [<ffffffff82db547b>] invalid_op+0x1b/0x20
[  111.844369]  [<ffffffff82dac59f>] ? _raw_spin_unlock_irqrestore+0x3e/0x61
[  111.893537]  [<ffffffff8197f395>] ? driver_register+0x24/0x116
[  111.943061]  [<ffffffff827e3b18>] __vmbus_driver_register+0x4a/0x5c
[  111.993386]  [<ffffffff8445fcc4>] ? rtsx_init+0x29/0x29
[  112.043646]  [<ffffffff8445fcf9>] storvsc_drv_init+0x35/0x3f
[  112.093912]  [<ffffffff81002099>] do_one_initcall+0x7f/0x13a
[  112.144693]  [<ffffffff843e4caa>] kernel_init+0xce/0x148
[  112.194717]  [<ffffffff82db5604>] kernel_thread_helper+0x4/0x10
[  112.243875]  [<ffffffff82dac9b4>] ? retint_restore_args+0x13/0x13
[  112.290508]  [<ffffffff843e4bdc>] ? start_kernel+0x412/0x412
[  112.336927]  [<ffffffff82db5600>] ? gs_change+0x13/0x13
[  112.382371] Rebooting in 10 seconds..


OOM when running udev net.agent (I suspect it's related to the new
kernel, since I didn't upgrade udev etc. recently):

[  319.628759] VFS: Mounted root (nfs filesystem) on device 0:14.
[  319.720353] debug: unmapping init [mem 0xffffffff8442e000-0xffffffff8481cfff]
[  319.813146] Write protecting the kernel read-only data: 49152k
[  319.906961] debug: unmapping init [mem 0xffff880002f94000-0xffff880002ffffff]
[  319.999937] vhci_hcd: changed 0
[  320.089325] debug: unmapping init [mem 0xffff880003f15000-0xffff880003ffffff]
[  320.747795] modprobe (2774) used greatest stack depth: 3432 bytes left
[  322.143880] ps (2839) used greatest stack depth: 2928 bytes left
[  322.824118] vhci_hcd: changed 0
[  325.040195] vhci_hcd: changed 0
[  325.284854] edd_id (2999) used greatest stack depth: 2832 bytes left
[  327.824190] vhci_hcd: changed 0
[  328.604934] net.agent invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=-17, oom_score_adj=-1000
[  328.604984] net.agent cpuset=/ mems_allowed=0
[  328.604993] Pid: 3224, comm: net.agent Not tainted 3.5.0-rc1+ #2
[  328.604994] Call Trace:
[  328.605003]  [<ffffffff82f82d7b>] ? _raw_spin_unlock+0x28/0x3b
[  328.605007]  [<ffffffff82ed6aa2>] dump_header+0x84/0xbe
[  328.605010]  [<ffffffff82ed6b9d>] oom_kill_process.part.11+0x57/0x25f
[  328.605014]  [<ffffffff81147005>] ? select_bad_process+0x124/0x163
[  328.605016]  [<ffffffff81147078>] oom_kill_process+0x34/0x36
[  328.605018]  [<ffffffff81147435>] out_of_memory+0x18c/0x1d3
[  328.605021]  [<ffffffff8114be87>] __alloc_pages_nodemask+0x5c2/0x762
[  328.605024]  [<ffffffff8116467d>] ? do_wp_page+0x2f0/0x523
[  328.605028]  [<ffffffff8117ce29>] alloc_pages_vma+0x12b/0x138
[  328.605030]  [<ffffffff811646d1>] do_wp_page+0x344/0x523
[  328.605032]  [<ffffffff81165f24>] ? handle_pte_fault+0x124/0x196
[  328.605034]  [<ffffffff81165f69>] handle_pte_fault+0x169/0x196
[  328.605038]  [<ffffffff81162c9d>] ? pmd_offset+0x14/0x3a
[  328.605040]  [<ffffffff811662ef>] handle_mm_fault+0x1b1/0x1cb
[  328.605043]  [<ffffffff82f866ba>] do_page_fault+0x36b/0x390
[  328.605047]  [<ffffffff816f537e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  328.605050]  [<ffffffff81165f24>] ? handle_pte_fault+0x124/0x196
[  328.605051]  [<ffffffff81165f24>] ? handle_pte_fault+0x124/0x196
[  328.605054]  [<ffffffff82f83626>] ? error_sti+0x5/0x6
[  328.605059]  [<ffffffff8112a569>] ? time_hardirqs_off+0x26/0x29
[  328.605061]  [<ffffffff82f83626>] ? error_sti+0x5/0x6
[  328.605108]  [<ffffffff810e025a>] ? trace_hardirqs_off_caller+0x3f/0x9c
[  328.605111]  [<ffffffff816f53bd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  328.605114]  [<ffffffff82f85fd4>] do_async_page_fault+0x31/0x5e
[  328.605117]  [<ffffffff82f83405>] async_page_fault+0x25/0x30
[  328.605118] Mem-Info:
[  328.605120] Node 0 DMA per-cpu:
[  328.605122] CPU    0: hi:    0, btch:   1 usd:   0
[  328.605123] Node 0 DMA32 per-cpu:
[  328.605125] CPU    0: hi:  186, btch:  31 usd:   8
[  328.605128] active_anon:9907 inactive_anon:226 isolated_anon:0
[  328.605128]  active_file:88 inactive_file:529 isolated_file:218
[  328.605128]  unevictable:0 dirty:0 writeback:0 unstable:0
[  328.605128]  free:990 slab_reclaimable:24607 slab_unreclaimable:22610
[  328.605128]  mapped:141 shmem:234 pagetables:2227 bounce:0
[  328.605134] Node 0 DMA free:1540kB min:100kB low:124kB high:148kB active_anon:4484kB inactive_anon:220kB active_file:44kB inactive_file:84kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15596kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:232kB slab_reclaimable:2656kB slab_unreclaimable:3824kB kernel_stack:216kB pagetables:1416kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:228 all_unreclaimable? yes
[  328.605138] lowmem_reserve[]: 0 362 362 362
[  328.605143] Node 0 DMA32 free:2420kB min:2380kB low:2972kB high:3568kB active_anon:35144kB inactive_anon:684kB active_file:308kB inactive_file:2032kB unevictable:0kB isolated(anon):0kB isolated(file):872kB present:370932kB mlocked:0kB dirty:0kB writeback:0kB mapped:564kB shmem:704kB slab_reclaimable:95772kB slab_unreclaimable:86616kB kernel_stack:2456kB pagetables:7492kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:7770 all_unreclaimable? yes
[  328.605145] lowmem_reserve[]: 0 0 0 0
[  328.605159] Node 0 DMA: 6*4kB 0*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 1544kB
[  328.605167] Node 0 DMA32: 39*4kB 21*8kB 3*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2420kB
[  328.605168] 1015 total pagecache pages
[  328.605169] 0 pages in swap cache
[  328.605170] Swap cache stats: add 0, delete 0, find 0/0
[  328.605171] Free swap  = 0kB
[  328.605172] Total swap = 0kB
[  328.607241] 98285 pages RAM
[  328.607242] 22516 pages reserved
[  328.607243] 18715 pages shared
[  328.607243] 70493 pages non-shared
[  328.607245] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  328.607270] [ 2775]     0  2775     2657       51   0       0             0 init
[  328.607274] [ 2776]     0  2776     2339      194   0       0             0 rc
[  328.607277] [ 2836]     0  2836     2347      208   0       0             0 S03udev
[  328.607280] [ 2860]     0  2860     5405      267   0     -17         -1000 udevd
[  328.607285] [ 2874]     0  2874     5371      236   0     -17         -1000 udevd
[  328.607288] [ 2876]     0  2876     5371      235   0     -17         -1000 udevd
[  328.607291] [ 2877]     0  2877     5371      243   0     -17         -1000 udevd
[  328.607294] [ 2878]     0  2878     5371      237   0     -17         -1000 udevd
[  328.607298] [ 2880]     0  2880     5371      235   0     -17         -1000 udevd
[  328.607302] [ 2881]     0  2881     5371      237   0     -17         -1000 udevd
[  328.607305] [ 2882]     0  2882     5371      235   0     -17         -1000 udevd
[  328.607309] [ 2883]     0  2883     5371      240   0     -17         -1000 udevd
[  328.607312] [ 2884]     0  2884     5371      237   0     -17         -1000 udevd
[  328.607316] [ 2885]     0  2885     5371      237   0     -17         -1000 udevd
[  328.607319] [ 2887]     0  2887     5371      242   0     -17         -1000 udevd
[  328.607322] [ 2888]     0  2888     5371      237   0     -17         -1000 udevd
[  328.607325] [ 2889]     0  2889     5371      235   0     -17         -1000 udevd
[  328.607329] [ 2890]     0  2890     5371      237   0     -17         -1000 udevd
[  328.607332] [ 2891]     0  2891     5371      235   0     -17         -1000 udevd
[  328.607345] [ 2893]     0  2893     5371      237   0     -17         -1000 udevd
[  328.607349] [ 2894]     0  2894     5371      235   0     -17         -1000 udevd
[  328.607353] [ 2895]     0  2895     5371      235   0     -17         -1000 udevd
[  328.607356] [ 2896]     0  2896     5371      235   0     -17         -1000 udevd
[  328.607359] [ 2897]     0  2897     5371      235   0     -17         -1000 udevd
[  328.607363] [ 2898]     0  2898     5371      235   0     -17         -1000 udevd
[  328.607366] [ 2899]     0  2899     5371      235   0     -17         -1000 udevd
[  328.607370] [ 2900]     0  2900     5371      235   0     -17         -1000 udevd
[  328.607373] [ 2901]     0  2901     5371      235   0     -17         -1000 udevd
[  328.607376] [ 2902]     0  2902     5371      235   0     -17         -1000 udevd
[  328.607380] [ 2903]     0  2903     5371      235   0     -17         -1000 udevd
[  328.607383] [ 2904]     0  2904     5371      235   0     -17         -1000 udevd
[  328.607386] [ 2905]     0  2905     5371      235   0     -17         -1000 udevd
[  328.607389] [ 2906]     0  2906     5371      235   0     -17         -1000 udevd
[  328.607393] [ 2907]     0  2907     5371      235   0     -17         -1000 udevd
[  328.607396] [ 2908]     0  2908     5372      238   0     -17         -1000 udevd
[  328.607400] [ 2909]     0  2909     5371      232   0     -17         -1000 udevd
[  328.607403] [ 2910]     0  2910     5371      232   0     -17         -1000 udevd
[  328.607406] [ 2911]     0  2911     5371      231   0     -17         -1000 udevd
[  328.607410] [ 2912]     0  2912     5371      227   0     -17         -1000 udevd
[  328.607413] [ 2913]     0  2913     5371      227   0     -17         -1000 udevd
[  328.607417] [ 2914]     0  2914     5371      227   0     -17         -1000 udevd
[  328.607419] [ 2915]     0  2915     5371      227   0     -17         -1000 udevd
[  328.607423] [ 2916]     0  2916     5371      227   0     -17         -1000 udevd
[  328.607426] [ 2917]     0  2917     5371      227   0     -17         -1000 udevd
[  328.607429] [ 2918]     0  2918     5371      227   0     -17         -1000 udevd
[  328.607432] [ 2919]     0  2919     5371      227   0     -17         -1000 udevd
[  328.607435] [ 2920]     0  2920     5371      227   0     -17         -1000 udevd
[  328.607438] [ 2921]     0  2921     5371      227   0     -17         -1000 udevd
[  328.607443] [ 2922]     0  2922     5371      227   0     -17         -1000 udevd
[  328.607447] [ 2923]     0  2923     5371      227   0     -17         -1000 udevd
[  328.607449] [ 2924]     0  2924     5371      227   0     -17         -1000 udevd
[  328.607452] [ 2925]     0  2925     5371      227   0     -17         -1000 udevd
[  328.607455] [ 2928]     0  2928     3169       98   0       0             0 udevadm
[  328.607459] [ 2929]     0  2929     5371      227   0     -17         -1000 udevd
[  328.607461] [ 2930]     0  2930     5371      227   0     -17         -1000 udevd
[  328.607465] [ 2931]     0  2931     5371      227   0     -17         -1000 udevd
[  328.607469] [ 2932]     0  2932     5371      227   0     -17         -1000 udevd
[  328.607474] [ 2933]     0  2933     5371      227   0     -17         -1000 udevd
[  328.607477] [ 2934]     0  2934     5371      227   0     -17         -1000 udevd
[  328.607480] [ 2935]     0  2935     5371      227   0     -17         -1000 udevd
[  328.607484] [ 2936]     0  2936     5371      227   0     -17         -1000 udevd
[  328.607487] [ 2937]     0  2937     5371      227   0     -17         -1000 udevd
[  328.607491] [ 2938]     0  2938     5371      227   0     -17         -1000 udevd
[  328.607494] [ 2939]     0  2939     5371      227   0     -17         -1000 udevd
[  328.607498] [ 2940]     0  2940     5371      227   0     -17         -1000 udevd
[  328.607501] [ 2941]     0  2941     5371      227   0     -17         -1000 udevd
[  328.607511] [ 2942]     0  2942     5371      227   0     -17         -1000 udevd
[  328.607515] [ 2943]     0  2943     5371      227   0     -17         -1000 udevd
[  328.607519] [ 2944]     0  2944     5371      227   0     -17         -1000 udevd
[  328.607522] [ 2945]     0  2945     5371      227   0     -17         -1000 udevd
[  328.607525] [ 2946]     0  2946     5371      227   0     -17         -1000 udevd
[  328.607529] [ 2947]     0  2947     5371      227   0     -17         -1000 udevd
[  328.607532] [ 2948]     0  2948     5371      229   0     -17         -1000 udevd
[  328.607537] [ 3055]     0  3055     4418      137   0     -17         -1000 net.agent
[  328.607541] [ 3056]     0  3056     4418      137   0     -17         -1000 net.agent
[  328.607544] [ 3059]     0  3059     1650      107   0     -17         -1000 ps
[  328.607548] [ 3060]     0  3060     1566       81   0     -17         -1000 grep
[  328.607551] [ 3062]     0  3062     1650      107   0     -17         -1000 ps
[  328.607554] [ 3063]     0  3063     1566       81   0     -17         -1000 grep
[  328.607558] [ 3096]     0  3096     4418      138   0     -17         -1000 net.agent
[  328.607561] [ 3101]     0  3101     4418      138   0     -17         -1000 net.agent
[  328.607565] [ 3102]     0  3102     4418      137   0     -17         -1000 net.agent
[  328.607568] [ 3103]     0  3103     4418      138   0     -17         -1000 net.agent
[  328.607572] [ 3111]     0  3111     4418      137   0     -17         -1000 net.agent
[  328.607576] [ 3113]     0  3113     4418      137   0     -17         -1000 net.agent
[  328.607580] [ 3117]     0  3117     4414      183   0     -17         -1000 net.agent
[  328.607583] [ 3118]     0  3118     4418      137   0     -17         -1000 net.agent
[  328.607587] [ 3119]     0  3119     4418      137   0     -17         -1000 net.agent
[  328.607590] [ 3120]     0  3120     4418      137   0     -17         -1000 net.agent
[  328.607593] [ 3121]     0  3121     4418      138   0     -17         -1000 net.agent
[  328.607596] [ 3122]     0  3122     4418      138   0     -17         -1000 net.agent
[  328.607600] [ 3123]     0  3123     4418      138   0     -17         -1000 net.agent
[  328.607603] [ 3124]     0  3124     4418      137   0     -17         -1000 net.agent
[  328.607606] [ 3125]     0  3125     4418      138   0     -17         -1000 net.agent
[  328.607609] [ 3126]     0  3126     4418      137   0     -17         -1000 net.agent
[  328.607613] [ 3127]     0  3127     4418      138   0     -17         -1000 net.agent
[  328.607616] [ 3129]     0  3129     4418      137   0     -17         -1000 net.agent
[  328.607620] [ 3130]     0  3130     1650      106   0     -17         -1000 ps
[  328.607624] [ 3131]     0  3131     1566       82   0     -17         -1000 grep
[  328.607627] [ 3135]     0  3135     4418      136   0     -17         -1000 net.agent
[  328.607630] [ 3136]     0  3136     4418      137   0     -17         -1000 net.agent
[  328.607635] [ 3137]     0  3137     4414      182   0     -17         -1000 net.agent
[  328.607638] [ 3139]     0  3139     4414      183   0     -17         -1000 net.agent
[  328.607641] [ 3143]     0  3143     1616       84   0     -17         -1000 ps
[  328.607645] [ 3144]     0  3144     1566       81   0     -17         -1000 grep
[  328.607649] [ 3145]     0  3145     4418      137   0     -17         -1000 net.agent
[  328.607652] [ 3146]     0  3146     4414      183   0     -17         -1000 net.agent
[  328.607654] [ 3150]     0  3150     4410      177   0     -17         -1000 net.agent
[  328.607658] [ 3151]     0  3151     4418      137   0     -17         -1000 net.agent
[  328.607661] [ 3152]     0  3152     4408      175   0     -17         -1000 net.agent
[  328.607665] [ 3153]     0  3153     4402      149   0     -17         -1000 net.agent
[  328.607675] [ 3154]     0  3154     4418      137   0     -17         -1000 net.agent
[  328.607680] [ 3155]     0  3155     2296      132   0     -17         -1000 net.agent
[  328.607682] [ 3156]     0  3156     1616       83   0     -17         -1000 ps
[  328.607685] [ 3157]     0  3157     1616       84   0     -17         -1000 ps
[  328.607689] [ 3158]     0  3158     1564       51   0     -17         -1000 grep
[  328.607692] [ 3164]     0  3164     1616       70   0     -17         -1000 ps
[  328.607697] [ 3165]     0  3165     1566       81   0     -17         -1000 grep
[  328.607700] [ 3166]     0  3166     1616       83   0     -17         -1000 ps
[  328.607704] [ 3167]     0  3167     1566       81   0     -17         -1000 grep
[  328.607707] [ 3169]     0  3169     1566       82   0     -17         -1000 grep
[  328.607711] [ 3170]     0  3170     2293      120   0     -17         -1000 net.agent
[  328.607714] [ 3171]     0  3171     2292      108   0     -17         -1000 net.agent
[  328.607718] [ 3172]     0  3172     2848      136   0     -17         -1000 net.agent
[  328.607721] [ 3173]     0  3173     2292      104   0     -17         -1000 net.agent
[  328.607725] [ 3175]     0  3175     4418      136   0     -17         -1000 net.agent
[  328.607728] [ 3176]     0  3176     2328      135   0     -17         -1000 net.agent
[  328.607731] [ 3177]     0  3177     1616       83   0     -17         -1000 ps
[  328.607734] [ 3178]     0  3178     1566       81   0     -17         -1000 grep
[  328.607738] [ 3179]     0  3179     4418      136   0     -17         -1000 net.agent
[  328.607741] [ 3183]     0  3183     1616       83   0     -17         -1000 ps
[  328.607745] [ 3184]     0  3184     1566       81   0     -17         -1000 grep
[  328.607748] [ 3185]     0  3185     2292      107   0     -17         -1000 net.agent
[  328.607751] [ 3186]     0  3186     4418      136   0     -17         -1000 net.agent
[  328.607754] [ 3188]     0  3188     4418      137   0     -17         -1000 net.agent
[  328.607758] [ 3189]     0  3189     1616       69   0     -17         -1000 ps
[  328.607761] [ 3190]     0  3190     1566       82   0     -17         -1000 grep
[  328.607764] [ 3191]     0  3191     1611       31   0     -17         -1000 ps
[  328.607768] [ 3192]     0  3192     1566       82   0     -17         -1000 grep
[  328.607771] [ 3193]     0  3193     4418      137   0     -17         -1000 net.agent
[  328.607775] [ 3194]     0  3194     3384      138   0     -17         -1000 net.agent
[  328.607778] [ 3195]     0  3195     4418      136   0     -17         -1000 net.agent
[  328.607782] [ 3196]     0  3196      159       28   0     -17         -1000 ps
[  328.607785] [ 3197]     0  3197     1566       82   0     -17         -1000 grep
[  328.607789] [ 3198]     0  3198     2320       63   0     -17         -1000 net.agent
[  328.607793] [ 3199]     0  3199      111       21   0     -17         -1000 grep
[  328.607796] [ 3200]     0  3200     1616       84   0     -17         -1000 ps
[  328.607800] [ 3201]     0  3201     1566       82   0     -17         -1000 grep
[  328.607803] [ 3202]     0  3202     4418      137   0     -17         -1000 net.agent
[  328.607806] [ 3203]     0  3203     4418      137   0     -17         -1000 net.agent
[  328.607809] [ 3204]     0  3204     4418       99   0     -17         -1000 net.agent
[  328.607812] [ 3205]     0  3205     2293      110   0     -17         -1000 net.agent
[  328.607815] [ 3206]     0  3206     1616       83   0     -17         -1000 ps
[  328.607818] [ 3207]     0  3207      142       27   0     -17         -1000 grep
[  328.607822] [ 3208]     0  3208      159       29   0     -17         -1000 ps
[  328.607826] [ 3209]     0  3209      658       29   0     -17         -1000 grep
[  328.607829] [ 3210]     0  3210     1566       79   0     -17         -1000 grep
[  328.607833] [ 3211]     0  3211     4418      135   0     -17         -1000 net.agent
[  328.607842] [ 3212]     0  3212     1614       51   0     -17         -1000 ps
[  328.607846] [ 3213]     0  3213     1566       81   0     -17         -1000 grep
[  328.607849] [ 3214]     0  3214     1561       31   0     -17         -1000 grep
[  328.607852] [ 3215]     0  3215     1561       32   0     -17         -1000 grep
[  328.607855] [ 3216]     0  3216      109        3   0     -17         -1000 grep
[  328.607860] [ 3217]     0  3217     4418       78   0     -17         -1000 net.agent
[  328.607864] [ 3218]     0  3218     4414       80   0     -17         -1000 net.agent
[  328.607867] [ 3219]     0  3219      126       15   0     -17         -1000 ps
[  328.607870] [ 3220]     0  3220      658       30   0     -17         -1000 grep
[  328.607873] [ 3221]     0  3221      126        2   0     -17         -1000 ps
[  328.607876] [ 3222]     0  3222     1561       32   0     -17         -1000 grep
[  328.607879] [ 3223]     0  3223     4418      134   0     -17         -1000 net.agent
[  328.607882] [ 3224]     0  3224     4418       75   0     -17         -1000 net.agent
[  328.607885] [ 3225]     0  3225     4418       75   0     -17         -1000 net.agent
[  328.607888] [ 3226]     0  3226     4414       71   0     -17         -1000 net.agent
[  328.607891] [ 3227]     0  3227     4418       99   0     -17         -1000 net.agent
[  328.607895] [ 3228]     0  3228     1561       31   0     -17         -1000 grep
[  328.607898] [ 3229]     0  3229     4418       77   0     -17         -1000 net.agent
[  328.607902] [ 3230]     0  3230     4418       77   0     -17         -1000 net.agent
[  328.607905] [ 3231]     0  3231     5371      188   0     -17         -1000 udevd
[  328.607908] [ 3232]     0  3232     4418       76   0     -17         -1000 net.agent
[  328.607911] [ 3233]     0  3233     4414       77   0     -17         -1000 net.agent
[  328.607914] [ 3234]     0  3234     4418       74   0     -17         -1000 net.agent
[  328.607918] [ 3235]     0  3235     4418       75   0     -17         -1000 net.agent
[  328.607921] [ 3236]     0  3236     4414       69   0     -17         -1000 net.agent
[  328.607923] Out of memory: Kill process 2836 (S03udev) score 56684993 or sacrifice child
[  328.607928] Killed process 2928 (udevadm) total-vm:12676kB, anon-rss:144kB, file-rss:248kB
[  379.158018] vhci_hcd: changed 0
[  379.961613] grep invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=-17, oom_score_adj=-1000
[  379.961617] grep cpuset=/ mems_allowed=0
[  379.961620] Pid: 3246, comm: grep Not tainted 3.5.0-rc1+ #2

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
