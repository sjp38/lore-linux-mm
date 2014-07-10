Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFD882965
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 22:42:43 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so9853804pdb.25
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 19:42:43 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id in9si47438240pbd.29.2014.07.09.19.42.41
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 19:42:42 -0700 (PDT)
Date: Thu, 10 Jul 2014 10:42:01 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 162/459] arch/tile/kernel/module.c:61:2: warning:
 passing argument 3 of 'map_vm_area' from incompatible pointer type
Message-ID: <53bdfd79.GpSuQIBmMpW63HEg%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: WANG Chao <chaowang@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   aee1e06c30707e3a0d8098b9ad9346d9b6f7b310
commit: ab6110cb6a940952f7941d0b0aab4fa9bfd6131c [162/459] mm/vmalloc.c: clean up map_vm_area third argument
config: make ARCH=tile tilegx_defconfig

All warnings:

   arch/tile/kernel/module.c: In function 'module_alloc':
>> arch/tile/kernel/module.c:61:2: warning: passing argument 3 of 'map_vm_area' from incompatible pointer type [enabled by default]
   include/linux/vmalloc.h:115:12: note: expected 'struct page **' but argument is of type 'struct page ***'

vim +/map_vm_area +61 arch/tile/kernel/module.c

867e359b Chris Metcalf 2010-05-28  45  	npages = (size + PAGE_SIZE - 1) / PAGE_SIZE;
867e359b Chris Metcalf 2010-05-28  46  	pages = kmalloc(npages * sizeof(struct page *), GFP_KERNEL);
867e359b Chris Metcalf 2010-05-28  47  	if (pages == NULL)
867e359b Chris Metcalf 2010-05-28  48  		return NULL;
867e359b Chris Metcalf 2010-05-28  49  	for (; i < npages; ++i) {
867e359b Chris Metcalf 2010-05-28  50  		pages[i] = alloc_page(GFP_KERNEL | __GFP_HIGHMEM);
867e359b Chris Metcalf 2010-05-28  51  		if (!pages[i])
867e359b Chris Metcalf 2010-05-28  52  			goto error;
867e359b Chris Metcalf 2010-05-28  53  	}
867e359b Chris Metcalf 2010-05-28  54  
867e359b Chris Metcalf 2010-05-28  55  	area = __get_vm_area(size, VM_ALLOC, MEM_MODULE_START, MEM_MODULE_END);
867e359b Chris Metcalf 2010-05-28  56  	if (!area)
867e359b Chris Metcalf 2010-05-28  57  		goto error;
5f220704 Chris Metcalf 2012-03-29  58  	area->nr_pages = npages;
5f220704 Chris Metcalf 2012-03-29  59  	area->pages = pages;
867e359b Chris Metcalf 2010-05-28  60  
867e359b Chris Metcalf 2010-05-28 @61  	if (map_vm_area(area, prot_rwx, &pages)) {
867e359b Chris Metcalf 2010-05-28  62  		vunmap(area->addr);
867e359b Chris Metcalf 2010-05-28  63  		goto error;
867e359b Chris Metcalf 2010-05-28  64  	}
867e359b Chris Metcalf 2010-05-28  65  
867e359b Chris Metcalf 2010-05-28  66  	return area->addr;
867e359b Chris Metcalf 2010-05-28  67  
867e359b Chris Metcalf 2010-05-28  68  error:
867e359b Chris Metcalf 2010-05-28  69  	while (--i >= 0)

:::::: The code at line 61 was first introduced by commit
:::::: 867e359b97c970a60626d5d76bbe2a8fadbf38fb arch/tile: core support for Tilera 32-bit chips.

:::::: TO: Chris Metcalf <cmetcalf@tilera.com>
:::::: CC: Chris Metcalf <cmetcalf@tilera.com>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
