Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2D06B02A4
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 08:40:00 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c206so9470220wme.3
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 05:40:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si4464647wrh.278.2017.01.19.05.39.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 05:39:58 -0800 (PST)
Subject: Re: [RFC PATCH 5/5] mm/compaction: run the compaction whenever
 fragmentation ratio exceeds the threshold
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1484291673-2239-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <835a0481-33ae-94fd-b84d-0ea394d66866@suse.cz>
Date: Thu, 19 Jan 2017 14:39:54 +0100
MIME-Version: 1.0
In-Reply-To: <1484291673-2239-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/13/2017 08:14 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Until now, we invoke the compaction whenever allocation request is stall
> due to non-existence of the high order freepage. It is effective since we
> don't need a high order freepage in usual and cost of maintaining
> high order freepages is quite high. However, it increases latency of high
> order allocation request and decreases success rate if allocation request
> cannot use the reclaim/compaction. Since there are some workloads that
> require high order freepage to boost the performance, it is a matter of
> trade-off that we prepares high order freepage in advance. Now, there is
> no way to prepare high order freepages, we cannot consider this trade-off.
> Therefore, this patch introduces a way to invoke the compaction when
> necessary to manage trade-off.
> 
> Implementation is so simple. There is a theshold to invoke the full
> compaction. If fragmentation ratio reaches this threshold in given order,
> we ask the full compaction to kcompactd with a hope that it restores
> fragmentation ratio.
> 
> If fragmentation ratio is unchanged or worse after full compaction,
> further compaction attempt would not be useful. So, this patch
> stops the full compaction in this case until the situation changes
> to avoid useless compaction effort.
> 
> Now, there is no scientific code to detect the situation change.
> kcompactd's full compaction would be re-enabled when lower order
> triggers kcompactd wake-up or time limit (a second) is passed.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

So, as you expected, I'm not thrilled about the tunables :) And also the
wakeups from allocator hotpaths. Otherwise I'll wait with discussing
details until we get some consensus on usecases and metrics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
