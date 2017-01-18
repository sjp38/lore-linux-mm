Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77C046B0260
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:32:28 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id yr2so1399698wjc.4
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:32:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g29si28466031wra.178.2017.01.18.01.32.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 01:32:27 -0800 (PST)
Subject: Re: [RFC 4/4] mm, page_alloc: fix premature OOM when racing with
 cpuset mems update
References: <20170117221610.22505-1-vbabka@suse.cz>
 <20170117221610.22505-5-vbabka@suse.cz>
 <036e01d2715a$3a227de0$ae6779a0$@alibaba-inc.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3ca060b7-0648-a829-7d5e-896490b4a622@suse.cz>
Date: Wed, 18 Jan 2017 10:32:25 +0100
MIME-Version: 1.0
In-Reply-To: <036e01d2715a$3a227de0$ae6779a0$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Ganapatrao Kulkarni' <gpkulkarni@gmail.com>
Cc: 'Michal Hocko' <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/18/2017 08:12 AM, Hillf Danton wrote:
>
> On Wednesday, January 18, 2017 6:16 AM Vlastimil Babka wrote:
>>
>> @@ -3802,13 +3811,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>>  	 * Also recalculate the starting point for the zonelist iterator or
>>  	 * we could end up iterating over non-eligible zones endlessly.
>>  	 */
> Is the newly added comment still needed?

You're right that it's no longer true. I think we can even remove most of the 
zoneref trickery and non-NULL checks in the fastpath (as a cleanup patch on 
top), as the loop in get_page_from_freelist() should handle it just fine. IIRC 
Mel even did this in the microopt series, but I pointed out that NULL 
preferred_zoneref pointer would be dangerous in get_page_from_freelist(). We 
didn't realize that we check the wrong pointer (i.e. patch 1/4 here).

Vlastimil

>
>> -	if (unlikely(ac.nodemask != nodemask)) {
>> -no_zone:
>> +	if (unlikely(ac.nodemask != nodemask))
>>  		ac.nodemask = nodemask;
>> -		ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
>> -						ac.high_zoneidx, ac.nodemask);
>> -		/* If we have NULL preferred zone, slowpath wll handle that */
>> -	}
>>
>>  	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
>>
>> --
>> 2.11.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
