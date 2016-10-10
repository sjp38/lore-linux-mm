Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 946486B0069
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 02:57:44 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id x79so32615352lff.2
        for <linux-mm@kvack.org>; Sun, 09 Oct 2016 23:57:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ke3si37038291wjb.240.2016.10.09.23.57.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 09 Oct 2016 23:57:43 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm: adjust reserved highatomic count
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-2-git-send-email-minchan@kernel.org>
 <7ac7c0d8-4b7b-e362-08e7-6d62ee20f4c3@suse.cz> <20161007142919.GA3060@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c0920ac2-fe63-567e-e24c-eb6d638143b0@suse.cz>
Date: Mon, 10 Oct 2016 08:57:40 +0200
MIME-Version: 1.0
In-Reply-To: <20161007142919.GA3060@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On 10/07/2016 04:29 PM, Minchan Kim wrote:
>>> In that case, we should adjust nr_reserved_highatomic.
>>> Otherwise, VM cannot reserve highorderatomic pageblocks any more
>>> although it doesn't reach 1% limit. It means highorder atomic
>>> allocation failure would be higher.
>>>
>>> So, this patch decreases the account as well as migratetype
>>> if it was MIGRATE_HIGHATOMIC.
>>>
>>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>>
>> Hm wouldn't it be simpler just to prevent the pageblock's migratetype to be
>> changed if it's highatomic? Possibly also not do move_freepages_block() in
>
> It could be. Actually, I did it with modifying can_steal_fallback which returns
> false it found the pageblock is highorderatomic but changed to this way again
> because I don't have any justification to prevent changing pageblock.
> If you give concrete justification so others isn't against on it, I am happy to
> do what you suggested.

Well, MIGRATE_HIGHATOMIC is not listed in the fallbacks array at all, so 
we are not supposed to steal from it in the first place. Stealing will 
only happen due to races, which would be too costly to close, so we 
allow them and expect to be rare. But we shouldn't allow them to break 
the accounting.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
