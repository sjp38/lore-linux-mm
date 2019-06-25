Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61C29C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:17:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 288602085A
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:17:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="klsFVayI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 288602085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C18176B0006; Tue, 25 Jun 2019 14:17:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA0AA8E0003; Tue, 25 Jun 2019 14:17:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8F738E0002; Tue, 25 Jun 2019 14:17:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 839B96B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 14:17:53 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 75so23717600ywb.3
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:17:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gd8q8neCT5NqLNWSpySLJWRTGAUdIgC+KA84NV729mY=;
        b=jIfHYebgMyfH11Tx553PTkoI3GpKqA0PFb2Dd4fGPq4U/ur6opDaSlcyRupPldmHRv
         VLqqLqv++4GBefDUrrwm0NRW1srV5ovoFEglV8zp39RSYI99rkcSZ5zMt6JSkl/sx+ZU
         GauvOF5Egak1TzotxXtTEs/0Tj5yffMIs+0gXyOeHVO3BjEpNBqNM+uE5bxQFyOiHQVk
         Nge8CEOnRP4UJt3PvMRY0oLfXnUwezWcsiMZBm/VT9EEyt78r8DT+3G1rWDNS1WTvi5J
         GA3AVDtum3+rrK7IdHWrs17XNTH9OwmACFnRNyhmk0jjIZqHD+x0p1lBMM0r2Z0Bux/z
         euHQ==
X-Gm-Message-State: APjAAAWDoC5x9UHhlAGPjrc4IVQ/KEJCJs+C1Mh0GtXQgKSiRzpJfnhG
	eHaRx4eq8kDKSUkbSzep9pGZYwO1sc3pKXVIOL4purBD97JA+vIy3xeM7IFtvzM1pDM1xU+vCgU
	bR0y3kbhm3C/tMzt/kulI2bv/+NJkjaDe/mFi7hiZTbO8Ccqzznt/DMprjZgxdFG06Q==
X-Received: by 2002:a81:480f:: with SMTP id v15mr58629ywa.144.1561486673351;
        Tue, 25 Jun 2019 11:17:53 -0700 (PDT)
X-Received: by 2002:a81:480f:: with SMTP id v15mr58601ywa.144.1561486672841;
        Tue, 25 Jun 2019 11:17:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561486672; cv=none;
        d=google.com; s=arc-20160816;
        b=wiUQ1ZRxcpCLTta/s2EMztcas7ZgAoZzpZZe/yFH49BbIVQ+sfUbC2Cy5GGUhWQ3oG
         Buj0jxEu7qRHk0IGZ4Q1fyWgfkWpckst3PdIC4n6WjJQYmwliIysenIry4GXDGnzrPAe
         PlZ1qOwwLTiQwiv1fjWm2BJvEOIjQvrYbLAzJ/mHYeiCd6nNzQijdU7cBdKG5kuH+GvR
         WzvIcASXFPxBbUmSnLPB9CvdCSNw4+I0THl+Zkfuk9RjBlcLndO5Lq4udErFoQHYg5aH
         XQKxGLFSO9+aIK8NsOeLhQXd/zm2wHDFt710P0/OAdh3SyS6oRnWatzJzNVoId5UEyYO
         RiNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gd8q8neCT5NqLNWSpySLJWRTGAUdIgC+KA84NV729mY=;
        b=RBWKk5ptldTOg+4XSHkA12RfWJjfZD0gJlcC1LlKw6v8Rz0oggWARGgcdZH/7tangU
         T99ryAlzw8/J4hZ4jGRkBFac7c+GoSYENfJrqVmar4AiNZyPKZcHW6R/DkMe9HsbzNun
         FYB9l1E1Mw8CvZKcDKWd668nQG/dRfyLqoUYJPCmxVPvUXtYPlBM1WjsjCUCvX9hFhC2
         6b/6W7Th0vN0HPoH/K6iaqF7xjobM6eTnV/vHrCLFW0Pf8v/Ba1kaUbqe4VdtRTQh2r7
         fc5MjoKCDsaFWACPyqyR1/lbde8rA4KLpkeoKvEwVvgDMJZJgUjUw8Zh4dODnBPwz5cf
         CvRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=klsFVayI;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t65sor8060238ywa.173.2019.06.25.11.17.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 11:17:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=klsFVayI;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gd8q8neCT5NqLNWSpySLJWRTGAUdIgC+KA84NV729mY=;
        b=klsFVayIWMeB3zp53s+cnxO5MakpqSwu+FbhTn0qaAt2J28Cz+esm64Q93IABrDnNu
         sokI3N0pH2PmqCl1w3A0IP6HdmtNX4ywdBo18UR7Bo7cz8V3au0JpCDMUaxgMc6yeDLB
         vlMgFhlHZiTn9UKmTWnSprBOAjqkbl9m/u0RmyKP55ZYdyymlOtfmsLHcZ29tGPNYZ6F
         WiRfnNZ/XuN2mPbITcOveBBSo86VQVWHdiOQAgbxAMTBDKlO0ZD+yqRhrnt1vY3Sf5Zx
         SYEguYD+3ir/4pUe5Sa+mK+rD0QkKiAnZfXR1A3PB4aRhNEg4NvFaXQc+ENV7rnH8KfZ
         WYkA==
X-Google-Smtp-Source: APXvYqyVMnkA1t4NbNAV4JVhrMm4t4SwyJ72YWdgbiRiIkMwuLjLpgN9kbkazuSPnykjjIk2gg0tKuSHrLqTodgR7E8=
X-Received: by 2002:a81:3a0f:: with SMTP id h15mr66887ywa.34.1561486672366;
 Tue, 25 Jun 2019 11:17:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190611231813.3148843-1-guro@fb.com> <20190611231813.3148843-4-guro@fb.com>
In-Reply-To: <20190611231813.3148843-4-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 25 Jun 2019 11:17:41 -0700
Message-ID: <CALvZod44+GuDxXSqWOZB3uhvdxJeH+vnXevx+=iy-azv74ueqA@mail.gmail.com>
Subject: Re: [PATCH v7 03/10] mm: generalize postponed non-root kmem_cache deactivation
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Team <kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Waiman Long <longman@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 4:18 PM Roman Gushchin <guro@fb.com> wrote:
>
> Currently SLUB uses a work scheduled after an RCU grace period
> to deactivate a non-root kmem_cache. This mechanism can be reused
> for kmem_caches release, but requires generalization for SLAB
> case.
>
> Introduce kmemcg_cache_deactivate() function, which calls
> allocator-specific __kmem_cache_deactivate() and schedules
> execution of __kmem_cache_deactivate_after_rcu() with all
> necessary locks in a worker context after an rcu grace period.
>
> Here is the new calling scheme:
>   kmemcg_cache_deactivate()
>     __kmemcg_cache_deactivate()                  SLAB/SLUB-specific
>     kmemcg_rcufn()                               rcu
>       kmemcg_workfn()                            work
>         __kmemcg_cache_deactivate_after_rcu()    SLAB/SLUB-specific
>
> instead of:
>   __kmemcg_cache_deactivate()                    SLAB/SLUB-specific
>     slab_deactivate_memcg_cache_rcu_sched()      SLUB-only
>       kmemcg_rcufn()                             rcu
>         kmemcg_workfn()                          work
>           kmemcg_cache_deact_after_rcu()         SLUB-only
>
> For consistency, all allocator-specific functions start with "__".
>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

