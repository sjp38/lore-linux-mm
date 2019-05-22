Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D47A8C18E7C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 01:24:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3E4A217F9
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 01:24:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3E4A217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 304B96B0003; Tue, 21 May 2019 21:24:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B4EF6B0006; Tue, 21 May 2019 21:24:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 157916B0007; Tue, 21 May 2019 21:24:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE5DC6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 21:24:04 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h7so586708pfq.22
        for <linux-mm@kvack.org>; Tue, 21 May 2019 18:24:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=Z4oIhuBkEvdpTB/co4tBNHb+IBH5o1Gu6iX2z/xMm+g=;
        b=MrcGQXHhRPCNfIBL7p39/lxKn8gTUWW14ckfNxyz+sArZYjYEljY/L7VgiriwGd+Iq
         qRYVij0BtR2/Zl2PILrlZbOjD8Qp9Rxy4feDqM5f00Jzkvj57NXi0yTPVKoMDRoiTZuo
         K/i4dBLu94sEXYSffDAIgppuZ1iYjtQV/pdCtfHcb/eF2zLaOaayHwxPu1+STg7DXIVr
         m+je+hN4b9bBxBvzOcr0bJk7po/IApjxC6HSpdH3rT8S5aOud3RoL6xQFRQtJnU2pjZO
         RChUmeM47DyWYq4nwPgU3YESKpQnQ8bQ6UawHCZ5sP0UOhkeMADZsyo9k7XbWVBQ30KQ
         96gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWgFMKEwZR4FnN6tOPsgjXXwHK8/Pe1MlHn1LQo8z9JsYLG+xQV
	ir36cHzoq8dTpLr3b7E20omUuCcpfjgcqRPCtcS/NbKLyM37bUfUiqL7cf9P/CxOm7gR0UhSWGV
	IqdrXasvyiQob8FxNl813c0aLkLkETt+baH8hju6niDyMBD2FXGWW3ZMWYEzaLKXv5g==
X-Received: by 2002:aa7:8296:: with SMTP id s22mr93348604pfm.52.1558488244292;
        Tue, 21 May 2019 18:24:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXb2/Hyy3uZmtiHROexh0Vuf4q/gZCCUbqGh4GlEgt3DseAPL4hSne5Ng2ihPwf/y7aHk4
X-Received: by 2002:aa7:8296:: with SMTP id s22mr93348508pfm.52.1558488242939;
        Tue, 21 May 2019 18:24:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558488242; cv=none;
        d=google.com; s=arc-20160816;
        b=MeAKQTQBztI4jOl3iDsxAu/0mwYrltSVyoV/nB0PPv4EUhcvOgQHHTxBdwMdLYQrWu
         Jf4YxJNGLHE/P09h4cw+SNvyJiXV+9bo5yA+9EVQ1EDEE6bvGYV8cUoJb0KpMkfnv0V/
         ocDNcZXsON4j7GERqfvW4QLAtvb059NAo25sg2GjZbBS238YsBIumZdM/IVBWv0VfXLM
         kAjtt9EhI51S9AyjxmCnnB4KGeN3jaRbIjtS48sS+rgvLXtG32r3+ZBHWFFgTtrC2quI
         +uajiBNyTZtIc5Qnl3/+hu6YFJuvoi2JbkCqPuvfxZPYzgcZzizpXvjxsCRdW3EG3Wbh
         HfHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=Z4oIhuBkEvdpTB/co4tBNHb+IBH5o1Gu6iX2z/xMm+g=;
        b=F/lNilhl7ktUZDT0i1t53+OEBiQtHJXm/BSOYd9ixExCE3uzL18Tt1TvxPLzC8+l7V
         bTQy3gv453FBCrVr6982OWPizY1jvRFKYbqIyrKRXD04rBu4D996stplu3rROHyhb5wf
         HqP3qR+SPZ9UHXhyn6sRBIxRYtQwr23tpevxurohoMuELzQbTxuyOpH0sGc75yS+Dx2E
         rFxvQXhoPgSMtDFCQo9zWLtA9PwMYvFvM/kUBmWHE9QV/47lxHyTPErmzM7EEMAVa22R
         u4F997g2ZXhSLeECMFYos0vUHEk6CKewPn1sU4FvmQhjTNvRQECqk5BEZYrMNvBSBdLZ
         4F1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q4si26887114pfb.272.2019.05.21.18.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 18:24:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 May 2019 18:24:02 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga005.fm.intel.com with ESMTP; 21 May 2019 18:24:00 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: <hannes@cmpxchg.org>,  <mhocko@suse.com>,  <mgorman@techsingularity.net>,  <kirill.shutemov@linux.intel.com>,  <josef@toxicpanda.com>,  <hughd@google.com>,  <shakeelb@google.com>,  <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>
Subject: Re: [v3 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
References: <1558431642-52120-1-git-send-email-yang.shi@linux.alibaba.com>
	<1558431642-52120-2-git-send-email-yang.shi@linux.alibaba.com>
Date: Wed, 22 May 2019 09:23:59 +0800
In-Reply-To: <1558431642-52120-2-git-send-email-yang.shi@linux.alibaba.com>
	(Yang Shi's message of "Tue, 21 May 2019 17:40:42 +0800")
Message-ID: <87ftp7cmds.fsf@yhuang-dev.intel.com>
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

The "if" here could be changed to "else if" because if add_to_swap()
fails we don't need to call PageTransHuge() here.  But this isn't a big
deal.

You have analyzed the code and found that nr_dirty, nr_unqueued_dirty,
nr_congested and nr_writeback are file cache related and not impacted by
THP swap out.  How about add your findings in the patch description?

Best Regards,
Huang, Ying


