Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0144E6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 05:25:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e201so39711656wme.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:25:08 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id j3si37513760wjz.119.2016.05.16.02.25.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 02:25:07 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id v200so13969745wmv.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:25:07 -0700 (PDT)
Date: Mon, 16 May 2016 11:25:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 13/13] mm, compaction: fix and improve watermark handling
Message-ID: <20160516092505.GE23146@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-14-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-14-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 10-05-16 09:36:03, Vlastimil Babka wrote:
> Compaction has been using watermark checks when deciding whether it was
> successful, and whether compaction is at all suitable. There are few problems
> with these checks.
> 
> - __compact_finished() uses low watermark in a check that has to pass if
>   the direct compaction is to finish and allocation should succeed. This is
>   too pessimistic, as the allocation will typically use min watermark. It
>   may happen that during compaction, we drop below the low watermark (due to
>   parallel activity), but still form the target high-order page. By checking
>   against low watermark, we might needlessly continue compaction. After this
>   patch, the check uses direct compactor's alloc_flags to determine the
>   watermark, which is effectively the min watermark.

OK, this makes some sense. It would be great if we could have at least
some clarification why the low wmark has been used previously. Probably
Mel can remember?

> - __compaction_suitable has the same issue in the check whether the allocation
>   is already supposed to succeed and we don't need to compact. Fix it the same
>   way.
>
> - __compaction_suitable() then checks the low watermark plus a (2 << order) gap
>   to decide if there's enough free memory to perform compaction. This check

And this was a real head scratcher when I started looking into the
compaction recently. Why do we need to be above low watermark to even
start compaction. Compaction uses additional memory only for a short
period of time and then releases the already migrated pages.

>   uses direct compactor's alloc_flags, but that's wrong. If alloc_flags doesn't
>   include ALLOC_CMA, we might fail the check, even though the freepage
>   isolation isn't restricted outside of CMA pageblocks. On the other hand,
>   alloc_flags may indicate access to memory reserves, making compaction proceed
>   and then fail watermark check during freepage isolation, which doesn't pass
>   alloc_flags. The fix here is to use fixed ALLOC_CMA flags in the
>   __compaction_suitable() check.

This makes my head hurt. Whut?

> - __isolate_free_page uses low watermark check to decide if free page can be
>   isolated. It also doesn't use ALLOC_CMA, so add it for the same reasons.

Why do we check the watermark at all? What would happen if this obscure
if (!is_migrate_isolate(mt)) was gone? I remember I put some tracing
there and it never hit for me even when I was testing close to OOM
conditions. Maybe an earlier check bailed out but this code path looks
really obscure so it should either deserve a large fat comment or to
die.

> - The use of low watermark checks in __compaction_suitable() and
>   __isolate_free_page does perhaps make sense for high-order allocations where
>   more freepages increase the chance of success, and we can typically fail
>   with some order-0 fallback when the system is struggling. But for low-order
>   allocation, forming the page should not be that hard. So using low watermark
>   here might just prevent compaction from even trying, and eventually lead to
>   OOM killer even if we are above min watermarks. So after this patch, we use
>   min watermark for non-costly orders in these checks, by passing the
>   alloc_flags parameter to split_page() and __isolate_free_page().

OK, so if IIUC costly high order requests even shouldn't try when we are
below watermark (unless they are __GFP_REPEAT which would get us to a
stronger compaction mode/priority) and that would reclaim us over low
wmark and go on. Is that what you are saying? This makes some sense but
then let's have a _single_ place to check the watermak please. This
checks at few different levels is just subtle as hell and error prone
likewise.

> To sum up, after this patch, the kernel should in some situations finish
> successful direct compaction sooner, prevent compaction from starting when it's
> not needed, proceed with compaction when free memory is in CMA pageblocks, and
> for non-costly orders, prevent OOM killing or excessive reclaim when free
> memory is between the min and low watermarks.

Could you please split this patch into three(?) parts. One to remove as many
wmark checks as possible, move low wmark to min for !costly high orders
and finally the cma part which I fail to understand...

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
