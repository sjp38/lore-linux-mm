Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FBABC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 21:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3864D20848
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 21:42:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="som4VuEn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3864D20848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5D316B0271; Tue,  4 Jun 2019 17:42:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE31E6B0273; Tue,  4 Jun 2019 17:42:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A83DE6B0274; Tue,  4 Jun 2019 17:42:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7186B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 17:42:43 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id p7so3817529otk.22
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 14:42:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MmbOSyUJaWKC7E6mkMCzZ130rukGjBMZ7YsMSlPmAOc=;
        b=aOEZUf7CKr8AtJjYTk/knYjIc/msvCeDPLXrNxee9fTdQmR/BTUVEy/nNogYdTeEJR
         gholISsdt60xjTKv4C1dPzQTWtLTdfonwwDu+H/dnVmK5AWXP2I8LpQTnJfVgZxgCNXD
         1r6M38eh5qhEnZzfK6HSBPZmaSJgI3zzNsMyFMPoP+rMXiJQ60eenKF5ArTAmZ1DqSBv
         4SIom0nHZkENRohcIIfaLTrOg6KhCsMxtgPleWJdqVfMVeFNj9p0F/vSKjT/DpUwxqYT
         IDhT/VH2dkx1uS+TF0mW44b55ty6m/16q7rahd5F/OsuMgLGCPM2Dc0KuIuwg7DPgtF3
         MfTQ==
X-Gm-Message-State: APjAAAXHd8asEad7uFJ5Rl2ymbBLH0KNgxa5vrNzBY/yqmWifsZR4GPL
	2a7dq4aKorurFCCx4ESBQpa9GgyYn8cOKurB/GEY9sQVg0wV5VzSV2+ln/wu4nDt7YsKs6QRmB4
	T0wCKlhlEY7H+VQYERmgi97YwXtslkRyG5N7gw/RYM3w15cmonzFvbF14n+sUHhx5pw==
X-Received: by 2002:a9d:7395:: with SMTP id j21mr7106470otk.204.1559684563162;
        Tue, 04 Jun 2019 14:42:43 -0700 (PDT)
X-Received: by 2002:a9d:7395:: with SMTP id j21mr7106448otk.204.1559684562511;
        Tue, 04 Jun 2019 14:42:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559684562; cv=none;
        d=google.com; s=arc-20160816;
        b=EEFuqRVjPrcgwf8SMGV1zLJK19z3yVXVeMq7YPm1ZOFtZPW6lme4gmTNMKwic0Z6uK
         hTnZmAsato0te4QqPJ0iFzuD84TNcl3A3xey2VA9rBVJJLRNXbICtIEq0P5/e1an7zAD
         jYDwnL0ZJxexKcbDBFoqbIzIW1wLyFbltm6DV7Ki8vDopQ9umdJ5ndU0QU32Em0nWjJg
         B86mIh5W6XC953tnpCpOUomZHZnOYON0rJdDx17rrJmCUoblzQVW4gRXteDzmeERXPpR
         Xq+nUSGk7yr5891fvgHaYtzySkES+W/552z4tOILDHPBYbILeoIkmB/r2e/xDSrajIqG
         QIDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MmbOSyUJaWKC7E6mkMCzZ130rukGjBMZ7YsMSlPmAOc=;
        b=b4E45aHAhuoZKsOpxRKfRaIrCjLRRh6qNosJLDf/6znY4rJNK7uzyK8c35pW1iwKTi
         hc+TN/kGEI1wNgeqC1pMITscByt1PvfGjl6EoOpbAaC37tAhIUIsCvdwKBP5c1g5hPvr
         Y73DCHF7F7OHAL0puGDiWCirO5T4iNLHTpnChMia66LzDEzjcOKORm+53UdYT7KptzBY
         GUv0GH4ws748pWuaAVIhSsSsWjvEUeMJg9Lh8cGFhoBxU/qoHxGwEpT4Lz2TpxnecgAt
         8f4Tl+cOjERUAWXqHmx2oXnPREkOp+xBaaeoDbEtzwsvHXNyd2ug/Hisc4qSkfbK6raJ
         ZqRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=som4VuEn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o64sor2376510oia.58.2019.06.04.14.42.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 14:42:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=som4VuEn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MmbOSyUJaWKC7E6mkMCzZ130rukGjBMZ7YsMSlPmAOc=;
        b=som4VuEnLAm6NcFA4G/8bUu59DJs6RQOXDu6uZ1dl355pmtObd2mRXHG+QnM2NILle
         6DTXAQBmdRMaZD/x8iF9Y+ryzMErSw+5JBQo8Ro6J+sgLvZco1iE/lfnV+f4LAl3DAHn
         BAy+HURpJHjZM6ifsf+NaHt6OzO9VRQgq9Rko4eWC5NCxUiL5IegRMqCGfwNenMs3zrq
         yAHjmwOlHQrfADQgDM4ZbZgN/gs2XWJsOhdjaDVoJadZeL6PHpmdxdY1+b8bHDr2gD1D
         TjQRJZ66edOjw2MfQXWpKr98kqESN59Fy+Gb7g6GhFh4MYAVLfUPkUh5tK+kWuRZ8sbq
         Tu/g==
