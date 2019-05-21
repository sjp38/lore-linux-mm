Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66C32C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:42:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 188482173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:42:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="Ofc5UreW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 188482173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A60016B0003; Tue, 21 May 2019 04:42:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A11B56B0005; Tue, 21 May 2019 04:42:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E1976B0006; Tue, 21 May 2019 04:42:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54F8A6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 04:42:12 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f9so7037994pfn.6
        for <linux-mm@kvack.org>; Tue, 21 May 2019 01:42:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=fL2NycB/KBQwPHhyJm1TK8C2/P0KHX/e0jDcXqFMlXc=;
        b=TrFjtGzmOCU4yeX5mDw/lvFiIlo2J+c0nd26mypRNbpExEQYgdYryMI9XsCh4UvBkg
         XTnu5axnGZkEyY7VBNuBsInzi8Pguy+QhFRHiQmKiD5C9s3msIv3qCdhNRl4+25ajhpw
         N5logD+QFcLz32yxc6T8n5ny5W1XAUClTktXg9l9WdaqlVKscpS/8/BtDjL0Eg+JyZH5
         DtbmeEk9fQA4+efK1KO5jiqKiNAHJph7gybizZKLMpNXgKiYYWS1s7vkHbR7IxQDFiDp
         2D05+TDFI9K+t79ELTjeY/rnyXVlNH/3tHXSq+TpDUauyLq+eQtGoR9fwO+VD5koxrJ8
         A7Rw==
X-Gm-Message-State: APjAAAX4X8iO77ShT1DMJhZL8dT1e83kzaSV7rLXhaYeCXweYq+l+Rhy
	Mr5fCeZBCCzw5QxgiVj06veb7sE8FVrYF4Ld0S/Jzzj8H4MmrpsiY0/ST42T2XU9ATNeVh+c38k
	EqzppdJhIV3rkNjzVyYE5Txd/kNb6lcivYsAYIFoXV75oNZiP81W2vOz4GM0RZjrEbw==
X-Received: by 2002:a17:902:8a83:: with SMTP id p3mr81677140plo.88.1558428131907;
        Tue, 21 May 2019 01:42:11 -0700 (PDT)
X-Received: by 2002:a17:902:8a83:: with SMTP id p3mr81677079plo.88.1558428131010;
        Tue, 21 May 2019 01:42:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558428131; cv=none;
        d=google.com; s=arc-20160816;
        b=WmRHONKQ/KIRLgzcPs9TCU0yLsxOMBBGi/MQzv5bcHudIdkFRAxmBHM674T3hXjtQH
         j09Mn5OuWY9M9efwTuGXvPQZoHAeN80c4d4VmcWAN3dRuQSImy//YTOPAycpfYw2tKkS
         0ZdZfU7mVlJ8BWZZCpNN47+9sp3VZNuDM6TOr5ccKyYsQaAxZZKT47NslzhcJmm1U6dc
         8LK49eO2pLbvnHy2oKOI5fZtaPrXi7AmP4TDUinsjOwnK29r5oavtxPavkio/4BbRPKP
         OUq6uWzHY8tz2e5dQriPgdgqIVyhzvOqc2nZ7kXRtdCdo9mYXH7kVpf03PZGz/tK7Sc9
         Vsgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=fL2NycB/KBQwPHhyJm1TK8C2/P0KHX/e0jDcXqFMlXc=;
        b=CwfQ9mC8WDeZlVHbvMbiXGiOFZwneA8+xTo8GCe4QUu3lFwAXSLDlaeN5hucmctQOl
         GdHNSPzS/c24VFsJ4XMoUX8qMMYHOm49/tzmAdXo/XCgK3AOgLdNhbev2Dr1wKKIb2bI
         hzlyjdRj1kDujAuHfvVvhPrluPb80EjSEfXdsLBXNjz6J+bwAw+wJMAzmzwAXkGQMTI+
         +DbEFSJtf/ol9mdGc+Xu9eb7e7wv5tkP/1HD9ri14I2NBFeHAiabDQoR0dnpwRaQkf0/
         TZGVYOGoGwe+lNXImm7Ek8AGtZk3MqGmjdMJ+8H31e8QeYazt3606MIM6PdQsAHevOk5
         N5kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=Ofc5UreW;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.41 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i8sor13704717pgi.42.2019.05.21.01.42.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 01:42:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=Ofc5UreW;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.41 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=fL2NycB/KBQwPHhyJm1TK8C2/P0KHX/e0jDcXqFMlXc=;
        b=Ofc5UreWBIBCwYkWRg3poRUI0RkUh9zFBpFMazgql8Eq4K1AQwC3CW/BRmyWVuy0If
         YpEU0indo2hVEy2p9tQt41yJd8MeelgTKIKvs2GoTsdkYbv7gxouQNWTIfwp3tOgXUlu
         iuMaEKsrvBdtucpuEY3mT1E/ZeFBu0mxEjZqm52eTdMw7Whna4qSRai1H9XdiJNksog2
         53RR3LtYGEM8Xu48PvnIssFyeA9DdiyZWxbH+KTps4uyqrBEV1CD/et0r4BUmSxaYAqs
         yisSFZbWlIlvop0smOgfEZNwu/TkfqC2sReITQYQwNuzRu/w7pFK1n3q/KjMUCopC4/L
         KydA==
