Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id F07986B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:33:22 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id z143so48943149ywz.7
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:33:22 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id b79si705539ywe.85.2017.02.10.09.33.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 09:33:22 -0800 (PST)
Date: Fri, 10 Feb 2017 09:33:04 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V2 2/7] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170210173303.GB86050@shli-mbp.local>
References: <cover.1486163864.git.shli@fb.com>
 <3914c9f53c343357c39cb891210da31aa30ad3a9.1486163864.git.shli@fb.com>
 <20170210130236.GK10893@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170210130236.GK10893@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 10, 2017 at 02:02:36PM +0100, Michal Hocko wrote:
> On Fri 03-02-17 15:33:18, Shaohua Li wrote:
> > Userspace indicates MADV_FREE pages could be freed without pageout, so
> > it pretty much likes used once file pages. For such pages, we'd like to
> > reclaim them once there is memory pressure. Also it might be unfair
> > reclaiming MADV_FREE pages always before used once file pages and we
> > definitively want to reclaim the pages before other anonymous and file
> > pages.
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
> > We also clear the pages SwapBacked flag to indicate they are MADV_FREE
> > pages.
> 
> I like this. I have expected this to be more convoluted but it looks
> quite straightforward. I didn't get to do a really deep review and add
> my acked-by but from a quick look there do not seem to be any surprises.
> I was worried about vmstat accounting. There are some places which
> isolate page from LRU and account based on the LRU and later use
> page_is_file_cache to tell which LRU this was. This should work fine,
> though, because you never touch pages which are off-lru.
> 
> That being said I do not see any major issues. There might be some minor
> things and this will need a lot of testing but it is definitely a move
> into right direction. I hope to do the deeper review after I get back
> from vacation (20th Feb).

Sweat! Thanks for your time! 
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> 
> I guess
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> would be appropriate.

Sure, will add in next post and will add 'the patches are based on Minchan's
patches' too.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
