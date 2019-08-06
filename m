Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AD91C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:29:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55A8B20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:29:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55A8B20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5EDF6B027D; Tue,  6 Aug 2019 05:29:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E106A6B027E; Tue,  6 Aug 2019 05:29:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D00386B027F; Tue,  6 Aug 2019 05:29:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8174E6B027D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 05:29:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f3so53395591edx.10
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 02:29:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=y85BrkNx8zbU/+lSQRKl1qX/fn0oXFSdUBFyhmD0Bzw=;
        b=NJqR7d5naeA5wAqmHXYn1t5YAO+bhpLi4uniUCGGCOUXADg0/3mUqdvBYyk6cdC/dE
         MB8XR27J03qoRQ+IC1/USDWprX5rxKhVkV4+PltPRrgSdD99Kr7ysW7EiIp2DmiJS+mR
         FyaIVpX8Es3PBbRoWDCL12t4GsLKiJMtxLlaXM36tX4rv/2RSPAFOnfO4RowaRiahAW1
         7XQo0Hqp25W37VhWLDpgcrTj93l1C+F+PzcLg1AqRV1pA+rkUKJgBEXeU2yYfERKp2OS
         9Wphf4rzPhCIMYJRacvHm8TBKbLqzvhWenMUzOQUu0eitcF6ENGdBdeLmMUozpNgFO4r
         uX6Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVI/wdOuwVvrrT5yaFXiLvbxWOoKf8tNY20F3i1T++NYdYxAE2d
	REWtsTKmzFUqOR8DYCEBAJZGanEQe2hVpBKSyrNmQGnIHMJRofiX0J5ZmNAnLVcWlDHyy5TzKQT
	TJ7Fa+dU5csW1Cj+e1KFNS9e8/Y4W1CSyC4whLpw89uYJ/mTPWLqaDJV9yR8VEfc=
X-Received: by 2002:a17:906:af86:: with SMTP id mj6mr2163121ejb.157.1565083773048;
        Tue, 06 Aug 2019 02:29:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhc0I/gLAKn+McDAuTHn4ZfeDYG6uhn1AZkVqepuTObqynTRkQkefNckOoUFJH388MP7re
X-Received: by 2002:a17:906:af86:: with SMTP id mj6mr2163083ejb.157.1565083772179;
        Tue, 06 Aug 2019 02:29:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565083772; cv=none;
        d=google.com; s=arc-20160816;
        b=YHwkxOENtg+AwgDNkTnpaXbJYWyGyBPvIB8BIGbZru1d4kUJ5kFcqNA1+jpPKa4VeU
         U443FFCaRarMJsI/l24yydgQRFm8xlq8yoqm66IAsrnBIGBJOcPtTogIrAPOVHxVvHa4
         0hLUOBIjBFKR6alM/xPskwWMjVKwH+4p9Ug7FMRoroj4coJEKoVzsLc5wknT0Z0HUlWl
         uSvGK7uxIBHV/a1AYH6q2ZgCgWcRzsyzOMPRfiqjn6MTJ27Hn1slLkGLSZsCUERLkitb
         /Say8COdXsu8WjKUIFCKCcc2nW+8tCNxIzvhcXMOPEyoDrWt+b8Poys0V/7cHunGukHi
         6njg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=y85BrkNx8zbU/+lSQRKl1qX/fn0oXFSdUBFyhmD0Bzw=;
        b=iliK2r0NegyF4qLFmka60meouucQxkO6mW0Roe2O6FgNDdEAg1UhD2O08qMGDz6EHH
         htLcScvmBaUWSRPd7kME1XKyEYqAHlY9V6L5GjcUqYM7DgP6SHzPVB5iffFAG+ldZh9H
         sxeYTLwQOf2v93XRPUT1Siw7QLsYkR7uL55XbhbncbF+8MvzHEeyJD7IM011AmOcNy33
         ffP2q4l+NAGqsJzV+Ta+RCz3ynqIRk0qqUSq3S0hRWyaF/ORrH4yiJSxX7CZgCmPwhx8
         FWhfWyxu2Pr5YBwy3oKiRxnEm3bwxJCWVMEzCCuJLHBkN5Y6Qqfe49qmWcBw1GpU6CWc
         pF+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qh16si27811263ejb.181.2019.08.06.02.29.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 02:29:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AF312AE6F;
	Tue,  6 Aug 2019 09:29:31 +0000 (UTC)
