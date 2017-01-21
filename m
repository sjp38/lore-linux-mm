Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EBC186B0253
	for <linux-mm@kvack.org>; Sat, 21 Jan 2017 07:22:34 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so134476238pfb.7
        for <linux-mm@kvack.org>; Sat, 21 Jan 2017 04:22:34 -0800 (PST)
Received: from out0-156.mail.aliyun.com (out0-156.mail.aliyun.com. [140.205.0.156])
        by mx.google.com with ESMTP id c78si9742424pfb.0.2017.01.21.04.22.33
        for <linux-mm@kvack.org>;
        Sat, 21 Jan 2017 04:22:33 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170120103843.24587-1-vbabka@suse.cz>
In-Reply-To: <20170120103843.24587-1-vbabka@suse.cz>
Subject: Re: [PATCH v2 0/4] fix premature OOM regression in 4.7+ due to cpuset races
Date: Sat, 21 Jan 2017 20:22:24 +0800
Message-ID: <003c01d273e1$0676cad0$13646070$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Mel Gorman' <mgorman@techsingularity.net>, 'Michal Hocko' <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Friday, January 20, 2017 6:39 PM Vlastimil Babka wrote: 
> 
> Changes since v1:
> - add/remove comments per Michal Hocko and Hillf Danton
> - move no_zone: label in patch 3 so we don't miss part of ac initialization
> 
> This is v2 of my attempt to fix the recent report based on LTP cpuset stress
> test [1]. The intention is to go to stable 4.9 LTSS with this, as triggering
> repeated OOMs is not nice. That's why the patches try to be not too intrusive.
> 
> Unfortunately why investigating I found that modifying the testcase to use
> per-VMA policies instead of per-task policies will bring the OOM's back, but
> that seems to be much older and harder to fix problem. I have posted a RFC [2]
> but I believe that fixing the recent regressions has a higher priority.
> 
> Longer-term we might try to think how to fix the cpuset mess in a better and
> less error prone way. I was for example very surprised to learn, that cpuset
> updates change not only task->mems_allowed, but also nodemask of mempolicies.
> Until now I expected the parameter to alloc_pages_nodemask() to be stable.
> I wonder why do we then treat cpusets specially in get_page_from_freelist()
> and distinguish HARDWALL etc, when there's unconditional intersection between
> mempolicy and cpuset. I would expect the nodemask adjustment for saving
> overhead in g_p_f(), but that clearly doesn't happen in the current form.
> So we have both crazy complexity and overhead, AFAICS.
> 
> [1] https://lkml.kernel.org/r/CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com
> [2] https://lkml.kernel.org/r/7c459f26-13a6-a817-e508-b65b903a8378@suse.cz
> 
> Vlastimil Babka (4):
>   mm, page_alloc: fix check for NULL preferred_zone
>   mm, page_alloc: fix fast-path race with cpuset update or removal
>   mm, page_alloc: move cpuset seqcount checking to slowpath
>   mm, page_alloc: fix premature OOM when racing with cpuset mems update
> 
>  include/linux/mmzone.h |  6 ++++-
>  mm/page_alloc.c        | 68 ++++++++++++++++++++++++++++++++++----------------
>  2 files changed, 52 insertions(+), 22 deletions(-)
> 
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
