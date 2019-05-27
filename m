Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC815C282E3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 03:15:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8048A21707
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 03:15:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8048A21707
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00F8D6B0007; Sun, 26 May 2019 23:15:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDBC36B0266; Sun, 26 May 2019 23:15:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA3816B026F; Sun, 26 May 2019 23:15:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD6A86B0007
	for <linux-mm@kvack.org>; Sun, 26 May 2019 23:15:34 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id q12so8228908oth.15
        for <linux-mm@kvack.org>; Sun, 26 May 2019 20:15:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=DbciZNzcsy+tYyk7HdnlATWT92JAe6UBFn6LE+lznuI=;
        b=gfb0WKOM0rJ/3CSBXhN0mU17WW6GvNC6gxn/E5qLm0Y1eBSz2eXVKiYd2AAUBGoMRk
         Lydrhl590+diDKjv3vXmQ/9uBi4Ow87hIDbjQBX2CNf7PROWHUB1oSa6vUkZ9/9cck84
         nHdGHmMJY5YOeIfs9S56nagDiSMrxYh+qrba+3SWDvMfsJE6Flu+eh/BwVrekUg3/d1R
         z/Vo+7ijLyzBscfVF+Y6MEA/XCxU+LGAe2Y3yx1pat4OgxzVKqcvbwFUquRneIRlsZ1R
         cdzcMvg38PsPJRxKrGPl2ZehKV8pbqeaqrUUGfAPHMlfZTd1Ss2QwtNkNdUfFgleWk27
         64TA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXhN9o3eNn9b18aPYc6mKqSnFM/pWVvzVUvPLhE9SOZWbGaz3Hb
	v/ztOioI4of0mhsc/nGFjZtklO1g9KsN405Mi3BrKM7C1VpITiI+QRUimLyz7FJ8gme86v5vlGV
	F4cxWm2BAEctjdPPAgtL5g8szFOKEOLz7JDCHQw86kQCfcuBPDtRqlT+/LN2kPR+f8Q==
X-Received: by 2002:aca:bb07:: with SMTP id l7mr8283539oif.124.1558926934350;
        Sun, 26 May 2019 20:15:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4PP3zmbUlfyAuthIjkE9SQTEwMkr8CB8S7LxOdg0VsiqzEzOkB12FtNtxT4IYb1IMihxz
X-Received: by 2002:aca:bb07:: with SMTP id l7mr8283513oif.124.1558926933560;
        Sun, 26 May 2019 20:15:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558926933; cv=none;
        d=google.com; s=arc-20160816;
        b=x1biyOwKnvis4S76hMSadToOJnQhnWyiKJI2TftWudE1R4fFptvffne4IWiHJemzwz
         vexHyVTL/cUu9rNWOmlW0Jl8Wt+euSJpaKFN2BAns2ylOiHqIgN6SQt9XspBH6owJkeA
         Xn5rQoCjKe+CvZcCmtPbXemUXVKbn89miuBwv1BpkkluAbUnZOMy/c7L26yAN6hS1nVJ
         UdZqlpccch4aYE4AmcvIgOjQBRwGeZHtw4xlQWleVwek8UkAL0324q7UyT7nF1p0NuY/
         jQA0q2L8IL+SzoThSOaixHaOdLMTCvpwC4fwMHaFOAZvRhMzcT87g3WtZr3adWYB3MvU
         ww1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DbciZNzcsy+tYyk7HdnlATWT92JAe6UBFn6LE+lznuI=;
        b=mi7q915C0Qa9nS7epANQtqJagHoIENSYNw93/QfiJR5CvtLIeg9ROlrYL8H7v7uFyl
         SZuy7xfbjKPbr8iEIk9dujehxGy1Q0gKVshzFC3c98c69zbBHWPZ+hFjvbAYzXsFD/Sm
         +0phFg/ms/DX7cu3rC8R2Z76cB8iov7+WviczvWRjMocenJTqadntwj13iYh3oWq6Glp
         WM4Py5lpOQbka3X9J4v4zB7l6AKykjh9LHKaqdCt4xezBfMPUD6z2HEEdMlM3TbZ2nXd
         fZ/TrBO7zULgWBw/NEMjAGK16uWyQ+NdWdx82vtn04V2uILYu++wpRV7X4aaDfeVNUdO
         tOJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id i8si5609453oih.11.2019.05.26.20.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 20:15:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R421e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSm5gg0_1558926918;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSm5gg0_1558926918)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 27 May 2019 11:15:19 +0800
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
 <a32dbca4-6239-828b-9f81-f24d582ddd75@linux.alibaba.com>
 <87imtw8uxs.fsf@yhuang-dev.intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <7035abc1-6f56-cce0-6a0b-29fceeefe339@linux.alibaba.com>
