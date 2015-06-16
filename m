Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id C4D466B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 08:33:06 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so102080685wiw.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 05:33:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dd10si23859037wib.30.2015.06.16.05.33.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 05:33:05 -0700 (PDT)
Message-ID: <5580177F.6070303@suse.cz>
Date: Tue, 16 Jun 2015 14:33:03 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] mm, compaction: decouple updating pageblock_skip
 and cached pfn
References: <1433928754-966-1-git-send-email-vbabka@suse.cz> <1433928754-966-7-git-send-email-vbabka@suse.cz> <20150616061013.GF12641@js1304-P5Q-DELUXE>
In-Reply-To: <20150616061013.GF12641@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 06/16/2015 08:10 AM, Joonsoo Kim wrote:
> On Wed, Jun 10, 2015 at 11:32:34AM +0200, Vlastimil Babka wrote:
>> The pageblock_skip bitmap and cached scanner pfn's are two mechanisms in
>> compaction to prevent rescanning pages where isolation has recently failed
>> or they were scanned during the previous compaction attempt.
>> 
>> Currently, both kinds of information are updated via update_pageblock_skip(),
>> which is suboptimal for the cached scanner pfn's:
>> 
>> - The condition "isolation has failed in the pageblock" checked by
>>   update_pageblock_skip() may be valid for the pageblock_skip bitmap, but makes
>>   less sense for cached pfn's. There's little point for the next compaction
>>   attempt to scan again a pageblock where all pages that could be isolated were
>>   already processed.
> 
> In async compaction, compaction could be stopped due to cc->contended
> in freepage scanner so sometimes isolated pages were not migrated. Your
> change makes next async compaction skip these pages. This possibly causes
> compaction complete prematurely by async compaction.

Hm, I see, thanks. That could be fixed when returning the non-migrated pages,
just like we do for the unused freepages and cached free scanner position.

> And, rescan previous attempted range could solve some race problem.
> If allocated page waits to set PageLRU in pagevec, compaction will
> pass it. If we try rescan after short time, page will have PageLRU and
> compaction can isolate and migrate it and make high order freepage. This
> requires some rescanning overhead but migration overhead which is more bigger
> than scanning overhead is just a little. If compaction pass it like as
> this change, pages on this area would be allocated for other requestor, and,
> when compaction revisit, there would be more page to migrate.

The same "race problem" (and many others) can happen when we don't abort and
later restart from cached pfn's, but just continue on to later pageblocks within
single compaction run. Still I would expect that it's statistically higher
chance to succeed in the next pageblock than rescanning pageblock(s) that we
just scanned.

> I basically agree with this change because it is more intuitive. But,
> I'd like to see some improvement result or test this patch myself before merging
> it.

Sure, please test. I don't expect much difference, the primary motivation was
really that the recorded pfn's by tracepoints looked much saner.

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
