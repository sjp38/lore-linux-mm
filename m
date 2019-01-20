Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CFC778E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 13:12:54 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m19so6897143edc.6
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 10:12:54 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18si1699757edh.385.2019.01.20.10.12.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 10:12:53 -0800 (PST)
Date: Sun, 20 Jan 2019 19:12:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/5] fix offline memcgroup still hold in memory
Message-ID: <20190120181250.GJ4087@dhcp22.suse.cz>
References: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiongchun Duan <duanxiongchun@bytedance.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, shy828301@gmail.com, tj@kernel.org, hannes@cmpxchg.org, zhangyongsu@bytedance.com, liuxiaozhou@bytedance.com, zhengfeiran@bytedance.com, wangdongdong.6@bytedance.com

On Sat 19-01-19 22:30:16, Xiongchun Duan wrote:
> we find that in huge memory system frequent creat creation and deletion
> memcgroup make the system leave lots of offline memcgroup.we had seen 100000 
> unrelease offline memcgroup in our system(512G memory).
> 
> this memcgroup hold because some memory page still charged.
> so we try to Multiple interval call force_empty to reclaim this memory page.
> 
> after applying those patchs,in our system,the unrelease offline memcgroup
> was reduced from 100000 to 100.

I've stopped at patch 3 because all these patches really ask for much
more justification. Please note that each patch should explain the
problem, the proposed solution on highlevel and explain why it is done
so. The cover letter should also explain the underlying problem.
What does prevent those memcgs to be reclaim completely on force_empty?

Besides that, I do agree that the current implementation of force_empty
is rather suboptimal. There is a hardcoded retry loop counter which
doesn't really make much sense to me. The context is interruptible and
there is no real reason to have a retry count limit. If a userspace want
to implement a policy it can do it from userspace - e.g.

timeout 2m echo 0 > force_empty

Last but not least a force_empty on offline has been proposed recently
http://lkml.kernel.org/r/1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com
I haven't followed up on that discussion yet but it is always better to
check what where arguments there and explain why this approach is any
better/different.

> Xiongchun Duan (5):
>   Memcgroup: force empty after memcgroup offline
>   Memcgroup: Add timer to trigger workqueue
>   Memcgroup:add a global work
>   Memcgroup:Implement force empty work function
>   Memcgroup:add cgroup fs to show offline memcgroup status
> 
>  Documentation/cgroup-v1/memory.txt |   7 +-
>  Documentation/sysctl/kernel.txt    |  10 ++
>  include/linux/memcontrol.h         |  11 ++
>  kernel/sysctl.c                    |   9 ++
>  mm/memcontrol.c                    | 271 +++++++++++++++++++++++++++++++++++++
>  5 files changed, 306 insertions(+), 2 deletions(-)
> 
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
