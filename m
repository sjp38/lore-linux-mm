Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37228C28CBF
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 02:12:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07EC6216FD
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 02:11:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07EC6216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93F896B0273; Sun, 26 May 2019 22:11:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F0976B0274; Sun, 26 May 2019 22:11:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 807E26B0275; Sun, 26 May 2019 22:11:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 494FF6B0273
	for <linux-mm@kvack.org>; Sun, 26 May 2019 22:11:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w14so10260380plp.4
        for <linux-mm@kvack.org>; Sun, 26 May 2019 19:11:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=zg1TU3spcfhMzy8mtS24OMWEDrKhLYgSI1I5lyYkXQA=;
        b=dUYx6Bq/nc01wxrezsXWa68pysqKwZEPXZSdSIxwkYF17Uo+af4TUFD+mzXHgf9OEg
         OggfP4hLBPPCB6Gawn/xASxwDf2JF0TPrVbXzv3hry4e55IS2Yb/1OOS3HDjY3tmJH34
         tcI7sYCUXwyzV34HfUQkHaPS9pbZhkpceTSPPOKQAK2mHFaao517NAhjC4/qByG5e8yG
         CP5XmXqXPJlLc3haVl7RDe7Dd1O3wFvnKo54IwGglaQ4xr7xl9oTBOA4vBRKxad4t6UX
         Pstp+5rdQy0jfupBwL5n8LpYfT8KgfJexq8AQ4ESl97dU5K3TXye5tTVxSiUE7n5t+3Y
         vk2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWhlr+o1BOBmJzbCgB5UQXknciUaa2U9X0RJr3QHUpyOXNjUhOr
	Tusg513G+QBYRkn9pX4Nfb99jkh8em4phIJQlGpmzXoN32Ecjc3Mi2TXRe6Vu8we1QSSZbWoVDl
	a/L1Ou9+07R8ilLVmOAsbcFKu3bXGY46pbdbo3eYC6xNVYjz6Tx/uGGUKRcdS4JKPjg==
X-Received: by 2002:a17:902:522:: with SMTP id 31mr1330394plf.296.1558923118944;
        Sun, 26 May 2019 19:11:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkAFLFUgLkqDv6zMKI5bLbiSGRcZtWzj0GLTEt8f4tIFrBJAi7EgjsvJJHoZik6ZZZJhdc
X-Received: by 2002:a17:902:522:: with SMTP id 31mr1330360plf.296.1558923118165;
        Sun, 26 May 2019 19:11:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558923118; cv=none;
        d=google.com; s=arc-20160816;
        b=YL/MbR7BdD6ggOg2sxPm4+rrD4auVmOyKC7zha08G3n3BH/2D68ZWUiMJ75wwN5Fz6
         pXKhapcl49WhLox9/aUU0hNdDPC+1KI50jq4qu3upMQUDEnmmx9+maTKxHR5QNy0USoL
         Ece8XnN8y86UakPKxAh5/v57LSNNi6NjY7LD6mTk950juW9n4+Ko/Xedaync3VAr+UlD
         tQht8c5XEUz9zlwTirmgROwFtrXZfoBSHegSndZ1Oq8LBfjhPeY5/uOgUkY0SkPPRIs4
         acm5rVTRS9eHnOr5ItJOogF6dcRwe2RBucJeYrGFghKhIuoKHqjj03ZuqFnrcZfgn1DN
         UX1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=zg1TU3spcfhMzy8mtS24OMWEDrKhLYgSI1I5lyYkXQA=;
        b=wOSZKgt5N1gCJiP3D/iXEdnztV0wiHUgmQ6qtAFRBWmOnEMv6EzecW3oeNq/SwhIP+
         DtZwAzG8yWbAz+gXtcdlhB5JPPekIzv+av1D+V91kPAn4s5dTD/qqNcFgyTJj2KMr2ZH
         r0VcBPRZZr3PUUl82ZZl8dEHrW7gvLg5IBCKc1Eg+jXzAJxpid+7LxA7NpwGWiN9rtrN
         UdLy5Xa/+YihaKYfEgLcoF0ufBRyFy4DA54vpinEqLsonrp9RGpOVyW7mqMbylZYTtcH
         uSC1upkxzmMB3yVkI9ZI86kq83bCWFxccsmKuUuQzCLQCSqXV5WFzpFM55M6xekDLZNk
         y0GA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s36si16271560pld.278.2019.05.26.19.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 19:11:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 May 2019 19:11:57 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by orsmga005.jf.intel.com with ESMTP; 26 May 2019 19:11:54 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: <hannes@cmpxchg.org>,  <mhocko@suse.com>,  <mgorman@techsingularity.net>,  <kirill.shutemov@linux.intel.com>,  <josef@toxicpanda.com>,  <hughd@google.com>,  <shakeelb@google.com>,  <hdanton@sina.com>,  <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>
