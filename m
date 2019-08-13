Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0491C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 18:14:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BBB020665
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 18:14:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="Xpgr53Vv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BBB020665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DCCE6B0007; Tue, 13 Aug 2019 14:14:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08DC16B0008; Tue, 13 Aug 2019 14:14:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE5586B000A; Tue, 13 Aug 2019 14:14:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0237.hostedemail.com [216.40.44.237])
	by kanga.kvack.org (Postfix) with ESMTP id CBFE16B0007
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:14:36 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 74139180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 18:14:36 +0000 (UTC)
X-FDA: 75818204952.06.hose26_b004e3c3a407
X-HE-Tag: hose26_b004e3c3a407
X-Filterd-Recvd-Size: 7669
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 18:14:35 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id w2so1235275pfi.3
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:14:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=EgcOWrbU42e6Bz/dNCaGzvQRlmmBX/ILwM0rAxK2QB8=;
        b=Xpgr53VvIkeiIKN7I509QxwJNBY38P1bS8Gb57ABqKGEjIDZT7FL7kvsq8TSUDicYz
         AV6mOPsUxwsdTmvxxhluwI1qmfupgIQR8/IJ38jYSTypC7rVcRM8NGi8WUEZipLoKVMZ
         Jz+1huobQe+KyeLD0c32pDcLoBiGynF7flJHDuhqOZmZo5qI/3OrbNwAjYVpzdxDsHSL
         twFboR4cqTfiADNZva+/cfsaEWD8i+bJqlvjgvQIb87GVugh+f0uW+pjcchomLVu2CtH
         16hyjA1yiWexmWe3OiNgDC1fxkbGApsvS3TU9O4P3UTG+oYTuGJ3zNimp3etPg43xIKQ
         TdMQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=EgcOWrbU42e6Bz/dNCaGzvQRlmmBX/ILwM0rAxK2QB8=;
        b=INh9p2sikY3QfAcQqKBwetqKfEfBHM2iasMbNsrTJKyM1I43N1+tjU3QgdXov3gOmV
         Uxbpu2XEXISWMsTH7D39CXRIXIixgfrsDEeAccJIFIA11ODZ/GbJga6FRdd7VGR9EGRO
         7ICTQfc6eCeVYI9cGfvKE8JqnkOIQnnlq03qC5zwiO4bq0V0cqgtPzWHHe/tJjtiPKaf
         KOMvGSs1Jaghk3Vs0QMJhhzsXiUc0yjXarMXYDSfCu4avAKhz/U3aiCK8BV6An7+ilEK
         vta9jh36jFZrPKVPTpE19CFHEOFY1lrfX3nOXed2spJeQt6OG5Drn0fMirgnJJaI+Pd0
         M4ww==
X-Gm-Message-State: APjAAAXuQWKZysz/SrwpmJ2t6MP/4K0Z+JNFj1F2FDQYhMK+b56DZNz3
	BsoTac6VgEkbSq7sNIGeK9vlZQ==
X-Google-Smtp-Source: APXvYqxm4rEwQVbBW1raq/7+W9mNweWzI0asgIirQw+hy7Tc8jMSIH3VXXZpkTVVJNolRGgIV23cFg==
X-Received: by 2002:a65:5c02:: with SMTP id u2mr35599324pgr.367.1565720073850;
        Tue, 13 Aug 2019 11:14:33 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:674])
        by smtp.gmail.com with ESMTPSA id e9sm1925110pge.39.2019.08.13.11.14.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Aug 2019 11:14:33 -0700 (PDT)
Date: Tue, 13 Aug 2019 14:14:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, cgroups@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: vmscan: do not share cgroup iteration between
 reclaimers
Message-ID: <20190813181431.GA23056@cmpxchg.org>
References: <20190812192316.13615-1-hannes@cmpxchg.org>
 <20190813132938.GJ17933@dhcp22.suse.cz>
 <CAHbLzkrRvoVLH16Cxq-f6hn-CLJjh=tJnYnF8P0xNiZ9=eEg8A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHbLzkrRvoVLH16Cxq-f6hn-CLJjh=tJnYnF8P0xNiZ9=eEg8A@mail.gmail.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 08:59:38AM -0700, Yang Shi wrote:
