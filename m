Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DAE466B0005
	for <linux-mm@kvack.org>; Wed, 23 May 2018 06:26:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 44-v6so17176574wrt.9
        for <linux-mm@kvack.org>; Wed, 23 May 2018 03:26:44 -0700 (PDT)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id q1-v6si8618967wrp.395.2018.05.23.03.26.43
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 03:26:43 -0700 (PDT)
Date: Wed, 23 May 2018 12:26:43 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC] Checking for error code in __offline_pages
Message-ID: <20180523102642.GA27700@techadventures.net>
References: <20180523073547.GA29266@techadventures.net>
 <20180523075239.GF20441@dhcp22.suse.cz>
 <20180523081609.GG20441@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523081609.GG20441@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, vbabka@suse.cz, pasha.tatashin@oracle.com, akpm@linux-foundation.org

On Wed, May 23, 2018 at 10:16:09AM +0200, Michal Hocko wrote:
> On Wed 23-05-18 09:52:39, Michal Hocko wrote:
> [...]
> > Yeah, the current code is far from optimal. We
> > used to have a retry count but that one was removed exactly because of
> > premature failures. There are three things here
> > 1) zone_movable should contain any bootmem or otherwise non-migrateable
> >    pages
> > 2) start_isolate_page_range should fail when seeing such pages - maybe
> >    has_unmovable_pages is overly optimistic and it should check all
> >    pages even in movable zones.
> > 3) migrate_pages should really tell us whether the failure is temporal
> >    or permanent. I am not sure we can do that easily though.
> 
> 2) should be the most simple one for now. Could you give it a try? Btw.
> the exact configuration that led to boothmem pages in zone_movable would
> be really appreciated:
 
Here is some information:

** Qemu cmdline:

# qemu-system-x86_64 -enable-kvm -smp 2  -monitor pty -m 6G,slots=8,maxmem=8G -numa node,mem=4096M -numa node,mem=2048M ...
# Option movablecore=4G (cmdline)

** e820 map and some numa information:

linux kernel: BIOS-provided physical RAM map:
linux kernel: BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
linux kernel: BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
linux kernel: BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
linux kernel: BIOS-e820: [mem 0x0000000000100000-0x00000000bffdffff] usable
linux kernel: BIOS-e820: [mem 0x00000000bffe0000-0x00000000bfffffff] reserved
linux kernel: BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
linux kernel: BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
linux kernel: BIOS-e820: [mem 0x0000000100000000-0x00000001bfffffff] usable
linux kernel: NX (Execute Disable) protection: active
linux kernel: SMBIOS 2.8 present.
linux kernel: DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 
linux kernel: Hypervisor detected: KVM
linux kernel: e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
linux kernel: e820: remove [mem 0x000a0000-0x000fffff] usable
linux kernel: last_pfn = 0x1c0000 max_arch_pfn = 0x400000000


