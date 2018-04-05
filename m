Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9BF6B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 10:57:56 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id z2-v6so4896162plk.3
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 07:57:56 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id n9-v6si5796014plk.71.2018.04.05.07.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 07:57:54 -0700 (PDT)
Date: Thu, 5 Apr 2018 22:57:26 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 1/1] z3fold: fix memory leak
Message-ID: <201804052205.ejzdZ5Qg%fengguang.wu@intel.com>
References: <1522803111-29209-1-git-send-email-wangxidong_97@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522803111-29209-1-git-send-email-wangxidong_97@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xidong Wang <wangxidong_97@163.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Vitaly Wool <vitalywool@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Xidong,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on mmotm/master]
[also build test WARNING on v4.16 next-20180405]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Xidong-Wang/z3fold-fix-memory-leak/20180404-114952
base:   git://git.cmpxchg.org/linux-mmotm.git master

smatch warnings:
mm/z3fold.c:493 z3fold_create_pool() error: potential null dereference 'pool'.  (kzalloc returns null)
mm/z3fold.c:493 z3fold_create_pool() error: we previously assumed 'pool' could be null (see line 465)

vim +/pool +493 mm/z3fold.c

   443	
   444	
   445	/*
   446	 * API Functions
   447	 */
   448	
   449	/**
   450	 * z3fold_create_pool() - create a new z3fold pool
   451	 * @name:	pool name
   452	 * @gfp:	gfp flags when allocating the z3fold pool structure
   453	 * @ops:	user-defined operations for the z3fold pool
   454	 *
   455	 * Return: pointer to the new z3fold pool or NULL if the metadata allocation
   456	 * failed.
   457	 */
   458	static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
   459			const struct z3fold_ops *ops)
   460	{
   461		struct z3fold_pool *pool = NULL;
   462		int i, cpu;
   463	
   464		pool = kzalloc(sizeof(struct z3fold_pool), gfp);
 > 465		if (!pool)
   466			goto out;
   467		spin_lock_init(&pool->lock);
   468		spin_lock_init(&pool->stale_lock);
   469		pool->unbuddied = __alloc_percpu(sizeof(struct list_head)*NCHUNKS, 2);
   470		for_each_possible_cpu(cpu) {
   471			struct list_head *unbuddied =
   472					per_cpu_ptr(pool->unbuddied, cpu);
   473			for_each_unbuddied_list(i, 0)
   474				INIT_LIST_HEAD(&unbuddied[i]);
   475		}
   476		INIT_LIST_HEAD(&pool->lru);
   477		INIT_LIST_HEAD(&pool->stale);
   478		atomic64_set(&pool->pages_nr, 0);
   479		pool->name = name;
   480		pool->compact_wq = create_singlethread_workqueue(pool->name);
   481		if (!pool->compact_wq)
   482			goto out;
   483		pool->release_wq = create_singlethread_workqueue(pool->name);
   484		if (!pool->release_wq)
   485			goto out_wq;
   486		INIT_WORK(&pool->work, free_pages_work);
   487		pool->ops = ops;
   488		return pool;
   489	
   490	out_wq:
   491		destroy_workqueue(pool->compact_wq);
   492	out:
 > 493		free_percpu(pool->unbuddied);
   494		kfree(pool);
   495		return NULL;
   496	}
   497	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
