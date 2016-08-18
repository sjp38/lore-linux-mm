Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A32B88308D
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 08:23:49 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k135so11489833lfb.2
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 05:23:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fn7si1633110wjc.190.2016.08.18.05.23.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 05:23:48 -0700 (PDT)
Subject: Re: [PATCH v6 05/11] mm, compaction: add the ultimate direct
 compaction priority
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-6-vbabka@suse.cz>
 <20160816055857.GB17448@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b44eef59-b2b3-e3a3-ab53-9d3880bab174@suse.cz>
Date: Thu, 18 Aug 2016 14:23:46 +0200
MIME-Version: 1.0
In-Reply-To: <20160816055857.GB17448@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/16/2016 07:58 AM, Joonsoo Kim wrote:
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -1644,6 +1644,8 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
>>  		.alloc_flags = alloc_flags,
>>  		.classzone_idx = classzone_idx,
>>  		.direct_compaction = true,
>> +		.whole_zone = (prio == COMPACT_PRIO_SYNC_FULL),
>> +		.ignore_skip_hint = (prio == COMPACT_PRIO_SYNC_FULL)
>>  	};
>>  	INIT_LIST_HEAD(&cc.freepages);
>>  	INIT_LIST_HEAD(&cc.migratepages);
>> @@ -1689,7 +1691,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>>  								ac->nodemask) {
>>  		enum compact_result status;
>>
>> -		if (compaction_deferred(zone, order)) {
>> +		if (prio > COMPACT_PRIO_SYNC_FULL
>> +					&& compaction_deferred(zone, order)) {
>>  			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
>>  			continue;
>
> Could we provide prio to compaction_deferred() and do the decision in
> that that function?
>
> BTW, in kcompactd, compaction_deferred() is checked but
> .ignore_skip_hint=true. Is there any reason? If we can remove
> compaction_deferred() for kcompactd, we can check .ignore_skip_hint
> to determine if defer is needed or not.

I don't want to change kcompactd right now, as the current series seems 
to help against premature OOMs. But I'll revisit it later.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
