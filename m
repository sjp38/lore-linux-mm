Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E360E6B29B5
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:02:39 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u129-v6so4297827qkf.15
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 04:02:39 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r10-v6si3983353qvi.112.2018.08.23.04.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 04:02:38 -0700 (PDT)
Date: Thu, 23 Aug 2018 07:02:37 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
In-Reply-To: <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com>
Message-ID: <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com> <20180821104418.GA16611@dhcp22.suse.cz> <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>



On Tue, 21 Aug 2018, James Morse wrote:

> Hi guys,
> 
> On 08/21/2018 11:44 AM, Michal Hocko wrote:
> > On Fri 17-08-18 15:44:27, Mikulas Patocka wrote:
> > > I report this crash on ARM64 on the kernel 4.17.11. The reason is that the
> > > function move_freepages_block accesses contiguous runs of
> > > pageblock_nr_pages. The ARM64 firmware sets holes of reserved memory there
> > > and when move_freepages_block stumbles over this hole, it accesses
> > > uninitialized page structures and crashes.
> 
> Any idea if this is nomap (so a hole in the linear map), or a missing struct
> page?

The page for this hole seems to be filled with 0xff.

> > > 00000000-03ffffff : System RAM
> > >    00080000-007bffff : Kernel code
> > >    00820000-00aa3fff : Kernel data
> > > 04200000-bf80ffff : System RAM
> > > bf810000-bfbeffff : reserved
> > > bfbf0000-bfc8ffff : System RAM
> > > bfc90000-bffdffff : reserved
> > > bffe0000-bfffffff : System RAM
> > > c0000000-dfffffff : MEM
> > >    c0000000-c00fffff : PCI Bus 0000:01
> > >      c0000000-c0003fff : 0000:01:00.0
> > >        c0000000-c0003fff : nvme
> To test Laura's bounds-of-zone theory [0], could you put some empty space
> between the nvme and the System RAM? (It sounds like this is a KVM guest).
> Reducing the amount of memory is probably easiest.

This is not KVM - it is real hardware with real PCIe nvme device. I don't 
have smaller memory stick.

The board can use u-boot firmware or EFI firmware. The u-boot firmware 
doesn't put a hole in the memory map and the board has been running with 
it for several months without a problem.

The EFI firmware puts a hole below 0xc0000000 and I got a crash after two 
weeks of uptime.

> > > The bug was already reported here for x86:
> > > https://bugzilla.redhat.com/show_bug.cgi?id=1598462
> > > 
> > > For x86, it was fixed in the kernel 4.17.7 - but I observed it in the
> > > kernel 4.17.11 on ARM64. I also observed it on 4.18-rc kernels running in
> > > KVM virtual machine on ARM when I compiled the guest kernel with 64kB page
> > > size.
> 
> I'm not sure this is the same bug.
> 
> [1] reports hitting a VM_BUG, this is a dereference of -ENOENT:

This crash is not from -ENOENT. It crashes because page->compound_head is 
0xffffffffffffffff (see below).

If I enable CONFIG_DEBUG_VM, I also get VM_BUG.

> > > Unable to handle kernel paging request at virtual address fffffffffffffffe
> 
> Does your kernel have HOLES_IN_ZONE enabled? (It looks like it depends on
> NUMA)

No.

> Could you reproduce this with CONIG_DEBUG_VM enabled?

I reproduced it in KVM with 64k pages and I enabled CONIG_DEBUG_VM, see 
below. (the bug could be triggerd more quickly in KVM).

> move_freepages() uses pfn_valid_within(), so it should handle missing struct
> pages in this range.
> 
> 
> > > CPU: 3 PID: 14823 Comm: updatedb.mlocat Not tainted 4.17.11 #16
> > > Hardware name: Marvell Armada 8040 MacchiatoBin/Armada 8040 MacchiatoBin,
> > > BIOS EDK II Jul 30 2018
> > > pstate: 00000085 (nzcv daIf -PAN -UAO)
> > > pc : move_freepages_block+0xb4/0x160
> > > lr : steal_suitable_fallback+0xe4/0x188
> 
> Any chance you could addr2line these?

