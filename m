Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2DB46B026C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 09:12:30 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j9-v6so26630578qtn.22
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:12:30 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j4-v6si333532qte.29.2018.07.11.06.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 06:12:29 -0700 (PDT)
Date: Wed, 11 Jul 2018 21:12:25 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Boot failures with "mm/sparse: Remove
 CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER" on powerpc (was Re: mmotm
 2018-07-10-16-50 uploaded)
Message-ID: <20180711131225.GI1969@MiWiFi-R3L-srv>
References: <20180710235044.vjlRV%akpm@linux-foundation.org>
 <87lgai9bt5.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lgai9bt5.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, pasha.tatashin@oracle.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

Hi Michael,

On 07/11/18 at 10:49pm, Michael Ellerman wrote:
> akpm@linux-foundation.org writes:
> > The mm-of-the-moment snapshot 2018-07-10-16-50 has been uploaded to
> >
> >    http://www.ozlabs.org/~akpm/mmotm/
> ...
> 
> > * mm-sparse-add-a-static-variable-nr_present_sections.patch
> > * mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
> > * mm-sparsemem-defer-the-ms-section_mem_map-clearing-fix.patch
> > * mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
> > * mm-sparse-optimize-memmap-allocation-during-sparse_init.patch
> > * mm-sparse-optimize-memmap-allocation-during-sparse_init-checkpatch-fixes.patch
> 
> > * mm-sparse-remove-config_sparsemem_alloc_mem_map_together.patch
> 
> This seems to be breaking my powerpc pseries qemu boots.
> 
> The boot log with some extra debug shows eg:
> 
>   $ make pseries_le_defconfig
>   $ qemu-system-ppc64 -nographic -vga none -M pseries -m 2G -kernel vmlinux 
>   vmemmap_populate f000000000000000..f000000000024000, node 0
>         * f000000000000000..f000000001000000 allocated at c000000076000000
>   hash__vmemmap_create_mapping: start 0xf000000000000000 size 0x1000000 phys 0x76000000
>   hash__vmemmap_create_mapping: failed -1
> 
>   <repeated many times>
> 
> Then there's lots of other warnings about bad page states and eventually
> a NULL deref and we panic().
> 
> 
> The problem seems to be that we're calling down into
> hash__vmemmap_create_mapping() for every call to vmemmap_populate(),
> whereas previously we would only call hash__vmemmap_create_mapping()
> once because our vmemmap_populated() would return true.
> 
> There's actually a comment in sparse_init() that says:
> 
> 	 * powerpc need to call sparse_init_one_section right after each
> 	 * sparse_early_mem_map_alloc, so allocate usemap_map at first.
> 
> So changing that behaviour does seem to be the problem.
> 
> I assume that comment is talking about the fact that we use pfn_valid()
> in vmemmap_populated().
> 
> I'm not clear on how to fix it though.

Have you tried reverting that patch and building kernel to test again?
Does it work?
