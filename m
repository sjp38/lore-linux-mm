Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FFA3C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:16:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FF1420665
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:16:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pVlUNDcM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FF1420665
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C44EF6B0006; Tue, 25 Jun 2019 20:16:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCF018E0003; Tue, 25 Jun 2019 20:16:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A95758E0002; Tue, 25 Jun 2019 20:16:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88A366B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:16:00 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id i63so1249803ywc.1
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 17:16:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=9hBC31XsM1drX/BZAp0N2OzT0r+e6co+lkmZ6G0GOVU=;
        b=dPpq/bdr/cOsDhLU9xnA/fjUAOQvCrutxznYC81RRPvZK3GcN/jWVlicYKQDYVt5HB
         VDQLvudv04uPd0atGvkoA1cEXIBW7JTFwY/dKM4XVmhe2ciTSGsh1oXwDxbSABs869J8
         mY7wHZvOjsEko2+AaYkQLQwc4KGdixLyv4z26m9+WErrkBT/mAyv67vXS+k74BG43DhO
         GA956r3oiFhULnKGaOhQ2ORVYO+ocB+DoLU2GXrEy6LdpxP9IHLrM3PsHEpSWptetYzo
         LPD+bXZvAf+BgISDmKEjudTqE43M13m05bHgibxBvD7OWJE5lnrmVlgZ0dlQXA6g7huk
         vsSA==
X-Gm-Message-State: APjAAAXLbg/xFU0SvJAE3QC6k8knq7SxFxKtezPrJKjYhQSpIYDaM4a3
	ttlDHXIMtC4ybVQzs+SUgFSNCryZC9rs0mfWWl8QRfsbmXdF0l2jhZVFZk8SXKsvvv4/lXJKRyU
	U6yu+zMQEUFLolk6b6umMpHsA8MaENdu2/yuJITRQV+W+yVE3a4IMkwqM49fAenjf3Q==
X-Received: by 2002:a81:2c46:: with SMTP id s67mr858486yws.46.1561508160364;
        Tue, 25 Jun 2019 17:16:00 -0700 (PDT)
X-Received: by 2002:a81:2c46:: with SMTP id s67mr858467yws.46.1561508159930;
        Tue, 25 Jun 2019 17:15:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561508159; cv=none;
        d=google.com; s=arc-20160816;
        b=JtCdPtNN0UvjXiEZf4rR1iI7gc1usHRo8OJuuBAU+8xck4aL6IepSIQNsDMSQxWZ06
         pWXO6JySOmqelMjcp1h9dVJpKA1ET3YCBzoKb7reslFxR7/8tluHyaGQeQtdAhQYD21G
         aoT9/ILP+j2i8gwcLbp7+doS5nFS3uDKHg/dfYmgHFT4lv6Z+pb2Of52/VLkpAIbi59F
         J550uSz9iM15gezLcgm7IueMCyIXJVMeKddTJ/TekY2jAKk63FSq4oNckjCW3TlQAI8u
         gNDC460j3f7RoZ8XzKGZZTE9+7SsnZbtsFSSmVsMDf5E4U0A9mj4FsZqJh7JTcWFBhqG
         2ZWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9hBC31XsM1drX/BZAp0N2OzT0r+e6co+lkmZ6G0GOVU=;
        b=fyf9yJWhyetoIQ7piZTnVDCI6foYs0QpcRRaWgyHe1T+UBwzXaG8QE0KqLveDmcs7Z
         Tw36xRyyd/rkrGvgpr4K1J/rirO/8/KAtbcZGPwMGa07oskBm3efs5N13WMNSqSQw7C6
         eGHkkFLsETXV1ucsmEdCUbFz4V2Zaj1pqeprE2h/atO2767OI+SzNxw9hAN5xgVgVea2
         HuUsMhfwyFwv5IYTwk0D+4BJ4pF+RqsAAzM5T7ytSDgE3oIfbOvlQTma20tCG0M1pHs2
         MhcbVI9Z2AqlNzWcpFW3GMuC8JIEAK4fvZdvrfCdBPe3VM2MynDGNeJVZPuvU+F+wow0
         fW+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pVlUNDcM;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r130sor9137124yba.43.2019.06.25.17.15.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 17:15:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pVlUNDcM;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9hBC31XsM1drX/BZAp0N2OzT0r+e6co+lkmZ6G0GOVU=;
        b=pVlUNDcM4cTi+agb1ezQeSRdpds872gA7cb6ZJ+baveCQCZw167X+Pb0NoSrYCPnIZ
         sf2SLj7IntgrbvnK4d70pRjkOHGKLkGjpCUUeY1KiNj4MKlhKC7A60xtgR4RarZVhHa8
         wUZY/HAv8uD8BwX9pcaLVVV9tVpVaTKtHLevMa/qA4Y4yPsSIy/xJzezpaGNRWYRP9dL
         rUx+O8OaqM4GcgiHUT/QEEjFbkksKz10UfVJ98MwhivQPhcj7ocX9O1xHW8OSBY7TaUw
         YHKHz2eNMBMhLFeUUtjp5QOHRhrZ9fxu2wmFJEC2OJjqXK3sJenC0N1OVW3pJNyS1pxO
         BwdA==
X-Google-Smtp-Source: APXvYqziwXiEu45zHzvz6AOVywxIKSFUF9xqlnDZnM9NN4/TdLcixitnoMQV0xS/KG+Sf7SbappnvvAohrHdZMKzwm8=
X-Received: by 2002:a25:a107:: with SMTP id z7mr790646ybh.165.1561508159394;
 Tue, 25 Jun 2019 17:15:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190611231813.3148843-1-guro@fb.com> <20190611231813.3148843-10-guro@fb.com>
In-Reply-To: <20190611231813.3148843-10-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 25 Jun 2019 17:15:48 -0700
Message-ID: <CALvZod4YoO0eoQmocHEFP7zrYpf3SzvaBEDpfDHS=_fiCyYcAA@mail.gmail.com>
Subject: Re: [PATCH v7 09/10] mm: stop setting page->mem_cgroup pointer for
 slab pages
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
> Every slab page charged to a non-root memory cgroup has a pointer
> to the memory cgroup and holds a reference to it, which protects
> a non-empty memory cgroup from being released. At the same time
> the page has a pointer to the corresponding kmem_cache, and also
> hold a reference to the kmem_cache. And kmem_cache by itself
> holds a reference to the cgroup.
>
> So there is clearly some redundancy, which allows to stop setting
> the page->mem_cgroup pointer and rely on getting memcg pointer
> indirectly via kmem_cache. Further it will allow to change this
> pointer easier, without a need to go over all charged pages.
>
> So let's stop setting page->mem_cgroup pointer for slab pages,
> and stop using the css refcounter directly for protecting
> the memory cgroup from going away. Instead rely on kmem_cache
> as an intermediate object.
>
> Make sure that vmstats and shrinker lists are working as previously,
> as well as /proc/kpagecgroup interface.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

