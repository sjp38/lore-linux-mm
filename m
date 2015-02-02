Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 989BC6B006C
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 09:19:50 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id fb4so17142491wid.2
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 06:19:50 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r19si5541972wiw.100.2015.02.02.06.19.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 06:19:49 -0800 (PST)
Message-ID: <54CF877D.9010609@suse.cz>
Date: Mon, 02 Feb 2015 15:19:41 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 3/3] mm/compaction: enhance compaction finish condition
References: <1422861348-5117-1-git-send-email-iamjoonsoo.kim@lge.com> <1422861348-5117-3-git-send-email-iamjoonsoo.kim@lge.com> <54CF4F61.3070905@suse.cz> <BLU436-SMTP200D06EB86F21EF7A29CE57833C0@phx.gbl>
In-Reply-To: <BLU436-SMTP200D06EB86F21EF7A29CE57833C0@phx.gbl>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.ok@hotmail.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/02/2015 02:51 PM, Zhang Yanfei wrote:
>> I've got another idea for small improvement. We should only test for fallbacks
>> when migration scanner has scanned (and migrated) a whole pageblock. Should be a
>> simple alignment test of cc->migrate_pfn.
>> Advantages:
>> - potentially less checking overhead
>> - chances of stealing increase if we created more free pages for migration
>> - thus less fragmentation
>> The cost is a bit more time spent compacting, but it's bounded and worth it
>> (especially the less fragmentation) IMHO.
> 
> This seems to make the compaction a little compicated... I kind of

Just a little bit, compared to e.g. this patch :)

> don't know why there is more anti-fragmentation by using this approach.

Ah so let me explain. Assume we want to allocate order-3 unmovable page and have
to invoke compaction because of that. The migration scanner starts in the
beginning of a movable pageblock, isolates and migrates 32 pages
(COMPACT_CLUSTER_MAX) from the beginning sucessfully, and then we check in
compact_finished and see that the allocation could fall back to this newly
created order-5 block. So we terminate compaction and allocation takes this
order-5 block, allocates order-3 and the rest remains on free list of unmovable.
It will try to steal more freepages from the pageblock, but there aren't any. So
we have a movable block with unmovable pages. The spare free pages are
eventually depleted and we fallback to another movable pageblock... bad.

With the proposed change, we would try to compact the pageblock fully. Possibly
we would free at least half of it, so it would be marked as unmovable during the
fallback allocation, and would be able to satisfy more unmovable allocations
that wouldn't have to fallback somewhere else.

I don't think that finishing the scan of a single pageblock is that big of a
cost here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
