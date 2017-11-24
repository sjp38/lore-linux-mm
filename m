Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B15426B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 17:30:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id u3so23500850pgn.3
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 14:30:30 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m3si18775388pgd.250.2017.11.24.14.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 14:30:29 -0800 (PST)
Date: Sat, 25 Nov 2017 06:29:31 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 19/23] kasan: make kasan_cache_create() work with 32-bit
 slab caches
Message-ID: <201711250632.5AaCH19c%fengguang.wu@intel.com>
References: <20171123221628.8313-19-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123221628.8313-19-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com

Hi Alexey,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[cannot apply to mmotm/master v4.14 next-20171124]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Alexey-Dobriyan/slab-make-kmalloc_index-return-unsigned-int/20171125-035138
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


vim +361 mm/kasan/kasan.c

7ed2f9e6 Alexander Potapenko 2016-03-25  338  
5d094e12 Alexey Dobriyan     2017-11-24  339  void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
d50112ed Alexey Dobriyan     2017-11-15  340  			slab_flags_t *flags)
7ed2f9e6 Alexander Potapenko 2016-03-25  341  {
5d094e12 Alexey Dobriyan     2017-11-24  342  	unsigned int orig_size = *size;
7ed2f9e6 Alexander Potapenko 2016-03-25  343  	int redzone_adjust;
80a9201a Alexander Potapenko 2016-07-28  344  
7ed2f9e6 Alexander Potapenko 2016-03-25  345  	/* Add alloc meta. */
7ed2f9e6 Alexander Potapenko 2016-03-25  346  	cache->kasan_info.alloc_meta_offset = *size;
7ed2f9e6 Alexander Potapenko 2016-03-25  347  	*size += sizeof(struct kasan_alloc_meta);
7ed2f9e6 Alexander Potapenko 2016-03-25  348  
7ed2f9e6 Alexander Potapenko 2016-03-25  349  	/* Add free meta. */
5f0d5a3a Paul E. McKenney    2017-01-18  350  	if (cache->flags & SLAB_TYPESAFE_BY_RCU || cache->ctor ||
7ed2f9e6 Alexander Potapenko 2016-03-25  351  	    cache->object_size < sizeof(struct kasan_free_meta)) {
7ed2f9e6 Alexander Potapenko 2016-03-25  352  		cache->kasan_info.free_meta_offset = *size;
7ed2f9e6 Alexander Potapenko 2016-03-25  353  		*size += sizeof(struct kasan_free_meta);
7ed2f9e6 Alexander Potapenko 2016-03-25  354  	}
7ed2f9e6 Alexander Potapenko 2016-03-25  355  	redzone_adjust = optimal_redzone(cache->object_size) -
7ed2f9e6 Alexander Potapenko 2016-03-25  356  		(*size - cache->object_size);
80a9201a Alexander Potapenko 2016-07-28  357  
7ed2f9e6 Alexander Potapenko 2016-03-25  358  	if (redzone_adjust > 0)
7ed2f9e6 Alexander Potapenko 2016-03-25  359  		*size += redzone_adjust;
80a9201a Alexander Potapenko 2016-07-28  360  
80a9201a Alexander Potapenko 2016-07-28 @361  	*size = min(KMALLOC_MAX_SIZE, max(*size, cache->object_size +
7ed2f9e6 Alexander Potapenko 2016-03-25  362  					optimal_redzone(cache->object_size)));
80a9201a Alexander Potapenko 2016-07-28  363  
80a9201a Alexander Potapenko 2016-07-28  364  	/*
80a9201a Alexander Potapenko 2016-07-28  365  	 * If the metadata doesn't fit, don't enable KASAN at all.
80a9201a Alexander Potapenko 2016-07-28  366  	 */
80a9201a Alexander Potapenko 2016-07-28  367  	if (*size <= cache->kasan_info.alloc_meta_offset ||
80a9201a Alexander Potapenko 2016-07-28  368  			*size <= cache->kasan_info.free_meta_offset) {
80a9201a Alexander Potapenko 2016-07-28  369  		cache->kasan_info.alloc_meta_offset = 0;
80a9201a Alexander Potapenko 2016-07-28  370  		cache->kasan_info.free_meta_offset = 0;
80a9201a Alexander Potapenko 2016-07-28  371  		*size = orig_size;
80a9201a Alexander Potapenko 2016-07-28  372  		return;
80a9201a Alexander Potapenko 2016-07-28  373  	}
80a9201a Alexander Potapenko 2016-07-28  374  
80a9201a Alexander Potapenko 2016-07-28  375  	*flags |= SLAB_KASAN;
7ed2f9e6 Alexander Potapenko 2016-03-25  376  }
7ed2f9e6 Alexander Potapenko 2016-03-25  377  

:::::: The code at line 361 was first introduced by commit
:::::: 80a9201a5965f4715d5c09790862e0df84ce0614 mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB

:::::: TO: Alexander Potapenko <glider@google.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
