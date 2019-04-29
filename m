Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1A3DC004C9
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 14:37:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53F4E20656
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 14:37:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ms9nqUQx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53F4E20656
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCE606B000A; Mon, 29 Apr 2019 10:37:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7D6E6B000C; Mon, 29 Apr 2019 10:37:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C92DD6B000D; Mon, 29 Apr 2019 10:37:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id A64246B000A
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:37:21 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id c4so8851680ywd.0
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:37:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=M/6XEsIqR8VWQpLXIhH0FRoDcnonKS2KQt8PYqdEcmQ=;
        b=PDXfmnh3Ja4Tg2MzkfZ8im13svhoJNc62umPEWFK8uYxNYjfJe7dLXfjE7FiNdTjBa
         ZB/QSy+yPoFp+xSSEDyrvRnc7S/lgbadKAcaP86AeNxsECRx6NuNS4K5NrWQYkrWYi3S
         ep8G6StlENMk4GeMZKHtDt2W4Q2ksc6Lh+DmW0oMdEoVDVrKT8Qb7XVo0nfWSXDNQIwb
         IsvZDZJQATpo05HCqlItJ3dxtmH2rEAvOXwbqcxGTgM2CRgcYtWhiZ8Oua5P7ajApejo
         a6AxgIh+6vxQpQJNUABJr2tz/BGzxHXhm0F9rArUyv26V2jAmc1L2+O2j9K4PVLnB/Gb
         ZnfQ==
X-Gm-Message-State: APjAAAVr7R9jVisPE8sS6nOfAJb4KGdeFHxag0r0JKdpEUsq26+Ok1HD
	zz4H3stsS2LpCIKF5fnkgu4CpKWrbTZHS/FkTmNH/KIHGtD/vVmGzV/nh66ozLjY63zOD2556/k
	R6luwbOgY3GLIiZkDCyNoJqz1/HzlZaOvz+8+qZZIp7uRy/0zoWKICc/6MStayIGCDg==
X-Received: by 2002:a81:218b:: with SMTP id h133mr49889091ywh.487.1556548641347;
        Mon, 29 Apr 2019 07:37:21 -0700 (PDT)
X-Received: by 2002:a81:218b:: with SMTP id h133mr49888973ywh.487.1556548639939;
        Mon, 29 Apr 2019 07:37:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556548639; cv=none;
        d=google.com; s=arc-20160816;
        b=WC0UsMCEd3AetDYy+7yKM77MhvE36VqDkxH2XbK782yXCzJxMi+ipeFWqm9yNdIoLF
         XSEYmwsgzJsJ7qsTpY2Gy5N7l4PBfBL3SpoHIJ1bUP6VwKL4Cx0Sj8ZSPj+5OLmpCx71
         aArE6eJs2OrYsSB2XfANSAEBw2nVwIthKPvfb4nA+G9GBniLmXYIqhA9nHtM0y9h0KE4
         y6BRKimNiPkF3L1x9gCzcav68mfYW5UHZ3EqHAZghCKn/G5kupgR/N31mv57w/Sip49d
         yn9wsiu0k7NEFA2D3n8i43G9DApH8wCTHwW0fQR63xX19Vhb3ShmK/VHb6fCcvwOVNTS
         I11A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=M/6XEsIqR8VWQpLXIhH0FRoDcnonKS2KQt8PYqdEcmQ=;
        b=J8NR4JU1j86kcrGJwwWRyoaSwXX6sxAADZZedMUwvPJX1bGeOlKPEVOlAuWZjNLvka
         xVneA1SACve4BBVWwgLKdBuQbALEtqMIyIiDjPIz7BQ65/ir36ftXo8VyrZETcgbq7FA
         WJvZGnOAwcY/vZxLqkV+nIpkWeLWFeaG/5GpgLSmupTMGQ8ivkMDhAgv4bBAujdgEkIe
         ECVAGYtrbs8oVWp4tyf7bgqeSReuXBbNvGBbe6q1XvaeRgYQ+JJH7hSa5USNYXrmgN3G
         Um6ambzwfOMBXg9YiCS8yM3wRoydzZIaJyV/nfJ5bmSXgCtGRLtvePK/LWwQra15okxZ
         yGLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ms9nqUQx;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k15sor11918378ybk.119.2019.04.29.07.37.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 07:37:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ms9nqUQx;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=M/6XEsIqR8VWQpLXIhH0FRoDcnonKS2KQt8PYqdEcmQ=;
        b=ms9nqUQx6QnRoflbPjYgEjlFy2Y9D0/6+0G9VqgYNlscBxoReHFFvdNWni+KPvrniA
         LyI6meDC6xaCQQcZpNBsWnausZSGUkfQLsxB2kAWos+57OQ52Pucuo8tCUdUsIudCDHZ
         vElK/QYsTago67Nbpl89mqFDK5RGuySBGU82zoLexyXiz1juRlqppKtH90OmOxaXTtwX
         Fio82mWAZZel9R/jB+y1QQYy4IHkRmjTMwdLDcuhsJpgFPqDu7u+6OKrhzVYEH2LN4R6
         NvvyeAIeOtREkegp0JCSBfdKaIbf9KB9vV7F6z0b5Xawd5KXDHlUeFFLCsrW3vW8G+Cx
         KX1A==
