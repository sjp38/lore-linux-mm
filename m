Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBAD38E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 03:56:00 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u6-v6so12018904pgn.10
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 00:56:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id l7-v6si20126606pgi.261.2018.09.11.00.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 00:55:59 -0700 (PDT)
Date: Tue, 11 Sep 2018 15:54:29 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 3/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <201809111526.rtKfFYhJ%fengguang.wu@intel.com>
References: <20180910234354.4068.65260.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
Content-Disposition: inline
In-Reply-To: <20180910234354.4068.65260.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, mingo@kernel.org, dave.hansen@intel.com, jglisse@redhat.com, akpm@linux-foundation.org, logang@deltatee.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Alexander,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.19-rc3]
[cannot apply to next-20180910]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Alexander-Duyck/Address-issues-slowing-persistent-memory-initialization/20180911-144536
config: openrisc-or1ksim_defconfig (attached as .config)
compiler: or1k-linux-gcc (GCC) 6.0.0 20160327 (experimental)
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=openrisc 

All errors (new ones prefixed by >>):

   mm/page_alloc.c: In function 'memmap_init_zone':
>> mm/page_alloc.c:5566:21: error: 'ZONE_DEVICE' undeclared (first use in this function)
     } else if (zone == ZONE_DEVICE) {
                        ^~~~~~~~~~~
   mm/page_alloc.c:5566:21: note: each undeclared identifier is reported only once for each function it appears in

vim +/ZONE_DEVICE +5566 mm/page_alloc.c

  5551	
  5552		if (highest_memmap_pfn < end_pfn - 1)
  5553			highest_memmap_pfn = end_pfn - 1;
  5554	
  5555		/*
  5556		 * Honor reservation requested by the driver for this ZONE_DEVICE
  5557		 * memory. We limit the total number of pages to initialize to just
  5558		 * those that might contain the memory mapping. We will defer the
  5559		 * ZONE_DEVICE page initialization until after we have released
  5560		 * the hotplug lock.
  5561		 */
  5562		if (altmap && start_pfn == altmap->base_pfn) {
  5563			start_pfn += altmap->reserve;
  5564			end_pfn = altmap->base_pfn +
  5565				  vmem_altmap_offset(altmap);
> 5566		} else if (zone == ZONE_DEVICE) {
  5567			end_pfn = start_pfn;
  5568		}
  5569	
  5570		for (pfn = start_pfn; pfn < end_pfn; pfn++) {
  5571			/*
  5572			 * There can be holes in boot-time mem_map[]s handed to this
  5573			 * function.  They do not exist on hotplugged memory.
  5574			 */
  5575			if (context != MEMMAP_EARLY)
  5576				goto not_early;
  5577	
  5578			if (!early_pfn_valid(pfn))
  5579				continue;
  5580			if (!early_pfn_in_nid(pfn, nid))
  5581				continue;
  5582			if (!update_defer_init(pgdat, pfn, end_pfn, &nr_initialised))
  5583				break;
  5584	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--2fHTh5uZTiUOsy+g
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
eFSjBBAqBEFEtRuS/38O+cBuiHMAAA==

--2fHTh5uZTiUOsy+g--
