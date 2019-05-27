Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EABCEC282E3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 03:00:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98F80216FD
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 03:00:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98F80216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AEBF6B026F; Sun, 26 May 2019 23:00:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4619C6B0270; Sun, 26 May 2019 23:00:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3276C6B0271; Sun, 26 May 2019 23:00:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11AE66B026F
	for <linux-mm@kvack.org>; Sun, 26 May 2019 23:00:25 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id l9so2415618iok.16
        for <linux-mm@kvack.org>; Sun, 26 May 2019 20:00:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=sOWycJ9bzov/RbQtedFxiz5lKfWqGr9DicE2cd8AK5g=;
        b=las9Mry4qdKv4isAlcXhEldAYCWHUwUVL3TBnOh+CUcgqZhMTekNbE1D9YEVD4uqjG
         4goGhzRfScyQmi92/colUw48tU8O5HHKSNeneOq+WhVg9mUuzHwyzkW6yVMQEcxaDXTr
         pLTlYER9MYuV4kqLFNGOsBC+ArBLzeI/RcntK5zyifuErCCjlh3E2tPw3ONSyiovxU3x
         MC9/sTKG54zHO6/csDBAHL9QemhoItXz1XamfEyT/5w/FmkhhdAkVSAr0dXm43i5pogo
         LnllnDxvrvdCqUtu+P9qwJA8JtGGbAkGbWuGbLy1AnCRjlSvOVCAggJKg0SusuzXlqYT
         NvLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWdJobTdWfIpc7yKYObS39BVeU4mUCXfxavO+1Kn2wuhvbyOaO0
	6hCMRt8O0Da0L6+Xqf+G46VI4uaHW9CbeawVc398RvXD9QW20n/yzZ03AbxxY78jOb6scaaBbIr
	RLuUJtut34/ChLd9TVLnzOsjCw19UolnRcZhAzDZq8ePyXAfp7UoDCldXe1VD5TfT2A==
X-Received: by 2002:a24:56d1:: with SMTP id o200mr26600436itb.93.1558926024761;
        Sun, 26 May 2019 20:00:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJZkVP6SNl4SeavICnTuED1Oh1WDl1B15TSKTXcaOrHWm64bFPDaBBTFigdB5fkNCL0dCj
X-Received: by 2002:a24:56d1:: with SMTP id o200mr26600398itb.93.1558926024086;
        Sun, 26 May 2019 20:00:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558926024; cv=none;
        d=google.com; s=arc-20160816;
        b=tyVcFLxtBAWo11lgWswTJ3tHy+hZa8T0/iKiq9DMrRYueM0k4nAydFtQx/BJzUYucV
         SWZUohMjSYTKON11LE8jH0BiMwA+aVQ3jLlelucHcU+UUdEk1GqR+i1VwmipGa+QgecC
         s8WFtRn/+IoIxmfY0Ltn3e6fK11jDgS5bxJ7vUIzZOz9oKkN6L4Z6XnlQ3JKbTac+C5R
         5zJybgDkgjXez7ZJiEy83+2nyBGzebjYhwSHlRVHNvI8zKbNzmD1jMf/0P7Vk3U2IuEm
         IjxPZyuK3ew1RgDZ7eNBSzW1Nwpa3ZBaK9cEsueoeeav/q/XwwO8YUxUuA6XUsUQGsRO
         8UGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=sOWycJ9bzov/RbQtedFxiz5lKfWqGr9DicE2cd8AK5g=;
        b=odA6Bs/NkHn7L9i+IsSha4CmKFKLMnH8sFEmyiZ2ePvuae8sv7GJ1FbLg1RkCJjAfi
         RW6UCvVFf8cr8KHdQ4tJY72fnQCKvrPBsVteMQI75PaFxoHXB+7am7zVLnOFARRmyx/B
         pkcaAHnAjtliQv1/ftptDJX7/hXoaRBwFzORQukDEMWDtx7K7eQGuVyrkr1qb4iZA01m
         wD8/wE4dFa6cOdqcUtWn2Lt1S5kH8s8mJwLEiPZmi0dO2xLzZhHUYcXjUnCWsPj4f70z
         jI2nvjuIg8yVUpkmWXKL6cxCTbrtAF7f7T7pm3fMBq7t5RLfVgd0ZyVshQj3WySMNgRm
         L3Zw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id o3si6230363jao.16.2019.05.26.20.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 20:00:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSlZzX5_1558925998;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSlZzX5_1558925998)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 27 May 2019 10:59:58 +0800
