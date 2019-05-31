Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECA0FC04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:47:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0856206C1
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:47:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0856206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62BF76B0278; Fri, 31 May 2019 04:47:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DB616B027A; Fri, 31 May 2019 04:47:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CBA76B027C; Fri, 31 May 2019 04:47:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 011DE6B0278
	for <linux-mm@kvack.org>; Fri, 31 May 2019 04:47:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h2so12923841edi.13
        for <linux-mm@kvack.org>; Fri, 31 May 2019 01:47:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6/x1Gq4+4tiNMFSEU7/AwUdW4MWI1lUpHuAHkH2vvbc=;
        b=NoSTOELj5l1Thw4KoUJ6Q58eClceZgYOEtV4UbZl/rzwUiKL4x6r1UyVtZxayB0q9+
         I/L8OS3hLSu0DqqjOxPMV1gRjUel9lVJr9leU+i8ME/vcBRVUN2L+5/Wi2QlhrPAskSM
         ENFkdE9EiF8hSaEzDFJhb6SK4vW+M61tY4+6vJrrMIbifQV/yHrbYTJzuV+RbZ2faPaV
         I+BpUTunvONGG9udqTNp/IqCk+8N+3hmn1fiAUA5vVLiJ49P/+CESE7h5KxhzaKGCq5P
         05lfYnbpqG3ekUIaIcCUuUGNtVbzNRAdha8Qg5qhWlI4xbVp7xfrTk79QLNDEWOZ/c9+
         PoVg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVkc6Voi4nYAJfS6WrbdA1GqfxoRipxsBakxbAmtkIPezfQSomX
	yROcGtCS5HONMRogUaGgxZ8gN97Mn379ZbwrN70DkHifT1v11HjwQ5Lw+LTs5x4zwvJPoqafXyZ
	81tKJvstQLpOBxRUFiVxJHKXrP0WHD1cn/r0t/UnifRgRQ4HITS5Ze3orpds8jGc=
X-Received: by 2002:a17:906:2e58:: with SMTP id r24mr7913949eji.184.1559292475579;
        Fri, 31 May 2019 01:47:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEIy+kPMX7KdvTkbDLucgZXZTLVkKyEqDge58ioC0A7zF/n3wSIqGiYu8gH9kJKWgc/Qsa
X-Received: by 2002:a17:906:2e58:: with SMTP id r24mr7913904eji.184.1559292474761;
        Fri, 31 May 2019 01:47:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559292474; cv=none;
        d=google.com; s=arc-20160816;
        b=bqc70tKAKi9A7QFKgyVhYohGK3nRiJhfjwqGgmxuB2C84RyGgnEqAydcXyGSVXvtXj
         b5Qztbg1oVNUMyW9qSw+1okwj/EbGyEiiIvB2/ltUe4HJTP5FE/xeHiRs3t929Bu1+tc
         tdr6OIGD+GpGpDfqxIQ/Raju7UjM503uFWAt7psmehzOMf+LxUSmp7Y29U4/GFINOxkP
         vrTLaK+Xu6bSgr0FH28m/jxtDbDQymZlgbfkWz2FRno75q04jKPWdKwPBOl36FVOe8jd
         atoOXv8P+KSeU/qQQXaVDOzU+pd28VeuPqrTxqq/CmIpeTmweGl2pvE9+Pnf9xbhxL6N
         e+PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6/x1Gq4+4tiNMFSEU7/AwUdW4MWI1lUpHuAHkH2vvbc=;
        b=HwZdSOJnyUCWSsUR5ryxmeYQN90EPvpNbqZV8yfYWieNrUKp3IX6lt+hpD7N5mJEH7
         CdlF74eSUYdKUexohK7yEwQtbBjO1KgtFjMaDcqG+gGfHRi8CQysLOjLW3S5eCPckQiv
         kALi1y7iLZIQHu0d00690+xjumxq0B+A9HN4MBYo6YpOdoPNtn7qoV3lBRqEA5slVmBf
         D6tz1iG/uMdEZInVOKLmluf6PiMRujqj0EvVL+HfeZPUGFGdvMrmLyk2JuOn6HdLl5lb
         gURFm2cdy507/ANxBpby7tRnndokgmtOGWxrPkafmVQcRLzmtOFeRNjO2Pvj/AAW67rS
         NOCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o26si3480702eja.316.2019.05.31.01.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 01:47:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CF1F3AF55;
	Fri, 31 May 2019 08:47:53 +0000 (UTC)
Date: Fri, 31 May 2019 10:47:52 +0200
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
	hdanton@sina.com
Subject: Re: [RFCv2 1/6] mm: introduce MADV_COLD
Message-ID: <20190531084752.GI6896@dhcp22.suse.cz>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-2-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531064313.193437-2-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> When a process expects no accesses to a certain memory range, it could
> give a hint to kernel that the pages can be reclaimed when memory pressure
> happens but data should be preserved for future use.  This could reduce
> workingset eviction so it ends up increasing performance.
> 
> This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> MADV_COLD can be used by a process to mark a memory range as not expected
> to be used in the near future. The hint can help kernel in deciding which
> pages to evict early during memory pressure.
> 
> Internally, it works via deactivating pages from active list to inactive's
> head if the page is private because inactive list could be full of
> used-once pages which are first candidate for the reclaiming and that's a
> reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> if the memory pressure happens, they will be reclaimed earlier than other
> active pages unless there is no access until the time.

[I am intentionally not looking at the implementation because below
points should be clear from the changelog - sorry about nagging ;)]

What kind of pages can be deactivated? Anonymous/File backed.
Private/shared? If shared, are there any restrictions?

Are there any restrictions on mappings? E.g. what would be an effect of
this operation on hugetlbfs mapping?

Also you are talking about inactive LRU but what kind of LRU is that? Is
it the anonymous LRU? If yes, don't we have the same problem as with the
early MADV_FREE implementation when enough page cache causes that
deactivated anonymous memory doesn't get reclaimed anytime soon. Or
worse never when there is no swap available?
-- 
Michal Hocko
SUSE Labs

