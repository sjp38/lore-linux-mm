Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D9F7C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:52:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5470521019
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:52:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5470521019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D19F86B0003; Thu, 23 May 2019 08:52:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA4426B000D; Thu, 23 May 2019 08:52:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B92116B000E; Thu, 23 May 2019 08:52:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 809976B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 08:52:52 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id h12so3410189pll.20
        for <linux-mm@kvack.org>; Thu, 23 May 2019 05:52:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=zJEMEWtLBL2ehZnVpdFKkDN09uYl4+fqSrN4fePstj4=;
        b=KG5/kSlFdCna6eaXk9IHrq5iwNHIWDdxLi0SRGldqcVoaBH6ljhVFKrxOvfaKWqdAL
         KzE+v1TxISbt5sdyc8ffoLwcIAmsirQJKEXW8ykBqsb2ZsvBojkYVy4U9o8npmzeR+c5
         oQLivKdlqQs8RUtycTeB9CHQuM08mygpaQrA496siwDEaOHkyL4wfDp3c9uJSDRaUiFD
         pi05CHe4gJHZ5Wdyaf58gKFFlmeHyKyGhRdNeeGZAZGj3Nv8NlAZ/AwihmjLGWDh3WST
         XmlZ1DPoksZyNKndRfxl3AvbLJTweTi+AZPsS4UmMllxWxfBf06rWUaQWKyVp5RMgeij
         zodg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX+SpKCuVNkUVYx29MUkG03SCecuuMx/e3AZJHplTCH10x+0e7b
	0yBtlSNy+8UQrC9RWlrbcUgDDB+8EfAztMT7CTpYMxjj7Mc2u5jbXKV6PsY9qXI6Q7btMFk2M2m
	gnndNq1PcV1cq4tDByoMABsdHDt2R/XvI38Eo6ffDX67VgjG0mjErDuY33lkv84cIxA==
X-Received: by 2002:a17:902:fa2:: with SMTP id 31mr99563057plz.128.1558615972141;
        Thu, 23 May 2019 05:52:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwIW6JcgQpMzPuE93gJxYUOLKFmf81GVhLQ/gsnf3+GrwYUeMTRephuqOYta3DjqDlYPuQ
X-Received: by 2002:a17:902:fa2:: with SMTP id 31mr99562960plz.128.1558615971355;
        Thu, 23 May 2019 05:52:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558615971; cv=none;
        d=google.com; s=arc-20160816;
        b=lVEqMkPBkAE1U5AEnRQrAXcTRHfonPdjVKPWRJfbvYqJwWHgaraUCEC4p/l94641p7
         hbCQw9jZ/6Zcx9azAWrGakOWXkfBpRYoarjjiroIx9RYz3mAJP2IQsZ5ettnZAK1e2vt
         lvhKugVCrUDYgfHBfNMxqJgivmM4eBRCWaxRHlSqlQbbYMALZGrPcEFtSVnS3hHRks5a
         X6/uiIq4y39rPM/0qo+1XoqRWDDBlsZa6RmYsszW3lWC2PhnB4GY8iTDpDcCEi6jlWv/
         jBkbGe8ZCbhIArDAzggZOYVoiv+vZlReIIdtBsgtsjhTTw64QXZL9R0BwfiRhIZd7r9o
         p2Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=zJEMEWtLBL2ehZnVpdFKkDN09uYl4+fqSrN4fePstj4=;
        b=MQC/HIelIF2gd3xbeZ8OLgzyD5C0//V3Dk88e53bGA7Q1E7KYIZ6DNq5J9EPA5dcSm
         oHkJ/2GnqwOoYkEAVZs1E33jTQ4c0E2rk3lTpcC/QvW5cS+tU2jJ+noo1P2gpjPVcP39
         zZMfb1zn+tB4CaEw2ApgbRcNtervtygVezThwgbUI7hQ6R2ssdgf91nEAL38+1iPD7Fq
         ywU8Odyoy8Q+11q1hVG/63bytgJbbvBkdzxBkykK3jF3VOPW+N6GDGHUM35el8HkvwlU
         YcBNRDHl3Ara+Kk1aSuSxIVFf4JrlF/021saXMFBubjX3I5UkilgijhtuJ766Z/mUWy1
         shxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id z27si30489336pga.47.2019.05.23.05.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 05:52:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 May 2019 05:52:50 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga008.fm.intel.com with ESMTP; 23 May 2019 05:52:48 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: <hannes@cmpxchg.org>,  <mhocko@suse.com>,  <mgorman@techsingularity.net>,  <kirill.shutemov@linux.intel.com>,  <josef@toxicpanda.com>,  <hughd@google.com>,  <shakeelb@google.com>,  <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>
Subject: Re: [v4 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
References: <1558578458-83807-1-git-send-email-yang.shi@linux.alibaba.com>
	<1558578458-83807-2-git-send-email-yang.shi@linux.alibaba.com>
Date: Thu, 23 May 2019 20:52:48 +0800
In-Reply-To: <1558578458-83807-2-git-send-email-yang.shi@linux.alibaba.com>
	(Yang Shi's message of "Thu, 23 May 2019 10:27:38 +0800")
Message-ID: <87lfyx9vtr.fsf@yhuang-dev.intel.com>
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
> v4: Fixed the comments from Johannes and Huang Ying
> v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
>     Switched back to use compound_order per Matthew
>     Fixed more counters per Johannes
> v2: Added Shakeel's Reviewed-by
>     Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski
>
>  mm/vmscan.c | 34 ++++++++++++++++++++++------------
>  1 file changed, 22 insertions(+), 12 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b65bc50..1b35a7a 100644
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
> @@ -1129,7 +1130,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  		VM_BUG_ON_PAGE(PageActive(page), page);
>  
> -		sc->nr_scanned++;
> +		/* Account the number of base pages evne though THP */

s/evne/even/

> +		nr_pages = 1 << compound_order(page);
> +		sc->nr_scanned += nr_pages;
>  
>  		if (unlikely(!page_evictable(page)))
>  			goto activate_locked;
> @@ -1250,7 +1253,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		case PAGEREF_ACTIVATE:
>  			goto activate_locked;
>  		case PAGEREF_KEEP:
> -			stat->nr_ref_keep++;
> +			stat->nr_ref_keep += nr_pages;
>  			goto keep_locked;
>  		case PAGEREF_RECLAIM:
>  		case PAGEREF_RECLAIM_CLEAN:

If the THP is split, you need

        sc->nr_scanned -= nr_pages - 1;

Otherwise the tail pages will be counted twice.

> @@ -1315,7 +1318,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			if (unlikely(PageTransHuge(page)))
>  				flags |= TTU_SPLIT_HUGE_PMD;
>  			if (!try_to_unmap(page, flags)) {
> -				stat->nr_unmap_fail++;
> +				stat->nr_unmap_fail += nr_pages;
>  				goto activate_locked;
>  			}
>  		}
> @@ -1442,7 +1445,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  		unlock_page(page);
>  free_it:
> -		nr_reclaimed++;
> +		/*
> +		 * THP may get swapped out in a whole, need account
> +		 * all base pages.
> +		 */
> +		nr_reclaimed += (1 << compound_order(page));

Best Regards,
Huang, Ying

