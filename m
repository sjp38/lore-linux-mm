Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id EF4CA6B025B
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:54:41 -0400 (EDT)
Received: by lbbyj8 with SMTP id yj8so13645049lbb.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 04:54:41 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ks11si7324181lac.78.2015.07.24.04.54.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 04:54:39 -0700 (PDT)
Date: Fri, 24 Jul 2015 14:54:22 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [mmotm:master 260/385] include/linux/mmu_notifier.h:247:19:
 sparse: context imbalance in 'kpageidle_clear_pte_refs_one' - unexpected
 unlock
Message-ID: <20150724115422.GB8100@esperanza>
References: <201507241941.wqF1a0kN%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <201507241941.wqF1a0kN%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andres Lagar-Cavilla <andreslc@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Jul 24, 2015 at 07:14:46PM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   61f5f835b6f06fbc233481b5d3c0afd71ecf54e8
> commit: a06e045a2c99e39bf342ccb5dbbd6655f3814238 [260/385] proc: add kpageidle file
> reproduce:
>   # apt-get install sparse
>   git checkout a06e045a2c99e39bf342ccb5dbbd6655f3814238
>   make ARCH=x86_64 allmodconfig
>   make C=1 CF=-D__CHECK_ENDIAN__
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
> >> include/linux/mmu_notifier.h:247:19: sparse: context imbalance in 'kpageidle_clear_pte_refs_one' - unexpected unlock
> 
> vim +/kpageidle_clear_pte_refs_one +247 include/linux/mmu_notifier.h
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
> 59eaee21 Vladimir Davydov     2015-07-23 @247  static inline int mmu_notifier_clear_young(struct mm_struct *mm,
> 59eaee21 Vladimir Davydov     2015-07-23  248  					   unsigned long start,
> 59eaee21 Vladimir Davydov     2015-07-23  249  					   unsigned long end)
> 59eaee21 Vladimir Davydov     2015-07-23  250  {
> 59eaee21 Vladimir Davydov     2015-07-23  251  	if (mm_has_notifiers(mm))
> 59eaee21 Vladimir Davydov     2015-07-23  252  		return __mmu_notifier_clear_young(mm, start, end);
> 59eaee21 Vladimir Davydov     2015-07-23  253  	return 0;
> 59eaee21 Vladimir Davydov     2015-07-23  254  }
> 59eaee21 Vladimir Davydov     2015-07-23  255  

Looks like this warning is issued, because page_check_address, used by
kpageidle_clear_pte_refs_one, is not annotated as acquiring a ptl lock.
It is false-positive then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
