Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D93D6B0023
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 06:08:48 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 96so5587076wrk.12
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 03:08:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si5953026wmf.191.2018.03.23.03.08.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 03:08:44 -0700 (PDT)
Date: Fri, 23 Mar 2018 11:08:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?562U5aSNOiDnrZTlpI06IFtQQVRD?= =?utf-8?Q?H=5D?=
 mm/memcontrol.c: speed up to force empty a memory cgroup
Message-ID: <20180323100839.GO23100@dhcp22.suse.cz>
References: <1521448170-19482-1-git-send-email-lirongqing@baidu.com>
 <20180319085355.GQ23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C23745764B@BC-MAIL-M28.internal.baidu.com>
 <20180319103756.GV23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C2374589DC@BC-MAIL-M28.internal.baidu.com>
 <2AD939572F25A448A3AE3CAEA61328C2374832C1@BC-MAIL-M28.internal.baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2AD939572F25A448A3AE3CAEA61328C2374832C1@BC-MAIL-M28.internal.baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li,Rongqing" <lirongqing@baidu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Fri 23-03-18 02:58:36, Li,Rongqing wrote:
> 
> 
> > -----e?(R)a>>?a??a>>?-----
> > a??a>>?aoo: linux-kernel-owner@vger.kernel.org
> > [mailto:linux-kernel-owner@vger.kernel.org] a>>GBPe!? Li,Rongqing
> > a??e??ae??e?': 2018a1'3ae??19ae?JPY 18:52
> > ae??a>>?aoo: Michal Hocko <mhocko@kernel.org>
> > ae??e??: linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> > cgroups@vger.kernel.org; hannes@cmpxchg.org; Andrey Ryabinin
> > <aryabinin@virtuozzo.com>
> > a,>>ec?: c-?a??: c-?a??: [PATCH] mm/memcontrol.c: speed up to force empty a
> > memory cgroup
> > 
> > 
> > 
> > > -----e?(R)a>>?a??a>>?-----
> > > a??a>>?aoo: Michal Hocko [mailto:mhocko@kernel.org]
> > > a??e??ae??e?': 2018a1'3ae??19ae?JPY 18:38
> > > ae??a>>?aoo: Li,Rongqing <lirongqing@baidu.com>
> > > ae??e??: linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> > > cgroups@vger.kernel.org; hannes@cmpxchg.org; Andrey Ryabinin
> > > <aryabinin@virtuozzo.com>
> > > a,>>ec?: Re: c-?a??: [PATCH] mm/memcontrol.c: speed up to force empty a
> > memory
> > > cgroup
> > >
> > > On Mon 19-03-18 10:00:41, Li,Rongqing wrote:
> > > >
> > > >
> > > > > -----e?(R)a>>?a??a>>?-----
> > > > > a??a>>?aoo: Michal Hocko [mailto:mhocko@kernel.org]
> > > > > a??e??ae??e?': 2018a1'3ae??19ae?JPY 16:54
> > > > > ae??a>>?aoo: Li,Rongqing <lirongqing@baidu.com>
> > > > > ae??e??: linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> > > > > cgroups@vger.kernel.org; hannes@cmpxchg.org; Andrey Ryabinin
> > > > > <aryabinin@virtuozzo.com>
> > > > > a,>>ec?: Re: [PATCH] mm/memcontrol.c: speed up to force empty a
> > > memory
> > > > > cgroup
> > > > >
> > > > > On Mon 19-03-18 16:29:30, Li RongQing wrote:
> > > > > > mem_cgroup_force_empty() tries to free only 32
> > > (SWAP_CLUSTER_MAX)
> > > > > > pages on each iteration, if a memory cgroup has lots of page
> > > > > > cache, it will take many iterations to empty all page cache, so
> > > > > > increase the reclaimed number per iteration to speed it up. same
> > > > > > as in
> > > > > > mem_cgroup_resize_limit()
> > > > > >
> > > > > > a simple test show:
> > > > > >
> > > > > >   $dd if=aaa  of=bbb  bs=1k count=3886080
> > > > > >   $rm -f bbb
> > > > > >   $time echo
> > > 100000000 >/cgroup/memory/test/memory.limit_in_bytes
> > > > > >
> > > > > > Before: 0m0.252s ===> after: 0m0.178s
> > > > >
> > > > > Andrey was proposing something similar [1]. My main objection was
> > > > > that his approach might lead to over-reclaim. Your approach is
> > > > > more conservative because it just increases the batch size. The
> > > > > size is still rather arbitrary. Same as SWAP_CLUSTER_MAX but that
> > > > > one is a commonly used unit of reclaim in the MM code.
> > > > >
> > > > > I would be really curious about more detailed explanation why
> > > > > having a larger batch yields to a better performance because we
> > > > > are doingg SWAP_CLUSTER_MAX batches at the lower reclaim level
> > anyway.
> > > > >
> > > >
> > > > Although SWAP_CLUSTER_MAX is used at the lower level, but the call
> > > > stack of try_to_free_mem_cgroup_pages is too long, increase the
> > > > nr_to_reclaim can reduce times of calling
> > > > function[do_try_to_free_pages, shrink_zones, hrink_node ]
> > > >
> > > > mem_cgroup_resize_limit
> > > > --->try_to_free_mem_cgroup_pages:  .nr_to_reclaim = max(1024,
> > > > --->SWAP_CLUSTER_MAX),
> > > >    ---> do_try_to_free_pages
> > > >      ---> shrink_zones
> > > >       --->shrink_node
> > > >        ---> shrink_node_memcg
> > > >          ---> shrink_list          <-------loop will happen in this place
> > > [times=1024/32]
> > > >            ---> shrink_page_list
> > >
> > > Can you actually measure this to be the culprit. Because we should
> > > rethink our call path if it is too complicated/deep to perform well.
> > > Adding arbitrary batch sizes doesn't sound like a good way to go to me.
> > 
> > Ok, I will try
> > 
> http://pasted.co/4edbcfff
> 
> This is result from ftrace graph, it maybe prove that the deep call
> path leads to low performance.

