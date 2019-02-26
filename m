Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80C01C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:06:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 405A7217F9
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:06:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 405A7217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D47DE8E0004; Tue, 26 Feb 2019 07:06:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCD388E0001; Tue, 26 Feb 2019 07:06:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6F1E8E0004; Tue, 26 Feb 2019 07:06:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44D4F8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:06:52 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id q26so2210717ljg.19
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:06:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8WwG5EpFMSrNgd78IwJZ3PTDDs6DXsAYPHWzueLYYsU=;
        b=LbR9Ujw5oRjuU8LnaE7LwaSu/HzXOxnuxxB2vw7loSQy4BuWBpp9TDj5l7JAeSaLX1
         C9pcyV5MhsmiP+s71HgfYuAmfhiIsXu0FMz6NgZ2wYrDCqjipTn/9VHw/LqTUVwqunac
         +FoLd0e7iP9up7kFf9TtYcbHCsI9ylEdYw5BqRPB6vCgX4nASzI5og3euNa4GitKZz6W
         vXV9U52aYTBXvZf08i4/D1Hq4eX2FXrDei88YjCmR+rI4lgoM7RRHQl/Viv623KFCEcm
         gOwK7UrBRnNSqlbnkwud32sVl4aQN/3nF9wrz/BarzGq0Kv/vf1eguSMUsft8JfJ3pbA
         TPIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAubWtLenPShmswGxJ6aMsMRYMW/+X/Cybbrc4Drht/zuWKj+sVej
	l6fv51K6lsVr3BUiIof971j/IitsOq9JFBmB5UJmALUpDU6cK8pcMWz5fVwsaR2AnA4AKWFrcz+
	elHmHpT27tY1Hma92pG1gv0YSlEnN4mFn8TmG7oRjCH8c2Pn2RpjvjATsFMmsD6JTRA==
X-Received: by 2002:a19:6454:: with SMTP id b20mr5990190lfj.150.1551182811656;
        Tue, 26 Feb 2019 04:06:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbIN67JapMeM8shhCzOj1HxVpOe9NfGA80gGzK8x1ZG4EMWD5PQOWsWELhw11vh/L79yOWw
X-Received: by 2002:a19:6454:: with SMTP id b20mr5990154lfj.150.1551182810692;
        Tue, 26 Feb 2019 04:06:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551182810; cv=none;
        d=google.com; s=arc-20160816;
        b=RtUgKNKBfV9Fg5Hthi+Qhpcc0bAX4WyVMwt68RiD4rLvFjpQsNLUw4THUxmx50JmzW
         1zwcFI2uhTCvY7CJ+Ne3UlSW8/sKX7RMPxvEKdWv+JXRs1W0IFvlLHYyTaaNYV34W6Q2
         ip9e6w7SAFxf/9qbPLGie44Xj8VbBOM+9Q6hOmXCfoufaTmBApIG2jS/K8duTVQdLmrk
         mvyomgt5hNCwVmCwzlpSfdsrjSO/vxaf9gor99jKSxopS9qKyykY5S7gnOoIoiaLTvtW
         oHRuLxffvYtZAGJOSmqe6/WVoeyTwQF3+OJh54KTys7U7kALQLmths9xI0ARYywqrRbD
         i1hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8WwG5EpFMSrNgd78IwJZ3PTDDs6DXsAYPHWzueLYYsU=;
        b=JtFeuZmnQzZSmnEaCZqiO+bR7u+qjU8k21IyorQcvwmJzNleBRVNtxLaTtNNXeRCrq
         r2aSxrOpeFP1T9yvedruRn6OjxQCo9vQmG9nIxJGxggQWpDDXIDS2BMcB+k1ZVevX7+q
         Llo85aZo7B4Vn04NZxqY4R48coRhSur9jGjTawXKPZGDCG8nSQbfoWAF3OJjj5JsmnzQ
         0WjfBpGrtAXSIN1th3ue6nOT46WbAwgGXh/7Q304F4p6iVbRO7EMad3saLEUUj/8cf8l
         d5cqulqjXPOWhrcPQLwD9gCnyy7ha/7zBGe8eWpAM/Yvym6qj2pCkS2DoKhzgrXlGemN
         s+/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id s9si9617199lje.100.2019.02.26.04.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 04:06:50 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gybVT-0007Vl-OC; Tue, 26 Feb 2019 15:06:43 +0300
Subject: Re: [PATCH 1/5] mm/workingset: remove unused @mapping argument in
 workingset_eviction()
To: Vlastimil Babka <vbabka@suse.cz>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>
References: <20190222174337.26390-1-aryabinin@virtuozzo.com>
 <e56aea36-f454-a75f-5f83-4150b87c9c15@suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <9c4d34b8-60b5-a05b-c196-b1cc4ecb235c@virtuozzo.com>
Date: Tue, 26 Feb 2019 15:07:02 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <e56aea36-f454-a75f-5f83-4150b87c9c15@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/25/19 3:01 PM, Vlastimil Babka wrote:
> On 2/22/19 6:43 PM, Andrey Ryabinin wrote:
>> workingset_eviction() doesn't use and never did use the @mapping argument.
>> Remove it.
>>
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Rik van Riel <riel@surriel.com>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> ---
>>  include/linux/swap.h | 2 +-
>>  mm/vmscan.c          | 2 +-
>>  mm/workingset.c      | 3 +--
>>  3 files changed, 3 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 649529be91f2..fc50e21b3b88 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -307,7 +307,7 @@ struct vma_swap_readahead {
>>  };
>>  
>>  /* linux/mm/workingset.c */
>> -void *workingset_eviction(struct address_space *mapping, struct page *page);
>> +void *workingset_eviction(struct page *page);
>>  void workingset_refault(struct page *page, void *shadow);
>>  void workingset_activation(struct page *page);
>>  
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index ac4806f0f332..a9852ed7b97f 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -952,7 +952,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
>>  		 */
>>  		if (reclaimed && page_is_file_cache(page) &&
>>  		    !mapping_exiting(mapping) && !dax_mapping(mapping))
>> -			shadow = workingset_eviction(mapping, page);
>> +			shadow = workingset_eviction(page);
>>  		__delete_from_page_cache(page, shadow);
>>  		xa_unlock_irqrestore(&mapping->i_pages, flags);
>>  
>> diff --git a/mm/workingset.c b/mm/workingset.c
>> index dcb994f2acc2..0906137760c5 100644
>> --- a/mm/workingset.c
>> +++ b/mm/workingset.c
>> @@ -215,13 +215,12 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
>>  
>>  /**
>>   * workingset_eviction - note the eviction of a page from memory
>> - * @mapping: address space the page was backing
>>   * @page: the page being evicted
>>   *
>>   * Returns a shadow entry to be stored in @mapping->i_pages in place
> 
> The line above still references @mapping, I guess kerneldoc build will
> complain?
> 

Maybe. Will replace it with @page->mapping->i_pages

