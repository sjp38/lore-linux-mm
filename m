Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF9166B0009
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 06:49:08 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o1so8038080pga.7
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 03:49:08 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id v4-v6si12269974plo.55.2018.03.25.03.49.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Mar 2018 03:49:07 -0700 (PDT)
Date: Sun, 25 Mar 2018 18:48:22 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 5/5] mm: page_alloc: reduce unnecessary binary search
 in early_pfn_valid()
Message-ID: <201803251858.caumopw1%fengguang.wu@intel.com>
References: <1521894282-6454-6-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Content-Disposition: inline
In-Reply-To: <1521894282-6454-6-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jia,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on mmotm/master]
[also build test ERROR on next-20180323]
[cannot apply to v4.16-rc6]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Jia-He/optimize-memblock_next_valid_pfn-and-early_pfn_valid/20180325-175026
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: i386-randconfig-x013-201812 (attached as .config)
compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   mm/page_alloc.c: In function 'memmap_init_zone':
>> mm/page_alloc.c:5499:4: error: continue statement not within a loop
       continue;
       ^~~~~~~~
>> mm/page_alloc.c:5501:4: error: break statement not within loop or switch
       break;
       ^~~~~
   mm/page_alloc.c:5520:5: error: continue statement not within a loop
        continue;
        ^~~~~~~~
   mm/page_alloc.c:5462:6: warning: unused variable 'idx' [-Wunused-variable]
     int idx = -1;
         ^~~
   mm/page_alloc.c: At top level:
>> mm/page_alloc.c:5551:1: error: expected identifier or '(' before '}' token
    }
    ^

vim +5499 mm/page_alloc.c

