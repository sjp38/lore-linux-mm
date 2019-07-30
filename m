Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3556C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:32:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80989206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:32:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80989206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 168278E0005; Tue, 30 Jul 2019 08:32:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 119148E0001; Tue, 30 Jul 2019 08:32:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 007A18E0005; Tue, 30 Jul 2019 08:32:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A987A8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:32:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so40228500edm.21
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 05:32:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sxp88b6WFbuBPxyrgKzXsDoKSg+xj88W193M1hypjv8=;
        b=P4XTWbR+WeQ+ms60XtLACOPCobeLA0YvvgtzQ70w71gBspOnEw6jrqJV1LU+ZUw/Jy
         lZAueR09rgd13z8yTagSpJ5/2mlOG4jSph0UviLPXM0FyD8QMXy7RwFjHisprPIPnXWx
         ULL+loflpP3FPJTKHP60b93ByxPDiKG8LTL5i/T2CjNB+yrT68TDW8sXEb2/bvmbA8Y/
         QI13Tm1U3XdTqys+rAYHgAer3DNXG0ffqwB/jQDVtaKklXN/zjEHd1k+45POHYMQadph
         4TsYhTnf+naV9O3rpYoHs3HI7vWUmcfOnLQ0j7hI81iu+i9gVkevGa3cdFIbzqAZ/28N
         mqSw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWM4p76bv4zWG9pGsoTc2tiV4fSoClqVAy4MPmu5QgjwHDdNjZx
	OpkDH42MHwNHiaNdKelKvDRjApqUrfnHuN16NdFQqZaHFS9sNqmXC2Jzdd8fzdJjKp0gpS0UNew
	eJLyvBZG27WMZZLMZFdubc7i/oOl3MXSFfdyHeWVb0UNiKHtLx+dDzh5OO1XBiqQ=
X-Received: by 2002:a50:ac6e:: with SMTP id w43mr101533928edc.181.1564489959266;
        Tue, 30 Jul 2019 05:32:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy82tInfArp+6qPIrJFcqpjIpkN3pBvi+A5raytjdml+jQOm/ctaUwq0ip+TdXdmHIGabGN
X-Received: by 2002:a50:ac6e:: with SMTP id w43mr101533867edc.181.1564489958585;
        Tue, 30 Jul 2019 05:32:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564489958; cv=none;
        d=google.com; s=arc-20160816;
        b=QpyPUqgk/qz30uM2suH/WLnSYj7rVy3QvWUBkZzX5y7Yox4Iew24u+ZdSM1PoakbBj
         s0ekWIs484Aat58jS6x5NLgFtz6V6tRLMg1DKGy/p7lCZbCwB0rR0JbCgrMfEHlFpqtb
         QU4lMIkRMxCowRPGa9bUJAayOGb+5nXxG3In4fcu5yN+huycrIDG2yNZVCqlhIcBW+04
         jhjeYes2nOWGfrfgeCtta/j0AeSsbh9vjuTTfCrqmrSysVlyT1Kun3IGgrio+i2Ztl/E
         d30oYfitWWZnAZ52Ro49VxsjjxXKsxKphsOtA2FLjGc8SbRxjsLTsiKya3f2W+Gl1wMs
         FwaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sxp88b6WFbuBPxyrgKzXsDoKSg+xj88W193M1hypjv8=;
        b=hKgPsyUkvHT43xv5NjmnNbH3acY6u0g4o6wGQ+cfWjNI7uPInwej2QI3yePXsRkqwA
         pO2piiA8y2C7jK1qszHc4srVddH9WEOHYc3f27jCTI7lm7Xj83tYpHqxPhNC1LrpyM+e
         cd2TXHZPmFbLoSgxswvS+MP2HOB/DvB3EVIJNsddxuAl0eTLQZ883wd6+qP0A0J0pEMw
         S0Ck7SX8rk8QkpjNrOi1c87wloVU7h1NsDovsPTgfw3321PvgA68Yxfmro36ZFiAKqVo
         0Enlub1fyB0Uo7qfFv99X/cQK6mEESOmqm8Kfl7MW60aCWsPeyFS6x2XOWmxoNXQHLiQ
         4nAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s23si16258021eju.114.2019.07.30.05.32.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 05:32:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EDE1AAFD2;
	Tue, 30 Jul 2019 12:32:37 +0000 (UTC)
Date: Tue, 30 Jul 2019 14:32:37 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-ID: <20190730123237.GR9330@dhcp22.suse.cz>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190729074523.GC9330@dhcp22.suse.cz>
 <20190729082052.GA258885@google.com>
 <20190729083515.GD9330@dhcp22.suse.cz>
 <20190730121110.GA184615@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730121110.GA184615@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 30-07-19 21:11:10, Minchan Kim wrote:
> On Mon, Jul 29, 2019 at 10:35:15AM +0200, Michal Hocko wrote:
> > On Mon 29-07-19 17:20:52, Minchan Kim wrote:
> > > On Mon, Jul 29, 2019 at 09:45:23AM +0200, Michal Hocko wrote:
> > > > On Mon 29-07-19 16:10:37, Minchan Kim wrote:
> > > > > In our testing(carmera recording), Miguel and Wei found unmap_page_range
> > > > > takes above 6ms with preemption disabled easily. When I see that, the
> > > > > reason is it holds page table spinlock during entire 512 page operation
> > > > > in a PMD. 6.2ms is never trivial for user experince if RT task couldn't
> > > > > run in the time because it could make frame drop or glitch audio problem.
> > > > 
> > > > Where is the time spent during the tear down? 512 pages doesn't sound
> > > > like a lot to tear down. Is it the TLB flushing?
> > > 
> > > Miguel confirmed there is no such big latency without mark_page_accessed
> > > in zap_pte_range so I guess it's the contention of LRU lock as well as
> > > heavy activate_page overhead which is not trivial, either.
> > 
> > Please give us more details ideally with some numbers.
> 
> I had a time to benchmark it via adding some trace_printk hooks between
> pte_offset_map_lock and pte_unmap_unlock in zap_pte_range. The testing
> device is 2018 premium mobile device.
> 
> I can get 2ms delay rather easily to release 2M(ie, 512 pages) when the
> task runs on little core even though it doesn't have any IPI and LRU
> lock contention. It's already too heavy.
> 
> If I remove activate_page, 35-40% overhead of zap_pte_range is gone
> so most of overhead(about 0.7ms) comes from activate_page via
> mark_page_accessed. Thus, if there are LRU contention, that 0.7ms could
> accumulate up to several ms.

Thanks for this information. This is something that should be a part of
the changelog. I am sorry to still poke into this because I still do not
have a full understanding of what is going on and while I do not object
to drop the spinlock I still suspect this is papering over a deeper
problem.

If mark_page_accessed is really expensive then why do we even bother to
do it in the tear down path in the first place? Why don't we simply set
a referenced bit on the page to reflect the young pte bit? I might be
missing something here of course.

-- 
Michal Hocko
SUSE Labs

