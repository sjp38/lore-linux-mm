Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3D12B6B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 09:47:28 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so15958397wiv.11
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 06:47:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j9si12420198wjf.10.2014.11.27.06.47.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Nov 2014 06:47:27 -0800 (PST)
Date: Thu, 27 Nov 2014 15:47:25 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20141127144725.GB19157@dhcp22.suse.cz>
References: <1413799924-17946-1-git-send-email-minchan@kernel.org>
 <1413799924-17946-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413799924-17946-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

[Late but I didn't get to this soone - I hope this is still up-to-date
version]

On Mon 20-10-14 19:11:58, Minchan Kim wrote:
> Linux doesn't have an ability to free pages lazy while other OS
> already have been supported that named by madvise(MADV_FREE).
> 
> The gain is clear that kernel can discard freed pages rather than
> swapping out or OOM if memory pressure happens.
> 
> Without memory pressure, freed pages would be reused by userspace
> without another additional overhead(ex, page fault + allocation
> + zeroing).
> 
> How to work is following as.
> 
> When madvise syscall is called, VM clears dirty bit of ptes of
> the range. If memory pressure happens, VM checks dirty bit of
> page table and if it found still "clean", it means it's a
> "lazyfree pages" so VM could discard the page instead of swapping out.
> Once there was store operation for the page before VM peek a page
> to reclaim, dirty bit is set so VM can swap out the page instead of
> discarding.

Is there any patch for madvise man page? I guess the semantic will be
same/similar to FreeBSD:
http://www.freebsd.org/cgi/man.cgi?query=madvise&sektion=2

I guess the changelog should be more specific that this is only for the
private MAP_ANON mappings (same applies to the patch for man).

> Firstly, heavy users would be general allocators(ex, jemalloc,
> tcmalloc and hope glibc supports it) and jemalloc/tcmalloc already
> have supported the feature for other OS(ex, FreeBSD)
> 
[...]
> 
> Cc: Michael Kerrisk <mtk.manpages@gmail.com>
> Cc: Linux API <linux-api@vger.kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Jason Evans <je@fb.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Michal Hocko <mhocko@suse.cz>
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
