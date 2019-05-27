Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C240C282E3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 02:48:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF78620665
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 02:48:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF78620665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63FE26B026F; Sun, 26 May 2019 22:48:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C82D6B0270; Sun, 26 May 2019 22:48:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 442156B0271; Sun, 26 May 2019 22:48:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07F7E6B026F
	for <linux-mm@kvack.org>; Sun, 26 May 2019 22:48:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b5so10299607plr.16
        for <linux-mm@kvack.org>; Sun, 26 May 2019 19:48:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=iiFm6cpxDmzzpykBzkte+4bbUD5vnffxk+V7FtQbOo0=;
        b=ofd829RjczDkuZ9QEoo6h0ThbjZpxwrrsQrNPyn5aXlnpJCm5Uzn05U9g0sYxJMCLZ
         9z3DLOKT3J9he4ThPUUtAoJZx7wROp9JhAoDvJ+9sMQi7wxaIx14LUHANDUfynn55TId
         hTk37WT+EWimLpywETJt3UEw7c8dh+VwEAkYKaFLOw2+RwrSBkJZZDNd0MmKJJpx7hu7
         CGHsws+EfRwH+FqNE7hCtJpMb20VV9UTwBYyHVlYkzO2owf4Kd9wxkPXtZ6L8C2lrfmX
         R2UTWAY/6K98WJaRMOphqIrj0c6/BOA1GLEqzZTV7G3IaCQhNYjD4EfLOt9TU9oORuOl
         Dq+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWZcnj7NFpYOQQ9Wsb1Ma7Zar9OS++RFFsrARnH22FdN0RJO2Ph
	by8LW0/8pyZxLIXfAdoXdXqkd7ESdHqTsMzp0MI1LrVN0fl7b0+i7v+KD0mNBAAltq9GcihyEgw
	1n+MKXGa5UFH64VjzPigGNTfy4r+47dO9Jgiz7XzoAj8qxw4iX919jSMlHParMlzm7w==
X-Received: by 2002:a17:90a:b78b:: with SMTP id m11mr28437319pjr.106.1558925290605;
        Sun, 26 May 2019 19:48:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKXy/wjaonTP7pJAcwXUqcGAb5o1c4dQOr4dBZ0tOa1RaSaLCXdi7Fjv8/8aEOfFXdgogD
X-Received: by 2002:a17:90a:b78b:: with SMTP id m11mr28437270pjr.106.1558925289758;
        Sun, 26 May 2019 19:48:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558925289; cv=none;
        d=google.com; s=arc-20160816;
        b=0iW14ZvPO0cXAYyAMQUQ4TQwy9BOOkgf5Cf7Kc5o4H2MTC0dl3rNq2bQJGd64H9miZ
         bm5wsKFQblKqIzKOd7Upyow6CvTJjKPmP++DXW0xKA0m+B/5ZX0FtB4YqYd4J1+0rBrB
         iQoDJp/IAyUnaS9sU2k7CDmZKfHsy63gHfNO6xN9wcxulOa6ElcSuajcfaIbpp6DqHgd
         7XcCnOhtf+zU+9Dz3qkzRig6UsHFlOhS5oefmdQAn74ao1NDXaTKqgPZOsLCYnY/IA+N
         l1NxfABCOcBjKAAv0T0laTlfZYFsDR44jWfSRglFkiFTkgW4jS5HyYDZIbvTdeJXhFKb
         P57g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iiFm6cpxDmzzpykBzkte+4bbUD5vnffxk+V7FtQbOo0=;
        b=dhDlSiUshz1892I2/s5fKuqaRuAGFf0erFDCi59V62bR/087zzWsCJf6X0ro1Rj+O/
         9uiBrZ0OjOZ9ueH86uI0lIT4L0yQKfAR+gq/BCXS1+oZsIM5Tjn35osCnFL0iPoZqn+H
         U+tqlxYO3oOfvVb9Ny2yQwKjgbFoC+oSzr9uFtsOrKpdSv0vLrgWbPp/sLfvC+doV3Y6
         AL28jnUm/DGImiHcPjqzr9NRauwqcvRTb1psSy6Pi5iqVa77OIj4jMa+lOR/uCePtelu
         FtsIMI/7hNcvQEWIfvXVF01QscsPkzGWTAHAtr/YNwRWFn6679zBg18FtcW64inPw4id
         EfPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id a5si3294418pgg.543.2019.05.26.19.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 19:48:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSlJH2R_1558925274;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSlJH2R_1558925274)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 27 May 2019 10:47:55 +0800
Subject: Re: [RESEND v5 PATCH 2/2] mm: vmscan: correct some vmscan counters
 for THP swapout
To: "Huang, Ying" <ying.huang@intel.com>
Cc: hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net,
 kirill.shutemov@linux.intel.com, josef@toxicpanda.com, hughd@google.com,
 shakeelb@google.com, hdanton@sina.com, akpm@linux-foundation.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1558922275-31782-1-git-send-email-yang.shi@linux.alibaba.com>
 <1558922275-31782-2-git-send-email-yang.shi@linux.alibaba.com>
 <87muj88x3p.fsf@yhuang-dev.intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <a32dbca4-6239-828b-9f81-f24d582ddd75@linux.alibaba.com>
