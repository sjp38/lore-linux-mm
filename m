Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71A0BC282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 15:49:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1726D20815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 15:49:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CQdUPBgP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1726D20815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98AB16B000A; Sun, 26 May 2019 11:49:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 914C96B000C; Sun, 26 May 2019 11:49:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DC566B000D; Sun, 26 May 2019 11:49:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18EB66B000A
	for <linux-mm@kvack.org>; Sun, 26 May 2019 11:49:50 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id h1so2718655ljj.14
        for <linux-mm@kvack.org>; Sun, 26 May 2019 08:49:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=n4m+LiumTm1QgY7CqTcS7kpSCtNHRS8I7/w8UUQMGTQ=;
        b=DhxfP2WFs6s2jJ6RCeP/Fg6Ef0TKZe75GN6ouf7psEiPUKGvgl9XAu2+ukuWYrP1H2
         7VOZMv9Db4uYbMet1kdq3crpKmRog/6wVUM8w0vro1Dj3JBzgHsQfZYSH36xTIZq/zbl
         vEkqb5TK9q8UDnGeonTk7KD7U9PvVcBSFVAe7RM97UpkdLqPrDzEAR9KJ8DrZPvkb2ur
         OkyEVSJ/RuCZdHda5nZpV8nHn3blR0Bf3ofZEJQK3+Q1wAwWwBtbbVh8K+RZ18LwDXuG
         G4zXDuUAp/VnS2DmlK2W3NgDHSbIFjOy7tWzQzTPPRKA9F8EyFm73TQngPGvqAMK0kQA
         1hag==
X-Gm-Message-State: APjAAAVey2CpPvEdRWfpCPdw8SHj5I7D43Ot/tt3uuuceW9PLlNoXl8s
	D5HWG/NrKHCfFmCD25S0cJmvr1GihOUOoSkMDkHYdKSXl1OycsUuHJEVohxJrAU1qqOrjXbec5H
	3AmbpmjM31JumTSKakKL2hxnv8Y/1fnP1lvoRv9xhuce/w5j1/Rc2MJOw1XTqx0mk1g==
X-Received: by 2002:a2e:5515:: with SMTP id j21mr32105370ljb.198.1558885789546;
        Sun, 26 May 2019 08:49:49 -0700 (PDT)
X-Received: by 2002:a2e:5515:: with SMTP id j21mr32105343ljb.198.1558885788496;
        Sun, 26 May 2019 08:49:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558885788; cv=none;
        d=google.com; s=arc-20160816;
        b=oYnp1pipNKt9Bgolrsw8mlK8UzrVq88zQkTWTd9J9W/PaSbExX4C8VJ8H4HBaQmTH+
         k5616lAhqw4iAbbctgvSpa94hF0iXlbhWvY5hz4xYxJzCPpTmxrJa8Gvyg6fKmKthujk
         bY7wki6F3JFqvx83LmOOQ9Tm0ISBEq+sG97GY1eVlj3B0DSgarO+Jgk1pgKpf0aJg/v+
         J/JyaY5MgRj2nO9n9A/dGi+bqq10a023L058GgdyjXMj8tlZ90VskKm+aRnKzcccEZo9
         ZNv09RgJjEEutwjIzkjaguYKOiJjwS0g3xpHSlAIWtRziAyZmhN6/3K+4B0yEIoLNRLa
         fotw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=n4m+LiumTm1QgY7CqTcS7kpSCtNHRS8I7/w8UUQMGTQ=;
        b=ZSj7ihV4kKUWeYCUYYQ7Hv1o4kACS1gkqaiKBo3SGZQPzb2MBHAmlw1P+LcDuEkAaJ
         Pd7ncWpgNfgjGGRQOLQIMNIEpHmp0hqyrvFJ10esUsJ3VBnHheUTkiVDfPn42yHH905P
         pN+pUqtUyXnXaozlppw4Vc65P0sGXbhL+AmST9vo2NK0nCWRZVhCvaGjGajNfe2kQAZ+
         dELfKCEdZ6yvobbxgTJQ9hdpNYZ5XBQtkTs0YGxg1KBCNsB/7ZG35FIZlg9SHCfFe1eF
         zSZ0LDVAmrxPbTA9nxxnsnqqkuaXXbKYHXX9gLsW8W7wd1fM5+ExlSUaYH7kogg54lBw
         Q1nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CQdUPBgP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16sor457719lfc.34.2019.05.26.08.49.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 May 2019 08:49:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CQdUPBgP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=n4m+LiumTm1QgY7CqTcS7kpSCtNHRS8I7/w8UUQMGTQ=;
        b=CQdUPBgPKphNRWvCidFWM4dXfQ0J88+9ox6K3fgr2GI+OeJMLrnw0+uT8t+2/FogzO
         +PXI/yCxkf5WTo5RRiyfS1cBYUNX309YGN0DpMxcmUjPUCVRHcljTOksbSAGpUuDk3U+
         PujWZGMtZ+hRfZsUitKWI3JkZsLDJo6PGjdPUhupH5nwS8XtU8WuI64wDFYVbJ1z2uN+
         uMQWF8njEJmnj/wa9m6u9qEi4bgB0bodrjLiDK5QopKXqn8Omqz/4vHKWHCylf+mTJQT
         XvVe17GaK8Wpg/EiaHsd2dgtf32iBYPCB1CPcWvOEA+PnnE0BTIYPVEEzgHQLYQKxaW8
         nhRA==