> On Tue, Aug 13, 2019 at 6:29 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 12-08-19 15:23:16, Johannes Weiner wrote:
> > > One of our services observed a high rate of cgroup OOM kills in the
> > > presence of large amounts of clean cache. Debugging showed that the
> > > culprit is the shared cgroup iteration in page reclaim.
> > >
> > > Under high allocation concurrency, multiple threads enter reclaim at
> > > the same time. Fearing overreclaim when we first switched from the
> > > single global LRU to cgrouped LRU lists, we introduced a shared
> > > iteration state for reclaim invocations - whether 1 or 20 reclaimers
> > > are active concurrently, we only walk the cgroup tree once: the 1st
> > > reclaimer reclaims the first cgroup, the second the second one etc.
> > > With more reclaimers than cgroups, we start another walk from the top.
> > >
> > > This sounded reasonable at the time, but the problem is that reclaim
> > > concurrency doesn't scale with allocation concurrency. As reclaim
> > > concurrency increases, the amount of memory individual reclaimers get
> > > to scan gets smaller and smaller. Individual reclaimers may only see
> > > one cgroup per cycle, and that may not have much reclaimable
> > > memory. We see individual reclaimers declare OOM when there is plenty
> > > of reclaimable memory available in cgroups they didn't visit.
> > >
> > > This patch does away with the shared iterator, and every reclaimer is
> > > allowed to scan the full cgroup tree and see all of reclaimable
> > > memory, just like it would on a non-cgrouped system. This way, when
> > > OOM is declared, we know that the reclaimer actually had a chance.
> > >
> > > To still maintain fairness in reclaim pressure, disallow cgroup
> > > reclaim from bailing out of the tree walk early. Kswapd and regular
> > > direct reclaim already don't bail, so it's not clear why limit reclaim
> > > would have to, especially since it only walks subtrees to begin with.
> >
> > The code does bail out on any direct reclaim - be it limit or page
> > allocator triggered. Check the !current_is_kswapd part of the condition.
> 
> Yes, please see commit 2bb0f34fe3c1 ("mm: vmscan: do not iterate all
> mem cgroups for global direct reclaim")

This patch is a workaround for the cgroup tree blowing up with zombie
cgroups. Roman's slab reparenting patches are fixing the zombies, so
we shouldn't need this anymore.

Because with or without the direct reclaim rule, we still don't want
offline cgroups to accumulate like this. They also slow down kswapd,
and they eat a ton of RAM.

> > > This change completely eliminates the OOM kills on our service, while
> > > showing no signs of overreclaim - no increased scan rates, %sys time,
> > > or abrupt free memory spikes. I tested across 100 machines that have
> > > 64G of RAM and host about 300 cgroups each.
> >
> > What is the usual direct reclaim involvement on those machines?
> >
> > > [ It's possible overreclaim never was a *practical* issue to begin
> > >   with - it was simply a concern we had on the mailing lists at the
> > >   time, with no real data to back it up. But we have also added more
> > >   bail-out conditions deeper inside reclaim (e.g. the proportional
> > >   exit in shrink_node_memcg) since. Regardless, now we have data that
> > >   suggests full walks are more reliable and scale just fine. ]
> >
> > I do not see how shrink_node_memcg bail out helps here. We do scan up-to
> > SWAP_CLUSTER_MAX pages for each LRU at least once. So we are getting to
> > nr_memcgs_with_pages multiplier with the patch applied in the worst case.
> >
> > How much that matters is another question and it depends on the
> > number of cgroups and the rate the direct reclaim happens. I do not
> > remember exact numbers but even walking a very large memcg tree was
> > noticeable.
> 
> I'm concerned by this too. It might be ok to cgroup v2, but v1 still
> dominates. And, considering offline memcgs it might be not unusual to
> have quite large memcg tree.

cgroup2 was affected by the offline memcgs just as much as cgroup1 -
probably even more so because it tracks more types of memory per
default. That's why Roman worked tirelessly on a solution.

But we shouldn't keep those bandaid patches around forever.

