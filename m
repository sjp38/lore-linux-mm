Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9679DC0651F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 21:15:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5032A21850
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 21:15:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="e2h82MMx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5032A21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFA696B0003; Thu,  4 Jul 2019 17:15:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAAAD8E0003; Thu,  4 Jul 2019 17:15:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC22A8E0001; Thu,  4 Jul 2019 17:15:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 939376B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 17:15:54 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id b124so3060102oii.11
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 14:15:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=MQQ07rB52HYdqZ61pXH1qpFuHoSeCNE8eQWm5DgwWXQ=;
        b=SzYyYih9+BF5onCA71QRvmBrbYRiWfNcOTzg4w7AxyJR9+hTrEdrHZWVfBFTGCHmgP
         iczZwb0uFRBEmht8iuc/CMBMCHG8RSP1oV2++0KyRnFAGraCk0NHgSZrImCtfc0ze4YP
         ZDFsZShK4XrBYNoLAmCXGO1p/GdbEH+ivK4BK7hb7aDA7OeN3ksYCei/nXx0fnRZf1RK
         FTCzn0LmvzoN/l1vXoLIXkQQV6Jzpp4dZvDV+VwTRl0QHTcikozd0KPt62sgiWyRCAG0
         hsZTDifRg5nwx6LFYLtmxNkskAUmuNlPKcZvfxwITvVv8u/Wf3sTiVdPN1R9HK2b6Wpc
         MTXA==
X-Gm-Message-State: APjAAAWngvICoLRWmxHJtu7yRt2tSYLf81ThFDKYa6FeJCMVc7o2AF0V
	u0dVnJCtMVmVkaBW8/6mZtZWUJBqXtJQIxEpRo0p9aEjYc8Fguo0kKazFNO+NG8nCsb3be8rUJX
	HltfSG59l9D8F3aG+WB9doO2SaqcMfJiRzECTvo7in4cUUkDEc7FBiV8nhFFRu++Aaw==
X-Received: by 2002:a05:6808:8c2:: with SMTP id k2mr221266oij.98.1562274954221;
        Thu, 04 Jul 2019 14:15:54 -0700 (PDT)
X-Received: by 2002:a05:6808:8c2:: with SMTP id k2mr221240oij.98.1562274953593;
        Thu, 04 Jul 2019 14:15:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562274953; cv=none;
        d=google.com; s=arc-20160816;
        b=OQjPtkhlsWr8zaEYz5ijQFX6S8RqzuQacynb505FLZXpyJJicOkFOtWtA0cmUPtTqn
         RicugARyLrIHKk1ku1jWFFhMUToixyUvUdSj23RBzG5Y2NH3yW/jWRIq2xvqIFW8EazS
         EQQ+WwY9wbK3jClVSY2ENj5ys8ge3auE4NK4cIYTGZ8ZeuJ8W5GrHifG7RuRsDMdbRca
         NSTQk8eDLH//MLABKNoztjAhRSQF55SVU0HbgMgLNfK2ul+T8qcyYOgZFJyMh9KdRuSV
         jRFtbWxo+qHaV8pV+SwDSjkmWgp1IMq6qR8Y75oev8g8GWeajgNZFk3twPDSyVKBZngo
         rCGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=MQQ07rB52HYdqZ61pXH1qpFuHoSeCNE8eQWm5DgwWXQ=;
        b=T80bRNwAitYvTExOqqaqgoK3W9HeDBkNki5izneFIHMhdfEz9aZJXv3Ad+WFdnHYh2
         rSgooIKOpgHiYeqelcHPw3tsTX7PLKvYnqSdBq3zJ687bKjyRRBVIHXEq4VDuxkLTBki
         zU2ErfYiq32EXVNRenpZHFJFqOJSwGkgZWjP2Ep3/+nltoTJdLKuzjKZ5rdY9T4hcRBn
         quHL0Mlhjxi3KLvNAqqme1oXxS5E34MGjltqGcGSPJAukwPyDUb0QEqPwwG578Z1JG3w
         sNpXbliM1JvEiJIouD0H1/bPuCleQ/3IxnvwTtm3ZRWBqzr3thuxDA1ze//gMa+c3N8e
         4hKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=e2h82MMx;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p25sor3635207otq.106.2019.07.04.14.15.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Jul 2019 14:15:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=e2h82MMx;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=MQQ07rB52HYdqZ61pXH1qpFuHoSeCNE8eQWm5DgwWXQ=;
        b=e2h82MMxM5QusbuIi3nIbhQZEHtR5kFU/nUkkFZx5sWrINuwT/dfST5LGTGrdk0of0
         Rxutpk8embd/ZBpeCuB4tF2xstGtmG3VhwWYmzEgblCfleeE1WJyQbpvzU7CTc7azKiH
         1clDKRW77SjF7lLqXyEQlgH0LF6A0i58ndW2LtlPMyT7Gcvf2aWACIGJwAHPGNDiTi3O
         HcvqV6iu+Eb9yIOndD22y66tjf2hG9i5gjODvkaLAnLrKf2cw3bavtwQRgwfAlGyRNTm
         qmiBMYH8jFIXRWcRMnYUovXZ6h6iAIuC/vlo4Vz+Euk37hR4t8wr1fIG7e/o6Cq8AMm3
         Eh8Q==
X-Google-Smtp-Source: APXvYqxsMa7vLQ93NSh84aEkmHW8QFIZWysP4vFr0NJkhQd2Eo1hNKRNG91e9aM9VDX4aae3UBAGAg==
X-Received: by 2002:a9d:bcc:: with SMTP id 70mr62005oth.210.1562274952935;
        Thu, 04 Jul 2019 14:15:52 -0700 (PDT)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id r25sm2277692otp.22.2019.07.04.14.15.50
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Jul 2019 14:15:51 -0700 (PDT)
Date: Thu, 4 Jul 2019 14:15:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Andrew Morton <akpm@linux-foundation.org>
cc: Oleg Nesterov <oleg@redhat.com>, Qian Cai <cai@lca.pw>, axboe@kernel.dk, 
    hch@lst.de, peterz@infradead.org, gkohli@codeaurora.org, mingo@redhat.com, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] swap_readpage: avoid blk_wake_io_task() if
 !synchronous
In-Reply-To: <20190704123218.87a763f771efad158e1b0a89@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1907041408040.1762@eggly.anvils>
References: <1559161526-618-1-git-send-email-cai@lca.pw> <20190704160301.GA5956@redhat.com> <20190704123218.87a763f771efad158e1b0a89@linux-foundation.org>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jul 2019, Andrew Morton wrote:
> On Thu, 4 Jul 2019 18:03:01 +0200 Oleg Nesterov <oleg@redhat.com> wrote:
> 
> > swap_readpage() sets waiter = bio->bi_private even if synchronous = F,
> > this means that the caller can get the spurious wakeup after return. This
> > can be fatal if blk_wake_io_task() does set_current_state(TASK_RUNNING)
> > after the caller does set_special_state(), in the worst case the kernel
> > can crash in do_task_dead().
> 
> I think we need a Fixes: and a cc:stable here?
> 
> IIRC, we're fixing 0619317ff8baa2 ("block: add polled wakeup task helper").

Yes, you are right.

But catch me by surprise: I had been thinking this was a 5.2 regression.
I guess something in 5.2 (doesn't matter what) has made it significantly
easier to hit: but now I look at old records, see that I hit it once on
5.0-rc1, then never again until 5.2.

Thanks, and to Oleg,
Hugh

