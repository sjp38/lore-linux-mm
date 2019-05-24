Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26DF5C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 05:38:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 827212133D
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 05:38:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 827212133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE8996B0005; Fri, 24 May 2019 01:38:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C993C6B0006; Fri, 24 May 2019 01:38:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B88EA6B0007; Fri, 24 May 2019 01:38:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7CCC36B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 01:38:14 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g5so6021377pfb.20
        for <linux-mm@kvack.org>; Thu, 23 May 2019 22:38:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=6TgtjZYgrYz0Qbf9+9C56H7jevyrVLrsgYNvF6kfDf8=;
        b=W5tmr+543ljUPQ5Xmh//B6O+dAegtzT5vmn/okkMIm/4EHI8UnM++qBF4kKaUR64u5
         JCm947fcxlZ7ehr1V3GCqGmFLQbAtDjWRS/3t/l5wBqsaauBqKGsktegsMSnBjF+pRJo
         g5L49IuTkL7YbOb2P0NN+hWxxPKfnSFJ2GZQ5zJqIyH0HlBLhaJTsJAguBCyvw+TDnFP
         /WtVF/PO6Ow6DIEbTq4oqy91Hof60fh9oFXSvKGeDQrvBHrrEbAIKwX58rLuV534+3X6
         LmqQ3RTmwvNHM2tFwrqQMh/wZuTd6bwzeT8ji5PRWhWIumyrFRB7uhgL49WSGXck1DyS
         6qhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUC60xhlSawAi0i66/eSDF8/hPN5BJUL0md6eqbb+6VuA4OM+pW
	tXEgabPYFV72gRypD2/tCPUehQXCuO3SM/khZc/5SASbSu3oNCgHjMdaeDz1wY3aOaNUkLJiitA
	5JGQQZXjhJszcqw4hL1jKYjvDscb3i/wJRt8he19JETJ2pigItem10Mj6NnQkZPxu0g==
X-Received: by 2002:a17:902:1ea:: with SMTP id b97mr76526493plb.317.1558676294037;
        Thu, 23 May 2019 22:38:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKlOsyeOSZ3D8xF/VkpsLw/Qm0ekqn2OJOgjQ7QlR0kaFiDyNcZbMEIRH0M0sJqmMN83NU
X-Received: by 2002:a17:902:1ea:: with SMTP id b97mr76526439plb.317.1558676293020;
        Thu, 23 May 2019 22:38:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558676293; cv=none;
        d=google.com; s=arc-20160816;
        b=R9hI6Ln/aXgllEpCl5EYHfDjrl369HxIwzxe7v9mWCx7zeqlpnST/17y7hsmdKjbxk
         y5M0g/LtmUDPR+YZ6chRriHg+GQABw2MCYFcQhGe1C8wj152GdbA75iHnxGJUanWDRwC
         QcYRPb6EwHjsNwqN6TqidoegSP4T/KAbFcN/NVyTCLLu5/3BpHPGDq6Aa946yUmkBwPB
         bGlZnAW2w4ejy0Ys5Qj5Y+qW1h64/I2hA5/NF5NvI0zAtwL+i2wF6JFNLAyOyg+GpF+N
         +FqHs5GvMZS9ilDAji5310LvP04K7cZ1j4balE0Q8SddQFXOV+DPsD01dQCz7vRCuTvq
         DmKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6TgtjZYgrYz0Qbf9+9C56H7jevyrVLrsgYNvF6kfDf8=;
        b=fCK3iXTun7NL3j3AjNNUo616yR3aNT528l/7+6Bp8wQRa/RILVeo87qxL1xK/D+Iwi
         VTvkIL9bjAi7dNZSgLg9e2vnbg0s0YTIzuoSrJjpcBHaTrGcJZku/9yDuV/kX4rFyyp+
         Qn9/2lZEELDMQI46rOM0D2niboWBE5mvN2haASsNVf60/0L89XIInpbYqZxZY0xvp1yn
         GAJ7uHICW7xhPuZCHdKROFMXo8E1hN+NXjUDgcI4qxfP+U/enBhRhcZzxXg/JnQaiAoL
         4Z6vh5x4GpzIFy+dejXUN7pZTS6r/1xwbuB21V/09xWfMqUtQQqBK8EzLy+3aN9a/pH5
         I6SA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id l97si2404399pje.18.2019.05.23.22.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 22:38:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R241e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSXa0AK_1558676276;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSXa0AK_1558676276)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 24 May 2019 13:37:56 +0800
