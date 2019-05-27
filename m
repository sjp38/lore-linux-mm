Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9A14C28CBF
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:55:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9039D2070D
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:55:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9039D2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 335C26B0270; Mon, 27 May 2019 03:55:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E7116B0271; Mon, 27 May 2019 03:55:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D4296B0272; Mon, 27 May 2019 03:55:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D65F46B0270
	for <linux-mm@kvack.org>; Mon, 27 May 2019 03:55:46 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id x14so10748862pln.6
        for <linux-mm@kvack.org>; Mon, 27 May 2019 00:55:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version:content-transfer-encoding;
        bh=HEVptXv3vS4UM3D+0CZNFIR8J0y3C1pPEfMQkYUBGEk=;
        b=MkNPm1wW8xNCGXb2qGz3sQobqk6MfTY/2hgpMAcLoR6m4cjsHapyPzYeVlTPx+Qjlr
         FZQOKdY3tR/4BpuCjysnopJcrxzZNGj6UHvfcVgo18fLkfv9mP96XbW1PIzMDfO0rvzR
         995pgHKoEjW8wQvsffixRVlcLTV/PxK2HTPrt6Tkr1UKENXOLHU5pS/18G3a00jKc1I7
         2nB9W4hWhYGkVMqkfc4qRIkLqigMzg4cpk7aGOoG2UkGKTVYde3O87rXZQgkATWQ383b
         T5yHQxMMe6xGMCbrHm6Cm3Pg2d2GZgQc9MsVrAuGH7VZls1NM/Vas8XDZroi+dZFfh5A
         H8/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVQ6W7WASUfLD2iJ8jefgfGbuMLTw0rF5lCXs0S+/dBYs1EQ/xX
	ElKZz5AajrMfzyvmXB6FbPqp+1royI22JKhHF+a1q+DPeDVGE1L0IK/0BRjOpgKgbUcQ8nBWW0t
	pvAreR/+9bTqQys/ohK6c/VssAqAn/kuNKOdHojXDW/bDHCF6twDsQZFk5cBX17z3dw==
X-Received: by 2002:a17:902:e492:: with SMTP id cj18mr66371423plb.341.1558943746519;
        Mon, 27 May 2019 00:55:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDdWREgejykqI1N5lpcqwhDnwu78YI6+HsPUzv0XaRnq+5gcHqgNkLKt9fxwFNJyDr1u3Q
X-Received: by 2002:a17:902:e492:: with SMTP id cj18mr66371356plb.341.1558943745721;
        Mon, 27 May 2019 00:55:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558943745; cv=none;
        d=google.com; s=arc-20160816;
        b=XehWdscyN84VLwv7KaiHUfhzl7m6H+7b6EmEFHvyBnWoSFmSo2kItDaZeC0po847hf
         UGai6Mfz8c6Ac6N9Bs18/0f/s+kdD5amCA9JZWBSVJM2We7xugE9MjDe7FeZh1m+solu
         BNBKeSXRGm/4RCFTMRaHa1sDjSPvU17lYUsuYTOmk/J1Hggc3j6m57mwJc9KIGWl7HmO
         +L8g+qxYw6oz8vuYmKh8wfKhS3nKdCUaY4T/jnDgaVSFsUMRIknqedRrKxvzEOaIQ+Ht
         yXkRrjYXJGILxZqBJgFEjcs7jdZSSg03sew9+SKX/hjchHZN4ziyTgfGQa+P5diLrw1K
         lv1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id
         :in-reply-to:date:references:subject:cc:to:from;
        bh=HEVptXv3vS4UM3D+0CZNFIR8J0y3C1pPEfMQkYUBGEk=;
        b=oQzuO4qM/J/ZxcOAQdNBwLsV7ZinCNIR9EJHpTR7o2El1p+hkYbzqKj4iWrb/MCga7
         P8nLDP78rYi8fYTsBiWOEty4RuO5apHSv/AzWR8RTuiTv9+96/4crRGaV4goB+8TopR5
         LVI6/+bSFAsw9r4l2YkmtM+NoW24wr6ixkUi5U5uTseeS5LZ3p5SD2p+Dn16M3QiPQmq
         gQWU6cQsF+GFwrhjLjw+xommHm024BSGGiw64mg0NYwBkokViqDTuGBbN2KiizQyTWM4
         pP8cQ6394uzrc3vhtI4fgOOjFIr6dkoWF76yKf4SvNeZZmxRJENXbZ+1Uisx52jpTUVG
         +alg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id d21si15828574pgv.353.2019.05.27.00.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 00:55:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 May 2019 00:55:44 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by orsmga008.jf.intel.com with ESMTP; 27 May 2019 00:55:42 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: <hannes@cmpxchg.org>,  <mhocko@suse.com>,  <mgorman@techsingularity.net>,  <kirill.shutemov@linux.intel.com>,  <josef@toxicpanda.com>,  <hughd@google.com>,  <shakeelb@google.com>,  <hdanton@sina.com>,  <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>
