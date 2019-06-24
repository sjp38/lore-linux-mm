Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E94A5C48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:33:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB4902133F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:33:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB4902133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 592F36B0006; Mon, 24 Jun 2019 08:33:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 543738E0003; Mon, 24 Jun 2019 08:33:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 431DA8E0002; Mon, 24 Jun 2019 08:33:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id D20466B0006
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:33:04 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id d8so1887939lfa.21
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 05:33:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ohghGPcXu2ZseHqkJVKQoJLxHBWZ5eux4qhds0y33jY=;
        b=PIvQE+Xi8XAOyJS7/l9VNEehG6UyLjJhDfGhjiGw4ASFwYLGQqVZvMCEg0U5BBA/bm
         1LGlzNUoZUXkO7D//9BWRNfuB9UWcvHXETXInCmsXLaBTR6Uxj9wcXDgT2Fko4ikwxz5
         7+aMGFvfBOQLl4QZbZ91uAlZa5l2/u0qZZFP3JHFXCf4abTdAgeI4+DJPbV+HeguonLW
         AX+7RiBnz9BvSI/x2HBgokoQ5fTRVwGmjL43I6oV8XqabsBs84D8gFF86sjYVumkB4kP
         32tZzSVkktFThsUVyrrYnfeaekAzKQYzZAKN59PvYfIWyvejCZLpye3fhl+VseiYPh50
         h63A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVwfn2KC4DpRCaFKbl2BGi336oPOB4Ad6YsTrtmC7yq72GJvvSG
	+XNSR4cG7Ol0xhh6kunXKaKrtfSx1e9WMAOe9/KMNVEElm4RwzW8F5jdlU8qKxu7P9B0O1oSyiz
	c474bomDtx6k6O3UKRmqo0FmdyF1pUyiwEt7ZhRK6NRp06nTYbdzkB0tOr9WTNnOSfA==
X-Received: by 2002:a2e:9116:: with SMTP id m22mr8958175ljg.216.1561379584140;
        Mon, 24 Jun 2019 05:33:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz03rdKYu3irVfwIDncq17ZCM8obf7RwY0c0TYOQOdlH8v1tiVMq8tadZaf/AcPgumL5BbI
X-Received: by 2002:a2e:9116:: with SMTP id m22mr8958149ljg.216.1561379583403;
        Mon, 24 Jun 2019 05:33:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561379583; cv=none;
        d=google.com; s=arc-20160816;
        b=eZqUb5UIWSu0psbyhJxzmoyKXPAzfsgWxBu47WK/03+WICaRp194zj+OnRUS+5bvBU
         4zAPzicEsLMY3dbsWlhp63zuKKuKXV3SknrvvAbl1RugSPCchsGNaEmi/LvOxzHj30jf
         TPeBxcm2KicFcygBfkuq4TvuMJSS7/Y/POK1w67jYHZxzO9kmkIEOR3Sxmp1/xc427zi
         yrAsElJuw5mFl/XV6dOuzUIf2/YQ9eQRe1cnlFETM/WIK8AjxQOd8ZsRtTfWpckJjaaY
         eMrocHAKtKTDKpJPcwotu5nswIO84wZrgP5/D7D5T+yeHQe0w2x9hqUxoRX6nbRaJyt4
         MbHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ohghGPcXu2ZseHqkJVKQoJLxHBWZ5eux4qhds0y33jY=;
        b=QSeiPYV1GDQKoKc6bKo8g2qwnGOVJKTXB6jz1rpibMELQPfBGQt4Q2tjcxEDRpm0WA
         3FIzCDz0HLXA4Vd/o91dh3KNmydlhR16Ia7BtdhXArG14en5uijC6/fWUw9qUc008Rrl
         hgguebumHwXCDEadNg905arHYQMb1FunrN4IXMhdkJZjkMpiFH2CNv46kA3UpQSxiE4B
         wRhE+0sKqF/1COLYRosEt02/UTl2DUx8n1hl8zQJxBmsVrpKC3o6yTkNvyCszzwiNGlU
         L9CTcTPYKNKIJrykarj13t8AJcRPrZVoibX2VOvn9w+mXA8t9NlH8uya02dCfqQYrUbv
         qqLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id u6si10517855lfn.115.2019.06.24.05.33.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 05:33:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hfO9c-0003UV-VK; Mon, 24 Jun 2019 15:33:01 +0300
Subject: Re: [PATCH 2/2] mm/vmscan: calculate reclaimed slab caches in all
 reclaim paths
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko
 <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>,
 Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>
References: <1561112086-6169-1-git-send-email-laoar.shao@gmail.com>
 <1561112086-6169-3-git-send-email-laoar.shao@gmail.com>
 <d919ea73-daea-8a77-da0a-d1dc6089fd92@virtuozzo.com>
 <CALOAHbCYgky01_LZF+JGq-ooQY-W=S9SE6yc_MmsmnqG5mmmVg@mail.gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <abcc5922-3d58-f9a3-b040-2871d384ab07@virtuozzo.com>
Date: Mon, 24 Jun 2019 15:33:00 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <CALOAHbCYgky01_LZF+JGq-ooQY-W=S9SE6yc_MmsmnqG5mmmVg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 24.06.2019 15:30, Yafang Shao wrote:
> On Mon, Jun 24, 2019 at 4:53 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>
>> On 21.06.2019 13:14, Yafang Shao wrote:
>>> There're six different reclaim paths by now,
>>> - kswapd reclaim path
>>> - node reclaim path
>>> - hibernate preallocate memory reclaim path
>>> - direct reclaim path
>>> - memcg reclaim path
>>> - memcg softlimit reclaim path
>>>
>>> The slab caches reclaimed in these paths are only calculated in the above
>>> three paths.
>>>
>>> There're some drawbacks if we don't calculate the reclaimed slab caches.
>>> - The sc->nr_reclaimed isn't correct if there're some slab caches
>>>   relcaimed in this path.
>>> - The slab caches may be reclaimed thoroughly if there're lots of
>>>   reclaimable slab caches and few page caches.
>>>   Let's take an easy example for this case.
>>>   If one memcg is full of slab caches and the limit of it is 512M, in
>>>   other words there're approximately 512M slab caches in this memcg.
>>>   Then the limit of the memcg is reached and the memcg reclaim begins,
>>>   and then in this memcg reclaim path it will continuesly reclaim the
>>>   slab caches until the sc->priority drops to 0.
>>>   After this reclaim stops, you will find there're few slab caches left,
>>>   which is less than 20M in my test case.
>>>   While after this patch applied the number is greater than 300M and
>>>   the sc->priority only drops to 3.
>>>
>>> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
>>> ---
>>>  mm/vmscan.c | 7 +++++++
>>>  1 file changed, 7 insertions(+)
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index 18a66e5..d6c3fc8 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -3164,11 +3164,13 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>>>       if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
>>>               return 1;
>>>
>>> +     current->reclaim_state = &sc.reclaim_state;
>>>       trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
>>>
>>>       nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
>>>
>>>       trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
>>> +     current->reclaim_state = NULL;
>>
>> Shouldn't we remove reclaim_state assignment from __perform_reclaim() after this?
>>
> 
> Oh yes. We should remove it. Thanks for pointing out.
> I will post a fix soon.

With the change above, feel free to add my Reviewed-by: to all of the series.

Kirill

