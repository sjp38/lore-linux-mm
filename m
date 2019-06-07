Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09B5AC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:10:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBF7E208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:10:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IV4zLHj0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBF7E208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DE2E6B026A; Fri,  7 Jun 2019 02:10:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48F766B0272; Fri,  7 Jun 2019 02:10:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A51F6B0273; Fri,  7 Jun 2019 02:10:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19E1A6B026A
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 02:10:28 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id s18so998817itl.7
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 23:10:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eTktKQuTzdipksXwS2CKl7p1qhwpDhKrtnVfw336+xs=;
        b=r40sOwT6t8d3PTbxYt6mVNIViPRf9yDiXpCEknFLdxF7A30YhH0KpdUhlFfNCPW8E4
         EcTqGjX1KiDGCRjLZQyuf8iaJjxZMCiXmrDVDUikmn8G+HM/LDKiilTCh9WadFgNKnMF
         uVAv2s7qV4/Nh3u58OQgIJAbrSrOxQBwQvdugXtEjA+FZ8KpHIziP2M58Oa3cDddstfB
         iU3Bi/7N65aFatjxk4bzKwwTNwbf7xr0AsQqT1hfTHN4hO9oRgyKB2noowwx4OrawkXk
         +4nr3hoyWYQwFxzyDEZrpAAUAee2wWsidal1dt3gntTDIygyRu4HYTAwfTnObNJlzPXM
         WBBA==
X-Gm-Message-State: APjAAAWR6dVgnPJ/lPB5Z+isFeDlZIx4rfo5m1hEbgPVGniGYWWVbv+J
	ckOfoUjl1/WAynaqBtm3rE1wG2EfJb/oHUemf4Wjy5c1BkI5zi+CqzrDK7pKCeZoE6r/m884OCr
	h8UEge/dXzGr47S1ju+7cv5z/F67GyRTLIIBjVA4GdD6eLjV+XzsKDY+XEOTDFF7ieA==
X-Received: by 2002:a24:b04c:: with SMTP id b12mr3187389itj.142.1559887827832;
        Thu, 06 Jun 2019 23:10:27 -0700 (PDT)
X-Received: by 2002:a24:b04c:: with SMTP id b12mr3187364itj.142.1559887827094;
        Thu, 06 Jun 2019 23:10:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559887827; cv=none;
        d=google.com; s=arc-20160816;
        b=Jcu/zfWTjTVbhipVScuVBMRwpfJDf/yjwOxdiAlqfmqVUkMAK7OUUcUC8qeWrKtURv
         fDc626dk2pWUEUGvOi6Uo72ST75MMvZASqeDn303No0iuho+1kNkswCXwfkQzg+FQE3Q
         TvBqZHKkdtLMOIrRSmoWFdm7GrU8Dxy4lTx2jbtL1L6HKKdLl8TvKdzEVWzN76SK4uRI
         5HOQwe+EiWrP4miKjQrlSWwIHp5bKm5vC5MleKlunp7mOAqXym+fFDNJsW9/HzC0Mr+2
         dkorRpnRPchcQ7pYAt/BMSxz3o/OovXcWvHu0WfDZGHMY4sG4ONATaYmhUrvDIc1DohM
         w1lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eTktKQuTzdipksXwS2CKl7p1qhwpDhKrtnVfw336+xs=;
        b=IS8p+fPRL/2p5sE8NW5XbgoT3kg40Civ//L81RUI/EAtu6gYsL0U0lZ5jR1y8Y2ulS
         CuFzlOiRx0yGXJjFfKyhZUK4gHmUv/YZYBCz9uIkTGrqRSS3jJoAeyjvL9N4TZpQOzpg
         CZ9VZAhGWBjT/m25/N5/GRta8QJ/PbT81eLaamdR35DZhDy3kqXDRmw28sP5CsclfcCU
         T80Ah4/lrTK/iGMcrN1CNGd3junOhDM+LJHBalS08sdnO8rlJjRhXTu5iVzvui+pv0cw
         n7q6MwjtN9CfUDHbT66qPi1P1m7Gjifazs+5X2jy82HNASPczV95ErZ7gQLUCEPFV2UN
         /Bgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IV4zLHj0;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i16sor2637193jac.1.2019.06.06.23.10.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 23:10:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IV4zLHj0;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eTktKQuTzdipksXwS2CKl7p1qhwpDhKrtnVfw336+xs=;
        b=IV4zLHj0L6VpXbqbPfvaZO0ippEsxT1gmsZ7V2S/nWcvEDeFcJtFVigu0otcpMlb4V
         xAIju+cbPCdOUT/MuR2nvYjv7p64PSoDQV1uECjr4JHKj5Cd399GbXWWJ0gcLYHdTTVU
         5Uibii/zVZc66zpE6bfmIS+FyQQHjvFWJQjNEyfTxcbOh2oo2vngN6QmQ/6F2J/S9FKv
         q9C3T2kLzobgefw3JAKSlbn5eeyfuSdFfkDiWGmOUY612TsQA2FMNDYyalfQvUz6kRuY
         hybvTl/YG2k1RrhoZC9b2f2XqMGHaltcu1HerUN+9/Ctgc2x3estuK7G6OirSjs9v0/f
         6efg==
