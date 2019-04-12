Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4704AC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 10:52:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B87902084D
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 10:52:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B87902084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 291496B000A; Fri, 12 Apr 2019 06:52:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 241596B000C; Fri, 12 Apr 2019 06:52:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 158606B026B; Fri, 12 Apr 2019 06:52:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4CA96B000A
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 06:52:15 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id p82so2125767ljp.6
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 03:52:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=NoTwcmZlaxlZxnY+lAEDa4yljOk7WMVd33uX3X2wQrE=;
        b=sIRJ+zoFKPZpoP25FOenpcG2Jd5m7iLTCiAjzkHV42+sCT/Dm7m+6OSvPvT3z25Okx
         WYyuZ8qNgfAoEq8+1jnQrj/CdRU6pgax+JFavBsf+dlWIsJ1x75ye+JLy8xARa6mstQR
         qRjTNxWQb52NrMJl4mbRN++ghlOwHoUod6Os9xuAj5TrB45acbOJzbZnKv94FRyStAuG
         sgloS/5a8vUYMixV8wY9z+DmJivXXX1uOYw0b5pMc+4tHg/xw12qxRClYWBE2XeP0TUZ
         lTgtSqxU3t3x2zg8qKZAFaj/7/wV+OefOs8GqV3Q/p9GlhwYBNtJFox7lUdngd0BqSrt
         9UhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAV8P4UceioM69LnhLZMSBuPnoSAUef+inb6GIgjo8jvmoMBfx5z
	vhPp+jvbqhZgz8xOEoF9jEdhykGoS/eFUgb/XXP71z8FcKDrrd/hQRoT7Lac+W+JxcEhUK/Z9T0
	0IlGIB5X00Pho1dbcD1Oq2aHwHrhLcS+Erw2D2YJV5gRgokb3xUbRwot4OIiqkCM6Fg==
X-Received: by 2002:a2e:b016:: with SMTP id y22mr31152681ljk.133.1555066334920;
        Fri, 12 Apr 2019 03:52:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8FYlpJ7n1KaT75LVyJ9y7fc45GnFKRVoWXTwi8/v2aOQiU7NhitfyCFTW8+OGlsHFRWfu
X-Received: by 2002:a2e:b016:: with SMTP id y22mr31152615ljk.133.1555066333752;
        Fri, 12 Apr 2019 03:52:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555066333; cv=none;
        d=google.com; s=arc-20160816;
        b=DtwS4O3IoaoWMgyzYb/VC1g+8+X4osJQXFqFeYH0oCsbCFylzfJxJ1QRDVxlY8cif0
         uvlNxh6xSP9umPuJBgPOCnLipZBjOjf275nhTRj63CdtFDGcfN3X3xrIBq8idTCstBrV
         2UxM3pRXU4uHZXa6ThgFN5RSleeoJ8mAgIhSHDJiR9KHo9xP2+CBL6pQko42DyFsu2Cb
         vFzO7HUGxL1NK1p5YrFvEYk2Ppn+mKwzUXmiVJdBK8aMstxrH3NZhB99rlxosMxg1yZd
         2Xhjhf5f1YfBY05v10t9MtteiYnxwypD/vCRZnyi1kJa6SH4ea3P+9ET2wvLp92R+buT
         +Fug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=NoTwcmZlaxlZxnY+lAEDa4yljOk7WMVd33uX3X2wQrE=;
        b=abiNs0wJeVq/YoHKhqbHY3BGo9J7lNBw60fya53itf/fNH5slz56gKpnE5GhCgZisz
         DhoYTaQjR5krTF9fAE57WdTuMItJUs1dCKkThqMQ9f+E5dDRT6J95KRbcySUZPOCP7R1
         XtAM/qYpPE9d3+DM9dRx9Z1/q8QhDS5F9AtFtq6RPIHMDwgYU1KEBae0kKp5fdkNzlj1
         VOyU/nel0j/fesVqevpfDchSM3w4714p7okAPYZJhUReBY3sppFZxANa5wvNdEV0xDtt
         NgKxEe1SShFz2iuZx3GB6jZFvef/Pyr28qiAZ5XbJejyyT6lVOJkAQgvDpk/SqCIlm3Z
         bHIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id l21si31290185ljb.192.2019.04.12.03.52.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 03:52:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hEtmy-0007D0-Mj; Fri, 12 Apr 2019 13:52:08 +0300
Subject: Re: [PATCH] mm: Simplify shrink_inactive_list()
To: Baoquan He <bhe@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org,
 dave@stgolabs.net, linux-mm@kvack.org
References: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
 <20190411221310.sz5jtsb563wlaj3v@ca-dmjordan1.us.oracle.com>
 <20190412000547.GB3856@localhost.localdomain>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <2108955f-af24-2772-baa2-69d1935773c8@virtuozzo.com>
Date: Fri, 12 Apr 2019 13:52:08 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190412000547.GB3856@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12.04.2019 03:05, Baoquan He wrote:
> On 04/11/19 at 06:13pm, Daniel Jordan wrote:
>> On Wed, Apr 10, 2019 at 06:07:04PM +0300, Kirill Tkhai wrote:
>>> @@ -1934,17 +1935,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>>>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
>>>  	reclaim_stat->recent_scanned[file] += nr_taken;
>>>  
>>> -	if (current_is_kswapd()) {
>>> -		if (global_reclaim(sc))
>>> -			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
>>> -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD,
>>> -				   nr_scanned);
>>> -	} else {
>>> -		if (global_reclaim(sc))
>>> -			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
>>> -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
>>> -				   nr_scanned);
>>> -	}
>>> +	if (global_reclaim(sc))
>>> +		__count_vm_events(PGSCAN_KSWAPD + is_direct, nr_scanned);
>>> +	__count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD + is_direct,
>>> +			     nr_scanned);
>>
>> Nice to avoid duplication like this, but now it takes looking at
>> vm_event_item.h to understand that (PGSCAN_KSWAPD + is_direct) might mean
>> PGSCAN_DIRECT.
>>
>> What about this pattern for each block instead, which makes the stat used
>> explicit and avoids the header change?
>>
>>        stat = current_is_kswapd() ? PG*_KSWAPD : PG*_DIRECT;
> 
> Yeah, looks nice. Maybe name it as item or event since we have had stat
> locally defined as "struct reclaim_stat stat".
> 
> 	enum vm_event_item item;
> 	...
>         item = current_is_kswapd() ? PG*_KSWAPD : PG*_DIRECT;

Sounds good.

