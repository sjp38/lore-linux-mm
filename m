Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82C85C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:09:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 274202085B
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:09:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ieee.org header.i=@ieee.org header.b="J3oCes5O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 274202085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ieee.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCA5B8E0004; Thu, 31 Jan 2019 11:09:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7B698E0003; Thu, 31 Jan 2019 11:09:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B687D8E0004; Thu, 31 Jan 2019 11:09:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DAA78E0003
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:09:47 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id p124so2854984itd.8
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:09:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=UZDhNb4sVXnlVoRkQvj1z4u9Zv5cFgKlz/b2lxRaoPI=;
        b=H6aIupw/svx6ODkIGT6TnWKpy7KrygBbTDiNHnLJNsvaPDRTmMVt8kxP39aTELFoEj
         TTyiOIOkUo9aA5Z2nPF0ssEdpXFWIWEdj9bTBIbo41fj/FOsEwcoLMzZOKMZXRxSfi1k
         xprn3BITu8lWGyFV3w6I97h6zF+Je/gyAmEV3+E/6lvRhDrZJgRr6eEpLT7MhUnNwNUM
         ed/c3zn9PHAMh/xw0WpsZNnRT7nIkJc78Uefv5VMeuymXtzl3Ag7hqxCROaojLc57NRt
         mdxrCC6zxT4Y5Uz4ylXB7HVzlFk+iXeYyyzXITCVm6D6m/jJnVUFKzkC/oUBjX2SyAZo
         /5kg==
X-Gm-Message-State: AJcUukfaGnwgc4pa3kr10lUtgj3QIInJlovirqaplSrFpVKPeGvCuvZP
	KuES6gnZoY/ZoCKTK/oFV+gfRrySRpIQSXjpUT7fpWAx3jfBA+bPDsxwmYtZ6hTfrqlDS7zxpeQ
	R05u43P4b0uWKiDH1a0mHEuV+mJxuM3OnSfLnDCNM4uvp/jXI3c/xjjrZ6Z3xEEy7B4FipzeDkL
	CkNXaZsz/l9kOO7mE/sDH3qQqAPW5z3nYOkrHXHYUFxWCRoCcrV3ZHKfd2wY1olCwguFOq+cLY8
	2NuPIr5lPT4FWUa+GB9YnFKthTNKoDxDTZ4P5NArqM1Pt4sPRXfpT0QKk7nIdtz5MecTCK++rXQ
	Svp5fXf1qrp1NtkSYJLUqwbUh18WsdBEibZNwhi9Jr7jUGV1TAEgRavGHPq2Fg1WDVDyp9G9ZG/
	1
X-Received: by 2002:a02:570d:: with SMTP id u13mr21568636jaa.71.1548950987330;
        Thu, 31 Jan 2019 08:09:47 -0800 (PST)
