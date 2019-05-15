Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 794E3C46460
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 06:25:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B5FA2084F
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 06:25:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B5FA2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 766E16B0005; Wed, 15 May 2019 02:25:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 717FD6B0006; Wed, 15 May 2019 02:25:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DF476B0007; Wed, 15 May 2019 02:25:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 120806B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 02:25:28 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id r195so411056wmf.8
        for <linux-mm@kvack.org>; Tue, 14 May 2019 23:25:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uH/Ak+qwpv4XA3p578BfJ9QI58tlfVBtU336J8yg4yM=;
        b=LMDw+I0OvO/PanpOLEpkZt2sOlXivNpSHn/Dv8pVQ7/TSaZG9aoQ9I0RkIrHuLzBJm
         6bswk0pvLnAw8+qylrQ82pPaLKWG97Ug3civzSA/yg8E4SCuoJyzryu8a9mA6ls0TqJi
         4ghGZ/Lt8+ZnZeyL/FBZ5qBdjTl05jN8huWcBc30ZGqRN6mlEXb2nKX/fGBTy0d+amx9
         e9+X5TOHA4aPFuoH70tlIFL76JzMM3qX/ua4C7GoKQp19ponXTvC97/b7r8iSDMLgpzQ
         XB2cpRbk6CnugTjC+CvemBIDiFwoN0oKUb/Q/eLdaA56cydvyUCXpZtDvuVzjQ1V+tPD
         gIlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXYS6MSJmlg1U7WQz2Xs0bZaLCqiHXcSJSqemP1zFkeeSLYchm7
	rfnTdoLDDJouiy0FPF0xLq7VmYuEkwV/nZdv5sk+NzmFKWrkQP4r9dlabDZ6Z4anjzfjENEt4ax
	j232Xjo5Fd8qKxnuEKbFlBAazrAo5/j/Zf5EM1JqCzetNOfIggqA7s18L/haniLne1g==
X-Received: by 2002:a1c:e912:: with SMTP id q18mr21405695wmc.137.1557901527442;
        Tue, 14 May 2019 23:25:27 -0700 (PDT)
X-Received: by 2002:a1c:e912:: with SMTP id q18mr21405641wmc.137.1557901526244;
        Tue, 14 May 2019 23:25:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557901526; cv=none;
        d=google.com; s=arc-20160816;
        b=qqeTh0RhB9uukZOgfL/5Hq62+KhrbGRcPsUCe/EXT2/vG+6IeMTzlEd1oDmayB4/YS
         8M+p0WfqvejmRx7WVPN5iG+9KtKzJ5CrR/7z/daHxTqGaTL9Nmv6oKMtm87mTNE0qgrt
         XsRZ/ULbBf71YtebP5Aj7OreYDi1o9O5TTC0H7E8X9s5Mu89+v5ODFIukNxs8DcrdIm8
         a4UTOVBKty4HR6ziPJDZMsPd6t1/5AjMOcx7z2gFT0+tXXfL46+Lh6GBGECiZgIubztd
         m3lOlJ+2yya8GB4WfSFqmcMHPBVcLhoSj5zCFSplKywuKP8Y9UzQA7KQ+HtSVlD2DgD0
         SPug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uH/Ak+qwpv4XA3p578BfJ9QI58tlfVBtU336J8yg4yM=;
        b=ZlcoA7TQPgKZXaZYMtlUMQPZWp6n22cW/FGFKc/ffZHDrXoPl6rQopPPjkHyFPUZOv
         2Ck7quQJkcC39pPTBWyHga2BVIIH6l2hUzjoDyXDRaxnMeeO1on7wxQeG2DYkDqG7pXt
         r0gddUmZRWa5hDy6Rst6cXULVnThgX/XYehzHdF6FRJVDtVHiPts+lQLrAKVifg07UH7
         dd2B7Nsz1yEl88Etrv/13cv3sMDkh2ULNobcOnpbYH54+6mFZPi/Yt0cGGFNTnsBrYSr
         B5dvlTHM/ldgC2+tTYrzpGhcH44TMLr43rZqAwO0FOgcZOU4FygZG9R42LxdWjOmVO7r
         Jgxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d14sor739854wrj.39.2019.05.14.23.25.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 23:25:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqy9N7PjZcstz8RL5u6WAhk+/8CIFxxZEJZhgG68v3OBGcUpeITTrUhLlcoCe1EHcGvB93LMWQ==
