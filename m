Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3C35C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 12:15:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66F1F217D4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 12:15:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66F1F217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 134DB6B0003; Tue, 21 May 2019 08:15:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E64B6B0006; Tue, 21 May 2019 08:15:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEF986B0007; Tue, 21 May 2019 08:15:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD5296B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 08:15:46 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 28so15015623qtw.5
        for <linux-mm@kvack.org>; Tue, 21 May 2019 05:15:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=m10K91xZiky9XuaFifpls41iCrhL5IxmkHVHI+nmI78=;
        b=AJ6DEac7m8RREgtUCYw1/7l5T5ZnTNcanMErnVO7VtVFSoe1dFeZCoutM0iLMxd885
         9Y7KjcqSZ3LHrSTpeYanlxJN2T2FtEbvltbL+QeRnprGH1NcH4SuQWHTW2WXIkiIodkM
         vNdiKx1EsfgAcU9fyusE3/+4a+jdoMDI7FUubn5tONLlDz3v8L2DlacaYjJ+GT+J3n/z
         z4Wsta5jMfHCY/duea+BgApG882NhhJm+Ssw8L9Ysanvd1rDMKswmDhLroQLD4ObYkfd
         T81HiNkYXx2Jk9UHpOM73m4W/uIOE4RFE+/KB2yDtYFKWF4mLWuPTSx9zwEHHfgA47sD
         WOqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWfb55vSfKX6lFcKGXgQtuhiz+8WTzI60yqs2EYjY9X5yl8usll
	ebrRXztCI2z7RR7kWPfdAcg6K9m51Se8RlquQbqmn6qzlMCAyFtL4CmeC/SADJdgDfS2QlqgLbx
	YmQucw1JPkL7B8MvnqrVUrAU/vPCFwiBik315XnJ4rRlV3PT6EvSuShIidl1gx3/O4A==
X-Received: by 2002:a0c:ba93:: with SMTP id x19mr706159qvf.107.1558440946535;
        Tue, 21 May 2019 05:15:46 -0700 (PDT)
X-Received: by 2002:a0c:ba93:: with SMTP id x19mr706080qvf.107.1558440945618;
        Tue, 21 May 2019 05:15:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558440945; cv=none;
        d=google.com; s=arc-20160816;
        b=lc0p3NEhGLZrxVOMKBbY2Me4JSrEQVaGfYBxFWT9fGWUX+t1kHFaImCA3ExgaeHUB1
         ILlAlJ22dQg2Ac2VlDbhN/MTB2g+jOUyFFtXLZeA6iK4nOr0uJpn1rOnTQGR2+pFUzkK
         Vo9idxuv2HjsIw0XTKdRHgaEKzELKVYbIX7nF/avw7Xktn2XeomLT1zDk5U6ETCbwNqu
         Vi7ekvp+qn7vNvd7LzEDQejriSMWVhgtxdqK1QerlMqSMXtozYcwbzsrOlGg4f+6h5/Q
         Q8DpCqDWAqd17/qXVmiHjcXnOalOxM0gosrlhpImejXz8mAVYnJNfpTenUq9d9rvaNPc
         Qveg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=m10K91xZiky9XuaFifpls41iCrhL5IxmkHVHI+nmI78=;
        b=sn1pnss8RuqIlro6ZLvKiYUGW5UUq49JuW6KazT0jSkwYMYoqIzz4til8G5et/v+AU
         ZdjElx3hbw5xvjEuZQ+Z54VT6C9st+iOl+94sgggbyGQFKxBBIn2eA0YkL769etaYL7d
         7a0CBdXDxVI5V6+WR3a1rgdK2OmJmJWNbmK8AE1787fT4ddA4hBUyoToRhmMx0g8z/YO
         4ZkRg4ouh+mMJgkS+9vpYfrG9RaUcTRhxL90+EPOfrKnUbsrWQYPYvcJ5n0vQxPI1XfV
         v/ZwDgHjFjK63Xd7Qdd5NoSbAfIc1kVbTFExoSRNhYqw9Ri02XwPE7yCf8VfeacFvpiM
         TESQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s23sor26433353qtc.5.2019.05.21.05.15.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 05:15:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxffB5wl3LjQOe5oYpjSlTb9ABOX/Diiui+Kry0FpNN5aC8sXH5lxcJbomIVigpeBr/kw6cLA==
