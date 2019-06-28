Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7388EC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:27:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 202AB208C4
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:27:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vt7AoMwr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 202AB208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A865F6B0003; Fri, 28 Jun 2019 15:27:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A105B8E0003; Fri, 28 Jun 2019 15:27:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 924868E0002; Fri, 28 Jun 2019 15:27:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2C36B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 15:27:26 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id u9so11824739ybb.14
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 12:27:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TvUXywiG0f7bCL3wZmKqPPbl6x6Ilq7Dj7JuFch+QdI=;
        b=ue0ogv9ykOEaE2kmzTFr2jOMguVsLAkBrCMd9isvog3ugkfGdxK69I/AG4sF08Gb4+
         Kv2m+h1WQgNYL79OLKdRmsEy3kZH+kpaK0q1daCVx/bYvNoUCtUNFzZG1Y+mtF0Bd81h
         yw6/XIGjdjkzI6WC29WzWn1/icpT7KpIQy0QKW4S9K2evtFUHejExEjzepyiz8hEMh59
         ex6WOrWmixa9YA1OeL3eFzmGQ0tLZpWdXQCb6g5qY7qo0+Y8PWHtRGXdklO0aiE3w4fw
         9LZjNVc7+u8KQBjGBczlT4Wq2PWHcqvoCeglSXLjtohkA4o5XPwpQ/kn3alW2MKFnh3v
         YQSg==
X-Gm-Message-State: APjAAAW3EJC20ECAK/pev2dBArFvOiCsKCyCo5YKuXwZA7lUAiY1RzKK
	i7pBSgwBkx5t/sCrGBRAC4vNKGUW+hrIWTUwOKV5P+1VU4q7nE3TJkzovLAevei64VZ1gEI6YlI
	AoDTLuUbUIAJRxIfgxZ5cngkqVLE+i3jOQHU2PM2BHN0wYR83VTlOAMSjGv2nUVbneQ==
X-Received: by 2002:a81:a603:: with SMTP id d3mr7110700ywh.87.1561750046133;
        Fri, 28 Jun 2019 12:27:26 -0700 (PDT)
X-Received: by 2002:a81:a603:: with SMTP id d3mr7110685ywh.87.1561750045482;
        Fri, 28 Jun 2019 12:27:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561750045; cv=none;
        d=google.com; s=arc-20160816;
        b=rGF69bW9Lcr2z8qbLxlU0pvk71sWZ7jC8+zZ9RP/ZzGfwAFpQyWtaRfH3gmgOz06wj
         DcpK3+W3XRBaWUw/U9oru2Eh6QVu+B7V3q0tPAOiXweV7ElpYJLUB1/kz+NwedXOWYpb
         2IS1Uj298Bu4onlLPpn8C0rXpH8dthuQ+J+ymMifPaHer/A2xQBAPILsejrH10B60Nmr
         MxK+rIqx34+ZIRtd0kCpnQPsTdv+ryLw6RpfITqTUQb/FmVcrhvNd8Nj0UUn7rho2f8K
         SDsfMPT0ucJrs6R/Dw+bQCjDYEulcFrRQE56wpAsS7+8+L3mM3S6WesnfLSnbCeuTvSo
         hg9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TvUXywiG0f7bCL3wZmKqPPbl6x6Ilq7Dj7JuFch+QdI=;
        b=HLHaChLmFTmjVIHETSb9W3sK21/vk2BwlJmhk9rLVDD14G7Il/sRhl23rD2DPKIZo9
         +18RyptyGs+fj5+hcEDeC2VzkFC+1uZ/kyh2mBVtkTkDNTPP0F6X2ykX+f/U3mnr8fve
         y1JYlqcJuv0Vr/JQ5wHltN5wDyn/cU+6laQ06ax8wH3j7ysApxYE+8q+0EK97pMYRB92
         YDKkuVx2OBRRIG2zZmK5fm/2d2OxxlEAvK3Wslwh37AVoPc3SdQBYpo+4XiqumGccLAJ
         MbfI5yI0JCBhmWweN2VJmtpGx27g8ucmd2nvJ/bxeMSYOpTtGIBMGmtdEXIG6Vl+PBZQ
         p2dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vt7AoMwr;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o194sor1737744ywo.122.2019.06.28.12.27.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 12:27:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vt7AoMwr;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TvUXywiG0f7bCL3wZmKqPPbl6x6Ilq7Dj7JuFch+QdI=;
        b=vt7AoMwrNcWqMkfexaU6xlBIiiJMEym5gtlszE1wfAtxsaHc1nUkstrKx+VfeTOdW4
         jQapxfMfdVK3Kha0PgKtzyz67iZqe3RpRtmY8sqR0qFSYnjgzcmPDH0oBxumTHL7rpPw
         nYmM/KbsDPwQWESafxthWv+EoEX8OBpvv+0JkYtwBtgXKpikXgGKVH8FznIk7SA7Qijn
         OH47owMfMltuYy1/N6QD/WhAOZGseF75WthtolK2ck54xcf0GFpr4l1YJiVcBYg29F13
         8MZF9RT5I9torHdvXAJeC8N9iKGeudMzvl8gW8wkxVdskrvnbXbAqjxQfWdKBQ0SzIm+
         27KA==
