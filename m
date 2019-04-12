Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D715C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 11:33:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEEBC2084D
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 11:33:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEEBC2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 709E36B000C; Fri, 12 Apr 2019 07:33:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68EB26B0010; Fri, 12 Apr 2019 07:33:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5092E6B026B; Fri, 12 Apr 2019 07:33:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id E07876B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:33:32 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id v18so2141073lja.21
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 04:33:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=xCs4qvhxMuauY9wt7JDl8hE09v4vv+TkSDrtSgFIoc8=;
        b=HlULUtDT9NTH/o+39TpaKut87my39ZncaIQDSDo2bvTCmvdAeSIt8HKaB4AlWDQTF0
         Q18vb6WQSUGMAdpnpQcMgHWwJC2+dUkwh8GXBP8ugHYcobAS9kzdj2sZZQe5txP5oqC1
         e+OuK3HjbOwMTiqRr11wTdRVosHSPPbZyhZXudQBDGGDj5YmXoivqMuohVd8cs97Jmx7
         ahYQ2Zq8/uRBFhiJonA511krVUI3aOlRQXZF4Xmo43r52Zmj6cyB6YPVpHLHQ0TgghDK
         QYnBs4FmunDupLREkhgwHAKIzT7o7+aiv2VrLZdo6TQGv8V3VDwATfD/MQ//jg8tNCIf
         RWxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWEgoiuQwzu+zsdR3s+1oZfExOg5Xw5netxhZxdVXhtTqxsbsHF
	Ym0MphWr2qyN8QERtyAx8HX4Jlhmb9WW9hL7lzFdlIPrrSYZnL1k0qbygaTlNUcTApLEBmQq28g
	Kj458Bfhds3nrRaplx07zZaUBYbrYFcovYZRR6wX7/A/ZoPh1CJFIdGDkhF8+US1Q1g==
X-Received: by 2002:a2e:6c0f:: with SMTP id h15mr5499431ljc.155.1555068812304;
        Fri, 12 Apr 2019 04:33:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz683ZxE1Tpvb5ByRt+5xd4lVHk2xZW5gTeYTzjM3QaYtnt+ETZo9f4iP0rihHG8tpt+27Y
X-Received: by 2002:a2e:6c0f:: with SMTP id h15mr5499375ljc.155.1555068811463;
        Fri, 12 Apr 2019 04:33:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555068811; cv=none;
        d=google.com; s=arc-20160816;
        b=GdV0dEpzxESvhljuuwXmVPnlmiz97X3Ychf4D7KghgUaYNXeI9LI3kz1qaxvaRMhV+
         AOen6UUwsFeqVyalrWNV0DWT2ehQQ6+j89DvdDEXlD8A3Vbgl4t4AZqwzKDbARDroaKN
         htzBwjbIjHZFtZKTUsiXIYxq+jNZ/mx2ksGvY7UWl2ooGe49A54tbZ0eRVaAxsjAANxv
         6bZY/flW2usMq8b0EpJxSwZhb+WVW4qDiVqYwwDktLhapHwVSBcrnunUnktdxAwBN3XS
         +Zb6g/AgafI7mn86I8cYw6JbZH7q68/sEEgKZeznBkvUmn7xTtCYDdJWTUb1mBo4T30O
         2ahw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xCs4qvhxMuauY9wt7JDl8hE09v4vv+TkSDrtSgFIoc8=;
        b=InwGVK/bzE/aT16NJJJ+9gYmT57y2jMERmGhSXyupklOoDXASXnUI6vgb92bPX74ZJ
         BKrp7sjSu3fmMuYRQXn9uChl/HmTsLZT9Xp2kK0FeKT+qHZY/abHoNb8gyQXb9Z9Rqyg
         5YkGRqyNpw1g946FrzLbYZNW2mG3miZMxi604WDCEsrub2HTiqdTahVeH6WhQYnzFLVd
         vIfgkcU1BCKXCWGvm5kvBqhaHU2HAjNSkVVQnXrDg2YEp8k7tOk5Fv9ydziCcDEPxW46
         aJ/iisItJmTTPJCpUewLio5rWziaFssvc/0AeWVTXLTWqeigUgEzEsOb0wFpuyT9RZwk
         wyBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id y14si31975545ljy.5.2019.04.12.04.33.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 04:33:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hEuQy-0007Sw-3v; Fri, 12 Apr 2019 14:33:28 +0300
Subject: Re: [PATCH v2] mm: Simplify shrink_inactive_list()
To: Michal Hocko <mhocko@suse.com>
Cc: Baoquan He <bhe@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>,
 akpm@linux-foundation.org, hannes@cmpxchg.org, dave@stgolabs.net,
 linux-mm@kvack.org
References: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
 <20190411221310.sz5jtsb563wlaj3v@ca-dmjordan1.us.oracle.com>
 <20190412000547.GB3856@localhost.localdomain>
 <26e570cd-dbee-575c-3a23-ff8798de77dc@virtuozzo.com>
 <20190412113131.GB5223@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <4ac7242c-54d3-cd44-2cd9-5d5c746e2690@virtuozzo.com>
Date: Fri, 12 Apr 2019 14:33:27 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190412113131.GB5223@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12.04.2019 14:31, Michal Hocko wrote:
> On Fri 12-04-19 13:55:59, Kirill Tkhai wrote:
>> This merges together duplicating patterns of code.
> 
> OK, this looks better than the previous version
> 
>> Also, replace count_memcg_events() with its
>> irq-careless namesake.
> 
> Why?

Since interrupts are already disabled, and there is
no a sense to disable them twice.

> 
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>>
>> v2: Introduce local variable.
>> ---
>>  mm/vmscan.c |   31 +++++++++----------------------
>>  1 file changed, 9 insertions(+), 22 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 836b28913bd7..d96efff59a11 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1907,6 +1907,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>>  	unsigned long nr_taken;
>>  	struct reclaim_stat stat;
>>  	int file = is_file_lru(lru);
>> +	enum vm_event_item item;
>>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>>  	bool stalled = false;
>> @@ -1934,17 +1935,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
>>  	reclaim_stat->recent_scanned[file] += nr_taken;
>>  
>> -	if (current_is_kswapd()) {
>> -		if (global_reclaim(sc))
>> -			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
>> -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD,
>> -				   nr_scanned);
>> -	} else {
>> -		if (global_reclaim(sc))
>> -			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
>> -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
>> -				   nr_scanned);
>> -	}
>> +	item = current_is_kswapd() ? PGSCAN_KSWAPD : PGSCAN_DIRECT;
>> +	if (global_reclaim(sc))
>> +		__count_vm_events(item, nr_scanned);
>> +	__count_memcg_events(lruvec_memcg(lruvec), item, nr_scanned);
>>  	spin_unlock_irq(&pgdat->lru_lock);
>>  
>>  	if (nr_taken == 0)
>> @@ -1955,17 +1949,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>>  
>>  	spin_lock_irq(&pgdat->lru_lock);
>>  
>> -	if (current_is_kswapd()) {
>> -		if (global_reclaim(sc))
>> -			__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
>> -		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_KSWAPD,
>> -				   nr_reclaimed);
>> -	} else {
>> -		if (global_reclaim(sc))
>> -			__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
>> -		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
>> -				   nr_reclaimed);
>> -	}
>> +	item = current_is_kswapd() ? PGSTEAL_KSWAPD : PGSTEAL_DIRECT;
>> +	if (global_reclaim(sc))
>> +		__count_vm_events(item, nr_reclaimed);
>> +	__count_memcg_events(lruvec_memcg(lruvec), item, nr_reclaimed);
>>  	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
>>  	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
>>  
> 

