Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC66FC43219
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 23:54:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7152D2067C
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 23:54:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vtb874mz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7152D2067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C92B16B0003; Sun, 28 Apr 2019 19:54:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C43316B0006; Sun, 28 Apr 2019 19:54:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B59AA6B0007; Sun, 28 Apr 2019 19:54:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91A516B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 19:54:37 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id d193so7755715ybh.13
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 16:54:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sJzmJt5dXSr46qHnoNS5EATc+3d/a2ElrqvTmuSBEdg=;
        b=s/KWRZIq39dgW+gt5JqOJUHLuQ4Pma5gOJH2mVc1XVpRY6lFNyaJxumBRWaJsawaNA
         o1q/fk+piZk3rHc8PJFkuDBJpVHkMWkPkuqrOjnrXz2rYLfjLcKJK3d3kql0ui20LHJb
         1LrVo3t9xu2BZ1iP7Hbkrn5k21/M/mLqDFXW2VhMvSn8HAP/snvnFLuv6/rkqDXxBDhn
         BpOA7nIqJlhSphmkce0dPENUULgHrfdGfwVqnTazUaaw6ttMLIzvkfO9QKQ52nTtbQ0S
         l61ghLsw9sDXi2Mi1VRSXQ+FBGSegB0Bv7skOyO8G4Pk2f1lrOJxo9pq+vUVVNoiSSfo
         AmnQ==
X-Gm-Message-State: APjAAAU9XCxTQGjSeewazYKnWdfHabkoyrKq2O3XdMaR1O3lU4qaY4DK
	R2x9TLuOZoLF01QlMkFvVvx5cdQnXOIkeFlR6yG2e/beOh4zC2tpaiJrOuToAjzjmoK+h3laNO4
	/9g3JcIzK/h4bHcu7+h7BgqOyUl/nlRohVs0EMd47TkLic7DozffjGiUoKX/cFPGE/Q==
X-Received: by 2002:a0d:cccb:: with SMTP id o194mr24509924ywd.506.1556495677281;
        Sun, 28 Apr 2019 16:54:37 -0700 (PDT)
X-Received: by 2002:a0d:cccb:: with SMTP id o194mr24509899ywd.506.1556495676524;
        Sun, 28 Apr 2019 16:54:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556495676; cv=none;
        d=google.com; s=arc-20160816;
        b=0TL4nemyy/yZQxXNiWETLuMGRzEr8mo6jDQkR9auVIOuFJcsLmZHjTnF1fjMSmT2lS
         82xw8tx/eNjMQ6IoWeXB5miA6Nj0vP8DVCZ68ZvDBDEI8OlkfP7rEheQx9nw3OHslGhT
         xYUQQkWdZRgjMTjUd/87KlPbYjnUcK8lV8R8fMWY+8xf/HOTiQvtzaH9gb9R9vQpIfb+
         n7vaAccDVi0LFWw2zZDmvFOrfJoQDbBTQli9Hlxl3NwxRuhpO9FCgoDTnMfadkhpoS4A
         8Dp0nzFd7EGI2tTs0cPYIJimwj//PDFKtnk3L2CWKWObd3N6gRq1ncMHH3Y3kPVlYrUK
         6EqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sJzmJt5dXSr46qHnoNS5EATc+3d/a2ElrqvTmuSBEdg=;
        b=euiFZ0N2p/6bP158vhgbhYz4Wf2uGshPpy39iye6/O6inAmp/BLofgkpZgTJNUvmXU
         MyyEFnKbafu5+Rru0V4UXRQkaQGcnqFgsslKJdKKDYEYid0zobJuDc/J5SAYUOoenBsW
         dd3zz8zds9OFW9j+2VjnKAlcymPo3P2Jj2451bMesNfCasmIqg+DJj8gy7IZdNSUyQ3X
         9fjqrvnHECc+fcH2OAwBko+7kdIRmzh62kxfT/g8JwtbCmLWfsPItYUtUbDcXldPRnfz
         qp933BsO1mJhRmUmKyneXiBw6VBQhqGSyVd8QmEvaS/P4d7abe6fGy9+Dq6qB6U092Ky
         q4/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vtb874mz;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s22sor6548459ybs.138.2019.04.28.16.54.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Apr 2019 16:54:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vtb874mz;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sJzmJt5dXSr46qHnoNS5EATc+3d/a2ElrqvTmuSBEdg=;
        b=vtb874mzD79EZ4lK/FKahzxhVi0KRxJCPlqZoqswyk+2KOM5zWGrGYQuwyAm+T22Tw
         owM7xGx6+2XBrBj5iKgttpXndlokSkCdXaHqUeHOFf+PlXlCZ2yp0uwBGU9kHmPDBaP3
         NPMqftVpxG32Ym3soeW3UjOB6L1fPjZDBlyMdNqNwt9OVII2tfrlqfl/gnvIPU3bMaZn
         cUVYDFNlR55+wB/mdDdGu/qVqcG7ro7bhCZ4ZElgyYQOn/W0/DI1IikYofKRbuRkkoiy
         mESCGm4KqIGV5Jq0W0rf0Z4UcYiBTtc6ftKlNJ6VQTSglnjByMoBHVI/DsH9MW04d21q
         MSfw==
X-Google-Smtp-Source: APXvYqywcrtNm7hfKOwHEbWcro/mUsCfRRyw7no0aSBlNf48FzHe5zU0X1HlsmhnwnPpE8C1iDov7piwnmKx6YCRD8c=
X-Received: by 2002:a25:f507:: with SMTP id a7mr46894022ybe.164.1556495676033;
 Sun, 28 Apr 2019 16:54:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190423154405.259178-1-shakeelb@google.com> <20190425064858.GL12751@dhcp22.suse.cz>
In-Reply-To: <20190425064858.GL12751@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Sun, 28 Apr 2019 16:54:24 -0700
Message-ID: <CALvZod5Peau7D-O1oi0jFfiOCJrSOMHDnr6TPrTxawt_jh9izw@mail.gmail.com>
Subject: Re: [PATCH v2] memcg: refill_stock for kmem uncharging too
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>, 
	Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 11:49 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 23-04-19 08:44:05, Shakeel Butt wrote:
> > The commit 475d0487a2ad ("mm: memcontrol: use per-cpu stocks for socket
> > memory uncharging") added refill_stock() for skmem uncharging path to
> > optimize workloads having high network traffic. Do the same for the kmem
> > uncharging as well. Though we can bypass the refill for the offlined
> > memcgs but it may impact the performance of network traffic for the
> > sockets used by other cgroups.
>
> While the change makes sense, I would really like to see what kind of
> effect on performance does it really have. Do you have any specific
> workload that benefits from it?
>

Thanks for the review. I will run some benchmarks and report back later.

Shakeel

