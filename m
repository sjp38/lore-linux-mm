Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 28DDA6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:55:03 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p66so35721139wmp.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 01:55:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n19si44877261wjr.18.2015.12.14.01.55.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Dec 2015 01:55:01 -0800 (PST)
Subject: Re: [PATCH v3 7/7] mm/compaction: replace compaction deferring with
 compaction limit
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1449126681-19647-8-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <566E91F4.3000709@suse.cz>
Date: Mon, 14 Dec 2015 10:55:00 +0100
MIME-Version: 1.0
In-Reply-To: <1449126681-19647-8-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/03/2015 08:11 AM, Joonsoo Kim wrote:
> Compaction deferring effectively reduces compaction overhead if
> compaction success isn't expected. But, it is implemented that
> skipping a number of compaction requests until compaction is re-enabled.
> Due to this implementation, unfortunate compaction requestor will get
> whole compaction overhead unlike others have zero overhead. And, after
> deferring start to work, even if compaction success possibility is
> restored, we should skip to compaction in some number of times.
>
> This patch try to solve above problem by using compaction limit.
> Instead of imposing compaction overhead to one unfortunate requestor,
> compaction limit distributes overhead to all compaction requestors.
> All requestors have a chance to migrate some amount of pages and
> after limit is exhausted compaction will be stopped. This will fairly
> distributes overhead to all compaction requestors. And, because we don't
> defer compaction request, someone will succeed to compact as soon as
> possible if compaction success possiblility is restored.
>
> Following is whole workflow enabled by this change.
>
> - if sync compaction fails, compact_order_failed is set to current order
> - if it fails again, compact_defer_shift is adjusted
> - with positive compact_defer_shift, migration_scan_limit is assigned and
> compaction limit is activated
> - if compaction limit is activated, compaction would be stopped when
> migration_scan_limit is exhausted
> - when success, compact_defer_shift and compact_order_failed is reset and
> compaction limit is deactivated
> - compact_defer_shift can be grown up to COMPACT_MAX_DEFER_SHIFT
>
> Most of changes are mechanical ones to remove compact_considered which
> is not needed now. Note that, after restart, compact_defer_shift is
> subtracted by 1 to avoid invoking __reset_isolation_suitable()
> repeatedly.
>
> I tested this patch on my compaction benchmark and found that high-order
> allocation latency is evenly distributed and there is no latency spike
> in the situation where compaction success isn't possible.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Looks fine overal, looking forward to next version :) (due to changes 
expected in preceding patches, I didn't review the code fully now).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