Date: Tue, 6 Aug 2019 11:29:30 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Artem S. Tashkinov" <aros@gmx.com>,
	linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>,
	Suren Baghdasaryan <surenb@google.com>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190806092930.GO11812@dhcp22.suse.cz>
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
 <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805133119.GO7597@dhcp22.suse.cz>
 <20190805185542.GA4128@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805185542.GA4128@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 14:55:42, Johannes Weiner wrote:
> On Mon, Aug 05, 2019 at 03:31:19PM +0200, Michal Hocko wrote:
> > On Mon 05-08-19 14:13:16, Vlastimil Babka wrote:
> > > On 8/4/19 11:23 AM, Artem S. Tashkinov wrote:
> > > > Hello,
> > > > 
> > > > There's this bug which has been bugging many people for many years
> > > > already and which is reproducible in less than a few minutes under the
> > > > latest and greatest kernel, 5.2.6. All the kernel parameters are set to
> > > > defaults.
> > > > 
> > > > Steps to reproduce:
> > > > 
> > > > 1) Boot with mem=4G
> > > > 2) Disable swap to make everything faster (sudo swapoff -a)
> > > > 3) Launch a web browser, e.g. Chrome/Chromium or/and Firefox
> > > > 4) Start opening tabs in either of them and watch your free RAM decrease
> > > > 
> > > > Once you hit a situation when opening a new tab requires more RAM than
> > > > is currently available, the system will stall hard. You will barely  be
> > > > able to move the mouse pointer. Your disk LED will be flashing
> > > > incessantly (I'm not entirely sure why). You will not be able to run new
> > > > applications or close currently running ones.
> > > 
> > > > This little crisis may continue for minutes or even longer. I think
> > > > that's not how the system should behave in this situation. I believe
> > > > something must be done about that to avoid this stall.
> > > 
> > > Yeah that's a known problem, made worse SSD's in fact, as they are able
> > > to keep refaulting the last remaining file pages fast enough, so there
> > > is still apparent progress in reclaim and OOM doesn't kick in.
> > > 
> > > At this point, the likely solution will be probably based on pressure
> > > stall monitoring (PSI). I don't know how far we are from a built-in
> > > monitor with reasonable defaults for a desktop workload, so CCing
> > > relevant folks.
> > 
> > Another potential approach would be to consider the refault information
> > we have already for file backed pages. Once we start reclaiming only
> > workingset pages then we should be trashing, right? It cannot be as
> > precise as the cost model which can be defined around PSI but it might
> > give us at least a fallback measure.
> 
> NAK, this does *not* work. Not even as fallback.
> 
> There is no amount of refaults for which you can say whether they are
> a problem or not. It depends on the disk speed (obvious) but also on
> the workload's memory access patterns (somewhat less obvious).
> 
> For example, we have workloads whose cache set doesn't quite fit into
> memory, but everything else is pretty much statically allocated and it
> rarely touches any new or one-off filesystem data. So there is always
> a steady rate of mostly uninterrupted refaults, however, most data
> accesses are hitting the cache! And we have fast SSDs that compensate
> for the refaults that do occur. The workload runs *completely fine*.

OK, thanks for this example. I can see how a constant working set
refault can work properly if the rate is slower than the overal IO
plus the allocation demand for other purpose.

Thanks!
-- 
Michal Hocko
SUSE Labs

