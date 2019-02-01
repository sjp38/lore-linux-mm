Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3002EC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:05:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1A8020869
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:05:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="RjNdbbwU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1A8020869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B7238E0002; Fri,  1 Feb 2019 02:05:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75A178E0001; Fri,  1 Feb 2019 02:05:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3BB8E0002; Fri,  1 Feb 2019 02:05:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD0FB8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 02:05:53 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id w22so981364lfc.12
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 23:05:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zZ6l/FA/GUGfptSWUSsSvsPRMmY7tMc07VEVRU1/bZo=;
        b=aOHHtJWq9C6hCgdTG222J1E2j1IKuaW3eN1nlms4K8S0wpKzdxFUr3SwldOPTRXVwe
         o5imeMCYklmJlma4A4M7XePqAiUnEQfq22ieFMWAJoDMpPj0VsSVavLQbP1h7MmxGqYu
         TMB2ZbF6WgbpglDorNPS0K/W51M4MY1ghwIYKTIN4murDdJBgUqF44GGEbLp/LXIjsyn
         Et4MnAyvVES+5+FWrObXpqULMaZlE2buUH78Bm6eVXj3bVaT9kjrdUYHdiFS202T74io
         pj925HAv32HYaPquUnklQP/5kYr+YdWuq/xGhq6pJeA6p3MbqulwFa9mQrZr6yhYPWfl
         oCoQ==
X-Gm-Message-State: AHQUAubanqqXpMubXp5JK+cO31oqiKRbMHr2+F/wRwSqrNkRgRjzbf0S
	mBzRT+eRSEY6vlCZFgiIL6w935eNvTbMwq6xI1ow8MUmfI7BoqtFsSAAy2tElQIxD79sDWkmJd9
	/c6i3lWTp2Ya2WhNRnBK4Fll+bIs4l+9r9iR46S18hU8fYERxdRvyiEKJddEpASA8KbumQRTztV
	wZbA/FlhBo27LaTGpdX0xcpseiyhcS4ADL2J0LGWI6gzr40VPg8oj5s4QaGqzYE/0IfFSNTwno/
	CMPSAsyZNmZhlNYdvMRp1HtNYlacyeo9K18mJyq35RGzZE5UAZAUtoUEgsObIoMva5pk5K60eKp
	Fz2X5XnlF99P5vgvIWyMP2orquRunLifEKEnWuNIjMLnxyVEakpdPFsazz/1PEFFbFzcBNtkHbH
	o
X-Received: by 2002:a2e:87c3:: with SMTP id v3-v6mr594585ljj.13.1549004753177;
        Thu, 31 Jan 2019 23:05:53 -0800 (PST)
X-Received: by 2002:a2e:87c3:: with SMTP id v3-v6mr594534ljj.13.1549004752165;
        Thu, 31 Jan 2019 23:05:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549004752; cv=none;
        d=google.com; s=arc-20160816;
        b=Qrn+dXAd6ue93lpOy41rF9OEbC6zJYs9Fz0jvVFUV+ri4neZjArB0v2TIjH33OLXiz
         Ge4AX0WmRMTgBQJCS435GQZU9ZuzmqDMFyGr5yBR14bzSB+SNwM5umfip4Z1hIHjKWaE
         8iZUTUoo2RRhO/TgnKxuHTYpZNDIuIxDl6KJNfxrRdGy8YqRfPBTKj60x4UTOQAlriEq
         39HrIVeL+XZ3KTYkk2Ralo3ogs3NHXs8Q//D1Ckve8JdWfP4pJBAXVyUr3VtNRv0knjK
         Wc+gW/n63lovoF9UQaRsupxtwvybuLFWkadeKd5a6HwvbnSR882LOrx56pq7mLm+UUwZ
         X5Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zZ6l/FA/GUGfptSWUSsSvsPRMmY7tMc07VEVRU1/bZo=;
        b=h/yOY7aD2ajWWL3IOPs6WG8aWgManfpEj4FiFyI0eW+Eo8h8ChsdDazL4Skdmktezr
         RH5eolLYRt2MewKyhqHYpNkVvNTxJMifba5xrfeH9E0gRDjmdIN8zmki7I87QuprGl1g
         dukAKBfLA8qWxE2bavtcki+tdh8ZRVGSIXBDptq4P/efte3IqCkohc5AMdEkVtK3az1e
         fMcE++eg/QVcqsLaQY9tq/WaUMsjCBhREZt+MIe1c9SIk1rmQHV/gluPaDYP0jXwyYNA
         0RGukio387+klUJiT9UW6lYlfOpGwiKtdLTf/vMDOyS/dqxigF/mtQls35XJuIXjniNp
         f45g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=RjNdbbwU;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x25sor2047071lfe.65.2019.01.31.23.05.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 23:05:52 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=RjNdbbwU;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zZ6l/FA/GUGfptSWUSsSvsPRMmY7tMc07VEVRU1/bZo=;
        b=RjNdbbwUIFJ0LwmamP5F0mU3irkYq2z0IVuzFdanXrbhj8sEB4vxYpXt3m3Fy+AB1M
         SPS0q/lXChAKZa7+XTmR/PS28WXYasFDvxUp+ubNu2T9eyNkNiPyzBdq2/uXlJ4I+rNj
         IqrPf9cFc5xriouM82L1v7b8OYmIQRv6uSAyo=