X-Google-Smtp-Source: APXvYqx/Z+xcfTj7msxd406E4QiWuVUE8NaIn1RLZw9Lw5xls8pb2+5DuUvvMRyfEQAXJ9Frvtwob28ZJJDlwvkGBe4=
X-Received: by 2002:a25:f507:: with SMTP id a7mr49459321ybe.164.1556548639264;
 Mon, 29 Apr 2019 07:37:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190428235613.166330-1-shakeelb@google.com> <20190429122214.GK21837@dhcp22.suse.cz>
In-Reply-To: <20190429122214.GK21837@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 29 Apr 2019 07:37:08 -0700
Message-ID: <CALvZod6-EOAkcuiuBpoE6uR2DFNUkUY8syHxenFEAZTxhgNMhQ@mail.gmail.com>
Subject: Re: [PATCH] memcg, oom: no oom-kill for __GFP_RETRY_MAYFAIL
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

On Mon, Apr 29, 2019 at 5:22 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sun 28-04-19 16:56:13, Shakeel Butt wrote:
> > The documentation of __GFP_RETRY_MAYFAIL clearly mentioned that the
> > OOM killer will not be triggered and indeed the page alloc does not
> > invoke OOM killer for such allocations. However we do trigger memcg
> > OOM killer for __GFP_RETRY_MAYFAIL. Fix that.
>
> An example of __GFP_RETRY_MAYFAIL memcg OOM report would be nice. I
> thought we haven't been using that flag for memcg allocations yet.
> But this is definitely good to have addressed.

Actually I am planning to use it for memcg allocations (specifically
fsnotify allocations).

>
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
>
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

>
> > ---
> >  mm/memcontrol.c | 4 +---
> >  1 file changed, 1 insertion(+), 3 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 2713b45ec3f0..99eca724ed3b 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2294,7 +2294,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >       unsigned long nr_reclaimed;
> >       bool may_swap = true;
> >       bool drained = false;
> > -     bool oomed = false;
> >       enum oom_status oom_status;
> >
> >       if (mem_cgroup_is_root(memcg))
> > @@ -2381,7 +2380,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >       if (nr_retries--)
> >               goto retry;
> >
> > -     if (gfp_mask & __GFP_RETRY_MAYFAIL && oomed)
> > +     if (gfp_mask & __GFP_RETRY_MAYFAIL)
> >               goto nomem;
> >
> >       if (gfp_mask & __GFP_NOFAIL)
> > @@ -2400,7 +2399,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >       switch (oom_status) {
> >       case OOM_SUCCESS:
> >               nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > -             oomed = true;
> >               goto retry;
> >       case OOM_FAILED:
> >               goto force;
> > --
> > 2.21.0.593.g511ec345e18-goog
> >
>
> --
> Michal Hocko
> SUSE Labs

