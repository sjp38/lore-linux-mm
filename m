Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F8F9C3A5AA
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 11:32:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB8E522CEC
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 11:32:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Z8+XdGz7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB8E522CEC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6ECE56B028E; Thu,  5 Sep 2019 07:32:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69CED6B0290; Thu,  5 Sep 2019 07:32:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 563A06B0291; Thu,  5 Sep 2019 07:32:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0021.hostedemail.com [216.40.44.21])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB186B028E
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 07:32:15 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D0B04824CA28
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:32:14 +0000 (UTC)
X-FDA: 75900653388.12.hen12_138aa0e4aba17
X-HE-Tag: hen12_138aa0e4aba17
X-Filterd-Recvd-Size: 6222
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:32:14 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id y22so1573191pfr.3
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 04:32:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=O2/2/UiNnPo2yFEZQiWQVkrfXLV3W+bgqpQbiqeCV1g=;
        b=Z8+XdGz7F2tDUyCosgkoIQT++5bXAeKZmhLPORlnDKcdVvyoeiYDUAM+Bz+BZrUdXD
         9v50xTLEkfzHJItvhLjlTCfg8cH7NFDUWKGg/JBWiYLP1pbiqciVQVv/kR7H43kpFyxM
         dVznmyxSukLwD3F/fuwtNxUQdtdU1f8qEGtXFZCLXduqzl7Kb/ptZHOOXwo9KHuhZsJt
         tjZCYiHCNiiFwlbMLtqTDMYd7yDm73JuA29rHETz0A9DDSMUuPJNL6ObCtWTpLQY900C
         KLU4y3igDxU+UslXXWebYVKFfqNGd3CRDKSBO6KxXSt9dTtvZhT0qQQykJRr81/FuvXs
         3qPg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=O2/2/UiNnPo2yFEZQiWQVkrfXLV3W+bgqpQbiqeCV1g=;
        b=XO4ImH5ODRnPzv6fMsPB1ovG8/vQzOPT19ebA9po3FURVxarEPut2lhtCclK7AzOom
         0aDsXCQS3CODBuU4lVhtVcIf9fqlRKd6lZcqoGkAePCvpkmF5OWAO1GETMhO7jpRz/Hc
         aVN4bQq+S9286mSjg3t6yj4Qv2vo6Lvid80XedoxUIzpOzyd2dxEpzMRo0wsYuwIe8Gx
         93Sd1PW5DRk/vYhvb/pi0Fv6X4lWnRfQvD0uX1s4FA1hrJ2nWmhXiUpMUFZLJy7Afr+N
         gSwcDGvt2Tl/qF3p9z4awJ5plJXXQITLRR0zwLpdc4xApiCRT2txxABwlyIsEbvKS7lt
         Yq9g==
X-Gm-Message-State: APjAAAUWAttSe2X1C//3h1LCmMB2nqgT4oKpC+Md+ue0kJ8H7Splt371
	14jv3UVcypFGVfrCFq4BpR8=
X-Google-Smtp-Source: APXvYqwMP3hi30dLG+ZuFVM6jRWm3eBY7wUln0Huh4bzmedKn7U/jTUHn6v2CFn6EGBQZ6I4thMKgQ==
X-Received: by 2002:a17:90a:3462:: with SMTP id o89mr3387204pjb.2.1567683132905;
        Thu, 05 Sep 2019 04:32:12 -0700 (PDT)
Received: from localhost ([175.223.39.227])
        by smtp.gmail.com with ESMTPSA id q2sm3101737pfg.144.2019.09.05.04.32.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 04:32:12 -0700 (PDT)
Date: Thu, 5 Sep 2019 20:32:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Qian Cai <cai@lca.pw>, Steven Rostedt <rostedt@goodmis.org>,
	Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Michal Hocko <mhocko@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190905113208.GA521@jagdpanzerIV>
References: <20190903185305.GA14028@dhcp22.suse.cz>
 <1567546948.5576.68.camel@lca.pw>
 <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV>
 <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV>
 <20190904074312.GA25744@jagdpanzerIV>
 <1567599263.5576.72.camel@lca.pw>
 <20190904144850.GA8296@tigerII.localdomain>
 <1567629737.5576.87.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1567629737.5576.87.camel@lca.pw>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/04/19 16:42), Qian Cai wrote:
> > Let me think more.
> 
> To summary, those look to me are all good long-term improvement that would
> reduce the likelihood of this kind of livelock in general especially for other
> unknown allocations that happen while processing softirqs, but it is still up to
> the air if it fixes it 100% in all situations as printk() is going to take more
> time

Well. So. I guess that we don't need irq_work most of the time.

We need to queue irq_work for "safe" wake_up_interruptible(), when we
know that we can deadlock in scheduler. IOW, only when we are invoked
from the scheduler. Scheduler has printk_deferred(), which tells printk()
that it cannot do wake_up_interruptible(). Otherwise we can just use
normal wake_up_process() and don't need that irq_work->wake_up_interruptible()
indirection. The parts of the scheduler, which by mistake call plain printk()
from under pi_lock or rq_lock have chances to deadlock anyway and should
be switched to printk_deferred().

I think we can queue significantly much less irq_work-s from printk().

Petr, Steven, what do you think?

Something like this. Call wake_up_interruptible(), switch to
wake_up_klogd() only when called from sched code.

---
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index cd51aa7d08a9..89cb47882254 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -2027,8 +2027,11 @@ asmlinkage int vprintk_emit(int facility, int level,
 	pending_output = (curr_log_seq != log_next_seq);
 	logbuf_unlock_irqrestore(flags);
 
+	if (!pending_output)
+		return printed_len;
+
 	/* If called from the scheduler, we can not call up(). */
-	if (!in_sched && pending_output) {
+	if (!in_sched) {
 		/*
 		 * Disable preemption to avoid being preempted while holding
 		 * console_sem which would prevent anyone from printing to
@@ -2043,10 +2046,11 @@ asmlinkage int vprintk_emit(int facility, int level,
 		if (console_trylock_spinning())
 			console_unlock();
 		preempt_enable();
-	}
 
-	if (pending_output)
+		wake_up_interruptible(&log_wait);
+	} else {
 		wake_up_klogd();
+	}
 	return printed_len;
 }
 EXPORT_SYMBOL(vprintk_emit);
---

> and could deal with console hardware that involve irq_exit() anyway.

printk->console_driver->write() does not involve irq.

> On the other hand, adding __GPF_NOWARN in the build_skb() allocation will fix
> this known NET_TX_SOFTIRQ case which is common when softirqd involved at least
> in short-term. It even have a benefit to reduce the overall warn_alloc() noise
> out there.

That's not up to me to decide.

	-ss

