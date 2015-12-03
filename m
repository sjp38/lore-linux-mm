Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 013F26B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 05:36:56 -0500 (EST)
Received: by wmww144 with SMTP id w144so16046588wmw.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 02:36:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v129si11328942wma.12.2015.12.03.02.36.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 02:36:54 -0800 (PST)
Subject: Re: [PATCH v3 1/7] mm/compaction: skip useless pfn when updating
 cached pfn
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1449126681-19647-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56601B44.609@suse.cz>
Date: Thu, 3 Dec 2015 11:36:52 +0100
MIME-Version: 1.0
In-Reply-To: <1449126681-19647-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/03/2015 08:11 AM, Joonsoo Kim wrote:
> Cached pfn is used to determine the start position of scanner
> at next compaction run. Current cached pfn points the skipped pageblock
> so we uselessly checks whether pageblock is valid for compaction and
> skip-bit is set or not. If we set scanner's cached pfn to next pfn of
> skipped pageblock, we don't need to do this check.
> 
> This patch moved update_pageblock_skip() to
> isolate_(freepages|migratepages). Updating pageblock skip information
> isn't relevant to CMA so they are more appropriate place
> to update this information.

That's step in a good direction, yeah. But why not go as far as some variant of
my (not resubmitted) patch "mm, compaction: decouple updating pageblock_skip and
cached pfn" [1]. Now the overloading of update_pageblock_skip() is just too much
- a struct page pointer for the skip bits, and a pfn of different page for the
cached pfn update, that's just more complex than it should be.

(I also suspect the pageblock_flags manipulation functions could be simpler if
they accepted zone pointer and pfn instead of struct page)

Also recently in Aaron's report we found a possible scenario where pageblocks
are being skipped without entering the isolate_*_block() functions, and it would
make sense to update the cached pfn's in that case, independently of updating
pageblock skip bits.

But this might be too out of scope of your series, so if you want I can
separately look at reviving some useful parts of [1] and the simpler
pageblock_flags manipulations.

[1] https://lkml.org/lkml/2015/6/10/237

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