X-Google-Smtp-Source: APXvYqyunb1STqBIBU39BsUSnBhhEnB3LeECVtcncwQGw3Y81kvjw/L7+x7FYetvuwFlF8rgcQz0hZKBwylfkIRbEZ0=
X-Received: by 2002:a19:d1cb:: with SMTP id i194mr55809485lfg.13.1558885788010;
 Sun, 26 May 2019 08:49:48 -0700 (PDT)
MIME-Version: 1.0
References: <201905261855.ag29CM2I%lkp@intel.com> <CAFqt6zYC0vGozczTTtU0YiM-PiREj-VYuq1PexQCPCpn0OwKVA@mail.gmail.com>
 <VI1PR03MB4206678FD979F4855AE26BA5AC1C0@VI1PR03MB4206.eurprd03.prod.outlook.com>
In-Reply-To: <VI1PR03MB4206678FD979F4855AE26BA5AC1C0@VI1PR03MB4206.eurprd03.prod.outlook.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 26 May 2019 21:24:46 +0530
Message-ID: <CAFqt6zZYkGMGsD2XYdoXunD+fDTRs+3MMAoVVs7s2BWQa=nffw@mail.gmail.com>
Subject: Re: [kwiboo-linux-rockchip:rockchip-5.1-patches-from-5.3-v5.1.5
 83/106] drivers/gpu//drm/rockchip/rockchip_drm_gem.c:230:9: error: implicit
 declaration of function 'vm_map_pages'; did you mean 'vma_pages'?
To: Jonas Karlman <jonas@kwiboo.se>
Cc: kbuild test robot <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 9:07 PM Jonas Karlman <jonas@kwiboo.se> wrote:
>
> On 2019-05-26 17:25, Souptick Joarder wrote:
> > Hi Jonas,
> >
> > On Sun, May 26, 2019 at 4:29 PM kbuild test robot <lkp@intel.com> wrote:
> >> tree:   https://github.com/Kwiboo/linux-rockchip rockchip-5.1-patches-from-5.3-v5.1.5
> >> head:   622dad206e3b82c53acac1857f8a6ff970c0d01b
> >> commit: 4004964b0854f3258032a723627d487882a74380 [83/106] drm/rockchip/rockchip_drm_gem.c: convert to use vm_map_pages()
> >> config: arm64-allyesconfig (attached as .config)
> >> compiler: aarch64-linux-gcc (GCC) 7.4.0
> >> reproduce:
> >>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >>         chmod +x ~/bin/make.cross
> >>         git checkout 4004964b0854f3258032a723627d487882a74380
> >>         # save the attached .config to linux build tree
> >>         GCC_VERSION=7.4.0 make.cross ARCH=arm64
> >>
> >> If you fix the issue, kindly add following tag
> >> Reported-by: kbuild test robot <lkp@intel.com>
> >>
> >> All errors (new ones prefixed by >>):
> >>
> >>    drivers/gpu//drm/rockchip/rockchip_drm_gem.c: In function 'rockchip_drm_gem_object_mmap_iommu':
> >>>> drivers/gpu//drm/rockchip/rockchip_drm_gem.c:230:9: error: implicit declaration of function 'vm_map_pages'; did you mean 'vma_pages'? [-Werror=implicit-function-declaration]
> >>      return vm_map_pages(vma, rk_obj->pages, count);
> >>             ^~~~~~~~~~~~
> >>             vma_pages
> >>    cc1: some warnings being treated as errors
> > Looking into https://github.com/Kwiboo/linux-rockchip/blob/rockchip-5.1-patches-from-5.3-v5.1.5/mm/memory.c
> > vm_map_pages() API is missing. vm_map_pages() merged into 5.2-rc1.
> > Is the below match merged into  https://github.com/Kwiboo/linux-rockchip ?
> >
> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?h=v5.2-rc1&id=a667d7456f189e3422725dddcd067537feac49c0
>
> Thanks for looking, I do not know why kbuild test robot have started building from my github tree,
> I pushed a v5.1 branch with cherry-picked commits from v5.2+next before I did a local build test and kbuild test robot started making some unnecessary noise.

Thanks for your quick response. I think, if kbuild picked your github tree
wrongly, you need to notify kbuild for the same.

> Will be more careful not to push code before making a local test build.
>
> Regards,
> Jonas
>
> >> vim +230 drivers/gpu//drm/rockchip/rockchip_drm_gem.c
> >>
> >>    219
> >>    220  static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
> >>    221                                                struct vm_area_struct *vma)
> >>    222  {
> >>    223          struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
> >>    224          unsigned int count = obj->size >> PAGE_SHIFT;
> >>    225          unsigned long user_count = vma_pages(vma);
> >>    226
> >>    227          if (user_count == 0)
> >>    228                  return -ENXIO;
> >>    229
> >>  > 230          return vm_map_pages(vma, rk_obj->pages, count);
> >>    231  }
> >>    232
> >>
> >> ---
> >> 0-DAY kernel test infrastructure                Open Source Technology Center
> >> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>

