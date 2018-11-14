Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Qian Cai <cai@gmx.us>
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: 8BIT
Mime-Version: 1.0 (Mac OS X Mail 12.0 \(3445.100.39\))
Subject: BUG: KASAN: slab-out-of-bounds in try_to_unmap_one+0x1c4/0x1af0
Message-Id: <4519B305-F61A-4C10-B55A-910A3EFB94AA@gmx.us>
Date: Tue, 13 Nov 2018 21:49:52 -0500
Sender: linux-kernel-owner@vger.kernel.org
To: linux kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Compiling kernel on an aarch64 server with the latest mainline (rc2) triggered this,

[ 1463.931841] BUG: KASAN: slab-out-of-bounds in try_to_unmap_one+0x1c4/0x1af0
[ 1463.938969] Write of size 32 at addr ffff80897ce87b58 by task kworker/u513:0/5209
[ 1463.946678] 
[ 1463.948656] CPU: 38 PID: 5209 Comm: kworker/u513:0 Kdump: loaded Tainted: G        W    L    4.20.0-rc2+ #4
[ 1463.958485] Hardware name: HPE Apollo 70             /C01_APACHE_MB         , BIOS L50_5.13_1.0.6 07/10/2018
[ 1463.968450] Workqueue: writeback wb_workfn (flush-253:0)
[ 1463.973848] Call trace:
[ 1463.976622]  dump_backtrace+0x0/0x2c8
[ 1463.980642] 
[ 1463.982239] Allocated by task 2:
[ 1463.985528]  kasan_kmalloc.part.1+0x40/0x108
[ 1463.989842]  kasan_kmalloc+0xb4/0xc8
[ 1463.993500]  kasan_slab_alloc+0x14/0x20
[ 1463.997630]  kmem_cache_alloc_node+0x140/0x430
[ 1464.002241]  copy_process.isra.2+0x39c/0x2e20
[ 1464.007009]  _do_fork+0x120/0xa28
[ 1464.010595]  kernel_thread+0x48/0x58
[ 1464.014206]  kthreadd+0x3dc/0x478
[ 1464.017698]  ret_from_fork+0x10/0x1c
[ 1464.021466] 
[ 1464.022981] Freed by task 1391:
[ 1464.026214]  __kasan_slab_free+0x114/0x228
[ 1464.030447]  kasan_slab_free+0x10/0x18
[ 1464.034305]  kmem_cache_free+0x9c/0x3a8
[ 1464.038284]  put_task_stack+0x94/0x110
[ 1464.042169]  finish_task_switch+0x3b0/0x488
[ 1464.046850]  __schedule+0x5e4/0xda0
[ 1464.050665]  schedule+0xdc/0x240
[ 1464.054012]  worker_thread+0x278/0xa70
[ 1464.058021]  kthread+0x1c4/0x1d0
[ 1464.061393]  ret_from_fork+0x10/0x1c
[ 1464.065051] 
[ 1464.067005] The buggy address belongs to the object at ffff80897ce88000
[ 1464.067005]  which belongs to the cache thread_stack of size 32768
[ 1464.080107] The buggy address is located 1192 bytes to the left of
[ 1464.080107]  32768-byte region [ffff80897ce88000, ffff80897ce90000)
[ 1464.092578] The buggy address belongs to the page:
[ 1464.097529] page:ffff7fe0225f3a00 count:1 mapcount:0 mapping:ffff8089c0014d80 index:0x0 compound_mapcount: 0
[ 1464.107724] flags: 0x1fffff0000010200(slab|head)
[ 1464.112648] raw: 1fffff0000010200 ffff7fe02266a408 ffff7fe022459408 ffff8089c0014d80
[ 1464.120496] raw: 0000000000000000 0000000000050005 00000001ffffffff 0000000000000000
[ 1464.128284] page dumped because: kasan: bad access detected
[ 1464.134011] 
[ 1464.135619] Memory state around the buggy address:
[ 1464.140576]  ffff80897ce87a00: fc fc fc fc fc fc fc fc fc fc fc fc f1 f1 f1 f1
[ 1464.148063]  00 f2 f2 f2 f2 f2^
[ 1464.168846]7c00: f2 f2 f2 f2