Subject: Re: [RESEND v5 PATCH 2/2] mm: vmscan: correct some vmscan counters
 for THP swapout
From: Yang Shi <yang.shi@linux.alibaba.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net,
 kirill.shutemov@linux.intel.com, josef@toxicpanda.com, hughd@google.com,
 shakeelb@google.com, hdanton@sina.com, akpm@linux-foundation.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1558922275-31782-1-git-send-email-yang.shi@linux.alibaba.com>
 <1558922275-31782-2-git-send-email-yang.shi@linux.alibaba.com>
 <87muj88x3p.fsf@yhuang-dev.intel.com>
 <a32dbca4-6239-828b-9f81-f24d582ddd75@linux.alibaba.com>
Message-ID: <e63dd512-c448-5bec-7461-32cd4e5c8cac@linux.alibaba.com>
Date: Mon, 27 May 2019 10:59:55 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <a32dbca4-6239-828b-9f81-f24d582ddd75@linux.alibaba.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/27/19 10:47 AM, Yang Shi wrote:
>
>
> On 5/27/19 10:11 AM, Huang, Ying wrote:
>> Yang Shi <yang.shi@linux.alibaba.com> writes:
>>
>>> Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
>>> swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
>>> and some other vm counters still get inc'ed by one even though a whole
>>> THP (512 pages) gets swapped out.
>>>
>>> This doesn't make too much sense to memory reclaim.  For example, 
>>> direct
>>> reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one 
>>> THP
>>> could fulfill it.  But, if nr_reclaimed is not increased correctly,
>>> direct reclaim may just waste time to reclaim more pages,
>>> SWAP_CLUSTER_MAX * 512 pages in worst case.
>>>
>>> And, it may cause pgsteal_{kswapd|direct} is greater than
>>> pgscan_{kswapd|direct}, like the below:
>>>
>>> pgsteal_kswapd 122933
>>> pgsteal_direct 26600225
>>> pgscan_kswapd 174153
>>> pgscan_direct 14678312
>>>
>>> nr_reclaimed and nr_scanned must be fixed in parallel otherwise it 
>>> would
>>> break some page reclaim logic, e.g.
>>>
>>> vmpressure: this looks at the scanned/reclaimed ratio so it won't
>>> change semantics as long as scanned & reclaimed are fixed in parallel.
>>>
>>> compaction/reclaim: compaction wants a certain number of physical pages
>>> freed up before going back to compacting.
>>>
>>> kswapd priority raising: kswapd raises priority if we scan fewer pages
>>> than the reclaim target (which itself is obviously expressed in order-0
>>> pages). As a result, kswapd can falsely raise its aggressiveness even
>>> when it's making great progress.
>>>
>>> Other than nr_scanned and nr_reclaimed, some other counters, e.g.
>>> pgactivate, nr_skipped, nr_ref_keep and nr_unmap_fail need to be fixed
>>> too since they are user visible via cgroup, /proc/vmstat or trace
>>> points, otherwise they would be underreported.
>>>
>>> When isolating pages from LRUs, nr_taken has been accounted in base
>>> page, but nr_scanned and nr_skipped are still accounted in THP.  It
>>> doesn't make too much sense too since this may cause trace point
>>> underreport the numbers as well.
>>>
>>> So accounting those counters in base page instead of accounting THP as
>>> one page.
>>>
>>> nr_dirty, nr_unqueued_dirty, nr_congested and nr_writeback are used by
>>> file cache, so they are not impacted by THP swap.
>>>
>>> This change may result in lower steal/scan ratio in some cases since
>>> THP may get split during page reclaim, then a part of tail pages get
>>> reclaimed instead of the whole 512 pages, but nr_scanned is accounted
>>> by 512, particularly for direct reclaim.  But, this should be not a
>>> significant issue.
>>>
>>> Cc: "Huang, Ying" <ying.huang@intel.com>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Mel Gorman <mgorman@techsingularity.net>
>>> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
>>> Cc: Hugh Dickins <hughd@google.com>
>>> Cc: Shakeel Butt <shakeelb@google.com>
>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> ---
>>> v5: Fixed sc->nr_scanned double accounting per Huang Ying
>>>      Added some comments to address the concern about premature OOM 
>>> per Hillf Danton
>>> v4: Fixed the comments from Johannes and Huang Ying
>>> v3: Removed Shakeel's Reviewed-by since the patch has been changed 
>>> significantly
>>>      Switched back to use compound_order per Matthew
>>>      Fixed more counters per Johannes
>>> v2: Added Shakeel's Reviewed-by
>>>      Use hpage_nr_pages instead of compound_order per Huang Ying and 
>>> William Kucharski
>>>
>>>   mm/vmscan.c | 42 +++++++++++++++++++++++++++++++-----------
>>>   1 file changed, 31 insertions(+), 11 deletions(-)
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index b65bc50..f4f4d57 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -1118,6 +1118,7 @@ static unsigned long shrink_page_list(struct 
>>> list_head *page_list,
>>>           int may_enter_fs;
>>>           enum page_references references = PAGEREF_RECLAIM_CLEAN;
>>>           bool dirty, writeback;
>>> +        unsigned int nr_pages;
>>>             cond_resched();
>>>   @@ -1129,6 +1130,13 @@ static unsigned long 
>>> shrink_page_list(struct list_head *page_list,
>>>             VM_BUG_ON_PAGE(PageActive(page), page);
>>>   +        nr_pages = 1 << compound_order(page);
>>> +
>>> +        /*
>>> +         * Accounted one page for THP for now.  If THP gets swapped
>>> +         * out in a whole, will account all tail pages later to
>>> +         * avoid accounting tail pages twice.
>>> +         */
>>>           sc->nr_scanned++;
>>>             if (unlikely(!page_evictable(page)))
>>> @@ -1250,7 +1258,7 @@ static unsigned long shrink_page_list(struct 
>>> list_head *page_list,
>>>           case PAGEREF_ACTIVATE:
>>>               goto activate_locked;
>>>           case PAGEREF_KEEP:
>>> -            stat->nr_ref_keep++;
>>> +            stat->nr_ref_keep += nr_pages;
>>>               goto keep_locked;
>>>           case PAGEREF_RECLAIM:
>>>           case PAGEREF_RECLAIM_CLEAN:
>> If the "Accessed bit" of a THP is set in the page table that maps it, it
>> will go PAGEREF_ACTIVATE path here.  And the sc->nr_scanned should
>> increase 512 instead of 1.  Otherwise sc->nr_activate may be larger than
>> sc->nr_scanned.
>
> Yes, it looks so. It seems the easiest way is to add "nr_pages - 1" in 
> activate_locked label if the page is still a THP.
>
> If we add all tail pages at the very beginning, then we have to minus 
> tail pages when THP gets split, there are a few places do this.

Reiterating all the goto, it seems minus tail pages may be easier since 
there are a lot places which goto activate_locked, keep_locked and keep 
after THP has been added into swap cache. We can't tell if the tail 
pages are accounted or not unless we introduce a new flag, otherwise 
adding tails pages in those labels may account tail pages twice.

>
>>
>> Best Regards,
>> Huang, Ying
>

