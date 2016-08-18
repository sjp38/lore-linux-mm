Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD45F6B0269
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:59:28 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so11063134lfg.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 04:59:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u1si1558331wju.85.2016.08.18.04.59.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 04:59:27 -0700 (PDT)
Subject: Re: [PATCH v6 04/11] mm, compaction: don't recheck watermarks after
 COMPACT_SUCCESS
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-5-vbabka@suse.cz>
 <20160816061200.GD17448@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8e0c91c4-4617-c41b-31c6-d3c9a8714952@suse.cz>
Date: Thu, 18 Aug 2016 13:59:24 +0200
MIME-Version: 1.0
In-Reply-To: <20160816061200.GD17448@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/16/2016 08:12 AM, Joonsoo Kim wrote:
> On Wed, Aug 10, 2016 at 11:12:19AM +0200, Vlastimil Babka wrote:
>> Joonsoo has reminded me that in a later patch changing watermark checks
>> throughout compaction I forgot to update checks in try_to_compact_pages() and
>> compactd_do_work(). Closer inspection however shows that they are redundant now
>> that compact_zone() reliably reports success with COMPACT_SUCCESS, as they just
>> repeat (a subset) of checks that have just passed. So instead of checking
>> watermarks again, just test the return value.
>
> In fact, it's not redundant. Even if try_to_compact_pages() returns
> !COMPACT_SUCCESS, watermark check could return true.
> __compact_finished() calls find_suitable_fallback() and it's slightly
> different with watermark check. Anyway, I don't think it is a big
> problem.

Andrew, can you please replace the changelog to clarify this?

===
Joonsoo has reminded me that in a later patch changing watermark checks
throughout compaction I forgot to update checks in 
try_to_compact_pages() and compactd_do_work(). Closer inspection however 
shows that they are redundant now in the success case, because 
compact_zone() now reliably reports this with COMPACT_SUCCESS. So 
effectively the checks just repeat (a subset) of checks that have just 
passed. So instead of checking watermarks again, just test the return value.

Note it's also possible that compaction would declare failure e.g. 
because its find_suitable_fallback() is more strict than simple 
watermark check, and then the watermark check we are removing would then 
still succeed. After this patch this is not possible and it's arguably 
better, because for long-term fragmentation avoidance we should rather 
try a different zone than allocate with the unsuitable fallback. If 
compaction of all zones fail and the allocation is important enough, it 
will retry and succeed anyway.

Also remove the stray "bool success" variable from kcompactd_do_work().
===


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