Subject: Re: [v4 PATCH 1/2] mm: vmscan: remove double slab pressure by inc'ing
 sc->nr_scanned
To: Hillf Danton <hdanton@sina.com>
Cc: ying.huang@intel.com, hannes@cmpxchg.org, mhocko@suse.com,
 mgorman@techsingularity.net, kirill.shutemov@linux.intel.com,
 josef@toxicpanda.com, hughd@google.com, shakeelb@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190524041545.10820-1-hdanton@sina.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6a3a7a59-fe63-68b9-cec1-400395a2a199@linux.alibaba.com>
Date: Fri, 24 May 2019 13:37:56 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190524041545.10820-1-hdanton@sina.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/24/19 12:15 PM, Hillf Danton wrote:
> On Thu, 23 May 2019 10:27:37 +0800 Yang Shi wrote:
>> The commit 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
>> has broken up the relationship between sc->nr_scanned and slab pressure.
>> The sc->nr_scanned can't double slab pressure anymore.  So, it sounds no
>> sense to still keep sc->nr_scanned inc'ed.  Actually, it would prevent
>> from adding pressure on slab shrink since excessive sc->nr_scanned would
>> prevent from scan->priority raise.
>>
> The deleted code below wants to get more slab pages shrinked, and it can do
> that without raising scan priority first even after commit 9092c71bb724. Or
> we may face the risk that priority goes up too much faster than thought, per
> the following snippet.

The priority is raised if kswapd_shrink_node() returns false for kswapd 
(The direct reclaim would just raise the priority if sc->nr_reclaimed >= 
sc->nr_to_reclaim). The kswapd_shrink_node() returns "return 
sc->nr_scanned >= sc->nr_to_reclaim". So, the old "double pressure" 
doesn't work as it was designed anymore since it would prevent from make 
"sc->nr_scanned < sc->nr_to_reclaim".

And, the patch 2/2 would not make the priority go up too much since one 
THP would be accounted as 512 base page.

>
> 		/*
> 		 * If we're getting trouble reclaiming, start doing
> 		 * writepage even in laptop mode.
> 		 */
> 		if (sc->priority < DEF_PRIORITY - 2)
>
>> The bonnie test doesn't show this would change the behavior of
>> slab shrinkers.
>>
>> 				w/		w/o
>> 			  /sec    %CP      /sec      %CP
>> Sequential delete: 	3960.6    94.6    3997.6     96.2
>> Random delete: 		2518      63.8    2561.6     64.6
>>
>> The slight increase of "/sec" without the patch would be caused by the
>> slight increase of CPU usage.
>>
>> Cc: Josef Bacik <josef@toxicpanda.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>> v4: Added Johannes's ack
>>
>>   mm/vmscan.c | 5 -----
>>   1 file changed, 5 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 7acd0af..b65bc50 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1137,11 +1137,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>   		if (!sc->may_unmap && page_mapped(page))
>>   			goto keep_locked;
>>   
>> -		/* Double the slab pressure for mapped and swapcache pages */
>> -		if ((page_mapped(page) || PageSwapCache(page)) &&
>> -		    !(PageAnon(page) && !PageSwapBacked(page)))
>> -			sc->nr_scanned++;
>> -
>>   		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
>>   			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
>>   
>> -- 
>> 1.8.3.1
>>
> Best Regards
> Hillf

