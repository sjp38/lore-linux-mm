Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA51DC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:50:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76C612173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:50:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76C612173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13EDD8E0004; Tue, 26 Feb 2019 07:50:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C80C8E0001; Tue, 26 Feb 2019 07:50:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EACD58E0004; Tue, 26 Feb 2019 07:50:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 79A678E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:50:17 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id u13so2240939ljj.13
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:50:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=enoqhJsJruWI+HqZrAeQUNE24yAsX3B+Sm24gozV4nM=;
        b=sLN99/pcjswG+0Gd3uGXTFksDgGNSRICJdeO8to5VFiQzVjSk7XXyl96ISyZI5/Rft
         QuaQ7Swe82sxSfcsxjsRfYLzEQQaohWSlBtLKU7Qh2uTY81iM6j2EQbiv45Ghm5vWrU+
         4G29gh+ub65NqYF90QEix928gBzFmO4zdLMU1eKQ5P+9tE2EfE+GtcMhCft6p3gU6Act
         25p5JMcPe7Y+LKGSzkSy6/Q3YKhWG2l4lKdfU4R8b2mMQZm+Sdt4kMRD0rGjSYU7SehW
         N7lanH4kQrv5JDa6DO1nhf7ZMReEXnBMLWKGA4VuIy6kju5Iqp/1084S6KxzBL8sh9a3
         J7vw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAubnyzJQ5wlBn3/vb19xnc9d7GoDyb5Y1a7WSJLpYpv86QAN+Obw
	zj2NZTLvPpJUUDBJ3U8Bd5Wr2yIYdCn7x3q94ZAmqaPcc8m+CyiYpVoYpdoEuJxw1NcXV+9EEHC
	44ZwA5uz4D5gNrTjzpGyYXPO77FWhEv6NO5B65XTl7eITTH1vInOrGGocM604WnxFyg==
X-Received: by 2002:ac2:4474:: with SMTP id y20mr4797709lfl.46.1551185416922;
        Tue, 26 Feb 2019 04:50:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaS23trmycnD3kcDLJ2WiWLoGYQr81cWa2uLXQVm6donzSMhiCm8hNXFcu2+y6efPDEjQVy
X-Received: by 2002:ac2:4474:: with SMTP id y20mr4797657lfl.46.1551185415871;
        Tue, 26 Feb 2019 04:50:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551185415; cv=none;
        d=google.com; s=arc-20160816;
        b=y7Ne4y+CyVhNyuhiLB/1Q7YSIVEVtdrwxBaQ4Kch/wVyg4HP5413utR9h+Q5aUGE1+
         I+G3ZS6mwzRced8gc2A+uv7hVPEA7PmYU5ySi3tPHplUxcmhULy8zNG0XgPaEiIfXmbX
         KRCP/kDBolbF/RUv0J8kggtrvtl0kwLYmU/ptEuhdvEV3mBK4N9A/cKUcXxuKJDEVV7z
         uFejS/3tQ+W3p8wCEil/pk825Dq5NHoLRCUdFkWg7ybKoJhATk5eVxrpRGDMLSMzqXiH
         YvZh3ATa9AECA491FFNK2V+bhqhBgMu7yLuAg1fXAZ4Chm2fAuXxYAkWkalZXqtgWN7X
         W2NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=enoqhJsJruWI+HqZrAeQUNE24yAsX3B+Sm24gozV4nM=;
        b=ARmzOyVdNfd7Dl/LTSmq8XIZW/vgASlbO0d1PDwEAuWYXTtcyBm1DwBpfq4c+d2ghE
         GuPQirD5wodqNsIhnOxpvsse0P+FN0wwCht7arCT3GyJwToxau1NUN8M9CWNhJfxVxNr
         bITeDU6alY3fIQ3/h9kkzBd89eR6yYj1e4VXrUmAXAQXWaoUDhkI/j1JeTxe7C6s+EGr
         wWVUrtPO3nsdr3tstOpVNb0mb4saQvTT+39CwZKh4w+fKae3ejnzFHvDLIrP3HnpyxjR
         zLGAsrLrgnIfTCm9Dm3yjF2ppQdBXRL9Cf7BurQTnzO5/dXgEbySxoFFYs6i4wEdR1VJ
         N89A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id p69si9644904ljb.75.2019.02.26.04.50.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 04:50:15 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gycBM-0007rk-W3; Tue, 26 Feb 2019 15:50:01 +0300