I analyzed the assembler:
PageBuddy in move_freepages returns false
Then we call PageLRU, the macro calls PF_HEAD which is compound_page()
compound_page reads page->compound_head, it is 0xffffffffffffffff, so it 
resturns 0xfffffffffffffffe - and accessing this address causes crash

> > > Call trace:
> > >   move_freepages_block+0xb4/0x160
> > >   get_page_from_freelist+0xad8/0xea8
> > >   __alloc_pages_nodemask+0xac/0x970
> > >   new_slab+0xc0/0x348
> > >   ___slab_alloc.constprop.32+0x2cc/0x350
> > >   __slab_alloc.isra.26.constprop.31+0x24/0x38
> > >   kmem_cache_alloc+0x168/0x198
> > >   spadfs_alloc_inode+0x2c/0x88
> > >   alloc_inode+0x20/0xa0
> > >   iget5_locked+0xf8/0x1c0
> 
> > >   spadfs_iget+0x44/0x4c8
> > >   spadfs_lookup+0x70/0x108
> 
> Hmmm. What's this?

http://artax.karlin.mff.cuni.cz/~mikulas/spadfs/download/

> Thanks,
> 
> James
> 
> 
> [0] https://www.spinics.net/lists/linux-mm/msg157223.html
> [1] https://www.spinics.net/lists/linux-mm/msg156764.html

The same crash in KVM. The guest kernel has 64k pages. I enabled 
CONFIG_DEBUG_VM:

[ 1493.526129] page:fffffdff802e1780 is uninitialized and poisoned
[ 1493.526136] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
[ 1493.528030] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
[ 1493.529320] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
[ 1493.530441] ------------[ cut here ]------------
[ 1493.531301] kernel BUG at include/linux/mm.h:978!
[ 1493.532176] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
[ 1493.533196] Modules linked in: raid0 raid10 dm_delay xfs reiserfs loop dm_crypt dm_zero dm_integrity raid1 dm_raid raid456 async_raid6_recov async_memcpy async_pq raid6_pq async_xor xor async_tx md_mod dm_thin_pool dm_cache_smq dm_cache dm_persistent_data dm_bio_prison libcrc32c dm_mirror dm_region_hash dm_log dm_snapshot dm_bufio dm_mod ipv6 autofs4 binfmt_misc nls_utf8 nls_cp852 vfat fat af_packet aes_ce_blk crypto_simd cryptd aes_ce_cipher crc32_ce crct10dif_ce ghash_ce gf128mul aes_arm64 sha2_ce sha256_arm64 sha1_ce sha1_generic efivars virtio_net virtio_rng net_failover rng_core failover virtio_console ext4 crc32c_generic crc16 mbcache jbd2 virtio_scsi sd_mod scsi_mod virtio_blk virtio_mmio virtio_pci virtio_ring virtio [last unloaded: brd]
[ 1493.545466] CPU: 1 PID: 25236 Comm: dd Not tainted 4.18.0 #7
[ 1493.546540] Hardware name: QEMU KVM Virtual Machine, BIOS 0.0.0 02/06/2015
[ 1493.547833] pstate: 40000085 (nZcv daIf -PAN -UAO)
[ 1493.548749] pc : move_freepages_block+0x144/0x248
[ 1493.549647] lr : move_freepages_block+0x144/0x248
[ 1493.550539] sp : fffffe0071177680
[ 1493.551176] x29: fffffe0071177680 x28: fffffc000861f3f8
[ 1493.552184] x27: 0000000000000048 x26: fffffc0008492000
[ 1493.553197] x25: fffffe007117771c x24: 000000000007ffc0
[ 1493.554203] x23: fffffc000861ef80 x22: fffffdff802fffc0
[ 1493.555209] x21: 0000000000000020 x20: fffffdff80280000
[ 1493.556220] x19: fffffdff802e1780 x18: 0000000000000000
[ 1493.557227] x17: 000003ff88424b08 x16: fffffc0008182c9c
[ 1493.558232] x15: 000000000000000a x14: 0720072007200720
[ 1493.559239] x13: 0720072007200720 x12: 0720072007200720
[ 1493.560249] x11: 0720072907290770 x10: 072807640765076e
[ 1493.561256] x9 : 076f07730769076f x8 : 0000000000000000
[ 1493.562261] x7 : 0750072807450747 x6 : 0000000000000007
[ 1493.563270] x5 : fffffe00bff30750 x4 : 0000000000000001
[ 1493.564276] x3 : 0000000000000007 x2 : 0000000000000007
[ 1493.565283] x1 : fffffe006260cd00 x0 : 0000000000000034
[ 1493.566297] Process dd (pid: 25236, stack limit = 0x0000000094cc07fb)
[ 1493.567506] Call trace:
[ 1493.567985]  move_freepages_block+0x144/0x248
[ 1493.568812]  steal_suitable_fallback+0x100/0x16c
[ 1493.569694]  get_page_from_freelist+0x440/0xb20
[ 1493.570554]  __alloc_pages_nodemask+0xe8/0x838
[ 1493.571401]  new_slab+0xd4/0x418
[ 1493.572022]  ___slab_alloc.constprop.27+0x380/0x4a8
[ 1493.572952]  __slab_alloc.isra.21.constprop.26+0x24/0x34
[ 1493.573955]  kmem_cache_alloc+0xa8/0x180
[ 1493.574704]  alloc_buffer_head+0x1c/0x90
[ 1493.575452]  alloc_page_buffers+0x68/0xb0
[ 1493.576222]  create_empty_buffers+0x20/0x1ec
[ 1493.577033]  create_page_buffers+0xb0/0xf0
[ 1493.577815]  __block_write_begin_int+0xc4/0x564
[ 1493.578676]  __block_write_begin+0x10/0x18
[ 1493.579457]  block_write_begin+0x48/0xd0
[ 1493.580212]  blkdev_write_begin+0x28/0x30
[ 1493.580977]  generic_perform_write+0x98/0x16c
[ 1493.581807]  __generic_file_write_iter+0x138/0x168
[ 1493.582715]  blkdev_write_iter+0x80/0xf0
[ 1493.583470]  __vfs_write+0xe4/0x10c
[ 1493.584138]  vfs_write+0xb4/0x168
[ 1493.584775]  ksys_write+0x44/0x88
[ 1493.585412]  sys_write+0xc/0x14
[ 1493.586018]  el0_svc_naked+0x30/0x34
[ 1493.586708] Code: aa1303e0 90001a01 91296421 94008902 (d4210000)
[ 1493.587857] ---[ end trace 1601ba47f6e883fe ]---
[ 1493.588780] note: dd[25236] exited with preempt_count 1

