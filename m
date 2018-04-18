Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF2386B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 09:06:10 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 127so722343pge.10
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 06:06:10 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0109.outbound.protection.outlook.com. [104.47.0.109])
        by mx.google.com with ESMTPS id o69si1157276pfi.322.2018.04.18.06.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 06:06:09 -0700 (PDT)
Subject: Re: [PATCH v2 04/12] mm: Assign memcg-aware shrinkers bitmap to memcg
References: <152399121146.3456.5459546288565589098.stgit@localhost.localdomain>
 <201804182053.71Pa9aRK%fengguang.wu@intel.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <9d2603ed-e7b9-3eb4-2e2c-9ce2060ff853@virtuozzo.com>
Date: Wed, 18 Apr 2018 16:05:59 +0300
MIME-Version: 1.0
In-Reply-To: <201804182053.71Pa9aRK%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Hi,

On 18.04.2018 15:55, kbuild test robot wrote:
> Hi Kirill,
> 
> Thank you for the patch! Perhaps something to improve:
> 
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on next-20180418]
> [cannot apply to v4.17-rc1]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Kirill-Tkhai/Improve-shrink_slab-scalability-old-complexity-was-O-n-2-new-is-O-n/20180418-184501
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: x86_64-randconfig-x011-201815 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
> 
> All warnings (new ones prefixed by >>):
> 
>    mm/memcontrol.c: In function 'expand_shrinker_maps':
>>> mm/memcontrol.c:402:9: warning: 'ret' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      return ret;>             ^~~

thanks for reporting this. Actually in terms of kernel it's a false positive
(since this function is called at time, when for_each_node() iterates not empty
list), but of course, I'll add ret initialization to silence the compiler.

This should not prevent the review of the patchset, so I'm waiting for people's
comments about it before resending v3.

> 
> vim +/ret +402 mm/memcontrol.c
> 
>    377	
>    378	int expand_shrinker_maps(int old_nr, int nr)
>    379	{
>    380		int id, size, old_size, node, ret;
>    381		struct mem_cgroup *memcg;
>    382	
>    383		old_size = old_nr / BITS_PER_BYTE;
>    384		size = nr / BITS_PER_BYTE;
>    385	
>    386		down_write(&shrinkers_max_nr_rwsem);
>    387		for_each_node(node) {
>    388			idr_for_each_entry(&mem_cgroup_idr, memcg, id) {
>    389				if (id == 1)
>    390					memcg = NULL;
>    391				ret = memcg_expand_maps(memcg, node, size, old_size);
>    392				if (ret)
>    393					goto unlock;
>    394			}
>    395	
>    396			/* root_mem_cgroup is not initialized yet */
>    397			if (id == 0)
>    398				ret = memcg_expand_maps(NULL, node, size, old_size);
>    399		}
>    400	unlock:
>    401		up_write(&shrinkers_max_nr_rwsem);
>  > 402		return ret;
>    403	}
>    404	#else /* CONFIG_SLOB */
>    405	static void get_shrinkers_max_nr(void) { }
>    406	static void put_shrinkers_max_nr(void) { }
>    407	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

Kirill
