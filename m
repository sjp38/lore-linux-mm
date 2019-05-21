Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AEE0C46460
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:39:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32CD321773
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:39:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="SdLWnqht"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32CD321773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C26DA6B0003; Tue, 21 May 2019 07:39:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD70C6B0006; Tue, 21 May 2019 07:39:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9EE96B0007; Tue, 21 May 2019 07:39:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 71DF16B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 07:39:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 63so11956789pga.18
        for <linux-mm@kvack.org>; Tue, 21 May 2019 04:39:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rMELqJJL8ZvhzB/8cSs6BQtnel3t9MrBMkPMUPyznmo=;
        b=ht7eosI67jeSuzHnGj9s6vGoAUo2TgJv49MpVhMt/Gl8SqPZR8TIt0zpRKAVcaaSvJ
         Uk5mvRovDtZGKiiB9qiy1yslzNB/Xerumi3Jx1PyeKL2TZu2qd9aeY+ZffdGbFrVkRwL
         X0WoEtkVDiLR6PoPY+RL+mWgMtsgkE87nE3AuQnGwMA3sB4fnfIvojXEZ04YNsN1e3Nr
         SUOPCZSMrmuiR5gRCgeJtHof7R23v5B4/dakoobkdX/AQDIFc+XD0kOCloyYRv9HguQa
         AyDFjoH+3ec7a0HwJ91QP4cwSD3ldWehLzCafuCQ8u0FIfR8T16x8QyUjd+2fZeLod9T
         pIqQ==
X-Gm-Message-State: APjAAAUH2K6BdsdnQAkLCS80HNKDGjSVq3yjCEjGGjUm5K9GfxdgFZyD
	7oGuFwU/agdXoiffoKn2W2jkZLIyto4fokqFJ73tPK7Ki/yAq3WkYZf4Asx0koacJ4kSa0vVQWb
	HumZFvbw3CKI0HqSfCFRkUnUVjHeFNzDzivJJJmAPIrbyWK1+hX+iWdeBTrlrzQCW5g==
X-Received: by 2002:a63:eb55:: with SMTP id b21mr52785078pgk.67.1558438764094;
        Tue, 21 May 2019 04:39:24 -0700 (PDT)
X-Received: by 2002:a63:eb55:: with SMTP id b21mr52785021pgk.67.1558438763283;
        Tue, 21 May 2019 04:39:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558438763; cv=none;
        d=google.com; s=arc-20160816;
        b=f6BB11Xyb3aDJNNS+LTDZup9RUHCvlwQO1dWys7z1QM1dUGfkHDi75H27wUsaC12hz
         FEHLXMcmNgjhwY6LgS8FwoYJCf5nYQBexrvZW2YcQCVHMG4oZwRWqOWNJxFyhtMyJvxY
         E7n59cCAoG1ib5RP6N25YEoYOgXsDmd6wcrdiSepGVx25ahHhBWO8a8E1ADYIPz9qu3U
         R3nrhcE7H9vuuKdZhHC598CSh5BQY1T4xYekkI/LRhoeBV/OaCMXluHQabGGBC/3+QKF
         yvkXwVhL329KZCWKRWQiWhFmjuxvOPPUysQdE5XN5zEyAcG3bx/KTm+/Ezls9o8OaV7S
         6VEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=rMELqJJL8ZvhzB/8cSs6BQtnel3t9MrBMkPMUPyznmo=;
        b=o0Uwxitn9a4CTxIYRuq5nRu0V49aU0U5OBHNcdnbd3e+DI2AIsY1Nn6uhecO09zyQf
         +Uj3PzivoLSRKtHKLv+6dPlXwoK/8s1kj+OArkIDJw4ecTwYiiQmUjlrUz8zCfqtp1v9
         si9ngg9GMl2vemr119CS0oHkedVMCeNHgeI7pmzZSA86OxIt8KETt8kwewdkDERHYHwm
         8V4r8ImYvdorcPC94tiYrcXKmY0WzJCFp+c720joP9GqM5GlumnsuPXLL06v9drxHu0J
         rhs1iGIuAX5O6NxguwA9npOvh/5112eyefUrlsn2bZ6G2Ig6vAKMo8+++X8L+zONp3fI
         nfXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=SdLWnqht;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.41 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c12sor14567108pgq.20.2019.05.21.04.39.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 04:39:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=SdLWnqht;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.41 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=rMELqJJL8ZvhzB/8cSs6BQtnel3t9MrBMkPMUPyznmo=;
        b=SdLWnqht52B7OyRuEON7GO5cjkx9YeJP66M6ScLRWshZWL/JYyRN1lFyS40hdy0MJ7
         n9ExXWXHib1zZMYNbdFrZEN53orV+OYjDbpw7JDnMP01MXEX7G1yHjFhrDXQ4Eb8z2zM
         FL6+EPWF0kR5pyFdpwGT/HWLd/PPTM3s4egkFIwajYeHoecTV3ILXHJjAszQtPt1HiO1
         h9WIme+Dsrb2+2sHBUKk4xvGdXL9gP4yx1/IfCzd8LH0R1nwWc5O8eotAs3ljXarhHfx
         +4ZZisu2cFZzAXmblk9zr1p68VDSVl31TX+9SlqeSpKAK2QmEwJpG3NZuMQYgq+LEtRS
         cGug==
X-Google-Smtp-Source: APXvYqx0c0fKttsWZt0IdW2QrLYIQNUSw5ol3x3/F1gUtr6E6B5iBHc/ImczvzmHNxcnr7K3JVzAhg==
X-Received: by 2002:a63:4a5a:: with SMTP id j26mr79262796pgl.361.1558438762842;
        Tue, 21 May 2019 04:39:22 -0700 (PDT)
