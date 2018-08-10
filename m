Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8D86B0007
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 03:01:12 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id c21-v6so4066088pgw.0
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 00:01:11 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30091.outbound.protection.outlook.com. [40.107.3.91])
        by mx.google.com with ESMTPS id r3-v6si8106823pgg.201.2018.08.10.00.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 10 Aug 2018 00:01:09 -0700 (PDT)
Subject: Re: [mmotm:master 124/394] mm/vmscan.c:410:15: error: 'shrinker_idr'
 undeclared; did you mean 'shrinker_list'?
References: <201808101327.UMjeeNfi%fengguang.wu@intel.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <f19e7e62-1146-da99-edb3-ee1f3c632fa9@virtuozzo.com>
Date: Fri, 10 Aug 2018 10:01:01 +0300
MIME-Version: 1.0
In-Reply-To: <201808101327.UMjeeNfi%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

There is v3 with #ifdef, it fixes the problem.

Thanks,
Kirill

On 10.08.2018 08:54, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   b1da01df1aa700864692a49a7007fc96cc1da7d9
> commit: f9ee2a2d698cd64d8032d56649e960a91bb98416 [124/394] mm: use special value SHRINKER_REGISTERING instead list_empty() check
> config: i386-tinyconfig (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         git checkout f9ee2a2d698cd64d8032d56649e960a91bb98416
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> Note: the mmotm/master HEAD b1da01df1aa700864692a49a7007fc96cc1da7d9 builds fine.
>       It only hurts bisectibility.
> 
> All errors (new ones prefixed by >>):
> 
>    mm/vmscan.c: In function 'register_shrinker_prepared':
>>> mm/vmscan.c:410:15: error: 'shrinker_idr' undeclared (first use in this function); did you mean 'shrinker_list'?
>      idr_replace(&shrinker_idr, shrinker, shrinker->id);
>                   ^~~~~~~~~~~~
>                   shrinker_list
>    mm/vmscan.c:410:15: note: each undeclared identifier is reported only once for each function it appears in
>>> mm/vmscan.c:410:47: error: 'struct shrinker' has no member named 'id'
>      idr_replace(&shrinker_idr, shrinker, shrinker->id);
>                                                   ^~
> 
> vim +410 mm/vmscan.c
> 
>    405	
>    406	void register_shrinker_prepared(struct shrinker *shrinker)
>    407	{
>    408		down_write(&shrinker_rwsem);
>    409		list_add_tail(&shrinker->list, &shrinker_list);
>  > 410		idr_replace(&shrinker_idr, shrinker, shrinker->id);
>    411		up_write(&shrinker_rwsem);
>    412	}
>    413	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 
