Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 24D5C6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 15:14:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l6so77747370wml.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 12:14:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d203si259470wmf.56.2016.04.18.12.14.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 12:14:24 -0700 (PDT)
Subject: Re: mmotm woes, mainly compaction
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
 <20160412121020.GC10771@dhcp22.suse.cz>
 <alpine.LSU.2.11.1604141114290.1086@eggly.anvils> <571026CA.6000708@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57153205.4050406@suse.cz>
Date: Mon, 18 Apr 2016 15:14:13 -0400
MIME-Version: 1.0
In-Reply-To: <571026CA.6000708@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/14/2016 07:24 PM, Vlastimil Babka wrote:
>> > @@ -1459,8 +1459,8 @@ static enum compact_result compact_zone(
>> >   		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
>> >   	}
>> >
>> > -	if (cc->migrate_pfn == start_pfn)
>> > -		cc->whole_zone = true;
>> > +	cc->whole_zone = cc->migrate_pfn == start_pfn &&
>> > +			cc->free_pfn == pageblock_start_pfn(end_pfn - 1);
>> >
>> >   	cc->last_migrated_pfn = 0;
> This would be for Michal, but I agree.

So there's an alternative here that wouldn't have the danger of missing
cc->whole_zone multiple time due to races. When resetting either one
scanner to zone boundary, reset the other as well (and set
cc->whole_zone). I think the situations, where not doing that have any
(performance) advantage, are rare.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
