Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 874AB6B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 04:51:33 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so42868232wid.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 01:51:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id at3si10695785wjc.201.2015.08.24.01.51.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 01:51:32 -0700 (PDT)
Subject: Re: [PATCH] mm/compaction: correct to flush migrated pages if
 pageblock skip happens
References: <1440129419-30023-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DADB11.6070000@suse.cz>
Date: Mon, 24 Aug 2015 10:51:29 +0200
MIME-Version: 1.0
In-Reply-To: <1440129419-30023-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On 08/21/2015 05:56 AM, Joonsoo Kim wrote:
> We cache isolate_start_pfn before entering isolate_migratepages().
> If pageblock is skipped in isolate_migratepages() due to whatever reason,
> cc->migrate_pfn could be far from isolate_start_pfn hence flushing pages
> that were freed happens. For example, following scenario can be possible.
>
> - assume order-9 compaction, pageblock order is 9
> - start_isolate_pfn is 0x200
> - isolate_migratepages()
>    - skip a number of pageblocks
>    - start to isolate from pfn 0x600
>    - cc->migrate_pfn = 0x620
>    - return
> - last_migrated_pfn is set to 0x200
> - check flushing condition
>    - current_block_start is set to 0x600
>    - last_migrated_pfn < current_block_start then do useless flush
>
> This wrong flush would not help the performance and success rate so
> this patch try to fix it. One simple way to know exact position
> where we start to isolate migratable pages is that we cache it
> in isolate_migratepages() before entering actual isolation. This patch
> implements it and fix the problem.

Yeah, that should work.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