^1da177e4 Linus Torvalds 2005-04-16  5468  
22b31eec6 Hugh Dickins   2009-01-06  5469  	if (highest_memmap_pfn < end_pfn - 1)
22b31eec6 Hugh Dickins   2009-01-06  5470  		highest_memmap_pfn = end_pfn - 1;
22b31eec6 Hugh Dickins   2009-01-06  5471  
4b94ffdc4 Dan Williams   2016-01-15  5472  	/*
4b94ffdc4 Dan Williams   2016-01-15  5473  	 * Honor reservation requested by the driver for this ZONE_DEVICE
4b94ffdc4 Dan Williams   2016-01-15  5474  	 * memory
4b94ffdc4 Dan Williams   2016-01-15  5475  	 */
4b94ffdc4 Dan Williams   2016-01-15  5476  	if (altmap && start_pfn == altmap->base_pfn)
4b94ffdc4 Dan Williams   2016-01-15  5477  		start_pfn += altmap->reserve;
4b94ffdc4 Dan Williams   2016-01-15  5478  
cbe8dd4af Greg Ungerer   2006-01-12  5479  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
a2f3aa025 Dave Hansen    2007-01-10  5480  		/*
b72d0ffb5 Andrew Morton  2016-03-15  5481  		 * There can be holes in boot-time mem_map[]s handed to this
b72d0ffb5 Andrew Morton  2016-03-15  5482  		 * function.  They do not exist on hotplugged memory.
a2f3aa025 Dave Hansen    2007-01-10  5483  		 */
b72d0ffb5 Andrew Morton  2016-03-15  5484  		if (context != MEMMAP_EARLY)
b72d0ffb5 Andrew Morton  2016-03-15  5485  			goto not_early;
b72d0ffb5 Andrew Morton  2016-03-15  5486  
c0b211780 Jia He         2018-03-24  5487  #if (defined CONFIG_HAVE_MEMBLOCK) && (defined CONFIG_HAVE_ARCH_PFN_VALID)
94200be7f Jia He         2018-03-24  5488  		if (!early_pfn_valid(pfn, &idx)) {
c0b211780 Jia He         2018-03-24  5489  			/*
c0b211780 Jia He         2018-03-24  5490  			 * Skip to the pfn preceding the next valid one (or
c0b211780 Jia He         2018-03-24  5491  			 * end_pfn), such that we hit a valid pfn (or end_pfn)
c0b211780 Jia He         2018-03-24  5492  			 * on our next iteration of the loop.
c0b211780 Jia He         2018-03-24  5493  			 */
5ce6c7e68 Jia He         2018-03-24  5494  			pfn = memblock_next_valid_pfn(pfn, &idx) - 1;
c0b211780 Jia He         2018-03-24  5495  #endif
d41dee369 Andy Whitcroft 2005-06-23  5496  			continue;
c0b211780 Jia He         2018-03-24  5497  		}
751679573 Andy Whitcroft 2006-10-21  5498  		if (!early_pfn_in_nid(pfn, nid))
751679573 Andy Whitcroft 2006-10-21 @5499  			continue;
b72d0ffb5 Andrew Morton  2016-03-15  5500  		if (!update_defer_init(pgdat, pfn, end_pfn, &nr_initialised))
3a80a7fa7 Mel Gorman     2015-06-30 @5501  			break;
342332e6a Taku Izumi     2016-03-15  5502  
342332e6a Taku Izumi     2016-03-15  5503  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
342332e6a Taku Izumi     2016-03-15  5504  		/*
b72d0ffb5 Andrew Morton  2016-03-15  5505  		 * Check given memblock attribute by firmware which can affect
b72d0ffb5 Andrew Morton  2016-03-15  5506  		 * kernel memory layout.  If zone==ZONE_MOVABLE but memory is
b72d0ffb5 Andrew Morton  2016-03-15  5507  		 * mirrored, it's an overlapped memmap init. skip it.
342332e6a Taku Izumi     2016-03-15  5508  		 */
342332e6a Taku Izumi     2016-03-15  5509  		if (mirrored_kernelcore && zone == ZONE_MOVABLE) {
b72d0ffb5 Andrew Morton  2016-03-15  5510  			if (!r || pfn >= memblock_region_memory_end_pfn(r)) {
342332e6a Taku Izumi     2016-03-15  5511  				for_each_memblock(memory, tmp)
342332e6a Taku Izumi     2016-03-15  5512  					if (pfn < memblock_region_memory_end_pfn(tmp))
342332e6a Taku Izumi     2016-03-15  5513  						break;
342332e6a Taku Izumi     2016-03-15  5514  				r = tmp;
342332e6a Taku Izumi     2016-03-15  5515  			}
342332e6a Taku Izumi     2016-03-15  5516  			if (pfn >= memblock_region_memory_base_pfn(r) &&
342332e6a Taku Izumi     2016-03-15  5517  			    memblock_is_mirror(r)) {
342332e6a Taku Izumi     2016-03-15  5518  				/* already initialized as NORMAL */
342332e6a Taku Izumi     2016-03-15  5519  				pfn = memblock_region_memory_end_pfn(r);
342332e6a Taku Izumi     2016-03-15 @5520  				continue;
342332e6a Taku Izumi     2016-03-15  5521  			}
342332e6a Taku Izumi     2016-03-15  5522  		}
342332e6a Taku Izumi     2016-03-15  5523  #endif
ac5d2539b Mel Gorman     2015-06-30  5524  
b72d0ffb5 Andrew Morton  2016-03-15  5525  not_early:
d08f92e7d Pavel Tatashin 2018-03-23  5526  		page = pfn_to_page(pfn);
d08f92e7d Pavel Tatashin 2018-03-23  5527  		__init_single_page(page, pfn, zone, nid);
d08f92e7d Pavel Tatashin 2018-03-23  5528  		if (context == MEMMAP_HOTPLUG)
d08f92e7d Pavel Tatashin 2018-03-23  5529  			SetPageReserved(page);
d08f92e7d Pavel Tatashin 2018-03-23  5530  
ac5d2539b Mel Gorman     2015-06-30  5531  		/*
ac5d2539b Mel Gorman     2015-06-30  5532  		 * Mark the block movable so that blocks are reserved for
ac5d2539b Mel Gorman     2015-06-30  5533  		 * movable at startup. This will force kernel allocations
ac5d2539b Mel Gorman     2015-06-30  5534  		 * to reserve their blocks rather than leaking throughout
ac5d2539b Mel Gorman     2015-06-30  5535  		 * the address space during boot when many long-lived
974a786e6 Mel Gorman     2015-11-06  5536  		 * kernel allocations are made.
ac5d2539b Mel Gorman     2015-06-30  5537  		 *
ac5d2539b Mel Gorman     2015-06-30  5538  		 * bitmap is created for zone's valid pfn range. but memmap
ac5d2539b Mel Gorman     2015-06-30  5539  		 * can be created for invalid pages (for alignment)
ac5d2539b Mel Gorman     2015-06-30  5540  		 * check here not to call set_pageblock_migratetype() against
ac5d2539b Mel Gorman     2015-06-30  5541  		 * pfn out of zone.
9bb5a391f Michal Hocko   2018-01-31  5542  		 *
9bb5a391f Michal Hocko   2018-01-31  5543  		 * Please note that MEMMAP_HOTPLUG path doesn't clear memmap
9bb5a391f Michal Hocko   2018-01-31  5544  		 * because this is done early in sparse_add_one_section
ac5d2539b Mel Gorman     2015-06-30  5545  		 */
ac5d2539b Mel Gorman     2015-06-30  5546  		if (!(pfn & (pageblock_nr_pages - 1))) {
ac5d2539b Mel Gorman     2015-06-30  5547  			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
9b6e63cbf Michal Hocko   2017-10-03  5548  			cond_resched();
^1da177e4 Linus Torvalds 2005-04-16  5549  		}
^1da177e4 Linus Torvalds 2005-04-16  5550  	}
ac5d2539b Mel Gorman     2015-06-30 @5551  }
^1da177e4 Linus Torvalds 2005-04-16  5552  