X-Google-Smtp-Source: APXvYqzCsB1yAjyy0lGkL6B8lZPrG+ajfCwjKyc+XM3O8ufM9vWUUtbOwWEDnqbjq8EZSqrub7VU4D5R8bU7jEiNJpU=
X-Received: by 2002:a05:6638:40c:: with SMTP id q12mr29265442jap.17.1559887826860;
 Thu, 06 Jun 2019 23:10:26 -0700 (PDT)
MIME-Version: 1.0
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
 <20190605144912.f0059d4bd13c563ddb37877e@linux-foundation.org>
 <CAFgQCTur5ReVHm6NHdbD3wWM5WOiAzhfEXdLnBGRdZtf7q1HFw@mail.gmail.com> <2b0a65ec-4fb0-430e-3e6a-b713fb5bb28f@nvidia.com>
In-Reply-To: <2b0a65ec-4fb0-430e-3e6a-b713fb5bb28f@nvidia.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 7 Jun 2019 14:10:15 +0800
Message-ID: <CAFgQCTtS7qOByXBnGzCW-Rm9fiNsVmhQTgqmNU920m77XyAwZQ@mail.gmail.com>
Subject: Re: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
	Ira Weiny <ira.weiny@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, 
	Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 7, 2019 at 5:17 AM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 6/5/19 7:19 PM, Pingfan Liu wrote:
> > On Thu, Jun 6, 2019 at 5:49 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> ...
> >>> --- a/mm/gup.c
> >>> +++ b/mm/gup.c
> >>> @@ -2196,6 +2196,26 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
> >>>       return ret;
> >>>  }
> >>>
> >>> +#ifdef CONFIG_CMA
> >>> +static inline int reject_cma_pages(int nr_pinned, struct page **pages)
> >>> +{
> >>> +     int i;
> >>> +
> >>> +     for (i = 0; i < nr_pinned; i++)
> >>> +             if (is_migrate_cma_page(pages[i])) {
> >>> +                     put_user_pages(pages + i, nr_pinned - i);
> >>> +                     return i;
> >>> +             }
> >>> +
> >>> +     return nr_pinned;
> >>> +}
> >>
> >> There's no point in inlining this.
> > OK, will drop it in V4.
> >
> >>
> >> The code seems inefficient.  If it encounters a single CMA page it can
> >> end up discarding a possibly significant number of non-CMA pages.  I
> > The trick is the page is not be discarded, in fact, they are still be
> > referrenced by pte. We just leave the slow path to pick up the non-CMA
> > pages again.
> >
> >> guess that doesn't matter much, as get_user_pages(FOLL_LONGTERM) is
> >> rare.  But could we avoid this (and the second pass across pages[]) by
> >> checking for a CMA page within gup_pte_range()?
> > It will spread the same logic to hugetlb pte and normal pte. And no
> > improvement in performance due to slow path. So I think maybe it is
> > not worth.
> >
> >>
>
> I think the concern is: for the successful gup_fast case with no CMA
> pages, this patch is adding another complete loop through all the
> pages. In the fast case.
>
> If the check were instead done as part of the gup_pte_range(), then
> it would be a little more efficient for that case.
>
> As for whether it's worth it, *probably* this is too small an effect to measure.
> But in order to attempt a measurement: running fio (https://github.com/axboe/fio)
> with O_DIRECT on an NVMe drive, might shed some light. Here's an fio.conf file
> that Jan Kara and Tom Talpey helped me come up with, for related testing:
>
> [reader]
> direct=1
> ioengine=libaio
> blocksize=4096
> size=1g
> numjobs=1
> rw=read
> iodepth=64
>
Yeah, agreed. Data is more persuasive. Thanks for your suggestion. I
will try to bring out the result.

Thanks,
  Pingfan