X-Google-Smtp-Source: APXvYqynUeUEzy72MP695EG5nsL6QCyxNd0eoISiaP6I/i+P560cW2wcRGnBreJqNUFhz98ZKE/JJA==
X-Received: by 2002:a63:ed16:: with SMTP id d22mr79872044pgi.35.1558428130440;
        Tue, 21 May 2019 01:42:10 -0700 (PDT)
Received: from brauner.io ([208.54.39.182])
        by smtp.gmail.com with ESMTPSA id u11sm21973817pfh.130.2019.05.21.01.42.04
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 01:42:09 -0700 (PDT)
Date: Tue, 21 May 2019 10:42:00 +0200
From: Christian Brauner <christian@brauner.io>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521084158.s5wwjgewexjzrsm6@brauner.io>
References: <20190520035254.57579-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> - Background
> 
> The Android terminology used for forking a new process and starting an app
> from scratch is a cold start, while resuming an existing app is a hot start.
> While we continually try to improve the performance of cold starts, hot
> starts will always be significantly less power hungry as well as faster so
> we are trying to make hot start more likely than cold start.
> 
> To increase hot start, Android userspace manages the order that apps should
> be killed in a process called ActivityManagerService. ActivityManagerService
> tracks every Android app or service that the user could be interacting with
> at any time and translates that into a ranked list for lmkd(low memory
> killer daemon). They are likely to be killed by lmkd if the system has to
> reclaim memory. In that sense they are similar to entries in any other cache.
> Those apps are kept alive for opportunistic performance improvements but
> those performance improvements will vary based on the memory requirements of
> individual workloads.
> 
> - Problem
> 
> Naturally, cached apps were dominant consumers of memory on the system.
> However, they were not significant consumers of swap even though they are
> good candidate for swap. Under investigation, swapping out only begins
> once the low zone watermark is hit and kswapd wakes up, but the overall
> allocation rate in the system might trip lmkd thresholds and cause a cached
> process to be killed(we measured performance swapping out vs. zapping the
> memory by killing a process. Unsurprisingly, zapping is 10x times faster
> even though we use zram which is much faster than real storage) so kill
> from lmkd will often satisfy the high zone watermark, resulting in very
> few pages actually being moved to swap.
> 
> - Approach
> 
> The approach we chose was to use a new interface to allow userspace to
> proactively reclaim entire processes by leveraging platform information.
> This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> that are known to be cold from userspace and to avoid races with lmkd
> by reclaiming apps as soon as they entered the cached state. Additionally,
> it could provide many chances for platform to use much information to
> optimize memory efficiency.
> 
> IMHO we should spell it out that this patchset complements MADV_WONTNEED
> and MADV_FREE by adding non-destructive ways to gain some free memory
> space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> kernel that memory region is not currently needed and should be reclaimed
> immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> kernel that memory region is not currently needed and should be reclaimed
> when memory pressure rises.
> 
> To achieve the goal, the patchset introduce two new options for madvise.
> One is MADV_COOL which will deactive activated pages and the other is
> MADV_COLD which will reclaim private pages instantly. These new options
> complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
> gain some free memory space. MADV_COLD is similar to MADV_DONTNEED in a way
> that it hints the kernel that memory region is not currently needed and
> should be reclaimed immediately; MADV_COOL is similar to MADV_FREE in a way
> that it hints the kernel that memory region is not currently needed and
> should be reclaimed when memory pressure rises.
> 
> This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> information required to make the reclaim decision is not known to the app.
> Instead, it is known to a centralized userspace daemon, and that daemon
> must be able to initiate reclaim on its own without any app involvement.
> To solve the concern, this patch introduces new syscall -
> 
> 	struct pr_madvise_param {
> 		int size;
> 		const struct iovec *vec;
> 	}
> 
> 	int process_madvise(int pidfd, ssize_t nr_elem, int *behavior,
> 				struct pr_madvise_param *restuls,
> 				struct pr_madvise_param *ranges,
> 				unsigned long flags);
> 
> The syscall get pidfd to give hints to external process and provides
> pair of result/ranges vector arguments so that it could give several
> hints to each address range all at once.
> 
> I guess others have different ideas about the naming of syscall and options
> so feel free to suggest better naming.

Yes, all new syscalls making use of pidfds should be named
pidfd_<action>. So please make this pidfd_madvise.

Please make sure to Cc me on this in the future as I'm maintaining
pidfds. Would be great to have Jann on this too since he's been touching
both mm and parts of the pidfd stuff with me.

