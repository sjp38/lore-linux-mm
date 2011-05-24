Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 870146B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 03:07:21 -0400 (EDT)
Received: by gxk23 with SMTP id 23so3191341gxk.14
        for <linux-mm@kvack.org>; Tue, 24 May 2011 00:07:18 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 24 May 2011 09:07:18 +0200
Message-ID: <BANLkTiknVO04h3qrU8Q6sBZbiLOaOjLPJg@mail.gmail.com>
Subject: kernel 2.6.38.6 page allocation failure. order:2, mode:0x4020
From: Stefan Majer <stefan.majer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

im running 4 nodes with ceph on top of btrfs with a dualport Intel
X520 10Gb Ethernet Card with the latest 3.3.9 ixgbe driver.
during benchmarks i get the following stack.
I can easily reproduce this by simply running rados bench from a fast
machine using this 4 nodes as ceph cluster.
We saw this with stock ixgbe driver from 2.6.38.6 and with the latest
3.3.9 ixgbe.
This kernel is tainted because we use fusion-io iodrives as journal
devices for btrfs.

Any hints to nail this down are welcome.

Greetings Stefan Majer

May 10 15:26:40 os02 kernel: [ 3652.485219] cosd: page allocation
failure. order:2, mode:0x4020
May 10 15:26:40 os02 kernel: [ 3652.485223] kswapd0: page allocation
failure. order:2, mode:0x4020
May 10 15:26:40 os02 kernel: [ 3652.485228] Pid: 57, comm: kswapd0
Tainted: P        W   2.6.38.6-1.fits.1.el6.x86_64 #1
May 10 15:26:40 os02 kernel: [ 3652.485230] Call Trace:
May 10 15:26:40 os02 kernel: [ 3652.485232]  <IRQ>
[<ffffffff81108ce7>] ? __alloc_pages_nodemask+0x6f7/0x8a0
May 10 15:26:40 os02 kernel: [ 3652.485247]  [<ffffffff814b0ad0>] ?
ip_local_deliver+0x80/0x90
May 10 15:26:40 os02 kernel: [ 3652.485250] cosd: page allocation
failure. order:2, mode:0x4020
May 10 15:26:40 os02 kernel: [ 3652.485256]  [<ffffffff81146cd2>] ?
kmalloc_large_node+0x62/0xb0
May 10 15:26:40 os02 kernel: [ 3652.485259] Pid: 1849, comm: cosd
Tainted: P        W   2.6.38.6-1.fits.1.el6.x86_64 #1
May 10 15:26:40 os02 kernel: [ 3652.485261] Call Trace:
May 10 15:26:40 os02 kernel: [ 3652.485264]  [<ffffffff8114becb>] ?
__kmalloc_node_track_caller+0x15b/0x1d0
May 10 15:26:40 os02 kernel: [ 3652.485266]  <IRQ>[<ffffffff81466f74>]
? __netdev_alloc_skb+0x24/0x50
May 10 15:26:40 os02 kernel: [ 3652.485274]  [<ffffffff81108ce7>] ?
__alloc_pages_nodemask+0x6f7/0x8a0
May 10 15:26:40 os02 kernel: [ 3652.485277]  [<ffffffff81466713>] ?
__alloc_skb+0x83/0x170
May 10 15:26:40 os02 kernel: [ 3652.485281]  [<ffffffff814b0ad0>] ?
ip_local_deliver+0x80/0x90
May 10 15:26:40 os02 kernel: [ 3652.485283]  [<ffffffff81466f74>] ?
__netdev_alloc_skb+0x24/0x50
May 10 15:26:40 os02 kernel: [ 3652.485287]  [<ffffffff81146cd2>] ?
kmalloc_large_node+0x62/0xb0
May 10 15:26:40 os02 kernel: [ 3652.485297]  [<ffffffffa005d9aa>] ?
ixgbe_alloc_rx_buffers+0x9a/0x450 [ixgbe]
May 10 15:26:40 os02 kernel: [ 3652.485300]  [<ffffffff8114becb>] ?
__kmalloc_node_track_caller+0x15b/0x1d0
May 10 15:26:40 os02 kernel: [ 3652.485305]  [<ffffffff812b79e0>] ?
swiotlb_map_page+0x0/0x110
May 10 15:26:40 os02 kernel: [ 3652.485308]  [<ffffffff81466f74>] ?
__netdev_alloc_skb+0x24/0x50
May 10 15:26:40 os02 kernel: [ 3652.485315]  [<ffffffffa0060930>] ?
ixgbe_poll+0x1140/0x1670 [ixgbe]
May 10 15:26:40 os02 kernel: [ 3652.485318]  [<ffffffff81466713>] ?
__alloc_skb+0x83/0x170
May 10 15:26:40 os02 kernel: [ 3652.485323]  [<ffffffff810f33eb>] ?
perf_pmu_enable+0x2b/0x40
May 10 15:26:40 os02 kernel: [ 3652.485326]  [<ffffffff81466f74>] ?
__netdev_alloc_skb+0x24/0x50
May 10 15:26:40 os02 kernel: [ 3652.485330]  [<ffffffff81474eb2>] ?
net_rx_action+0x102/0x2a0
May 10 15:26:40 os02 kernel: [ 3652.485336]  [<ffffffffa005d9aa>] ?
ixgbe_alloc_rx_buffers+0x9a/0x450 [ixgbe]
May 10 15:26:40 os02 kernel: [ 3652.485341]  [<ffffffff8106b745>] ?
__do_softirq+0xb5/0x210
May 10 15:26:40 os02 kernel: [ 3652.485344]  [<ffffffff81474840>] ?
napi_skb_finish+0x50/0x70
May 10 15:26:40 os02 kernel: [ 3652.485348]  [<ffffffff810c7ca4>] ?
handle_IRQ_event+0x54/0x180
May 10 15:26:40 os02 kernel: [ 3652.485354]  [<ffffffffa0060930>] ?
ixgbe_poll+0x1140/0x1670 [ixgbe]
May 10 15:26:40 os02 kernel: [ 3652.485357]  [<ffffffff8106b7bd>] ?
__do_softirq+0x12d/0x210
May 10 15:26:40 os02 kernel: [ 3652.485360]  [<ffffffff810f33eb>] ?
perf_pmu_enable+0x2b/0x40
May 10 15:26:40 os02 kernel: [ 3652.485364]  [<ffffffff8100cf3c>] ?
call_softirq+0x1c/0x30
May 10 15:26:40 os02 kernel: [ 3652.485367]  [<ffffffff81474eb2>] ?
net_rx_action+0x102/0x2a0
May 10 15:26:40 os02 kernel: [ 3652.485369]  [<ffffffff8100e975>] ?
do_softirq+0x65/0xa0
May 10 15:26:40 os02 kernel: [ 3652.485372]  [<ffffffff8106b745>] ?
__do_softirq+0xb5/0x210
May 10 15:26:40 os02 kernel: [ 3652.485375]  [<ffffffff8106b605>] ?
irq_exit+0x95/0xa0
May 10 15:26:40 os02 kernel: [ 3652.485379]  [<ffffffff810c7ca4>] ?
handle_IRQ_event+0x54/0x180
May 10 15:26:40 os02 kernel: [ 3652.485383]  [<ffffffff8154a276>] ?
do_IRQ+0x66/0xe0
May 10 15:26:40 os02 kernel: [ 3652.485386]  [<ffffffff8106b7bd>] ?
__do_softirq+0x12d/0x210
May 10 15:26:40 os02 kernel: [ 3652.485389]  [<ffffffff81542a53>] ?
ret_from_intr+0x0/0x15
May 10 15:26:40 os02 kernel: [ 3652.485391]  <EOI>
[<ffffffff8100cf3c>] ? call_softirq+0x1c/0x30
May 10 15:26:40 os02 kernel: [ 3652.485397]  [<ffffffff81110a54>] ?
shrink_inactive_list+0x164/0x460
May 10 15:26:40 os02 kernel: [ 3652.485400]  [<ffffffff8100e975>] ?
do_softirq+0x65/0xa0
May 10 15:26:40 os02 kernel: [ 3652.485404]  [<ffffffff8153facc>] ?
schedule+0x44c/0xa10
May 10 15:26:40 os02 kernel: [ 3652.485407]  [<ffffffff8106b605>] ?
irq_exit+0x95/0xa0
May 10 15:26:40 os02 kernel: [ 3652.485412]  [<ffffffff81109b1a>] ?
determine_dirtyable_memory+0x1a/0x30
May 10 15:26:40 os02 kernel: [ 3652.485416]  [<ffffffff8154a276>] ?
do_IRQ+0x66/0xe0
May 10 15:26:40 os02 kernel: [ 3652.485419]  [<ffffffff81111453>] ?
shrink_zone+0x3d3/0x530
May 10 15:26:40 os02 kernel: [ 3652.485422]  [<ffffffff81542a53>] ?
ret_from_intr+0x0/0x15
May 10 15:26:40 os02 kernel: [ 3652.485423]  <EOI>
[<ffffffff81074a4a>] ? del_timer_sync+0x3a/0x60
May 10 15:26:40 os02 kernel: [ 3652.485430]  [<ffffffff812a774d>] ?
copy_user_generic_string+0x2d/0x40
May 10 15:26:40 os02 kernel: [ 3652.485435]  [<ffffffff811054a5>] ?
zone_watermark_ok_safe+0xb5/0xd0
May 10 15:26:40 os02 kernel: [ 3652.485439]  [<ffffffff810ff351>] ?
iov_iter_copy_from_user_atomic+0x101/0x170
May 10 15:26:40 os02 kernel: [ 3652.485442]  [<ffffffff81112a69>] ?
kswapd+0x889/0xb20
May 10 15:26:40 os02 kernel: [ 3652.485457]  [<ffffffffa026c91d>] ?
btrfs_copy_from_user+0xcd/0x130 [btrfs]
May 10 15:26:40 os02 kernel: [ 3652.485460]  [<ffffffff811121e0>] ?
kswapd+0x0/0xb20
May 10 15:26:40 os02 kernel: [ 3652.485472]  [<ffffffffa026d844>] ?
__btrfs_buffered_write+0x1a4/0x330 [btrfs]
May 10 15:26:40 os02 kernel: [ 3652.485476]  [<ffffffff810862b6>] ?
kthread+0x96/0xa0
May 10 15:26:40 os02 kernel: [ 3652.485479]  [<ffffffff8117151f>] ?
file_update_time+0x5f/0x170
May 10 15:26:40 os02 kernel: [ 3652.485482]  [<ffffffff8100ce44>] ?
kernel_thread_helper+0x4/0x10
May 10 15:26:40 os02 kernel: [ 3652.485493]  [<ffffffffa026dc08>] ?
btrfs_file_aio_write+0x238/0x4e0 [btrfs]
May 10 15:26:40 os02 kernel: [ 3652.485496]  [<ffffffff81086220>] ?
kthread+0x0/0xa0
May 10 15:26:40 os02 kernel: [ 3652.485507]  [<ffffffffa026d9d0>] ?
btrfs_file_aio_write+0x0/0x4e0 [btrfs]
May 10 15:26:40 os02 kernel: [ 3652.485511]  [<ffffffff8100ce40>] ?
kernel_thread_helper+0x0/0x10
May 10 15:26:40 os02 kernel: [ 3652.485515]  [<ffffffff81158ff3>] ?
do_sync_readv_writev+0xd3/0x110
May 10 15:26:40 os02 kernel: [ 3652.485516] Mem-Info:
May 10 15:26:40 os02 kernel: [ 3652.485519]  [<ffffffff81163d42>] ?
path_put+0x22/0x30
May 10 15:26:40 os02 kernel: [ 3652.485521] Node 0 DMA per-cpu:
May 10 15:26:40 os02 kernel: [ 3652.485525]  [<ffffffff812584a3>] ?
selinux_file_permission+0xf3/0x150
May 10 15:26:40 os02 kernel: [ 3652.485528] CPU    0: hi:    0, btch: 1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485530] CPU    1: hi:    0, btch: 1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485534]  [<ffffffff81251583>] ?
security_file_permission+0x23/0x90
May 10 15:26:40 os02 kernel: [ 3652.485535] CPU    2: hi:    0, btch: 1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485538] CPU    3: hi:    0, btch: 1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485542]  [<ffffffff81159f14>] ?
do_readv_writev+0xd4/0x1e0
May 10 15:26:40 os02 kernel: [ 3652.485544] CPU    4: hi:    0, btch: 1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485547] CPU    5: hi:    0, btch: 1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485550]  [<ffffffff81540d91>] ?
mutex_lock+0x31/0x60
May 10 15:26:40 os02 kernel: [ 3652.485552] CPU    6: hi:    0, btch: 1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485554] CPU    7: hi:    0, btch: 1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485557]  [<ffffffff8115a066>] ?
vfs_writev+0x46/0x60
May 10 15:26:40 os02 kernel: [ 3652.485558] Node 0 DMA32 per-cpu:
May 10 15:26:40 os02 kernel: [ 3652.485562]  [<ffffffff8115a1a1>] ?
sys_writev+0x51/0xc0
May 10 15:26:40 os02 kernel: [ 3652.485564] CPU    0: hi:  186, btch:
31 usd: 144
May 10 15:26:40 os02 kernel: [ 3652.485567] CPU    1: hi:  186, btch:
31 usd: 198
May 10 15:26:40 os02 kernel: [ 3652.485571]  [<ffffffff8100c002>] ?
system_call_fastpath+0x16/0x1b
May 10 15:26:40 os02 kernel: [ 3652.485573] CPU    2: hi:  186, btch:
31 usd: 180
May 10 15:26:40 os02 kernel: [ 3652.485574] Mem-Info:
May 10 15:26:40 os02 kernel: [ 3652.485576] CPU    3: hi:  186, btch:
31 usd: 171
May 10 15:26:40 os02 kernel: [ 3652.485578] Node 0 CPU    4: hi:  186,
btch:  31 usd: 159
May 10 15:26:40 os02 kernel: [ 3652.485581] DMA per-cpu:
May 10 15:26:40 os02 kernel: [ 3652.485582] CPU    5: hi:  186, btch:
31 usd:  69
May 10 15:26:40 os02 kernel: [ 3652.485585] CPU    0: hi:    0, btch:
1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485587] CPU    6: hi:  186, btch:
31 usd: 180
May 10 15:26:40 os02 kernel: [ 3652.485589] CPU    1: hi:    0, btch:
1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485591] CPU    7: hi:  186, btch:
31 usd: 184
May 10 15:26:40 os02 kernel: [ 3652.485593] CPU    2: hi:    0, btch:
1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485594] Node 0 CPU    3: hi:    0,
btch:   1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485597] Normal per-cpu:
May 10 15:26:40 os02 kernel: [ 3652.485598] CPU    4: hi:    0, btch:
1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485600] CPU    0: hi:  186, btch:
31 usd: 100
May 10 15:26:40 os02 kernel: [ 3652.485602] CPU    5: hi:    0, btch:
1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485604] CPU    1: hi:  186, btch:
31 usd:  47
May 10 15:26:40 os02 kernel: [ 3652.485606] CPU    6: hi:    0, btch:
1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485608] CPU    2: hi:  186, btch:
31 usd: 168
May 10 15:26:40 os02 kernel: [ 3652.485610] CPU    7: hi:    0, btch:
1 usd:   0
May 10 15:26:40 os02 kernel: [ 3652.485612] CPU    3: hi:  186, btch:
31 usd: 140
May 10 15:26:40 os02 kernel: [ 3652.485614] Node 0 CPU    4: hi:  186,
btch:  31 usd: 177
May 10 15:26:40 os02 kernel: [ 3652.485617] DMA32 per-cpu:
May 10 15:26:40 os02 kernel: [ 3652.485618] CPU    5: hi:  186, btch:
31 usd:  77
May 10 15:26:40 os02 kernel: [ 3652.485621] CPU    0: hi:  186, btch:
31 usd: 144
May 10 15:26:40 os02 kernel: [ 3652.485623] CPU    6: hi:  186, btch:
31 usd: 168
May 10 15:26:40 os02 kernel: [ 3652.485625] CPU    1: hi:  186, btch:
31 usd: 198
May 10 15:26:40 os02 kernel: [ 3652.485627] CPU    7: hi:  186, btch:
31 usd:  68
May 10 15:26:40 os02 kernel: [ 3652.485629] CPU    2: hi:  186, btch:
31 usd: 180
May 10 15:26:40 os02 kernel: [ 3652.485634] active_anon:255806
inactive_anon:19454 isolated_anon:0
May 10 15:26:40 os02 kernel: [ 3652.485636]  active_file:420093
inactive_file:5180559 isolated_file:0
May 10 15:26:40 os02 kernel: [ 3652.485637]  unevictable:50582
dirty:314034 writeback:8484 unstable:0
May 10 15:26:40 os02 kernel: [ 3652.485639]  free:30074
slab_reclaimable:35739 slab_unreclaimable:13526
May 10 15:26:40 os02 kernel: [ 3652.485641]  mapped:3440 shmem:51
pagetables:1342 bounce:0
May 10 15:26:40 os02 kernel: [ 3652.485643] CPU    3: hi:  186, btch:
31 usd: 171
May 10 15:26:40 os02 kernel: [ 3652.485644] Node 0 CPU    4: hi:  186,
btch:  31 usd: 159
May 10 15:26:40 os02 kernel: [ 3652.485652] DMA free:15852kB min:12kB
low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB
mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
May 10 15:26:40 os02 kernel: [ 3652.485659] CPU    5: hi:  186, btch:
31 usd:  69
May 10 15:26:40 os02 kernel: [ 3652.485661] lowmem_reserve[]:CPU    6:
hi:  186, btch:  31 usd: 180
May 10 15:26:40 os02 kernel: [ 3652.485663]  0CPU    7: hi:  186,
btch:  31 usd: 184
May 10 15:26:40 os02 kernel: [ 3652.485665]  2991Node 0  24201Normal per-cpu:
May 10 15:26:40 os02 kernel: [ 3652.485668]  24201CPU    0: hi:  186,
btch:  31 usd: 100
May 10 15:26:40 os02 kernel: [ 3652.485671]
May 10 15:26:40 os02 kernel: [ 3652.485672] CPU    1: hi:  186, btch:
31 usd:  47
May 10 15:26:40 os02 kernel: [ 3652.485674] Node 0 CPU    2: hi:  186,
btch:  31 usd: 168
May 10 15:26:40 os02 kernel: [ 3652.485682] DMA32 free:85748kB
min:2460kB low:3072kB high:3688kB active_anon:20480kB
inactive_anon:5268kB active_file:151588kB inactive_file:2645188kB
unevictable:72kB isolated(anon):0kB isolated(file):0kB
present:3063392kB mlocked:0kB dirty:210820kB writeback:0kB
mapped:648kB shmem:0kB slab_reclaimable:28400kB
slab_unreclaimable:2152kB kernel_stack:520kB pagetables:100kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
May 10 15:26:40 os02 kernel: [ 3652.485690] CPU    3: hi:  186, btch:
31 usd: 140
May 10 15:26:40 os02 kernel: [ 3652.485691] lowmem_reserve[]:CPU    4:
hi:  186, btch:  31 usd: 177
May 10 15:26:40 os02 kernel: [ 3652.485693]  0CPU    5: hi:  186,
btch:  31 usd:  77
May 10 15:26:40 os02 kernel: [ 3652.485696]  0CPU    6: hi:  186,
btch:  31 usd: 168
May 10 15:26:40 os02 kernel: [ 3652.485698]  21210CPU    7: hi:  186,
btch:  31 usd:  68
May 10 15:26:40 os02 kernel: [ 3652.485701]  21210active_anon:255806
inactive_anon:19454 isolated_anon:0
May 10 15:26:40 os02 kernel: [ 3652.485705]  active_file:420093
inactive_file:5180559 isolated_file:0
May 10 15:26:40 os02 kernel: [ 3652.485706]  unevictable:50582
dirty:314034 writeback:8484 unstable:0
May 10 15:26:40 os02 kernel: [ 3652.485707]  free:30074
slab_reclaimable:35739 slab_unreclaimable:13526
May 10 15:26:40 os02 kernel: [ 3652.485708]  mapped:3440 shmem:51
pagetables:1342 bounce:0
May 10 15:26:40 os02 kernel: [ 3652.485709]
May 10 15:26:40 os02 kernel: [ 3652.485710] Node 0 Node 0 DMA
free:15852kB min:12kB low:12kB high:16kB active_anon:0kB
inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB
dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
May 10 15:26:40 os02 kernel: [ 3652.485724] Normal free:18696kB
min:17440kB low:21800kB high:26160kB active_anon:1002744kB
inactive_anon:72548kB active_file:1528784kB inactive_file:18077048kB
unevictable:202256kB isolated(anon):0kB isolated(file):0kB
present:21719040kB mlocked:0kB dirty:1045316kB writeback:33936kB
mapped:13112kB shmem:204kB slab_reclaimable:114556kB
slab_unreclaimable:51952kB kernel_stack:3768kB pagetables:5268kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:32
all_unreclaimable? no
May 10 15:26:40 os02 kernel: [ 3652.485731]
lowmem_reserve[]:lowmem_reserve[]: 0 0 2991 0 24201 0 24201 0
May 10 15:26:40 os02 kernel: [ 3652.485737]
May 10 15:26:40 os02 kernel: [ 3652.485738] Node 0 Node 0 DMA32
free:85748kB min:2460kB low:3072kB high:3688kB active_anon:20480kB
inactive_anon:5268kB active_file:151588kB inactive_file:2645188kB
unevictable:72kB isolated(anon):0kB isolated(file):0kB
present:3063392kB mlocked:0kB dirty:210820kB writeback:0kBmapped:648kB
shmem:0kB slab_reclaimable:28400kB slab_unreclaimable:2152kB
kernel_stack:520kB pagetables:100kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
May 10 15:26:40 os02 kernel: [ 3652.485747] DMA:lowmem_reserve[]:1*4kB
 01*8kB  00*16kB  212101*32kB  212101*64kB
