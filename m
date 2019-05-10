Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0982C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 15:41:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 240122175B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 15:41:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 240122175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C6A06B0003; Fri, 10 May 2019 11:41:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 979DF6B0007; Fri, 10 May 2019 11:41:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 866536B0008; Fri, 10 May 2019 11:41:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 513646B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 11:41:45 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n4so4285755pgm.19
        for <linux-mm@kvack.org>; Fri, 10 May 2019 08:41:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=0jCaNHW6dM+XxfnryYMb/Iu2qkwB/NjgM/1S3D1MQ3s=;
        b=UQVZD7VJRFc9wrOk8GjqdfAcrxlaOZFctnuErZOlXlcA2Od3G1YDSN3wnrZS6e6Ji+
         gFcCfuEU0YNpUTyLyMPaJBVNZwLv1IJ+Hc/Lqc8K0tEp1InD73kmOgnQlj+PR6fKmUkE
         nFfLOsho6GRpuGgsh+k7EeTXLdpAFt0FaFZG3xy7RcUAC9aYosMVk6mNTwT6J81UCnr/
         lQWD0EFxcL6PGsUvczlmmZTjLM/tTWScIRYTa3m0pdFXaK9b1YDoBUXY6heEurWMPtO9
         EzS7Vs4W5L7f5976T5rWbQXou+VsRVtLETEPZ2FyKpijGauOTiW646KVm/uQyVREP/Gz
         n15w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUD/Ssm/owzV+2A3/b9O5B486juc2xh1wcf81gbjQ/2Lm01ftt1
	3i/N2FPe0D/NdvKaARm2R+wqRtgu3sbKLU2fan3uDEWg0d0NDUE8TcPHXlClNyJ+R/ZoTT8RUsA
	weyFn/1tQKvd9wYiKZhJkwNju6VGMacd0TL7IrR34Wj0WomavxFY27slq6ZNyL9YCSg==
X-Received: by 2002:a63:ba5a:: with SMTP id l26mr14546995pgu.183.1557502904968;
        Fri, 10 May 2019 08:41:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy79eHRz9I4ESG3lhzl9dlUUBFRcU6TXDDd+vToy+TJsuIV9CUBlAKohpT41PosNQA1Rlxy
X-Received: by 2002:a63:ba5a:: with SMTP id l26mr14546892pgu.183.1557502904082;
        Fri, 10 May 2019 08:41:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557502904; cv=none;
        d=google.com; s=arc-20160816;
        b=nzoAd8qpVZ7+02Nxj+KojVha3NUC2PW3zObCuidW2PNTEcsCdl56iBVG2RUpdvGZLo
         8vuZ3hr6lDhCQyBsXHEkunI10+mG6fK3XlMmSReQC3/79iih2ah3NKfy8mwn/j2OBEiL
         NPJE+fbTRNGVOp7NrW4ZhyIvm34wURo7utlas4bzFp7LOtUecqD1mt+BT/FecETHjTr5
         pCpvXjBlqRnd/3ej5umu82OxjvmlI1ZmQuqZML1CkEZcE+2S6L3NyEV/oaoUyYocsK94
         FvRBL345qBbXXL7/14nlaOswcbRtIFV5lgjz4/UVJkivWjAEFG3KyhKIUO0BEOLbd0fg
         VJ+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=0jCaNHW6dM+XxfnryYMb/Iu2qkwB/NjgM/1S3D1MQ3s=;
        b=cVZTBxFtziTYf/BnGbfOk0AjDnl4mLXbnMBFlYRjJUIbnu9KqEoWFuKzL80gqQl7FR
         th2nfpB+kNePKJnV3cTbuOpcUE27uhIXw541dBUOTAUuvYj9rhMwBJK2jrTGCeOeo0GJ
         a2F0gjQw1hgUSXwbpcFRlKfGuWO94ZX7Xv6glBR03LL4AdHBBqW6gHn8A6geppTJrtb1
         3NDVd0AK8KLOLcOAWM03zx7YiQ3r5jeTy3WK9jCIXEYUP2IlgvWaSWXcmscu02c/lR+Y
         0nt1+8N2Z93f/v8N6dTba7Su+ReNf41AJRQtcgXxtoOkVVcuB875TWGIgaD8wJ4os0Ro
         rjHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id q82si9150469pfc.12.2019.05.10.08.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 08:41:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R891e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TRM5wdz_1557502897;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRM5wdz_1557502897)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 10 May 2019 23:41:39 +0800
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
To: "Huang, Ying" <ying.huang@intel.com>
Cc: hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net,
 kirill.shutemov@linux.intel.com, hughd@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
 <87y33fjbvr.fsf@yhuang-dev.intel.com>
 <1fb73973-f409-1411-423b-c48895d3dde8@linux.alibaba.com>
 <87tve3j9jf.fsf@yhuang-dev.intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <c5d74c72-b54f-de22-43b4-8723518bdc0d@linux.alibaba.com>
Date: Fri, 10 May 2019 08:41:34 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <87tve3j9jf.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/9/19 8:03 PM, Huang, Ying wrote:
> Yang Shi <yang.shi@linux.alibaba.com> writes:
>
>> On 5/9/19 7:12 PM, Huang, Ying wrote:
>>> Yang Shi <yang.shi@linux.alibaba.com> writes:
>>>
>>>> Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
>>>> swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
>>>> still gets inc'ed by one even though a whole THP (512 pages) gets
>>>> swapped out.
>>>>
>>>> This doesn't make too much sense to memory reclaim.  For example, direct
>>>> reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
>>>> could fulfill it.  But, if nr_reclaimed is not increased correctly,
>>>> direct reclaim may just waste time to reclaim more pages,
>>>> SWAP_CLUSTER_MAX * 512 pages in worst case.
>>>>
>>>> This change may result in more reclaimed pages than scanned pages showed
>>>> by /proc/vmstat since scanning one head page would reclaim 512 base pages.
>>>>
>>>> Cc: "Huang, Ying" <ying.huang@intel.com>
>>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>>> Cc: Michal Hocko <mhocko@suse.com>
>>>> Cc: Mel Gorman <mgorman@techsingularity.net>
>>>> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
>>>> Cc: Hugh Dickins <hughd@google.com>
>>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>>> ---
>>>> I'm not quite sure if it was the intended behavior or just omission. I tried
>>>> to dig into the review history, but didn't find any clue. I may miss some
>>>> discussion.
>>>>
>>>>    mm/vmscan.c | 6 +++++-
>>>>    1 file changed, 5 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>> index fd9de50..7e026ec 100644
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -1446,7 +1446,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>>>      		unlock_page(page);
>>>>    free_it:
>>>> -		nr_reclaimed++;
>>>> +		/*
>>>> +		 * THP may get swapped out in a whole, need account
>>>> +		 * all base pages.
>>>> +		 */
>>>> +		nr_reclaimed += (1 << compound_order(page));
>>>>      		/*
>>>>    		 * Is there need to periodically free_page_list? It would
>>> Good catch!  Thanks!
>>>
>>> How about to change this to
>>>
>>>
>>>           nr_reclaimed += hpage_nr_pages(page);
>> Either is fine to me. Is this faster than "1 << compound_order(page)"?
> I think the readability is a little better.  And this will become
>
>          nr_reclaimed += 1
>
> if CONFIG_TRANSPARENT_HUAGEPAGE is disabled.

Good point. Will update in v2 soon.

>
> Best Regards,
> Huang, Ying
>
>>> Best Regards,
>>> Huang, Ying