:::::: The code at line 5499 was first introduced by commit
:::::: 7516795739bd53175629b90fab0ad488d7a6a9f7 [PATCH] Reintroduce NODES_SPAN_OTHER_NODES for powerpc

:::::: TO: Andy Whitcroft <apw@shadowen.org>
:::::: CC: Linus Torvalds <torvalds@g5.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--LZvS9be/3tNcYl/X
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICHF2t1oAAy5jb25maWcAhFxbc+M2sn7fX6GavOw+JPFlRjunTvkBAkEJEUkwAChZfmE5
Hk3WFY89x9Zkk39/ugFeALCpSaUSs7txIdCXrxugfvjHDwv27fTy5f70+HD/9PT34vfj8/H1
/nT8tPj8+HT830WmFpWyC5FJ+xMIF4/P3/76+fH643Lx/qfL5U8XP74+LH/88uVysT2+Ph+f
Fvzl+fPj79+gi8eX53/88A+uqlyu29uPy/b66ubv4Hl8kJWxuuFWqqrNBFeZ0CNTNbZubJsr
XTJ78+749Pn66kecwLtegmm+gXa5f7x5d//68J+f//q4/PnBzeXNTbf9dPzsn4d2heLbTNSt
aepaaTsOaSzjW6sZF1NeWTbjgxu5LFnd6iprV9KatpTVzcdzfHZ7c7mkBbgqa2a/208kFnVX
CZG1Zt1mJWsLUa3tZpzrWlRCS95Kw5A/Zaya9ZS42Qu53tj0ldmh3bCdaGve5hkfuXpvRNne
8s2aZVnLirXS0m7Kab+cFXKlmRWwcQU7JP1vmGl53bQaeLcUj/GNaAtZwQbJOzFKuEkZYZu6
rYV2fTAtgpd1K9SzRLmCp1xqY1u+aartjFzN1oIW8zOSK6Er5tS3VsbIVSESEdOYWsDWzbD3
rLLtpoFR6hI2cANzpiTc4rHCSdpiNRnDqappVW1lCcuSgWHBGslqPSeZCdh093qsAGuIzBPM
tTVlPde0qbVaCTOyc3nbCqaLAzy3pQj2vF5bBu8MGrkThbm5Gsxe/9rulQ6Wc9XIIoPJi1bc
+jYmMj67gc3E18oV/Ke1zGBj8DI/LNbObz0t3o6nb19HvwOvb1tR7WD2YPCwLPbmepgA17Ad
zpwkbMm7d9BNz/G01gpjF49vi+eXE/YceA5W7IQ2sOXYjiC3rLEqUcwtqIko2vWdrGnOCjhX
NKu4C2025NzezbWYGb+4ew+M4V2DWYWvmvLd3M4J4AzP8W/vzrdWxEJHM+5o4OlZU4C9KGMr
VsLG/fP55fn4r2D7zMHsZM2JDsEAQU/LXxvRBCYWUrExt0W4Ql5PQKeVPrTMQnTYEF03RoBP
C9uxBqImIek2w5mTk8ABwf56TQazWLx9++3t77fT8cuoyYP/Bqtxtke4dmCZjdrTHJHnAmIs
Dp3n4MLNdiqHTgr8BcrTnZRyrZ2no9l8E6o2UjJVMllRNPCb4M1gFQ4zQzGrYVecZ2JWaVpK
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
2Lh1SIIHwBQP3tDFjfEPP3w61TOJAQA=

--LZvS9be/3tNcYl/X--