Received: from brauner.io ([208.54.39.182])
        by smtp.gmail.com with ESMTPSA id u123sm35572404pfu.67.2019.05.21.04.39.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 04:39:22 -0700 (PDT)
Date: Tue, 21 May 2019 13:39:13 +0200
From: Christian Brauner <christian@brauner.io>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
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
Message-ID: <20190521113911.2rypoh7uniuri2bj@brauner.io>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190521084158.s5wwjgewexjzrsm6@brauner.io>
 <20190521110552.GG219653@google.com>
 <20190521113029.76iopljdicymghvq@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190521113029.76iopljdicymghvq@brauner.io>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:30:29PM +0200, Christian Brauner wrote:
> On Tue, May 21, 2019 at 08:05:52PM +0900, Minchan Kim wrote:
> > On Tue, May 21, 2019 at 10:42:00AM +0200, Christian Brauner wrote:
> > > On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> > > > - Background
> > > > 
> > > > The Android terminology used for forking a new process and starting an app
> > > > from scratch is a cold start, while resuming an existing app is a hot start.
> > > > While we continually try to improve the performance of cold starts, hot
> > > > starts will always be significantly less power hungry as well as faster so
> > > > we are trying to make hot start more likely than cold start.
> > > > 
> > > > To increase hot start, Android userspace manages the order that apps should
> > > > be killed in a process called ActivityManagerService. ActivityManagerService
> > > > tracks every Android app or service that the user could be interacting with
> > > > at any time and translates that into a ranked list for lmkd(low memory
> > > > killer daemon). They are likely to be killed by lmkd if the system has to
> > > > reclaim memory. In that sense they are similar to entries in any other cache.
> > > > Those apps are kept alive for opportunistic performance improvements but
> > > > those performance improvements will vary based on the memory requirements of
> > > > individual workloads.
> > > > 
> > > > - Problem
> > > > 
> > > > Naturally, cached apps were dominant consumers of memory on the system.
> > > > However, they were not significant consumers of swap even though they are
> > > > good candidate for swap. Under investigation, swapping out only begins
> > > > once the low zone watermark is hit and kswapd wakes up, but the overall
> > > > allocation rate in the system might trip lmkd thresholds and cause a cached
> > > > process to be killed(we measured performance swapping out vs. zapping the
> > > > memory by killing a process. Unsurprisingly, zapping is 10x times faster
> > > > even though we use zram which is much faster than real storage) so kill
> > > > from lmkd will often satisfy the high zone watermark, resulting in very
> > > > few pages actually being moved to swap.
> > > > 
> > > > - Approach
> > > > 
> > > > The approach we chose was to use a new interface to allow userspace to
> > > > proactively reclaim entire processes by leveraging platform information.
> > > > This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> > > > that are known to be cold from userspace and to avoid races with lmkd
> > > > by reclaiming apps as soon as they entered the cached state. Additionally,
> > > > it could provide many chances for platform to use much information to
> > > > optimize memory efficiency.
> > > > 
> > > > IMHO we should spell it out that this patchset complements MADV_WONTNEED
> > > > and MADV_FREE by adding non-destructive ways to gain some free memory
> > > > space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> > > > kernel that memory region is not currently needed and should be reclaimed
> > > > immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> > > > kernel that memory region is not currently needed and should be reclaimed
> > > > when memory pressure rises.
> > > > 
> > > > To achieve the goal, the patchset introduce two new options for madvise.
> > > > One is MADV_COOL which will deactive activated pages and the other is
> > > > MADV_COLD which will reclaim private pages instantly. These new options
> > > > complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
> > > > gain some free memory space. MADV_COLD is similar to MADV_DONTNEED in a way
> > > > that it hints the kernel that memory region is not currently needed and
> > > > should be reclaimed immediately; MADV_COOL is similar to MADV_FREE in a way
> > > > that it hints the kernel that memory region is not currently needed and
> > > > should be reclaimed when memory pressure rises.
> > > > 
> > > > This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> > > > information required to make the reclaim decision is not known to the app.
> > > > Instead, it is known to a centralized userspace daemon, and that daemon
> > > > must be able to initiate reclaim on its own without any app involvement.
> > > > To solve the concern, this patch introduces new syscall -
> > > > 
> > > > 	struct pr_madvise_param {
> > > > 		int size;
> > > > 		const struct iovec *vec;
> > > > 	}
> > > > 
> > > > 	int process_madvise(int pidfd, ssize_t nr_elem, int *behavior,
> > > > 				struct pr_madvise_param *restuls,
> > > > 				struct pr_madvise_param *ranges,
> > > > 				unsigned long flags);
> > > > 
> > > > The syscall get pidfd to give hints to external process and provides
> > > > pair of result/ranges vector arguments so that it could give several
> > > > hints to each address range all at once.
> > > > 
> > > > I guess others have different ideas about the naming of syscall and options
> > > > so feel free to suggest better naming.
> > > 
> > > Yes, all new syscalls making use of pidfds should be named
> > > pidfd_<action>. So please make this pidfd_madvise.
> > 
> > I don't have any particular preference but just wondering why pidfd is
> > so special to have it as prefix of system call name.
> 
> It's a whole new API to address processes. We already have
> clone(CLONE_PIDFD) and pidfd_send_signal() as you have seen since you
> exported pidfd_to_pid(). And we're going to have pidfd_open(). Your
> syscall works only with pidfds so it's tied to this api as well so it
> should follow the naming scheme. This also makes life easier for
> userspace and is consistent.

This is at least my reasoning. I'm not going to make this a whole big
pedantic argument. If people have really strong feelings about not using
this prefix then fine. But if syscalls can be grouped together and have
consistent naming this is always a big plus.

