Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FEB2C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:44:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D308E206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:44:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D308E206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C8998E0008; Wed, 31 Jul 2019 11:44:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 577D18E0003; Wed, 31 Jul 2019 11:44:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4663C8E0008; Wed, 31 Jul 2019 11:44:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EAFA08E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:44:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z20so42700049edr.15
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:44:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZbvamhdZzBVA/zXVKsWsOuvH06J35H570ELcFj4YuqU=;
        b=HmyKYhh5gRj679hBgNJUqj9Nf9dnF0FCxVdMbzigGpvw28IKyjLM824QQdRaO5pckF
         Bt0XvZmwMupB/DG8CY8lYf4Ijlq3d5PBhAN5fbFQ8HPGw4Eul3U2fEzSNzI6xcZJKeyl
         Q6mFhOZKcoC+Ta5pXYEGqtDy11TNjODdFIRFYaaM3sDbhozUyGkf/DL+aK8j7q2H+baf
         4yNaQ72rlfPP+ERg1U1Vqc8l4SCqyhDhRlOBOPlEth445Z5P6rPfD4LdjudAxOkwONmq
         BH7fotuFm8Qp6vmXN52Sx5Iized9IVM1YVsMeY9gKtdoV/ySEZcZT2qJD4exsmmwBrPO
         qpAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXzA9zniDB2j4smmy5V1YgMuIlpRu4Frx7dnlozi3dhT7m9Exa4
	PjeO8FRuONmtcw/GGTuNqEcLymAbGuX1EE2juWH8DbiLpGl7XWfNqagAH4/DTjoRVEZlMyKxg6E
	2KLyqPfK6e/lm2QidL7R6S9/9oJEYwXBLAITPflZS698lvn9dsGLAuhF5HCZLC4QebA==
X-Received: by 2002:a17:906:4911:: with SMTP id b17mr92849015ejq.158.1564587895444;
        Wed, 31 Jul 2019 08:44:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFEHSuqqvujwgROu3SDfOeEe/T2LUF7C0ZU3A0apgxELoMFM1b3WF2BMz39Nd2pIethtar
X-Received: by 2002:a17:906:4911:: with SMTP id b17mr92848949ejq.158.1564587894539;
        Wed, 31 Jul 2019 08:44:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564587894; cv=none;
        d=google.com; s=arc-20160816;
        b=WeUs/xOKlhfoiYmDhB23tfwKN0RTNEl7mleKGlPvWesvQKthcZzA5QSspnLIki4w6b
         C1gqjC9UlUe2DavAnC/NtR2Xe4kToA1tE4NB5x31VwIqfOPknP5RwrnmYufwpcIWnEbz
         TZTCDAwyroPHmL1zsciUZjLPkqAVMiFrUfV764Fczy+ya1VK+HByGfodcRDXdMxwJ+lT
         TM1rYTQU5gN05O2zT7ZyVyHWvI2lzq2HSZAQ/0uJsqukoNdr4/24498RcgNIxZycDA2J
         kBIYu453ku1nKB+lYF1Te1C6tHnA3oLyZaEh4dEo6XerEhsJFkQVuFwFffa0kqDRari7
         2T5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZbvamhdZzBVA/zXVKsWsOuvH06J35H570ELcFj4YuqU=;
        b=wyhrDAmOd1yaelNTwp03k8nyR4BKQkNRWm39A0NrpEVpfNqVLChGryh7bbUUYPiPqw
         4eimZjw4sg0p8aUsLKK4mBNAkgcyaDd8KaEgFvQNhqPT8kRm5Zyp8ZooxS9zqtsetU/G
         NS+kOKYRIZaJZLodIPWUf2QFOp0iJDz85jlFL1M1vC2i7ptcD4MbW4UKxZFGWhtCpQs8
         XPQuH2EY9/kuovvfiZroj7ohcylOMl5XkHVWD54CYeVJIjrL9c+/vcWA/CDzpa6t0GLk
         SDAtb+aQ41gXk8nnGFMzu4mh4A92WDxGG8DAErsZzqansXpgA4cacwMDDSOxzMPrycVJ
         gKhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id n55si19919491edd.231.2019.07.31.08.44.54
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:44:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AD136344;
	Wed, 31 Jul 2019 08:44:53 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A9F223F694;
	Wed, 31 Jul 2019 08:44:52 -0700 (PDT)
Date: Wed, 31 Jul 2019 16:44:50 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
Message-ID: <20190731154450.GB17773@arrakis.emea.arm.com>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
 <20190730130215.919b31c19df935cc5f1483e6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730130215.919b31c19df935cc5f1483e6@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 01:02:15PM -0700, Andrew Morton wrote:
> On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:
> 
> > Add mempool allocations for struct kmemleak_object and
> > kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> > under memory pressure. Additionally, mask out all the gfp flags passed
> > to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> > 
> > A boot-time tuning parameter (kmemleak.mempool) is added to allow a
> > different minimum pool size (defaulting to NR_CPUS * 4).
> 
> btw, the checkpatch warnings are valid:
> 
> WARNING: usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc
> #70: FILE: mm/kmemleak.c:197:
> +static int min_object_pool = NR_CPUS * 4;
> 
> WARNING: usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc
> #71: FILE: mm/kmemleak.c:198:
> +static int min_scan_area_pool = NR_CPUS * 1;
> 
> There can be situations where NR_CPUS is much larger than
> num_possible_cpus().  Can we initialize these tunables within
> kmemleak_init()?

We could and, at least on arm64, cpu_possible_mask is already
initialised at that point. However, that's a totally made up number. I
think we would better go for a Kconfig option (defaulting to, say, 1024)
similar to the CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE and we grow it if
people report better values in the future.

-- 
Catalin