X-Received: by 2002:a02:570d:: with SMTP id u13mr21568597jaa.71.1548950986544;
        Thu, 31 Jan 2019 08:09:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548950986; cv=none;
        d=google.com; s=arc-20160816;
        b=gUxd3fLYsB3qBLa7f/M+kmtMZWoiLxyDlF/7mkbXIMxuUjMUiuQAf8S8dGhT4EZ9i/
         hzHanVu1uu7iaI8+Ueq5rMeR0KTBYrhYqwqNRjhFvf1QPgLfJ5XJJ0vZQz34IYdWb42v
         g95DOX2zc+/RGVfBvoDPJ3b7I9HhzySxeqi/tLEKJnJL8PPKW7vWeul4v0HCy7iGMnmu
         qiW2GWb6GzGa7O5pIgZdL7qXEe+S0L4EE9HQizAO0z3jpvcrksU4WkuhGo0I3HjjJ10u
         FVgLPnnI8ryXZFPISuJ7JB7MKcU+GJ+fKSJtatqLfq/SLI0/5NgU42GI8mzJAGHXkaZ0
         xp7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=UZDhNb4sVXnlVoRkQvj1z4u9Zv5cFgKlz/b2lxRaoPI=;
        b=sgx9vqcBsgvJr9mdxODVYs1wY9jQhnutyLVbVUY93zxsxC/C80lWrPUjVdqR88V2o+
         ENNzKULdFkN7TBIWKN2yOP/52h50J7Wx4g5IJV++NAGlnpwwE4jj3bYGpLV+QnNY6vFW
         vjbm4dTW+ICpHS6w74a4cOFAIERSZmv4BcxeBKGaD4BtXpbEptxYGTNb+znMBu53QtM0
         MTNES50GnwQp+iMVGCKak/U4NQrWc8c9js2qHSzYNGlChRSl/nInry5NQj8DDewe13iJ
         aCHybZs9FlqCKHykMhYxM9BIP78TKIeGSKR218s5KXwiCM/Z1UWgNd6YsJgYNgcQ56LU
         TMCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ieee.org header.s=google header.b=J3oCes5O;
       spf=pass (google.com: domain of ddstreet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ddstreet@gmail.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ieee.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v192sor9249937itb.17.2019.01.31.08.09.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 08:09:46 -0800 (PST)
Received-SPF: pass (google.com: domain of ddstreet@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ieee.org header.s=google header.b=J3oCes5O;
       spf=pass (google.com: domain of ddstreet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ddstreet@gmail.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ieee.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ieee.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UZDhNb4sVXnlVoRkQvj1z4u9Zv5cFgKlz/b2lxRaoPI=;
        b=J3oCes5OPHB+6WC7iK+6Bv/vJAn/0GRY3kTFJiC1znYpGLb6xldzpM/uW2qPALEQpZ
         Q6DAGAc/VWFUsGjie0B6CnvC3WdDL5Wx5yBNoAFH9G/xbGnTRudXOXlW7bwsV9BsStCz
         y63OK+00cx80Mef8GgK7mmbwNllr75Gh/wnfo=
X-Google-Smtp-Source: ALg8bN5qFLcdLOpTE2pGibV42YVQjE5QLQrQnNLCf+DjrvQhpaeRJgPXfQVNu1buofq1DYB/NxRhVXHBDAXeFOdf4rs=
X-Received: by 2002:a24:9dce:: with SMTP id f197mr19131102itd.13.1548950986086;
 Thu, 31 Jan 2019 08:09:46 -0800 (PST)
MIME-Version: 1.0
References: <20190122152151.16139-9-gregkh@linuxfoundation.org>
 <CALZtONCjGashJkkDSxjP-E8-p67+WeAjDaYn5dQi=FomByh8Qg@mail.gmail.com> <20190129203325.GA2723@kroah.com>
In-Reply-To: <20190129203325.GA2723@kroah.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 31 Jan 2019 11:09:09 -0500
Message-ID: <CALZtONBSgcHMLZBAdc3FmGFbVrQhvdWKpKe+ATSuGk8_D=QP_A@mail.gmail.com>
Subject: Re: [PATCH] zswap: ignore debugfs_create_dir() return value
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 3:33 PM Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
>
> On Tue, Jan 29, 2019 at 02:46:30PM -0500, Dan Streetman wrote:
> > On Tue, Jan 22, 2019 at 10:23 AM Greg Kroah-Hartman
> > <gregkh@linuxfoundation.org> wrote:
> > >
> > > When calling debugfs functions, there is no need to ever check the
> > > return value.  The function can work or not, but the code logic should
> > > never do something different based on this.
> > >
> > > Cc: Seth Jennings <sjenning@redhat.com>
> > > Cc: Dan Streetman <ddstreet@ieee.org>
> > > Cc: linux-mm@kvack.org
> > > Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > > ---
> > >  mm/zswap.c | 2 --
> > >  1 file changed, 2 deletions(-)
> > >
> > > diff --git a/mm/zswap.c b/mm/zswap.c
> > > index a4e4d36ec085..f583d08f6e24 100644
> > > --- a/mm/zswap.c
> > > +++ b/mm/zswap.c
> > > @@ -1262,8 +1262,6 @@ static int __init zswap_debugfs_init(void)
> > >                 return -ENODEV;
> > >
> > >         zswap_debugfs_root = debugfs_create_dir("zswap", NULL);
> > > -       if (!zswap_debugfs_root)
> > > -               return -ENOMEM;
> > >
> > >         debugfs_create_u64("pool_limit_hit", 0444,
> > >                            zswap_debugfs_root, &zswap_pool_limit_hit);
> >
> > wait, so if i'm reading the code right, in the case where
> > debugfs_create_dir() returns NULL, that will then be passed along to
> > debugfs_create_u64() as its parent directory - and the debugfs nodes
> > will then get created in the root debugfs directory.  That's not what
> > we want to happen...
>
> True, but that is such a rare thing to ever happen (hint, you have to be
> out of memory), that it's not really a bad thing.  But, you are not the
> first to mention this, which is why this patch is on its way to Linus
> for 5.0-final:
>         https://lore.kernel.org/lkml/20190123102814.GB17123@kroah.com/

Ah!  Great, in that case then definitely

Acked-by: Dan Streetman <ddstreet@ieee.org>

>
> thanks,
>
> greg k-h

