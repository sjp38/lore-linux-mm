Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABFCBC5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 08:38:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4910D218A0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 08:38:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4910D218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3DC46B0003; Wed,  3 Jul 2019 04:38:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AED888E0003; Wed,  3 Jul 2019 04:38:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A03BA8E0001; Wed,  3 Jul 2019 04:38:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52C3C6B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 04:38:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m23so1154503edr.7
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 01:38:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ov/WUMJVjnGbIQZfKUy91267gBtC+5ZEz6DU5KJvSdY=;
        b=I7fFGpvy97PXD3/4zdxna5560x4cSyv/UIvv1PlAv5fI57BSph5VtDgitzoUUlK+js
         HErr6FG6HHIlqssiHlFlcM+ZG+9lK5Td9O3Xgx01+LMha5C9uOia7vrLXLVC4nfVjBbx
         4e/LpoGmGmhWCxRzO4QHWL+5ulNAKW+Kw2eJ6lMrlB4n8bHVSCu/tiRHRp5zjaIHEszh
         dbUnnqI9b+b8VcpfHFJ8lBeuzzoAqvQ2yX43uQHqauioZCUekhGZTqVvsLQMeS0SR3yI
         Jsvhgw+C9Im59PpfPHvwYZeLjUblO7TD26eZk/B6O+VJ6XRImGZ7RYHaPU3mTPrjAI2p
         oCxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUzAA1ot+OpnvZQskPndbe6oDhjjHupTtzLTSHXAZZx0Vs4sL9v
	IPV9UCKouZKZQJHW7RfvTfQBPQKGgyDpXphFDRVEc+8XaqEocKyhzeoSWL7dLfa/QnCdUS82KTo
	a5O2BAefh4yo7BMgD14FIrAt3XHo8YI+QQ5POzYZ/Kahp7FBBFQ/04M7C3nWbrNeBdg==
X-Received: by 2002:a17:906:710:: with SMTP id y16mr33804455ejb.58.1562143089907;
        Wed, 03 Jul 2019 01:38:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNXqRDExS09+gK/wZsCOCJilFwtViZY+QTfSmPhtLNMoiXkYxkj7ZBws20UfjdgQzoaQRp
X-Received: by 2002:a17:906:710:: with SMTP id y16mr33804408ejb.58.1562143089068;
        Wed, 03 Jul 2019 01:38:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562143089; cv=none;
        d=google.com; s=arc-20160816;
        b=uhtK3LzOBrBpGD2ZVGikKcZtHG9LFeeTuVegy7AiEr4TP6vfqF/yB1JHTXe4SPkSfQ
         RdwKSVJdrleiObbO3YyGFmNZx5hB65kOLf/eNFNWTejwezH0KN+ngQK9fzxPtOtV2NC1
         vxeMrxgzTQxIL/GGEjtst16CSAuQamu37CJ235LELrZfvErX3foc8QtFgHL3SJGkZRV3
         FCZHitC6fMU9rGPuVEKRw7gX/g6OwmfuVzZGe83gTRBK1bhKI+M3LvWtorPA5EEV55BH
         wO/CyP4gkcG9bRP0R2lFPEKXmnavaiO8LyuajX20+ITUUxttfAo6lPzafV9dKMbBqXcR
         14RA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ov/WUMJVjnGbIQZfKUy91267gBtC+5ZEz6DU5KJvSdY=;
        b=l8AoHoMXBbczljzFIOAmC2spNxvhKHd1AblyrKX0wryh2wjVeQFDjhV8rd2oN3Vqk0
         PHbKyYkmdbdXbxmOwziuIu5Rftzu2mBnzM8DRxgvS3YWPbvwlc0OqyRrDNFSQ/tYh9/0
         Z+delOguRpCRrM8lN8d6voz4QAX1H7/j9xjrdOtL7+07qu+QObxlBdAEookfv46J0/4S
         HC8Y64twpoVv40o56w1uDVU/GvKdf/7+RqxrmUpzjmMgRmmr+33JWQ0Bvv2ADPvbeh8h
         eaAo9GO3gVq2hk9GRyI15kK0teGPKtMzJCSmullAGYxm6Hzfx3wfK/QZmOeRXGcUf9S4
         j14w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id pj23si1167171ejb.251.2019.07.03.01.38.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 01:38:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) client-ip=81.17.249.39;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id B97C09904D
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 08:38:08 +0000 (UTC)
Received: (qmail 31277 invoked from network); 3 Jul 2019 08:38:08 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.21.36])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 3 Jul 2019 08:38:08 -0000
Date: Wed, 3 Jul 2019 09:38:03 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hdanton@sina.com>,
	Roman Gushchin <guro@fb.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm, vmscan: prevent useless kswapd loops
Message-ID: <20190703083803.GA2737@techsingularity.net>
References: <20190701201847.251028-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190701201847.251028-1-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 01:18:47PM -0700, Shakeel Butt wrote:
> On production we have noticed hard lockups on large machines running
> large jobs due to kswaps hoarding lru lock within isolate_lru_pages when
> sc->reclaim_idx is 0 which is a small zone. The lru was couple hundred
> GiBs and the condition (page_zonenum(page) > sc->reclaim_idx) in
> isolate_lru_pages was basically skipping GiBs of pages while holding the
> LRU spinlock with interrupt disabled.
> 
> On further inspection, it seems like there are two issues:
> 
> 1) If the kswapd on the return from balance_pgdat() could not sleep
> (i.e. node is still unbalanced), the classzone_idx is unintentionally
> set to 0  and the whole reclaim cycle of kswapd will try to reclaim
> only the lowest and smallest zone while traversing the whole memory.
> 
> 2) Fundamentally isolate_lru_pages() is really bad when the allocation
> has woken kswapd for a smaller zone on a very large machine running very
> large jobs. It can hoard the LRU spinlock while skipping over 100s of
> GiBs of pages.
> 
> This patch only fixes the (1). The (2) needs a more fundamental solution.
> To fix (1), in the kswapd context, if pgdat->kswapd_classzone_idx is
> invalid use the classzone_idx of the previous kswapd loop otherwise use
> the one the waker has requested.
> 
> Fixes: e716f2eb24de ("mm, vmscan: prevent kswapd sleeping prematurely
> due to mismatched classzone_idx")
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