Does it? Let's have a look at the condensed output:
  6)               |    try_to_free_mem_cgroup_pages() {
  6)               |      mem_cgroup_select_victim_node() {
  6)   0.320 us    |        mem_cgroup_node_nr_lru_pages();
  6)   0.151 us    |        mem_cgroup_node_nr_lru_pages();
  6)   2.190 us    |      }
  6)               |      do_try_to_free_pages() {
  6)               |        shrink_node() {
  6)               |          shrink_node_memcg() {
  6)               |            shrink_inactive_list() {
  6) + 23.131 us   |              shrink_page_list();
  6) + 33.960 us   |            }
  6) + 39.203 us   |          }
  6)               |          shrink_slab() {
  6) + 72.955 us   |          }
  6) ! 116.529 us  |        }
  6)               |        shrink_node() {
  6)   0.050 us    |          mem_cgroup_iter();
  6)   0.035 us    |          mem_cgroup_low();
  6)               |          shrink_node_memcg() {
  6)   3.955 us    |          }
  6)               |          shrink_slab() {
  6) + 54.296 us   |          }
  6) + 61.502 us   |        }
  6) ! 185.020 us  |      }
  6) ! 188.165 us  |    }

try_to_free_mem_cgroup_pages is the full memcg reclaim path taking
188,165 us. The pure reclaim path is shrink_node and that took 116+61 = 177 us.
So we have 11us spent on the way. Is this really making such a difference?
How does the profile look when we do larger batches?

> And when increase reclaiming page in try_to_free_mem_cgroup_pages, it
> can reduce calling of shrink_slab, which save times, in my cases, page
> caches occupy most memory, slab is little, but shrink_slab will be
> called everytime

OK, that makes more sense! shrink_slab is clearly visible here. It is
more expensive than the page reclaim. This is something to look into.

Thanks!
-- 
Michal Hocko
SUSE Labs
