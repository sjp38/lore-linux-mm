Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 96AFB6B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:40:49 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id j8so19766278lfd.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 12:40:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id en8si250154wjd.165.2016.04.26.12.40.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 12:40:48 -0700 (PDT)
Subject: Re: [PATCH mmotm 3/3] mm, compaction: prevent nr_isolated_* from
 going negative
References: <1461591269-28615-1-git-send-email-vbabka@suse.cz>
 <1461591350-28700-1-git-send-email-vbabka@suse.cz>
 <1461591350-28700-4-git-send-email-vbabka@suse.cz>
 <20160426005503.GC2707@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571FC43D.6010102@suse.cz>
Date: Tue, 26 Apr 2016 21:40:45 +0200
MIME-Version: 1.0
In-Reply-To: <20160426005503.GC2707@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

On 04/26/2016 02:55 AM, Joonsoo Kim wrote:
> On Mon, Apr 25, 2016 at 03:35:50PM +0200, Vlastimil Babka wrote:
>> @@ -846,9 +845,11 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>>  				spin_unlock_irqrestore(&zone->lru_lock,	flags);
>>  				locked = false;
>>  			}
>> -			putback_movable_pages(migratelist);
>> -			nr_isolated = 0;
>> +			acct_isolated(zone, cc);
>> +			putback_movable_pages(&cc->migratepages);
>> +			cc->nr_migratepages = 0;
>>  			cc->last_migrated_pfn = 0;
>> +			nr_isolated = 0;
>
> Is it better to use separate list and merge it cc->migratepages when
> finishing instead of using cc->migratepages directly? If
> isolate_migratepages() try to isolate more than one page block and keep
> isolated page on previous pageblock, this putback all will invalidate
> all the previous work. It would be beyond of the scope of this
> function. Now, isolate_migratepages() try to isolate the page in one
> pageblock so this code is safe. But, I think that removing such
> dependency will be helpful in the future. I'm not strongly insisting it
> so if you think it's not useful thing, please ignore this comment.

migratelist was merely a reference to cc->migratepages, so it wouldn't prevent 
the situation you are suggesting. A truly separate list would need to be 
appended to cc->migratepages when leaving isolate_migratepages_block() and 
there's no need to do that right now.

BTW, can you check patch 1/3? Thanks!

Vlastimil

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