memory map for the KVM guest:

09000000-09000fff : pl011@9000000
  09000000-09000fff : pl011@9000000
09030000-09030fff : pl061@9030000
10000000-3efeffff : pcie@10000000
  10000000-101fffff : PCI Bus 0000:01
    10000000-1003ffff : 0000:01:00.0
    10040000-10040fff : 0000:01:00.0
  10200000-103fffff : PCI Bus 0000:02
  10400000-105fffff : PCI Bus 0000:03
    10400000-10400fff : 0000:03:00.0
  10600000-107fffff : PCI Bus 0000:04
  10800000-109fffff : PCI Bus 0000:05
    10800000-10800fff : 0000:05:00.0
3f000000-3fffffff : PCI ECAM
40000000-f85dffff : System RAM
  40080000-4057ffff : Kernel code
  405d0000-408effff : Kernel data
f85e0000-f86bffff : reserved
f86c0000-f86dffff : System RAM
f86e0000-f874ffff : reserved
f8750000-fbc1ffff : System RAM
fbc20000-fbffffff : reserved
fc000000-ffffffff : System RAM
8000000000-ffffffffff : pcie@10000000
  8000000000-80001fffff : PCI Bus 0000:01
    8000000000-8000003fff : 0000:01:00.0
      8000000000-8000003fff : virtio-pci-modern
  8000200000-80003fffff : PCI Bus 0000:02
  8000400000-80005fffff : PCI Bus 0000:03
    8000400000-8000403fff : 0000:03:00.0
      8000400000-8000403fff : virtio-pci-modern
  8000600000-80007fffff : PCI Bus 0000:04
    8000600000-8000603fff : 0000:04:00.0
      8000600000-8000603fff : virtio-pci-modern
  8000800000-80009fffff : PCI Bus 0000:05
    8000800000-8000803fff : 0000:05:00.0
      8000800000-8000803fff : virtio-pci-modern

Mikulas
