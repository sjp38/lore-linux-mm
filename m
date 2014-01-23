Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 88F5B6B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 17:49:38 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so2378715pde.27
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 14:49:38 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xy6si15610892pab.327.2014.01.23.14.49.34
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 14:49:34 -0800 (PST)
Message-ID: <52E19C7D.7050603@intel.com>
Date: Thu, 23 Jan 2014 14:49:33 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Panic on 8-node system in memblock_virt_alloc_try_nid()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>Santosh Shilimkar <santosh.shilimkar@ti.com>

Linus's current tree doesn't boot on an 8-node/1TB NUMA system that I
have.  Its reboots are *LONG*, so I haven't fully bisected it, but it's
down to a just a few commits, most of which are changes to the memblock
code.  Since the panic is in the memblock code, it looks like a
no-brainer.  It's almost certainly the code from Santosh or Grygorii
that's triggering this.

Config and good/bad dmesg with memblock=debug are here:

	http://sr71.net/~dave/intel/3.13/

Please let me know if you need it bisected further than this.

The remaining commits are these:

> commit 4883e997b26ed857da8dae6a6e6aeb12830b978d
> commit 560dca27a6b36015e4f69a4ceba0ee5be0707c17
> commit 9a28f9dc8d10b619af9a37b1e27c41ada5415629
> commit b6cb5bab263791d09abe88f24df6c2da53415320
> commit cfb665864e54ee7a160750b4815bfe6b7eb13d0d
> commit 9233d2be108f573caa21eb450411bf8fa68cadbb
> commit 4fc0bc58cb7d983e55baa8dcbb7c1a4ee54e65be
> commit 9e43aa2b8d1cb3137bd7e60d5fead83d0569de2b
> commit 999c17e3de4855af4e829c0871ad32fc76a93991
> commit 0d036e9e33df8befa9348683ba68258fee7f0a00
> commit 8b89a1169437541a2a9b62c8f7b1a5c0ceb0fbde
> commit bb016b84164554725899aef544331085e08cb402
> commit c15295001aa940df4e3cf6574808a4addca9f2e5
> commit 457ff1de2d247d9b8917c4664c2325321a35e313
> commit c2f69cdafebb3a46e43b5ac57ca12b539a2c790f
> commit 6782832eba5e8c87a749a41da8deda1c3ef67ba0
> commit 9da791dfabc60218c81904c7906b45789466e68e
> commit 098b081b50d5eb8c7e0200a4770b0bcd28eab9ce
> commit 26f09e9b3a0696f6fe20b021901300fba26fb579
> commit b115423357e0cda6d8f45d0c81df537d7b004020
> commit 87029ee9390b2297dae699d5fb135b77992116e5
> commit 79f40fab0b3a78e0e41fac79a65a9870f4b05652
> commit 869a84e1ca163b737236dae997db4a6a1e230b9b
> commit 10e89523bf5aade79081f501452fe7f1a16fa189
> commit fd615c4e671979e3e362df537d6be38f8d27aa80
> commit 5b6e529521d35e1bcaa0fe43456d1bbb335cae5d

The oops I see is this:

> [    0.000000] Kernel panic - not syncing: : Failed to allocate 2143289344 bytes align=0x200000 nid=0 from=0x1000000 max_addr=0x0
> [    0.000000] 
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.13.0-slub-03995-g0dc3fd0-dirty #816
> [    0.000000] Hardware name: FUJITSU-SV PRIMEQUEST 1800E2/SB, BIOS PRIMEQUEST 1000 Series BIOS Version 1.24 09/14/2011
> [    0.000000]  0000000001000000 ffffffff81c01ce8 ffffffff81706941 0000000000000687
> [    0.000000]  ffffffff81a30b48 ffffffff81c01d68 ffffffff817029de 0000000000000000
> [    0.000000]  0000000000000030 ffffffff81c01d80 ffffffff81c01d18 ffffffff81c01d68
> [    0.000000] Call Trace:
> [    0.000000]  [<ffffffff81706941>] dump_stack+0x4e/0x68
> [    0.000000]  [<ffffffff817029de>] panic+0xbb/0x1cb
> [    0.000000]  [<ffffffff81d3bef9>] memblock_virt_alloc_try_nid+0xa1/0xa1
> [    0.000000]  [<ffffffff816ff5f9>] __earlyonly_bootmem_alloc.constprop.0+0x21/0x28
> [    0.000000]  [<ffffffff81d3cf27>] sparse_mem_maps_populate_node+0x34/0x132
> [    0.000000]  [<ffffffff81d3cbd3>] ? alloc_usemap_and_memmap+0x10f/0x10f
> [    0.000000]  [<ffffffff81d3cbdc>] sparse_early_mem_maps_alloc_node+0x9/0xb
> [    0.000000]  [<ffffffff81d3cb96>] alloc_usemap_and_memmap+0xd2/0x10f
> [    0.000000]  [<ffffffff81d3ce29>] sparse_init+0x85/0x14f
> [    0.000000]  [<ffffffff81d2adbb>] paging_init+0x13/0x22
> [    0.000000]  [<ffffffff81d1b521>] setup_arch+0xb51/0xc6e
> [    0.000000]  [<ffffffff81703150>] ? printk+0x4d/0x4f
> [    0.000000]  [<ffffffff81d14b1a>] start_kernel+0x85/0x3db
> [    0.000000]  [<ffffffff81d145a8>] x86_64_start_reservations+0x2a/0x2c
> [    0.000000]  [<ffffffff81d1469a>] x86_64_start_kernel+0xf0/0xf7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
