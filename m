Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57BF2C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 12:27:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A96021530
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 12:27:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A96021530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BF196B0003; Wed, 19 Jun 2019 08:27:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96F9A8E0002; Wed, 19 Jun 2019 08:27:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 837218E0001; Wed, 19 Jun 2019 08:27:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 354156B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:27:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so25925106eda.9
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:27:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=4yGfXmblYUae8vGaYilqj5C2CIFUVNlipiZZ6wz7gBo=;
        b=EOCsWON/fbGFXEXQWW/gmdXsfktHc7QjhNZiG1fQEVrSL/6Xcc9Oeemk2yeA0pP6jH
         y9S/Jjusog4IULx0t/PIJakh5zo+tCaBfdzqDI+7jjnfsveTEsdiLJHw+bu6xggmzLe1
         TOFaLaED/0A7cjKd8nm8Q8TH/nHktOuZ+obv7AIy4ZxGWf0Ue3tyh5Gi0Ao7JSB0pxFF
         Tl+buhfQ2V+k2ipE//Wnza4gpIFAoTwhijCYW8Ah5W7hxpkhco8vsiYffd/mXWLS7r1m
         QE1R7czGk4V8msA7TYUq7yNyEVrO2xc9rbTlBRWIbF+mF/L8lM74YDrzppWA1xTO6AMI
         kxbg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVE+nJ5PGMEiKD7MAv7sXv0ebJCcGIMbm3cPSGzLvczaj0KS9zO
	jjONRCbbydZulO7BbuRXyUkLofOvMT2M2AZqs2fc+f3Gh050W3Ck/yuT1BCEOLMCMFsuHpJJChk
	bERmrHiYDVEX1vQc/t88vyJGVWI9EoYhk/cDEuIQ7xy8CDheHgbUshgke981QTc0=
X-Received: by 2002:a17:906:b741:: with SMTP id fx1mr104534052ejb.45.1560947273729;
        Wed, 19 Jun 2019 05:27:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxehjEj3F696q6QhAUNKwAbeFEzvzs7Xbz+ePF2V9T5Uzgm1RDPNwjKuFvU/4HXpQg5/Y2M
X-Received: by 2002:a17:906:b741:: with SMTP id fx1mr104533984ejb.45.1560947272721;
        Wed, 19 Jun 2019 05:27:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560947272; cv=none;
        d=google.com; s=arc-20160816;
        b=wHCti02oi4liCPmGQ+iGcpOouteVvjXXi8cV6btWVop4SUL77XEKMx4EpiV4dElgDp
         3Q/GcnmbhB/EjpL1/i6NHxNt16zBPU8vcmN25ItSzV3aQoh7gYB3f2cBWfQ+63owW50I
         eNUwEKtETFQ3C+qct15USb2OCNfueFvsk6HDk3m5RoUDS3eMLhAL1bB2bVEA/5pScqU+
         nnXd/RxepFyTzAKJ2lsyd3V+KhZm8/B6o2zTw+LLMQKy0CWiZzwALicqOU0OXp31sdC3
         otKtTVDaQhmhHABJJmYyefoQPWySxWjzpLvTlPgqLPaGwz7W0DBpRm35q1eGCAU0UnE2
         VW4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=4yGfXmblYUae8vGaYilqj5C2CIFUVNlipiZZ6wz7gBo=;
        b=GluEkECBwFkfNk424k3X2N1JrEzkQptHWndAjFpda+7berojpwdvxTVZDUhNz9nsrl
         2rlvidKi2RCLyb+tZddJATl+Fqg2M8UDVLiOBj+6Rdofi+07skX6Q79wyJgijGNr9+ub
         XebhggJm+sNuRCC25VaXd/6O4iqwfi5+4qucCCk9iDk5T1a/5nwJyNIP/0cvNQrK+F0v
         zv6MjazPYE1qWFi1yrauYle8s0hvjyARpAi30CZFHoZfEhS7NUnfY2jrVir3iGRFif0b
         JN9mXqVRYn8K4h5QA0MKeU6rngKuZEFPNres9s1qnBZrQzY69BmOJvcXlp7tZxAmh4pU
         kdxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w24si13511783eda.92.2019.06.19.05.27.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 05:27:52 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DC7A6AD3B;
	Wed, 19 Jun 2019 12:27:51 +0000 (UTC)
Date: Wed, 19 Jun 2019 14:27:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Message-ID: <20190619122750.GN2968@dhcp22.suse.cz>
References: <20190610111252.239156-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190610111252.239156-1-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 10-06-19 20:12:47, Minchan Kim wrote:
> This patch is part of previous series:
> https://lore.kernel.org/lkml/20190531064313.193437-1-minchan@kernel.org/T/#u
> Originally, it was created for external madvise hinting feature.
> 
> https://lkml.org/lkml/2019/5/31/463
> Michal wanted to separte the discussion from external hinting interface
> so this patchset includes only first part of my entire patchset
> 
>   - introduce MADV_COLD and MADV_PAGEOUT hint to madvise.
> 
> However, I keep entire description for others for easier understanding
> why this kinds of hint was born.
> 
> Thanks.
> 
> This patchset is against on next-20190530.
> 
> Below is description of previous entire patchset.
> ================= &< =====================
> 
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
> To achieve the goal, the patchset introduce two new options for madvise.
> One is MADV_COLD which will deactivate activated pages and the other is
> MADV_PAGEOUT which will reclaim private pages instantly. These new options
> complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
> gain some free memory space. MADV_PAGEOUT is similar to MADV_DONTNEED in a way
> that it hints the kernel that memory region is not currently needed and
> should be reclaimed immediately; MADV_COLD is similar to MADV_FREE in a way
> that it hints the kernel that memory region is not currently needed and
> should be reclaimed when memory pressure rises.

This all is a very good background information suitable for the cover
letter.

> This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> information required to make the reclaim decision is not known to the app.
> Instead, it is known to a centralized userspace daemon, and that daemon
> must be able to initiate reclaim on its own without any app involvement.
> To solve the concern, this patch introduces new syscall -
> 
>     struct pr_madvise_param {
>             int size;               /* the size of this structure */
>             int cookie;             /* reserved to support atomicity */
>             int nr_elem;            /* count of below arrary fields */
>             int __user *hints;      /* hints for each range */
>             /* to store result of each operation */
>             const struct iovec __user *results;
>             /* input address ranges */
>             const struct iovec __user *ranges;
>     };
>     
>     int process_madvise(int pidfd, struct pr_madvise_param *u_param,
>                             unsigned long flags);

But this and the following paragraphs are referring to the later step
when the madvise gains a remote process capabilities and that is out
of the scope of this patch series so I would simply remove it from
here. Andrew tends to put the cover letter into the first patch of the
series and that would be indeed
confusing here.
-- 
Michal Hocko
SUSE Labs