X-Received: by 2002:ac8:2de1:: with SMTP id q30mr66863571qta.312.1558440945186;
        Tue, 21 May 2019 05:15:45 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id x3sm11330559qtk.75.2019.05.21.05.15.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 May 2019 05:15:44 -0700 (PDT)
Date: Tue, 21 May 2019 14:15:42 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Christian Brauner <christian@brauner.io>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521121542.3hfvouyynw2haail@butterfly.localdomain>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190521084158.s5wwjgewexjzrsm6@brauner.io>
 <20190521110552.GG219653@google.com>
 <20190521113029.76iopljdicymghvq@brauner.io>
 <20190521114120.GJ219653@google.com>
 <E01B155E-2FB4-4411-8725-3A3D7ADBE1D9@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <E01B155E-2FB4-4411-8725-3A3D7ADBE1D9@brauner.io>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 02:04:00PM +0200, Christian Brauner wrote:
> On May 21, 2019 1:41:20 PM GMT+02:00, Minchan Kim <minchan@kernel.org> wrote:
> >On Tue, May 21, 2019 at 01:30:32PM +0200, Christian Brauner wrote:
> >> On Tue, May 21, 2019 at 08:05:52PM +0900, Minchan Kim wrote:
> >> > On Tue, May 21, 2019 at 10:42:00AM +0200, Christian Brauner wrote:
> >> > > On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> >> > > > - Background
> >> > > > 
> >> > > > The Android terminology used for forking a new process and
> >starting an app
> >> > > > from scratch is a cold start, while resuming an existing app is
> >a hot start.
> >> > > > While we continually try to improve the performance of cold
> >starts, hot
> >> > > > starts will always be significantly less power hungry as well
> >as faster so
> >> > > > we are trying to make hot start more likely than cold start.
> >> > > > 
> >> > > > To increase hot start, Android userspace manages the order that
> >apps should
> >> > > > be killed in a process called ActivityManagerService.
> >ActivityManagerService
> >> > > > tracks every Android app or service that the user could be
> >interacting with
> >> > > > at any time and translates that into a ranked list for lmkd(low
> >memory
> >> > > > killer daemon). They are likely to be killed by lmkd if the
> >system has to
> >> > > > reclaim memory. In that sense they are similar to entries in
> >any other cache.
> >> > > > Those apps are kept alive for opportunistic performance
> >improvements but
> >> > > > those performance improvements will vary based on the memory
> >requirements of
> >> > > > individual workloads.
> >> > > > 
> >> > > > - Problem
> >> > > > 
> >> > > > Naturally, cached apps were dominant consumers of memory on the
> >system.
> >> > > > However, they were not significant consumers of swap even
> >though they are
> >> > > > good candidate for swap. Under investigation, swapping out only
> >begins
> >> > > > once the low zone watermark is hit and kswapd wakes up, but the
> >overall
> >> > > > allocation rate in the system might trip lmkd thresholds and
> >cause a cached
> >> > > > process to be killed(we measured performance swapping out vs.
> >zapping the
> >> > > > memory by killing a process. Unsurprisingly, zapping is 10x
> >times faster
> >> > > > even though we use zram which is much faster than real storage)
> >so kill
> >> > > > from lmkd will often satisfy the high zone watermark, resulting
> >in very
> >> > > > few pages actually being moved to swap.
> >> > > > 
> >> > > > - Approach
> >> > > > 
> >> > > > The approach we chose was to use a new interface to allow
> >userspace to
> >> > > > proactively reclaim entire processes by leveraging platform
> >information.
> >> > > > This allowed us to bypass the inaccuracy of the kernel’s LRUs
> >for pages
> >> > > > that are known to be cold from userspace and to avoid races
> >with lmkd
> >> > > > by reclaiming apps as soon as they entered the cached state.
> >Additionally,
> >> > > > it could provide many chances for platform to use much
> >information to
> >> > > > optimize memory efficiency.
> >> > > > 
> >> > > > IMHO we should spell it out that this patchset complements
> >MADV_WONTNEED
> >> > > > and MADV_FREE by adding non-destructive ways to gain some free
> >memory
> >> > > > space. MADV_COLD is similar to MADV_WONTNEED in a way that it
> >hints the
> >> > > > kernel that memory region is not currently needed and should be
> >reclaimed
> >> > > > immediately; MADV_COOL is similar to MADV_FREE in a way that it
> >hints the
> >> > > > kernel that memory region is not currently needed and should be
> >reclaimed
> >> > > > when memory pressure rises.
> >> > > > 
> >> > > > To achieve the goal, the patchset introduce two new options for
> >madvise.
> >> > > > One is MADV_COOL which will deactive activated pages and the
> >other is
> >> > > > MADV_COLD which will reclaim private pages instantly. These new
> >options
> >> > > > complement MADV_DONTNEED and MADV_FREE by adding
> >non-destructive ways to
> >> > > > gain some free memory space. MADV_COLD is similar to
> >MADV_DONTNEED in a way
> >> > > > that it hints the kernel that memory region is not currently
> >needed and
> >> > > > should be reclaimed immediately; MADV_COOL is similar to
> >MADV_FREE in a way
> >> > > > that it hints the kernel that memory region is not currently
> >needed and
> >> > > > should be reclaimed when memory pressure rises.
> >> > > > 
> >> > > > This approach is similar in spirit to madvise(MADV_WONTNEED),
> >but the
> >> > > > information required to make the reclaim decision is not known
> >to the app.
> >> > > > Instead, it is known to a centralized userspace daemon, and
> >that daemon
> >> > > > must be able to initiate reclaim on its own without any app
> >involvement.
> >> > > > To solve the concern, this patch introduces new syscall -
> >> > > > 
> >> > > > 	struct pr_madvise_param {
> >> > > > 		int size;
> >> > > > 		const struct iovec *vec;
> >> > > > 	}
> >> > > > 
> >> > > > 	int process_madvise(int pidfd, ssize_t nr_elem, int *behavior,
> >> > > > 				struct pr_madvise_param *restuls,
> >> > > > 				struct pr_madvise_param *ranges,
> >> > > > 				unsigned long flags);
> >> > > > 
> >> > > > The syscall get pidfd to give hints to external process and
> >provides
> >> > > > pair of result/ranges vector arguments so that it could give
> >several
> >> > > > hints to each address range all at once.
> >> > > > 
> >> > > > I guess others have different ideas about the naming of syscall
> >and options
> >> > > > so feel free to suggest better naming.
> >> > > 
> >> > > Yes, all new syscalls making use of pidfds should be named
> >> > > pidfd_<action>. So please make this pidfd_madvise.
> >> > 
> >> > I don't have any particular preference but just wondering why pidfd
> >is
> >> > so special to have it as prefix of system call name.
> >> 
> >> It's a whole new API to address processes. We already have
> >> clone(CLONE_PIDFD) and pidfd_send_signal() as you have seen since you
> >> exported pidfd_to_pid(). And we're going to have pidfd_open(). Your
> >> syscall works only with pidfds so it's tied to this api as well so it
> >> should follow the naming scheme. This also makes life easier for
> >> userspace and is consistent.
> >
> >Okay. I will change the API name at next revision.
> >Thanks.
> 
> Thanks!
> Fwiw, there's been a similar patch by Oleksandr for pidfd_madvise I stumbled upon a few days back:
> https://gitlab.com/post-factum/pf-kernel/commit/0595f874a53fa898739ac315ddf208554d9dc897
> 
> He wanted to be cc'ed but I forgot.

Thanks :).

FWIW, since this submission is essentially a continuation of our discussion
involving my earlier KSM submissions here, I won't move my gitlab branch
forward and will be happy to assist with what we have here, be it
pidfd_madvise() or a set or /proc files (or smth else).

> 
> Christian
> 

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

