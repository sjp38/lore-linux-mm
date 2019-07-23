Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9021C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 20:50:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6405C218D4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 20:50:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="buC5Qa3v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6405C218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 008B28E0002; Tue, 23 Jul 2019 16:50:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFC9D6B000A; Tue, 23 Jul 2019 16:50:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC2728E0002; Tue, 23 Jul 2019 16:50:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A03AB6B0008
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 16:50:32 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so22696557plp.12
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:50:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=8+jweQXNw+FvBUs6L1ninWLU4jT9qpYpiOUnyQkbE24=;
        b=f5TsQ2NDvPLYyAvfv8sV+/e7Ji5WQjnapX+v55UWnixuSihaUsyVYXkNg3CV5Netiw
         q0/l5qM4oR+Z9b2x3dsvUGPPAC9FVtSbJ6gTiF1wGawqQt0ZCRCRhy62huaPlH0kOJ+l
         Y4HQ8Kky9x5wXg3Caf9iInJUf4mJ10pRvgeAss5tNq7TF0PFREBhDgly254LSuELNiJE
         cYUQ4iCTfmFLmN5lSI0bqATP+Th7HVX4+fPZS+QDlkjJa+HojgQuBr+GHEsrbJ1WABOy
         Nn16m3RisNo4bitzCUQdKWrahlEpDvViiV18r3hXjaj0tKIAuq8bkdXwmCWtp5AQVWiS
         kEIQ==
X-Gm-Message-State: APjAAAVMBKimiv1bnE2d2bnJTO9dvE7jLlRa3FKlom3jUmsJlL9lU1XZ
	TPwgFbn38DUx+WSWZPQYukHTWy3sEigbNBc+9XolD5PhA/qgqkuz/sxwK3n8dBZrMMvlOVso2ZN
	y+oe6yZPs/taOymvELxsMRIV0wvAmrIohoPEA382iImOAqybtrl3Fevbu2G2QtPFg8Q==
X-Received: by 2002:a17:902:110b:: with SMTP id d11mr85913378pla.213.1563915032205;
        Tue, 23 Jul 2019 13:50:32 -0700 (PDT)
X-Received: by 2002:a17:902:110b:: with SMTP id d11mr85913336pla.213.1563915031419;
        Tue, 23 Jul 2019 13:50:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563915031; cv=none;
        d=google.com; s=arc-20160816;
        b=WeVbiBxUuhm9LnTK+W6tyL8DavI+rlLx8/l/o/FkVwpkGN5a0OcG9U9Z5G0KW7xUKO
         R4H/SefhyrZoi/I+kGSbssarCSrJm6lOntsGwN3ziiiI/Idmud98KD2/9B7DdAF2W6IW
         oUhoh7tLVG9REcnSMhFU81zYlKZRjjWxPEK+b/m0rAMAVr8Te1eErb2EWgdiX9mXpQKP
         2pJpPoL2htL2kfqcpiWITAI8/mJCog61WuxWgayGQ9bimH/iiw50zFG6eZBfBZqHSJEB
         lxLr0B/8GUFYPWB5psQ7mDSkkzj1xpzeHvl5MZRVBDw0K3P0DuC+tzLN2vbsHil7Exd/
         mt3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=8+jweQXNw+FvBUs6L1ninWLU4jT9qpYpiOUnyQkbE24=;
        b=qiD+izS5cpmoxggmPJgkR/CnhbZm30HZqZI4BF2jy0LHQHOlt/Yi/OSbH7LYsuHDqi
         KKht+8auSrjzYwagJ6TSe2J0/FRtEkK+LCj7SSWa2xn7BM6v6aSWNSw0QdAEtEI1one4
         xbXe7quyGLuJvkDmfkjQQZMAYi7265QwgfwOkmBfpsob3zVWkXe2/+Ge+17bBYlxVztU
         EW1Ge3N5IkNnQ16L1N+O+qlhfb1wx3yhw9bCBTDROevItsBpwoYHmmbGGq+HucSzYgZe
         vbzZBQ+cRCT4fhYzQGroQ7BcjhMNytrrAnRgCXf7i/dLZhZOV4oGoD2ic30QOvDtrhBh
         ejZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=buC5Qa3v;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ck2sor51929686plb.1.2019.07.23.13.50.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 13:50:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=buC5Qa3v;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=8+jweQXNw+FvBUs6L1ninWLU4jT9qpYpiOUnyQkbE24=;
        b=buC5Qa3vmUJPzu5hmh7UlXW+7BjE84M7XsvjmO2wR+fJ6KPC106sjJAWESvmbKYSHn
         8jPS6hBDBxJS1rAFsJJP4+8hFxfuElN5ND41jEU58Bx6P8WqXcb87AnXQKJ3LE/kkI30
         KdFt2BJo5aImDmFGv1cdsv+Z+Y+7v8Qf3cVAZtXYzEIwN+NorT1dv+gyYM0J9NtDOele
         12DB0fCUgk1CGlJm5t53su11w62w26pLFZFclqpZZIlzZtBVcle/u7n3mbu2XDeQgn6k
         1CEjpg/O6QhjI+E14pGFki+IqznIFPUuDwXq1xzMIyxMm2LynxxE415jBRzXS3psomfc
         vIzg==
X-Google-Smtp-Source: APXvYqxrlSLQPni9wZ41ZMpEj+bbeH0eZMnx6RzFfkeVySStNOE1b78LdLI4ugryp9XNqsuk5Pf5tg==
X-Received: by 2002:a17:902:fe14:: with SMTP id g20mr77954861plj.54.1563915028532;
        Tue, 23 Jul 2019 13:50:28 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:a7f8])
        by smtp.gmail.com with ESMTPSA id y23sm45948610pfo.106.2019.07.23.13.50.27
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 13:50:27 -0700 (PDT)
Date: Tue, 23 Jul 2019 16:50:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mm: Throttle allocators when failing reclaim over
 memory.high
