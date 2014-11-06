Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 939096B0088
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 04:13:14 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so867785pad.35
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 01:13:14 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ys9si5460212pab.0.2014.11.06.01.13.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 01:13:13 -0800 (PST)
Date: Thu, 6 Nov 2014 12:13:00 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [mmotm:master 143/283] mm/slab.c:3260:4: error: implicit
 declaration of function 'slab_free'
Message-ID: <20141106091300.GA21897@esperanza>
References: <201411060959.OFpcU713%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <201411060959.OFpcU713%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Thu, Nov 06, 2014 at 09:16:02AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   4873e01c1a932866e01a6ecd91b39d45a8efd8e7
> commit: 9f3ee6d5fef72724587d8934583b3994679c4e40 [143/283] slab: recharge slab pages to the allocating memory cgroup
> config: sh-titan_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 9f3ee6d5fef72724587d8934583b3994679c4e40
>   # save the attached .config to linux build tree
>   make.cross ARCH=sh 
> 
> All error/warnings:
> 
>    mm/slab.c: In function 'slab_alloc':
> >> mm/slab.c:3260:4: error: implicit declaration of function 'slab_free' [-Werror=implicit-function-declaration]
>    mm/slab.c: At top level:
> >> mm/slab.c:3534:122: warning: conflicting types for 'slab_free' [enabled by default]
> >> mm/slab.c:3534:122: error: static declaration of 'slab_free' follows non-static declaration
>    mm/slab.c:3260:4: note: previous implicit declaration of 'slab_free' was here
>    cc1: some warnings being treated as errors
> 
> vim +/slab_free +3260 mm/slab.c
> 
>   3254	
>   3255		if (likely(objp)) {
>   3256			kmemcheck_slab_alloc(cachep, flags, objp, cachep->object_size);
>   3257			if (unlikely(flags & __GFP_ZERO))
>   3258				memset(objp, 0, cachep->object_size);
>   3259			if (unlikely(memcg_kmem_recharge_slab(objp, flags))) {
> > 3260				slab_free(cachep, objp);
>   3261				objp = NULL;
>   3262			}
>   3263		}

Oops, I placed the forward declaration of slab_free under CONFIG_NUMA.
Sorry :-(

The fix would be:

diff --git a/mm/slab.c b/mm/slab.c
index 61b01c2ae1d9..00cd028404cb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2961,6 +2961,8 @@ out:
 	return objp;
 }
 
+static __always_inline void slab_free(struct kmem_cache *cachep, void *objp);
+
 #ifdef CONFIG_NUMA
 /*
  * Try allocating on another node if PFA_SPREAD_SLAB is a mempolicy is set.
@@ -3133,8 +3135,6 @@ done:
 	return obj;
 }
 
-static __always_inline void slab_free(struct kmem_cache *cachep, void *objp);
-
 static __always_inline void *
 slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 		   unsigned long caller)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
