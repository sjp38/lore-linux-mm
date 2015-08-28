Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id CBC246B0254
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 12:36:21 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so29305059pad.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 09:36:21 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id st10si10763302pab.215.2015.08.28.09.36.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 09:36:20 -0700 (PDT)
Date: Fri, 28 Aug 2015 19:36:11 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150828163611.GI9610@esperanza>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1440775530-18630-4-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hi Tejun,

On Fri, Aug 28, 2015 at 11:25:29AM -0400, Tejun Heo wrote:
> Currently, try_charge() tries to reclaim memory directly when the high
> limit is breached; however, this has a couple issues.
> 
> * try_charge() can be invoked from any in-kernel allocation site and
>   reclaim path may use considerable amount of stack.  This can lead to
>   stack overflows which are extremely difficult to reproduce.

IMO this paragraph does not justify this patch at all, because one will
still invoke direct reclaim from try_charge() on hitting the hard limit.

> 
> * If the allocation doesn't have __GFP_WAIT, direct reclaim is
>   skipped.  If a process performs only speculative allocations, it can
>   blow way past the high limit.  This is actually easily reproducible
>   by simply doing "find /".  VFS tries speculative !__GFP_WAIT
>   allocations first, so as long as there's memory which can be
>   consumed without blocking, it can keep allocating memory regardless
>   of the high limit.

I think there shouldn't normally occur a lot of !__GFP_WAIT allocations
in a row - they should still alternate with normal __GFP_WAIT
allocations. Yes, that means we can breach memory.high threshold for a
short period of time, but it isn't a hard limit, so it looks perfectly
fine to me.

I tried to run `find /` over ext4 in a cgroup with memory.high set to
32M and kmem accounting enabled. With such a setup memory.current never
got higher than 33152K, which is only 384K greater than the memory.high.
Which FS did you use?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