Message-ID: <20190723205026.GB30522@cmpxchg.org>
References: <20190501184104.GA30293@chrisdown.name>
 <20190723180700.GA29459@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190723180700.GA29459@chrisdown.name>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 02:07:00PM -0400, Chris Down wrote:
> We're trying to use memory.high to limit workloads, but have found that
> containment can frequently fail completely and cause OOM situations
> outside of the cgroup. This happens especially with swap space -- either
> when none is configured, or swap is full. These failures often also
> don't have enough warning to allow one to react, whether for a human or
> for a daemon monitoring PSI.
> 
> Here is output from a simple program showing how long it takes in μsec
> (column 2) to allocate a megabyte of anonymous memory (column 1) when a
> cgroup is already beyond its memory high setting, and no swap is
> available:
> 
>     [root@ktst ~]# systemd-run -p MemoryHigh=100M -p MemorySwapMax=1 \
>     > --wait -t timeout 300 /root/mdf
>     [...]
>     95  1035
>     96  1038
>     97  1000
>     98  1036
>     99  1048
>     100 1590
>     101 1968
>     102 1776
>     103 1863
>     104 1757
>     105 1921
>     106 1893
>     107 1760
>     108 1748
>     109 1843
>     110 1716
>     111 1924
>     112 1776
>     113 1831
>     114 1766
>     115 1836
>     116 1588
>     117 1912
>     118 1802
>     119 1857
>     120 1731
>     [...]
>     [System OOM in 2-3 seconds]
> 
> The delay does go up extremely marginally past the 100MB memory.high
> threshold, as now we spend time scanning before returning to usermode,
> but it's nowhere near enough to contain growth. It also doesn't get
> worse the more pages you have, since it only considers nr_pages.
> 
> The current situation goes against both the expectations of users of
> memory.high, and our intentions as cgroup v2 developers. In
> cgroup-v2.txt, we claim that we will throttle and only under "extreme
> conditions" will memory.high protection be breached. Likewise, cgroup v2
> users generally also expect that memory.high should throttle workloads
> as they exceed their high threshold. However, as seen above, this isn't
> always how it works in practice -- even on banal setups like those with
> no swap, or where swap has become exhausted, we can end up with
> memory.high being breached and us having no weapons left in our arsenal
> to combat runaway growth with, since reclaim is futile.
> 
> It's also hard for system monitoring software or users to tell how bad
> the situation is, as "high" events for the memcg may in some cases be
> benign, and in others be catastrophic. The current status quo is that we
> fail containment in a way that doesn't provide any advance warning that
> things are about to go horribly wrong (for example, we are about to
> invoke the kernel OOM killer).
> 
> This patch introduces explicit throttling when reclaim is failing to
> keep memcg size contained at the memory.high setting. It does so by
> applying an exponential delay curve derived from the memcg's overage
> compared to memory.high.  In the normal case where the memcg is either
> below or only marginally over its memory.high setting, no throttling
> will be performed.
> 
> This composes well with system health monitoring and remediation, as
> these allocator delays are factored into PSI's memory pressure
> calculations. This both creates a mechanism system administrators or
> applications consuming the PSI interface to trivially see that the memcg
> in question is struggling and use that to make more reasonable
> decisions, and permits them enough time to act. Either of these can act
> with significantly more nuance than that we can provide using the system
> OOM killer.
> 
> This is a similar idea to memory.oom_control in cgroup v1 which would
> put the cgroup to sleep if the threshold was violated, but it's also
> significantly improved as it results in visible memory pressure, and
> also doesn't schedule indefinitely, which previously made tracing and
> other introspection difficult (ie. it's clamped at 2*HZ per allocation
> through MEMCG_MAX_HIGH_DELAY_JIFFIES).
> 
> Contrast the previous results with a kernel with this patch:
> 
>     [root@ktst ~]# systemd-run -p MemoryHigh=100M -p MemorySwapMax=1 \
>     > --wait -t timeout 300 /root/mdf
>     [...]
>     95  1002
>     96  1000
>     97  1002
>     98  1003
>     99  1000
>     100 1043
>     101 84724
>     102 330628
>     103 610511
>     104 1016265
>     105 1503969
>     106 2391692
>     107 2872061
>     108 3248003
>     109 4791904
>     110 5759832
>     111 6912509
>     112 8127818
>     113 9472203
>     114 12287622
>     115 12480079
>     116 14144008
>     117 15808029
>     118 16384500
>     119 16383242
>     120 16384979
>     [...]
> 
> As you can see, in the normal case, memory allocation takes around 1000
> μsec. However, as we exceed our memory.high, things start to increase
> exponentially, but fairly leniently at first. Our first megabyte over
> memory.high takes us 0.16 seconds, then the next is 0.46 seconds, then
> the next is almost an entire second. This gets worse until we reach our
> eventual 2*HZ clamp per batch, resulting in 16 seconds per megabyte.
> However, this is still making forward progress, so permits tracing or
> further analysis with programs like GDB.
> 
> We use an exponential curve for our delay penalty for a few reasons:
> 
> 1. We run mem_cgroup_handle_over_high to potentially do reclaim after
>    we've already performed allocations, which means that temporarily
>    going over memory.high by a small amount may be perfectly legitimate,
>    even for compliant workloads. We don't want to unduly penalise such
>    cases.
> 2. An exponential curve (as opposed to a static or linear delay) allows
>    ramping up memory pressure stats more gradually, which can be useful
>    to work out that you have set memory.high too low, without destroying
>    application performance entirely.
> 
> This patch expands on earlier work by Johannes Weiner. Thanks!
> 
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com
> ---

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