Subject: Re: [RESEND v5 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
References: <1558922275-31782-1-git-send-email-yang.shi@linux.alibaba.com>
	<1558922275-31782-2-git-send-email-yang.shi@linux.alibaba.com>
Date: Mon, 27 May 2019 10:11:54 +0800
In-Reply-To: <1558922275-31782-2-git-send-email-yang.shi@linux.alibaba.com>
	(Yang Shi's message of "Mon, 27 May 2019 09:57:55 +0800")
Message-ID: <87muj88x3p.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yang Shi <yang.shi@linux.alibaba.com> writes:

> Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
> swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
> and some other vm counters still get inc'ed by one even though a whole
> THP (512 pages) gets swapped out.
>
> This doesn't make too much sense to memory reclaim.  For example, direct
> reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
> could fulfill it.  But, if nr_reclaimed is not increased correctly,
> direct reclaim may just waste time to reclaim more pages,
> SWAP_CLUSTER_MAX * 512 pages in worst case.
>
> And, it may cause pgsteal_{kswapd|direct} is greater than
> pgscan_{kswapd|direct}, like the below:
>
> pgsteal_kswapd 122933
> pgsteal_direct 26600225
> pgscan_kswapd 174153
> pgscan_direct 14678312
>
> nr_reclaimed and nr_scanned must be fixed in parallel otherwise it would
> break some page reclaim logic, e.g.
>
> vmpressure: this looks at the scanned/reclaimed ratio so it won't
> change semantics as long as scanned & reclaimed are fixed in parallel.
>
> compaction/reclaim: compaction wants a certain number of physical pages
> freed up before going back to compacting.
>
> kswapd priority raising: kswapd raises priority if we scan fewer pages
> than the reclaim target (which itself is obviously expressed in order-0
> pages). As a result, kswapd can falsely raise its aggressiveness even
> when it's making great progress.
>
> Other than nr_scanned and nr_reclaimed, some other counters, e.g.
> pgactivate, nr_skipped, nr_ref_keep and nr_unmap_fail need to be fixed
> too since they are user visible via cgroup, /proc/vmstat or trace
> points, otherwise they would be underreported.
>
> When isolating pages from LRUs, nr_taken has been accounted in base
> page, but nr_scanned and nr_skipped are still accounted in THP.  It
> doesn't make too much sense too since this may cause trace point
> underreport the numbers as well.
>
> So accounting those counters in base page instead of accounting THP as
> one page.
>
> nr_dirty, nr_unqueued_dirty, nr_congested and nr_writeback are used by
> file cache, so they are not impacted by THP swap.
>
> This change may result in lower steal/scan ratio in some cases since
> THP may get split during page reclaim, then a part of tail pages get
> reclaimed instead of the whole 512 pages, but nr_scanned is accounted
> by 512, particularly for direct reclaim.  But, this should be not a
> significant issue.
>
> Cc: "Huang, Ying" <ying.huang@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> v5: Fixed sc->nr_scanned double accounting per Huang Ying
>     Added some comments to address the concern about premature OOM per Hillf Danton 
> v4: Fixed the comments from Johannes and Huang Ying
> v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
>     Switched back to use compound_order per Matthew
>     Fixed more counters per Johannes
> v2: Added Shakeel's Reviewed-by
>     Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski
>
>  mm/vmscan.c | 42 +++++++++++++++++++++++++++++++-----------
>  1 file changed, 31 insertions(+), 11 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b65bc50..f4f4d57 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1118,6 +1118,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		int may_enter_fs;
>  		enum page_references references = PAGEREF_RECLAIM_CLEAN;
>  		bool dirty, writeback;
> +		unsigned int nr_pages;
>  
>  		cond_resched();
>  
> @@ -1129,6 +1130,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  		VM_BUG_ON_PAGE(PageActive(page), page);
>  
> +		nr_pages = 1 << compound_order(page);
> +
> +		/*
> +		 * Accounted one page for THP for now.  If THP gets swapped
> +		 * out in a whole, will account all tail pages later to
> +		 * avoid accounting tail pages twice.
> +		 */
>  		sc->nr_scanned++;
>  
>  		if (unlikely(!page_evictable(page)))
> @@ -1250,7 +1258,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		case PAGEREF_ACTIVATE:
>  			goto activate_locked;
>  		case PAGEREF_KEEP:
> -			stat->nr_ref_keep++;
> +			stat->nr_ref_keep += nr_pages;
>  			goto keep_locked;
>  		case PAGEREF_RECLAIM:
>  		case PAGEREF_RECLAIM_CLEAN:

If the "Accessed bit" of a THP is set in the page table that maps it, it
will go PAGEREF_ACTIVATE path here.  And the sc->nr_scanned should
increase 512 instead of 1.  Otherwise sc->nr_activate may be larger than
sc->nr_scanned.

Best Regards,
Huang, Ying

