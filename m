Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id AC2576B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:22:09 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id 6so39226109qgy.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 06:22:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 33si12347677qgj.71.2016.01.28.06.22.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 06:22:08 -0800 (PST)
Date: Thu, 28 Jan 2016 15:22:04 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [linux-next:master 1811/2084] mm/slab.h:316:9: error: implicit
 declaration of function 'virt_to_head_page'
Message-ID: <20160128152204.5a8218bd@redhat.com>
In-Reply-To: <201601281613.YeqluRNV%fengguang.wu@intel.com>
References: <201601281613.YeqluRNV%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, brouer@redhat.com


Hi Andrew,

Looks like I forgot to include linux/mm.h.
Will you fix up your quilt patch:

 http://ozlabs.org/~akpm/mmots/broken-out/mm-fault-inject-take-over-bootstrap-kmem_cache-check.patch

Or how does it work with the MM tree?

Fix needed (verified and compile tested on linux-next):

$ git diff
diff --git a/mm/failslab.c b/mm/failslab.c
index 0c5b3f31f310..b0fac98cd938 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -1,5 +1,6 @@
 #include <linux/fault-inject.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 #include "slab.h"
 
 static struct {


- -- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


On Thu, 28 Jan 2016 16:07:16 +0800
kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   888c8375131656144c1605071eab2eb6ac49abc3
> commit: 074b6f53c320a81e975c0b5dd79daa5e78a711ba [1811/2084] mm: fault-inject take over bootstrap kmem_cache check
> config: i386-randconfig-a0-01271607 (attached as .config)
> reproduce:
>         git checkout 074b6f53c320a81e975c0b5dd79daa5e78a711ba
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from mm/failslab.c:3:0:
>    mm/slab.h: In function 'cache_from_obj':
> >> mm/slab.h:316:9: error: implicit declaration of function 'virt_to_head_page' [-Werror=implicit-function-declaration]  
>      page = virt_to_head_page(x);
>             ^
> >> mm/slab.h:316:7: warning: assignment makes pointer from integer without a cast [-Wint-conversion]  
>      page = virt_to_head_page(x);
>           ^
>    cc1: some warnings being treated as errors
> 
> vim +/virt_to_head_page +316 mm/slab.h
> 
> b9ce5ef4 Glauber Costa 2012-12-18  310  	 * to not do even the assignment. In that case, slab_equal_or_root
> b9ce5ef4 Glauber Costa 2012-12-18  311  	 * will also be a constant.
> b9ce5ef4 Glauber Costa 2012-12-18  312  	 */
> b9ce5ef4 Glauber Costa 2012-12-18  313  	if (!memcg_kmem_enabled() && !unlikely(s->flags & SLAB_DEBUG_FREE))
> b9ce5ef4 Glauber Costa 2012-12-18  314  		return s;
> b9ce5ef4 Glauber Costa 2012-12-18  315  
> b9ce5ef4 Glauber Costa 2012-12-18 @316  	page = virt_to_head_page(x);
> b9ce5ef4 Glauber Costa 2012-12-18  317  	cachep = page->slab_cache;
> b9ce5ef4 Glauber Costa 2012-12-18  318  	if (slab_equal_or_root(cachep, s))
> b9ce5ef4 Glauber Costa 2012-12-18  319  		return cachep;
> 
> :::::: The code at line 316 was first introduced by commit
> :::::: b9ce5ef49f00daf2254c6953c8d31f79aabccd34 sl[au]b: always get the cache from its page in kmem_cache_free()
> 
> :::::: TO: Glauber Costa <glommer@parallels.com>
> :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
