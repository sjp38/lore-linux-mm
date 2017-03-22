Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7976B0038
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 10:44:22 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u108so40593295wrb.3
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 07:44:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f18si2508312wrc.171.2017.03.22.07.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 07:44:21 -0700 (PDT)
Date: Wed, 22 Mar 2017 10:43:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v5] mm/vmscan: more restrictive condition for retry in
 do_try_to_free_pages
Message-ID: <20170322144349.GA22107@cmpxchg.org>
References: <1490191893-5923-1-git-send-email-ysxie@foxmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1490191893-5923-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <ysxie@foxmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, qiuxishi@huawei.com

On Wed, Mar 22, 2017 at 10:11:33PM +0800, Yisheng Xie wrote:
> From: Yisheng Xie <xieyisheng1@huawei.com>
> 
> By reviewing code, I find that when enter do_try_to_free_pages, the
> may_thrash is always clear, and it will retry shrink zones to tap
> cgroup's reserves memory by setting may_thrash when the former
> shrink_zones reclaim nothing.
> 
> However, when memcg is disabled or on legacy hierarchy, or there do not
> have any memcg protected by low limit, it should not do this useless
> retry at all, for we do not have any cgroup's reserves memory to tap,
> and we have already done hard work but made no progress, which as Michal
> pointed out in former version, we are trying hard to control the retry
> logical of page alloctor, and the current additional round of reclaim is
> just lame.
> 
> Therefore, to avoid this unneeded retrying and make code more readable,
> we remove the may_thrash field in scan_control, instead, introduce
> memcg_low_reclaim and memcg_low_skipped, and only retry when
> memcg_low_skipped, by setting memcg_low_reclaim.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Suggested-by: Shakeel Butt <shakeelb@google.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks Yisheng!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
