Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B378D6B0024
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 11:21:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 139so8349545pfw.7
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 08:21:14 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e8si6567300pgf.679.2018.03.24.08.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Mar 2018 08:21:13 -0700 (PDT)
Date: Sat, 24 Mar 2018 23:21:00 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 05/11] x86/mm: do not auto-massage page protections
Message-ID: <201803242334.5GLFH8qU%fengguang.wu@intel.com>
References: <20180323174454.CD00F614@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Content-Disposition: inline
In-Reply-To: <20180323174454.CD00F614@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on tip/auto-latest]
[also build test ERROR on next-20180323]
[cannot apply to tip/x86/core v4.16-rc6]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Dave-Hansen/Use-global-pages-with-PTI/20180324-205009
config: arm-gemini_defconfig (attached as .config)
compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=arm 

All errors (new ones prefixed by >>):

   mm/early_ioremap.c: In function '__early_ioremap':
>> mm/early_ioremap.c:117:22: error: '__default_kernel_pte_mask' undeclared (first use in this function); did you mean '__current_kernel_time'?
     pgprot_val(prot) &= __default_kernel_pte_mask;
                         ^~~~~~~~~~~~~~~~~~~~~~~~~
                         __current_kernel_time
   mm/early_ioremap.c:117:22: note: each undeclared identifier is reported only once for each function it appears in

vim +117 mm/early_ioremap.c

   104	
   105	static void __init __iomem *
   106	__early_ioremap(resource_size_t phys_addr, unsigned long size, pgprot_t prot)
   107	{
   108		unsigned long offset;
   109		resource_size_t last_addr;
   110		unsigned int nrpages;
   111		enum fixed_addresses idx;
   112		int i, slot;
   113	
   114		WARN_ON(system_state >= SYSTEM_RUNNING);
   115	
   116		/* Sanitize 'prot' against any unsupported bits: */
 > 117		pgprot_val(prot) &= __default_kernel_pte_mask;
   118	
   119		slot = -1;
   120		for (i = 0; i < FIX_BTMAPS_SLOTS; i++) {
   121			if (!prev_map[i]) {
   122				slot = i;
   123				break;
   124			}
   125		}
   126	
   127		if (WARN(slot < 0, "%s(%08llx, %08lx) not found slot\n",
   128			 __func__, (u64)phys_addr, size))
   129			return NULL;
   130	
   131		/* Don't allow wraparound or zero size */
   132		last_addr = phys_addr + size - 1;
   133		if (WARN_ON(!size || last_addr < phys_addr))
   134			return NULL;
   135	
   136		prev_size[slot] = size;
   137		/*
   138		 * Mappings have to be page-aligned
   139		 */
   140		offset = offset_in_page(phys_addr);
   141		phys_addr &= PAGE_MASK;
   142		size = PAGE_ALIGN(last_addr + 1) - phys_addr;
   143	
   144		/*
   145		 * Mappings have to fit in the FIX_BTMAP area.
   146		 */
   147		nrpages = size >> PAGE_SHIFT;
   148		if (WARN_ON(nrpages > NR_FIX_BTMAPS))
   149			return NULL;
   150	
   151		/*
   152		 * Ok, go for it..
   153		 */
   154		idx = FIX_BTMAP_BEGIN - NR_FIX_BTMAPS*slot;
   155		while (nrpages > 0) {
   156			if (after_paging_init)
   157				__late_set_fixmap(idx, phys_addr, prot);
   158			else
   159				__early_set_fixmap(idx, phys_addr, prot);
   160			phys_addr += PAGE_SIZE;
   161			--idx;
   162			--nrpages;
   163		}
   164		WARN(early_ioremap_debug, "%s(%08llx, %08lx) [%d] => %08lx + %08lx\n",
   165		     __func__, (u64)phys_addr, size, slot, offset, slot_virt[slot]);
   166	
   167		prev_map[slot] = (void __iomem *)(offset + slot_virt[slot]);
   168		return prev_map[slot];
   169	}
   170	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--CE+1k2dSO48ffgeK
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
Xl1mG6r0Xv817Z/hWb0AAA==

--CE+1k2dSO48ffgeK--
