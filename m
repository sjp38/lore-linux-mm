Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8249DC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:19:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A89220896
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:19:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A89220896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8AD16B0006; Wed, 12 Jun 2019 07:19:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3AE86B0007; Wed, 12 Jun 2019 07:19:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C02A96B0008; Wed, 12 Jun 2019 07:19:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7727D6B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:19:24 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id v15so1054553wmh.1
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:19:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2DY9BNuwvWwHmPyKTH7LGXdzKvzCIaqNI7kWqlmuhvc=;
        b=qeGcWvlZMfkk5cF6xL1gnqxPJz8ZB03HE2Tj3l99FikPSp8gkmigXKWyDUZ5mZ4pja
         3G0E80Adtksti+AMAiWq9f/r3whRUufIArbs3pYj800CYeexAuDK6QQqmS99Zzb3EMqj
         0OcyI6mB/cndz/iZyqAnTEfxkGvxFx7/myvXYeR/QC2zRhOuGlNtLqTaY8xiCW03hUSh
         Qv1UwBInTCzhPKY70fUTu/JZIeavUVKXaoIpl5u3eq/V3a5ufAVRYAPfsZZhhmvQHCjw
         NmW8v3PraGX9nx7Ow9EY3E6DDPop1KoVCMRvbh+pwhJ07ayPbuhf58k3ng+OnKhXq0Ln
         zPgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWhoxIgFcmGBl65WfOceBuz1TiYsT7l4BE51Jz+zqGeiHP9+j4q
	KGRjyIVz8v2D5UBcyNxG9pC/W+1Ebvfd2CQ/JrIDr/lSBBajr6iH6c/Ffa1hNsVahJ9gKqTs3QV
	6Snn6FEZ4hEV2ZVoe5INdC8zgfgCmQSFr+NEzslYnC4MiKrP9BviuwRrngL7QIl2O0g==
X-Received: by 2002:a1c:480a:: with SMTP id v10mr21618114wma.120.1560338363932;
        Wed, 12 Jun 2019 04:19:23 -0700 (PDT)
X-Received: by 2002:a1c:480a:: with SMTP id v10mr21618048wma.120.1560338362847;
        Wed, 12 Jun 2019 04:19:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560338362; cv=none;
        d=google.com; s=arc-20160816;
        b=iLZy1rZwJaHcVt4aNQ0PzW2dZF079pWrklLXMv6KiNwAgQN+O9r9jXhWwh8pnAJIby
         027WXmPyHvBXeHS08NH3OmmSeUP46tHhpto/6nYbJf2DXDu5vxlJEAtSy/23Svr3pPhY
         7/MuICRUNdZlZNnYEf2WOkJ/wGfCiCtX4Q+rGhDrR9zuSWL9vyBvpvelaUy2Yczp3cNf
         jlH0ayfqH1M6NFukc4DTIC4ul2eDa9VCmO10QEsevWBqDpZSkEXi9MQK5FrbWktWuA2j
         UZYxyAynsg982Hp5kdGb81tSWWdgdmsR5JuWnaHXp5wN0RTrJ7+Em/i45qf29RtjgiKa
         FbyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2DY9BNuwvWwHmPyKTH7LGXdzKvzCIaqNI7kWqlmuhvc=;
        b=wLauI5UfzPgvnmB3bDq4saVKCGvFIP3N/sybVBEwZH1lGDrFVzl78DLsTy8d3pex0k
         sbz85YnOJYZ9L4nribouBumqPGh3ehy1HwPB9CzQRX1yg1pvWgfFvtjXUGvDDvMbtzoh
         tlRAnJOXHlNPw0cGZqdk7VcMvb1MjbVNvLJ1ilsjUp1sMVRrG0BoYkwa9RQqKK1Z7I4A
         aw+rcNzAsSFAtfsXgPF7MjPdew9pj7lp1t9x2TR1xrxYCNpZ9VF+uIc3SKN//VOAG8Ja
         EjMbIDhoR1gARQ1DoGFnhSewoDi+fPPAVMlI79lhSDMdH0cq7ZJ3qVrmrxSzmKzVVkiK
         Qizg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t6sor364947wrq.30.2019.06.12.04.19.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:19:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqy/37Y6CvQfxqtHse3Rk+em+nImH5GtIIV1i2YZ9vY5x/E8azVs6GhTTo5OHfW1RpK9PFD6Ig==
X-Received: by 2002:a5d:488b:: with SMTP id g11mr42236505wrq.72.1560338362423;
        Wed, 12 Jun 2019 04:19:22 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id m21sm4710436wmc.1.2019.06.12.04.19.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 04:19:21 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:19:20 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Pavel Machek <pavel@ucw.cz>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, hdanton@sina.com,
	lizeb@google.com
Subject: Re: [PATCH v2 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Message-ID: <20190612111920.evedpmre63ivnxkz@butterfly.localdomain>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190612105945.GA16442@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612105945.GA16442@amd>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 12:59:45PM +0200, Pavel Machek wrote:
> > - Problem
> > 
> > Naturally, cached apps were dominant consumers of memory on the system.
> > However, they were not significant consumers of swap even though they are
> > good candidate for swap. Under investigation, swapping out only begins
> > once the low zone watermark is hit and kswapd wakes up, but the overall
> > allocation rate in the system might trip lmkd thresholds and cause a cached
> > process to be killed(we measured performance swapping out vs. zapping the
> > memory by killing a process. Unsurprisingly, zapping is 10x times faster
> > even though we use zram which is much faster than real storage) so kill
> > from lmkd will often satisfy the high zone watermark, resulting in very
> > few pages actually being moved to swap.
> 
> Is it still faster to swap-in the application than to restart it?

It's the same type of question I was addressing earlier in the remote
KSM discussion: making applications aware of all the memory management stuff
or delegate the decision to some supervising task.

In this case, we cannot rewrite all the application to handle imaginary
SIGRESTART (or whatever you invent to handle restarts gracefully). SIGTERM
may require more memory to finish stuff to not lose your data (and I guess
you don't want to lose your data, right?), and SIGKILL is pretty much
destructive.

Offloading proactive memory management to a process that knows how to do
it allows to handle not only throwaway containers/microservices, but also
usual desktop/mobile workflow.

> > This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> > information required to make the reclaim decision is not known to the app.
> > Instead, it is known to a centralized userspace daemon, and that daemon
> > must be able to initiate reclaim on its own without any app involvement.
> > To solve the concern, this patch introduces new syscall -
> > 
> >     struct pr_madvise_param {
> >             int size;               /* the size of this structure */
> >             int cookie;             /* reserved to support atomicity */
> >             int nr_elem;            /* count of below arrary fields */
> >             int __user *hints;      /* hints for each range */
> >             /* to store result of each operation */
> >             const struct iovec __user *results;
> >             /* input address ranges */
> >             const struct iovec __user *ranges;
> >     };
> >     
> >     int process_madvise(int pidfd, struct pr_madvise_param *u_param,
> >                             unsigned long flags);
> 
> That's quite a complex interface.
> 
> Could we simply have feel_free_to_swap_out(int pid) syscall? :-).

I wonder for how long we'll go on with adding new syscalls each time we need
some amendment to existing interfaces. Yes, clone6(), I'm looking at
you :(.

In case of process_madvise() keep in mind it will be focused not only on
MADV_COLD, but also, potentially, on other MADV_ flags as well. I can
hardly imagine we'll add one syscall per each flag.

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