Date: Mon, 27 May 2019 10:47:51 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <87muj88x3p.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/27/19 10:11 AM, Huang, Ying wrote:
> Yang Shi <yang.shi@linux.alibaba.com> writes:
>
>> Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
>> swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
>> and some other vm counters still get inc'ed by one even though a whole
>> THP (512 pages) gets swapped out.
>>
>> This doesn't make too much sense to memory reclaim.  For example, direct
>> reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
>> could fulfill it.  But, if nr_reclaimed is not increased correctly,
>> direct reclaim may just waste time to reclaim more pages,
>> SWAP_CLUSTER_MAX * 512 pages in worst case.
>>
>> And, it may cause pgsteal_{kswapd|direct} is greater than
>> pgscan_{kswapd|direct}, like the below:
>>
>> pgsteal_kswapd 122933
>> pgsteal_direct 26600225
>> pgscan_kswapd 174153
>> pgscan_direct 14678312
>>
>> nr_reclaimed and nr_scanned must be fixed in parallel otherwise it would
>> break some page reclaim logic, e.g.
>>
>> vmpressure: this looks at the scanned/reclaimed ratio so it won't
>> change semantics as long as scanned & reclaimed are fixed in parallel.
>>
>> compaction/reclaim: compaction wants a certain number of physical pages
>> freed up before going back to compacting.
>>
>> kswapd priority raising: kswapd raises priority if we scan fewer pages
>> than the reclaim target (which itself is obviously expressed in order-0
>> pages). As a result, kswapd can falsely raise its aggressiveness even
>> when it's making great progress.
>>
>> Other than nr_scanned and nr_reclaimed, some other counters, e.g.
>> pgactivate, nr_skipped, nr_ref_keep and nr_unmap_fail need to be fixed
>> too since they are user visible via cgroup, /proc/vmstat or trace
>> points, otherwise they would be underreported.
>>
>> When isolating pages from LRUs, nr_taken has been accounted in base
>> page, but nr_scanned and nr_skipped are still accounted in THP.  It
>> doesn't make too much sense too since this may cause trace point
>> underreport the numbers as well.
>>
>> So accounting those counters in base page instead of accounting THP as
>> one page.
>>
>> nr_dirty, nr_unqueued_dirty, nr_congested and nr_writeback are used by
>> file cache, so they are not impacted by THP swap.
>>
>> This change may result in lower steal/scan ratio in some cases since
>> THP may get split during page reclaim, then a part of tail pages get
>> reclaimed instead of the whole 512 pages, but nr_scanned is accounted
>> by 512, particularly for direct reclaim.  But, this should be not a
>> significant issue.
>>
>> Cc: "Huang, Ying" <ying.huang@intel.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Shakeel Butt <shakeelb@google.com>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>> v5: Fixed sc->nr_scanned double accounting per Huang Ying
>>      Added some comments to address the concern about premature OOM per Hillf Danton
>> v4: Fixed the comments from Johannes and Huang Ying
>> v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
>>      Switched back to use compound_order per Matthew
>>      Fixed more counters per Johannes
>> v2: Added Shakeel's Reviewed-by
>>      Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski
>>
>>   mm/vmscan.c | 42 +++++++++++++++++++++++++++++++-----------
>>   1 file changed, 31 insertions(+), 11 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index b65bc50..f4f4d57 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1118,6 +1118,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>   		int may_enter_fs;
>>   		enum page_references references = PAGEREF_RECLAIM_CLEAN;
>>   		bool dirty, writeback;
>> +		unsigned int nr_pages;
>>   
>>   		cond_resched();
>>   
>> @@ -1129,6 +1130,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>   
>>   		VM_BUG_ON_PAGE(PageActive(page), page);
>>   
>> +		nr_pages = 1 << compound_order(page);
>> +
>> +		/*
>> +		 * Accounted one page for THP for now.  If THP gets swapped
>> +		 * out in a whole, will account all tail pages later to
>> +		 * avoid accounting tail pages twice.
>> +		 */
>>   		sc->nr_scanned++;
>>   
>>   		if (unlikely(!page_evictable(page)))
>> @@ -1250,7 +1258,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>   		case PAGEREF_ACTIVATE:
>>   			goto activate_locked;
>>   		case PAGEREF_KEEP:
>> -			stat->nr_ref_keep++;
>> +			stat->nr_ref_keep += nr_pages;
>>   			goto keep_locked;
>>   		case PAGEREF_RECLAIM:
>>   		case PAGEREF_RECLAIM_CLEAN:
> If the "Accessed bit" of a THP is set in the page table that maps it, it
> will go PAGEREF_ACTIVATE path here.  And the sc->nr_scanned should
> increase 512 instead of 1.  Otherwise sc->nr_activate may be larger than
> sc->nr_scanned.

Yes, it looks so. It seems the easiest way is to add "nr_pages - 1" in 
activate_locked label if the page is still a THP.

If we add all tail pages at the very beginning, then we have to minus 
tail pages when THP gets split, there are a few places do this.

>
> Best Regards,
> Huang, Ying

