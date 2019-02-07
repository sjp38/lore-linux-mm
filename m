Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 193B5C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:03:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA9242175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:03:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GjiAT/gI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA9242175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C5DA8E0044; Thu,  7 Feb 2019 11:03:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 675A48E0002; Thu,  7 Feb 2019 11:03:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58C5F8E0044; Thu,  7 Feb 2019 11:03:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF04C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:03:02 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id c17so75825ljd.22
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:03:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XbhO6aTIpP/xPNM6je9v7tcpC/w9vjx4259+gRxRQwc=;
        b=amMnL5uHEWN3HBcZiL9h/URv8wbvAwsp5ekWerDQQskUlN42Cwq+ZxGrSLkC3XGQfg
         Z9y9rqoEWZ/zSafw4qDa3lqRkHdRI0P+FzEKI2U5wjV3J4XTGPRLYLejEQqnUfzslSMB
         Uy2JgBlIa++3hOScAbk12mvzPEZV1AvndpBtULOUCOHX3VGbUyNvEgzDGP08th22Pkbl
         R1t+df+bI3pJrLcmyMo+QJwTVKg4uWnjWtaV8IY/TcO655x0L4Aq0T1a7Na0xSzpfCwU
         yaV7J7vOnvMwBeGkIx3n/Us2xx+N/y1JYJg7tgRiHmA/uf155aYXXPgk5/64xW2kOroz
         uydA==
X-Gm-Message-State: AHQUAuYlLg23LUuYzFuN88rZg5iyZ1PvNs35tituOohE89mcXYCwp1Ca
	WFXYsYucLU/ZXpf/90cA4D4oih6QmEdqQVSsqIEpV374KfDD7Mf3sDIBDdg0SgxDQDg34UQxSG2
	hYtJ5BImHxQDDt3wFCCA+lreSOV5QjzCvvoFmakMMpkFnge79mu/YMLBl0+wZI6nCdkiZJmUDjP
	0HXRffkn+kJxjmP56XQPKpmgZXAnYzvoOuII9xS9r3ggcCSk9POF7vbz2sqiIvNdTiG2FdBB9Mx
	9yXRwp4pe4IVn0804ll1Yg7yyIBGGyRrThGzNljtC2r+h2yZeFgLYi3fcxqjpUjBdsAlnvDvwsg
	5R6P1ySA5XhCtWhAnBWB5EvbWlvgC9y87Y+uFZ3lKRYQ4pveVc6RgL+tKLagxTnO30MabPXaGV/
	f
X-Received: by 2002:a19:a411:: with SMTP id q17mr10492528lfc.160.1549555382157;
        Thu, 07 Feb 2019 08:03:02 -0800 (PST)
X-Received: by 2002:a19:a411:: with SMTP id q17mr10492484lfc.160.1549555381206;
        Thu, 07 Feb 2019 08:03:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549555381; cv=none;
        d=google.com; s=arc-20160816;
        b=phZKFnyCwZh2CQ6YtVpbG2jfO/kQ5jrAvPGYsMQfXJwumYy8ibVJj0chvn/EknQ9Ko
         370EAy+wx8hJqBsx6vCVNf56rYCCkJsB2G1AIxSdJunyWGxmYOdTNB2zYHhrlxuZku3J
         9eTz7ckpH/LG16vZPIUY3SFOQq2SJdRaIoIQDptEfEracaq2xxe9/gHS9sz2jape4FDf
         YFCDCyF5/lPNI0ABMgOzWdKZ58MUVlQV/6QAuuu9kTIQUdaJSaS2Nhp/qP5EgITEA+Qq
         vSqySN6WSbUutGGdCjncBJjpAO81pdk6ApVADraPySOgbCym2VH3/3eIfr7uCv+d1+fY
         553g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XbhO6aTIpP/xPNM6je9v7tcpC/w9vjx4259+gRxRQwc=;
        b=gj2HcQ0p5XrKVFeXjVm8qmmQcxtZc2J87tgrdf1dacYJA6Znz5Evd2hioUlvN5OVan
         kFJDEbZzWDCpGS5qq8CNAfJX8eXNwtwsLHaSX2POK1VHTVmxfc+tvk77EafzYA5NrECj
         aeTaWOBaOVeLaB0xXQLy/RhxIIRXJiUrWhjut4ShDCD5NPmkCeTrQ/gRuqRC9IDW6Gm6
         JeriLShP4nofd4NDhnWVYgr3ybqgRr1DsleUSc9e2O2G5cSg4KM69ORpg9nWTC+Z193U
         tjL2NCrG8hSq7ihpGqJ9zFKgXW9F8wRXPkHvn5Sdz+PeVHRlCbUP1LaYILUZ+T2t0rG1
         ZrLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="GjiAT/gI";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z4-v6sor425904ljz.22.2019.02.07.08.03.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 08:03:01 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="GjiAT/gI";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XbhO6aTIpP/xPNM6je9v7tcpC/w9vjx4259+gRxRQwc=;
        b=GjiAT/gIsh5Mq6FaeJOcXRPVS+aPNNLKdv+19jCUnMwmRGIdhLqn3qDw/4sBtvN8Hh
         ju5PXYuad3zjRdl4YnH6xybt7cBkrbmeOnKARIuUOVU23QxAGpMC+Hdo6To4YYz20SdN
         KcTwZZWk54YH7U7nqUwLwSjiM9GATvQyhZUXP3zIoYmhVtPcGhqivpfFt5hrHNrlLnxo
         tIyWz8GH0zeVk4l5jxYZ+30lNxdS11GYkmxBwZke/ifmkSt1cGDnrqxpSjof3u8Ym6Qe
         fsNkAS4OqyhqNSBKMi847x/GuItYvXS/zeCBaX1OV5BcJ5lVqZztpXRUYwokbPHyzTQT
         Yr+A==
