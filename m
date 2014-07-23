Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AAA366B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 04:02:31 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so1238951pab.40
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 01:02:31 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id z8si1634939pas.117.2014.07.23.01.02.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 01:02:30 -0700 (PDT)
Date: Wed, 23 Jul 2014 11:02:25 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [mmotm:master 155/499] mm/memcontrol.c:2946
 memcg_update_cache_size() error: we previously assumed 'cur_params' could be
 null (see line 2932)
Message-ID: <20140723080225.GG13737@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild@01.org, Vladimir Davydov <vdavydov@parallels.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   bb46fa8ad844d29e9f74f6209777d955a42916f6
commit: dbc3484b1953f019f408b7c1ecaa3f5e0e8c24bb [155/499] memcg: keep all children of each root cache on a list

mm/memcontrol.c:2946 memcg_update_cache_size() error: we previously assumed 'cur_params' could be null (see line 2932)

git remote add mmotm git://git.cmpxchg.org/linux-mmotm.git
git remote update mmotm
git checkout dbc3484b1953f019f408b7c1ecaa3f5e0e8c24bb
vim +/cur_params +2946 mm/memcontrol.c

f8570263 Vladimir Davydov 2014-01-23  2926  		new_params = kzalloc(size, GFP_KERNEL);
f8570263 Vladimir Davydov 2014-01-23  2927  		if (!new_params)
55007d84 Glauber Costa    2012-12-18  2928  			return -ENOMEM;
55007d84 Glauber Costa    2012-12-18  2929  
f8570263 Vladimir Davydov 2014-01-23  2930  		new_params->is_root_cache = true;
dbc3484b Vladimir Davydov 2014-07-22  2931  		INIT_LIST_HEAD(&new_params->children);
dbc3484b Vladimir Davydov 2014-07-22 @2932  		if (cur_params)
dbc3484b Vladimir Davydov 2014-07-22  2933  			list_replace(&cur_params->children,
dbc3484b Vladimir Davydov 2014-07-22  2934  				     &new_params->children);
55007d84 Glauber Costa    2012-12-18  2935  
55007d84 Glauber Costa    2012-12-18  2936  		/*
55007d84 Glauber Costa    2012-12-18  2937  		 * There is the chance it will be bigger than
55007d84 Glauber Costa    2012-12-18  2938  		 * memcg_limited_groups_array_size, if we failed an allocation
55007d84 Glauber Costa    2012-12-18  2939  		 * in a cache, in which case all caches updated before it, will
55007d84 Glauber Costa    2012-12-18  2940  		 * have a bigger array.
55007d84 Glauber Costa    2012-12-18  2941  		 *
55007d84 Glauber Costa    2012-12-18  2942  		 * But if that is the case, the data after
55007d84 Glauber Costa    2012-12-18  2943  		 * memcg_limited_groups_array_size is certainly unused
55007d84 Glauber Costa    2012-12-18  2944  		 */
55007d84 Glauber Costa    2012-12-18  2945  		for (i = 0; i < memcg_limited_groups_array_size; i++) {
55007d84 Glauber Costa    2012-12-18 @2946  			if (!cur_params->memcg_caches[i])
55007d84 Glauber Costa    2012-12-18  2947  				continue;
f8570263 Vladimir Davydov 2014-01-23  2948  			new_params->memcg_caches[i] =
55007d84 Glauber Costa    2012-12-18  2949  						cur_params->memcg_caches[i];

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
