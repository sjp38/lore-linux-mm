Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DE1BC282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:48:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD090217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:48:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Rn1w8rrq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD090217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 529DA6B000C; Fri, 24 May 2019 11:48:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DB506B000D; Fri, 24 May 2019 11:48:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C9936B000E; Fri, 24 May 2019 11:48:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2816B000C
	for <linux-mm@kvack.org>; Fri, 24 May 2019 11:48:44 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id v16so4653850otp.17
        for <linux-mm@kvack.org>; Fri, 24 May 2019 08:48:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=VnZfOS1iwVY/y3S5ygO9n8yXSXom1QPOKMwgmm4Nkio=;
        b=byW6sfG4Fsz4wiBJSG014sGIoEdomHWtd8PA4DyxFKfD8Rxy6wRKQxq3Wi3NEgpPhJ
         Ngp75xLHFT0ltmZ23EH5Kp9OfU0P8H2Zm6eWotjBuB+ywrv/c7U39qNxKKwXbuP+fraN
         jBQz7+3HJMNxV/bR9YdG8ODyMwp/aZApcu5TUJ695farC+7nvjTX1C2JfkKQmnNnHM6g
         D+GsRIolPdUMY/bB9DWucQCnqfAdgr+DyCg8LB4AetXnkPYWK6sxrfc10IxQycinm5lO
         ImeS4ZvLMM76FQues63Pe/5SZStVJWxEWbatMZeIGZXxi64y1iiaZpV6rfu3Sx5VeUvg
         dWqA==
X-Gm-Message-State: APjAAAWQaxAzSq2HfLXxUAOTzykZWRB5Qirsxmb/kIw6ci3mF/6dubB/
	S2C5WlCO9QweIXSV1IiU0xWMj251Yu4fkRkmrql/3pkuzIDI33pSLPpobcUqYMWoq2G8w6o+xrz
	Jj4PMaDC4Gs6abePYjDDcc+GugPhjmAcYR5UecI9m7zhmtJN76s+1buZmNXeLVtDzkw==
X-Received: by 2002:a9d:32a:: with SMTP id 39mr44584060otv.228.1558712923674;
        Fri, 24 May 2019 08:48:43 -0700 (PDT)
X-Received: by 2002:a9d:32a:: with SMTP id 39mr44584012otv.228.1558712923096;
        Fri, 24 May 2019 08:48:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558712923; cv=none;
        d=google.com; s=arc-20160816;
        b=KEEQSSQD41+pJ04Jl0xdOBSV+aXFETlYDIBbWipUswA+9JsXGCvgKxUYgLpTDB41VS
         rpQPkYl6eqn9Rl97a77qSIMfTuGkyIh0vcQr8eBLXkm8vxDvYEVno49z5gChxsWeHWy3
         ufhr0fE2WQjFfpCl6zlZjHHJX/LFwi/3SemYUQeVViIs4MC7Qjbln9ZfgERnuZrAAEHn
         1ujDTs4Tq1KNDOZ51hmduIQHApo6XzhMMO8Ho+bv+Z+LxF7uvZ+b/xsWDNdoR5zBlM8T
         rYk017weu+RQVGt0sbI77e8yZl0Kl2o9/NIEDSTpEgZEU1iAD3Q558sFx7enQajwV+zw
         UCIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=VnZfOS1iwVY/y3S5ygO9n8yXSXom1QPOKMwgmm4Nkio=;
        b=KPwqG3UnoSP7zNK8IM3NkMicWxhChc8wJxJq2vF3jMh83L4r2ExgKQNi7fzsXVzOOF
         9fPk+oE013p8AbwqOhwRbYHaDJmgaDhnOMJDu1cYtLUlD54shlQ6nhX33MaW+OEXqE3W
         V6+HJ/k2jJKvWhqKFZPCj68t1ie80hMFupxREK5q+sJx/Davkt0tCxBLkxqtSeZbF7Em
         gSGokgoK7O7rjebuEGKmLvpYRmxZpubFR6aAXlztGN+6dLoN4baYluLHVpUHytLiZSOQ
         dR7bsmHAdvuI4w8RVmzOUsJshTbb667HTuPcfI1dFr40UhiiP1XJeXeClWA40LgVeaAY
         nGEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Rn1w8rrq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j66sor1138738oia.126.2019.05.24.08.48.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 08:48:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Rn1w8rrq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=VnZfOS1iwVY/y3S5ygO9n8yXSXom1QPOKMwgmm4Nkio=;
        b=Rn1w8rrq8jnqx+HnE9zs1bnGB0aDFB9M0RNzuGCNQxPDSvCjbZOLE/1/8l6w3jwS6V
         pmEZtLZqA1fmX11DldIiqC8w3eAWCNOn4/08jY4rmP1pCZJ9hrnoVvLAfyQP+nje0T10
         bGM7I4GosQwiCSD7vKCWa1RcNjBZv8Qr+KhCN+J8gkVBXvT7DPy2LVo97iuxRsREsnFD
         8ucA6KSgdfbUysB6hJuvkhTgO+XsMrjiV4fQ587UBx/kLhvb3YBgtTM4RL+0fTheleTt
         ql5JfvYfCMPOHAd9oHF1+7a45IA/oyBjb855gQdQf5OQivqCLy1zIlTBnTMkC0G99uw3
         Bm4A==
