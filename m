Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC796B2543
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 12:12:37 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id o27-v6so1435361pfj.6
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 09:12:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b8-v6si1941357ple.171.2018.08.22.09.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 09:12:35 -0700 (PDT)
Date: Wed, 22 Aug 2018 09:12:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 187/242] mm/memblock.c:1290:6: error:
 'early_region_idx' undeclared; did you mean 'early_pfn_to_nid'?
Message-Id: <20180822091233.333b52bd38efcf3f7d86be37@linux-foundation.org>
In-Reply-To: <201808221909.yuIwBvuo%fengguang.wu@intel.com>
References: <201808221909.yuIwBvuo%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Jia He <jia.he@hxt-semitech.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, 22 Aug 2018 19:37:44 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   10b78d76f1897885d7753586ecd113e9d6728c5d
> commit: be2e6e87ac5e7f8f30c442bb1a042266e1ab6fcd [187/242] mm/memblock: introduce pfn_valid_region()
> config: arm-omap2plus_defconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout be2e6e87ac5e7f8f30c442bb1a042266e1ab6fcd
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.2.0 make.cross ARCH=arm 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    mm/memblock.c: In function 'pfn_valid_region':
> >> mm/memblock.c:1290:6: error: 'early_region_idx' undeclared (first use in this function); did you mean 'early_pfn_to_nid'?
>      if (early_region_idx != -1) {
>          ^~~~~~~~~~~~~~~~
>          early_pfn_to_nid
>    mm/memblock.c:1290:6: note: each undeclared identifier is reported only once for each function it appears in
> >> mm/memblock.c:1305:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }

oops

--- a/mm/memblock.c~mm-page_alloc-reduce-unnecessary-binary-search-in-memblock_next_valid_pfn-fix-fix
+++ a/mm/memblock.c
@@ -1232,6 +1232,7 @@ int __init_memblock memblock_set_node(ph
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 #ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
+static int early_region_idx __initdata_memblock = -1;
 unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
 {
 	struct memblock_type *type = &memblock.memory;
@@ -1240,7 +1241,6 @@ unsigned long __init_memblock memblock_n
 	uint mid, left = 0;
 	unsigned long start_pfn, end_pfn, next_start_pfn;
 	phys_addr_t addr = PFN_PHYS(++pfn);
-	static int early_region_idx __initdata_memblock = -1;
 
 	/* fast path, return pfn+1 if next pfn is in the same region */
 	if (early_region_idx != -1) {
_
