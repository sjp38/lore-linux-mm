Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D689DC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 18:55:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9594120B1F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 18:55:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="KqQaDyfI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9594120B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0253D6B0007; Mon,  5 Aug 2019 14:55:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F189D6B0008; Mon,  5 Aug 2019 14:55:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E08116B000A; Mon,  5 Aug 2019 14:55:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A5E366B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 14:55:51 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x1so4261138plm.9
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 11:55:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IQcIqePmHwbU1aOJ0YM+1RcergtjpirpesFhw8kFv0g=;
        b=EsbiiMYmx2G2Eh34VU7VEpmTvQA6WWtxgUQSnyj4Eb8IKTJDBfOLvbVsnZ843puVn7
         CS4rxBaR8x+hKmILwx/Zj4dXyvGkoFzEgxvzKvQrLkRGoo6LxbILiP01tZOG1dAfOsS5
         MoHIhLmXGZA920iswHAT6isbsZt9PE34Mr+1iXlq0oW/Fz8o7UFVBhonBd5Lh5CPUS3s
         7eT/LZYRr+gNgmi7sl6si5gYI8WipsQBFl9VRwcfaVeDmq4aJBYMXgpDWUn1gMA1fnv/
         AUSG2Q1vAJBCqSGD3dMURirZASnR2re2V0tQyXQ0pQqryuUOVoJFJjE91/An73T6vyRZ
         YhVw==
X-Gm-Message-State: APjAAAULCjQ7+U5zf9sgKRfCRcFk3zI5KjzYusfeAaQiImv98KgSLA3h
	1dtUJs3fXmWZ6OAS+0xWcigL4AOYQcr5QLCPHbmQhuD3giwheQjxMoW2xVlMz1tyv+gqOqlgPwF
	Wx6Y/m6ZpeTxB0s9D5W5Gh15L32wTT++rcASh8o99+L+kPV7kwKp247Vrv0KiZAIhFQ==
X-Received: by 2002:a62:17d3:: with SMTP id 202mr74589441pfx.198.1565031351164;
        Mon, 05 Aug 2019 11:55:51 -0700 (PDT)
X-Received: by 2002:a62:17d3:: with SMTP id 202mr74589357pfx.198.1565031350071;
        Mon, 05 Aug 2019 11:55:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565031350; cv=none;
        d=google.com; s=arc-20160816;
        b=gkRWKE2yUv5CnCDy+FE5mG7eRD5qU7sFjF01q5vGvGXRy5BTZ8bQqdx8dp3nFqzUMx
         a19gNmrPhZaXmSGmwS3kP7/fldmBoWFanY8aKKGUQbTRiApiUdRIj6lPgTAxG0kHKYYl
         hz0Qq1tQTFtqf7hAZhtRiARYdFvTY9WTvSgsrvHAbtTVdkeo4hn9/FNcEcLMGDpfn3Yo
         ulbI8E6bPl9EvJzmejJfPMfyBimbuVnMm/vb02V1VvpRGPMyIbLsCe/4XrJQHDgkl62d
         8SH9owhKtRwfIrsUYxHrZ1oYhgD2GYF7OmwVeJLO8hxjksgqDPgzRKSkCm1HHGkefeNe
         oyKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IQcIqePmHwbU1aOJ0YM+1RcergtjpirpesFhw8kFv0g=;
        b=poUjG2PuoD5EAJbCVMKTN6VsdcW0dFit3MYi94wMet6pHOnJ9GMsWaJWopqgqw1pDK
         pfr1H9FfSCtAONIc63ZGQVZFzKd/zBRHl1R2a51BJCDEOLqxjCmbpk9kfBaP1PETFxg7
         HsVS0PO+PrDD4RbJ3A5llsKFPI+QL7OVvxz6MjnAH4Nz/bU1/F/OP3xUnJtZD/E49nBW
         Asr+6USCl15g/FospEG+n5PyAD6PICEyMNCY6dwEIsCSS6mw2prBS7eRT+5vCPGiFKPM
         Jt67KKuuMYt+dHLEdPRnS7KwRJnE1jKAw17d00NsnlBwyGIpii0j2cEDfS33QV5RLCVv
         bM/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=KqQaDyfI;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor21875338pjv.21.2019.08.05.11.55.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 11:55:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=KqQaDyfI;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IQcIqePmHwbU1aOJ0YM+1RcergtjpirpesFhw8kFv0g=;
        b=KqQaDyfIGQaedidhq4D9gHxw/6dy36hac81f3g2RQhCbOg3VujyHZZjXZhRmA+3vPC
         /ANIN0nWfn+cHMmYH7csSIIy+NTsFbTcbfVlULjuWBxTSdbQoJkOjvoEmI1aS12DMihn
         pLSr8aI+EMOrwQb6UQb8FKD606UAYxgXjV1BOv07NWCXAdD8UbBzhw0YE/LzLhWUL6PS
         3ak6oAICVtR/T3dZbNyhu2nVeneYM+vTRDTqfm3Cujvc7UDUB04vojzbSQwTry1wnfTK
         z6zGGbXiY6ZJ/NF3fGRkxoLi4qbzxJmOi5legLVkoPyqU4r6YjJRi+hWYZ7IGz24otV2
         dZ5g==
