Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 76D366B0274
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:50:06 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q18-v6so14866556pll.3
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:50:06 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id h22-v6si17639146pgv.242.2018.07.11.05.50.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Jul 2018 05:50:05 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Boot failures with "mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER" on powerpc (was Re: mmotm 2018-07-10-16-50 uploaded)
In-Reply-To: <20180710235044.vjlRV%akpm@linux-foundation.org>
References: <20180710235044.vjlRV%akpm@linux-foundation.org>
Date: Wed, 11 Jul 2018 22:49:58 +1000
Message-ID: <87lgai9bt5.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, bhe@redhat.com, pasha.tatashin@oracle.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

akpm@linux-foundation.org writes:
> The mm-of-the-moment snapshot 2018-07-10-16-50 has been uploaded to
>
>    http://www.ozlabs.org/~akpm/mmotm/
...

> * mm-sparse-add-a-static-variable-nr_present_sections.patch
> * mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
> * mm-sparsemem-defer-the-ms-section_mem_map-clearing-fix.patch
> * mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
> * mm-sparse-optimize-memmap-allocation-during-sparse_init.patch
> * mm-sparse-optimize-memmap-allocation-during-sparse_init-checkpatch-fixes.patch

> * mm-sparse-remove-config_sparsemem_alloc_mem_map_together.patch

This seems to be breaking my powerpc pseries qemu boots.

The boot log with some extra debug shows eg:

  $ make pseries_le_defconfig
  $ qemu-system-ppc64 -nographic -vga none -M pseries -m 2G -kernel vmlinux 
  ...
  vmemmap_populate f000000000000000..f000000000004000, node 0
        * f000000000000000..f000000001000000 allocated at c00000007e000000
  hash__vmemmap_create_mapping: start 0xf000000000000000 size 0x1000000 phys 0x7e000000
  vmemmap_populate f000000000000000..f000000000008000, node 0
        * f000000000000000..f000000001000000 allocated at c00000007d000000
  hash__vmemmap_create_mapping: start 0xf000000000000000 size 0x1000000 phys 0x7d000000
  vmemmap_populate f000000000000000..f00000000000c000, node 0
        * f000000000000000..f000000001000000 allocated at c00000007c000000
  hash__vmemmap_create_mapping: start 0xf000000000000000 size 0x1000000 phys 0x7c000000
  vmemmap_populate f000000000000000..f000000000010000, node 0
        * f000000000000000..f000000001000000 allocated at c00000007b000000
  hash__vmemmap_create_mapping: start 0xf000000000000000 size 0x1000000 phys 0x7b000000
  vmemmap_populate f000000000000000..f000000000014000, node 0
        * f000000000000000..f000000001000000 allocated at c00000007a000000
  hash__vmemmap_create_mapping: start 0xf000000000000000 size 0x1000000 phys 0x7a000000
  vmemmap_populate f000000000000000..f000000000018000, node 0
        * f000000000000000..f000000001000000 allocated at c000000079000000
  hash__vmemmap_create_mapping: start 0xf000000000000000 size 0x1000000 phys 0x79000000
  vmemmap_populate f000000000000000..f00000000001c000, node 0
        * f000000000000000..f000000001000000 allocated at c000000078000000
  hash__vmemmap_create_mapping: start 0xf000000000000000 size 0x1000000 phys 0x78000000
  vmemmap_populate f000000000000000..f000000000020000, node 0
        * f000000000000000..f000000001000000 allocated at c000000077000000
  hash__vmemmap_create_mapping: start 0xf000000000000000 size 0x1000000 phys 0x77000000
  vmemmap_populate f000000000000000..f000000000024000, node 0
        * f000000000000000..f000000001000000 allocated at c000000076000000
  hash__vmemmap_create_mapping: start 0xf000000000000000 size 0x1000000 phys 0x76000000
  hash__vmemmap_create_mapping: failed -1

  <repeated many times>

Then there's lots of other warnings about bad page states and eventually
a NULL deref and we panic().


The problem seems to be that we're calling down into
hash__vmemmap_create_mapping() for every call to vmemmap_populate(),
whereas previously we would only call hash__vmemmap_create_mapping()
once because our vmemmap_populated() would return true.

There's actually a comment in sparse_init() that says:

	 * powerpc need to call sparse_init_one_section right after each
	 * sparse_early_mem_map_alloc, so allocate usemap_map at first.

So changing that behaviour does seem to be the problem.

I assume that comment is talking about the fact that we use pfn_valid()
in vmemmap_populated().

I'm not clear on how to fix it though.

Any ideas?

cheers
