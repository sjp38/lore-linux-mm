Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 015F36B0264
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 07:05:24 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id bc4so154772917lbc.2
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 04:05:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a125si12755381wmh.123.2016.04.04.04.05.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 04:05:22 -0700 (PDT)
Subject: Re: [PATCH v2 4/4] mm, compaction: direct freepage allocation for
 async direct compaction
References: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
 <1459414236-9219-5-git-send-email-vbabka@suse.cz>
 <20160404093159.GB4773@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57024A6F.100@suse.cz>
Date: Mon, 4 Apr 2016 13:05:19 +0200
MIME-Version: 1.0
In-Reply-To: <20160404093159.GB4773@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/04/2016 11:31 AM, Mel Gorman wrote:
> On Thu, Mar 31, 2016 at 10:50:36AM +0200, Vlastimil Babka wrote:
>> The goal of direct compaction is to quickly make a high-order page available
>> for the pending allocation. The free page scanner can add significant latency
>> when searching for migration targets, although to succeed the compaction, the
>> only important limit on the target free pages is that they must not come from
>> the same order-aligned block as the migrated pages.
>>
>
> What prevents the free pages being allocated from behind the migration
> scanner? Having compaction abort when the scanners meet misses
> compaction opportunities but it avoids the problem of Compactor A using
> pageblock X as a migration target and Compactor B using pageblock X as a
> migration source.

It's true that there's no complete protection, but parallel async 
compactions should eventually get detect contention and back off. Sync 
compaction keeps using the free scanner, so this seemed like a safe 
thing to attempt in the initial async compaction, without compromising 
success rates thanks to the followup sync compaction.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
