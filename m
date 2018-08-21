Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D33E56B1E43
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 06:44:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id q29-v6so1835436edd.0
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 03:44:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m4-v6si9475864edb.333.2018.08.21.03.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 03:44:20 -0700 (PDT)
Date: Tue, 21 Aug 2018 12:44:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
Message-ID: <20180821104418.GA16611@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>

[Cc Pavel in case he has some ideas]

On Fri 17-08-18 15:44:27, Mikulas Patocka wrote:
> Hi
> 
> I report this crash on ARM64 on the kernel 4.17.11. The reason is that the 
> function move_freepages_block accesses contiguous runs of 
> pageblock_nr_pages. The ARM64 firmware sets holes of reserved memory there 
> and when move_freepages_block stumbles over this hole, it accesses 
> uninitialized page structures and crashes.
> 
> 00000000-03ffffff : System RAM
>   00080000-007bffff : Kernel code
>   00820000-00aa3fff : Kernel data
> 04200000-bf80ffff : System RAM
> bf810000-bfbeffff : reserved
> bfbf0000-bfc8ffff : System RAM
> bfc90000-bffdffff : reserved
> bffe0000-bfffffff : System RAM
> c0000000-dfffffff : MEM
>   c0000000-c00fffff : PCI Bus 0000:01
>     c0000000-c0003fff : 0000:01:00.0
>       c0000000-c0003fff : nvme
> 
> The bug was already reported here for x86:
> https://bugzilla.redhat.com/show_bug.cgi?id=1598462
> 
> For x86, it was fixed in the kernel 4.17.7 - but I observed it in the 
> kernel 4.17.11 on ARM64. I also observed it on 4.18-rc kernels running in 
> KVM virtual machine on ARM when I compiled the guest kernel with 64kB page 
> size.
> 
> 
> Unable to handle kernel paging request at virtual address fffffffffffffffe
> Mem abort info:
>   ESR = 0x96000005
>   Exception class = DABT (current EL), IL = 32 bits
>   SET = 0, FnV = 0
>   EA = 0, S1PTW = 0
> Data abort info:
>   ISV = 0, ISS = 0x00000005
>   CM = 0, WnR = 0
> swapper pgtable: 4k pages, 39-bit VAs, pgdp = 00000000791c2068
> [fffffffffffffffe] pgd=0000000000000000, pud=0000000000000000
> Internal error: Oops: 96000005 [#1] PREEMPT SMP
> Modules linked in: ftdi_sio usbserial fuse vhost_net vhost tun bridge stp llc autofs4 udlfb syscopyarea sysfillrect sysimgblt fb_sys_fops fb font binfmt_misc ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_nat iptable_nat nf_nat_ipv4 iptable_mangle xt_TCPMSS nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT nf_reject_ipv4 xt_tcpudp xt_conntrack xt_multiport iptable_filter ip_tables x_tables pppoe pppox af_packet ppp_generic slhc nls_utf8 nls_cp852 vfat fat hid_generic usbhid hid snd_usb_audio snd_hwdep snd_usbmidi_lib snd_rawmidi snd_pcm snd_timer snd soundcore nf_nat_ftp nf_conntrack_ftp nf_nat nf_conntrack sd_mod ipv6 aes_ce_blk crypto_simd cryptd aes_ce_cipher crc32_ce ghash_ce gf128mul aes_arm64 sha2_ce sha256_arm64
>  sha1_ce sha1_generic efivars xhci_plat_hcd xhci_hcd ahci_platform libahci_platform libahci libata usbcore usb_common mvpp2 unix
> CPU: 3 PID: 14823 Comm: updatedb.mlocat Not tainted 4.17.11 #16
> Hardware name: Marvell Armada 8040 MacchiatoBin/Armada 8040 MacchiatoBin, BIOS EDK II Jul 30 2018
> pstate: 00000085 (nzcv daIf -PAN -UAO)
> pc : move_freepages_block+0xb4/0x160
> lr : steal_suitable_fallback+0xe4/0x188
> sp : ffffffc0add9f570
> x29: ffffffc0add9f570 x28: 0000000000000000 
> x27: ffffffffffffff60 x26: ffffff800886ef58 
> x25: 0000000000000008 x24: 0000000000000003 
> x23: 0000000000000020 x22: 0000000000000000 
> x21: 0000000000000003 x20: ffffff800886ed80 
> x19: 0000000000000002 x18: ffffffbf02fefe00 
> x17: 0000007fa0916380 x16: ffffff80081dc528 
> x15: 0000000000000001 x14: 0000000000000020 
> x13: 0000000000000068 x12: 0000000000000080 
> x11: ffffffbf02fe8020 x10: ffffff800886ef38 
> x9 : 0000000000000000 x8 : 0000000000000000 
> x7 : 0000000000100000 x6 : ffffffffffffffff 
> x5 : fffffffffffffffe x4 : ffffffbf02feffc0 
> x3 : ffffffc0add9f5ac x2 : 00000000000000a0 
> x1 : ffffffbf02fe8000 x0 : ffffff800886ed80 
> Process updatedb.mlocat (pid: 14823, stack limit = 0x000000005d2941e3)
> Call trace:
>  move_freepages_block+0xb4/0x160
>  get_page_from_freelist+0xad8/0xea8
>  __alloc_pages_nodemask+0xac/0x970
>  new_slab+0xc0/0x348
>  ___slab_alloc.constprop.32+0x2cc/0x350
>  __slab_alloc.isra.26.constprop.31+0x24/0x38
>  kmem_cache_alloc+0x168/0x198
>  spadfs_alloc_inode+0x2c/0x88
>  alloc_inode+0x20/0xa0
>  iget5_locked+0xf8/0x1c0
>  spadfs_iget+0x44/0x4c8
>  spadfs_lookup+0x70/0x108
>  __lookup_slow+0x78/0x140
>  lookup_slow+0x3c/0x60
>  walk_component+0x1e4/0x2e0
>  path_lookupat.isra.11+0x64/0x1e8
>  filename_lookup.part.20+0x6c/0xe8
>  user_path_at_empty+0x4c/0x60
>  vfs_statx+0x78/0xd8
>  sys_newfstatat+0x24/0x48
>  el0_svc_naked+0x30/0x34
> Code: f9401026 d10004c5 f24000df 9a8110a5 (f94000a5) 
> ---[ end trace def2ceafdfecd702 ]---
> note: updatedb.mlocat[14823] exited with preempt_count 1

-- 
Michal Hocko
SUSE Labs
