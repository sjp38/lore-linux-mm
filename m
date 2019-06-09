Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55B6EC28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 12:23:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DD89208E4
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 12:23:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CR31kyMK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DD89208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AD0C6B000A; Sun,  9 Jun 2019 08:23:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9357C6B000C; Sun,  9 Jun 2019 08:23:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 824566B000D; Sun,  9 Jun 2019 08:23:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9FB6B000A
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 08:23:40 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 9so761566ljv.14
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 05:23:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=iFbsAteAWCOB8EYWVkTmBCNQWQgWWukwnbyxrLkrB0g=;
        b=quAogtFi0BNlEEnd3UtxuH7WncGgnFm/k+HrClxn87EaXQ6+BJaY+JmF3d5BRXglqo
         dDyTffrSC66m+zMCitkBdpMSjZJxRLim35faFPHvLXUvHUGY0MQsK6FA/WlGZqfiheAy
         /iplawT6sPGJAOjIoPrBbAFUfOxC6ZGRQek7ZnBzlv9Q9nn/kKaggHl3wSVOXMl42w9T
         VMg5l7jWo9iR2xS5F2635SbMtW5fnR85/C49cg8Bjn3in7NyZ8koTUUrz2dNgegSfryV
         Xe9Ij6uzilPgG29m4+FXJ7DhaV2kklD63kEDpW28oHR6LbvpiKFrvoHRKN4gRWBGWIDV
         9ZQg==
X-Gm-Message-State: APjAAAUh0joFMMqS0gq6YkWXLtgR+6MJvVR7Bzz0ixXDV6R8AXO+5c18
	rsMyf7FDgwKLHPnILbfp/GEPvJTUbGXrWgFy21bP36x2xtbbrRG1gJfM1J/RIzdT/WKtHoQr8tu
	mqT1+3mqQJg1i1bCvsRu0hSXssFI+I9a2eVCI04FEsTzEkN9ZRtjISb+Aa/leg0ArNA==
X-Received: by 2002:ac2:4c84:: with SMTP id d4mr31325946lfl.1.1560083019378;
        Sun, 09 Jun 2019 05:23:39 -0700 (PDT)
X-Received: by 2002:ac2:4c84:: with SMTP id d4mr31325927lfl.1.1560083018612;
        Sun, 09 Jun 2019 05:23:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560083018; cv=none;
        d=google.com; s=arc-20160816;
        b=0L09c215jxzmMLI8OwyiZNZp4KHM2x7XhXoxccDtO2Wkbj4BybBssNqJBoECjxdJDH
         wWAvi9XNufABrBv0zCK0xlVMl8WeeB4+tP1T8/xhzf2m+tKs7Wcg7gPyJ7jJ0jXnvkMT
         wRvC+IoF6WYA95lErsLzZHiik/sYqK6Wk5f8fXkULV3C30upkE6Hv/ZGqFvwIJmTv1ul
         3CWOqNk5XoZIPjYeC/rgpXFyjuChC3Gy2I3RUi5LZP2IDy0MZXo0q2pDNEJ009bTIzj1
         AHkfVPJYGjFYkHbQv07Guq1NJxkuQWqbbgErPFA1UBPrvYQ5qI6MJiMT6lHpl5AS78bN
         545A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=iFbsAteAWCOB8EYWVkTmBCNQWQgWWukwnbyxrLkrB0g=;
        b=WR4q2f6fHXqeW9cRU6zLMop1l9uyF0Thj+UMKOqOPmbs0TyThN5M1csvCypOoJ11FS
         gMQNCO3gMXQNVjnJadK52lJ/LRWF9X8nf6oV7+ndv88PvSL0TmHspLuhkWJBcw4bHR1/
         PkZMKeJaXHNh5OcWDRjjdFneZr9y2W0W5wV7KFLc1mX1gHtI4O46eyLWio2mRbI/IXBG
         +ktiob8O68gT7svTn/DFdmkMQl3ItZWJkb3PPIU95cgk6Pbj2HnsIf6+u0aEXjGsHan1
         rhtmhKtHXVz5drf8qqn/F1uxZMsY1ZbNAj2kevpDitjmxH6eKNh3tv8/a3vB+ai9Nwuf
         IDpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CR31kyMK;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5sor712393lja.9.2019.06.09.05.23.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 05:23:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CR31kyMK;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=iFbsAteAWCOB8EYWVkTmBCNQWQgWWukwnbyxrLkrB0g=;
        b=CR31kyMKqJssQbVi1JNiJC/mpUqUbB9GeHhEnWXxUYEm/NFvtyAwx+ibkWn73vB8s1
         ijmN8IVbIB6z7z2Xw7lOxf+6NAJ94vILodRFkmRNak6nbqnti1w7Vec83AbVODQti+Kg
         7iZr/mfEAgiffcNh//LPD7cgzTHZYJwM9cu/zGu5dgHfwIT/9Yo8YMZFtBELx50wYa0F
         rbPp54YHrqXeg1OAS9y5SI2EhI+hVbTYKJJdL1LP54ucpmGb/21rizHKTKR6QAjKJzsX
         SYmGj1j3ACblLdnWniEQFA6KCwJKI0YxvpBvj6O7nu3fu2xWUvqQV5NL2r+mOCMSZlEB
         WSNg==
X-Google-Smtp-Source: APXvYqy8PsCjFxIJXLZEqVIOqouGGmLPoWA0WKXKYrav3RxdCeb2sgrOXhs44ORw1QLgIMf7oUBMtA==
X-Received: by 2002:a2e:b0d0:: with SMTP id g16mr21038731ljl.161.1560083018160;
        Sun, 09 Jun 2019 05:23:38 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id c8sm1354240ljk.77.2019.06.09.05.23.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 09 Jun 2019 05:23:37 -0700 (PDT)
Date: Sun, 9 Jun 2019 15:23:35 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 04/10] mm: generalize postponed non-root kmem_cache
 deactivation
Message-ID: <20190609122334.6jbpiwgrdzs4xill@esperanza>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605024454.1393507-5-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 07:44:48PM -0700, Roman Gushchin wrote:
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

Much easier to review after extracting renaming, thanks.

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

