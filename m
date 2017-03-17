Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1691F6B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 10:50:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g8so4133218wmg.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 07:50:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u93si11438845wrb.292.2017.03.17.07.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 07:50:40 -0700 (PDT)
Date: Fri, 17 Mar 2017 10:50:20 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v4] mm/vmscan: more restrictive condition for retry in
 do_try_to_free_pages
Message-ID: <20170317145020.GA8106@cmpxchg.org>
References: <1489577808-19228-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489577808-19228-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com

On Wed, Mar 15, 2017 at 07:36:48PM +0800, Yisheng Xie wrote:
> By reviewing code, I find that when enter do_try_to_free_pages, the
> may_thrash is always clear, and it will retry shrink zones to tap
> cgroup's reserves memory by setting may_thrash when the former
> shrink_zones reclaim nothing.
> 
> However, when memcg is disabled or on legacy hierarchy, or there do not
> have any memcg protected by low limit, it should not do this useless retry
> at all, for we do not have any cgroup's reserves memory to tap, and we
> have already done hard work but made no progress.
> 
> To avoid this unneeded retrying, add a new field in scan_control named
> memcg_low_protection, set it if there is any memcg protected by low limit
> and only do the retry when memcg_low_protection is set while may_thrash
> is clear.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Suggested-by: Shakeel Butt <shakeelb@google.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

I don't see the point of this patch. It adds more code just to
marginally optimize a near-OOM cold path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