X-Google-Smtp-Source: APXvYqyW4iOkpvEW07bkloS7q8ueiELOVVaDniEHBFWvpgPMKVs+sfmDFFX+MOSdAC6C6h4JfkN/ao+FJlBeTpW2WMg=
X-Received: by 2002:aca:ab07:: with SMTP id u7mr6444454oie.73.1558712922804;
 Fri, 24 May 2019 08:48:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190523223746.4982-1-ira.weiny@intel.com> <CAPcyv4gYxyoX5U+Fg0LhwqDkMRb-NRvPShOh+nXp-r_HTwhbyA@mail.gmail.com>
 <20190524153625.GA23100@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190524153625.GA23100@iweiny-DESK2.sc.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 24 May 2019 08:48:31 -0700
Message-ID: <CAPcyv4gtYws-csDXSEzyL4UUQtD8iDgCC=m4vk1x8fFqF9fttg@mail.gmail.com>
Subject: Re: [PATCH] mm/swap: Fix release_pages() when releasing devmap pages
To: Ira Weiny <ira.weiny@intel.com>
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

On Fri, May 24, 2019 at 8:35 AM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Thu, May 23, 2019 at 08:58:12PM -0700, Dan Williams wrote:
> > On Thu, May 23, 2019 at 3:37 PM <ira.weiny@intel.com> wrote:
> > >
> > > From: Ira Weiny <ira.weiny@intel.com>
> > >
> > > Device pages can be more than type MEMORY_DEVICE_PUBLIC.
> > >
> > > Handle all device pages within release_pages()
> > >
> > > This was found via code inspection while determining if release_pages=
()
> > > and the new put_user_pages() could be interchangeable.
> > >
> > > Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > > ---
> > >  mm/swap.c | 7 +++----
> > >  1 file changed, 3 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/mm/swap.c b/mm/swap.c
> > > index 3a75722e68a9..d1e8122568d0 100644
> > > --- a/mm/swap.c
> > > +++ b/mm/swap.c
> > > @@ -739,15 +739,14 @@ void release_pages(struct page **pages, int nr)
> > >                 if (is_huge_zero_page(page))
> > >                         continue;
> > >
> > > -               /* Device public page can not be huge page */
> > > -               if (is_device_public_page(page)) {
> > > +               if (is_zone_device_page(page)) {
> > >                         if (locked_pgdat) {
> > >                                 spin_unlock_irqrestore(&locked_pgdat-=
>lru_lock,
> > >                                                        flags);
> > >                                 locked_pgdat =3D NULL;
> > >                         }
> > > -                       put_devmap_managed_page(page);
> > > -                       continue;
> > > +                       if (put_devmap_managed_page(page))
> >
> > This "shouldn't" fail, and if it does the code that follows might get
>
> I agree it shouldn't based on the check.  However...
>
> > confused by a ZONE_DEVICE page. If anything I would make this a
> > WARN_ON_ONCE(!put_devmap_managed_page(page)), but always continue
> > unconditionally.
>
> I was trying to follow the pattern from put_page()  Where if fails it ind=
icated
> it was not a devmap page and so "regular" processing should continue.

In this case that regular continuation already happened by not taking
the if (is_zone_device_page(page)) branch

>
> Since I'm unsure I'll just ask what does this check do?
>
>         if (!static_branch_unlikely(&devmap_managed_key))
>                 return false;

That attempts to skip the overhead imposed by device-pages, i.e.
->page_free() callback and other extras, if there are no device-page
producers in the system. I.e. use the old simple put_page() path when
there is no hmm or pmem.

