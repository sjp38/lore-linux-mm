Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48C236B0389
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 01:16:08 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id u188so12721329qkc.1
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 22:16:08 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i10si4960180qtg.210.2017.02.23.22.16.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 22:16:07 -0800 (PST)
Date: Thu, 23 Feb 2017 22:15:50 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V4 3/6] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170224061549.GB86912@brenorobert-mbp.dhcp.thefacebook.com>
References: <cover.1487788131.git.shli@fb.com>
 <a1a28aa85280a7b3fd6145604eed4132228bd6d1.1487788131.git.shli@fb.com>
 <20170224014939.GC9818@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170224014939.GC9818@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 24, 2017 at 10:49:39AM +0900, Minchan Kim wrote:
> On Wed, Feb 22, 2017 at 10:50:41AM -0800, Shaohua Li wrote:
> > madv MADV_FREE indicate pages are 'lazyfree'. They are still anonymous
> > pages, but they can be freed without pageout. To destinguish them
> > against normal anonymous pages, we clear their SwapBacked flag.
> > 
> > MADV_FREE pages could be freed without pageout, so they pretty much like
> > used once file pages. For such pages, we'd like to reclaim them once
> > there is memory pressure. Also it might be unfair reclaiming MADV_FREE
> > pages always before used once file pages and we definitively want to
> > reclaim the pages before other anonymous and file pages.
> > 
> > To speed up MADV_FREE pages reclaim, we put the pages into
> > LRU_INACTIVE_FILE list. The rationale is LRU_INACTIVE_FILE list is tiny
> > nowadays and should be full of used once file pages. Reclaiming
> > MADV_FREE pages will not have much interfere of anonymous and active
> > file pages. And the inactive file pages and MADV_FREE pages will be
> > reclaimed according to their age, so we don't reclaim too many MADV_FREE
> > pages too. Putting the MADV_FREE pages into LRU_INACTIVE_FILE_LIST also
> > means we can reclaim the pages without swap support. This idea is
> > suggested by Johannes.
> > 
> > This patch doesn't move MADV_FREE pages to LRU_INACTIVE_FILE list yet to
> > avoid bisect failure, next patch will do it.
> > 
> > The patch is based on Minchan's original patch.
> > 
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> 
> Other than that Johannes pointed out, code itself looks good to me.
> However, I hope to merge this patch with next one.
> It's enough simple to merge, change behavior(about deactivation),
> mark_page_lazyfree is introduced but there is no callsite to use it
> in this patch.
> 
> I don't think it's worth to separate.

I think it's more clear in this way, doing one thing in one patch.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
