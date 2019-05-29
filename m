Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84D01C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:33:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 440E120B1F
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:33:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 440E120B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C75DA6B000A; Wed, 29 May 2019 06:33:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C27106B000C; Wed, 29 May 2019 06:33:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B16496B0010; Wed, 29 May 2019 06:33:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 62EF16B000A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 06:33:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y22so2765372eds.14
        for <linux-mm@kvack.org>; Wed, 29 May 2019 03:33:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xolAKlBezUbmnetCTkhctm9MYKTMqvSgH6NVZFIF5So=;
        b=qiTGMzhYN4cwtM41NOZPdh5KDioezMgH40ww03+X0FF4E0kQmVthbQsjZsFZ9Iy1Su
         8L/r0ZYXn+HdWJ1Rw5LfpPAN07CmFx9XKksfAx3hop4pFjTm7xp6wMNAsvZTm3z1oj1J
         C5TvOzGFgbcrZ24rQ3kQuuB5uTCDE2AdC/wQGmDLMbFuNLkOIf5OyWwhM+uqhnFMX6hl
         WuHBObQx2aR+4mqUFVNqaAT+pKz3J6hvi9UjtIufTblDDESkltGvT6JjLhmihcGfijWz
         fhtjHVUdn9xHNoKVHgok23cK7IQNRoR/jcf3n+QbYQT5uahMmZfMbOyjyLZQp30vMANC
         OIkg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXrdFRCbHWE9SSamewFJwrrLKTzF1Ow6ml2cSK0ddYdXFwifxja
	7gY5avyXr/Go3ac5a/qCiLdZQzvlwulRXpCaa7yyooNfkpguhNLZx9Lk8AyU7Uy0LlSKCJLUvJT
	7siMrs9LCdja9dkIdeaX36s8BKXuk3WejqzqbDxSJCVA5LQVzimynpRtXNmMTiww=
X-Received: by 2002:a17:906:2acf:: with SMTP id m15mr90766529eje.31.1559126035867;
        Wed, 29 May 2019 03:33:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKvqbg6hNUuzuBYYmSDkCkbraSIPTPBYjAtjY8O/NBMCBqJnGyEltSuzXxjtT6ZB64AEuJ
X-Received: by 2002:a17:906:2acf:: with SMTP id m15mr90766460eje.31.1559126034816;
        Wed, 29 May 2019 03:33:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559126034; cv=none;
        d=google.com; s=arc-20160816;
        b=EjQDUf+8upbeyhOyDjeoWN+DDcgwxr75WRUou9oEzGHlKIEZl7QPC0AtT2DrpVY5ih
         rsmA1zAJNmkSXlDbedIMOoIWJDhnx6NlVPzlE2zp0oWcOCHHgIaFbMvZrXak1kTtCcWe
         xr3+mATaBiXDONcQOxEaVVnGQLrAQsXZ3WUEtXYBQm9NzAIsx2tl3Gkwm63jSmUJWx8d
         3++e+bBtBTxzpOCgiLUJrphKdruwEl6+Tt5NXEia7QOT8cELvVb7tJs5MbH/oSJ0Lj3e
         iogplwrGr5EF2g5dG2JtjJZ5A8Dx90xk27cd/Vqch10/+pXZvTEY6LLuR30gFWtH/6p5
         gawg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xolAKlBezUbmnetCTkhctm9MYKTMqvSgH6NVZFIF5So=;
        b=L56/7ImxyuboLxu6RNNVBAysWjfsHe5qNS8aOBR9d/w5illuaph3Kv2sJdIPY/H45F
         bhxZj8+bVqst1rgA+/tWr42tozD/W4zD+Kg6/6eXwFy5n/0U3la1gx026wd4YxFxd2+Z
         chqmeovh3WB9HbUlIhOMzX4VIyfXIFE2HXuMsib5F2R2kMpKg6gbhjP2nzWNdQBl1F3C
         CZx+tSr/+d2hr5e8L/02/RpM7p/wqworVZKkzc6Cbz5IGCUC6HJzVnWxLplVjBgBhCWO
         alznQaz6VdHfJcB+h/gDadN49fW0CyQIXUMR7YDDaBBF/h7VQ8vCwbjs4cXrrGje29tf
         T2JA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g4si1001374ejw.305.2019.05.29.03.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 03:33:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 50483AC40;
	Wed, 29 May 2019 10:33:54 +0000 (UTC)