Subject: Re: [v6 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
References: <1558929166-3363-1-git-send-email-yang.shi@linux.alibaba.com>
	<1558929166-3363-2-git-send-email-yang.shi@linux.alibaba.com>
	<87ef4k8jgs.fsf@yhuang-dev.intel.com>
	<aa145948-ac14-c89b-d847-ffca81d8dbdf@linux.alibaba.com>
Date: Mon, 27 May 2019 15:55:41 +0800
In-Reply-To: <aa145948-ac14-c89b-d847-ffca81d8dbdf@linux.alibaba.com> (Yang
	Shi's message of "Mon, 27 May 2019 15:40:52 +0800")
Message-ID: <87a7f88h6q.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yang Shi <yang.shi@linux.alibaba.com> writes:

> On 5/27/19 3:06 PM, Huang, Ying wrote:
>> Yang Shi <yang.shi@linux.alibaba.com> writes:
>>
>>> Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
>>> swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
>>> and some other vm counters still get inc'ed by one even though a whole
>>> THP (512 pages) gets swapped out.
>>>
>>> This doesn't make too much sense to memory reclaim.  For example, direct
>>> reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
>>> could fulfill it.  But, if nr_reclaimed is not increased correctly,
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
>>> nr_reclaimed and nr_scanned must be fixed in parallel otherwise it would
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
>>> page, but nr_scanned and nr_skipped are still accounted in THP.  It
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
>>> by 512, particularly for direct reclaim.  But, this should be not a
>>> significant issue.
>>>
>>> Cc: "Huang, Ying" <ying.huang@intel.com>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Mel Gorman <mgorman@techsingularity.net>
>>> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
>>> Cc: Hugh Dickins <hughd@google.com>
>>> Cc: Shakeel Butt <shakeelb@google.com>
>>> Cc: Hillf Danton <hdanton@sina.com>
>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> ---
>>> v6: Fixed the other double account issue introduced by v5 per Huang Ying
>>> v5: Fixed sc->nr_scanned double accounting per Huang Ying
>>>      Added some comments to address the concern about premature OOM per Hillf Danton
>>> v4: Fixed the comments from Johannes and Huang Ying
>>> v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
>>>      Switched back to use compound_order per Matthew
>>>      Fixed more counters per Johannes
>>> v2: Added Shakeel's Reviewed-by
>>>      Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski
>>>
>>>   mm/vmscan.c | 47 +++++++++++++++++++++++++++++++++++------------
>>>   1 file changed, 35 insertions(+), 12 deletions(-)
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index b65bc50..378edff 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -1118,6 +1118,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>>   		int may_enter_fs;
>>>   		enum page_references references = PAGEREF_RECLAIM_CLEAN;
>>>   		bool dirty, writeback;
>>> +		unsigned int nr_pages;
>>>     		cond_resched();
>>>   @@ -1129,7 +1130,10 @@ static unsigned long
>>> shrink_page_list(struct list_head *page_list,
>>>     		VM_BUG_ON_PAGE(PageActive(page), page);
>>>   -		sc->nr_scanned++;
>>> +		nr_pages = 1 << compound_order(page);
>>> +
>>> +		/* Account the number of base pages even though THP */
>>> +		sc->nr_scanned += nr_pages;
>>>     		if (unlikely(!page_evictable(page)))
>>>   			goto activate_locked;
>>> @@ -1250,7 +1254,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>>   		case PAGEREF_ACTIVATE:
>>>   			goto activate_locked;
>>>   		case PAGEREF_KEEP:
>>> -			stat->nr_ref_keep++;
>>> +			stat->nr_ref_keep += nr_pages;
>>>   			goto keep_locked;
>>>   		case PAGEREF_RECLAIM:
>>>   		case PAGEREF_RECLAIM_CLEAN:
>>> @@ -1306,6 +1310,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>>   		}
>>>     		/*
>>> +		 * THP may get split above, need minus tail pages and update
>>> +		 * nr_pages to avoid accounting tail pages twice.
>>> +		 */
>>> +		if ((nr_pages > 1) && !PageTransHuge(page)) {
>>> +			sc->nr_scanned -= (nr_pages - 1);
>>> +			nr_pages = 1;
>>> +		}
>> After checking the code again, it appears there's another hole in the
>> code.  In the following code snippet.
>>
>> 				if (!add_to_swap(page)) {
>> 					if (!PageTransHuge(page))
>> 						goto activate_locked;
>> 					/* Fallback to swap normal pages */
>> 					if (split_huge_page_to_list(page,
>> 								    page_list))
>> 						goto activate_locked;
>> #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> 					count_vm_event(THP_SWPOUT_FALLBACK);
>> #endif
>> 					if (!add_to_swap(page))
>> 						goto activate_locked;
>> 				}
>>
>>
>> If the THP is split, but the first or the second add_to_swap() fails, we
>> still need to deal with sc->nr_scanned and nr_pages.
>>
>> How about add a new label before "activate_locked" to deal with that?
>
> It sounds not correct. If swapout fails it jumps to activate_locked
> too, it has to be handled in if (!add_to_swap(page)). The below fix
> should be good enough since only THP can reach here:
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 378edff..fff3937 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1294,8 +1294,15 @@ static unsigned long shrink_page_list(struct
> list_head *page_list,
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> count_vm_event(THP_SWPOUT_FALLBACK);
>  #endif
> -                                       if (!add_to_swap(page))
> +                                       if (!add_to_swap(page)) {
> +                                               /*
> +                                                * Minus tail pages
> and reset
> +                                                * nr_pages.
> +                                                */
> +                                               sc->nr_scanned -= 
> (nr_pages - 1);
> +                                               nr_pages = 1;
>                                                 goto activate_locked;
> +                                       }
>                                 }

I think you need to add similar logic for the first add_to_swap() in the
original code snippet.

>> 				if (!add_to_swap(page)) {
>> 					if (!PageTransHuge(page))

To reduce code duplication, I suggest to add another label to deal with
it.

activate_locked_split:
        if (nr_pages > 1) {
                sc->nr_scanned -= nr_pages - 1;
                nr_pages = 1;
        }

activate_locked:

And use "goto active_locked_split" if add_to_swap() failed.

Best Regards,
Huang, Ying

