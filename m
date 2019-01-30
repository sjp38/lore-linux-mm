Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F84AC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:00:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF7BC2184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:00:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B2ri7Tjm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF7BC2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 743CE8E0003; Wed, 30 Jan 2019 05:00:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71AB68E0001; Wed, 30 Jan 2019 05:00:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6302D8E0003; Wed, 30 Jan 2019 05:00:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id E96FF8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 05:00:08 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id 2-v6so6749301ljs.15
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:00:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/ahPDIIFv/MMPOGpeZxT3pmApwBNz3CD4N0VP4gKld8=;
        b=oRIqcET+n0309JT1ATUlkguLfcRlMC+kJWWsC6T4YWR0Dt/txBDTG/GuB7gKq1YkMJ
         OBCEHwywXJwEUFDB0rqtNK2suhHeASM8BX/8CmqyFs1U4dqkJLuzAGWtuCdR6UBBIwkD
         ryk9QJo7aC2+g7/pJzeHRX60iW+6NGPna6QsFjYNNvTYPX4KlKeOL5ps+FLUa86DiaT5
         CQEfprOmYUSkBpg3sL25R0MLz/uUhoCJTfYzb+8N8FKatyhfwFjM9Ar3B/Xe5/LGLUyi
         sWjMvyEko5zLgyKXFqZoYOJjNySD3xoxrJBUYUC2/EDKuR9C9jPHLX6SGc8WiDNzi54V
         sZkg==
X-Gm-Message-State: AJcUukcrw+AFtHzPyFc8nNXyYTpFaRH6V2VlJFiwWDeDTEk31wBUHQAL
	N4hKN/2z3MDLe21EtNAgtLk2LpSeAVoOepXfBm1dTpOusGMMdHLP+nV0dl/nK7hIpb1eHyIpXkU
	/P9wCvxwfcsXjLRmm0UBicRZAxmCxMt7mwmn57xXLmMsAVnh/u0ZXdrd9vTzEVBQ5faLUv7Lbx8
	zIruVdWP2TMOhptesI63mu3yKcVpATzluFALaPGMJuMLDF0rDdxMNGvEbtSgEPVubsY/EePxMqu
	5mcW8XC6Zdc932iDx/ZNP8rzKLsskDdlhNxjWF9DfVq+eYUF8zFnd//CRlBO3eaR15PAbs+Eyb5
	QcopAFvAeIsV8Zjq2YHxmY8gEegaJoECQylNn8XCzYYg0ki8hzNUjGUNLvpbkAjh3BqoN9t9bnD
	1
X-Received: by 2002:a19:5d42:: with SMTP id p2mr22617987lfj.83.1548842408392;
        Wed, 30 Jan 2019 02:00:08 -0800 (PST)
X-Received: by 2002:a19:5d42:: with SMTP id p2mr22617921lfj.83.1548842407307;
        Wed, 30 Jan 2019 02:00:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548842407; cv=none;
        d=google.com; s=arc-20160816;
        b=vCHLX/lAGiy6wR31S+57VETZs8pJmbrgV0qmHYxLH0/SnOlPKsGnUEl+bT3c8yHUsG
         E9qZRs2eV+1epFMloXBLJvEX+RDYaetO4DdPwzxYQEDIyxpDa/CpjMf69NJGNzEU5nbB
         YJ216pu9snNzv6iGab5XWOv05JBE5/xLX0+RORwWOCWJrb4XpNNEyTYEDYU06qu0FvQE
         0fjFj4UWJfRoUpEzcxEK/1MWk2G7JFzk6bMiAAw+v2APNOdFFPYQtBJg4QPDBIUDexbS
         x0kIOiRkFUnJPnulAQxiF9R5CMADkOYV/th6Q5KQWOs1nOpmbLE2MqQ3Qvwc5AOSkzWu
         Ngiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/ahPDIIFv/MMPOGpeZxT3pmApwBNz3CD4N0VP4gKld8=;
        b=Ndvq/+a6RWoJzhgH40RTx4odxnFbDx+g7GyXKe5iC5h39YjUEmBjXGp6hXo4fwR1mQ
         RmRef/Z1f4GRcTg6TEMSh31ccEJT0y2sZjBdKAPyDgciazG7S59WivfWC+PkFBC3ifgA
         +Rn3c+aIBL/AddIyVCu8vQ7zSuXX4nU9jvy/6F0sXR+XdOz+++KufdEbgClwf/QGUglh
         zZNClC5C7f34C5+AZlqgWIWcGdkh5pjxAYY77qSpOgzYR6UEdhdM1G7PAyTyg3oR/ndW
         Sbv4UYjtoas2Ir2+e0r19/e4xVFkWSvrzdUCpbIv8f8OySA1OLDxwCY2S0mYsSjBrM0A
         fYxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B2ri7Tjm;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1-v6sor725073ljg.10.2019.01.30.02.00.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 02:00:07 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B2ri7Tjm;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/ahPDIIFv/MMPOGpeZxT3pmApwBNz3CD4N0VP4gKld8=;
        b=B2ri7TjmimvAXTVQ6NpGSwysKvPv1hRX+3Oh7rms+F5kl5dzWJHrIFOwJuF4qThTKO
         I04XKp6YookGQQmu5HRlrq8WM8/edqRbmryusF30k9Tmj3RyeHRH1aMeSyc+mATq5BgQ
         Z40SqAe9+PkppudAohfQEIxSSDOoIhBa1tFqVWxK3HgblGGMvyid0d57zye3T4U5GjiD
         3sUbwI3/bkTL+5Nm02NbviKLld0N+TdVirbLuwg+Dmh71heG9+55XVbxGeryWKgXNc5x
         +lferOF3M5QO8an0Kmgzwnfy9oM1GjM2QE8henvXUlnxEA9X8MLoUvsfFTLfaXycLlZ1
         h1Sg==