X-Google-Smtp-Source: ALg8bN69dGCX49CZzYU93FLTHfd1p9pGWzMGDIay13YF+benTXGWNcLxxKf0Ahcx5U/LsloIzTMmlA==
X-Received: by 2002:a19:d9d6:: with SMTP id s83mr30113944lfi.57.1549004751017;
        Thu, 31 Jan 2019 23:05:51 -0800 (PST)
Received: from mail-lj1-f171.google.com (mail-lj1-f171.google.com. [209.85.208.171])
        by smtp.gmail.com with ESMTPSA id d19-v6sm1140165ljc.37.2019.01.31.23.05.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 23:05:49 -0800 (PST)
Received: by mail-lj1-f171.google.com with SMTP id s5-v6so4830171ljd.12
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 23:05:49 -0800 (PST)
X-Received: by 2002:a2e:8045:: with SMTP id p5-v6mr29493803ljg.87.1549004749092;
 Thu, 31 Jan 2019 23:05:49 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-3-vbabka@suse.cz>
 <20190131095644.GR18811@dhcp22.suse.cz> <nycvar.YFH.7.76.1901311114260.6626@cbobk.fhfr.pm>
 <20190131102348.GT18811@dhcp22.suse.cz> <CAHk-=wjkiNPWb97JXV6=J6DzscB1g7moGJ6G_nSe=AEbMugTNw@mail.gmail.com>
 <20190201051355.GV6173@dastard>
In-Reply-To: <20190201051355.GV6173@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 31 Jan 2019 23:05:32 -0800
X-Gmail-Original-Message-ID: <CAHk-=wg0FXvwB09WJaZk039CfQ0hEnyES_ANE392dfsx6U8WUQ@mail.gmail.com>
Message-ID: <CAHk-=wg0FXvwB09WJaZk039CfQ0hEnyES_ANE392dfsx6U8WUQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT is
 set for the I/O
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, Jiri Kosina <jikos@kernel.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Linux API <linux-api@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
	Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, 
	Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, Cyril Hrubis <chrubis@suse.cz>, 
	Tejun Heo <tj@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Daniel Gruss <daniel@gruss.cc>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 9:16 PM Dave Chinner <david@fromorbit.com> wrote:
>
> You are conflating "best effort non-blocking operation" with
> "atomic guarantee".  RWF_NOWAIT/IOCB_NOWAIT is the
> former, not the latter.

Right.

That's my *point*, Dave.

It's not 'atomic guarantee", and never will be. We are in 100%
agreement. That's what I _said_.

And part of "best effort" is very much "not a security information leak".

I really don't see why you are so argumentative.

As I mentioned earlier in the thread, it's actually quite possible
that users will actually find that starting read-ahead is a *good*
thing, Dave.

Even - in fact *particularly* - the user you brought up: samba using
RWF_NOWAIT to try to do things synchronously quickly.

So Dave, why are you being so negative?

             Linus

