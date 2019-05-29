Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6EA2C28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:08:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DA6D21670
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:08:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XvJCcOWl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DA6D21670
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 277396B026A; Wed, 29 May 2019 06:08:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22A4D6B026B; Wed, 29 May 2019 06:08:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 117036B026C; Wed, 29 May 2019 06:08:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2C326B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 06:08:45 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id v4so278617vsl.4
        for <linux-mm@kvack.org>; Wed, 29 May 2019 03:08:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JqrLgxA4AciEivrwCOum3XhYhFc14FWOXrSGbHtn8l4=;
        b=F3/pnbB25C26+TzLBDgb5NvHDoeRi6937XME+a4Utchvr7DbqZyoHkmF/ul8wnV79o
         TQW4GuQ0EkeP7CF8h/tcFBiifdaTc0MNX2Hvt4tLQK0vyN1bbntLFM5vvQkaQh9G8eB2
         L0nVk3Crsh7IlQ2XMl0Y0aD7/ObpG4m/+ACRwBJzj8dqzThJ76xoFh2T1Qnvfih14JSt
         y/lIw7UhJbl1PkTC8BYAdDyDA8Uo5ZxapsBurScpJD+Wzb/YBozOV6CUNn8JxmC4SVgv
         Hd1iz6y3C6BaLPfHPnm4NGnQFMrH/uKgmv1ZImB8MZxmhpnUL4Tb4FxVa2aXkNTFhdCd
         HXhA==
X-Gm-Message-State: APjAAAX73SXNAQsQNxLYc27U+iMOdRFxhz3e4MyEGD7g4tZaJgypQXpE
	9kErJKGzUK+1kTumHkq0GJaXu/x8RGkjRmvkJLSX7XrYELSxXb2UKaYi9N1TPPs1zkU4SNJEXIN
	F24ITpjxc8fippMAPVJ6q+3lM+xUvfWag1QTjrsPmMvaeroxH2yLdH7kPXssN030fDA==
X-Received: by 2002:a67:d68e:: with SMTP id o14mr46880942vsj.140.1559124525579;
        Wed, 29 May 2019 03:08:45 -0700 (PDT)
X-Received: by 2002:a67:d68e:: with SMTP id o14mr46880895vsj.140.1559124524553;
        Wed, 29 May 2019 03:08:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559124524; cv=none;
        d=google.com; s=arc-20160816;
        b=zasjQ3JevfjPejcQXRVgk2/EtITmd5YVxUFO9bdterIHPAirSUJ2VTaYis+4vVQUBr
         A7pXVpkfJcljEqYm8zr8bdlHGc6EDKd2QgQKYb7iQozM9sB4bZFtnvZBCykOiQ62GwM0
         ZyZOdNJpgHaUhgvPxy8ooYhEsbKW3g++WePPXWHTDQONQuhqaldy6z/KzQhTEhtDu8hY
         WD5HficgBDxbhHbeZMO6MLjpkMWkOGKgXjTdLFtoRb4QnQB+jZfKALQvwziKQk1cKAqi
         U75xv5GOabiJAZAkGlcNDTakCfWNwfrI1abPluIo3n8yChY7PEvxAb5C+3dkUSGQ5aoM
         o0dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JqrLgxA4AciEivrwCOum3XhYhFc14FWOXrSGbHtn8l4=;
        b=UQB1mO8hVk3hdYDfQt/iScwz7ZZOhW9eJFNopoxhv3NMsgWECDP2SXQTUXfESAeVHS
         6zInkiv7Alt2IcLTS4nEHCFFGA9m5QOD/iwtUStnpTzc4JAXVpP4q9asAFwEFd409f0u
         zTeaB7lZQQwlmrHuhr/tyDuV3VVRJykiZAHrV50V/Gc69AJBBnsryKXmqdsMyAx8Lwi0
         gGCO553/lxA0aOYUuCLlj7gI1e4rT9EfacpZ8AousLS73kQC1ycbcTNM9wv9UoeOHEvf
         f+dUoF3iVNUD30Rajh9dUTkceKX6V9MB62pdC4nfeacmtUdqpkXP8uJd3pP4gZoumA4J
         oWBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XvJCcOWl;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y23sor6846621vsk.1.2019.05.29.03.08.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 03:08:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XvJCcOWl;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JqrLgxA4AciEivrwCOum3XhYhFc14FWOXrSGbHtn8l4=;
        b=XvJCcOWlfI2cAhepwsVATWYEeMXjuPGe36MHEYZY73iUGWkDtfiutI6POmJ9WBgnS5
         7Zc+MH34Bcng8GBK5pAcN4+/ymPXCE+cXwGYB27pb6fpcm7JJpWRObHmiVtzA72kO7Vt
         9+YOcI2Zw1oJR4UQfSqS3YY8SCLdrxar3eA2YXi5fviMqALw30QBbOqvt5re4j9bK06T
         MxXx7a5LVP5i0xbfny+YkspK2cwfOCnZBTAt3WnFtwFkd4xGRcuYSn0qZjjDGgjxXAFp
         q1ZvaHN3BjJcwWhnr0OVqYGhnNyVRVJJJjOo2VP9Y1mgoPIvFrPK79bYI9MyJL/gQWXB
         lB1w==
