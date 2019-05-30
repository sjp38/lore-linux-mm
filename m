Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7686C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 08:04:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B1A1218CA
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 08:04:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="wxvteZMt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B1A1218CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1373E6B000A; Thu, 30 May 2019 04:04:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BFAA6B0010; Thu, 30 May 2019 04:04:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F176C6B026C; Thu, 30 May 2019 04:04:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2B1B6B000A
	for <linux-mm@kvack.org>; Thu, 30 May 2019 04:04:15 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id r27so4093608iob.14
        for <linux-mm@kvack.org>; Thu, 30 May 2019 01:04:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ZNHljSo+xuO+rijXANsB4tJFe4vq/fcU3WZ/qW7T1K4=;
        b=LNu7HT5dQ7IzQVRX2Th+q6QXJXI5rLgGEsULKRsiftf1SeYLG+RTbZQG0gZIt5qRC3
         0rY1FDptliis5ZHzTnta8oNRJj2Jek78Lz25OOjaI3lt4uGdL6l+XZBf9ocsQkyGZX5C
         2gEs1Hq2k7dMCfJH3mRwy1UyqSwlQ2bDlVh/Au3PxORDSHRwWqIMKcHrDMhRCeGXa6XL
         qydKpjuf9cedQGMJnWzz7PKLFxCyhqTIssObns6rV6Romny3yAuC/FitiNIip8X17vg4
         1mJSM4rkCa+OXzXkg8eayrV5HixZCt3Ffwo+qQH8BF4u7OjZRwFwiHZhKTr5R3JBiq0l
         7UTw==
X-Gm-Message-State: APjAAAXpLfsZQyh1pHHO8PQNNuo3uxGhe4INPYwqn2sSt1WX2fENItqn
	HNtqXcKAljoQrXZvX94745/LolfnESRIvd9EF9W+yI4I0OoDnOwtJeyIggUELNyh5tZCAjOitYC
	ijfr9pdMrB6jbjXENVLsdX179uesXol8PhEMYUV6jIHm7s0m5O75OX5en65+n3y1zSw==
X-Received: by 2002:a02:a615:: with SMTP id c21mr1358378jam.67.1559203455566;
        Thu, 30 May 2019 01:04:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwfWY42/5lrO2ilo6POu8g92DcYIfQWVC+k99eyLiiuuG/GGU0UUE2tTP+51b7DgBp1ZuV
X-Received: by 2002:a02:a615:: with SMTP id c21mr1358351jam.67.1559203454977;
        Thu, 30 May 2019 01:04:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559203454; cv=none;
        d=google.com; s=arc-20160816;
        b=fm8LiGQ6K4JFOvi+XZwgncmpsQY6B+4KKMYbz54fw4IciWPIlBczc+SuVvcLEj1JQL
         U6VoF1j7/IDc3JZ5NQZIt9WJkiWt2friXXMWWVL9DVlgBJPGU3c1TOhe5nrcxTyV1gj4
         wwUCdliIA7bu8DmvWf194b+l3EzrQmt8xrGlb25AiWmJSeaaVFODbKzaxAKSdiYRVMEq
         Ho3Z8Wf+MKs/qxoEmMYWgFvAyjvA+6MDABBFNLnMblfTZKDgCFuzS6V3fg+qwjQXmDOj
         /suU/wJAPxeyCTIY6mI6627ogQ0Gla/cNDG9pKIXtYN5QbrxatuVXalh7QJZomITYuHN
         RDhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ZNHljSo+xuO+rijXANsB4tJFe4vq/fcU3WZ/qW7T1K4=;
        b=e6wOjxaB+h6I0pACFeXVbMxv9TVDlOYwU+g9HJ8IDMZbbP6U6TRxL6oSZSbcPInCm0
         RzEo1gLDrqmtfoesHdi5uSPrZZpkfJZcHBDomTjJiubWNQyTSZTJopmdp0dmNAEGO4nU
         ZH9kAqycIqxFekf6BzIIIOkDbKu5vbiNR+D9wcK/ZVkBzZRr+sjho1JxkmqZvs0jiw2e
         KZVjKc85U/gyPHw3ifTA4X5XWglqfJ/MuQLktMpzRV212Q9BcSonIva2CSJSGmDf+4eZ
         HY0cBrVvTxhRXBuJtcxDiyvSZLCE3C7BrRoQR0fNdmUX1HSusN7iM1VRpsbSfdOu2aoK
         xQKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=wxvteZMt;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h124si1267361jab.37.2019.05.30.01.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 01:04:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=wxvteZMt;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ZNHljSo+xuO+rijXANsB4tJFe4vq/fcU3WZ/qW7T1K4=; b=wxvteZMtqs4EUcTAMJWHqixz6
	mFlqd2lJn4cAJwAR/hiRZrEL1HzdpfpSWviOKW76MazUqLmiCOX0GXm9QTDDGduA5qdqBmPAd1R7/
	gtqvGkRUITnXCQaDqEVvt5XPaHTg+ZT+AMGLgBcwFJMbrTOd+9sLivPTHl8mHadihGFP0gX7iwini
	Q8Pj3wSK1+yjR342xlFv6RVYcZ+uBZY/cOmdfazWIwbFvd8oxQeWoMEc04vYPX77/yQa648a+tnc3
	5OW0ffbHO3MaepHn+iCGQ4H+GGlo9+ea+OgZeFcCBAVm+/3fFP9eqtKq+q2nEJa3OQDIFlizD1mXZ
	w34kI7GWQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWG2a-0004nX-GI; Thu, 30 May 2019 08:04:00 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id D70FB201B3992; Thu, 30 May 2019 10:03:58 +0200 (CEST)
Date: Thu, 30 May 2019 10:03:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Qian Cai <cai@lca.pw>
Cc: axboe@kernel.dk, akpm@linux-foundation.org, hch@lst.de, oleg@redhat.com,
	gkohli@codeaurora.org, mingo@redhat.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-ID: <20190530080358.GG2623@hirez.programming.kicks-ass.net>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559161526-618-1-git-send-email-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 04:25:26PM -0400, Qian Cai wrote:

> Fixes: 0619317ff8ba ("block: add polled wakeup task helper")

What is the purpose of that patch ?! The Changelog doesn't mention any
benefit or performance gain. So why not revert that?

> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  include/linux/blkdev.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> index 592669bcc536..290eb7528f54 100644
> --- a/include/linux/blkdev.h
> +++ b/include/linux/blkdev.h
> @@ -1803,7 +1803,7 @@ static inline void blk_wake_io_task(struct task_struct *waiter)
>  	 * that case, we don't need to signal a wakeup, it's enough to just
>  	 * mark us as RUNNING.
>  	 */
> -	if (waiter == current)
> +	if (waiter == current && in_task())
>  		__set_current_state(TASK_RUNNING);

NAK, No that's broken too.

The right fix is something like:

	if (waiter == current) {
		barrier();
		if (current->state & TASK_NORAL)
			__set_current_state(TASK_RUNNING);
	}

But even that is yuck to do outside of the scheduler code, as it looses
tracepoints and stats.

So can we please just revert that original patch and start over -- if
needed?

>  	else
>  		wake_up_process(waiter);
> -- 
> 1.8.3.1
> 

