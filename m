Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDF76B00D8
	for <linux-mm@kvack.org>; Mon,  5 May 2014 20:29:34 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so3631006pab.10
        for <linux-mm@kvack.org>; Mon, 05 May 2014 17:29:34 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id yd10si10218840pab.2.2014.05.05.17.29.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 May 2014 17:29:33 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so3630997pab.10
        for <linux-mm@kvack.org>; Mon, 05 May 2014 17:29:33 -0700 (PDT)
Date: Mon, 5 May 2014 17:29:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 3/4] mm, compaction: add per-zone migration pfn cache
 for async compaction
In-Reply-To: <53679F16.8020007@suse.cz>
Message-ID: <alpine.DEB.2.02.1405051726210.4720@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011435000.23898@chino.kir.corp.google.com> <53675B3A.5090607@suse.cz>
 <alpine.DEB.2.02.1405050243490.11071@chino.kir.corp.google.com> <53679F16.8020007@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 5 May 2014, Vlastimil Babka wrote:

> I see, although I would still welcome some numbers to back such change.

It's pretty difficult to capture numbers for this in real-world scenarios 
since it happens rarely (and when it happens, it's very significant 
latency) and without an instrumented kernel that will determine how many 
pageblocks have been skipped.  I could create a synthetic example of it in 
the kernel and get numbers for a worst-case scenario with a 64GB zone if 
you'd like, I'm not sure how representative it will be.

> What I still don't like is the removal of the intent of commit 50b5b094e6. You
> now again call set_pageblock_skip() unconditionally, thus also on pageblocks
> that async compaction skipped due to being non-MOVABLE. The sync compaction
> will thus ignore them.
> 

I'm not following you, with this patch there are two cached pfns for the 
migration scanner: one is used for sync and one is used for async.  When 
cc->sync == true, both cached pfns are updated (async is not going to 
succeed for a pageblock when sync failed for that pageblock); when 
cc->sync == false, the async cached pfn is updated only and we pick up 
again where we left off for subsequent async compactions.  Sync compaction 
will still begin where it last left off and consider these non-MOVABLE 
pageblocks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
