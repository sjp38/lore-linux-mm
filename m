Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 61E1F6B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:24:44 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l6so150875829wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:24:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r4si29332824wjw.190.2016.04.11.08.24.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 08:24:43 -0700 (PDT)
Subject: Re: [PATCH 1/2] vmscan: consider classzone_idx in compaction_ready
References: <1460357151-25554-1-git-send-email-mhocko@kernel.org>
 <1460357151-25554-2-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570BC1BA.6070904@suse.cz>
Date: Mon, 11 Apr 2016 17:24:42 +0200
MIME-Version: 1.0
In-Reply-To: <1460357151-25554-2-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/11/2016 08:45 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> while playing with the oom detection rework [1] I have noticed
> that my heavy order-9 (hugetlb) load close to OOM ended up in an
> endless loop where the reclaim hasn't made any progress but
> did_some_progress didn't reflect that and compaction_suitable
> was backing off because no zone is above low wmark + 1 << order.
>
> It turned out that this is in fact an old standing bug in compaction_ready
> which ignores the requested_highidx and did the watermark check for
> 0 classzone_idx. This succeeds for zone DMA most of the time as the zone
> is mostly unused because of lowmem protection. This also means that the
> OOM killer wouldn't be triggered for higher order requests even when
> there is no reclaim progress and we essentially rely on order-0 request
> to find this out. This has been broken in one way or another since
> fe4b1b244bdb ("mm: vmscan: when reclaiming for compaction, ensure there
> are sufficient free pages available") but only since 7335084d446b ("mm:
> vmscan: do not OOM if aborting reclaim to start compaction") we are not
> invoking the OOM killer based on the wrong calculation.
>
> Propagate requested_highidx down to compaction_ready and use it for both
> the watermak check and compaction_suitable to fix this issue.
>
> [1] http://lkml.kernel.org/r/1459855533-4600-1-git-send-email-mhocko@kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