linux kernel: SRAT: PXM 0 -> APIC 0x00 -> Node 0
linux kernel: SRAT: PXM 1 -> APIC 0x01 -> Node 1
linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x0009ffff]
linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x00100000-0xbfffffff]
linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x100000000-0x13fffffff]
linux kernel: ACPI: SRAT: Node 1 PXM 1 [mem 0x140000000-0x1bfffffff]
linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x1c0000000-0x43fffffff] hotplug
linux kernel: NUMA: Node 0 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0xbfffffff] -> [mem 0x0
linux kernel: NUMA: Node 0 [mem 0x00000000-0xbfffffff] + [mem 0x100000000-0x13fffffff] -> [mem 0
linux kernel: NODE_DATA(0) allocated [mem 0x13ffd6000-0x13fffffff]
linux kernel: NODE_DATA(1) allocated [mem 0x1bffd3000-0x1bfffcfff]


** /proc/zoneinfo

Node 0, zone      DMA
  per-node stats
      nr_inactive_anon 2107
      nr_active_anon 49560
      nr_inactive_file 25375
      nr_active_file 19038
      nr_unevictable 12
      nr_slab_reclaimable 5996
      nr_slab_unreclaimable 7236
      nr_isolated_anon 0
      nr_isolated_file 0
      workingset_refault 0
      workingset_activate 0
      workingset_nodereclaim 0
      nr_anon_pages 48910
      nr_mapped    13780
      nr_file_pages 46676
      nr_dirty     13
      nr_writeback 0
      nr_writeback_temp 0
      nr_shmem     2263
      nr_shmem_hugepages 0
      nr_shmem_pmdmapped 0
      nr_anon_transparent_hugepages 50
      nr_unstable  0
      nr_vmscan_write 0
      nr_vmscan_immediate_reclaim 0
      nr_dirtied   17749
      nr_written   17462
                   83328
  pages free     3961
        min      29
        low      36
        high     43
        spanned  4095
        present  3998
        managed  3977
        protection: (0, 2939, 2939, 3898, 3898)
      nr_free_pages 3961
      nr_zone_inactive_anon 0
      nr_zone_active_anon 0
      nr_zone_inactive_file 0
      nr_zone_active_file 0
      nr_zone_unevictable 0
      nr_zone_write_pending 0
      nr_mlock     0
      nr_page_table_pages 0
      nr_kernel_stack 0
      nr_bounce    0
      nr_zspages   0
      nr_free_cma  0
      numa_hit     2
      numa_miss    0
      numa_foreign 0
      numa_interleave 0
      numa_local   1
      numa_other   1
  pagesets
    cpu: 0
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
    cpu: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
  node_unreclaimable:  0
  start_pfn:           1
Node 0, zone    DMA32
  pages free     724414
        min      5583
        low      6978
        high     8373
        spanned  1044480
        present  782304
        managed  758516
        protection: (0, 0, 0, 959, 959)
      nr_free_pages 724414
      nr_zone_inactive_anon 0
      nr_zone_active_anon 0
      nr_zone_inactive_file 1697
      nr_zone_active_file 8915
      nr_zone_unevictable 0
      nr_zone_write_pending 12
      nr_mlock     0
      nr_page_table_pages 2976
      nr_kernel_stack 4000
      nr_bounce    0
      nr_zspages   0
      nr_free_cma  0
      numa_hit     281025
      numa_miss    0
      numa_foreign 0
      numa_interleave 8583
      numa_local   135392
      numa_other   145633
  pagesets
    cpu: 0
              count: 164
              high:  186
              batch: 31
  vm stats threshold: 24
    cpu: 1
              count: 32
              high:  186
              batch: 31
  vm stats threshold: 24
  node_unreclaimable:  0
  start_pfn:           4096
Node 0, zone   Normal
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 7677, 7677)
Node 0, zone  Movable
  pages free     160140
        min      1823
        low      2278
        high     2733
        spanned  262144
        present  262144
        managed  245670
        protection: (0, 0, 0, 0, 0)
      nr_free_pages 160140
      nr_zone_inactive_anon 2107
      nr_zone_active_anon 49560
      nr_zone_inactive_file 23678
      nr_zone_active_file 10123
      nr_zone_unevictable 12
      nr_zone_write_pending 1
      nr_mlock     12
      nr_page_table_pages 0
      nr_kernel_stack 0
      nr_bounce    0
      nr_zspages   0
      nr_free_cma  0
      numa_hit     214370
      numa_miss    0
      numa_foreign 0
      numa_interleave 0
      numa_local   214344
      numa_other   26
  pagesets
    cpu: 0
              count: 32
              high:  42
              batch: 7
  vm stats threshold: 16
    cpu: 1
              count: 26
              high:  42
              batch: 7
  vm stats threshold: 16
  node_unreclaimable:  0
  start_pfn:           1048576
Node 0, zone   Device
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 0, 0)
Node 1, zone      DMA
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 2014, 2014)
Node 1, zone    DMA32
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 2014, 2014)
Node 1, zone   Normal
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 16117, 16117)
Node 1, zone  Movable
  per-node stats
      nr_inactive_anon 524
      nr_active_anon 25734
      nr_inactive_file 28733
      nr_active_file 12316
      nr_unevictable 8
      nr_slab_reclaimable 0
      nr_slab_unreclaimable 0
      nr_isolated_anon 0
      nr_isolated_file 0
      workingset_refault 0
      workingset_activate 0
      workingset_nodereclaim 0
      nr_anon_pages 24656
      nr_mapped    16871
      nr_file_pages 41647
      nr_dirty     1
      nr_writeback 0
      nr_writeback_temp 0
      nr_shmem     598
      nr_shmem_hugepages 0
      nr_shmem_pmdmapped 0
      nr_anon_transparent_hugepages 8
      nr_unstable  0
      nr_vmscan_write 0
      nr_vmscan_immediate_reclaim 0
      nr_dirtied   125
      nr_written   98
                   0
  pages free     448427
        min      3827
        low      4783
        high     5739
        spanned  524288
        present  524288
        managed  515766
        protection: (0, 0, 0, 0, 0)
      nr_free_pages 448427
      nr_zone_inactive_anon 524
      nr_zone_active_anon 25734
      nr_zone_inactive_file 28733
      nr_zone_active_file 12316
      nr_zone_unevictable 8
      nr_zone_write_pending 1
      nr_mlock     8
      nr_page_table_pages 0
      nr_kernel_stack 0
      nr_bounce    0
      nr_zspages   0
      nr_free_cma  0
      numa_hit     199599
      numa_miss    0
      numa_foreign 0
      numa_interleave 0
      numa_local   199599
      numa_other   0
  pagesets
    cpu: 0
              count: 9
              high:  42
              batch: 7
  vm stats threshold: 20
    cpu: 1
              count: 2
              high:  42
              batch: 7
  vm stats threshold: 20
  node_unreclaimable:  0
  start_pfn:           1310720
Node 1, zone   Device
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 0, 0)


I hope this is enough.

Thanks
Oscar Salvador
