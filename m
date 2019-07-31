Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FF87C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:26:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A0E820693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:26:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A0E820693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4F9E8E0008; Wed, 31 Jul 2019 08:26:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFFD18E0001; Wed, 31 Jul 2019 08:26:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC7B68E0008; Wed, 31 Jul 2019 08:26:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 601FF8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:26:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so42289332eda.9
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:26:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XedTXaeQUbc2Eii+m33NWqzYIeDu7e0MmI7swzvsUOY=;
        b=q75FrnIk53bQL1LFGZqVtkLCg2kCpTuGn+G+YOZVZflNok9wRzar4CLsA8HuSDrpqZ
         QZC59XV7506yChPox3YWyhUlLBdjjBk6WrpaOV0adgEcQkb8aqoPH53LXhRSsKFR4mAx
         lTgRmGjaxVUMWY5TIs5dzAoP5Qr3yhChWzWyjDwyIR3tV+SOCzS5ql9Js2cMhTK9tF4d
         eACrJLH14A+WFKICshCQvQBaIPL0LKgUlX86ZrKjBkjtMOrgsgMcvKPSMnDrAuZl0er5
         G1aM7JnPN7YSLXbEg1zYtvOOUc6gzJrInSmgFipzNksHmUsnNnbNqc/Oyf1Rcedd6DzM
         81OQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAUjTm2IhgzBeydkeexcHZC1qZXPmN3DSp2LoDaHayEql8gFCJBu
	8aMVZiu/o/CCirYmRhezy4tK+nT03yLdfqQUDdhzloe6blRim6wY4Q54WfhCV1bQdyi2o1tMXxm
	G0uJeorqZq6rvVU6rR5X385vrg1T4LuIuKw23RCtorBSm9BvO5jOiABf4WfYqJyEUNQ==
X-Received: by 2002:a17:906:e241:: with SMTP id gq1mr93069511ejb.265.1564575962868;
        Wed, 31 Jul 2019 05:26:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygOj9CJRqRakq0RGkAFDyxQDLFhpkJT7I1J20wt8wRLeJ42oHDbHxTbRLly+PSkrH1LB8d
X-Received: by 2002:a17:906:e241:: with SMTP id gq1mr93069445ejb.265.1564575962021;
        Wed, 31 Jul 2019 05:26:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564575962; cv=none;
        d=google.com; s=arc-20160816;
        b=hZPxglnFlbHJTXvgf3QemmAElWX1cBhlDwtHNUwH8MIZsPkxbrPbZ1Qq9oGRgrNQgT
         Ab1BXb5wMvJBiaby9Fe0OoCFxsaorgoN5XyW02rp/KizKoLaYburV0336xVUAlsolPft
         9VpKHfl3SaMFVbybYlDfcsj5hBU91J19ZAW72xolE7t3IU9jx5O+/+kJSC9YhxK0pm73
         B1IfCdy8M/YGhtJUCsqw/bewZNQ0Z8VvhkvhJUO6vtYD9ihMGLlu1OefFpUc+3a90StO
         NWimFe1ZrIwXcXAaB2JDmSfcKo5xIb8UZiZ4LtXJSMh8NSsInReKIRYcxPDGHdBheS/h
         MouA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XedTXaeQUbc2Eii+m33NWqzYIeDu7e0MmI7swzvsUOY=;
        b=nG8vVawcwNCwCNZT7Tw5ZqgjuhkzKhmIsBgacyIG8ZNYXhSrysD5bS4SSIW1lNY5b1
         EK1c+hGZU+gJE0oomXib2eg88i6jfzHDNBkqPLsXocfbMoYs+pvj6wJIqzqj5ur7Iz6h
         OEPCcRK+0+JUAlQUgjFhpK50cWlOkWHQqug/Jlz0sJSyoM1kAgekli5ygeOaiX+1hWPv
         FzKKZ9m6X4AHRpJgeDKnfJRcsb5B0fXWDoXN/AZ+uPR3iX+z9rZT5aYygGf14lddepH/
         rU26E5vmpRvqArxlisSPpC/nOYeJSz1tsUBO/GPvJrmukpmlijsgH85PM89lm/0KM673
         4rTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i20si18240970ejb.107.2019.07.31.05.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 05:26:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7C955AC64;
	Wed, 31 Jul 2019 12:26:01 +0000 (UTC)
Date: Wed, 31 Jul 2019 13:25:59 +0100
From: Mel Gorman <mgorman@suse.de>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hillf Danton <hdanton@sina.com>, Mike Kravetz <mike.kravetz@oracle.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim
 perform dryrun detection
Message-ID: <20190731122559.GH2708@suse.de>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-2-mike.kravetz@oracle.com>
 <20190725080551.GB2708@suse.de>
 <295a37b1-8257-9b4a-b586-9a4990cc9d35@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <295a37b1-8257-9b4a-b586-9a4990cc9d35@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 01:08:44PM +0200, Vlastimil Babka wrote:
> On 7/26/19 9:40 AM, Hillf Danton wrote:
> > 
> > On Thu, 25 Jul 2019 08:05:55 +0000 (UTC) Mel Gorman wrote:
> >>
> >> Agreed that the description could do with improvement. However, it
> >> makes sense that if compaction reports it can make progress that it is
> >> unnecessary to continue reclaiming.
> > 
> > Thanks Mike and Mel.
> > 
> > Hillf
> > ---8<---
> > From: Hillf Danton <hdanton@sina.com>
> > Subject: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim perform dryrun detection
> > 
> > Address the issue of should_continue_reclaim continuing true too often
> > for __GFP_RETRY_MAYFAIL attempts when !nr_reclaimed and nr_scanned.
> > This could happen during hugetlb page allocation causing stalls for
> > minutes or hours.
> > 
> > We can stop reclaiming pages if compaction reports it can make a progress.
> > A code reshuffle is needed to do that. And it has side-effects, however,
> > with allocation latencies in other cases but that would come at the cost
> > of potential premature reclaim which has consequences of itself.
> 
> I don't really understand that paragraph, did Mel meant it like this?
> 

Fundamentally, the balancing act is between a) reclaiming more now so
that compaction is more likely to succeed or b) keep pages resident to
avoid refaulting.

With a) high order allocations are faster, less likely to stall and more
likely to succeed. However, it can also prematurely reclaim pages and free
more memory than is necessary for compaction to succeed in a reasonable
amount of time. We also know from testing that it can hit corner cases
with hugetlbfs where stalls happen for prolonged periods of time anyway
and the series overall is known to fix those stalls.

> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Hillf Danton <hdanton@sina.com>
> 
> I agree this is an improvement overall, but perhaps the patch does too
> many things at once. The reshuffle is one thing and makes sense. The
> change of the last return condition could perhaps be separate. Also
> AFAICS the ultimate result is that when nr_reclaimed == 0, the function
> will now always return false. Which makes the initial test for
> __GFP_RETRY_MAYFAIL and the comments there misleading. There will no
> longer be a full LRU scan guaranteed - as long as the scanned LRU chunk
> yields no reclaimed page, we abort.
> 

I've no strong feelings on whether it is worth splitting the patch. In
my mind it's more or less doing one thing even though the one thing is a
relatively high-level problem.

-- 
Mel Gorman
SUSE Labs

