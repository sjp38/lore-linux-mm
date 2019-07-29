Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F9A9C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:21:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBE6E20644
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:20:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gmynHK9g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBE6E20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FB8A8E0006; Mon, 29 Jul 2019 04:20:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AB598E0002; Mon, 29 Jul 2019 04:20:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59B278E0006; Mon, 29 Jul 2019 04:20:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2464A8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:20:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g18so32693287plj.19
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:20:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2sHb6igh5/VG31vZ5TimH3Lv/XXcD5eHvB6x/vi/sxg=;
        b=K8YCnrBu9hDAldAEeibGIbUtUiti7KdUWp0h39HHAuEhM70BuPz4u2pEWlTUwWGbBG
         M2704F5q5+tCoJA6BL45x6mo9cznE9DBxcFNBhCfKuiCxFi/TsQsOdjQXUqELRE+ayXQ
         Pp7zhSTqeF/o5uRYdfuIJvpIu5sAX2tGOnmqfAgE599YCJp2snM+OZhQAwaO980s1N7D
         y3XRxPAaIkxgbFnsHNjb+RK3V5sbSaGNnKXAaQY1SR8mzVEsovkvQwFPFWELVXmJPkN/
         TciefNgq1SHdVX/ROSSNN+Ai39cZ4C0mRcKyOEqiePkY3dBaaG1zXRShDbv81TcYfs27
         6t8g==
X-Gm-Message-State: APjAAAUud9rCc/VOYVzAiUyGm0EPufHbBIcHwXp0O58r0gGFaH20rovP
	BDpJeOymMGh3T0h1DIZQyG2VecY0s7sN8ypIhdsG5Hg26NqpOC8e26F2aSLl9SV2Pleai5tfgAO
	6gdyK1JaclUwgC8A2x4EesWn9bP1x8HFeNAILwllSrbOUo3fdkcJHfAnv2LjhhoM=
X-Received: by 2002:a17:902:2a29:: with SMTP id i38mr109673528plb.46.1564388458755;
        Mon, 29 Jul 2019 01:20:58 -0700 (PDT)
X-Received: by 2002:a17:902:2a29:: with SMTP id i38mr109673486plb.46.1564388458162;
        Mon, 29 Jul 2019 01:20:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564388458; cv=none;
        d=google.com; s=arc-20160816;
        b=v/Qhq7kVQZeqw5HilyTh2bp1oYizjdnhACoJ1u0BbXbWPeriqJF4FytDEZGR22Suep
         RUcTMp7Tn6DM1z5iqWpqj1DEEVv7tYat00/0IxTGbpIwsY/R78LXvNh4N+9vmBCcPF+d
         Cb4i2mlRVndsyvsJpZnvp8dZmWrAlU6XCT3Ybu1STm2PePw/ekMtiqaw0R0lywjUqHVa
         aFTlQm44Jw7neuBB+6RHPBWkX8oPSLAukzf8ESWkOr2iZZjJ9aQpPPSZJFcJlOvw7fGO
         nKERSGN1z9LWVqsxwhCRkLKkuB/zZw6VZlH9qV8lmnw3JzZ7AbmMCFWSgRgeS7P/3hlO
         wtyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=2sHb6igh5/VG31vZ5TimH3Lv/XXcD5eHvB6x/vi/sxg=;
        b=Olt3B2qNeC5RLA0AaeVRoHFpBjESFEnwzKBims4zkfZ3lfWMA2pgYy9dLIn5pKizhC
         enudQEt3UOOdkk3pZV4NX9z5XMMk4qcu4ecUIjaGRvHYDGrSw20GVAmfMNN6Zx1fFf1s
         UhSQ+BQzwFr5Ci/TychvowxbhIs1XzJmgDydRbGnhKPHIcoeLqnbbv8qjmtZIf5MZQAT
         cJE2zQnqWfDnnwBOIdRbeCWbJVUeXM0vHfx1d5TOMsQGOnuqzsBhsYZA3DAxdUWZAQSv
         NQwVgo1V9VLuRTQz1Z/KQl/mYH2MjzuV48eG+Jr5mTgtwVcjEw3EGiNg1AglCoxu8dhB
         jkRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gmynHK9g;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor72917255plt.64.2019.07.29.01.20.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 01:20:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gmynHK9g;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2sHb6igh5/VG31vZ5TimH3Lv/XXcD5eHvB6x/vi/sxg=;
        b=gmynHK9gyyTGbg08KX1ZQt/n4uNaNufyxFQUsiO6i7otivMqyM4q94qS47AsyjiSVz
         sh/KPvUiy8JFTmCXgaBbyvbzFmuebJJpq7OKcH656fOdOUDx1Ff2mlmF7RiGQiBYHtwU
         jbwDZsWevu5V4BTlyjpzZh3wGR1cUNovfzrkFOPT1JpXxKGxXa+IDLkxqbMdq1PEiyVk
         rrIqoI562bWsu3KXIN6408heothnZN4VbnypkaWfRf5oJo1Q3PchVIpQHMX43q+tpgCs
         MmeT9qhO+HEm7abd7SjLKzzuBbMqTIWzxZhZLX1kfTOnCT/q+up4nY4kIku7111SK4a1
         2d/w==