X-Google-Smtp-Source: ALg8bN5A2L7T88ZjEk542s9LF+gJzDLfcz24saQivM+b0ybEgO7nrHTut38OlFHM6aQVTbEJTgLEJ+q5EvHTEynOpcQ=
X-Received: by 2002:a2e:8643:: with SMTP id i3-v6mr25670564ljj.43.1548842406798;
 Wed, 30 Jan 2019 02:00:06 -0800 (PST)
MIME-Version: 1.0
References: <20190111150801.GA2714@jordon-HP-15-Notebook-PC> <CAFqt6zZx9qxx_Xv=n-PY45OvS7E8ZBq+ZqaeEKfsaCirwaASSg@mail.gmail.com>
In-Reply-To: <CAFqt6zZx9qxx_Xv=n-PY45OvS7E8ZBq+ZqaeEKfsaCirwaASSg@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 30 Jan 2019 15:29:55 +0530
Message-ID: <CAFqt6zboe40Ss6C6h9zhkO71pxKOkA1zV6OrH-+aU3-1yVzeWA@mail.gmail.com>
Subject: Re: [PATCH 2/9] arch/arm/mm/dma-mapping.c: Convert to use vm_insert_range
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, 
	Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	linux-arm-kernel@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 25, 2019 at 11:54 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> On Fri, Jan 11, 2019 at 8:33 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
> >
> > Convert to use vm_insert_range() to map range of kernel
> > memory to user vma.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>
> Any comment on this patch ?

Any comment on this patch ?

>
> > ---
> >  arch/arm/mm/dma-mapping.c | 22 ++++++----------------
> >  1 file changed, 6 insertions(+), 16 deletions(-)
> >
> > diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> > index 78de138..5334391 100644
> > --- a/arch/arm/mm/dma-mapping.c
> > +++ b/arch/arm/mm/dma-mapping.c
> > @@ -1582,31 +1582,21 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
> >                     void *cpu_addr, dma_addr_t dma_addr, size_t size,
> >                     unsigned long attrs)
> >  {
> > -       unsigned long uaddr = vma->vm_start;
> > -       unsigned long usize = vma->vm_end - vma->vm_start;
> >         struct page **pages = __iommu_get_pages(cpu_addr, attrs);
> >         unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
> > -       unsigned long off = vma->vm_pgoff;
> > +       int err;
> >
> >         if (!pages)
> >                 return -ENXIO;
> >
> > -       if (off >= nr_pages || (usize >> PAGE_SHIFT) > nr_pages - off)
> > +       if (vma->vm_pgoff >= nr_pages)
> >                 return -ENXIO;
> >
> > -       pages += off;
> > -
> > -       do {
> > -               int ret = vm_insert_page(vma, uaddr, *pages++);
> > -               if (ret) {
> > -                       pr_err("Remapping memory failed: %d\n", ret);
> > -                       return ret;
> > -               }
> > -               uaddr += PAGE_SIZE;
> > -               usize -= PAGE_SIZE;
> > -       } while (usize > 0);
> > +       err = vm_insert_range(vma, pages, nr_pages);
> > +       if (err)
> > +               pr_err("Remapping memory failed: %d\n", err);
> >
> > -       return 0;
> > +       return err;
> >  }
> >  static int arm_iommu_mmap_attrs(struct device *dev,
> >                 struct vm_area_struct *vma, void *cpu_addr,
> > --
> > 1.9.1
> >