X-Google-Smtp-Source: AHgI3IaLErP6UQHRoJXwjaGn0+byhpg0FJEkJj8lu4LnRPheskg9h3w2v7B+w3vp6ap3L+ni8MOMEGmZGFdfVJFI55k=
X-Received: by 2002:a2e:858e:: with SMTP id b14-v6mr2729099lji.43.1549555380735;
 Thu, 07 Feb 2019 08:03:00 -0800 (PST)
MIME-Version: 1.0
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
 <20190131083842.GE28876@rapoport-lnx> <CAFqt6za9xA_8OKiaaHXcO9go+RtPdjLY5Bz_fgQL+DZbermNhA@mail.gmail.com>
 <20190207155700.GA8040@rapoport-lnx>
In-Reply-To: <20190207155700.GA8040@rapoport-lnx>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 7 Feb 2019 21:37:08 +0530
Message-ID: <CAFqt6zbE0JD09ibp3jZ0rr5xp52SEK+Pi6pGMQwSp_=d0edy7g@mail.gmail.com>
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, 
	Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, 
	Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, 
	Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, 
	joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, 
	mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, 
	linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, 
	linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, 
	iommu@lists.linux-foundation.org, linux-media@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 7, 2019 at 9:27 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> Hi Souptick,
>
> On Thu, Feb 07, 2019 at 09:19:47PM +0530, Souptick Joarder wrote:
> > Hi Mike,
> >
> > Just thought to take opinion for documentation before placing it in v3.
> > Does it looks fine ?
>
> Overall looks good to me. Several minor points below.

Thanks Mike. Noted.
Shall I consider it as *Reviewed-by:* with below changes ?

>
> > +/**
> > + * __vm_insert_range - insert range of kernel pages into user vma
> > + * @vma: user vma to map to
> > + * @pages: pointer to array of source kernel pages
> > + * @num: number of pages in page array
> > + * @offset: user's requested vm_pgoff
> > + *
> > + * This allow drivers to insert range of kernel pages into a user vma.
>
>           allows
> > + *
> > + * Return: 0 on success and error code otherwise.
> > + */
> > +static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > +                               unsigned long num, unsigned long offset)
> >
> >
> > +/**
> > + * vm_insert_range - insert range of kernel pages starts with non zero offset
> > + * @vma: user vma to map to
> > + * @pages: pointer to array of source kernel pages
> > + * @num: number of pages in page array
> > + *
> > + * Maps an object consisting of `num' `pages', catering for the user's
>                                    @num pages
> > + * requested vm_pgoff
> > + *
> > + * If we fail to insert any page into the vma, the function will return
> > + * immediately leaving any previously inserted pages present.  Callers
> > + * from the mmap handler may immediately return the error as their caller
> > + * will destroy the vma, removing any successfully inserted pages. Other
> > + * callers should make their own arrangements for calling unmap_region().
> > + *
> > + * Context: Process context. Called by mmap handlers.
> > + * Return: 0 on success and error code otherwise.
> > + */
> > +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > +                               unsigned long num)
> >
> >
> > +/**
> > + * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
> > + * @vma: user vma to map to
> > + * @pages: pointer to array of source kernel pages
> > + * @num: number of pages in page array
> > + *
> > + * Similar to vm_insert_range(), except that it explicitly sets @vm_pgoff to
>
>                                                                   the offset
>
> > + * 0. This function is intended for the drivers that did not consider
> > + * @vm_pgoff.
> > + *
> > + * Context: Process context. Called by mmap handlers.
> > + * Return: 0 on success and error code otherwise.
> > + */
> > +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> > +                               unsigned long num)
> >
>
> --
> Sincerely yours,
> Mike.
>

