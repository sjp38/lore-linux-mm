Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB2FF6B0261
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:59:17 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id x79so7946564lff.2
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 02:59:17 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id wt1si47782707wjc.140.2016.10.18.02.59.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 02:59:15 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 5E706986C3
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:59:15 +0000 (UTC)
Date: Tue, 18 Oct 2016 10:59:12 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] bdi flusher should not be throttled here when it fall
 into buddy slow path
Message-ID: <20161018095912.GD22174@techsingularity.net>
References: <1476774765-21130-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1476774765-21130-1-git-send-email-zhouxianrong@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, mingo@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, vbabka@suse.cz, mhocko@suse.com, vdavydov.dev@gmail.com, minchan@kernel.org, riel@redhat.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com

On Tue, Oct 18, 2016 at 03:12:45PM +0800, zhouxianrong@huawei.com wrote:
> From: z00281421 <z00281421@notesmail.huawei.com>
> 
> bdi flusher may enter page alloc slow path due to writepage and kmalloc. 
> in that case the flusher as a direct reclaimer should not be throttled here
> because it can not to reclaim clean file pages or anaonymous pages
> for next moment; furthermore writeback rate of dirty pages would be
> slow down and other direct reclaimers and kswapd would be affected.
> bdi flusher should be iosceduled by get_request rather than here.
> 
> Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>

What does this patch do that PF_LESS_THROTTLE is not doing already if
there is an underlying BDI?

There have been a few patches like this recently that look like they might
do something useful but are subtle. They really should be accompanied by
a test case and data showing they either fix a functional issue (machine
livelocking due to writeback not making progress) or a performance issue.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
