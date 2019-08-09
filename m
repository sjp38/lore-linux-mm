Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55554C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:59:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F7532171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:59:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F7532171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C01C76B000A; Fri,  9 Aug 2019 05:59:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBCC96B000C; Fri,  9 Aug 2019 05:59:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA13F6B000D; Fri,  9 Aug 2019 05:59:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71CBD6B000A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:59:23 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id t9so46666112wrx.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:59:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KgoYV/DEcmFFeP3FUArNRqJOmf7sIQS/ZVBtMMHoP0Q=;
        b=NVQwZ2H61DwraluFhbHr/6OnyGl33ZPaWg44UymDrDOYv0FSa7Bw7iyzCMW8PX50/1
         qjueBPj5wGRNbO5/ck2qZlNNYGkO60+6G0LSdIgqRleawGzRRxIGx/ksA/iuZJypIGhH
         RiqAyj/Rc7unY6rzlvVLCe/JPWkRccGDomt5ZRukfIaS82L4nv9lM+sCCP8caMylo3HB
         EodFJR2C/26ma+IYd7UOpj8USxmiT9VXb5qiYBQvYdcKpjvX8NJ94v85SnPyeMzuHVWJ
         rfC3brC1dmKLp5MhpOeFVX6S5cKeGtoeUY3bmEHtV957ovBIDA26veooaaf1JJmBSoH+
         OqgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.66 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUrWtgQ9HO/NhQrHGA7PMc/OUNBfNwdwIvy2rPNQIgycih5aONJ
	iGp0uIxF4AG/70Tp5HgXDXFljpD9T68DX1e5NdFmFXHHfv2r02rt+rCcL/BEMIsYY+nKZ9g5fqu
	ElFoxUgTRK+kdvrYG7ACA/2ADQS6SK5macOyK2hpOXKgoTIDbWQd12r4InFnjub2lZg==
X-Received: by 2002:adf:dfc8:: with SMTP id q8mr9161076wrn.312.1565344763028;
        Fri, 09 Aug 2019 02:59:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZoA3DXsgjizfJ9Vp9AjM3ukFv9wODEZGgdkR9FHXh4FeUAiMPNvKcB6bUOMVeNH6hGtK6
X-Received: by 2002:adf:dfc8:: with SMTP id q8mr9161010wrn.312.1565344762407;
        Fri, 09 Aug 2019 02:59:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565344762; cv=none;
        d=google.com; s=arc-20160816;
        b=ueCdODrA+d5hey2iNBsEqsnOve7yDVTxwK++/zBb3NTJ7A1UsMddkTWx0UkSWn+Vl4
         4NQEeUMRl3EOHm9SzNu68Qn0BqymKfaoZ7VaLfPWL7l5QxV5Cl4kZQe60IuhNVxQiYz3
         OeM1MbsGrxGFTFUaOSjizUs9wbJUQF9SbSqYgvgr5ZQ9+mj2GfyKCYwz3St2OXjw/ev6
         2m+ytINZJmQ8zDp/Bc125HSJnkaPsE0V+hm0ZJuQmk+CJwcMPoHnwLjw2bXatIJ4SUD8
         3XkZM2qN7ULfWB+8jkuQxpmPhdg2n1NzO4UiRBQvFvo7IlqDJn2et94WETwqnRqeo3DG
         oEMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KgoYV/DEcmFFeP3FUArNRqJOmf7sIQS/ZVBtMMHoP0Q=;
        b=pAhOsRSy4gcRHVzZp9Uo/+wpKtZIpZ5RhaiB9yoUxiy4qX84705+aZVX+SgjL37Ib3
         lwJsU+ld20AAM8j6e/rmGSzDKDWiIlCzwGRiwidpTQpjdm8H5CQJEVjHEcT2484hKO4C
         MQEVZQMzfwI74iTYWsW0aigD2wQS07FE17MSqmu5q8yqbbNNGaEGyb+4/w8D3+zPGdJI
         c9nX9nPqHzyOZkb63cym6d4+eFx6kIrbFuUafrNa22vx/nzPvZAtgL8kVNTrf6hkW/K9
         uEToQBQ649QLNOO8oLbMVkIEn8yoEw2wS59VgSx256doeQNrjoPMHWZLWOV65pH6tDhZ
         007w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.66 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp33.blacknight.com (outbound-smtp33.blacknight.com. [81.17.249.66])
        by mx.google.com with ESMTPS id i12si84162368wrn.69.2019.08.09.02.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 02:59:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.66 as permitted sender) client-ip=81.17.249.66;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.66 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.17])
	by outbound-smtp33.blacknight.com (Postfix) with ESMTPS id 02D3FD053E
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 10:59:21 +0100 (IST)
Received: (qmail 20186 invoked from network); 9 Aug 2019 09:59:21 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.18.93])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 9 Aug 2019 09:59:21 -0000
Date: Fri, 9 Aug 2019 10:59:19 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Dave Chinner <david@fromorbit.com>,
	Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm, vmscan: Do not special-case slab reclaim when
 watermarks are boosted
Message-ID: <20190809095919.GN2739@techsingularity.net>
References: <20190808182946.GM2739@techsingularity.net>
 <7c39799f-ce00-e506-ef3b-4cd8fbff643c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <7c39799f-ce00-e506-ef3b-4cd8fbff643c@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 10:46:19AM +0200, Vlastimil Babka wrote:
> On 8/8/19 8:29 PM, Mel Gorman wrote:
> 
> ...
> 
> > Removing the special casing can still indirectly help fragmentation by
> 
> I think you mean e.g. 'against fragmentation'?
> 

Yes.

> > Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Reviewed-by: Dave Chinner <dchinner@redhat.com>
> > Cc: stable@vger.kernel.org # v5.0+
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

-- 
Mel Gorman
SUSE Labs

