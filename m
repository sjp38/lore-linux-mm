Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C04FBC742AB
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:53:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7ACED20645
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:53:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Qj1RfR/O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ACED20645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CD0D8E0123; Fri, 12 Jul 2019 03:53:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07E988E00DB; Fri, 12 Jul 2019 03:53:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAEC68E0123; Fri, 12 Jul 2019 03:53:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B80FE8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:53:26 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q14so5086353pff.8
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 00:53:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=yBJq9CDSWPk31o8rRIJukShqhxBMe0EUUUqQoPxta+0=;
        b=T2s1lK4qgewdSqCUQuF7LfaLj6XAThZ/iGwD8YaAGV+aaTmBNXxcosUrHxbL8FwRfJ
         56dZwzuMrrFMTCEa1Fi+ml1rWxH0z8p9wjhImZvn3oEyPanxa5W+8j64TIfiwzVAC13w
         HMqQItI9/+lmkAHiBi/JdYr+JXENDr6+En+9jPSPj2Tmy97py8J5LSzkc0LcQSIzsldy
         HlykuIvgOT7zusc6bxj0j77AXbhe92vEdl7r/Q/rJNgsTNBEpy5+47D48MY0pKQIaU9v
         pD4avNZ/bHpzSV12Zyy2Rnp4F1qiNp9v4Lt2bGwnvsLUORS1PRZzrgihJKYLJNgwcVgf
         X9Vg==
X-Gm-Message-State: APjAAAW2uC44o2OFAGoEIwF3QV597VXCNJfp+cvhsnKuAiEJMjpu3g57
	P4RNyeCXW1ifeiB4RdxNUYnpp/rs735PnPejGJ9jibc4iuT1FzYlWS33gYxZTT5X0GzR/yu/hcQ
	/mxh4md8Axn7HG4iFkd8s+o/yEIRBu6tO/BZ4o7th3QmSrKlF4M2mwI3djAUQTdQUgw==
X-Received: by 2002:a17:90a:ad41:: with SMTP id w1mr9944027pjv.52.1562918006392;
        Fri, 12 Jul 2019 00:53:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+GLgMb4jaDa6BUxNSl/EyM1rqio8lhxqhX7NqRzcwCquKaZ9SZalNEqHOwpi7gUrVsQ71
