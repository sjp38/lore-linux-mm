Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id B496E6B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 05:59:51 -0400 (EDT)
Received: by pabxd6 with SMTP id xd6so41409944pab.2
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 02:59:51 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id o2si1865750pdi.153.2015.08.06.02.59.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 02:59:50 -0700 (PDT)
Date: Thu, 6 Aug 2015 12:59:38 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [linux-next:master 6252/6518]
 include/linux/mmu_notifier.h:247:19: sparse: context imbalance in
 'page_idle_clear_pte_refs_one' - unexpected unlock
Message-ID: <20150806095938.GO11971@esperanza>
References: <201508061748.2PzbGIFl%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <201508061748.2PzbGIFl%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Aug 06, 2015 at 05:48:54PM +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   c6b169e6ffb962068153bd92b0c4ecbd731a122f
> commit: cbba4e22584984bffccd07e0801fd2b8ec1ecf5f [6252/6518] Move /proc/kpageidle to /sys/kernel/mm/page_idle/bitmap
> reproduce:
>   # apt-get install sparse
>   git checkout cbba4e22584984bffccd07e0801fd2b8ec1ecf5f
>   make ARCH=x86_64 allmodconfig
>   make C=1 CF=-D__CHECK_ENDIAN__
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
> >> include/linux/mmu_notifier.h:247:19: sparse: context imbalance in 'page_idle_clear_pte_refs_one' - unexpected unlock
> 
> vim +/page_idle_clear_pte_refs_one +247 include/linux/mmu_notifier.h
> 
> cddb8a5c Andrea Arcangeli     2008-07-28  231  
> cddb8a5c Andrea Arcangeli     2008-07-28  232  static inline void mmu_notifier_release(struct mm_struct *mm)
> cddb8a5c Andrea Arcangeli     2008-07-28  233  {
> cddb8a5c Andrea Arcangeli     2008-07-28  234  	if (mm_has_notifiers(mm))
> cddb8a5c Andrea Arcangeli     2008-07-28  235  		__mmu_notifier_release(mm);
> cddb8a5c Andrea Arcangeli     2008-07-28  236  }
> cddb8a5c Andrea Arcangeli     2008-07-28  237  
> cddb8a5c Andrea Arcangeli     2008-07-28  238  static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
> 57128468 Andres Lagar-Cavilla 2014-09-22  239  					  unsigned long start,
> 57128468 Andres Lagar-Cavilla 2014-09-22  240  					  unsigned long end)
> cddb8a5c Andrea Arcangeli     2008-07-28  241  {
> cddb8a5c Andrea Arcangeli     2008-07-28  242  	if (mm_has_notifiers(mm))
> 57128468 Andres Lagar-Cavilla 2014-09-22  243  		return __mmu_notifier_clear_flush_young(mm, start, end);
> cddb8a5c Andrea Arcangeli     2008-07-28  244  	return 0;
> cddb8a5c Andrea Arcangeli     2008-07-28  245  }
> cddb8a5c Andrea Arcangeli     2008-07-28  246  
> 632116f6 Vladimir Davydov     2015-08-06 @247  static inline int mmu_notifier_clear_young(struct mm_struct *mm,
> 632116f6 Vladimir Davydov     2015-08-06  248  					   unsigned long start,
> 632116f6 Vladimir Davydov     2015-08-06  249  					   unsigned long end)
> 632116f6 Vladimir Davydov     2015-08-06  250  {
> 632116f6 Vladimir Davydov     2015-08-06  251  	if (mm_has_notifiers(mm))
> 632116f6 Vladimir Davydov     2015-08-06  252  		return __mmu_notifier_clear_young(mm, start, end);
> 632116f6 Vladimir Davydov     2015-08-06  253  	return 0;
> 632116f6 Vladimir Davydov     2015-08-06  254  }
> 632116f6 Vladimir Davydov     2015-08-06  255  

False-positive as I explained to the similar warning for
kpageilde_clear_pte_refs_one:

http://www.spinics.net/lists/linux-mm/msg92053.html

It is caused by page_check_address, which is not annotated as acquiring
a ptl lock.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
