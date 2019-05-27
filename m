Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65FD7C282E5
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 02:58:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 107C4216FD
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 02:58:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 107C4216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 881CD6B026F; Sun, 26 May 2019 22:58:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 809E56B0270; Sun, 26 May 2019 22:58:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F95A6B0271; Sun, 26 May 2019 22:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 340066B026F
	for <linux-mm@kvack.org>; Sun, 26 May 2019 22:58:44 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w14so10330890plp.4
        for <linux-mm@kvack.org>; Sun, 26 May 2019 19:58:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=nJRUM3mQsJiK2G3jKgYoH/TLZ+4Vv4owaioyiRR+y+U=;
        b=F2x5DEZ6SAoiLpZtHl92YTaMg/MH7fMyYgtsTneu4wFyIeuxpn2K92QeCswc/T0qZE
         h4DoHlY0lG8WfYNNpws9VzHSKf+ZALD5AgpojK+0XqwC74b5jOLflbzWvPBnLmlzTfH+
         H4sY8kcYE8B7mLHoVNsYfwA9dfRaMoxqOYGn6Ild5IvAIIP9r3/5AktWBAGLX7OuIQ89
         2PhwdlHcdeOFfWLkBz6AAzLsvFxW7OzJZoS1JvTC47i/lH2FkEHXSkjy25uYVvTeoD5u
         Muxy3NM6M468fhGs6oOEquzn5+2XD3Y0oXkY72+OpGcTiKzmzZScQRJrj+L0TPwprps6
         lXfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWmYNfTGpIIE1Nf2KAf9k2lszUCTpc03oidf4PNIUMW9rz9NOyu
	J31zgDVdFxifOgdz9UruZVg35M4hq/NC5lTWnjPBnd+0n8POWzm9UCdEWZ4iWz/R62MseHGnfBs
	O6rdol3lJdmIpXNjAQVNJzZNbLSdnCmb5EF38xi+4fXpP+ImSQlolnqoXsdk+M26aRg==
X-Received: by 2002:a63:f44f:: with SMTP id p15mr123012716pgk.65.1558925923842;
        Sun, 26 May 2019 19:58:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXqBo18SeKxHqkBKCAlegzfTwPSi4qOLusUx0jsQThszf5aRb8IokoM/2O60skHfgWHtXX
X-Received: by 2002:a63:f44f:: with SMTP id p15mr123012681pgk.65.1558925922902;
        Sun, 26 May 2019 19:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558925922; cv=none;
        d=google.com; s=arc-20160816;
        b=jj12zfwfJIVSN94vFvdwkblyI9r7clEbcC/xti8vxowXaw0fH7SPLlhQ+trE1S8DBC
         XUVlQp/H1+OyM4HIBqOhd8KxeCQDn2Tdq0Ye0SLeX+UiOrJ/sDCDExYJil4qlLpqu+2V
         mrMA7KAGRsblJFmoymnErUSSSPYAEnluybDXanEZIyz9qm4B2/6bioPAGSOuD/KIU2cG
         FmCF0ksWpkhB/VeALs+K5LtK+LbFMdEnctlr+H6fSMmV4D+OTZmbZv3IL88GqN9IpUNM
         jxDY04Mx94KLERgw5l/dlZLQx/kqa6PYwWk6YtqZcOTfEV/ExXPvJfovG/wBYT1WcwFR
         3mEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=nJRUM3mQsJiK2G3jKgYoH/TLZ+4Vv4owaioyiRR+y+U=;
        b=D8XW/NnppiBW0mL0wAPj765wC3F5kp+X35ZMa73ODYKo997qCRx1V7mGxudKEbN5gH
         MHssU7BAfAEqHIox77uXuh4CkI7MeX/5U5E0nggTG8EJhCrOgD8iZz05v0UrdX2Inp8Z
         uGKVmdgUKFZuAbU53usLpelqg/7DL/l7Ap6JvNZSXRwmw0Jc9HzMFapPa1c12p/Rf8kr
         zvvBJgMyLAClBzNgwYPb0dAIu4o6Ol/Q757TpUxyBUBVOGoffyvjf/tFAYL1Xmd97mLF
         SNcsvHLixAjH1ohpRzBTuohPVr1w6lYYQtkKkTt8+07KW5NBZY2aPlzS/8TFc0EoTEJg
         Q9RA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w16si16311761plp.185.2019.05.26.19.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 19:58:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 May 2019 19:58:42 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga006.fm.intel.com with ESMTP; 26 May 2019 19:58:40 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: <hannes@cmpxchg.org>,  <mhocko@suse.com>,  <mgorman@techsingularity.net>,  <kirill.shutemov@linux.intel.com>,  <josef@toxicpanda.com>,  <hughd@google.com>,  <shakeelb@google.com>,  <hdanton@sina.com>,  <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>
