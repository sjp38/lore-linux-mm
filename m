Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D47EF6B025F
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:11:23 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 101so157584510qtb.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 23:11:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ew17si23728070wjd.262.2016.08.15.23.11.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Aug 2016 23:11:22 -0700 (PDT)
Subject: Re: [PATCH v6 04/11] mm, compaction: don't recheck watermarks after
 COMPACT_SUCCESS
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-5-vbabka@suse.cz>
 <20160816061200.GD17448@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7cd558df-d815-2e05-6a24-d1e1c87f184f@suse.cz>
Date: Tue, 16 Aug 2016 08:11:21 +0200
MIME-Version: 1.0
In-Reply-To: <20160816061200.GD17448@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

Right, I meant they are redundant in the SUCCESS case.

> __compact_finished() calls find_suitable_fallback() and it's slightly
> different with watermark check. Anyway, I don't think it is a big
> problem.

I agree. It might be even better for long-term fragmentation that we 
e.g. try another zone instead of taking page from the "unsuitable 
fallback". If that's not successful, and the allocation is important 
enough there will later eventually be another watermark check permitting 
the unsuitable fallback.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