X-Google-Smtp-Source: APXvYqzSCE0z59kl4Upmp3wn1FWiwFbydqjXU+SBtt9efM9Z8jZQTMXLALdpKllyD+vumjd3lYW8613GvLhWpIBE3/g=
X-Received: by 2002:a67:e90f:: with SMTP id c15mr3517797vso.9.1559124523923;
 Wed, 29 May 2019 03:08:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190520035254.57579-1-minchan@kernel.org> <20190520035254.57579-7-minchan@kernel.org>
 <20190520092258.GZ6836@dhcp22.suse.cz> <20190521024820.GG10039@google.com>
 <20190521062421.GD32329@dhcp22.suse.cz> <20190521102613.GC219653@google.com>
 <20190521103726.GM32329@dhcp22.suse.cz> <20190527074940.GB6879@google.com>
In-Reply-To: <20190527074940.GB6879@google.com>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 29 May 2019 03:08:32 -0700
Message-ID: <CAKOZuesK-8zrm1zua4dzqh4TEMivsZKiccySMvfBjOyDkg-MEw@mail.gmail.com>
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector arrary
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 12:49 AM Minchan Kim <minchan@kernel.org> wrote:
>
> On Tue, May 21, 2019 at 12:37:26PM +0200, Michal Hocko wrote:
> > On Tue 21-05-19 19:26:13, Minchan Kim wrote:
> > > On Tue, May 21, 2019 at 08:24:21AM +0200, Michal Hocko wrote:
> > > > On Tue 21-05-19 11:48:20, Minchan Kim wrote:
> > > > > On Mon, May 20, 2019 at 11:22:58AM +0200, Michal Hocko wrote:
> > > > > > [Cc linux-api]
> > > > > >
> > > > > > On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> > > > > > > Currently, process_madvise syscall works for only one address range
> > > > > > > so user should call the syscall several times to give hints to
> > > > > > > multiple address range.
> > > > > >
> > > > > > Is that a problem? How big of a problem? Any numbers?
> > > > >
> > > > > We easily have 2000+ vma so it's not trivial overhead. I will come up
> > > > > with number in the description at respin.
> > > >
> > > > Does this really have to be a fast operation? I would expect the monitor
> > > > is by no means a fast path. The system call overhead is not what it used
> > > > to be, sigh, but still for something that is not a hot path it should be
> > > > tolerable, especially when the whole operation is quite expensive on its
> > > > own (wrt. the syscall entry/exit).
> > >
> > > What's different with process_vm_[readv|writev] and vmsplice?
> > > If the range needed to be covered is a lot, vector operation makes senese
> > > to me.
> >
> > I am not saying that the vector API is wrong. All I am trying to say is
> > that the benefit is not really clear so far. If you want to push it
> > through then you should better get some supporting data.
>
> I measured 1000 madvise syscall vs. a vector range syscall with 1000
> ranges on ARM64 mordern device. Even though I saw 15% improvement but
> absoluate gain is just 1ms so I don't think it's worth to support.
> I will drop vector support at next revision.

Please do keep the vector support. Absolute timing is misleading,
since in a tight loop, you're not going to contend on mmap_sem. We've
seen tons of improvements in things like camera start come from
coalescing mprotect calls, with the gains coming from taking and
releasing various locks a lot less often and bouncing around less on
the contended lock paths. Raw throughput doesn't tell the whole story,
especially on mobile.

