Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C8BEC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 19:58:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1E5820857
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 19:58:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="fc1D85Qh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1E5820857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17F2E8E0003; Fri,  1 Mar 2019 14:58:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1049A8E0001; Fri,  1 Mar 2019 14:58:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F10058E0003; Fri,  1 Mar 2019 14:58:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF7F88E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 14:58:43 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id y133so23377194ywa.21
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 11:58:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=iet7hguJ74vBzlUc4/t0rTAEzUcMPS5XRiat49LTLdU=;
        b=Evk831Abv641KwMr5R70iFhELBG8/nInJk+O8RmUdsf6foLhPpHeA7z6/yiLiziGoJ
         X7Oanqg4q8LF4BoBjQI+La0TqKtfEjrTaZeDwGa4N03sTuyR/mR8MSjte4oZfhMurVGY
         fB0MCUNv6mg5gvROfHAe7ylxK4ZVCq72nDnTRN2dEN6VApMj7xXPfYbpsEhJSolIqbrH
         EfUBzdazoqXkIKdHsDIcARdf+hOcl+H93awJQCjVsy3iRzoZspFOIgT06ovdiOsyz7Gi
         MPsdOBo7RgV21BH1c4tatfrm+uONNzapbIOretQWWXXSqbt6FZk2h6UOuMaa8agYt9ej
         /hQQ==
X-Gm-Message-State: APjAAAWw+eWS9Tu8agBNU4hf2LumhMApv7tn5ukN7LXnJu8Sk+RTfdUV
	DxyGSHomSEnyGLonEyO3aF/9YN3/dyMe7vkrd+c4YwlPn/4+THhLz8Pub5wuBN9sSW75Jt/HD0f
	a2AuW+o76WeDYjfUCupYxwQ3e4tO4MHvFsepVgEEOWuHI7Y/uVTtnl2DYpH3u9NV9RA==
X-Received: by 2002:a25:d20d:: with SMTP id j13mr5709568ybg.417.1551470323448;
        Fri, 01 Mar 2019 11:58:43 -0800 (PST)
X-Google-Smtp-Source: APXvYqxl7L77orH5LfzN7wNMhDVno4k1xLJ5sOkmvi1371pekD/1ccDIimuWH6Tx/RijqD/q4j3H
X-Received: by 2002:a25:d20d:: with SMTP id j13mr5709532ybg.417.1551470322665;
        Fri, 01 Mar 2019 11:58:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551470322; cv=none;
        d=google.com; s=arc-20160816;
        b=hkiUxmurKD2GBk4C1L9GzQjWrWTiT1DSXG2MBMWwO0qgumqdXzorii2KPYRKc+oBjc
         eOTFCtLxiXcwo1iEt1wRhGrPQ+ULN59sXTzFFDPBGabfDAk5nAV2Jb6gVdB13uWkAUwa
         6CdFzFl+0KrIurGe6ceC3mhx+LdDBGC2TTSbfoUkkNm2FskQciuTUbMHyeE9SpTWo8l/
         czZ3Fhldx3mhy1Qyy3pZAr9MrXmRAJoqDQrv4zCwh0QlXn8laQ9vlrWJkasrWB4hJOrH
         w+XxfiXruabWlbJm+XGRrH9aDrDgWJKfi78Wau7oYqbkn6AStmEQW0Kh0i0KY0bwPebs
         pWMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=iet7hguJ74vBzlUc4/t0rTAEzUcMPS5XRiat49LTLdU=;
        b=MWxzfxFSF2/R3Xgt0V/IAz4VeByZPiTQQ8fVfmZXk6QN/S5ECDUMfAcqlrjr272p3Z
         Hb8JzoYqJU51BsVe1fBQsA+sEfhnt6vyCuRUeBph3fjos1WMzcFfl/P0D/BJzjJmT27I
         rQEDrcmHYTQ5bLhKspH24lepshCa2rVHe6mIZokeuVyek7kOsCo3mmJzcrFvW0AgxiH0
         8wr29RGjfKP+xoKsCoL2/4FgsWoFVekYoZ06WjXSchC80WS2l0d82A1zqMkWOZr39WGD
         w40s09Nei1z/SZznJ8m7jCa2XH2fvux30eLHBZbuEzWGqROmUreA3JCrFuD5hPVeJlQh
         CU1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fc1D85Qh;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id n16si1470051ybp.261.2019.03.01.11.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 11:58:42 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fc1D85Qh;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c798efa0000>; Fri, 01 Mar 2019 11:58:50 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 01 Mar 2019 11:58:41 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 01 Mar 2019 11:58:41 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 1 Mar
 2019 19:58:41 +0000