Subject: Re: [RESEND v5 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
References: <1558922275-31782-1-git-send-email-yang.shi@linux.alibaba.com>
	<1558922275-31782-2-git-send-email-yang.shi@linux.alibaba.com>
	<87muj88x3p.fsf@yhuang-dev.intel.com>
	<a32dbca4-6239-828b-9f81-f24d582ddd75@linux.alibaba.com>
Date: Mon, 27 May 2019 10:58:39 +0800
In-Reply-To: <a32dbca4-6239-828b-9f81-f24d582ddd75@linux.alibaba.com> (Yang
	Shi's message of "Mon, 27 May 2019 10:47:51 +0800")
Message-ID: <87imtw8uxs.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yang Shi <yang.shi@linux.alibaba.com> writes:

> On 5/27/19 10:11 AM, Huang, Ying wrote:
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
>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> ---
>>> v5: Fixed sc->nr_scanned double accounting per Huang Ying
>>>      Added some comments to address the concern about premature OOM per Hillf Danton
>>> v4: Fixed the comments from Johannes and Huang Ying
>>> v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
>>>      Switched back to use compound_order per Matthew
>>>      Fixed more counters per Johannes
>>> v2: Added Shakeel's Reviewed-by
>>>      Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski
>>>
>>>   mm/vmscan.c | 42 +++++++++++++++++++++++++++++++-----------
>>>   1 file changed, 31 insertions(+), 11 deletions(-)
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index b65bc50..f4f4d57 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -1118,6 +1118,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>>   		int may_enter_fs;
>>>   		enum page_references references = PAGEREF_RECLAIM_CLEAN;
>>>   		bool dirty, writeback;
>>> +		unsigned int nr_pages;
>>>     		cond_resched();
>>>   @@ -1129,6 +1130,13 @@ static unsigned long
>>> shrink_page_list(struct list_head *page_list,
>>>     		VM_BUG_ON_PAGE(PageActive(page), page);
>>>   +		nr_pages = 1 << compound_order(page);
>>> +
>>> +		/*
>>> +		 * Accounted one page for THP for now.  If THP gets swapped
>>> +		 * out in a whole, will account all tail pages later to
>>> +		 * avoid accounting tail pages twice.
>>> +		 */
>>>   		sc->nr_scanned++;
>>>     		if (unlikely(!page_evictable(page)))
>>> @@ -1250,7 +1258,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>>   		case PAGEREF_ACTIVATE:
>>>   			goto activate_locked;
>>>   		case PAGEREF_KEEP:
>>> -			stat->nr_ref_keep++;
>>> +			stat->nr_ref_keep += nr_pages;
>>>   			goto keep_locked;
>>>   		case PAGEREF_RECLAIM:
>>>   		case PAGEREF_RECLAIM_CLEAN:
>> If the "Accessed bit" of a THP is set in the page table that maps it, it
>> will go PAGEREF_ACTIVATE path here.  And the sc->nr_scanned should
>> increase 512 instead of 1.  Otherwise sc->nr_activate may be larger than
>> sc->nr_scanned.
>
> Yes, it looks so. It seems the easiest way is to add "nr_pages - 1" in
> activate_locked label if the page is still a THP.

Add keep_locked label.

> If we add all tail pages at the very beginning, then we have to minus
> tail pages when THP gets split, there are a few places do this.

I think we can do that in one place too.  Just before try_to_unmap() via
checking nr_pages and page order.  And we need to update nr_pages if
the THP is split anyway.

Best Regards,
Huang, Ying

>>
>> Best Regards,
>> Huang, Ying