X-Google-Smtp-Source: APXvYqzqA+KOZhPbDYXfQOwSJMtDyzmoVXzgNlQERlbradygWxcdNYFH5+0WgV6Y8Woa5qAU4AVWwA==
X-Received: by 2002:a17:90a:32ec:: with SMTP id l99mr19767165pjb.44.1565031344784;
        Mon, 05 Aug 2019 11:55:44 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::26a1])
        by smtp.gmail.com with ESMTPSA id p7sm94739480pfp.131.2019.08.05.11.55.43
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 11:55:44 -0700 (PDT)
Date: Mon, 5 Aug 2019 14:55:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Artem S. Tashkinov" <aros@gmx.com>,
	linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>,
	Suren Baghdasaryan <surenb@google.com>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190805185542.GA4128@cmpxchg.org>
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
 <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805133119.GO7597@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805133119.GO7597@dhcp22.suse.cz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 03:31:19PM +0200, Michal Hocko wrote:
> On Mon 05-08-19 14:13:16, Vlastimil Babka wrote:
> > On 8/4/19 11:23 AM, Artem S. Tashkinov wrote:
> > > Hello,
> > > 
> > > There's this bug which has been bugging many people for many years
> > > already and which is reproducible in less than a few minutes under the
> > > latest and greatest kernel, 5.2.6. All the kernel parameters are set to
> > > defaults.
> > > 
> > > Steps to reproduce:
> > > 
> > > 1) Boot with mem=4G
> > > 2) Disable swap to make everything faster (sudo swapoff -a)
> > > 3) Launch a web browser, e.g. Chrome/Chromium or/and Firefox
> > > 4) Start opening tabs in either of them and watch your free RAM decrease
> > > 
> > > Once you hit a situation when opening a new tab requires more RAM than
> > > is currently available, the system will stall hard. You will barely  be
> > > able to move the mouse pointer. Your disk LED will be flashing
> > > incessantly (I'm not entirely sure why). You will not be able to run new
> > > applications or close currently running ones.
> > 
> > > This little crisis may continue for minutes or even longer. I think
> > > that's not how the system should behave in this situation. I believe
> > > something must be done about that to avoid this stall.
> > 
> > Yeah that's a known problem, made worse SSD's in fact, as they are able
> > to keep refaulting the last remaining file pages fast enough, so there
> > is still apparent progress in reclaim and OOM doesn't kick in.
> > 
> > At this point, the likely solution will be probably based on pressure
> > stall monitoring (PSI). I don't know how far we are from a built-in
> > monitor with reasonable defaults for a desktop workload, so CCing
> > relevant folks.
> 
> Another potential approach would be to consider the refault information
> we have already for file backed pages. Once we start reclaiming only
> workingset pages then we should be trashing, right? It cannot be as
> precise as the cost model which can be defined around PSI but it might
> give us at least a fallback measure.

NAK, this does *not* work. Not even as fallback.

There is no amount of refaults for which you can say whether they are
a problem or not. It depends on the disk speed (obvious) but also on
the workload's memory access patterns (somewhat less obvious).

For example, we have workloads whose cache set doesn't quite fit into
memory, but everything else is pretty much statically allocated and it
rarely touches any new or one-off filesystem data. So there is always
a steady rate of mostly uninterrupted refaults, however, most data
accesses are hitting the cache! And we have fast SSDs that compensate
for the refaults that do occur. The workload runs *completely fine*.

If the cache hit rate was lower and refaults would make up a bigger
share of overall page accesses, or if there was a spinning disk in
that machine, the machine would be completely livelocked - with the
same exact number of refaults and the same amount of RAM!

That's not just an approximation error that we could compensate
for. The same rate of refaults in a system could mean anything from 0%
(all refaults readahead, and IO is done before workload notices) to
100% memory pressure (all refaults are cache misses and workload fully
serialized on pages in question) - and anything in between (a subset
of threads of the workload wait for a subset of the refaults).

The refault rate by itself carries no signal on workload progress.

This is the whole reason why psi was developed - to compare the time
you spend on refaults (encodes IO speed and readhahead efficiency)
compared to the time you spend on being productive (encodes refaults
as share of overall memory accesses of a the workload).

