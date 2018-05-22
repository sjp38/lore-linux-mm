Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2F416B026A
	for <linux-mm@kvack.org>; Tue, 22 May 2018 17:39:47 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id a6-v6so12799404pll.22
        for <linux-mm@kvack.org>; Tue, 22 May 2018 14:39:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a3-v6si16588527pff.43.2018.05.22.14.39.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 14:39:46 -0700 (PDT)
Date: Tue, 22 May 2018 14:39:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix race between kmem_cache destroy, create and
 deactivate
Message-Id: <20180522143945.f8a925d15d34615c87fb9c50@linux-foundation.org>
In-Reply-To: <201805230558.T1nJMRRH%fengguang.wu@intel.com>
References: <20180521174116.171846-1-shakeelb@google.com>
	<201805230558.T1nJMRRH%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Shakeel Butt <shakeelb@google.com>, kbuild-all@01.org, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 23 May 2018 05:14:36 +0800 kbuild test robot <lkp@intel.com> wrote:

> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.17-rc6 next-20180517]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Shakeel-Butt/mm-fix-race-between-kmem_cache-destroy-create-and-deactivate/20180523-041715
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: i386-randconfig-x009-201820 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/slub.c: In function '__kmem_cache_alias':
> >> mm/slub.c:4251:4: error: implicit declaration of function 'kmem_cache_put_locked'; did you mean 'kmem_cache_init_late'? [-Werror=implicit-function-declaration]
>        kmem_cache_put_locked(s);
>        ^~~~~~~~~~~~~~~~~~~~~
>        kmem_cache_init_late
>    cc1: some warnings being treated as errors

Thanks.

--- a/mm/slab.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v2-fix
+++ a/mm/slab.h
@@ -204,6 +204,8 @@ ssize_t slabinfo_write(struct file *file
 void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
 int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 
+extern void kmem_cache_put_locked(struct kmem_cache *s);
+
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 
 /* List of all root caches. */
@@ -296,7 +298,6 @@ extern void slab_init_memcg_params(struc
 extern void memcg_link_cache(struct kmem_cache *s);
 extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 				void (*deact_fn)(struct kmem_cache *));
-extern void kmem_cache_put_locked(struct kmem_cache *s);
 #else /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 /* If !memcg, all caches are root. */
_
