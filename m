Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 170646B0262
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 19:39:05 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id os4so59012726pac.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 16:39:05 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id i13si8022131pgd.184.2016.10.12.16.39.03
        for <linux-mm@kvack.org>;
        Wed, 12 Oct 2016 16:39:04 -0700 (PDT)
Date: Thu, 13 Oct 2016 08:39:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 3/4] mm: try to exhaust highatomic reserve before the
 OOM
Message-ID: <20161012233901.GA30745@bbox>
References: <1476259429-18279-1-git-send-email-minchan@kernel.org>
 <1476259429-18279-4-git-send-email-minchan@kernel.org>
 <20161012083449.GD17128@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161012083449.GD17128@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

Hi Michal,

On Wed, Oct 12, 2016 at 10:34:50AM +0200, Michal Hocko wrote:
> Looks much better. Thanks! I am wondering whether we want to have this
> marked for stable. The patch is quite non-intrusive and fires only when
> we are really OOM. It is definitely better to try harder than go and
> disrupt the system by the OOM killer. So I would add
> Fixes: 0aaa29a56e4f ("mm, page_alloc: reserve pageblocks for high-order atomic allocations on demand")
> Cc: stable # 4.4+

Thanks for the information.

> 
> The backport will look slightly different for kernels prior 4.6 because
> we do not have should_reclaim_retry yet but the check might hook right
> before __alloc_pages_may_oom.

As I just got one report and I didn't see similar problem in LKML
recently, I didn't mark it to the stable given that patchset size
in v1. However, with review, it becomes simple(Thanks, Michal and
Vlastimil) and I should admit my ladar is too limited so if you think
it's worth, I don't mind.

For the stable, {3,4}/4 are must but once we decide, I want to backport
all patches {1-4}/4 because without {1,2}, nr_reserved_highatomic mismatch
can happen so that unreserve logic doesn't work until force logic is
triggered when no_progress_loops is greater than MAX_RECLAIM_RETRIES.
It happend very easily in my test.
Withtout {1,2}, it works but looks no-good for me.


> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
