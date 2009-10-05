Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3953B6B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 01:14:05 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Mon, 5 Oct 2009 07:13:58 +0200
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <COE24pZSBH.A.k2B.ZNTxKB@chimera> <200910021111.55749.elendil@planet.nl>
In-Reply-To: <200910021111.55749.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Message-Id: <200910050714.01908.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 02 October 2009, Frans Pop wrote:
> On Thursday 01 October 2009, Rafael J. Wysocki wrote:
> > Bug-Entry=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0: http://bugzilla.kernel.org/sho=
w_bug.cgi?id=3D14141
> > Subject=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0: order 2 page allocat=
ion failures in iwlagn
> > Submitter=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0: Frans Pop <elendil@planet.nl>
> > Date=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0: 2009-=
09-06 7:40 (26 days old)
> > References=C2=A0=C2=A0=C2=A0=C2=A0: http://marc.info/?l=3Dlinux-kernel&=
m=3D125222287419691&w=3D4
> > Handled-By=C2=A0=C2=A0=C2=A0=C2=A0: Pekka Enberg <penberg@cs.helsinki.f=
i>
>
> I'm not sure about this.
>
> The error messages from failed allocations should now be a lot less as a
> result of this commit:
> commit f82a924cc88a5541df1d4b9d38a0968cd077a051
> Author: Reinette Chatre <reinette.chatre@intel.com>
> Date: =C2=A0 Thu Sep 17 10:43:56 2009 -0700
> =C2=A0 =C2=A0 iwlwifi: reduce noise when skb allocation fails
>
> That commit is in mainline, and I'm not sure if it is important enough
> for a stable update (AFAICT it's not listed for 2.6.31.2).
>
> That commit is mostly cosmetic, but possibly the real regression is not
> in iwlagn but in the way memory is freed/defragmented. That aspect was
> also reported by Bartlomiej (#14016) and was extensively discussed
> (without a clear conclusion) here: http://lkml.org/lkml/2009/8/26/140.

I may be getting somewhere with this. I just got the allocation failures
included below on .32-rc3. Note that these are not the "fixable" failures
that got suppressed with the commit referenced above, but the "this could
affect networking" failures that are still reported.

What I was doing when I got them is also interesting:
=2D a kernel build
=2D a gitk for the kernel tree (with full history this uses ~40% of memory)
=2D by mistake I then started a _second_ gitk

The second gitk (which shows as 'wish8.5' in top) caused a massive swap
out which brought the system to a standstill for a while (with huge
latencies as well, including a completely stuck mouse cursor, which
happens rarely).
The system has 2GB RAM + 2GB swap, so IIUC there is no danger of getting
into an OOM as the first gitk can be swapped out completely.

I'll dig into this a bit more as it looks like this should be reproducible,
probably even without the kernel build. Next step is to see how .30 behaves
in the same situation.

Even if it is reproducible with .30, I wonder if the kernel shouldn't be
more robust in this situation. Currently it seems to allow one single
process to claim so much memory before swapping out that "normal" operation
of other processes is affected. I can understand that such a situation may
be hard to avoid on a very busy system where multiple processes start
claiming (a lot of) memory at roughly the same time, but I'd say it should
be avoidable if a single process is the culprit.

BTW, the system recovered completely, although that took some time (the
first gitk remained visible in top long after I closed its window; I think
because the system was busy swapping it back in before terminating it).

Cheers,
=46JP

kcryptd: page allocation failure. order:2, mode:0x4020
Pid: 1483, comm: kcryptd Not tainted 2.6.32-rc3 #22
Call Trace:
 <IRQ>  [<ffffffff8107c3d5>] __alloc_pages_nodemask+0x5a2/0x5ec
 [<ffffffff81264892>] ? _spin_unlock+0x9/0xb
 [<ffffffff811e73cd>] ? __alloc_skb+0x3c/0x15b
 [<ffffffffa03202cb>] ? iwl_rx_allocate+0x8f/0x305 [iwlcore]
 [<ffffffff8107c431>] __get_free_pages+0x12/0x41
 [<ffffffff8109cb1a>] __kmalloc_track_caller+0x3b/0xed
 [<ffffffff811e73f7>] __alloc_skb+0x66/0x15b
 [<ffffffffa03202cb>] iwl_rx_allocate+0x8f/0x305 [iwlcore]
 [<ffffffffa0320557>] iwl_rx_replenish_now+0x16/0x23 [iwlcore]
 [<ffffffffa035c0c8>] iwl_rx_handle+0x3a8/0x3c1 [iwlagn]
 [<ffffffff81051add>] ? sched_clock_local+0x1c/0x80
 [<ffffffffa035c60d>] iwl_irq_tasklet_legacy+0x52c/0x7a4 [iwlagn]
 [<ffffffffa0317aaf>] ? __iwl_read32+0xa5/0xb4 [iwlcore]
 [<ffffffff8103efb8>] tasklet_action+0x71/0xbc
 [<ffffffff8103f837>] __do_softirq+0x96/0x11b
 [<ffffffff8100cabc>] call_softirq+0x1c/0x28
 [<ffffffff8100e5ef>] do_softirq+0x33/0x6b
 [<ffffffff8103f5c5>] irq_exit+0x36/0x75
 [<ffffffff8100dcf1>] do_IRQ+0xa3/0xba
 [<ffffffff8100c353>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff811199dd>] ? scatterwalk_start+0x11/0x19
 [<ffffffff8111bbca>] ? blkcipher_walk_first+0x173/0x196
 [<ffffffff8111b67b>] ? blkcipher_walk_done+0xe6/0x1b8
 [<ffffffff8111bc35>] ? blkcipher_walk_virt+0x1a/0x1d
 [<ffffffffa02001cf>] ? crypto_cbc_encrypt+0x43/0x18e [cbc]
 [<ffffffff81127efd>] ? blk_recount_segments+0x1b/0x2c
 [<ffffffffa021371e>] ? aes_encrypt+0x0/0xf [aes_x86_64]
 [<ffffffff8111af64>] ? async_encrypt+0x38/0x3a
 [<ffffffffa01f7b54>] ? crypt_convert+0x1f9/0x28b [dm_crypt]
 [<ffffffffa01f8009>] ? kcryptd_crypt+0x423/0x449 [dm_crypt]
 [<ffffffffa01f7be6>] ? kcryptd_crypt+0x0/0x449 [dm_crypt]
 [<ffffffff81049bfd>] ? worker_thread+0x146/0x1d8
 [<ffffffff8104d706>] ? autoremove_wake_function+0x0/0x38
 [<ffffffff81049ab7>] ? worker_thread+0x0/0x1d8
 [<ffffffff8104d3f4>] ? kthread+0x7d/0x85
 [<ffffffff8100c9ba>] ? child_rip+0xa/0x20
 [<ffffffff8104d377>] ? kthread+0x0/0x85
 [<ffffffff8100c9b0>] ? child_rip+0x0/0x20
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 171
CPU    1: hi:  186, btch:  31 usd: 177
active_anon:298532 inactive_anon:100163 isolated_anon:52
 active_file:3993 inactive_file:4001 isolated_file:12
 unevictable:399 dirty:0 writeback:76102 unstable:0 buffer:125
 free:14107 slab_reclaimable:4510 slab_unreclaimable:20421
 mapped:7949 shmem:0 pagetables:4437 bounce:0
DMA free:7928kB min:40kB low:48kB high:60kB active_anon:3340kB inactive_ano=
n:3608kB active_file:384kB
   inactive_file:472kB unevictable:0kB isolated(anon):0kB isolated(file):0k=
B present:15336kB mlocked:0kB
   dirty:0kB writeback:80kB mapped:256kB shmem:0kB slab_reclaimable:12kB sl=
ab_unreclaimable:104kB kernel_stack:0kB
   pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:=
0 all_unreclaimable? no
lowmem_reserve[]: 0 1976 1976 1976
DMA32 free:48500kB min:5664kB low:7080kB high:8496kB active_anon:1190788kB =
inactive_anon:397044kB active_file:15588kB
   inactive_file:15532kB unevictable:1596kB isolated(anon):208kB isolated(f=
ile):48kB present:2023748kB mlocked:1596kB
   dirty:0kB writeback:304328kB mapped:31540kB shmem:0kB slab_reclaimable:1=
8028kB slab_unreclaimable:81496kB kernel_stack:1672kB
   pagetables:17732kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scann=
ed:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 19*4kB 13*8kB 3*16kB 7*32kB 11*64kB 11*128kB 5*256kB 0*512kB 0*1024kB =
0*2048kB 1*4096kB =3D 7940kB
DMA32: 9299*4kB 1341*8kB 4*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*102=
4kB 0*2048kB 0*4096kB =3D 48500kB
98572 total pagecache pages
90213 pages in swap cache
Swap cache stats: add 175874, delete 85661, find 7850/8731
=46ree swap  =3D 1425944kB
Total swap =3D 2097144kB
518064 pages RAM
10350 pages reserved
82388 pages shared
437481 pages non-shared
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 =
free buffers remaining.
swapper: page allocation failure. order:2, mode:0x4020
Pid: 0, comm: swapper Not tainted 2.6.32-rc3 #22
Call Trace:
 <IRQ>  [<ffffffff8107c3d5>] __alloc_pages_nodemask+0x5a2/0x5ec
 [<ffffffff81264892>] ? _spin_unlock+0x9/0xb
 [<ffffffff811e73cd>] ? __alloc_skb+0x3c/0x15b
 [<ffffffffa03202cb>] ? iwl_rx_allocate+0x8f/0x305 [iwlcore]
 [<ffffffff8107c431>] __get_free_pages+0x12/0x41
 [<ffffffff8109cb1a>] __kmalloc_track_caller+0x3b/0xed
 [<ffffffff811e73f7>] __alloc_skb+0x66/0x15b
 [<ffffffffa03202cb>] iwl_rx_allocate+0x8f/0x305 [iwlcore]
 [<ffffffffa0320557>] iwl_rx_replenish_now+0x16/0x23 [iwlcore]
 [<ffffffffa035c0c8>] iwl_rx_handle+0x3a8/0x3c1 [iwlagn]
 [<ffffffffa035c60d>] iwl_irq_tasklet_legacy+0x52c/0x7a4 [iwlagn]
 [<ffffffffa0317aaf>] ? __iwl_read32+0xa5/0xb4 [iwlcore]
 [<ffffffff8103efb8>] tasklet_action+0x71/0xbc
 [<ffffffff8103f837>] __do_softirq+0x96/0x11b
 [<ffffffff8100cabc>] call_softirq+0x1c/0x28
 [<ffffffff8100e5ef>] do_softirq+0x33/0x6b
 [<ffffffff8103f5c5>] irq_exit+0x36/0x75
 [<ffffffff8100dcf1>] do_IRQ+0xa3/0xba
 [<ffffffff8100c353>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffffa0278ec7>] ? acpi_idle_enter_simple+0xf9/0x127 [processor]
 [<ffffffffa0278ebd>] ? acpi_idle_enter_simple+0xef/0x127 [processor]
 [<ffffffff811da545>] ? cpuidle_idle_call+0x8c/0xc7
 [<ffffffff8100ae2e>] ? cpu_idle+0x55/0x8d
 [<ffffffff8125432d>] ? rest_init+0x61/0x63
 [<ffffffff81436c3e>] ? start_kernel+0x348/0x353
 [<ffffffff8143629a>] ? x86_64_start_reservations+0xaa/0xae
 [<ffffffff8143637f>] ? x86_64_start_kernel+0xe1/0xe8
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 171
CPU    1: hi:  186, btch:  31 usd: 155
active_anon:297901 inactive_anon:99948 isolated_anon:52
 active_file:3920 inactive_file:3948 isolated_file:12
 unevictable:399 dirty:0 writeback:34634 unstable:0 buffer:125
 free:23390 slab_reclaimable:4510 slab_unreclaimable:11714
 mapped:7819 shmem:0 pagetables:4437 bounce:0
DMA free:7908kB min:40kB low:48kB high:60kB active_anon:3340kB inactive_ano=
n:3608kB active_file:384kB
   inactive_file:472kB unevictable:0kB isolated(anon):0kB isolated(file):0k=
B present:15336kB mlocked:0kB
   dirty:0kB writeback:36kB mapped:256kB shmem:0kB slab_reclaimable:12kB sl=
ab_unreclaimable:12kB kernel_stack:0kB
   pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:=
0 all_unreclaimable? no
lowmem_reserve[]: 0 1976 1976 1976
DMA32 free:85652kB min:5664kB low:7080kB high:8496kB active_anon:1188264kB =
inactive_anon:396184kB active_file:15296kB
   inactive_file:15320kB unevictable:1596kB isolated(anon):208kB isolated(f=
ile):48kB present:2023748kB mlocked:1596kB
   dirty:0kB writeback:138500kB mapped:31020kB shmem:0kB slab_reclaimable:1=
8028kB slab_unreclaimable:46844kB
   kernel_stack:1672kB pagetables:17732kB unstable:0kB bounce:0kB writeback=
_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 17*4kB 12*8kB 4*16kB 6*32kB 11*64kB 11*128kB 5*256kB 0*512kB 0*1024kB =
0*2048kB 1*4096kB =3D 7908kB
DMA32: 12419*4kB 4439*8kB 1*16kB 0*32kB 1*64kB 1*128kB 1*256kB 0*512kB 0*10=
24kB 0*2048kB 0*4096kB =3D 85652kB
97616 total pagecache pages
89394 pages in swap cache
Swap cache stats: add 175906, delete 86512, find 7850/8733
=46ree swap  =3D 1425864kB
Total swap =3D 2097144kB
518064 pages RAM
10350 pages reserved
82282 pages shared
428383 pages non-shared
iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 =
free buffers remaining.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
