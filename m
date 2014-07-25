Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 370606B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:35:57 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so911497wiv.13
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 05:35:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cd10si17723897wjc.14.2014.07.25.05.35.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 05:35:50 -0700 (PDT)
Date: Fri, 25 Jul 2014 13:35:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V4 10/15] mm, compaction: remember position within
 pageblock in free pages scanner
Message-ID: <20140725123532.GE10819@suse.de>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
 <1405518503-27687-11-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1405518503-27687-11-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>

On Wed, Jul 16, 2014 at 03:48:18PM +0200, Vlastimil Babka wrote:
> Unlike the migration scanner, the free scanner remembers the beginning of the
> last scanned pageblock in cc->free_pfn. It might be therefore rescanning pages
> uselessly when called several times during single compaction. This might have
> been useful when pages were returned to the buddy allocator after a failed
> migration, but this is no longer the case.
> 
> This patch changes the meaning of cc->free_pfn so that if it points to a
> middle of a pageblock, that pageblock is scanned only from cc->free_pfn to the
> end. isolate_freepages_block() will record the pfn of the last page it looked
> at, which is then used to update cc->free_pfn.
> 
> In the mmtests stress-highalloc benchmark, this has resulted in lowering the
> ratio between pages scanned by both scanners, from 2.5 free pages per migrate
> page, to 2.25 free pages per migrate page, without affecting success rates.
> 
> With __GFP_NO_KSWAPD allocations, this appears to result in a worse ratio (2.1
> instead of 1.8), but page migration successes increased by 10%, so this could
> mean that more useful work can be done until need_resched() aborts this kind
> of compaction.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Minchan Kim <minchan@kernel.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