X-Received: by 2002:a17:90a:ad41:: with SMTP id w1mr9943975pjv.52.1562918005634;
        Fri, 12 Jul 2019 00:53:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562918005; cv=none;
        d=google.com; s=arc-20160816;
        b=TRqGUdxrW1Y3pw06vFykkflYJS8NBbF6NF3H1rbiQenEJt0+BVuwf1HbR+RfpZB5Dx
         V7tvkG1PlzJ5QErLyxG+D84RPCuxPB9oGwJqdK7Fp6J3Dwkp1nnN6+4Wo3/3vifZ7Qhf
         j8IztYp+ruM2GSYMwCb+gV59D0TK3XDjuN1029jXqGC+bFuWusj6m5QoQOiabYuFx0es
         0h+tYK4VTHZNt4lHUJC0IrZ4Zm7+ZzAGJR9Wklh64zJjrMhWKOSMF6PU7TJSjzVQ2vl0
         lEsYS9hgoxVMU7hWwoL0LvxEZpBsIHPG3eR8Ep2OP2ZUmakXi0vIAYZL5Jj/hbFErIo8
         nYTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=yBJq9CDSWPk31o8rRIJukShqhxBMe0EUUUqQoPxta+0=;
        b=qi8OW/Dux34bRhxQ3IisbVozXqPnQPYphjJdFw5Ql4kKWP/A8nPzd2SG8tjjslNI4k
         uNrJJHy6kB7WAxrLKWoWV3BXJ+o46t4flyWJ4vlIRROH/YG/tejKRxI2euNDovwztrVf
         37tHUMEHWI4bKgq3fUP4i/K+wJ2D5g+oPxyAbcs2BoWt3KWtl1RodgUYjXIIAkt9i5c4
         fneHnepLL0+jJoEUhg63ljd3TqQgFRcf4B+G6wqEAJQ+8GFx//0ZdO/KO7Tlaa6juvd5
         84/u6umHTroaM1xSGe2NsrVfdnK2lPT0zXAYamJw+WFgB7aNwL2oy2KBaQPNmIZX17gt
         u91A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Qj1RfR/O";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d18si7697485pfn.202.2019.07.12.00.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 00:53:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Qj1RfR/O";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=yBJq9CDSWPk31o8rRIJukShqhxBMe0EUUUqQoPxta+0=; b=Qj1RfR/O8WufKxSqWgw5cNtHdP
	EiGCtkdhnfwmBHRpq16DvuUT5c9pJocq2KVloiR2wNQRjNvSizqzigMTOuvCIrABB4VRLg6nt0atI
	+9JPW+rbGxfKWv0Dwzg/13BWWqMwyt912a0wnbJ/4Q+pt5oU9IqVCIdxofj9cz2RmTvKze+nm2k9S
	IzDbo38zYGjtuGmMto/J0ZEiGXsNyHPTCL3lyS5bh+k6uG3uZl8ODKmLzV2S1U/NKL3x+bBuuHwtH
	e/TOKwj9nw7Mi5MRQPOuizEX9cEzb6LV9O7izC5X3w9vMRSmw8OpUkwxZjXoaIsqnY2/nJ3Av7SRr
	wE54IWHA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hlqMq-0004VU-NY; Fri, 12 Jul 2019 07:53:22 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id C950520B2B4C6; Fri, 12 Jul 2019 09:53:18 +0200 (CEST)
Date: Fri, 12 Jul 2019 09:53:18 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
	linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
	Mel Gorman <mgorman@suse.de>, riel@surriel.com
Subject: Re: [PATCH 4/4] numa: introduce numa cling feature
Message-ID: <20190712075318.GM3402@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <9a440936-1e5d-d3bb-c795-ef6f9839a021@linux.alibaba.com>
 <20190711142728.GF3402@hirez.programming.kicks-ass.net>
 <82f42063-ce51-dd34-ba95-5b32ee733de7@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <82f42063-ce51-dd34-ba95-5b32ee733de7@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 11:10:08AM +0800, 王贇 wrote:
> On 2019/7/11 下午10:27, Peter Zijlstra wrote:

> >> Thus we introduce the numa cling, which try to prevent tasks leaving
> >> the preferred node on wakeup fast path.
> > 
> > 
> >> @@ -6195,6 +6447,13 @@ static int select_idle_sibling(struct task_struct *p, int prev, int target)
> >>  	if ((unsigned)i < nr_cpumask_bits)
> >>  		return i;
> >>
> >> +	/*
> >> +	 * Failed to find an idle cpu, wake affine may want to pull but
> >> +	 * try stay on prev-cpu when the task cling to it.
> >> +	 */
> >> +	if (task_numa_cling(p, cpu_to_node(prev), cpu_to_node(target)))
> >> +		return prev;
> >> +
> >>  	return target;
> >>  }
> > 
> > Select idle sibling should never cross node boundaries and is thus the
> > entirely wrong place to fix anything.
> 
> Hmm.. in our early testing the printk show both select_task_rq_fair() and
> task_numa_find_cpu() will call select_idle_sibling with prev and target on
> different node, thus we pick this point to save few lines.

But it will never return @prev if it is not in the same cache domain as
@target. See how everything is gated by:

  && cpus_share_cache(x, target)

> But if the semantics of select_idle_sibling() is to return cpu on the same
> node of target, what about move the logical after select_idle_sibling() for
> the two callers?

No, that's insane. You don't do select_idle_sibling() to then ignore the
result. You have to change @target before calling select_idle_sibling().

