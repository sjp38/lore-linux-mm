Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4096B0070
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:27:09 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id z60so3582903qgd.33
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 08:27:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v68si16742745qge.125.2014.10.20.08.27.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 08:27:05 -0700 (PDT)
Message-ID: <544529C0.5080205@redhat.com>
Date: Mon, 20 Oct 2014 11:26:56 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm, compaction: always update cached scanner positions
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz> <1412696019-21761-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1412696019-21761-5-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On 10/07/2014 11:33 AM, Vlastimil Babka wrote:
> Compaction caches the migration and free scanner positions between compaction
> invocations, so that the whole zone gets eventually scanned and there is no
> bias towards the initial scanner positions at the beginning/end of the zone.
>
> The cached positions are continuously updated as scanners progress and the
> updating stops as soon as a page is successfully isolated. The reasoning
> behind this is that a pageblock where isolation succeeded is likely to succeed
> again in near future and it should be worth revisiting it.
>
> However, the downside is that potentially many pages are rescanned without
> successful isolation. At worst, there might be a page where isolation from LRU
> succeeds but migration fails (potentially always). So upon encountering this
> page, cached position would always stop being updated for no good reason.
> It might have been useful to let such page be rescanned with sync compaction
> after async one failed, but this is now handled by caching scanner position
> for async and sync mode separately since commit 35979ef33931 ("mm, compaction:
> add per-zone migration pfn cache for async compaction").
>
> After this patch, cached positions are updated unconditionally. In
> stress-highalloc benchmark, this has decreased the numbers of scanned pages
> by few percent, without affecting allocation success rates.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