X-Google-Smtp-Source: APXvYqwy/zP1uRQYn1PObI3YjbeOg8OAYcgtGZPJVk80vheA3mZKMw14QcF60p+PtjD68c6OpiKRTCMpu+IhxFZif08=
X-Received: by 2002:aca:6087:: with SMTP id u129mr5555815oib.70.1559684562041;
 Tue, 04 Jun 2019 14:42:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190604164813.31514-1-ira.weiny@intel.com> <cfd74a0f-71b5-1ece-80af-7f415321d5c1@nvidia.com>
 <CAPcyv4hmN7M3Y1HzVGSi9JuYKUUmvBRgxmkdYdi_6+H+eZAyHA@mail.gmail.com> <4d97645c-0e55-37c0-1a16-8649706b9e78@nvidia.com>
In-Reply-To: <4d97645c-0e55-37c0-1a16-8649706b9e78@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 4 Jun 2019 14:42:30 -0700
Message-ID: <CAPcyv4h8fgkaP_zVT0bBwnstkO+=V8RRH5z4a=EemQLFamXB1Q@mail.gmail.com>
Subject: Re: [PATCH v3] mm/swap: Fix release_pages() when releasing devmap pages
To: John Hubbard <jhubbard@nvidia.com>
Cc: "Weiny, Ira" <ira.weiny@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 1:17 PM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 6/4/19 1:11 PM, Dan Williams wrote:
> > On Tue, Jun 4, 2019 at 12:48 PM John Hubbard <jhubbard@nvidia.com> wrote:
> >>
> >> On 6/4/19 9:48 AM, ira.weiny@intel.com wrote:
> >>> From: Ira Weiny <ira.weiny@intel.com>
> >>>
> ...
> >>> diff --git a/mm/swap.c b/mm/swap.c
> >>> index 7ede3eddc12a..6d153ce4cb8c 100644
> >>> --- a/mm/swap.c
> >>> +++ b/mm/swap.c
> >>> @@ -740,15 +740,20 @@ void release_pages(struct page **pages, int nr)
> >>>               if (is_huge_zero_page(page))
> >>>                       continue;
> >>>
> >>> -             /* Device public page can not be huge page */
> >>> -             if (is_device_public_page(page)) {
> >>> +             if (is_zone_device_page(page)) {
> >>>                       if (locked_pgdat) {
> >>>                               spin_unlock_irqrestore(&locked_pgdat->lru_lock,
> >>>                                                      flags);
> >>>                               locked_pgdat = NULL;
> >>>                       }
> >>> -                     put_devmap_managed_page(page);
> >>> -                     continue;
> >>> +                     /*
> >>> +                      * Not all zone-device-pages require special
> >>> +                      * processing.  Those pages return 'false' from
> >>> +                      * put_devmap_managed_page() expecting a call to
> >>> +                      * put_page_testzero()
> >>> +                      */
> >>
> >> Just a documentation tweak: how about:
> >>
> >>                         /*
> >>                          * ZONE_DEVICE pages that return 'false' from
> >>                          * put_devmap_managed_page() do not require special
> >>                          * processing, and instead, expect a call to
> >>                          * put_page_testzero().
> >>                          */
> >
> > Looks better to me, but maybe just go ahead and list those
> > expectations explicitly. Something like:
> >
> >                         /*
> >                          * put_devmap_managed_page() only handles
> >                          * ZONE_DEVICE (struct dev_pagemap managed)
> >                          * pages when the hosting dev_pagemap has the
> >                          * ->free() or ->fault() callback handlers
> >                          *  implemented as indicated by
> >                          *  dev_pagemap.type. Otherwise the expectation
> >                          *  is to fall back to a plain decrement /
> >                          *  put_page_testzero().
> >                          */
>
> I like it--but not here, because it's too much internal detail in a
> call site that doesn't use that level of detail. The call site looks
> at the return value, only.
>
> Let's instead put that blurb above (or in) the put_devmap_managed_page()
> routine itself. And leave the blurb that I wrote where it is. And then I
> think everything will have an appropriate level of detail in the right places.

Ok.  Ideally there wouldn't be any commentary needed at the call site
and the put_page() could be handled internal to
put_devmap_managed_page(), but I did not see a way to do that without
breaking the compile out / static branch optimization when there are
no active ZONE_DEVICE users.

