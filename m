Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1775C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 13:55:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FA982133D
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 13:55:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FA982133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9CD76B0003; Thu, 23 May 2019 09:55:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4DF16B0005; Thu, 23 May 2019 09:55:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3C3F6B0006; Thu, 23 May 2019 09:55:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BCFD6B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 09:55:56 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id v187so4761814ioe.9
        for <linux-mm@kvack.org>; Thu, 23 May 2019 06:55:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=J3X3Ev06bflyKroFXI8wmeUSigzbqDjtgAg2mc0oR5c=;
        b=NsPDYVl8pP0AQrzoeEBxILVM2oMKdkX9V98UEYEKK6tWaGcJepvzx+eFIWYed1nJ5v
         znhgr8mkl3DDl+ohV85q/8tEUhXda5nv46GOCSezWP6Ii8r3KBhz0EP6pXhkZVtBGiZj
         5i21zbsTsyvfz6VTQLWbBpxTV1aLPM3ZcHgsG4yurXaMZyJUK1Tar7z+gLl++gS0y/ft
         frb4SQ6QnKYCruxNqLM9ShtC19GEzTlAzkRcOv/MJ4u5oqeF0n+5KMgcsmvKEqGEVHH6
         /FOTRtaE50fCglaH8kYjeQDcowAD8JzELof+RlTlXghAV/+7YoQJji4GPW/FRewBBEID
         MN5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXkKhk1VuHKxreM+VGi4RqAN7E2j7aB3IXiRFo1XeeSMUEEpjxh
	FCW1XocsTSSLgO6maGNiMP/26sd60lmwr/0/cyjJvuCWRlddPF9nQ0dDEpReLzkEctQrVvbvQRb
	7UFSXT6ECW/GLUO8BBUsFfA7/5Yq9dLWyX6DWOL3kddqEqQZNJYsoZlIG14x/bEDzog==
X-Received: by 2002:a05:660c:917:: with SMTP id s23mr13129586itj.166.1558619756236;
        Thu, 23 May 2019 06:55:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjFJYuiajo8ZhG0hrauBUzQpvURuqnmww8O36ldPJdfs4COtvdR+hrL/bj/7EaFHf24U84
X-Received: by 2002:a05:660c:917:: with SMTP id s23mr13129544itj.166.1558619755463;
        Thu, 23 May 2019 06:55:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558619755; cv=none;
        d=google.com; s=arc-20160816;
        b=F/7TqJJHXYrBEL6/eI1J9UiEcwFp8jEJlj0qOV8Ui0p3/0v2VjyR9lJzN3jOX8EKY+
         74g8mX34pqpkFGuTG5nM0a4aY2zhU2Ds8a39o7YXuJI47Ic9XVJQl8i3UMtD7mBNzDTe
         MlSpT0r2qmnHBWXcNvMfSQVovtWKcnYcTk/Fbp/ZZAu+xWwfWbukcEcdRrzMwgZ7LlTK
         /9idmrCUBXOFPL850LbVhVfX3+VlH6ie5OM+XxjNYfQ6/deTQ5ggz2LLZ/PRPbgzNOsd
         SuQh3/5ZDR43UKyt7Ofg+UIDeX7TXGko+b3hrqXtTC8rrwuEpeJOpC5kDoVhNmkNr0Q+
         +8nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=J3X3Ev06bflyKroFXI8wmeUSigzbqDjtgAg2mc0oR5c=;
        b=Ih061SnHG9vpnsc7Z9YuL8BbjJVlRQkSKRxqXQYaiHUeCXrfdVJZt7eVt/Bdn2xLl8
         vIsfSU3XPJ9qUeDFITEa5NT8ffHhdvWhO6AnK+SZCypWo7zRslfiMO3Mw6iMiu8PcIlJ
         dbzdZtsE3wDU9dsbYdzlDHWhrZWTH0DLW536P1mEQQAfWgiW1SLGuc1aDcHBqK48+gbJ
         NDxuXhE80kmRTRkq4NtTh3OjqoDGlakj0MBHbOjOsCv0T+SrG9Y0cgBKgIhsmEegQDVd
         sIYPCGGpP3DdVUtGrKH7ro1z26HgswNa5HI6pqTJUOmpDCDoo+zi0Rk8/+N9Na6FG/9q
         2qcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id k14si15376564ioc.104.2019.05.23.06.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 06:55:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R321e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TSTyrdx_1558619738;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSTyrdx_1558619738)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 23 May 2019 21:55:39 +0800
Subject: Re: [v4 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP
 swapout
To: "Huang, Ying" <ying.huang@intel.com>
Cc: hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net,
 kirill.shutemov@linux.intel.com, josef@toxicpanda.com, hughd@google.com,
 shakeelb@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1558578458-83807-1-git-send-email-yang.shi@linux.alibaba.com>
 <1558578458-83807-2-git-send-email-yang.shi@linux.alibaba.com>
 <87lfyx9vtr.fsf@yhuang-dev.intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <18866477-ec08-3571-c7fe-1c8417da6c3a@linux.alibaba.com>
Date: Thu, 23 May 2019 21:55:37 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <87lfyx9vtr.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/23/19 8:52 PM, Huang, Ying wrote:
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
>> v4: Fixed the comments from Johannes and Huang Ying
>> v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
>>      Switched back to use compound_order per Matthew
>>      Fixed more counters per Johannes
>> v2: Added Shakeel's Reviewed-by
>>      Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski
>>
>>   mm/vmscan.c | 34 ++++++++++++++++++++++------------
>>   1 file changed, 22 insertions(+), 12 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index b65bc50..1b35a7a 100644
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
>> @@ -1129,7 +1130,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>   
>>   		VM_BUG_ON_PAGE(PageActive(page), page);
>>   
>> -		sc->nr_scanned++;
>> +		/* Account the number of base pages evne though THP */
> s/evne/even/
>
>> +		nr_pages = 1 << compound_order(page);
>> +		sc->nr_scanned += nr_pages;
>>   
>>   		if (unlikely(!page_evictable(page)))
>>   			goto activate_locked;
>> @@ -1250,7 +1253,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>   		case PAGEREF_ACTIVATE:
>>   			goto activate_locked;
>>   		case PAGEREF_KEEP:
>> -			stat->nr_ref_keep++;
>> +			stat->nr_ref_keep += nr_pages;
>>   			goto keep_locked;
>>   		case PAGEREF_RECLAIM:
>>   		case PAGEREF_RECLAIM_CLEAN:
> If the THP is split, you need
>
>          sc->nr_scanned -= nr_pages - 1;
>
> Otherwise the tail pages will be counted twice.

Yes, it looks so.

>
>> @@ -1315,7 +1318,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>   			if (unlikely(PageTransHuge(page)))
>>   				flags |= TTU_SPLIT_HUGE_PMD;
>>   			if (!try_to_unmap(page, flags)) {
>> -				stat->nr_unmap_fail++;
>> +				stat->nr_unmap_fail += nr_pages;
>>   				goto activate_locked;
>>   			}
>>   		}
>> @@ -1442,7 +1445,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>   
>>   		unlock_page(page);
>>   free_it:
>> -		nr_reclaimed++;
>> +		/*
>> +		 * THP may get swapped out in a whole, need account
>> +		 * all base pages.
>> +		 */
>> +		nr_reclaimed += (1 << compound_order(page));
> Best Regards,
> Huang, Ying

