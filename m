Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17B54C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:49:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A781A214AE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:49:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="rL5Ivjyx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A781A214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3ECD56B0003; Tue, 23 Apr 2019 13:49:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39AE56B0005; Tue, 23 Apr 2019 13:49:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B1976B0007; Tue, 23 Apr 2019 13:49:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E6AFA6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:49:33 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y2so10116401pfl.16
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:49:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HJ35sOEMVN34mLI2USzMGGKY3B+fCBZ3VVgsD22RONA=;
        b=UMeKf8xLzIhPEtmezLcDRHPvFzlOinETwfkOXzYGMR8lXz8usD/emCsA/+VusMpOpO
         jMcP0SLPtF1OgM1Sj4lrvXJSlVPWYoYLs8nbpMPxtrZNQsNxTcfTSoiFm6kLqFaCQdSY
         5Z/OXH1C7kBtlr1V9JcEkIN3/0vDG+J2kYBNPTSRECxkZqscAFgXf99jMUgWKEBlgQDG
         43YRyQt+EvMkjTFG4RQfe8hv912P1QlZcvgPvXeu+cAMebQFKwH5WGwZtUaa5mDcWzbs
         1oBeJc9wPMmjqhWvL4h2cxoAIE2cno/p8hEz49XaLsK2l8zMeUWXa0wQ5O/rdoz1gkS1
         rZbA==
X-Gm-Message-State: APjAAAU8ViFJg3amZYMDH9bZBHdpwLwYBp7f8yJSGFSQmvd9OKTzjrnO
	nkHTLOogliy1FWiDuFbuMR3u6lOKLSw8QTJE8l+iVIBtjaFM3drcOxha+4r4RnkS4fvwGYEPvYt
	DDfmaEkoCl6bonKrEOc9toayODP4AWQBnAend27ZP81Bq7mstAGut5iFGxi/2LrxsnA==
X-Received: by 2002:a62:b418:: with SMTP id h24mr27625762pfn.145.1556041772947;
        Tue, 23 Apr 2019 10:49:32 -0700 (PDT)
X-Received: by 2002:a62:b418:: with SMTP id h24mr27625700pfn.145.1556041772229;
        Tue, 23 Apr 2019 10:49:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556041772; cv=none;
        d=google.com; s=arc-20160816;
        b=k3qnSKfMdEPEgR25qCVaA4K0YyIY99iQZX5AW0HTha56NPG/CwIDO+IHoWJM6UBpYV
         mr/+qviOY9BiF9zEeQWKWxehvbAHCpRI32IIQr1kBVbIBh41pZDn3BTfAaA5Iifxw6k8
         fJ7LXdZMHWoelMn/rwnTxMB7RgXoJk60mftdomW3b6bdmrEkMTbHQG2CqxAcU+4aVkmF
         /q4toPEJxcPpxdz2v43shyTvg3t3r6Xl7e/e9CrmuSj11OEsKRxwyejprR/hbubWQ8t9
         J/tq9wJK4OIHEucELT+XvJgZNBkAWoQMwwCofFU/LFtT3q0gdpwQypyVR2lMFFUTKfw+
         jSIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HJ35sOEMVN34mLI2USzMGGKY3B+fCBZ3VVgsD22RONA=;
        b=gXc2/GGTtkTwscnloAKnKNNC9TACey0SGvkKtZDlqcSiGFoT4n9wQa6OhCxhEsWWHk
         fDBoGCu9gZfPjPJwb5TgnccY2jmB99nDuhUvKk4XJJHKPU363GG5RkAJYrOHTxaBjjxz
         6igBr9GmiIs8tW2CpJAQZfS2rPMG2Ee+Bvktgl4VLLcOln75xZmsHJdqeEqMxNTtpMax
         PmykXzJDciOP0hOqf2mV5F7rLGVmrgH2eOKUlvkhCfP1EFyoehdfjBa1EzCcluNjYcB1
         bg4P20ipbGR0MP21c+d+0CgAVmIkprlSRzElD9axNFkhMq7OlZl0lgrIyUMFpVkdXt6c
         6IFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=rL5Ivjyx;
       spf=temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) smtp.mailfrom=hannes@cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor3208140plo.22.2019.04.23.10.49.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 10:49:24 -0700 (PDT)