X-Received: by 2002:adf:b6a5:: with SMTP id j37mr20768030wre.4.1557901525798;
        Tue, 14 May 2019 23:25:25 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id o6sm1390076wrh.55.2019.05.14.23.25.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 23:25:25 -0700 (PDT)
Date: Wed, 15 May 2019 08:25:23 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190515062523.5ndf7obzfgugilfs@butterfly.localdomain>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514144105.GF4683@dhcp22.suse.cz>
 <20190514145122.GG4683@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514145122.GG4683@dhcp22.suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Tue, May 14, 2019 at 04:51:22PM +0200, Michal Hocko wrote:
> [Forgot Hugh]
> 
> On Tue 14-05-19 16:41:05, Michal Hocko wrote:
> > [This is adding a new user visible interface so you should be CCing
> > linux-api mailing list. Also CC Hugh for KSM in general. Done now]

Right, thanks for taking care of this.

> > On Tue 14-05-19 15:16:50, Oleksandr Natalenko wrote:
> > > By default, KSM works only on memory that is marked by madvise(). And the
> > > only way to get around that is to either:
> > > 
> > >   * use LD_PRELOAD; or
> > >   * patch the kernel with something like UKSM or PKSM.
> > > 
> > > Instead, lets implement a sysfs knob, which allows marking VMAs as
> > > mergeable. This can be used manually on some task in question or by some
> > > small userspace helper daemon.
> > > 
> > > The knob is named "force_madvise", and it is write-only. It accepts a PID
> > > to act on. To mark the VMAs as mergeable, use:
> > > 
> > >    # echo PID > /sys/kernel/mm/ksm/force_madvise
> > > 
> > > To unmerge all the VMAs, use the same approach, prepending the PID with
> > > the "minus" sign:
> > > 
> > >    # echo -PID > /sys/kernel/mm/ksm/force_madvise
> > > 
> > > This patchset is based on earlier Timofey's submission [1], but it doesn't
> > > use dedicated kthread to walk through the list of tasks/VMAs. Instead,
> > > it is up to userspace to traverse all the tasks in /proc if needed.
> > > 
> > > The previous suggestion [2] was based on amending do_anonymous_page()
> > > handler to implement fully automatic mode, but this approach was
> > > incorrect due to improper locking and not desired due to excessive
> > > complexity.
> > > 
> > > The current approach just implements minimal interface and leaves the
> > > decision on how and when to act to userspace.
> > 
> > Please make sure to describe a usecase that warrants adding a new
> > interface we have to maintain for ever.

I think of two major consumers of this interface:

1) hosts, that run containers, especially similar ones and especially in
a trusted environment;

2) heavy applications, that can be run in multiple instances, not
limited to opensource ones like Firefox, but also those that cannot be
modified.

I'll add this justification to the cover letter once I send another
iteration of this submission if necessary.

Thank you.

> > 
> > > 
> > > Thanks.
> > > 
> > > [1] https://lore.kernel.org/patchwork/patch/1012142/
> > > [2] http://lkml.iu.edu/hypermail/linux/kernel/1905.1/02417.html
> > > 
> > > Oleksandr Natalenko (4):
> > >   mm/ksm: introduce ksm_enter() helper
> > >   mm/ksm: introduce ksm_leave() helper
> > >   mm/ksm: introduce force_madvise knob
> > >   mm/ksm: add force merging/unmerging documentation
> > > 
> > >  Documentation/admin-guide/mm/ksm.rst |  11 ++
> > >  mm/ksm.c                             | 160 +++++++++++++++++++++------
> > >  2 files changed, 137 insertions(+), 34 deletions(-)
> > > 
> > > -- 
> > > 2.21.0
> > > 
> > 
> > -- 
> > Michal Hocko
> > SUSE Labs
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

