Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 53BA66B007D
	for <linux-mm@kvack.org>; Wed,  7 May 2014 17:47:09 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so1727548pab.7
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:47:08 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id xf3si14406620pab.425.2014.05.07.14.47.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 14:47:08 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so1770406pab.3
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:47:08 -0700 (PDT)
Date: Wed, 7 May 2014 14:47:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/2] mm/compaction: avoid rescanning pageblocks in
 isolate_freepages
In-Reply-To: <1399464550-26447-2-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.02.1405071446520.8454@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com> <1399464550-26447-1-git-send-email-vbabka@suse.cz> <1399464550-26447-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, 7 May 2014, Vlastimil Babka wrote:

> The compaction free scanner in isolate_freepages() currently remembers PFN of
> the highest pageblock where it successfully isolates, to be used as the
> starting pageblock for the next invocation. The rationale behind this is that
> page migration might return free pages to the allocator when migration fails
> and we don't want to skip them if the compaction continues.
> 
> Since migration now returns free pages back to compaction code where they can
> be reused, this is no longer a concern. This patch changes isolate_freepages()
> so that the PFN for restarting is updated with each pageblock where isolation
> is attempted. Using stress-highalloc from mmtests, this resulted in 10%
> reduction of the pages scanned by the free scanner.
> 
> Note that the somewhat similar functionality that records highest successful
> pageblock in zone->compact_cached_free_pfn, remains unchanged. This cache is
> used when the whole compaction is restarted, not for multiple invocations of
> the free scanner during single compaction.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