Received-SPF: temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=rL5Ivjyx;
       spf=temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) smtp.mailfrom=hannes@cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HJ35sOEMVN34mLI2USzMGGKY3B+fCBZ3VVgsD22RONA=;
        b=rL5Ivjyx36jFOWtetsKkBvhiq1yEvr4Qmm0ZlvCmDUC2+eFE0G4gMVTq/WXa/Z/VSv
         kLwnW3GUFGa7z4n7iRwSxxlK8Ksw+aFqxAEW0Y/DyKT5Fe6ICDuYhwRjnujivXEWYPhT
         tkqbEjaR0DnO0HXdfospmOFBO/1dI0p74lJWKRj3iZ6PVj7Y2wtvpa02npKerDHbzYje
         lWaZZVCFcqL9cAIkJXHwQQjFJj7qCESWeKDEsaYLBrD7iCjZ95kRvwhMaK/pFB1DKHxm
         mAF+XBgi+U3r/6HCaOg3vLRcf9Dac/E1SkWfNdcvZ/U4c6mmrAO4tKUP9LJkARUL9Thl
         GTXg==
X-Google-Smtp-Source: APXvYqzLEX8dVZvSG+PB7Bk1d0vauwxd8b/MTAVfmvg4aRR+XDDwTwnPG2csGjW/dJJbjeSCwjKBtw==
X-Received: by 2002:a17:902:70c9:: with SMTP id l9mr9715395plt.33.1556041763655;
        Tue, 23 Apr 2019 10:49:23 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:6d60])
        by smtp.gmail.com with ESMTPSA id s19sm7001420pgj.62.2019.04.23.10.49.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 10:49:22 -0700 (PDT)
Date: Tue, 23 Apr 2019 13:49:20 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Rik van Riel <riel@surriel.com>, lsf-pc@lists.linux-foundation.org,
	Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>
Subject: Re: [LSF/MM TOPIC] Proactive Memory Reclaim
Message-ID: <20190423174920.GA5613@cmpxchg.org>
References: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
 <8588314f167c9525e134ade91afdbebcd9e62eb1.camel@surriel.com>
 <CALvZod44yAJTLuvg9jtqHF9uKuKNtXL9p_=3Ld+eakSijAbo1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod44yAJTLuvg9jtqHF9uKuKNtXL9p_=3Ld+eakSijAbo1A@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 10:04:19AM -0700, Shakeel Butt wrote:
> On Tue, Apr 23, 2019 at 9:08 AM Rik van Riel <riel@surriel.com> wrote:
> > On Tue, 2019-04-23 at 08:30 -0700, Shakeel Butt wrote:
> > This sounds similar to a project Johannes has
> > been working on, except he is not tracking which
> > memory is idle at all, but only the pressure on
> > each cgroup, through the PSI interface:
> >
> > https://facebookmicrosites.github.io/psi/docs/overview
> >
> 
> I think both techniques are orthogonal and can be used concurrently.
> This technique proactively reclaims memory and hopes that we don't go
> to direct reclaim but in the worst case if we trigger direct reclaim
> then we can use PSI to early detect when to give up on reclaim and
> trigger oom-kill.
> 
> Another thing I want to point out is our usage model: this proactive
> memory reclaim is transparent to the jobs. The admin (infrastructure
> owner) is using proactive reclaim to create more schedulable memory
> transparently to the job owners.

That's our motivation too.

We want a more accurate sense of actually "required" RAM for each job,
as determined by the job's latency expectations, the access frequency
curve, and IO latency (or compression and CPU latency - whatever is
used for secondary storage). The latter two change dynamically based
on memory and IO access patterns, but psi factors that in.

It's supposed to be transparent to the job owners and not impact their
performance. It's supposed to help them understand their own memory
requirements and the utilization of their resource allotment. Having a
better sense of utilization also helps fleet capacity planning.

