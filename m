Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A4AAC74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:10:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC15B2166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:10:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="coBVf6pq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC15B2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 350C38E00C1; Thu, 11 Jul 2019 10:10:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FDE28E00BF; Thu, 11 Jul 2019 10:10:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A0AC8E00C1; Thu, 11 Jul 2019 10:10:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D36778E00BF
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:10:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n9so281939pgq.4
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:10:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=dmt+pyxw4T8mpV04yaOR9Ac6pmdUH/6jx5BRJ/VTKwk=;
        b=EtaxKCWV/TsQAk4gddF3vdbXnSShsvu6TcQY1X2FWWwD6gLGAdwjZQzuguUqWaDCwC
         qA5UUS+Eh594IvOuhqzfkKy2i3HvR78KBSKnmmRXSbAu4ReKc22L7tWR0n3JhLHa/CNh
         dvGw7dX1ofpmSzhmUnb8IndSKuYsq0SL11HgBsDMG+hAc9+sDkXGmISXt2Km8CiX4Jif
         eecuCVZo+15jXQH8W3zaYsoI2lar3/j+moLi9FxDODzDg29tW/KMUWZsgl5irqUNKwVe
         n3ysMQyh1+PUoY0f95ZdCHywkzomZlMS4B1I1nglnrnquQFGSPSE01oZNyR3OLIQPkQ3
         muGQ==
X-Gm-Message-State: APjAAAVvjcIazXG+bE4/gKCy3Kq/cSp84BIgnU+EtWdtN3Nf3cIj14iI
	8Jdwx1w0EqVI5fr26XnFD8M8o5OAYEKTpJdtXx9T9IiaDSzn3laBatWprtNKGDHOxqdSmrSKQLp
	CMjcBFmX+2o7FjING0Tn100pdfHV1ieaTGutO2Sa99fM3Kg1ftEf1AoTuRwVTBrlYKA==
X-Received: by 2002:a17:902:290b:: with SMTP id g11mr4890482plb.26.1562854247283;
        Thu, 11 Jul 2019 07:10:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9Jnt7G5hPZ9EiWuDuzmu6iC3OniZg4WWq7On3KkNwP0tYjPSrHUWdf3UiYtBv1Weerz1I
X-Received: by 2002:a17:902:290b:: with SMTP id g11mr4890308plb.26.1562854245253;
        Thu, 11 Jul 2019 07:10:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562854245; cv=none;
        d=google.com; s=arc-20160816;
        b=L62SzbH9bVyycHmYwfXf6tHNExOVF1xrWbZHK1qpZ5M4Z+pDICd/hopc3fozB1cZi4
         FMwWr7149pkUqsOLnMV5Syc8qG7PDbL3bbnbqscTdREdaJx6xwtMxvcR1LZG5IG0KWd3
         kBpshhQBJJIBxVsW/S1b1rf0QoTGytaEoKCmhgrUicmZKuS7Os65eWV+Uv5IVYO9dbJK
         DVmHMGoFhm8CT9a+pj/2WhIe8ty2LO81hhdQWUP09fz9fmp4B452Fz/sKXVb4ozENFDL
         zpmvN0LVFkwEjLUsNVGlSW8gCQPs+AYcGmkyOilTPyYm8cAR6mpv8IvqHbJCUr+mSLRp
         99ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=dmt+pyxw4T8mpV04yaOR9Ac6pmdUH/6jx5BRJ/VTKwk=;
        b=p6tlpwdL9jYSfJOlkmoQJjCilXFw8R0h0fdVVyXRIA65WSyqzIjZeA+aI2DVUHexrh
         SyUeq7qnS3Uy3XHMICpHozoRHxNuRSObjuj5JCI9+Qkxa76NELNhBAQLRkMre5q52+IX
         OkpYWntjas8MlXNekpoNsF20eSw2eyHAal6WEF999uPHgAC6TnQv+dn+KiZIXeuOIxyM
         ztbBATIHg4/U6or2A64c00nTY0u2VUyGrkd5e6ubXmlKU+lmPta/XsrIxcMOcz0ONR0h
         t4OUz2lqWjkbTQ7d8sbCT205CzrwC8DUfcOEQdcWCXLoY04bpFbekANGnI5tgXp8cf1f
         zjVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=coBVf6pq;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p1si4810898plq.286.2019.07.11.07.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 07:10:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=coBVf6pq;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=dmt+pyxw4T8mpV04yaOR9Ac6pmdUH/6jx5BRJ/VTKwk=; b=coBVf6pqOhCxhlHxZ9jfrb5HIq
	ZIxMQPsvl/1QYBSuJZ2qrOQS7f4mGMfasw7bXNG0qpCNsuWadIMZLNwl7OYbGVCJd2UbbWWOT8ulL
	jieZjB9EX28Ot8ElDXoevE6hXg5n/VAFcpM98wDmKV6665EcvkBeD9L5rJycn1WxB6LHzIxH8wXvq
	ai4b9IGzqcLo5U+aVro7B8GQnPKYlV/UqE2Z+Q0QYcOCk2KgY8s9EUTYzgQoyOdASD0VX/9FFt6rL
	IhYObU/yrPxXR0U5ksG4M3yFW1wLduESZnhsr2ZVMTiJV6QfLbdbuv0idzy2WmW/c3WpQM91jVDUb
	pIsG/a8w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hlZmS-00016J-Jn; Thu, 11 Jul 2019 14:10:40 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 661B320976D81; Thu, 11 Jul 2019 16:10:38 +0200 (CEST)
Date: Thu, 11 Jul 2019 16:10:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
	linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
	Mel Gorman <mgorman@suse.de>, riel@surriel.com
Subject: Re: [PATCH 3/4] numa: introduce numa group per task group
Message-ID: <20190711141038.GE3402@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <93cf9333-2f9a-ca1e-a4a6-54fc388d1673@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <93cf9333-2f9a-ca1e-a4a6-54fc388d1673@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 11:32:32AM +0800, 王贇 wrote:
> By tracing numa page faults, we recognize tasks sharing the same page,
> and try pack them together into a single numa group.
> 
> However when two task share lot's of cache pages while not much
> anonymous pages, since numa balancing do not tracing cache page, they
> have no chance to join into the same group.
> 
> While tracing cache page cost too much, we could use some hints from

I forgot; where again do we skip shared pages? task_numa_work() doesn't
seem to skip file vmas.

> userland and cpu cgroup could be a good one.
> 
> This patch introduced new entry 'numa_group' for cpu cgroup, by echo
> non-zero into the entry, we can now force all the tasks of this cgroup
> to join the same numa group serving for task group.
> 
> In this way tasks are more likely to settle down on the same node, to
> share closer cpu cache and gain benefit from NUMA on both file/anonymous
> pages.
> 
> Besides, when multiple cgroup enabled numa group, they will be able to
> exchange task location by utilizing numa migration, in this way they
> could achieve single node settle down without breaking load balance.

I dislike cgroup only interfaces; it there really nothing else we could
use for this?