Date: Mon, 27 May 2019 11:15:15 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <87imtw8uxs.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/27/19 10:58 AM, Huang, Ying wrote:
> Yang Shi <yang.shi@linux.alibaba.com> writes:
>
>> On 5/27/19 10:11 AM, Huang, Ying wrote:
>>> Yang Shi <yang.shi@linux.alibaba.com> writes:
>>>
>>>> Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
>>>> swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
>>>> and some other vm counters still get inc'ed by one even though a whole
>>>> THP (512 pages) gets swapped out.
>>>>
>>>> This doesn't make too much sense to memory reclaim.  For example, direct
>>>> reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
>>>> could fulfill it.  But, if nr_reclaimed is not increased correctly,
>>>> direct reclaim may just waste time to reclaim more pages,
>>>> SWAP_CLUSTER_MAX * 512 pages in worst case.
>>>>
>>>> And, it may cause pgsteal_{kswapd|direct} is greater than
>>>> pgscan_{kswapd|direct}, like the below:
>>>>
>>>> pgsteal_kswapd 122933
>>>> pgsteal_direct 26600225
>>>> pgscan_kswapd 174153
>>>> pgscan_direct 14678312
>>>>
>>>> nr_reclaimed and nr_scanned must be fixed in parallel otherwise it would
>>>> break some page reclaim logic, e.g.
>>>>
>>>> vmpressure: this looks at the scanned/reclaimed ratio so it won't
>>>> change semantics as long as scanned & reclaimed are fixed in parallel.
>>>>
>>>> compaction/reclaim: compaction wants a certain number of physical pages
>>>> freed up before going back to compacting.
>>>>
>>>> kswapd priority raising: kswapd raises priority if we scan fewer pages
>>>> than the reclaim target (which itself is obviously expressed in order-0
>>>> pages). As a result, kswapd can falsely raise its aggressiveness even
>>>> when it's making great progress.
>>>>
>>>> Other than nr_scanned and nr_reclaimed, some other counters, e.g.
>>>> pgactivate, nr_skipped, nr_ref_keep and nr_unmap_fail need to be fixed
>>>> too since they are user visible via cgroup, /proc/vmstat or trace
>>>> points, otherwise they would be underreported.
>>>>
>>>> When isolating pages from LRUs, nr_taken has been accounted in base
>>>> page, but nr_scanned and nr_skipped are still accounted in THP.  It
>>>> doesn't make too much sense too since this may cause trace point
>>>> underreport the numbers as well.
>>>>
>>>> So accounting those counters in base page instead of accounting THP as
>>>> one page.
>>>>
>>>> nr_dirty, nr_unqueued_dirty, nr_congested and nr_writeback are used by
>>>> file cache, so they are not impacted by THP swap.
>>>>
>>>> This change may result in lower steal/scan ratio in some cases since
>>>> THP may get split during page reclaim, then a part of tail pages get
>>>> reclaimed instead of the whole 512 pages, but nr_scanned is accounted
>>>> by 512, particularly for direct reclaim.  But, this should be not a
>>>> significant issue.
>>>>
>>>> Cc: "Huang, Ying" <ying.huang@intel.com>
>>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>>> Cc: Michal Hocko <mhocko@suse.com>
>>>> Cc: Mel Gorman <mgorman@techsingularity.net>
>>>> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
>>>> Cc: Hugh Dickins <hughd@google.com>
>>>> Cc: Shakeel Butt <shakeelb@google.com>
>>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>>> ---
>>>> v5: Fixed sc->nr_scanned double accounting per Huang Ying
>>>>       Added some comments to address the concern about premature OOM per Hillf Danton
>>>> v4: Fixed the comments from Johannes and Huang Ying
>>>> v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
>>>>       Switched back to use compound_order per Matthew
>>>>       Fixed more counters per Johannes
>>>> v2: Added Shakeel's Reviewed-by
>>>>       Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski
>>>>
>>>>    mm/vmscan.c | 42 +++++++++++++++++++++++++++++++-----------
>>>>    1 file changed, 31 insertions(+), 11 deletions(-)
>>>>
>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>> index b65bc50..f4f4d57 100644
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -1118,6 +1118,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>>>    		int may_enter_fs;
>>>>    		enum page_references references = PAGEREF_RECLAIM_CLEAN;
>>>>    		bool dirty, writeback;
>>>> +		unsigned int nr_pages;
>>>>      		cond_resched();
>>>>    @@ -1129,6 +1130,13 @@ static unsigned long
>>>> shrink_page_list(struct list_head *page_list,
>>>>      		VM_BUG_ON_PAGE(PageActive(page), page);
>>>>    +		nr_pages = 1 << compound_order(page);
>>>> +
>>>> +		/*
>>>> +		 * Accounted one page for THP for now.  If THP gets swapped
>>>> +		 * out in a whole, will account all tail pages later to
>>>> +		 * avoid accounting tail pages twice.
>>>> +		 */
>>>>    		sc->nr_scanned++;
>>>>      		if (unlikely(!page_evictable(page)))
>>>> @@ -1250,7 +1258,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>>>    		case PAGEREF_ACTIVATE:
>>>>    			goto activate_locked;
>>>>    		case PAGEREF_KEEP:
>>>> -			stat->nr_ref_keep++;
>>>> +			stat->nr_ref_keep += nr_pages;
>>>>    			goto keep_locked;
>>>>    		case PAGEREF_RECLAIM:
>>>>    		case PAGEREF_RECLAIM_CLEAN:
>>> If the "Accessed bit" of a THP is set in the page table that maps it, it
>>> will go PAGEREF_ACTIVATE path here.  And the sc->nr_scanned should
>>> increase 512 instead of 1.  Otherwise sc->nr_activate may be larger than
>>> sc->nr_scanned.
>> Yes, it looks so. It seems the easiest way is to add "nr_pages - 1" in
>> activate_locked label if the page is still a THP.
> Add keep_locked label.
>
>> If we add all tail pages at the very beginning, then we have to minus
>> tail pages when THP gets split, there are a few places do this.
> I think we can do that in one place too.  Just before try_to_unmap() via
> checking nr_pages and page order.  And we need to update nr_pages if
> the THP is split anyway.

Yes, I agree.

>
> Best Regards,
> Huang, Ying
>
>>> Best Regards,
>>> Huang, Ying

