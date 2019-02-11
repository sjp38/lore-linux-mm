Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21A50C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:53:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7454921B25
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:53:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="qSa3z0GI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7454921B25
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CAE48E0130; Mon, 11 Feb 2019 13:53:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 178BF8E012D; Mon, 11 Feb 2019 13:53:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 041118E0130; Mon, 11 Feb 2019 13:53:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB1958E012D
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:53:23 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id y63so8331044yby.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:53:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Py05Zd5WRf99APZb89NwZR67zhDUZEH9vW9/0MbuiHY=;
        b=qo7xkCS4VA+Eb/dfoGzg3V7oJVpbVLmTCkbEFGlK3OC1kyo7aXfctYwox0iS4O16Wd
         IDL3azDDpou+Fpu1TtAH3TfLwreqV4xgJYc7BNjRvozvuxLD6/1OGjkk1doXCK2PhyYF
         /Ag3jwFXquMmbkNkCD2xWIHUdYnBOsIbIbSsmaF9XPnkI9HKi6zXagsp1BXwAZ0N5kOs
         iufnW6FLAQQKkuVZ0Dyxg/HFokHg0Es4whuZw1mdEhHehVunp2ls/DKho8FYQWQrCpq+
         CTLGX3AFIFRW5j8SQ7asbCt9EF+0qwsJ64k4Fq55FCryfmybJ2GPnFcNV40zGSL06bmZ
         UP2Q==
X-Gm-Message-State: AHQUAuZerIpg661j1ymJbmU6Taovwtacfi2LQcsO4GNk91jQ+pdISXLf
	h4/BfSpDLH8YrJ3FNxkBHQkNOpdNJQZuiXo6wR2V2b0k1m8PKWLeG6nPz379ifKH2wvJCcG300l
	o+dnWpzrHnVnyPYaf6UsYDV1jFcKiqqDmw8S48sU3/MWOdiqq9hOa58iD03CM4IRpNXLpj0uVAz
	6i9BHavB/yF2lrDEaJGgVw/70iTymTMcO5lau37czCG0nB2WRIIsWT7FiBx68ZVO6JoWyEYzAQa
	U5Q5F1sAa2BNEYTIR9ko5+fsW7U73wV/PlvC73KmldsOiBxNPAv2V+dJHcZNASSZHSu6XH/wpQr
	mdQ1e3oFzd8yqI7XLLkWpLeesxk0uXNAxlSnCbNkUoeUG/odcI1mLJ19EbDsBBpu8VKDxkeE3RM
	z
X-Received: by 2002:a25:3445:: with SMTP id b66mr13108345yba.515.1549911203490;
        Mon, 11 Feb 2019 10:53:23 -0800 (PST)
X-Received: by 2002:a25:3445:: with SMTP id b66mr13108310yba.515.1549911202902;
        Mon, 11 Feb 2019 10:53:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549911202; cv=none;
        d=google.com; s=arc-20160816;
        b=XA+0bc6iEf9oXnQx2t5BG91QtCbsqiNwLcQKAByK1yLWtyALmPXh2QaMd2hyTeqbYG
         zU8i5GKjODhSqpJ7WerCUCmpL+F4aX+itRva/SBVLXA9DmKrRQidqT6y5rHGQsjB6vCT
         kXJnpgZuCvQZTyJ1nR83hPIHrIj0JPWzWWG08k+OrPIDNLLQuz1O3FnkXbCrMMsp7Y0Z
         bNjW6AGy53Ry+Lp7rqxvihIOA03DDkV8MK6h7KOPtoeOmYfuYgQI85IBavgQsCcGMgqT
         1g1DOCvCxJ0UXVz9ynV7BziA2rjP+xufPvr3ubOvDC3q7VSzjeTvduphZ19a8Dm44/6o
         /5QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Py05Zd5WRf99APZb89NwZR67zhDUZEH9vW9/0MbuiHY=;
        b=rABoCFBzdG9Z2q2yB+64fO1NCSI4K2HM61HuDebUGVUpw6/AETOOUpjJ69viRwvJBs
         r0VpePIFtfXTgPpEVB4Y70PQEy5q82kw3lM4YIkSeJMBMVE2lcTSpNETzZMlR6QF31ti
         CeQ/Fh0fYqLQYJiNJypTuUkrq8/tRK51+mGM8GPpenwK6vwCJhD7zqJWegXUI/GO41fw
         qj9e69iElCKsalA11ak7iSdwlmPW4qNJnvZzENGV2GQ+AkDPVCOr5RbbkcjTZQVvW7kf
         17gUwvKqPissuX5U+07JmsduzbDRPVXLMcA8xy2pnWpydtKXhf7wdwegIxk42N5nXa5z
         lBOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=qSa3z0GI;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s18sor1962589ywg.182.2019.02.11.10.53.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 10:53:20 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=qSa3z0GI;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Py05Zd5WRf99APZb89NwZR67zhDUZEH9vW9/0MbuiHY=;
        b=qSa3z0GIZnsgj32mJi2Ca7wOnqCbzwnm5RT8DySZ6pWh1WOgpp45wlmjIiZmkIxpXK
         OUHRmZnVAQNjI+GEzk+4wDOGWOoCLiaJSVPshy/8m6N+5ZP6qPJzOllpPEU+cJOsxOe5
         NwXqtqYV2pr5soO7WF9+pblCA8G92HZG+b2KHjlxO8KIiRLAgYmgQVQkijqn9kAicSmn
         7cIdEQly0paG5QgbfsSJSkdV5HUQhowt7XOVfGw0ikvmHTRwqxsB3x+bnVb+eE49lc3j
         EIqGyspVRWlaPWDoKU7NZnpeWz+iEivKbpwAM9Wg4zrdML8eA1hWjmCWZHOZzb7MPiqF
         3toA==
X-Google-Smtp-Source: AHgI3IbtLUi3lvGZJNJ4o01pGavyO3l5XXe+wSMIfjTHUZdZj2M8pLAyy/MtZS6vUABiI3tI2IF4NQ==
X-Received: by 2002:a81:2f03:: with SMTP id v3mr114708ywv.136.1549911200143;
        Mon, 11 Feb 2019 10:53:20 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:6e5])
        by smtp.gmail.com with ESMTPSA id k64sm2670628ywe.66.2019.02.11.10.53.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 10:53:19 -0800 (PST)
Date: Mon, 11 Feb 2019 13:53:18 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] mm: workingset: replace IRQ-off check with a lockdep
 assert.
Message-ID: <20190211185318.GA13953@cmpxchg.org>
References: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
 <20190211113829.sqf6bdi4c4cdd3rp@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211113829.sqf6bdi4c4cdd3rp@linutronix.de>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 12:38:29PM +0100, Sebastian Andrzej Siewior wrote:
> Commit
> 
>   68d48e6a2df57 ("mm: workingset: add vmstat counter for shadow nodes")
> 
> introduced an IRQ-off check to ensure that a lock is held which also
> disabled interrupts. This does not work the same way on -RT because none
> of the locks, that are held, disable interrupts.
> Replace this check with a lockdep assert which ensures that the lock is
> held.
> 
> Cc: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

I'm not against checking for the lock, but if IRQs aren't disabled,
what ensures __mod_lruvec_state() is safe? I'm guessing it's because
preemption is disabled and irq handlers are punted to process context.

That said, it seems weird to me that

	spin_lock_irqsave();
	BUG_ON(!irqs_disabled());
	spin_unlock_irqrestore();

would trigger. Wouldn't it make sense to have a raw_irqs_disabled() or
something and keep the irqs_disabled() abstraction layer intact?