Date: Wed, 29 May 2019 12:33:52 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Daniel Colascione <dancol@google.com>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector
 arrary
Message-ID: <20190529103352.GD18589@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-7-minchan@kernel.org>
 <20190520092258.GZ6836@dhcp22.suse.cz>
 <20190521024820.GG10039@google.com>
 <20190521062421.GD32329@dhcp22.suse.cz>
 <20190521102613.GC219653@google.com>
 <20190521103726.GM32329@dhcp22.suse.cz>
 <20190527074940.GB6879@google.com>
 <CAKOZuesK-8zrm1zua4dzqh4TEMivsZKiccySMvfBjOyDkg-MEw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuesK-8zrm1zua4dzqh4TEMivsZKiccySMvfBjOyDkg-MEw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 29-05-19 03:08:32, Daniel Colascione wrote:
> On Mon, May 27, 2019 at 12:49 AM Minchan Kim <minchan@kernel.org> wrote:
> >
> > On Tue, May 21, 2019 at 12:37:26PM +0200, Michal Hocko wrote:
> > > On Tue 21-05-19 19:26:13, Minchan Kim wrote:
> > > > On Tue, May 21, 2019 at 08:24:21AM +0200, Michal Hocko wrote:
> > > > > On Tue 21-05-19 11:48:20, Minchan Kim wrote:
> > > > > > On Mon, May 20, 2019 at 11:22:58AM +0200, Michal Hocko wrote:
> > > > > > > [Cc linux-api]
> > > > > > >
> > > > > > > On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> > > > > > > > Currently, process_madvise syscall works for only one address range
> > > > > > > > so user should call the syscall several times to give hints to
> > > > > > > > multiple address range.
> > > > > > >
> > > > > > > Is that a problem? How big of a problem? Any numbers?
> > > > > >
> > > > > > We easily have 2000+ vma so it's not trivial overhead. I will come up
> > > > > > with number in the description at respin.
> > > > >
> > > > > Does this really have to be a fast operation? I would expect the monitor
> > > > > is by no means a fast path. The system call overhead is not what it used
> > > > > to be, sigh, but still for something that is not a hot path it should be
> > > > > tolerable, especially when the whole operation is quite expensive on its
> > > > > own (wrt. the syscall entry/exit).
> > > >
> > > > What's different with process_vm_[readv|writev] and vmsplice?
> > > > If the range needed to be covered is a lot, vector operation makes senese
> > > > to me.
> > >
> > > I am not saying that the vector API is wrong. All I am trying to say is
> > > that the benefit is not really clear so far. If you want to push it
> > > through then you should better get some supporting data.
> >
> > I measured 1000 madvise syscall vs. a vector range syscall with 1000
> > ranges on ARM64 mordern device. Even though I saw 15% improvement but
> > absoluate gain is just 1ms so I don't think it's worth to support.
> > I will drop vector support at next revision.
> 
> Please do keep the vector support. Absolute timing is misleading,
> since in a tight loop, you're not going to contend on mmap_sem. We've
> seen tons of improvements in things like camera start come from
> coalescing mprotect calls, with the gains coming from taking and
> releasing various locks a lot less often and bouncing around less on
> the contended lock paths. Raw throughput doesn't tell the whole story,
> especially on mobile.

This will always be a double edge sword. Taking a lock for longer can
improve a throughput of a single call but it would make a latency for
anybody contending on the lock much worse.

Besides that, please do not overcomplicate the thing from the early
beginning please. Let's start with a simple and well defined remote
madvise alternative first and build a vector API on top with some
numbers based on _real_ workloads.
-- 
Michal Hocko
SUSE Labs

