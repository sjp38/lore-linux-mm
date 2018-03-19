Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6BFB6B0007
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 06:38:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e10so9457075pff.3
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 03:38:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p91-v6si12095660plb.705.2018.03.19.03.37.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Mar 2018 03:37:59 -0700 (PDT)
Date: Mon, 19 Mar 2018 11:37:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?562U5aSNOiBbUEFUQ0g=?= =?utf-8?Q?=5D?=
 mm/memcontrol.c: speed up to force empty a memory cgroup
Message-ID: <20180319103756.GV23100@dhcp22.suse.cz>
References: <1521448170-19482-1-git-send-email-lirongqing@baidu.com>
 <20180319085355.GQ23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C23745764B@BC-MAIL-M28.internal.baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2AD939572F25A448A3AE3CAEA61328C23745764B@BC-MAIL-M28.internal.baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li,Rongqing" <lirongqing@baidu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Mon 19-03-18 10:00:41, Li,Rongqing wrote:
> 
> 
> > -----e?(R)a>>?a??a>>?-----
> > a??a>>?aoo: Michal Hocko [mailto:mhocko@kernel.org]
> > a??e??ae??e?': 2018a1'3ae??19ae?JPY 16:54
> > ae??a>>?aoo: Li,Rongqing <lirongqing@baidu.com>
> > ae??e??: linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> > cgroups@vger.kernel.org; hannes@cmpxchg.org; Andrey Ryabinin
> > <aryabinin@virtuozzo.com>
> > a,>>ec?: Re: [PATCH] mm/memcontrol.c: speed up to force empty a memory
> > cgroup
> > 
> > On Mon 19-03-18 16:29:30, Li RongQing wrote:
> > > mem_cgroup_force_empty() tries to free only 32 (SWAP_CLUSTER_MAX)
> > > pages on each iteration, if a memory cgroup has lots of page cache, it
> > > will take many iterations to empty all page cache, so increase the
> > > reclaimed number per iteration to speed it up. same as in
> > > mem_cgroup_resize_limit()
> > >
> > > a simple test show:
> > >
> > >   $dd if=aaa  of=bbb  bs=1k count=3886080
> > >   $rm -f bbb
> > >   $time echo 100000000 >/cgroup/memory/test/memory.limit_in_bytes
> > >
> > > Before: 0m0.252s ===> after: 0m0.178s
> > 
> > Andrey was proposing something similar [1]. My main objection was that his
> > approach might lead to over-reclaim. Your approach is more conservative
> > because it just increases the batch size. The size is still rather arbitrary. Same
> > as SWAP_CLUSTER_MAX but that one is a commonly used unit of reclaim in
> > the MM code.
> > 
> > I would be really curious about more detailed explanation why having a
> > larger batch yields to a better performance because we are doingg
> > SWAP_CLUSTER_MAX batches at the lower reclaim level anyway.
> > 
> 
> Although SWAP_CLUSTER_MAX is used at the lower level, but the call stack of 
> try_to_free_mem_cgroup_pages is too long, increase the nr_to_reclaim can reduce
> times of calling function[do_try_to_free_pages, shrink_zones, hrink_node ]
> 
> mem_cgroup_resize_limit
> --->try_to_free_mem_cgroup_pages:  .nr_to_reclaim = max(1024,  SWAP_CLUSTER_MAX),
>    ---> do_try_to_free_pages 
>      ---> shrink_zones
>       --->shrink_node
>        ---> shrink_node_memcg
>          ---> shrink_list          <-------loop will happen in this place [times=1024/32]
>            ---> shrink_page_list

Can you actually measure this to be the culprit. Because we should
rethink our call path if it is too complicated/deep to perform well.
Adding arbitrary batch sizes doesn't sound like a good way to go to me.
-- 
Michal Hocko
SUSE Labs
