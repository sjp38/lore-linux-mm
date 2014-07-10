Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9548C6B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 00:36:46 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id hy10so9554290vcb.3
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 21:36:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id qe9si22481708vcb.79.2014.07.09.21.36.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jul 2014 21:36:45 -0700 (PDT)
Date: Thu, 10 Jul 2014 12:36:33 +0800
From: WANG Chao <chaowang@redhat.com>
Subject: Re: [mmotm:master 162/459] arch/tile/kernel/module.c:61:2: warning:
 passing argument 3 of 'map_vm_area' from incompatible pointer type
Message-ID: <20140710043633.GG28832@dhcp-17-89.nay.redhat.com>
References: <53bdfd79.GpSuQIBmMpW63HEg%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53bdfd79.GpSuQIBmMpW63HEg%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Metcalf <cmetcalf@tilera.com>, kbuild-all@01.org

[Adding tile maintainer Chris in CC]

On 07/10/14 at 10:42am, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   aee1e06c30707e3a0d8098b9ad9346d9b6f7b310
> commit: ab6110cb6a940952f7941d0b0aab4fa9bfd6131c [162/459] mm/vmalloc.c: clean up map_vm_area third argument
> config: make ARCH=tile tilegx_defconfig
> 
> All warnings:
> 
>    arch/tile/kernel/module.c: In function 'module_alloc':
> >> arch/tile/kernel/module.c:61:2: warning: passing argument 3 of 'map_vm_area' from incompatible pointer type [enabled by default]
>    include/linux/vmalloc.h:115:12: note: expected 'struct page **' but argument is of type 'struct page ***'
> 
> vim +/map_vm_area +61 arch/tile/kernel/module.c
> 
> 867e359b Chris Metcalf 2010-05-28  45  	npages = (size + PAGE_SIZE - 1) / PAGE_SIZE;
> 867e359b Chris Metcalf 2010-05-28  46  	pages = kmalloc(npages * sizeof(struct page *), GFP_KERNEL);
> 867e359b Chris Metcalf 2010-05-28  47  	if (pages == NULL)
> 867e359b Chris Metcalf 2010-05-28  48  		return NULL;
> 867e359b Chris Metcalf 2010-05-28  49  	for (; i < npages; ++i) {
> 867e359b Chris Metcalf 2010-05-28  50  		pages[i] = alloc_page(GFP_KERNEL | __GFP_HIGHMEM);
> 867e359b Chris Metcalf 2010-05-28  51  		if (!pages[i])
> 867e359b Chris Metcalf 2010-05-28  52  			goto error;
> 867e359b Chris Metcalf 2010-05-28  53  	}
> 867e359b Chris Metcalf 2010-05-28  54  
> 867e359b Chris Metcalf 2010-05-28  55  	area = __get_vm_area(size, VM_ALLOC, MEM_MODULE_START, MEM_MODULE_END);
> 867e359b Chris Metcalf 2010-05-28  56  	if (!area)
> 867e359b Chris Metcalf 2010-05-28  57  		goto error;
> 5f220704 Chris Metcalf 2012-03-29  58  	area->nr_pages = npages;
> 5f220704 Chris Metcalf 2012-03-29  59  	area->pages = pages;
> 867e359b Chris Metcalf 2010-05-28  60  
> 867e359b Chris Metcalf 2010-05-28 @61  	if (map_vm_area(area, prot_rwx, &pages)) {
> 867e359b Chris Metcalf 2010-05-28  62  		vunmap(area->addr);
> 867e359b Chris Metcalf 2010-05-28  63  		goto error;
> 867e359b Chris Metcalf 2010-05-28  64  	}
> 867e359b Chris Metcalf 2010-05-28  65  
> 867e359b Chris Metcalf 2010-05-28  66  	return area->addr;
> 867e359b Chris Metcalf 2010-05-28  67  
> 867e359b Chris Metcalf 2010-05-28  68  error:
> 867e359b Chris Metcalf 2010-05-28  69  	while (--i >= 0)

Hi, Andrew

I just send an update patch to address this. Please find below in your
inbox:

[PATCH v2] mm/vmalloc.c: clean up map_vm_area third argument

Hi Chris,

it seems like arch/tile/kernel/module.c::module_alloc() uses
map_vm_area wrong. You didn't take the pointer (struct page **pages)
increments into account. I fixed this along with the patch I
mentioned above (CCed you). Please let me know if I was wrong.

Thanks
WANG Chao

> 
> :::::: The code at line 61 was first introduced by commit
> :::::: 867e359b97c970a60626d5d76bbe2a8fadbf38fb arch/tile: core support for Tilera 32-bit chips.
> 
> :::::: TO: Chris Metcalf <cmetcalf@tilera.com>
> :::::: CC: Chris Metcalf <cmetcalf@tilera.com>
> 
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
