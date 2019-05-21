Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7061BC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:00:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7B2121019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:00:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="wIui4g4k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7B2121019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 595616B0003; Tue, 21 May 2019 12:00:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 547D76B0006; Tue, 21 May 2019 12:00:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4352D6B0007; Tue, 21 May 2019 12:00:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB9C6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:00:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id l16so12575506pfb.23
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:00:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TogRCtoGuspU/BxsVzKAUgCg8HetjOKzKzquxHXPaGw=;
        b=YFgI2wtVkseL6dBhm2goRAX4MPws4lSb1gcskNI/ilUKjL1HpQmqHhE6qZxMapmy4/
         WpYxrEGX2ckehlME4vQEreoRDEWXMiqNJrFFhfPHd+0/Il1FZWLKnQKAgzSdA1BUct7s
         2JBlocc9Ngqh+qnG2D3+PTzIgbQNURQMyR4bvTtHIkMjGxFGY1WViiCoyVud7E4WOUbt
         y7vpHlFqL53BiZoCvzGhTlHU8tINxwntrHJic6XQzLBw1wbrAAVjTEscU+iCyran6l2U
         BitpYzIqDrBYxP0vFkZ3P8OAWjJMWH7Lj6nAhjjwWQmnspxXw8C93eRKkzF+pIQmv28B
         k5jg==
X-Gm-Message-State: APjAAAWt3+1yXXwhCX16fGiIcDu7GBmm4cVPTlt1h6ZRVQiSBBggf7qa
	e40zWV64DUKks5tTLTC+U5fXxb6KrUbGAYG5TGost5X9Vg6M5WQqGCWf3/7l7t5WzFKJkBN57i1
	udS0CfvdE8W6/Lf8H5qlrvRdNeR069bfVwxWmlfCdPXBMe7Bh3DVb2+Sx5pS/yZZonw==
X-Received: by 2002:a63:8242:: with SMTP id w63mr82262720pgd.169.1558454442665;
        Tue, 21 May 2019 09:00:42 -0700 (PDT)
X-Received: by 2002:a63:8242:: with SMTP id w63mr82262596pgd.169.1558454441762;
        Tue, 21 May 2019 09:00:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558454441; cv=none;
        d=google.com; s=arc-20160816;
        b=0RC0gPAS9tLitfIEkLOsFfmMpTYs7Rli2+d3Szktci99c95SRQxEo0Ey57k/uzq7On
         zVV3mPU0xinl1uH6w9SpnfElXN6+vUIF0o49j8bPSyDpvJUmdbDOTuWafKyqHjLgR02R
         IJdkkD8hUmDjr2GllZOjTH+P7R1ulYsTYfF2JF4XNHj49VwJhskhfjBesJoLddhJh150
         6AgLM5BKJtxMiSedHkNVU//6qh9ZQopSZrtlDBViqF2RRdJ5VMf7M53u+ONVLAg/kiY4
         yR84Oi2oPhVLbHuwB5cn7UXnFBXh5vQgQBWcwd7EDh2vYgyyWB4cGbHZdZA94FEKl8Ya
         OuJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TogRCtoGuspU/BxsVzKAUgCg8HetjOKzKzquxHXPaGw=;
        b=pZlW9iDivcxrpdIzi7dz1XuF+H0WjeHa90Vuq2Sb/5Sv0P+zq3ktyP2J+ppYM1JTQ2
         dB8Hh6VrYn8RJpvBDyBxMRyqG1DEiZHsd9Knw98MWCAgCS9lENDSRq6CjDKSjufzhwE+
         bJEMj70TindfA9Pc1PtKEEWnTi6E4YaH6FZDD61s8sawGmd/E+ApQ6hrZRg4OED3W0yc
         vPhJAmF8dt9atYVQbfE/Iv/zLhrRkgKoVfLSV0giwiyxVG0cYLHCTrn881QoaXU2NKrO
         WiVFwizS6gGTkT/se92FQ5/u9CteULCWuIPF7ts7Kxg+ULuGEJHxB/RU5XOAalHYud5G
         KOgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=wIui4g4k;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 12sor23324639plb.62.2019.05.21.09.00.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 09:00:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=wIui4g4k;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TogRCtoGuspU/BxsVzKAUgCg8HetjOKzKzquxHXPaGw=;
        b=wIui4g4kwP3d/GZyhrnpO6RHy90AmOgOnzjS2vF0sveuvoaPnfLdxdH9RrRg5hpRgp
         U33vio9BLyz3UReiFWIMl4VZwWBedBOuZSAtg2qsvOtwnHWjrhel1MlYkTsgNv89uGlX
         cw/WN8Etok87tutmL2ouDbDeI7Zor00D8GVpFc6VfVgH/dhUvxkXQqEzvp5fyKb5sb/O
         cHCxTqQFvq42wqiCvonxs1u1lwnmETMkfaIQl1xiHk6SWV8ElGEzRCWwFkD5RnbrNTMs
         wfpGzdKuhi7z6BMzYtSgQ8g3N5ARw0b6WOpcOgEJhR+T2EXAsd9kztZ8RTF3ZqfbrcTd
         73Ag==
