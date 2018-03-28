Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F23AB6B0029
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 04:01:57 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v126so157379pgb.23
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 01:01:57 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s21si2440556pfi.87.2018.03.28.01.01.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 01:01:56 -0700 (PDT)
Date: Wed, 28 Mar 2018 15:59:48 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm/list_lru: replace spinlock with RCU in
 __list_lru_count_one
Message-ID: <201803281454.4QSlrPKy%fengguang.wu@intel.com>
References: <1522137544-27496-1-git-send-email-lirongqing@baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522137544-27496-1-git-send-email-lirongqing@baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li RongQing <lirongqing@baidu.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

Hi Li,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.16-rc7]
[cannot apply to next-20180327]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Li-RongQing/mm-list_lru-replace-spinlock-with-RCU-in-__list_lru_count_one/20180328-042620
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/list_lru.c:59:15: sparse: incompatible types in comparison expression (different address spaces)
   mm/list_lru.c:61:24: sparse: incompatible types in comparison expression (different address spaces)
>> mm/list_lru.c:59:15: sparse: incompatible types in comparison expression (different address spaces)
   mm/list_lru.c:61:24: sparse: incompatible types in comparison expression (different address spaces)
>> mm/list_lru.c:59:15: sparse: incompatible types in comparison expression (different address spaces)
   mm/list_lru.c:61:24: sparse: incompatible types in comparison expression (different address spaces)
>> mm/list_lru.c:59:15: sparse: incompatible types in comparison expression (different address spaces)
   mm/list_lru.c:61:24: sparse: incompatible types in comparison expression (different address spaces)
>> mm/list_lru.c:59:15: sparse: incompatible types in comparison expression (different address spaces)
   mm/list_lru.c:61:24: sparse: incompatible types in comparison expression (different address spaces)
>> mm/list_lru.c:59:15: sparse: incompatible types in comparison expression (different address spaces)
   mm/list_lru.c:61:24: sparse: incompatible types in comparison expression (different address spaces)

vim +59 mm/list_lru.c

    51	
    52	static inline struct list_lru_one *
    53	list_lru_from_memcg_idx(struct list_lru_node *nlru, int idx)
    54	{
    55		struct list_lru_memcg *tmp;
    56	
    57		WARN_ON_ONCE(!rcu_read_lock_held());
    58	
  > 59		tmp = rcu_dereference(nlru->memcg_lrus);
    60		if (tmp && idx >= 0)
    61			return rcu_dereference(tmp->lru[idx]);
    62	
    63		return &nlru->lru;
    64	}
    65	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
