Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 563D56B027D
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 21:19:53 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 4so1605365plb.1
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 18:19:53 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t193si1918233pgb.156.2018.02.21.18.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 18:19:51 -0800 (PST)
Date: Thu, 22 Feb 2018 10:19:10 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 66/152] mm/page_alloc.c:5449:11: error: implicit
 declaration of function 'memblock_next_valid_pfn'; did you mean
 'memblock_virt_alloc_low'?
Message-ID: <201802221002.wAbbZEtT%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="RnlQjJ0d97Da+TV1"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugeniu Rosca <erosca@de.adit-jv.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   745388a34645dd2b69f5e7115ad47fea7a218726
commit: 358ab62d860b706d6cd8c34afad63d64317b297b [66/152] mm: page_alloc: skip over regions of invalid pfns on UMA
config: sparc-defconfig (attached as .config)
compiler: sparc-linux-gcc (GCC) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 358ab62d860b706d6cd8c34afad63d64317b297b
        # save the attached .config to linux build tree
        make.cross ARCH=sparc 

All errors (new ones prefixed by >>):

   mm/page_alloc.c: In function 'memmap_init_zone':
>> mm/page_alloc.c:5449:11: error: implicit declaration of function 'memblock_next_valid_pfn'; did you mean 'memblock_virt_alloc_low'? [-Werror=implicit-function-declaration]
        pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
              ^~~~~~~~~~~~~~~~~~~~~~~
              memblock_virt_alloc_low
   cc1: some warnings being treated as errors

vim +5449 mm/page_alloc.c

^1da177e4 Linus Torvalds 2005-04-16  5423  
22b31eec6 Hugh Dickins   2009-01-06  5424  	if (highest_memmap_pfn < end_pfn - 1)
22b31eec6 Hugh Dickins   2009-01-06  5425  		highest_memmap_pfn = end_pfn - 1;
22b31eec6 Hugh Dickins   2009-01-06  5426  
4b94ffdc4 Dan Williams   2016-01-15  5427  	/*
4b94ffdc4 Dan Williams   2016-01-15  5428  	 * Honor reservation requested by the driver for this ZONE_DEVICE
4b94ffdc4 Dan Williams   2016-01-15  5429  	 * memory
4b94ffdc4 Dan Williams   2016-01-15  5430  	 */
4b94ffdc4 Dan Williams   2016-01-15  5431  	if (altmap && start_pfn == altmap->base_pfn)
4b94ffdc4 Dan Williams   2016-01-15  5432  		start_pfn += altmap->reserve;
4b94ffdc4 Dan Williams   2016-01-15  5433  
cbe8dd4af Greg Ungerer   2006-01-12  5434  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
a2f3aa025 Dave Hansen    2007-01-10  5435  		/*
b72d0ffb5 Andrew Morton  2016-03-15  5436  		 * There can be holes in boot-time mem_map[]s handed to this
b72d0ffb5 Andrew Morton  2016-03-15  5437  		 * function.  They do not exist on hotplugged memory.
a2f3aa025 Dave Hansen    2007-01-10  5438  		 */
b72d0ffb5 Andrew Morton  2016-03-15  5439  		if (context != MEMMAP_EARLY)
b72d0ffb5 Andrew Morton  2016-03-15  5440  			goto not_early;
b72d0ffb5 Andrew Morton  2016-03-15  5441  
b92df1de5 Paul Burton    2017-02-22  5442  		if (!early_pfn_valid(pfn)) {
b92df1de5 Paul Burton    2017-02-22  5443  			/*
b92df1de5 Paul Burton    2017-02-22  5444  			 * Skip to the pfn preceding the next valid one (or
b92df1de5 Paul Burton    2017-02-22  5445  			 * end_pfn), such that we hit a valid pfn (or end_pfn)
b92df1de5 Paul Burton    2017-02-22  5446  			 * on our next iteration of the loop.
b92df1de5 Paul Burton    2017-02-22  5447  			 */
358ab62d8 Eugeniu Rosca  2018-02-21  5448  			if (IS_ENABLED(CONFIG_HAVE_MEMBLOCK))
b92df1de5 Paul Burton    2017-02-22 @5449  				pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
d41dee369 Andy Whitcroft 2005-06-23  5450  			continue;
b92df1de5 Paul Burton    2017-02-22  5451  		}
751679573 Andy Whitcroft 2006-10-21  5452  		if (!early_pfn_in_nid(pfn, nid))
751679573 Andy Whitcroft 2006-10-21  5453  			continue;
b72d0ffb5 Andrew Morton  2016-03-15  5454  		if (!update_defer_init(pgdat, pfn, end_pfn, &nr_initialised))
3a80a7fa7 Mel Gorman     2015-06-30  5455  			break;
342332e6a Taku Izumi     2016-03-15  5456  

:::::: The code at line 5449 was first introduced by commit
:::::: b92df1de5d289c0b5d653e72414bf0850b8511e0 mm: page_alloc: skip over regions of invalid pfns where possible

:::::: TO: Paul Burton <paul.burton@imgtec.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--RnlQjJ0d97Da+TV1
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
lgNM67XZ6OTIRo7+FeqAfgMBRVxmHMEAAA==

--RnlQjJ0d97Da+TV1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
