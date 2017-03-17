Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70EB76B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:08:14 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y51so14954447wry.6
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:08:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 135si4190390wmh.53.2017.03.17.11.08.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 11:08:13 -0700 (PDT)
Date: Fri, 17 Mar 2017 19:08:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mm/vmscan: more restrictive condition for retry in
 do_try_to_free_pages
Message-ID: <20170317180809.GB23957@dhcp22.suse.cz>
References: <1489577808-19228-1-git-send-email-xieyisheng1@huawei.com>
 <20170317145020.GA8106@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170317145020.GA8106@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, riel@redhat.com, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com

On Fri 17-03-17 10:50:20, Johannes Weiner wrote:
> On Wed, Mar 15, 2017 at 07:36:48PM +0800, Yisheng Xie wrote:
> > By reviewing code, I find that when enter do_try_to_free_pages, the
> > may_thrash is always clear, and it will retry shrink zones to tap
> > cgroup's reserves memory by setting may_thrash when the former
> > shrink_zones reclaim nothing.
> > 
> > However, when memcg is disabled or on legacy hierarchy, or there do not
> > have any memcg protected by low limit, it should not do this useless retry
> > at all, for we do not have any cgroup's reserves memory to tap, and we
> > have already done hard work but made no progress.
> > 
> > To avoid this unneeded retrying, add a new field in scan_control named
> > memcg_low_protection, set it if there is any memcg protected by low limit
> > and only do the retry when memcg_low_protection is set while may_thrash
> > is clear.
> > 
> > Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> > Suggested-by: Michal Hocko <mhocko@kernel.org>
> > Suggested-by: Shakeel Butt <shakeelb@google.com>
> > Reviewed-by: Shakeel Butt <shakeelb@google.com>
> 
> I don't see the point of this patch. It adds more code just to
> marginally optimize a near-OOM cold path.

The current behavior is surprising and not really desirable when we want
to control the retry logic from the page allocator. So I do not think
that the additional 5 lines of code would be unbearable burden or
maintenance cost. I am not saying the patch adds any break through but
it is not pointless either.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
