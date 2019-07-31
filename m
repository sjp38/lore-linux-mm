Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 836E9C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 07:21:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 451BB218BB
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 07:21:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 451BB218BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E20968E0003; Wed, 31 Jul 2019 03:21:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD1C18E0001; Wed, 31 Jul 2019 03:21:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C985A8E0003; Wed, 31 Jul 2019 03:21:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 797DA8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 03:21:04 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so41760420ede.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 00:21:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jhx6/Aw9oNPkMcp5yKnieVEF039ctGqu4bfl/yHqZbU=;
        b=muZOFZCKvUOZnz8ndjHfv0RqbzWJgRhBoI6SFReffRI22OXCuScirj+nC8WkqCaT3I
         fvFfA7fLVzGDMTPmIoOuljqmBMpbqHXjGDQFc5A3WCsHTJXqhXwtq3nAPbj+9ZFtTrwa
         KAaaz5C2WQz2Dz8KSviJO/DRj9kc9zl+ZiwHHSpYduhW5EK09HK1ZxRzl8jp31y7et8l
         MjRYkJJCD2juVWcvPrvAKZyWTPfqbwoxbv55zZuu6vaZDEgmbyKyUYNkKFeTNMPumYJ2
         yalM2mhvpqlN1s4TrBwPoOnJ8hlccQoWnizR+xYc89z+023Ry/IaP9PQuOOJ5OK6ocrV
         HvQA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVwaEAif6eBDcDXsbhOUTY//Ey6RaNjIaFCQnnNa3Ph5vb8WED4
	jjaU9QJJMopFLDpN1kyTdj2aJPAR5m5fa04fdoyTyjL68j46gGjZFlc/47V5//xFYy41MyX2alm
	NF/DcmyI2cWPe+YPfyGdVixNxXOVst1k0eAWCjbtMat7e+X5PEPTiYpxmvJHAaRc=
X-Received: by 2002:a17:906:7092:: with SMTP id b18mr94125475ejk.40.1564557664044;
        Wed, 31 Jul 2019 00:21:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGA2Wd/Hhw7CdjAY0croA6NF0BQrrpdPX/kBn0i1Dd0VDgpMVR7xEfVLaRjkdb2M+JY08u
X-Received: by 2002:a17:906:7092:: with SMTP id b18mr94125425ejk.40.1564557663050;
        Wed, 31 Jul 2019 00:21:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564557663; cv=none;
        d=google.com; s=arc-20160816;
        b=WBVeuaae1OIhooTY+MkuQV1d2h3mpfdByAljETt1IJfOyVbWW3vUMQSTKWy++BHsUm
         kqDzLt2JmLl1LbtcFaYnFLO69yjnajeN1mgV+GIoD+MDwhnhqdJn7TtJ+SbmZxMtonLu
         9hj7HJrOzL45uuOuZ0u1ADI8D6qmlSxNYL/hC3q/3Nn04UF3yXvrcNKqF5VL8wKrdKvU
         EHCVjh2c4we541ChmaxdHUheZjvBZQQ2IyadOPzxV/x9YlqQWZOODAXdid7Frkkl2fBJ
         uAowg3XDzwmFy3WD41qP1WoNdRHhdBtY11h5wPDVFPQmHFuZAew80/W+Cmhvcxwi8iyz
         nETg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jhx6/Aw9oNPkMcp5yKnieVEF039ctGqu4bfl/yHqZbU=;
        b=o8BHMP4weDofRDOZ7XoApXMOFhG+tIOpUOVwGDm7ZZdDxZmXRGboDA4kFocojsNgvu
         rkMrP37994Y4ONsryWeoenaxwqXOU6RDHFlRDwDO+nxG8j9mmi3hOP4h+geCSGnGLJds
         eA2NqdOw124HGFcVG7xPRWQ5DbUDZ+6koY8HXGB0GaaLJvCMi/l+Al+fg06CAlvxE482
         FT+mNM2qkjlxpoEzWsolAT2AUqX8I/3ZewCn4wAarMUALUguxx2QWyKNzye5KKyRgpdc
         JYssceDJ3OSjHVoPAEwBXBk39ub4Oywg5qJDpgwmvyXzH/cEZwrELFVFIQv4ED0bKwXC
         E3hA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si19742481ejk.288.2019.07.31.00.21.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 00:21:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E663DAE52;
	Wed, 31 Jul 2019 07:21:01 +0000 (UTC)
Date: Wed, 31 Jul 2019 09:21:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-ID: <20190731072101.GX9330@dhcp22.suse.cz>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190729074523.GC9330@dhcp22.suse.cz>
 <20190729082052.GA258885@google.com>
 <20190729083515.GD9330@dhcp22.suse.cz>
 <20190730121110.GA184615@google.com>
 <20190730123237.GR9330@dhcp22.suse.cz>
 <20190730123935.GB184615@google.com>
 <20190730125751.GS9330@dhcp22.suse.cz>
 <20190731054447.GB155569@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731054447.GB155569@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 14:44:47, Minchan Kim wrote:
> On Tue, Jul 30, 2019 at 02:57:51PM +0200, Michal Hocko wrote:
> > [Cc Nick - the email thread starts http://lkml.kernel.org/r/20190729071037.241581-1-minchan@kernel.org
> >  A very brief summary is that mark_page_accessed seems to be quite
> >  expensive and the question is whether we still need it and why
> >  SetPageReferenced cannot be used instead. More below.]
> > 
> > On Tue 30-07-19 21:39:35, Minchan Kim wrote:
[...]
> > > commit bf3f3bc5e73
> > > Author: Nick Piggin <npiggin@suse.de>
> > > Date:   Tue Jan 6 14:38:55 2009 -0800
> > > 
> > >     mm: don't mark_page_accessed in fault path
> > > 
> > >     Doing a mark_page_accessed at fault-time, then doing SetPageReferenced at
> > >     unmap-time if the pte is young has a number of problems.
> > > 
> > >     mark_page_accessed is supposed to be roughly the equivalent of a young pte
> > >     for unmapped references. Unfortunately it doesn't come with any context:
> > >     after being called, reclaim doesn't know who or why the page was touched.
> > > 
> > >     So calling mark_page_accessed not only adds extra lru or PG_referenced
> > >     manipulations for pages that are already going to have pte_young ptes anyway,
> > >     but it also adds these references which are difficult to work with from the
> > >     context of vma specific references (eg. MADV_SEQUENTIAL pte_young may not
> > >     wish to contribute to the page being referenced).
> > > 
> > >     Then, simply doing SetPageReferenced when zapping a pte and finding it is
> > >     young, is not a really good solution either. SetPageReferenced does not
> > >     correctly promote the page to the active list for example. So after removing
> > >     mark_page_accessed from the fault path, several mmap()+touch+munmap() would
> > >     have a very different result from several read(2) calls for example, which
> > >     is not really desirable.
> > 
> > Well, I have to say that this is rather vague to me. Nick, could you be
> > more specific about which workloads do benefit from this change? Let's
> > say that the zapped pte is the only referenced one and then reclaim
> > finds the page on inactive list. We would go and reclaim it. But does
> > that matter so much? Hot pages would be referenced from multiple ptes
> > very likely, no?
> 
> As Nick mentioned in the description, without mark_page_accessed in
> zapping part, repeated mmap + touch + munmap never acticated the page
> while several read(2) calls easily promote it.

And is this really a problem? If we refault the same page then the
refaults detection should catch it no? In other words is the above still
a problem these days?

-- 
Michal Hocko
SUSE Labs

