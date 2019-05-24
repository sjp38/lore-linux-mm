Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F030BC282DE
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 03:58:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99F5E21773
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 03:58:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Qs74XkHj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99F5E21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE1656B0005; Thu, 23 May 2019 23:58:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E91A86B0006; Thu, 23 May 2019 23:58:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D81356B0007; Thu, 23 May 2019 23:58:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id ADA406B0005
	for <linux-mm@kvack.org>; Thu, 23 May 2019 23:58:25 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id z1so3874968oth.8
        for <linux-mm@kvack.org>; Thu, 23 May 2019 20:58:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=f6c9m1oolNz7qnNp31NpIo+ILEox6NGu8lwYyMw+NLU=;
        b=Tp8e62zrmuPGRiekR3MyBc8zu2OubGEjd8wnsYeTFj/notY2DE7jetQkF1F6DVJcaK
         yrGTLHgLYQ+DL5me4iHTNR3LhMA3Qm+1fUb95Sd7jiKJNdqH9a2gMErZeeY7oOcyg4gN
         kEvgJyYQe3/n4NYMYS5IVPoqAzqqZhub8gQhkmpsCEerXRRXnx7x82/VwM5STI9LnnFq
         8u6z3SsM6BOdSuqlQ9elsRKi0l0q2huaf1aGGMQLDI9pdlMUn/TAdO3g7v9gd7vIraNG
         leDc79rsi+gPXUjiqRc7FSIOcYnGB1NUQNxflnjfgCByGW8TyWC59t5j406isc+uIEU0
         u7Og==
X-Gm-Message-State: APjAAAUw5gPQCTpnqK58nxuffoJWOGdN0HgA+K8E+PUtGIi8D6t99g1H
	z7+Cmc/gK5C8skhnCTCaNhjsyqYG8ijV+KLCmcCdeZOJE5jLl85dfJ2P12CBegKm1zli8tXR6nl
	9bw7pmKZ3cKOapJGr3FyEjJdALTnGfZN8vS1TZR/G58I7GrzfAw51hjXUWsjHvehyHw==
X-Received: by 2002:a9d:640f:: with SMTP id h15mr13757258otl.338.1558670305345;
        Thu, 23 May 2019 20:58:25 -0700 (PDT)
X-Received: by 2002:a9d:640f:: with SMTP id h15mr13757226otl.338.1558670304355;
        Thu, 23 May 2019 20:58:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558670304; cv=none;
        d=google.com; s=arc-20160816;
        b=O3i3y1Zyks4ATcGZVhO/Jwsaz4hvvFX6hDFacg5qHbcLc11dyTf5DP9L6NBlEFf1EQ
         Rtu2xLvcLIct5H2w6D5+yWYmyjJKtsKXHcNr/YIuce95GHidSdaYvQsLPc9faEyZPZpM
         ANLv2B1seKf4K7YHlNFuY6jGIDlcFhbcZHywGaSXByiJwSG5QbJBCWM3MqYWhZCiqF5I
         ASEw0R8oVTmB3i8sx7T6Mlx6BQKTS8IhlpOtfMVleB+luYTFIY2HD7rq61uRez7ElB1d
         o71uJR56W88djrPN+BsVWf5CrMSJIgAx3EJJq1SkaZk0qSfAqiVrraWnWvQqAA15yJgf
         neag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=f6c9m1oolNz7qnNp31NpIo+ILEox6NGu8lwYyMw+NLU=;
        b=iJGVbkto5Er7g69VYplWAXEDz1B4L6QhJUpJoJjFtNt06AiujZl8uNU1pe2xhhOTp/
         WyAHbHxxKimpyxuEP/8x1aqUpNx19ElnPqznXxh7qxad/mfjQHQwUH0TgDps8MxjyjYs
         HGlcJJdQmJ8TfxNJHKCV6l8CUnn9rmPrBCsTX5Wp4OVaebirVCXXQPDzoH53scgpNxuj
         S8NfP8+7To2Fbr4biKtYjEFAIicClVRxUo3EUNGYikDEmvEO21d6kNZUT+emkqLhKd/z
         WqncUDAa2hi+rAOoZ8u2QU9Bpa62OgylF2PlkylNBcrmKV1QiqUBjyaYn3hUdSsuvbjy
         cRUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Qs74XkHj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s13sor553142otq.14.2019.05.23.20.58.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 20:58:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Qs74XkHj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=f6c9m1oolNz7qnNp31NpIo+ILEox6NGu8lwYyMw+NLU=;
        b=Qs74XkHjFhIG5eWAqZuHInffVvs+3AV05OrIpZ2xTnqAoDqX14pggyRk9f9DKHpuSs
         IRIBA2Ri/L1Hws5vXuO4/80WJMPdl81Bfp9VTtv6MkS+yeMMugK5uHJSDrPNnXcruuw3
         fJM4itI1+d6xJhugS2SaMdwDq6lT+66DbFSttJHrPC9+6vC2KDSJ8ido/7gjDGJXyt6f
         Eli8t58rYv3qybUABQC+8jQRyJo3F65nGswTPDcjH5BfeMOzlFdaSN0IOzN5j/p+fvgV
         4gO7UElauHskekm3kCMewjQB2ilKCmqgQOr8DJjZu2CsqzL0iuxZTXFDWF/JNWUVpQX/
         GcNg==
X-Google-Smtp-Source: APXvYqywpzGD5Aa+i2XlHKnDBTwl+TOaDWcG21EMI6kjm8dn1v7UUbbQbcsfdcmnB3N5ud5QB84Okj6zu4K2XRFRUpg=
X-Received: by 2002:a9d:6e96:: with SMTP id a22mr4573516otr.207.1558670303779;
 Thu, 23 May 2019 20:58:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190523223746.4982-1-ira.weiny@intel.com>
In-Reply-To: <20190523223746.4982-1-ira.weiny@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 23 May 2019 20:58:12 -0700
Message-ID: <CAPcyv4gYxyoX5U+Fg0LhwqDkMRb-NRvPShOh+nXp-r_HTwhbyA@mail.gmail.com>
Subject: Re: [PATCH] mm/swap: Fix release_pages() when releasing devmap pages
To: "Weiny, Ira" <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 3:37 PM <ira.weiny@intel.com> wrote:
>
> From: Ira Weiny <ira.weiny@intel.com>
>
> Device pages can be more than type MEMORY_DEVICE_PUBLIC.
>
> Handle all device pages within release_pages()
>
> This was found via code inspection while determining if release_pages()
> and the new put_user_pages() could be interchangeable.
>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  mm/swap.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/mm/swap.c b/mm/swap.c
> index 3a75722e68a9..d1e8122568d0 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -739,15 +739,14 @@ void release_pages(struct page **pages, int nr)
>                 if (is_huge_zero_page(page))
>                         continue;
>
> -               /* Device public page can not be huge page */
> -               if (is_device_public_page(page)) {
> +               if (is_zone_device_page(page)) {
>                         if (locked_pgdat) {
>                                 spin_unlock_irqrestore(&locked_pgdat->lru=
_lock,
>                                                        flags);
>                                 locked_pgdat =3D NULL;
>                         }
> -                       put_devmap_managed_page(page);
> -                       continue;
> +                       if (put_devmap_managed_page(page))

This "shouldn't" fail, and if it does the code that follows might get
confused by a ZONE_DEVICE page. If anything I would make this a
WARN_ON_ONCE(!put_devmap_managed_page(page)), but always continue
unconditionally.

Other than that you can add:

    Reviewed-by: Dan Williams <dan.j.williams@intel.com>

