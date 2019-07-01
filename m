Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C47CBC5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:38:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BECE2054F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:38:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nKCbXIFP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BECE2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1540B8E0005; Mon,  1 Jul 2019 03:38:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DBAB8E0002; Mon,  1 Jul 2019 03:38:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E96D58E0005; Mon,  1 Jul 2019 03:38:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f207.google.com (mail-pg1-f207.google.com [209.85.215.207])
	by kanga.kvack.org (Postfix) with ESMTP id B02188E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 03:38:57 -0400 (EDT)
Received: by mail-pg1-f207.google.com with SMTP id f18so559239pgb.10
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 00:38:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=oLH1OncNHxs8jMVlyqKzbM2LmgvaD0Lm4DDU5l+6xuE=;
        b=CGA+Om9Ga3wJCLkGUmzvIzvuMqAYsy3TmTSh723RqmschRedVqI1FJpgWQoRA3vQXm
         3uk8H4KFhjLvr9yokFmUqbqD/8/FcFqkvjZ6G5srEdKcGmT1Au+6j5z69QOMkH8xllG1
         Qe0MtcK8xdjwcMPuIwXwdkGglVLnJQzM/9ZJD4b9S/IVgiHSjbYby5AH+bLD6xa3RLYO
         TLEAyAe9Sk2k2K0aG7gLNwnJDxiYEZ0dMk/cdELspkKDkp5je17SkINXKbGI24SndLFO
         YDTFSTtKS7SZhF+tAeHbEUFVE8P7Ge4RORd7xVClQxweRuhNPhd1f9bYFmtX3/ofaKNm
         xxuA==
X-Gm-Message-State: APjAAAWBz8pgB+fr5Oz7v0ijbiMezH1tV6ijHDZnxzLyU7NPC9tWUJOz
	wveSdMbUkPasSQE7PtbDJSm/tJju/HyQW9SQDGEjO7qr2xp9yYO/pDsZhI/sD9xcAy0zbDz7H+c
	SmcMtejP+lbSrbYFzd0V36SQi1hWIfp0bYZfsZewkjV1AN+BO5w81YSKPF96e7c8=
X-Received: by 2002:a17:902:44f:: with SMTP id 73mr27744362ple.192.1561966737201;
        Mon, 01 Jul 2019 00:38:57 -0700 (PDT)
X-Received: by 2002:a17:902:44f:: with SMTP id 73mr27744301ple.192.1561966736319;
        Mon, 01 Jul 2019 00:38:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561966736; cv=none;
        d=google.com; s=arc-20160816;
        b=l2p8EgeoO3h+GDORbwe425OqGxU/GW3OOZLMCik4/zvbiHOaWo1C2pk9yVvvYwAqo0
         1tVBfLgmldceinlOoIOF6efy1+Yf8oQzKKpT8FDz1CiHdx4jFCbQgmLDmlQTnrIdVZ1z
         uLzrmbZ16otP9vSz8rTgBRENqX1xcbtxtC6XRr2bG4t6NrBDj4uapH6MsI9PT1LaD6uG
         g7UkSlP1LqLYLHXK3Kx5mbR2WZEj6mQRwIWkzKZHGD996fF+jfAyFKf4ZEVlE0mE+Prf
         LYjf1YfuwuI1ODFehqEQaiOolEe/7+F4pVivMGFrONoBJ4I9g8k13oawpLB1GtbX6+6z
         cDvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=oLH1OncNHxs8jMVlyqKzbM2LmgvaD0Lm4DDU5l+6xuE=;
        b=pvkAgXCWLQxJDkCorSnBoysYMicrMydYCRgtjSJ8wGtlMrC7BVmwZt4zActhHIgWxV
         6xUbP2aNXv9eHcSs4upA836O/xMjqs+ZdUGzEfuQ21ld/8iRw0dG/qHcAFdLJXz4L8mT
         hJEaRtKkujaz7PUSQWRUqS/tiAejgE3cqxX5HFFGGPyNHQOIZr39qes8Qc/H/sPKg2Jf
         GffXXa9kVLwtFtZyV+QWayLqJDV6QvASma+siBSz3hsij0VJPmub+WO09Uz7I9qiJ2QC
         DttSbNDc+GIjY5xQxgShlXwluTpd57QVAcfSDzfT973L2bKBhj42hSFqDzYqBOphgVkH
         8x7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nKCbXIFP;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e16sor4836725pfn.24.2019.07.01.00.38.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 00:38:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nKCbXIFP;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=oLH1OncNHxs8jMVlyqKzbM2LmgvaD0Lm4DDU5l+6xuE=;
        b=nKCbXIFP0qhCB9TYyiIPTDswXVswW8CR9y8Csly4Id5HAH94lfYeljtiMc58SdKPxU
         pwXoZijwnVSxsgPzAl/R9CvVncgvHBxXeEPQjkY4CQ8CorFmkIN4zMiIIIPXaZnYuAlC
         EgFuUgMnbYFoKaRigKTPbD01B9cpVCfV9RQlcIfFEvpIDBFKQSXxa5K34RKkqnG3WDtl
         RlKK4bi/fAYaN5APqWQ5PddFXT4IxjihNUz0gk9JwBzVjc3J7bNX4EFXYc/QEtpKlwzC
         9OYZmZCQ5TKdl/FwhtRPjD9UCuuSdguZGdKBLGBEBouIwzY4SpU5ZzNaJZQxfJmHZWsK
         6oOQ==
X-Google-Smtp-Source: APXvYqyCp/N10OoZuyoBqCG1Owt7owZdT4mU1H00JSac3imof61OnjmhaWbc9E9JZ9rjSsi/ctXplw==
X-Received: by 2002:a63:2cd1:: with SMTP id s200mr23505101pgs.439.1561966735773;
        Mon, 01 Jul 2019 00:38:55 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id z4sm9658756pfa.142.2019.07.01.00.38.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 01 Jul 2019 00:38:54 -0700 (PDT)
Date: Mon, 1 Jul 2019 16:38:48 +0900
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Message-ID: <20190701073848.GB136163@google.com>
References: <20190627115405.255259-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190627115405.255259-1-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Folks,

Do you guys have comments? I think it would be long enough to be
pending. If there is no further comments, I want to ask to merge.

Thanks.

On Thu, Jun 27, 2019 at 08:54:00PM +0900, Minchan Kim wrote:
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
> 
> Minchan Kim (5):
>   mm: introduce MADV_COLD
>   mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
>   mm: account nr_isolated_xxx in [isolate|putback]_lru_page
>   mm: introduce MADV_PAGEOUT
>   mm: factor out pmd young/dirty bit handling and THP split
> 
>  include/linux/huge_mm.h                |   3 -
>  include/linux/swap.h                   |   2 +
>  include/uapi/asm-generic/mman-common.h |   2 +
>  mm/compaction.c                        |   2 -
>  mm/gup.c                               |   7 +-
>  mm/huge_memory.c                       |  74 -----
>  mm/internal.h                          |   2 +-
>  mm/khugepaged.c                        |   3 -
>  mm/madvise.c                           | 438 ++++++++++++++++++++++++-
>  mm/memory-failure.c                    |   3 -
>  mm/memory_hotplug.c                    |   4 -
>  mm/mempolicy.c                         |   6 +-
>  mm/migrate.c                           |  37 +--
>  mm/oom_kill.c                          |   2 +-
>  mm/swap.c                              |  42 +++
>  mm/vmscan.c                            |  86 ++++-
>  16 files changed, 566 insertions(+), 147 deletions(-)
> 
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 

