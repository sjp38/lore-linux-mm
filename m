Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B37FBC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:46:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D7F020840
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:46:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="j6j9cc3o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D7F020840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 140976B0005; Tue, 13 Aug 2019 13:46:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EEB56B0006; Tue, 13 Aug 2019 13:46:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1FD26B0007; Tue, 13 Aug 2019 13:46:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0123.hostedemail.com [216.40.44.123])
	by kanga.kvack.org (Postfix) with ESMTP id D30376B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:46:30 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 877898248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:46:30 +0000 (UTC)
X-FDA: 75818134140.28.ball05_38b974bb63f16
X-HE-Tag: ball05_38b974bb63f16
X-Filterd-Recvd-Size: 6375
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:46:29 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id k3so606062pgb.10
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:46:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mXGH6sfF5Mv8489pO8HNMnvL4N6Kj76jRZqkd1Btows=;
        b=j6j9cc3oeGRVjeb4q1mX5UvZe7oyDjzfb402Fg+7HhPoR8ZZ6I+HCu+AQE3gq0eDDd
         5SBPUQaw2UJReVDDVyXNzMhXDX6rSNUrGZEzebEzR3mC+q1snggT0oxh7Uly5MzYNf5r
         yJLjMHsZJW7MI2LqKKAA1/VIg6caDPkH/ibZtIg4WtRiccYwshL2Lm7PbBhc9gdSlBBi
         BZoO7hz6wHRCK6BnX9Ew8PkGymJjUq48Of9zE+Aq9pDUvh2e/I/OMBDu85QL/WNz3rPv
         lyKbsxEcKoQzkyqDhiw2oQOo/gaNSd8BdY6gFL1sHjdu/3qsLd9O7/r4sNtlcfFs2fOa
         62CQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=mXGH6sfF5Mv8489pO8HNMnvL4N6Kj76jRZqkd1Btows=;
        b=koX5Op29Hiw3VuEsQOKzSW6rOLK7SOZeOngFIhT3U6NzCattV6FatUNi6/SqsrFqBQ
         UgVmk1n7YtXgdpaGK8p5S57SryZRWXVq0pUfzEsEWrGKFIeFT4/9BlG5u0+eU/UCuP6m
         UPxlN1glW8pONakB1CZZcC0uwFT53yF3QWgP6sPRQvZXa8My73On5h159iFazuvGAvcA
         tt7x75VmoEaDlzBFDfSRCuzGyoCqAscsAuXngwtSgjC0AKUoODtaB0aNO94GMn6tRJEG
         3InBvJHqwBfs45H9kf0HRL8yM8urFsDh0GgRRayhWzdBQzOiccV6lAdo0blkTLMiyZ9s
         d6rA==
X-Gm-Message-State: APjAAAUbyHjlNkUTssl4dAIkNFzaMEH8r0Lgukuoez9Q3Ek8c/BAqWj8
	6Qw36er1pMskU1z+L7eA0o9YGw==
X-Google-Smtp-Source: APXvYqyIrpmWgiXBiK3PDYma3AbBRu7FLdOh0ZmeN1sG7QioNu25fJleeVa7zulYpZwXNMNhBdfcVQ==
X-Received: by 2002:a17:90b:d8f:: with SMTP id bg15mr3266929pjb.65.1565718388234;
        Tue, 13 Aug 2019 10:46:28 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:674])
        by smtp.gmail.com with ESMTPSA id g11sm9780395pfh.121.2019.08.13.10.46.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Aug 2019 10:46:27 -0700 (PDT)
Date: Tue, 13 Aug 2019 13:46:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, linux-btrfs@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH RESEND] block: annotate refault stalls from IO submission
Message-ID: <20190813174625.GA21982@cmpxchg.org>
References: <20190808190300.GA9067@cmpxchg.org>
 <20190809221248.GK7689@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809221248.GK7689@dread.disaster.area>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 10, 2019 at 08:12:48AM +1000, Dave Chinner wrote:
> On Thu, Aug 08, 2019 at 03:03:00PM -0400, Johannes Weiner wrote:
> > psi tracks the time tasks wait for refaulting pages to become
> > uptodate, but it does not track the time spent submitting the IO. The
> > submission part can be significant if backing storage is contended or
> > when cgroup throttling (io.latency) is in effect - a lot of time is
> 
> Or the wbt is throttling.
> 
> > spent in submit_bio(). In that case, we underreport memory pressure.
> > 
> > Annotate submit_bio() to account submission time as memory stall when
> > the bio is reading userspace workingset pages.
> 
> PAtch looks fine to me, but it raises another question w.r.t. IO
> stalls and reclaim pressure feedback to the vm: how do we make use
> of the pressure stall infrastructure to track inode cache pressure
> and stalls?
> 
> With the congestion_wait() and wait_iff_congested() being entire
> non-functional for block devices since 5.0, there is no IO load
> based feedback going into memory reclaim from shrinkers that might
> require IO to free objects before they can be reclaimed. This is
> directly analogous to page reclaim writing back dirty pages from
> the LRU, and as I understand it one of things the PSI is supposed
> to be tracking.
>
> Lots of workloads create inode cache pressure and often it can
> dominate the time spent in memory reclaim, so it would seem to me
> that having PSI only track/calculate pressure and stalls from LRU
> pages misses a fair chunk of the memory pressure and reclaim stalls
> that can be occurring.

psi already tracks the entire reclaim operation. So if reclaim calls
into the shrinker and the shrinker scans inodes, initiates IO, or even
waits on IO, that time is accounted for as memory pressure stalling.

If you can think of asynchronous events that are initiated from
reclaim but cause indirect stalls in other contexts, contexts which
can clearly link the stall back to reclaim activity, we can annotate
them using psi_memstall_enter() / psi_memstall_leave().

In that vein, what would be great to have is be a distinction between
read stalls on dentries/inodes that have never been touched before
versus those that have been recently reclaimed - analogous to cold
page faults vs refaults.

It would help psi, sure, but more importantly it would help us better
balance pressure between filesystem metadata and the data pages. We
would be able to tell the difference between a `find /' and actual
thrashing, where hot inodes are getting kicked out and reloaded
repeatedly - and we could backfeed that pressure to the LRU pages to
allow the metadata caches to grow as needed.

For example, it could make sense to swap out a couple of completely
unused anonymous pages if it means we could hold the metadata
workingset fully in memory. But right now we cannot do that, because
we cannot risk swapping just because somebody runs find /.

I have semi-seriously talked to Josef about this before, but it wasn't
quite obvious where we could track non-residency or eviction
information for inodes, dentries etc. Maybe you have an idea?

