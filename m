Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67B99C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 13:45:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24C6021019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 13:45:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YrXbIX5q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24C6021019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC5048E00BC; Thu, 11 Jul 2019 09:45:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B74E78E0032; Thu, 11 Jul 2019 09:45:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A64178E00BC; Thu, 11 Jul 2019 09:45:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83E718E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 09:45:40 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id q26so6850985ioi.10
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 06:45:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=motTGlaLa78AkkT94ppPVZ2/Cr7h+cvS3zIYf8Ec2sw=;
        b=thCC9LFpft8Br9nOCFdtBVKhn1sL6Tv1AfnsWUilt/6Ef1Qq5r+2ycEjah9SAJhgC0
         63HWw7XCUKnT98g5CNjTfytzrT5lclMDxZrWL3P9Fk9AqOn8eysqnRElFuS6ZRVP06JJ
         aeSWLWJj64RK3amXMb6RUzLPLKUexB67Q8aXzOot7x1yhI4NvDgDik43m/nBodWVzMww
         ETUEG/vx1gWR1lBkaN2onhePAuhXazIoMbR5FRSh+/cPuW8bvlTNcwD+Rzi4Yj6G5E15
         nTtmUXqhY8kdP/sqnWvIhSuTAv18RXKYGV76y5EqKf5KrZNkxNJjMLhaB/hWK686D+UN
         DuLw==
X-Gm-Message-State: APjAAAUakgmkNrcjMrJk1jgp8MPCBCs06M8N1WXLDL41dZ49tMOwE7k8
	saPchEupzk6MRXmgK1+FamsM3x4KyZTeV9WSjeOTYKTuZlT6mt2uDhMTqKZutOV2TbXGDip+vZ9
	+Gn2d6GiliPEs1v23Oiarl5ggEOAIpadaoGI+qSTKmGRXZRxaN9G+oZwTeSIcpufZYA==
X-Received: by 2002:a5d:960e:: with SMTP id w14mr1431465iol.189.1562852740338;
        Thu, 11 Jul 2019 06:45:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtyAA+sMk0smIhkIv6v5l6AoBJpp7RETKNxOXAyg3v3TFiOAXprDkDJLiyV9ARt46s4JPe
X-Received: by 2002:a5d:960e:: with SMTP id w14mr1431338iol.189.1562852738530;
        Thu, 11 Jul 2019 06:45:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562852738; cv=none;
        d=google.com; s=arc-20160816;
        b=Fbf8ZOE2g8qrcA2t0lVUM8gOgcJ6h6PyLGpVdxMazQz6DxGCtYgBkPF3dThX2UOEio
         Z97eULRt5NwphwYDmdEd7qKOuO/EjbUr/dm/7EZIY80gw21X1Ni/4OTWdKHut++qffOA
         amR55UCYzdG+J9ANXjA+tGMLsuLY9orgZ5B7NxYbG3MY4HixVq/YTlAtW7cjSl5/x2vg
         liGfOrAIIz1W5Ju5CF3auMioMPB8LK+b3rlKQ8Dy0o6NIIAKqLwdbgfUby1p8hHYZl4Z
         r6vOD1gkSPXGCE51DVQBtT4LkPrrbd2eAURNa9xMiYU5PYyx+dZS0oxDjtkJ8fMXTXdj
         34Jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=motTGlaLa78AkkT94ppPVZ2/Cr7h+cvS3zIYf8Ec2sw=;
        b=AR35EWvbpTCd/NYKe9brJU+7uPVxGOk7zkUofvwnCen4Hq90L9QlSfU8AVyFP+E4Ml
         g/xd1W76RctDnCZClGvuYnOUHHlf23elDIKO7OygOEC9tHFYEuEySczwIlXTrIQR2RoV
         5xCPp8o7QhY87imCf52wsPziXgE5R5MZC6Qi+mazf8olWEj9RAqIXBvfM4wMYYuBc+WM
         OLr6A/ZdT5z2dAkArMLdx9xi8N1wCkYsW9IGfXq9Ec/oT2Bk1l2G4Nf5Vj4n9n19BUxr
         rTXzgxgo/6P8sy9hzeFkzVsam9EUOA5pF6sCUkYeTX2N9doDvhSWi1X2iKfIxTvtl5e6
         DyCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=YrXbIX5q;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id z11si8057292iop.97.2019.07.11.06.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 06:45:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=YrXbIX5q;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=motTGlaLa78AkkT94ppPVZ2/Cr7h+cvS3zIYf8Ec2sw=; b=YrXbIX5qnEOqZJQGogVWSKOxdl
	nGFNn6+c0qufC1VtyAe6+rL5HrRV67MuO+rpGnEO0OyUNgeIEPyNiSiZrfk6aZZrK5WNwcSr/8dyK
	A26SZPB2XsuHf+D4zUZlaMuqB+7kEyEb+ngAnNP6xe5ohRPxdletoBrzIZXJ31TWB1dFGaguDRjL6
	GRsekT6kNLxlJ7kZwHIlito+ouKUCAR/I/CsOhElJJb1HCWsIfFsFnE2fFyvtCjGYfq8lmKOXoZik
	mAS0/IpGxoFZ8o1KHUmMwLXx5fGM8kctE7QQMdPbSolTQ9Qd+HRIStso/avMYCaTNCZnK6yy3EO1W
	VNCWBhCQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hlZO4-0003nk-NU; Thu, 11 Jul 2019 13:45:32 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 7E86920B54EA8; Thu, 11 Jul 2019 15:45:27 +0200 (CEST)
Date: Thu, 11 Jul 2019 15:45:27 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
	linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
	Mel Gorman <mgorman@suse.de>, riel@surriel.com
Subject: Re: [PATCH 2/4] numa: append per-node execution info in
 memory.numa_stat
Message-ID: <20190711134527.GC3402@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <825ebaf0-9f71-bbe1-f054-7fa585d61af1@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <825ebaf0-9f71-bbe1-f054-7fa585d61af1@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 11:29:15AM +0800, 王贇 wrote:

> +++ b/include/linux/memcontrol.h
> @@ -190,6 +190,7 @@ enum memcg_numa_locality_interval {
> 
>  struct memcg_stat_numa {
>  	u64 locality[NR_NL_INTERVAL];
> +	u64 exectime;

Maybe call the field jiffies, because that's what it counts.

>  };
> 
>  #endif
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2edf3f5ac4b9..d5f48365770f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3575,6 +3575,18 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
>  		seq_printf(m, " %u", jiffies_to_msecs(sum));
>  	}
>  	seq_putc(m, '\n');
> +
> +	seq_puts(m, "exectime");
> +	for_each_online_node(nr) {
> +		int cpu;
> +		u64 sum = 0;
> +
> +		for_each_cpu(cpu, cpumask_of_node(nr))
> +			sum += per_cpu(memcg->stat_numa->exectime, cpu);
> +
> +		seq_printf(m, " %llu", jiffies_to_msecs(sum));
> +	}
> +	seq_putc(m, '\n');
>  #endif
> 
>  	return 0;

