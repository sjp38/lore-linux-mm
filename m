Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63EEAC41514
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 07:45:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3276F2075B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 07:45:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3276F2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD0C28E0006; Mon, 29 Jul 2019 03:45:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B81208E0002; Mon, 29 Jul 2019 03:45:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A70338E0006; Mon, 29 Jul 2019 03:45:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 59FDD8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 03:45:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o13so37767574edt.4
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 00:45:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yqSQZl5BR1RkSKHgIy75PKBcAUe+/8sHe4TA3mojtkU=;
        b=JQqxJ6c8fx1diEI1kiJ8oSthGYBGNQ8TwSaCdFob6O9vFHgEiUCm1uacEmuWrC2UR4
         1EXW/+n7VSE8YLiFQLhkknGhQP+FewK5+MoOoXyVoMb7x03j6GLsUe56csWtRCp5m5D4
         WNnUSsE4CW9d0PszET5UgkIiMm7X9sUq43wOrPhpB4l+3IfIjpcdNkb6NlrM6QPqlpFh
         2y1or6PAd2TA3cuzOjrylb6o/3WGjgFje+oIoH06cc/YtyWZuDtOZMbQ4bt++5J39zxJ
         f/+2kapT/mw9T5Rh+btAuz+ctQ2YwKCa43gGQcpstQUNW0AfSxPOc03hj2Gvmar7dUZK
         WQgw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWSaxbwHDxlMJDszYtijhCH4BptLRU4uiCJiAStFf3P/Q8Pzku7
	dSixy8nyVT7qNM0n68/taABBfzE7lAGGbTZgQlCV+IH2rRPL/J19178I+E/fPozxDhwxk2d+HTO
	JgaBi50lSb3uzejj7B8qGgqv8KNII0XAHmjVYLy59pAoCUDdw9xmi5hd4uusaSb4=
X-Received: by 2002:a50:b1bd:: with SMTP id m58mr94310306edd.185.1564386325937;
        Mon, 29 Jul 2019 00:45:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4zVV8283qcL2dOskvWniRr/qB47Gfjf/S+PSNltbJjv0eFRBkTV4079I1LgS7mGYNrQwj
X-Received: by 2002:a50:b1bd:: with SMTP id m58mr94310271edd.185.1564386325306;
        Mon, 29 Jul 2019 00:45:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564386325; cv=none;
        d=google.com; s=arc-20160816;
        b=n5IVaOaqIRBHf1uUY+JHoiRTRfu8mYapr+O8TOzQHGEbjfryiZuEDRH6lApL/bnCEU
         bFBtbB+YVbbtTODi6+7nm1g4KelE7+WIN/GzSB/Av9Ky30iRf8QJc9pcm4FyQDrhc5bF
         Ab25sXrU3sX2Tn3RLP5+mBzfp45acLyknutRnb8uBTUhID111BHvWmEBqWtwPKbV1jrL
         62yu8PKPy+ZlSPyQ6Ht1Qxypbg3QoEqEiAyS1F3wpI77Toc556CpMG+tfNLKzldAenh+
         RYlgoXY610F5p+lQCZ1spFGv/wuasA3IvCX4imxOJ3JD8hV4nN41MocSkYuH5cOA7VOy
         lZEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yqSQZl5BR1RkSKHgIy75PKBcAUe+/8sHe4TA3mojtkU=;
        b=na/q6n0ILJA+iXWQyv08+TGBFQ8I3kb3GzHU5BhywDRQoTkIFiLGeByiEA8djNC7Ol
         23CQXrizS5NjAuItFP9HMDJVf5FvJbIJN2gKcuxOyFg1UCoo63faSc5dE2bYtz+z+a16
         6W1F+ITDWtRXQBZqc3ZisAygggZ5BHyVWqNvK8QREahhom5BbCw/OQ9mnDLXDUTUqwfS
         9fsyFdsAQ73i+nS1Nf+2/QuPSlniGHUBE+wA1ZBeycxmMCRetI0efvrUbVly9n2ZxdUt
         ZhU8BJii5mFck7OQ1KEiIgMP46owXsfU5JVBE8+BnRO2EQVVDApOib8tLxLhtKcD3qap
         1c8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y12si16575830edd.87.2019.07.29.00.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 00:45:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7FC2CAE5E;
	Mon, 29 Jul 2019 07:45:24 +0000 (UTC)
Date: Mon, 29 Jul 2019 09:45:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-ID: <20190729074523.GC9330@dhcp22.suse.cz>
References: <20190729071037.241581-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729071037.241581-1-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-07-19 16:10:37, Minchan Kim wrote:
> In our testing(carmera recording), Miguel and Wei found unmap_page_range
> takes above 6ms with preemption disabled easily. When I see that, the
> reason is it holds page table spinlock during entire 512 page operation
> in a PMD. 6.2ms is never trivial for user experince if RT task couldn't
> run in the time because it could make frame drop or glitch audio problem.

Where is the time spent during the tear down? 512 pages doesn't sound
like a lot to tear down. Is it the TLB flushing?

> This patch adds preemption point like coyp_pte_range.
> 
> Reported-by: Miguel de Dios <migueldedios@google.com>
> Reported-by: Wei Wang <wvw@google.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/memory.c | 19 ++++++++++++++++---
>  1 file changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 2e796372927fd..bc3e0c5e4f89b 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1007,6 +1007,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  				struct zap_details *details)
>  {
>  	struct mm_struct *mm = tlb->mm;
> +	int progress = 0;
>  	int force_flush = 0;
>  	int rss[NR_MM_COUNTERS];
>  	spinlock_t *ptl;
> @@ -1022,7 +1023,16 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  	flush_tlb_batched_pending(mm);
>  	arch_enter_lazy_mmu_mode();
>  	do {
> -		pte_t ptent = *pte;
> +		pte_t ptent;
> +
> +		if (progress >= 32) {
> +			progress = 0;
> +			if (need_resched())
> +				break;
> +		}
> +		progress += 8;

Why 8?

> +
> +		ptent = *pte;
>  		if (pte_none(ptent))
>  			continue;
>  
> @@ -1123,8 +1133,11 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  	if (force_flush) {
>  		force_flush = 0;
>  		tlb_flush_mmu(tlb);
> -		if (addr != end)
> -			goto again;
> +	}
> +
> +	if (addr != end) {
> +		progress = 0;
> +		goto again;
>  	}
>  
>  	return addr;
> -- 
> 2.22.0.709.g102302147b-goog

-- 
Michal Hocko
SUSE Labs