Subject: Re: [PATCH RFC] mm/vmscan: try to protect active working set of
 cgroup from reclaim.
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
 Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
 Mel Gorman <mgorman@techsingularity.net>, Roman Gushchin <guro@fb.com>,
 Shakeel Butt <shakeelb@google.com>
References: <20190222175825.18657-1-aryabinin@virtuozzo.com>
 <20190222191552.GA15922@cmpxchg.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <f752c208-599c-9b5a-bc42-e4282df43616@virtuozzo.com>
Date: Tue, 26 Feb 2019 15:50:19 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190222191552.GA15922@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/22/19 10:15 PM, Johannes Weiner wrote:
> On Fri, Feb 22, 2019 at 08:58:25PM +0300, Andrey Ryabinin wrote:
>> In a presence of more than 1 memory cgroup in the system our reclaim
>> logic is just suck. When we hit memory limit (global or a limit on
>> cgroup with subgroups) we reclaim some memory from all cgroups.
>> This is sucks because, the cgroup that allocates more often always wins.
>> E.g. job that allocates a lot of clean rarely used page cache will push
>> out of memory other jobs with active relatively small all in memory
>> working set.
>>
>> To prevent such situations we have memcg controls like low/max, etc which
>> are supposed to protect jobs or limit them so they to not hurt others.
>> But memory cgroups are very hard to configure right because it requires
>> precise knowledge of the workload which may vary during the execution.
>> E.g. setting memory limit means that job won't be able to use all memory
>> in the system for page cache even if the rest the system is idle.
>> Basically our current scheme requires to configure every single cgroup
>> in the system.
>>
>> I think we can do better. The idea proposed by this patch is to reclaim
>> only inactive pages and only from cgroups that have big
>> (!inactive_is_low()) inactive list. And go back to shrinking active lists
>> only if all inactive lists are low.
> 
> Yes, you are absolutely right.
> 
> We shouldn't go after active pages as long as there are plenty of
> inactive pages around. That's the global reclaim policy, and we
> currently fail to translate that well to cgrouped systems.
> 
> Setting group protections or limits would work around this problem,
> but they're kind of a red herring. We shouldn't ever allow use-once
> streams to push out hot workingsets, that's a bug.
> 
>> @@ -2489,6 +2491,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>>  
>>  		scan >>= sc->priority;
>>  
>> +		if (!sc->may_shrink_active && inactive_list_is_low(lruvec,
>> +						file, memcg, sc, false))
>> +			scan = 0;
>> +
>>  		/*
>>  		 * If the cgroup's already been deleted, make sure to
>>  		 * scrape out the remaining cache.
>> @@ -2733,6 +2739,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>>  	unsigned long nr_reclaimed, nr_scanned;
>>  	bool reclaimable = false;
>> +	bool retry;
>>  
>>  	do {
>>  		struct mem_cgroup *root = sc->target_mem_cgroup;
>> @@ -2742,6 +2749,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>  		};
>>  		struct mem_cgroup *memcg;
>>  
>> +		retry = false;
>> +
>>  		memset(&sc->nr, 0, sizeof(sc->nr));
>>  
>>  		nr_reclaimed = sc->nr_reclaimed;
>> @@ -2813,6 +2822,13 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>  			}
>>  		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
>>  
>> +		if ((sc->nr_scanned - nr_scanned) == 0 &&
>> +		     !sc->may_shrink_active) {
>> +			sc->may_shrink_active = 1;
>> +			retry = true;
>> +			continue;
>> +		}
> 
> Using !scanned as the gate could be a problem. There might be a cgroup
> that has inactive pages on the local level, but when viewed from the
> system level the total inactive pages in the system might still be low
> compared to active ones. In that case we should go after active pages.
> 
> Basically, during global reclaim, the answer for whether active pages
> should be scanned or not should be the same regardless of whether the
> memory is all global or whether it's spread out between cgroups.
> 
> The reason this isn't the case is because we're checking the ratio at
> the lruvec level - which is the highest level (and identical to the
> node counters) when memory is global, but it's at the lowest level
> when memory is cgrouped.
> 
> So IMO what we should do is:
> 
> - At the beginning of global reclaim, use node_page_state() to compare
>   the INACTIVE_FILE:ACTIVE_FILE ratio and then decide whether reclaim
>   can go after active pages or not. Regardless of what the ratio is in
>   individual lruvecs.
> 
> - And likewise at the beginning of cgroup limit reclaim, walk the
>   subtree starting at sc->target_mem_cgroup, sum up the INACTIVE_FILE
>   and ACTIVE_FILE counters, and make inactive_is_low() decision on
>   those sums.
> 

Sounds reasonable.

