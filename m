Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C98226B0010
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 06:34:12 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id k4-v6so7429466pls.15
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 03:34:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3si5857392pgr.744.2018.03.23.03.34.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 03:34:11 -0700 (PDT)
Date: Fri, 23 Mar 2018 11:34:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memcontrol.c: speed up to force empty a memory cgroup
Message-ID: <20180323103407.GP23100@dhcp22.suse.cz>
References: <1521448170-19482-1-git-send-email-lirongqing@baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521448170-19482-1-git-send-email-lirongqing@baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li RongQing <lirongqing@baidu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, hannes@cmpxchg.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Mon 19-03-18 16:29:30, Li RongQing wrote:
> mem_cgroup_force_empty() tries to free only 32 (SWAP_CLUSTER_MAX) pages
> on each iteration, if a memory cgroup has lots of page cache, it will
> take many iterations to empty all page cache, so increase the reclaimed
> number per iteration to speed it up. same as in mem_cgroup_resize_limit()
> 
> a simple test show:
> 
>   $dd if=aaa  of=bbb  bs=1k count=3886080
>   $rm -f bbb
>   $time echo 100000000 >/cgroup/memory/test/memory.limit_in_bytes
>
> Before: 0m0.252s ===> after: 0m0.178s

One more note. I have only now realized that increasing the patch size
might have another negative side effect. Memcg reclaim bails out early
when the required target has been reclaimed and so we might skip memcgs
in the hierarchy and could end up hamering one child in the hierarchy
much more than others. Our current code is not ideal and we workaround
this by a smaller target and caching the last reclaimed memcg so the
imbalance is not so visible at least.

This is not something that couldn't be fixed and maybe 1M chunk would be
acceptable as well. I dunno. Let's focus on the main bottleneck first
before we start doing these changes though.
-- 
Michal Hocko
SUSE Labs