X-Google-Smtp-Source: APXvYqzPD2uMU0BPGJcyzlG6gVZffWUBi8HGnNgWln9aj61e+obG9uHjQlq+n0jJV4ijNPnNUaKatg==
X-Received: by 2002:a17:902:ea:: with SMTP id a97mr33346954pla.182.1564388457651;
        Mon, 29 Jul 2019 01:20:57 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id n98sm60659702pjc.26.2019.07.29.01.20.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 01:20:56 -0700 (PDT)
Date: Mon, 29 Jul 2019 17:20:52 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-ID: <20190729082052.GA258885@google.com>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190729074523.GC9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729074523.GC9330@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 09:45:23AM +0200, Michal Hocko wrote:
> On Mon 29-07-19 16:10:37, Minchan Kim wrote:
> > In our testing(carmera recording), Miguel and Wei found unmap_page_range
> > takes above 6ms with preemption disabled easily. When I see that, the
> > reason is it holds page table spinlock during entire 512 page operation
> > in a PMD. 6.2ms is never trivial for user experince if RT task couldn't
> > run in the time because it could make frame drop or glitch audio problem.
> 
> Where is the time spent during the tear down? 512 pages doesn't sound
> like a lot to tear down. Is it the TLB flushing?

Miguel confirmed there is no such big latency without mark_page_accessed
in zap_pte_range so I guess it's the contention of LRU lock as well as
heavy activate_page overhead which is not trivial, either.

> 
> > This patch adds preemption point like coyp_pte_range.
> > 
> > Reported-by: Miguel de Dios <migueldedios@google.com>
> > Reported-by: Wei Wang <wvw@google.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/memory.c | 19 ++++++++++++++++---
> >  1 file changed, 16 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 2e796372927fd..bc3e0c5e4f89b 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -1007,6 +1007,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
> >  				struct zap_details *details)
> >  {
> >  	struct mm_struct *mm = tlb->mm;
> > +	int progress = 0;
> >  	int force_flush = 0;
> >  	int rss[NR_MM_COUNTERS];
> >  	spinlock_t *ptl;
> > @@ -1022,7 +1023,16 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
> >  	flush_tlb_batched_pending(mm);
> >  	arch_enter_lazy_mmu_mode();
> >  	do {
> > -		pte_t ptent = *pte;
> > +		pte_t ptent;
> > +
> > +		if (progress >= 32) {
> > +			progress = 0;
> > +			if (need_resched())
> > +				break;
> > +		}
> > +		progress += 8;
> 
> Why 8?

Just copied from copy_pte_range.

