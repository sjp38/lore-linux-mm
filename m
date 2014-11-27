Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B4BFF6B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 00:10:07 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so4273128pad.17
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 21:10:07 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id xr4si9932595pbb.16.2014.11.26.21.10.04
        for <linux-mm@kvack.org>;
        Wed, 26 Nov 2014 21:10:06 -0800 (PST)
Date: Thu, 27 Nov 2014 14:13:12 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [mmotm:master 185/397] mm/nommu.c:1193:8: warning: assignment
 makes pointer from integer without a cast
Message-ID: <20141127051311.GB6755@js1304-P5Q-DELUXE>
References: <201411270833.w1auTAKD%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201411270833.w1auTAKD%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Nov 27, 2014 at 08:20:35AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   a2d887dee78e23dc092ff14ae2ad22592437a328
> commit: cd4687a1102a69d9045d09e0af6bb9bacfb49ee5 [185/397] mm/nommu: use alloc_pages_exact() rather than it's own implementation
> config: m32r-m32104ut_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout cd4687a1102a69d9045d09e0af6bb9bacfb49ee5
>   # save the attached .config to linux build tree
>   make.cross ARCH=m32r 
> 
> All warnings:
> 
>    mm/nommu.c: In function 'do_mmap_private':
> >> mm/nommu.c:1193:8: warning: assignment makes pointer from integer without a cast
>       base = __get_free_pages(GFP_KERNEL, order);
>            ^
> 
> vim +1193 mm/nommu.c
> 
>   1177		/* allocate some memory to hold the mapping
>   1178		 * - note that this may not return a page-aligned address if the object
>   1179		 *   we're allocating is smaller than a page
>   1180		 */
>   1181		order = get_order(len);
>   1182		kdebug("alloc order %d for %lx", order, len);
>   1183	
>   1184		total = 1 << order;
>   1185		point = len >> PAGE_SHIFT;
>   1186	
>   1187		/* we don't want to allocate a power-of-2 sized page set */
>   1188		if (sysctl_nr_trim_pages && total - point >= sysctl_nr_trim_pages) {
>   1189			total = point;
>   1190			kdebug("try to alloc exact %lu pages", total);
>   1191			base = alloc_pages_exact(len, GFP_KERNEL);
>   1192		} else {
> > 1193			base = __get_free_pages(GFP_KERNEL, order);
>   1194		}

This will fix the warning.
Thanks.

----------->8-------------------