May 10 15:26:40 os02 kernel: [ 3652.485754] 1*128kB Node 0 1*256kB
Normal free:18696kB min:17440kB low:21800kB high:26160kB
active_anon:1002744kB inactive_anon:72548kB active_file:1528784kB
inactive_file:18077048kB unevictable:202256kB isolated(anon):0kB
isolated(file):0kB present:21719040kB mlocked:0kB dirty:1045316kB
writeback:33936kB mapped:13112kB shmem:204kB slab_reclaimable:114556kB
slab_unreclaimable:51952kB kernel_stack:3768kB pagetables:5268kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:32
all_unreclaimable? no
May 10 15:26:40 os02 kernel: [ 3652.485764] 0*512kB
lowmem_reserve[]:1*1024kB  01*2048kB  03*4096kB  0= 15852kB May 10
15:26:40 os02 kernel: [ 3652.485771]  0Node 0 May 10 15:26:40 os02
kernel: [ 3652.485773] DMA32: Node 0 59*4kB DMA: 125*8kB 1*4kB 66*16kB
1*8kB 80*32kB 0*16kB 188*64kB 1*32kB 51*128kB 1*64kB 15*256kB 1*128kB
40*512kB 1*256kB 31*1024kB 0*512kB 1*2048kB 1*1024kB 1*4096kB 1*2048kB
= 85620kB
May 10 15:26:40 os02 kernel: [ 3652.485789] 3*4096kB Node 0 = 15852kB
May 10 15:26:40 os02 kernel: [ 3652.485791] Normal: Node 0 3930*4kB
DMA32: 0*8kB 59*4kB 1*16kB 125*8kB 0*32kB 66*16kB 0*64kB 80*32kB
0*128kB 188*64kB 1*256kB 51*128kB 1*512kB 15*256kB 0*1024kB 40*512kB
1*2048kB 31*1024kB 0*4096kB 1*2048kB = 18552kB
May 10 15:26:40 os02 kernel: [ 3652.485807] 1*4096kB 5651289 total
pagecache pages
May 10 15:26:40 os02 kernel: [ 3652.485809] = 85620kB
May 10 15:26:40 os02 kernel: [ 3652.485810] 0 pages in swap cache
May 10 15:26:40 os02 kernel: [ 3652.485811] Node 0 Swap cache stats:
add 0, delete 0, find 0/0
May 10 15:26:40 os02 kernel: [ 3652.485814] Normal: Free swap  = 1048572kB
May 10 15:26:40 os02 kernel: [ 3652.485815] 3930*4kB Total swap = 1048572kB
May 10 15:26:40 os02 kernel: [ 3652.485817] 0*8kB 1*16kB 0*32kB 0*64kB
0*128kB 1*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 18552kB
May 10 15:26:40 os02 kernel: [ 3652.485822] 5651289 total pagecache pages
May 10 15:26:40 os02 kernel: [ 3652.485823] 0 pages in swap cache
May 10 15:26:40 os02 kernel: [ 3652.485824] Swap cache stats: add 0,
delete 0, find 0/0
May 10 15:26:40 os02 kernel: [ 3652.485825] Free swap  = 1048572kB
May 10 15:26:40 os02 kernel: [ 3652.485826] Total swap = 1048572kB

-- 
Stefan Majer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