X-Google-Smtp-Source: APXvYqyeNqvAsUAnD2/zSmW+uHs3PMxd0RthI9aXZomvVE0l90UkfP/cn8j691rqydeWakodWOrph9gJGKwfB7MrDG0=
X-Received: by 2002:a81:ae0e:: with SMTP id m14mr7609987ywh.308.1561750044891;
 Fri, 28 Jun 2019 12:27:24 -0700 (PDT)
MIME-Version: 1.0
References: <20190628015520.13357-1-shakeelb@google.com> <6e28c8ce-96e1-5a1e-bd06-d1df5856094e@linux.alibaba.com>
In-Reply-To: <6e28c8ce-96e1-5a1e-bd06-d1df5856094e@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 28 Jun 2019 12:27:13 -0700
Message-ID: <CALvZod6sDHNwTbUPSnBdj4bEG1gT1BDgwD=f=MrDOAx4yVuRiQ@mail.gmail.com>
Subject: Re: [PATCH] mm, vmscan: prevent useless kswapd loops
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hdanton@sina.com>, Roman Gushchin <guro@fb.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 11:53 AM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>
>
> On 6/27/19 6:55 PM, Shakeel Butt wrote:
> > On production we have noticed hard lockups on large machines running
> > large jobs due to kswaps hoarding lru lock within isolate_lru_pages when
> > sc->reclaim_idx is 0 which is a small zone. The lru was couple hundred
> > GiBs and the condition (page_zonenum(page) > sc->reclaim_idx) in
> > isolate_lru_pages was basically skipping GiBs of pages while holding the
> > LRU spinlock with interrupt disabled.
> >
> > On further inspection, it seems like there are two issues:
> >
> > 1) If the kswapd on the return from balance_pgdat() could not sleep
> > (maybe all zones are still unbalanced), the classzone_idx is set to 0,
> > unintentionally, and the whole reclaim cycle of kswapd will try to reclaim
> > only the lowest and smallest zone while traversing the whole memory.
> >
> > 2) Fundamentally isolate_lru_pages() is really bad when the allocation
> > has woken kswapd for a smaller zone on a very large machine running very
> > large jobs. It can hoard the LRU spinlock while skipping over 100s of
> > GiBs of pages.
> >
> > This patch only fixes the (1). The (2) needs a more fundamental solution.
> >
> > Fixes: e716f2eb24de ("mm, vmscan: prevent kswapd sleeping prematurely
> > due to mismatched classzone_idx")
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
> > ---
> >   mm/vmscan.c | 2 +-
> >   1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 9e3292ee5c7c..786dacfdfe29 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -3908,7 +3908,7 @@ static int kswapd(void *p)
> >
> >               /* Read the new order and classzone_idx */
> >               alloc_order = reclaim_order = pgdat->kswapd_order;
> > -             classzone_idx = kswapd_classzone_idx(pgdat, 0);
> > +             classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
>
> I'm a little bit confused by the fix. What happen if kswapd is waken for
> a lower zone? It looks kswapd may just reclaim the higher zone instead
> of the lower zone?
>
> For example, after bootup, classzone_idx should be (MAX_NR_ZONES - 1),
> if GFP_DMA is used for allocation and kswapd is waken up for ZONE_DMA,
> kswapd_classzone_idx would still return (MAX_NR_ZONES - 1) since
> kswapd_classzone_idx(pgdat, classzone_idx) returns the max classzone_idx.
>

Indeed you are right. I think kswapd_classzone_idx() is too much
convoluted. It has different semantics when called from the wakers
than when called from kswapd(). Let me see if we can decouple the
logic in this function based on the context (or have two separate
functions for both contexts).

thanks,
Shakeel

