Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2E41C6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 10:48:43 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id f198so149059264wme.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:48:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a4si25014397wjv.9.2016.04.11.07.48.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 07:48:42 -0700 (PDT)
Subject: Re: [PATCH 10/11] mm, oom: protect !costly allocations some more
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-11-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570BB948.6000900@suse.cz>
Date: Mon, 11 Apr 2016 16:48:40 +0200
MIME-Version: 1.0
In-Reply-To: <1459855533-4600-11-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/05/2016 01:25 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> should_reclaim_retry will give up retries for higher order allocations
> if none of the eligible zones has any requested or higher order pages
> available even if we pass the watermak check for order-0. This is done
> because there is no guarantee that the reclaimable and currently free
> pages will form the required order.
>
> This can, however, lead to situations were the high-order request (e.g.
> order-2 required for the stack allocation during fork) will trigger
> OOM too early - e.g. after the first reclaim/compaction round. Such a
> system would have to be highly fragmented and there is no guarantee
> further reclaim/compaction attempts would help but at least make sure
> that the compaction was active before we go OOM and keep retrying even
> if should_reclaim_retry tells us to oom if
> 	- the last compaction round backed off or
> 	- we haven't completed at least MAX_COMPACT_RETRIES active
> 	  compaction rounds.
>
> The first rule ensures that the very last attempt for compaction
> was not ignored while the second guarantees that the compaction has done
> some work. Multiple retries might be needed to prevent occasional
> pigggy packing of other contexts to steal the compacted pages before
> the current context manages to retry to allocate them.
>
> compaction_failed() is taken as a final word from the compaction that
> the retry doesn't make much sense. We have to be careful though because
> the first compaction round is MIGRATE_ASYNC which is rather weak as it
> ignores pages under writeback and gives up too easily in other
> situations. We therefore have to make sure that MIGRATE_SYNC_LIGHT mode
> has been used before we give up. With this logic in place we do not have
> to increase the migration mode unconditionally and rather do it only if
> the compaction failed for the weaker mode. A nice side effect is that
> the stronger migration mode is used only when really needed so this has
> a potential of smaller latencies in some cases.
>
> Please note that the compaction doesn't tell us much about how
> successful it was when returning compaction_made_progress so we just
> have to blindly trust that another retry is worthwhile and cap the
> number to something reasonable to guarantee a convergence.
>
> If the given number of successful retries is not sufficient for a
> reasonable workloads we should focus on the collected compaction
> tracepoints data and try to address the issue in the compaction code.
> If this is not feasible we can increase the retries limit.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