X-Google-Smtp-Source: APXvYqyoOF6SBd83+gAazCMfYqTWG3+2p2HzlLnpjCxSydoi6lXrw1DngRpB8G56wL8bSR5L7cm4xg==
X-Received: by 2002:a17:902:b204:: with SMTP id t4mr32077199plr.285.1558454440852;
        Tue, 21 May 2019 09:00:40 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:6169])
        by smtp.gmail.com with ESMTPSA id e78sm40285940pfh.134.2019.05.21.09.00.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 May 2019 09:00:40 -0700 (PDT)
Date: Tue, 21 May 2019 12:00:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ying.huang@intel.com, mhocko@suse.com, mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com, josef@toxicpanda.com,
	hughd@google.com, shakeelb@google.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v3 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP
 swapout
Message-ID: <20190521160038.GB3687@cmpxchg.org>
References: <1558431642-52120-1-git-send-email-yang.shi@linux.alibaba.com>
 <1558431642-52120-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1558431642-52120-2-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 05:40:42PM +0800, Yang Shi wrote:
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
> v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
>     Switched back to use compound_order per Matthew
>     Fixed more counters per Johannes
> v2: Added Shakeel's Reviewed-by
>     Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski
> 
>  mm/vmscan.c | 40 ++++++++++++++++++++++++++++------------
>  1 file changed, 28 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b65bc50..1044834 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1250,7 +1250,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		case PAGEREF_ACTIVATE:
>  			goto activate_locked;
>  		case PAGEREF_KEEP:
> -			stat->nr_ref_keep++;
> +			stat->nr_ref_keep += (1 << compound_order(page));
>  			goto keep_locked;
>  		case PAGEREF_RECLAIM:
>  		case PAGEREF_RECLAIM_CLEAN:
> @@ -1294,6 +1294,17 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  						goto activate_locked;
>  				}
>  
> +				/*
> +				 * Account all tail pages when THP is added
> +				 * into swap cache successfully.
> +				 * The head page has been accounted at the
> +				 * first place.
> +				 */
> +				if (PageTransHuge(page))
> +					sc->nr_scanned +=
> +						((1 << compound_order(page)) -
> +							1);
> +
>  				may_enter_fs = 1;

Even if we don't split and reclaim the page, we should always account
the number of base pages in nr_scanned. Otherwise it's not clear what
nr_scanned means.

>  				/* Adding to swap updated mapping */
> @@ -1315,7 +1326,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			if (unlikely(PageTransHuge(page)))
>  				flags |= TTU_SPLIT_HUGE_PMD;
>  			if (!try_to_unmap(page, flags)) {
> -				stat->nr_unmap_fail++;
> +				stat->nr_unmap_fail +=
> +					(1 << compound_order(page));
>  				goto activate_locked;
>  			}
>  		}
> @@ -1442,7 +1454,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  		unlock_page(page);
>  free_it:
> -		nr_reclaimed++;
> +		/*
> +		 * THP may get swapped out in a whole, need account
> +		 * all base pages.
> +		 */
> +		nr_reclaimed += (1 << compound_order(page));

This expression is quite repetitive. Why not do

		int nr_pages;

		page = lru_to_page(page_list);
		nr_pages = 1 << compound_order(page);
		list_del(&page->lru);

		if (!trylock_page(page))
			...

at the head of the loop and add nr_pages to all these counters
instead?

> @@ -1642,14 +1659,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
>  	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
>  	unsigned long skipped = 0;
> -	unsigned long scan, total_scan, nr_pages;
> +	unsigned long scan, nr_pages;
>  	LIST_HEAD(pages_skipped);
>  	isolate_mode_t mode = (sc->may_unmap ? 0 : ISOLATE_UNMAPPED);
>  
>  	scan = 0;
> -	for (total_scan = 0;
> -	     scan < nr_to_scan && nr_taken < nr_to_scan && !list_empty(src);
> -	     total_scan++) {
> +	while (scan < nr_to_scan && nr_taken < nr_to_scan && !list_empty(src)) {
>  		struct page *page;

Once you fixed the units, scan < nr_to_scan && nr_taken >= nr_to_scan
is an impossible condition. You should be able to write:

	while (scan < nr_to_scan && !list_empty(src))

Also, you need to keep total_scan. The trace point wants to know how
many pages were actually looked at, including the ones from ineligible
zones that were skipped over.

>  
>  		page = lru_to_page(src);
> @@ -1659,7 +1674,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  
>  		if (page_zonenum(page) > sc->reclaim_idx) {
>  			list_move(&page->lru, &pages_skipped);
> -			nr_skipped[page_zonenum(page)]++;
> +			nr_skipped[page_zonenum(page)] +=
> +				(1 << compound_order(page));
>  			continue;
>  		}
>  
> @@ -1669,7 +1685,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  		 * ineligible pages.  This causes the VM to not reclaim any
>  		 * pages, triggering a premature OOM.
>  		 */
> -		scan++;
> +		scan += (1 << compound_order(page));
>  		switch (__isolate_lru_page(page, mode)) {
>  		case 0:
>  			nr_pages = hpage_nr_pages(page);

Same here, you can calculate nr_pages at the top of the loop and use
it throughout.

> @@ -1707,9 +1723,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  			skipped += nr_skipped[zid];
>  		}
>  	}
> -	*nr_scanned = total_scan;
> +	*nr_scanned = scan;
>  	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan,
> -				    total_scan, skipped, nr_taken, mode, lru);
> +				    scan, skipped, nr_taken, mode, lru);
>  	update_lru_sizes(lruvec, lru, nr_zone_taken);
>  	return nr_taken;
>  }
> -- 
> 1.8.3.1
> 

