Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6DF7C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 13:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7709621019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 13:44:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="0h1y0UG2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7709621019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1181D8E00BB; Thu, 11 Jul 2019 09:44:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C8318E0032; Thu, 11 Jul 2019 09:44:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED2B28E00BB; Thu, 11 Jul 2019 09:44:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB9918E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 09:44:05 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id u25so6768396iol.23
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 06:44:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=TBOYZ0TJRtXkPl4BWDGsbuy8MB5If3yCD5dZFWq2zO0=;
        b=T3lZ5p4xdPZjCyhuOrzS+zBVWTaSiXsD4YTkDM5TABnDIURdiuWLMX3etHmXBvE9uk
         4VphMiAi4hLz+Io7/RP98kOs7iMYqVV3ZVgG+zzM+/l9VTsc/iuqXOmt2Enq9Qm6BL2H
         QQ0pssKBgwBwLzhHqKPofGy+fO7bMc+E5cAEXwQaOXt10p/OgSWmo7bpN/lFqe98C7pX
         tN/qeF3N4nJEaks3lwgEp1BQM4Nh+rvjYqd4Xs4DgsjWQBxAYfPQXzduzBqB4VaEzuPB
         bbHPWv4CAire6qDfqrizHJ9Lo/XS5Jp7bzfrVrFMAkKPtwJ6R1NvlHCCHbB52PKv37Ab
         Onog==
X-Gm-Message-State: APjAAAXmquuvC2qKWtmb+dw0AsuLxR8C+35tJbuacrtFgm3u3AdOpVFb
	eHKSceQXOFE7AUa65soju8p/gHR1QfrT81FMGNb+va24aoJGUyTlvTcJ0OxQw/bT3O+nBpsEo4m
	6xqO4NGqWloIwu2ShIIAQ/9rFwvHcF5wXGq+bivij328AP3eudvP49NlRqvwECqe2Tw==
X-Received: by 2002:a02:5185:: with SMTP id s127mr4659655jaa.44.1562852645498;
        Thu, 11 Jul 2019 06:44:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8PhHcH8yIusDRf2iQNlnqiPEz4YyMR8lD8px9WjpTncTROvdph7tx6jR1rBwRvtL8tSs1
X-Received: by 2002:a02:5185:: with SMTP id s127mr4659574jaa.44.1562852644586;
        Thu, 11 Jul 2019 06:44:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562852644; cv=none;
        d=google.com; s=arc-20160816;
        b=r0ULet0YBPCsBaPeI5ucrmzwzfSwpQF1F2Dt4pidiTXmPlnklmrG3XBM+qduR2wIh+
         bVLNQiuHSJ/WjbA1GlWbpjMuS7iz8ZAYmzoBpubLtyGI3pa74a5LUGkg6NoWAA9WvO1W
         ewDtHmRMicIjzaKeBHUC6uJwiCysYeK7G+DpILHLZ6iZF9tcfbXCuMckhfsSHv/I3fdq
         OHdE8yJkBzHlWC55fllo4FLutb3TZR9AzSYesLRHibHb7rg/Vw7XuR7AB5HJvGRtiA6b
         Jity+GP83x8i05V4GPG33rVB3Z6pzbnElx38ierlso0xB3vXJFQr3U1LeQhX/qg3nMO1
         /tBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=TBOYZ0TJRtXkPl4BWDGsbuy8MB5If3yCD5dZFWq2zO0=;
        b=cWf5P588D8pSgNvtPMzX7AHdDvLLO+Q7NfnaJEIWb3fZv4xdFwGRVReYSEJ7VZP42+
         ZwSJj7y0ERti+P4ygUPGUxYG0xppl0EMQdLi88t14NyoCmYQ55ylyhBediNm//kwxPrE
         q6NH2/EsVhTeE3ljMtk9Y/4Yr86qmTLRA1Ad2Z3xsZqjlyICzQWbtRVHfD7inTPxJCKg
         SinlL8N+BtPlrKCvur6ySVwQfDuDKHzoRI6/SXj8XdOvqFPGy/2woa8+clEnAuJfdC9z
         PFGWN035d2XwJgIWHXQdoE2M3obeuqPYxhsD71Zrgy/6wuLs9Y64lqXIECsXcoeO18e/
         XX5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=0h1y0UG2;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u1si7622600iom.155.2019.07.11.06.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 06:44:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=0h1y0UG2;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=TBOYZ0TJRtXkPl4BWDGsbuy8MB5If3yCD5dZFWq2zO0=; b=0h1y0UG2apY07KX9lcujJGVlJP
	7BsFf1QI7kw9dZ9QFkRN3jZ6jGNVYCzTa9mcxtQ9ECqThLZHq8pvoqpJAwHtZwCw4GlnXAnvFxTde
	/s6Rv+1nVR1RHDbRwHgdRqXnLXLSJyjrWtkvM72Z5wjn8t10N+jIVsGNJqJfjpLOh+cMY0UPaFnpS
	Y0jg5QWZJcIPZ3DBM9zgnuKPMu9KtfYaQXk/pYEjsMfjdI/MPf2Zuev6ivKE1FS8IG27KMVgxpuh/
	69sHVDz+IxevRGT0k3TCldwKV3SdXxMD/60u4cPGqHLssnGQVDeCvbdNdd8Np/pb0LbrA7hcCPDk+
	znssWpkg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hlZMZ-0003nD-9M; Thu, 11 Jul 2019 13:43:55 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id A4BBC20B54EA6; Thu, 11 Jul 2019 15:43:53 +0200 (CEST)
Date: Thu, 11 Jul 2019 15:43:53 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
	linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
	Mel Gorman <mgorman@suse.de>, riel@surriel.com
Subject: Re: [PATCH 1/4] numa: introduce per-cgroup numa balancing locality,
 statistic
Message-ID: <20190711134353.GB3402@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 11:28:10AM +0800, 王贇 wrote:
> +#ifdef CONFIG_NUMA_BALANCING
> +
> +enum memcg_numa_locality_interval {
> +	PERCENT_0_29,
> +	PERCENT_30_39,
> +	PERCENT_40_49,
> +	PERCENT_50_59,
> +	PERCENT_60_69,
> +	PERCENT_70_79,
> +	PERCENT_80_89,
> +	PERCENT_90_100,
> +	NR_NL_INTERVAL,
> +};

That's just daft; why not make 8 equal sized buckets.

> +struct memcg_stat_numa {
> +	u64 locality[NR_NL_INTERVAL];
> +};

> +	if (remote || local) {
> +		idx = ((local * 10) / (remote + local)) - 2;

		idx = (NR_NL_INTERVAL * local) / (remote + local);

> +	}
> +
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(p);
> +	if (idx != -1)
> +		this_cpu_inc(memcg->stat_numa->locality[idx]);
> +	rcu_read_unlock();
> +}
> +#endif

