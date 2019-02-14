Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CE7CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:30:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63DEC2229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:30:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63DEC2229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B8358E0002; Thu, 14 Feb 2019 05:30:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16A4D8E0001; Thu, 14 Feb 2019 05:30:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0812B8E0002; Thu, 14 Feb 2019 05:30:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDE88E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:30:41 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id g75so1453170ljg.17
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:30:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1NZndyitaWXBd06VmAqbJ+aqzl/CyKYMIHzKOfZvkUY=;
        b=MO9apHGrvljHvOjY0dIRGFieVhJaQjO6MZM0l4erRC922aPtxqSJxi+BXySSys9YLr
         ZKohT1Rdhw+607DQ9wdSm0hqyp3BnlefkQ9vtMtZc1dLmTY/n3/DHks1JYlmSjMtAazl
         nult4740M/rBfqiFLA5MMgIKFay/IE1OqoorzCUzrbbrqhuE3FUegs7PcCCo2AxgyyvV
         hi90XxgKCMrhu8ldfjUU36Ym6XCW8TUWA+DnVgutVG7J3EAu3A+kS5uf/sU+cwyktk/D
         tou49fsux7VyZ7BVnb6ewk62fa5cuFy15L04n6G7KouiRlCzHlnJebI0G4nrR+Jz+lPL
         iUwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuYPcQAZc0yfz25VvG8l4YXZuEC9NO2oygR0iUVsd4RIAOFjLZ9X
	hrh9du/zuSYdRaJYldOBKLJodL1bPlPIhJuYyswQin+ru+ydi6Wy8CnqoDtnzc0xvQgaFlBZAYw
	DvY60Qd7dd6du7InUHM6jJ4Ozzje2WFOiyh3wtEQEQlr892/EElJLZ1bT+69m++7Hzw==
X-Received: by 2002:a19:a706:: with SMTP id q6mr1916267lfe.150.1550140240958;
        Thu, 14 Feb 2019 02:30:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaaX725Ot/PAS9olAYP0DCITrsyigyVqwSyNUUQiCp4vVVKca4uE78OBJzBHs4bWlZXKMch
X-Received: by 2002:a19:a706:: with SMTP id q6mr1916214lfe.150.1550140239961;
        Thu, 14 Feb 2019 02:30:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550140239; cv=none;
        d=google.com; s=arc-20160816;
        b=LJ5mONn/4NCAGSPpwjk93dYCgLDTSwBu4P0mnCVfZiZqyF3AgritdGjHBHLKH4pYmP
         QmiqHr0LfsKbco2OfK4Bj69VSBBIbyOABfktInS6Q9cAnTThWeaurYrXKd+dN9eR6psf
         oAfBem1S/DiIDybQjM3NbFNl2CAh9W4Yy9leIvv4m3gbB6slmCDWd92Rh/Hw+sqVSQHI
         E60nY9E7ZS+ADZyObnkUBmK8IKl+GCjbiBAFDT3JvVjeVM/d2/o6xJiL/cnNnBl8qIWX
         SEU1PZncjuSdAA+JwlnFEV+D//dGNOO3ttDmphGGjP9V1mc+VeW9mEUYX0BJGoijTAeS
         GEow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1NZndyitaWXBd06VmAqbJ+aqzl/CyKYMIHzKOfZvkUY=;
        b=pdqf41f4wvAl4pmpkPvxbR8OqELbRGDnk2oMK7dXXuxGANHPhOpvGE7w9BAXR7H47D
         T9ZDmM9DTMbil+IoIYxD+2Ctpi/cWIICHRqRHhQakKyep92Qj36JQoAqNCpev77lK/T+
         EUS8w6osIfh1qQx/TMURYb3RYkT8Yjuz01QcZk+UzrMKyiut1+/XnS6IBQPoGB4ezpQd
         gyZZSBKVbh7vdHd7Y1G+HxdlL8j4AejchKzpAzDxpn7xp5mTPTRQ/A9e01tGndui3ETp
         D36xM+NjmmwlbD9nsB8lNje3tFE2N1u+O6wI86Ix7Uh++/JmGhU9moPENp6jk4ygQyKW
         kAGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id b10si1520610lfi.120.2019.02.14.02.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:30:39 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1guEHu-00051w-Bd; Thu, 14 Feb 2019 13:30:38 +0300
Subject: Re: [PATCH 2/4] mm: Move nr_deactivate accounting to
 shrink_active_list()
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
 <154998444590.18704.9387109537711017589.stgit@localhost.localdomain>
 <20190213191348.tpwwu3m7o3cmg7ma@ca-dmjordan1.us.oracle.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <4e6627e9-ef49-9636-cc36-ccba295ad9bf@virtuozzo.com>
Date: Thu, 14 Feb 2019 13:30:38 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190213191348.tpwwu3m7o3cmg7ma@ca-dmjordan1.us.oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.02.2019 22:13, Daniel Jordan wrote:
> On Tue, Feb 12, 2019 at 06:14:05PM +0300, Kirill Tkhai wrote:
>> We know, which LRU is not active.
> 
> s/,//
> 
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  mm/vmscan.c |   10 ++++------
>>  1 file changed, 4 insertions(+), 6 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 84542004a277..8d7d55e71511 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2040,12 +2040,6 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
>>  		}
>>  	}
>>  
>> -	if (!is_active_lru(lru)) {
>> -		__count_vm_events(PGDEACTIVATE, nr_moved);
>> -		count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE,
>> -				   nr_moved);
>> -	}
>> -
>>  	return nr_moved;
>>  }
>>  
>> @@ -2137,6 +2131,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
>>  
>>  	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
>>  	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
>> +
>> +	__count_vm_events(PGDEACTIVATE, nr_deactivate);
>> +	__count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE, nr_deactivate);
> 
> Nice, you're using the irq-unsafe one since irqs are already disabled.  I guess
> this was missed in c3cc39118c361.  Do you want to insert a patch before this
> one that converts all instances of this pattern in vmscan.c over?

I had that in plan, but I'm not sure I want to do that in this patchset. Maybe,
something next later on top of this.

> There's a similar oversight in lru_lazyfree_fn with count_memcg_page_event, but
> that'd mean __count_memcg_page_event which is probably overkill.