Subject: Re: [PATCH v2 2/4] mm: remove zone_lru_lock() function access
 ->lru_lock directly
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton
	<akpm@linux-foundation.org>
CC: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>,
	Rik van Riel <riel@surriel.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman
	<mgorman@techsingularity.net>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
 <20190228083329.31892-2-aryabinin@virtuozzo.com>
 <44ffadb4-4235-76c9-332f-680dda5da521@nvidia.com>
 <186bf66b-fec5-a614-3ffd-64b8d7660fe5@virtuozzo.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <1aac5881-0590-8c24-d963-1a7be86a7c43@nvidia.com>
Date: Fri, 1 Mar 2019 11:58:40 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <186bf66b-fec5-a614-3ffd-64b8d7660fe5@virtuozzo.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551470330; bh=iet7hguJ74vBzlUc4/t0rTAEzUcMPS5XRiat49LTLdU=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=fc1D85Qh67XVnbF++2wghKnKz2r/XTZWPhZRYHcMwgialicSrayW/7fis6GLUxt3q
	 nwDHzN11qXq8F+g92Z8hYbEa7zHCO4T73RWtBU4RPOE7q+QSZO//0eju/cigOiEftt
	 BTErVRdvrONbuzpEpC0G8HMdzi31LmWkdXx+7df4oPyZVVitXAe+DwXJLd5fSSzBSB
	 k8e+qDuTenbi8L4be+B3I/ky0Qv7mmYbP4CNbApDy2zivyxa9dEoqCZtXNoJQEQqBr
	 M1enFdc5hBexsFfHUFiauKaYstoHRAffAfBXypVDMp7kqUO4sqNUYOwU2jVVA4QNgu
	 2AoVxJonVzYug==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/1/19 2:51 AM, Andrey Ryabinin wrote:
> 
> 
> On 3/1/19 12:44 AM, John Hubbard wrote:
>> On 2/28/19 12:33 AM, Andrey Ryabinin wrote:
>>> We have common pattern to access lru_lock from a page pointer:
>>> 	zone_lru_lock(page_zone(page))
>>>
>>> Which is silly, because it unfolds to this:
>>> 	&NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)]->zone_pgdat->lru_lock
>>> while we can simply do
>>> 	&NODE_DATA(page_to_nid(page))->lru_lock
>>>
>>
>> Hi Andrey,
>>
>> Nice. I like it so much that I immediately want to tweak it. :)
>>
>>
>>> Remove zone_lru_lock() function, since it's only complicate things.
>>> Use 'page_pgdat(page)->lru_lock' pattern instead.
>>
>> Here, I think the zone_lru_lock() is actually a nice way to add
>> a touch of clarity at the call sites. How about, see below:
>>
>> [snip]
>>
>>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>>> index 2fd4247262e9..22423763c0bd 100644
>>> --- a/include/linux/mmzone.h
>>> +++ b/include/linux/mmzone.h
>>> @@ -788,10 +788,6 @@ typedef struct pglist_data {
>>>  
>>>  #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
>>>  #define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
>>> -static inline spinlock_t *zone_lru_lock(struct zone *zone)
>>> -{
>>> -	return &zone->zone_pgdat->lru_lock;
>>> -}
>>>  
>>
>> Instead of removing that function, let's change it, and add another
>> (since you have two cases: either a page* or a pgdat* is available),
>> and move it to where it can compile, like this:
>>
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 80bb6408fe73..cea3437f5d68 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1167,6 +1167,16 @@ static inline pg_data_t *page_pgdat(const struct page *page)
>>         return NODE_DATA(page_to_nid(page));
>>  }
>>  
>> +static inline spinlock_t *zone_lru_lock(pg_data_t *pgdat)
>> +{
>> +       return &pgdat->lru_lock;
>> +}
>> +
> 
> 
> I don't think wrapper for a simple plain access to the struct member is reasonable.
> Besides, there are plenty of "spin_lock(&pgdat->lru_lock)" even without this patch,
> so for consistency reasons &pgdat->lru_lock seems like a better choice to me.
> 
> Also "&pgdat->lru_lock" is just shorter than:
>       "node_lru_lock(pgdat)"
> 
> 
> 
>> +static inline spinlock_t *zone_lru_lock_from_page(struct page *page)
>> +{
>> +       return zone_lru_lock(page_pgdat(page));
>> +}
>> +
> 
> I don't think such function would find any use. Usually lru_lock is taken
> to perform some manipulations with page *and* pgdat, thus it's better to remember
> page_pgdat(page) in local variable.
> 

That's a good argument.

thanks,
-- 
John Hubbard
NVIDIA

