Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92767C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 19:51:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A23D20866
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 19:51:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="l3SHbq+t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A23D20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95EE16B0266; Wed,  5 Jun 2019 15:51:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9106E6B0269; Wed,  5 Jun 2019 15:51:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FE436B026A; Wed,  5 Jun 2019 15:51:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0066B0266
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 15:51:27 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id t128so2296093ywd.15
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 12:51:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ADSrVTY729P8giks2VI3lL/ewrVA0y+ziy53/CJHjbI=;
        b=l4hM3jZdHt2eIi8gft4JXm0g42+jjSDxsGwv48N7cySTma7cqCkZsZX0nUZrtc9nzw
         ewxOMg/XVuodmRSVFgdZjWuY/dTQlWZP8h+FIOgUgQxg78vSixdXwF806uvZwaStHC0X
         T8xB/MEz8wrN0K7201UuVYZIN3YLzcinugIZHCwch9mxPpCEMmn+ERVTj8ncUiAfvMHT
         /guincJcwAnnYTXS99HAqpAnjNR5k+1boF/G54fsS3wDLouYUUse2MUJKa44cx54ujIl
         4l+2OgBmYVQVtb5Uhj411a3xffquBJKq/W0Jk20cbnS1Cm7tWDzpSZIhOzKjxY2gL/37
         +hMA==
X-Gm-Message-State: APjAAAWbk/bjH2Ii9OpeETLgOKPsy55AQkdH1Mu37rL/fQ5VLxoN7WYd
	HhsGM+hwaNyrKWIjnHXGBqHfPrPao17y+vHbseZbOGs+ifNQAkikWtX2eCUdwL00OGFBGC2oYwY
	DMsJqHLXPQlovjCvlYVmHpIvteyK6iPLbA0RfE7oHkoh94cpHuAJfCgmTiLtWNZpWlQ==
X-Received: by 2002:a25:2486:: with SMTP id k128mr20050559ybk.217.1559764287040;
        Wed, 05 Jun 2019 12:51:27 -0700 (PDT)
X-Received: by 2002:a25:2486:: with SMTP id k128mr20050522ybk.217.1559764286320;
        Wed, 05 Jun 2019 12:51:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559764286; cv=none;
        d=google.com; s=arc-20160816;
        b=GxLZ5VAdAzq5vXBxuadaS2ykWxn1e2pW+hjR00vAq6Dx6DZfAK3RaDBnlsThy2MJRa
         1+I+1H+hPwYHXnFozlVKSkd2bK7cdxw4Yo7n3a1ivDPAPNdQlkxxVwwXLYL8yRexLYwM
         JtDqP5sBtaL8JzHV/DXh68Gbtt/EKEb8+4QqcVEUJgcWf8vJXIj99ScM3xy5YNCrcAee
         Ja3eD2Lvd0J8fps96UcoxEWdo+nVCYwSjsMP+8UmSjgh1/f0QTlApv8unRRtzAhsHOsr
         DYmJ/Pe1IyOsZaDRH2x0OuD28Zt03xBGRZT5IgmWwj0LPa2NagUq2QR/OWLfvyxR1dEZ
         WUEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ADSrVTY729P8giks2VI3lL/ewrVA0y+ziy53/CJHjbI=;
        b=GuHnBw3/UwRNpD2lNlA6XvsXzjmrgE6H40ySkSKpFJokRSV/I8FA6dCVy75lB3sfAq
         p6N30M2hhJN6JIaSWfjUW3S5ltOQLPWk7AAJl99Huda7l4+QwTO7XAGRlb5t4tNlcfl9
         DKcDrfaDQzHx5rPeN1vzjdwKTwIBfkQycwfguOK2xEY8sgUnVKeyrDsMrRkBKY/50cLI
         fLzXWGd4mvvuXZvxImh5IgPxtA+6iqKlpWmRVS7lEkcgoFCYPzgy32YTeLyOVQDAofWM
         ENnWCa1JsDui44Jp0RMIM2bjiqnPii6021VKXZ38eMSWRIvYYCHiQjPJ+AhbGi8ORe97
         Whxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=l3SHbq+t;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i81sor7676124yba.62.2019.06.05.12.51.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 12:51:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=l3SHbq+t;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ADSrVTY729P8giks2VI3lL/ewrVA0y+ziy53/CJHjbI=;
        b=l3SHbq+tQMcR8JiOwkKI+rqmX8UZZye9PTtYe2D5QDQJbkEw4tn4YzYjfj1Avcsc8J
         cRSil6+QYDOrKQcFibXBl8KHBvqgfc+1gWOKhOe5AQUjTBRcaA3c9aZHM9gXxsy42Uaj
         XaKe/llBw2BCOk7t9sYKNJWXw59+a0I7dELeuw9kQpYWeGkMxRiRyXAcTSC6Y+L4A1hI
         8NfTciR75XJzP+w3pQnIvURLV7LJhtCB6aKw4xvZuKpyq0I/nCGRAMJWlVW7ec6CpZJy
         ACUbqKujEVikDTF5Sng3n0OT3pwVrcF9Was5/ZEXf62lg8i+p7yOdy49gg/QBSLKQy/T
         wMSA==
X-Google-Smtp-Source: APXvYqxszqUD/k5nU1g4wHGqDzn8YOE0ACTETUwVMD6KIg9ukVr7Jucv9S+W7J8xRSISnfIGsWcd/E7G53G2roOi1so=
X-Received: by 2002:a25:7c05:: with SMTP id x5mr19854493ybc.358.1559764285452;
 Wed, 05 Jun 2019 12:51:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190605024454.1393507-1-guro@fb.com> <20190605024454.1393507-2-guro@fb.com>
 <CALvZod4F4FqO27Y+msXrxT9yaDLLN7njmBsRoTkmQSPE_7=FtQ@mail.gmail.com> <20190605171355.GA10098@tower.DHCP.thefacebook.com>
In-Reply-To: <20190605171355.GA10098@tower.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 5 Jun 2019 12:51:14 -0700
Message-ID: <CALvZod6Cu+Uyy-Jp-er0Kz9dwLhmb5KO0XP3X55PVcSx4A4w3g@mail.gmail.com>
Subject: Re: [PATCH v6 01/10] mm: add missing smp read barrier on getting
 memcg kmem_cache pointer
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Waiman Long <longman@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 5, 2019 at 10:14 AM Roman Gushchin <guro@fb.com> wrote:
>
> On Tue, Jun 04, 2019 at 09:35:02PM -0700, Shakeel Butt wrote:
> > On Tue, Jun 4, 2019 at 7:45 PM Roman Gushchin <guro@fb.com> wrote:
> > >
> > > Johannes noticed that reading the memcg kmem_cache pointer in
> > > cache_from_memcg_idx() is performed using READ_ONCE() macro,
> > > which doesn't implement a SMP barrier, which is required
> > > by the logic.
> > >
> > > Add a proper smp_rmb() to be paired with smp_wmb() in
> > > memcg_create_kmem_cache().
> > >
> > > The same applies to memcg_create_kmem_cache() itself,
> > > which reads the same value without barriers and READ_ONCE().
> > >
> > > Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Signed-off-by: Roman Gushchin <guro@fb.com>
> >
> > Reviewed-by: Shakeel Butt <shakeelb@google.com>
> >
> > This seems like independent to the series. Shouldn't this be Cc'ed stable?
>
> It is independent, but let's keep it here to avoid merge conflicts.
>
> It has been so for a long time, and nobody complained, so I'm not sure
> if we really need a stable backport. Do you have a different opinion?
>

Nah, it's fine as it is.

