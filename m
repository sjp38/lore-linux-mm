Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFCE6B0035
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 02:08:44 -0500 (EST)
Received: by mail-la0-f49.google.com with SMTP id er20so2867594lab.8
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 23:08:43 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id jb7si2631685lbc.128.2014.01.09.23.08.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 23:08:42 -0800 (PST)
Message-ID: <52CF9C73.2080604@parallels.com>
Date: Fri, 10 Jan 2014 11:08:35 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [mmotm:master 207/422] mm/memcontrol.c:5884:5: warning: 'ret'
 may be used uninitialized in this function
References: <52cf4efc.V0q0VylLQvSBxkmp%fengguang.wu@intel.com>
In-Reply-To: <52cf4efc.V0q0VylLQvSBxkmp%fengguang.wu@intel.com>
Content-Type: multipart/mixed;
	boundary="------------020906070006030402000000"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

--------------020906070006030402000000
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

Shame on me :-( I wonder why my compiler didn't complain...

The patch fixing this is attached. Andrew, could you please apply it?

Thank you and sorry for the inconvenience.

On 01/10/2014 05:38 AM, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   3fe55fa60ae65a3c8348ae1bfc6fd2e5c3f10654
> commit: f44aea42422dcbc58cd8cc4fc8c564b91a283cef [207/422] memcg: rework memcg_update_kmem_limit synchronization
> config: x86_64-randconfig-c2-0110 (attached as .config)
>
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
>
> All warnings:
>
>    mm/memcontrol.c: In function 'mem_cgroup_css_online':
>>> mm/memcontrol.c:5884:5: warning: 'ret' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      if (ret)
>         ^
>    mm/memcontrol.c:5192:6: note: 'ret' was declared here
>      int ret;
>          ^
>
> vim +/ret +5884 mm/memcontrol.c
>
> 3c11ecf4 KAMEZAWA Hiroyuki 2010-05-26  5868  		return -EINVAL;
> 3c11ecf4 KAMEZAWA Hiroyuki 2010-05-26  5869  	}
> c0ff4b85 Raghavendra K T   2011-11-02  5870  	memcg->oom_kill_disable = val;
> 4d845ebf KAMEZAWA Hiroyuki 2010-06-29  5871  	if (!val)
> c0ff4b85 Raghavendra K T   2011-11-02  5872  		memcg_oom_recover(memcg);
> 0999821b Glauber Costa     2013-02-22  5873  	mutex_unlock(&memcg_create_mutex);
> 3c11ecf4 KAMEZAWA Hiroyuki 2010-05-26  5874  	return 0;
> 3c11ecf4 KAMEZAWA Hiroyuki 2010-05-26  5875  }
> 3c11ecf4 KAMEZAWA Hiroyuki 2010-05-26  5876  
> c255a458 Andrew Morton     2012-07-31  5877  #ifdef CONFIG_MEMCG_KMEM
> cbe128e3 Glauber Costa     2012-04-09  5878  static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
> e5671dfa Glauber Costa     2011-12-11  5879  {
> 55007d84 Glauber Costa     2012-12-18  5880  	int ret;
> 55007d84 Glauber Costa     2012-12-18  5881  
> 2633d7a0 Glauber Costa     2012-12-18  5882  	memcg->kmemcg_id = -1;
> 55007d84 Glauber Costa     2012-12-18  5883  	ret = memcg_propagate_kmem(memcg);
> 55007d84 Glauber Costa     2012-12-18 @5884  	if (ret)
> 55007d84 Glauber Costa     2012-12-18  5885  		return ret;
> 2633d7a0 Glauber Costa     2012-12-18  5886  
> 1d62e436 Glauber Costa     2012-04-09  5887  	return mem_cgroup_sockets_init(memcg, ss);
> 573b400d Michel Lespinasse 2013-04-29  5888  }
> e5671dfa Glauber Costa     2011-12-11  5889  
> 10d5ebf4 Li Zefan          2013-07-08  5890  static void memcg_destroy_kmem(struct mem_cgroup *memcg)
> d1a4c0b3 Glauber Costa     2011-12-11  5891  {
> 1d62e436 Glauber Costa     2012-04-09  5892  	mem_cgroup_sockets_destroy(memcg);
>
> :::::: The code at line 5884 was first introduced by commit
> :::::: 55007d849759252ddd573aeb36143b947202d509 memcg: allocate memory for memcg caches whenever a new memcg appears
>
> :::::: TO: Glauber Costa <glommer@parallels.com>
> :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
>
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation


--------------020906070006030402000000
Content-Type: text/x-patch;
	name="0001-memcg-fix-uninitialized-var-in-memcg_propagate_kmem.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename*0="0001-memcg-fix-uninitialized-var-in-memcg_propagate_kmem.pat";
	filename*1="ch"


--------------020906070006030402000000--
