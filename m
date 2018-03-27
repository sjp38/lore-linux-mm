Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE4A6B000D
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 17:58:06 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w19-v6so245337plq.2
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 14:58:06 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id n8si1487396pgt.480.2018.03.27.14.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 14:58:04 -0700 (PDT)
Date: Wed, 28 Mar 2018 05:57:23 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 3/6] Protectable Memory
Message-ID: <201803280458.FLPWjWSo%fengguang.wu@intel.com>
References: <20180327015524.14318-4-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Content-Disposition: inline
In-Reply-To: <20180327015524.14318-4-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: kbuild-all@01.org, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org, david@fromorbit.com, rppt@linux.vnet.ibm.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Igor,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.16-rc7 next-20180327]
[cannot apply to mmotm/master]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Igor-Stoppa/mm-security-ro-protection-for-dynamic-data/20180328-041541
config: i386-randconfig-x073-201812 (attached as .config)
compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   In file included from include/asm-generic/bug.h:18:0,
                    from arch/x86/include/asm/bug.h:83,
                    from include/linux/bug.h:5,
                    from include/linux/mmdebug.h:5,
                    from include/linux/mm.h:9,
                    from mm/pmalloc.c:11:
   mm/pmalloc.c: In function 'grow':
   include/linux/kernel.h:809:16: warning: comparison of distinct pointer types lacks a cast
     (void) (&max1 == &max2);   \
                   ^
   include/linux/kernel.h:818:2: note: in expansion of macro '__max'
     __max(typeof(x), typeof(y),   \
     ^~~~~
>> mm/pmalloc.c:155:17: note: in expansion of macro 'max'
     addr = vmalloc(max(size, pool->refill));
                    ^~~

vim +/max +155 mm/pmalloc.c

  > 11	#include <linux/mm.h>
    12	#include <linux/vmalloc.h>
    13	#include <linux/kernel.h>
    14	#include <linux/log2.h>
    15	#include <linux/slab.h>
    16	#include <linux/set_memory.h>
    17	#include <linux/bug.h>
    18	#include <linux/mutex.h>
    19	#include <linux/llist.h>
    20	#include <asm/cacheflush.h>
    21	#include <asm/page.h>
    22	
    23	#include <linux/pmalloc.h>
    24	
    25	#define MAX_ALIGN_ORDER (ilog2(sizeof(void *)))
    26	struct pmalloc_pool {
    27		struct mutex mutex;
    28		struct list_head pool_node;
    29		struct llist_head vm_areas;
    30		unsigned long refill;
    31		unsigned long offset;
    32		unsigned long align;
    33	};
    34	
    35	static LIST_HEAD(pools_list);
    36	static DEFINE_MUTEX(pools_mutex);
    37	
    38	static inline void tag_area(struct vmap_area *area)
    39	{
    40		area->vm->flags |= VM_PMALLOC;
    41	}
    42	
    43	static inline void untag_area(struct vmap_area *area)
    44	{
    45		area->vm->flags &= ~VM_PMALLOC;
    46	}
    47	
    48	static inline struct vmap_area *current_area(struct pmalloc_pool *pool)
    49	{
    50		return llist_entry(pool->vm_areas.first, struct vmap_area,
    51				   area_list);
    52	}
    53	
    54	static inline bool is_area_protected(struct vmap_area *area)
    55	{
    56		return area->vm->flags & VM_PMALLOC_PROTECTED;
    57	}
    58	
    59	static inline bool protect_area(struct vmap_area *area)
    60	{
    61		if (unlikely(is_area_protected(area)))
    62			return false;
    63		set_memory_ro(area->va_start, area->vm->nr_pages);
    64		area->vm->flags |= VM_PMALLOC_PROTECTED;
    65		return true;
    66	}
    67	
    68	static inline void destroy_area(struct vmap_area *area)
    69	{
    70		WARN(!is_area_protected(area), "Destroying unprotected area.");
    71		set_memory_rw(area->va_start, area->vm->nr_pages);
    72		vfree((void *)area->va_start);
    73	}
    74	
    75	static inline bool empty(struct pmalloc_pool *pool)
    76	{
    77		return unlikely(llist_empty(&pool->vm_areas));
    78	}
    79	
    80	static inline bool protected(struct pmalloc_pool *pool)
    81	{
    82		return is_area_protected(current_area(pool));
    83	}
    84	
    85	static inline unsigned long get_align(struct pmalloc_pool *pool,
    86					      short int align_order)
    87	{
    88		if (likely(align_order < 0))
    89			return pool->align;
    90		return 1UL << align_order;
    91	}
    92	
    93	static inline bool exhausted(struct pmalloc_pool *pool, size_t size,
    94				     short int align_order)
    95	{
    96		unsigned long align = get_align(pool, align_order);
    97		unsigned long space_before = round_down(pool->offset, align);
    98		unsigned long space_after = pool->offset - space_before;
    99	
   100		return unlikely(space_after < size && space_before < size);
   101	}
   102	
   103	static inline bool space_needed(struct pmalloc_pool *pool, size_t size,
   104					short int align_order)
   105	{
   106		return empty(pool) || protected(pool) ||
   107			exhausted(pool, size, align_order);
   108	}
   109	
   110	#define DEFAULT_REFILL_SIZE PAGE_SIZE
   111	/**
   112	 * pmalloc_create_custom_pool() - create a new protectable memory pool
   113	 * @refill: the minimum size to allocate when in need of more memory.
   114	 *          It will be rounded up to a multiple of PAGE_SIZE
   115	 *          The value of 0 gives the default amount of PAGE_SIZE.
   116	 * @align_order: log2 of the alignment to use when allocating memory
   117	 *               Negative values give log2(sizeof(size_t)).
   118	 *
   119	 * Creates a new (empty) memory pool for allocation of protectable
   120	 * memory. Memory will be allocated upon request (through pmalloc).
   121	 *
   122	 * Return:
   123	 * * pointer to the new pool	- success
   124	 * * NULL			- error
   125	 */
   126	struct pmalloc_pool *pmalloc_create_custom_pool(unsigned long refill,
   127							short int align_order)
   128	{
   129		struct pmalloc_pool *pool;
   130	
   131		pool = kzalloc(sizeof(struct pmalloc_pool), GFP_KERNEL);
   132		if (WARN(!pool, "Could not allocate pool meta data."))
   133			return NULL;
   134	
   135		pool->refill = refill ? PAGE_ALIGN(refill) : DEFAULT_REFILL_SIZE;
   136		if (align_order < 0)
   137			pool->align = sizeof(size_t);
   138		else
   139			pool->align = 1UL << align_order;
   140		mutex_init(&pool->mutex);
   141	
   142		mutex_lock(&pools_mutex);
   143		list_add(&pool->pool_node, &pools_list);
   144		mutex_unlock(&pools_mutex);
   145		return pool;
   146	}
   147	
   148	
   149	static int grow(struct pmalloc_pool *pool, size_t size,
   150			short int align_order)
   151	{
   152		void *addr;
   153		struct vmap_area *area;
   154	
 > 155		addr = vmalloc(max(size, pool->refill));
   156		if (WARN(!addr, "Failed to allocate %zd bytes", PAGE_ALIGN(size)))
   157			return -ENOMEM;
   158	
   159		area = find_vmap_area((unsigned long)addr);
   160		tag_area(area);
   161		pool->offset = area->vm->nr_pages * PAGE_SIZE;
   162		llist_add(&area->area_list, &pool->vm_areas);
   163		return 0;
   164	}
   165	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--x+6KMIRAuhnl3hBn
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
Vp6iAQA=

--x+6KMIRAuhnl3hBn--
