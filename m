Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82A57C10F0E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 01:30:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C23420880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 01:30:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EDyFgf/a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C23420880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A404E6B0007; Sun,  7 Apr 2019 21:30:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C8BF6B0008; Sun,  7 Apr 2019 21:30:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86A4C6B000A; Sun,  7 Apr 2019 21:30:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 622936B0007
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 21:30:21 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id w11so9974501iom.20
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 18:30:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nCywoWrMYJtCxHlq86kes488DcNaYRqh8YYUtxyVIWY=;
        b=JwhNlIOFbHPkEO4Ex+eyDzlJdnZeYHsSWWTg7xQHupq88NtJvpF7VnMCDfMraWcOYx
         Zfp0BrGj4JnKNWiF/SjL9jgAP1zxQcW3PaCSE1pJR/VwLqFvrl5Dl6J764sHWiVUZpkh
         j2yeKfgRXWrLZAw32s0g/7KhbCsHp3SxEhM/zOrOa9RdLTwNXrp2Hz3xgM7llZSWZRzb
         qiDPQJ6SlqikQ0Iq1f0fr7XOptg1Z4hyZ5nRo3wLw5XT9rTc7jIyRBzInyCB3jCJm5pS
         h8aXUBae7b5sxUXHS5OvULjfay9kAA+s2Wfmg5YwcG+/Rdk31a9YkfuZVjd6e8DSZpZi
         K2qQ==
X-Gm-Message-State: APjAAAVmL+Kr/NgtaPHOYmIIaCdLWKt2hIcO0RfADX95Hffw7hZJGLJ+
	Efa4jWMjesn0t97nh60cM7AhnmqTWaYB3lD3XB3UYKsUjBnxc1jLGthfmqmFnPqM1KKYsWxA5La
	B6PWYWMAuK9+4x3xU20M4yT+eJVG4ucCPYOr8g9l9Q/5AKxoHetwkBKTPDQr6+mTCtw==
X-Received: by 2002:a02:1006:: with SMTP id 6mr19357098jay.47.1554687021144;
        Sun, 07 Apr 2019 18:30:21 -0700 (PDT)
X-Received: by 2002:a02:1006:: with SMTP id 6mr19357054jay.47.1554687020345;
        Sun, 07 Apr 2019 18:30:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554687020; cv=none;
        d=google.com; s=arc-20160816;
        b=w3GAkOWL1mgWZOjipbs+ZA08i0jy0Qx2hZ15T/M3LXeup5vftaRfNtCAt26Uk84YWq
         15U7vhAH6RY3UgKjo3Hou1PgV7KGH2jQbZsMNg10wey5gcofENFZ58R5rPOeWvHtsEMV
         m2ONJcSrrMR9jhRS3pT+dFBlldzRWlyGPfJoFBF2XPkssriZ2/a9yz35jzIcH5pKJPVI
         zRisydzMoEJ7RKzQ+JyULoi142mlAzTgHAg5TR+4xXas+FlJeu52zVyGjVepaQY8LL2Y
         hZqEtH9+U2afvp7hsNuVj+Q4qmsqkF6HXb4EvqEMNfEq5R4kP6sEp2QmWJrZFpPYkUCc
         0Z4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nCywoWrMYJtCxHlq86kes488DcNaYRqh8YYUtxyVIWY=;
        b=U1COkiHhjKKg7rHR5ECrGzDkbFEtduRKVyXnWPJXL9Jgkj4wU0fj/mvgf1Yph/dCdS
         Hu/NezIr2A+r2fC6S6DRJWILY0fhAMYoQypsgVkxUV4sQW9c/ZbwzI0KK0HOLMEJofv7
         UMSbmI3A1tTl2wraP+O0+UZMaozHgqyJAKRchSLls00/gnLuTmybJTnoeosC+eJehONb
         cH+m4p8rN0UtXSxLhLziWwjc66Kh8zlLP43EGQ4fyOMyF8T9IWjYXBrPkd+WEkdJOf7L
         geoLEKPAiNGyi5P6Yym47WxnUhietmDc0YfNYuHSXZ0XsnRADXDThMSU3xQOFRvEpLRd
         B5qA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="EDyFgf/a";
       spf=pass (google.com: domain of yuq825@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuq825@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u63sor12606089ita.2.2019.04.07.18.30.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Apr 2019 18:30:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuq825@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="EDyFgf/a";
       spf=pass (google.com: domain of yuq825@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuq825@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nCywoWrMYJtCxHlq86kes488DcNaYRqh8YYUtxyVIWY=;
        b=EDyFgf/aPlebajoC3F/rMiW8uhpJusnN1Doo0IEat36waEOQrFZEIAZiCvz6XjGPn8
         64fxb3Z5KMIyegaBOtMs3K36vCj3bo7LAM90Ti4EptH33l6FEfO2aLVZUWnGRKl6M4Sb
         bSve5k/6mBxguDsWmeJnNglLxvj3+hZg9xMKjPPn1Q3iscYJ+WB1E2BvEhbwIiVS528s
         K5T/OYLeVzAmCEp+qmQxMynGFOcvJnoXi7/BWG1oC3mA6uPXBH6/kc91ykqMYBIyxidk
         MxacnA8ycu7Bcz51sw3xdypNpGF0iiqvJpSUcoy6vpJUR9Mq3I3k5bbQ+afUsOkkle8t
         26UQ==
X-Google-Smtp-Source: APXvYqz4jjlqKA12Lbb36/Yv08soFZcRR4DzriZpseKnQLfWTot1LMnhnhLz3Rn17Wv6H3kwXT3lcegcV8Kvgtv0sLk=
X-Received: by 2002:a24:c544:: with SMTP id f65mr18703899itg.90.1554687019377;
 Sun, 07 Apr 2019 18:30:19 -0700 (PDT)
MIME-Version: 1.0
References: <201904061457.ZCY5n0Jo%lkp@intel.com> <c71215b3-8a6a-a4dd-b9bd-9252bd052a32@infradead.org>
In-Reply-To: <c71215b3-8a6a-a4dd-b9bd-9252bd052a32@infradead.org>
From: Qiang Yu <yuq825@gmail.com>
Date: Mon, 8 Apr 2019 09:30:08 +0800
Message-ID: <CAKGbVbsFXvEjxNH7Wm5Qr8ODyDfJ438qRELn0AB1BJdVV1AK6Q@mail.gmail.com>
Subject: Re: [mmotm:master 227/248] lima_gem.c:undefined reference to `vmf_insert_mixed'
To: Randy Dunlap <rdunlap@infradead.org>
Cc: kbuild test robot <lkp@intel.com>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org, 
	Linux Memory Management List <linux-mm@kvack.org>, Manfred Spraul <manfred@colorfullife.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, lima@lists.freedesktop.org, 
	dri-devel <dri-devel@lists.freedesktop.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks Randy, I can add these.

Where should I send/submit the patch to in this case? Still drm-misc?

Regards,
Qiang


On Mon, Apr 8, 2019 at 3:08 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>
> On 4/5/19 11:47 PM, kbuild test robot wrote:
> > Hi Andrew,
> >
> > It's probably a bug fix that unveils the link errors.
> >
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   b09c000f671826e6f073a7f89b266e4ac998952b
> > commit: 39a08f353e1f30f7ba2e8b751a9034010a99666c [227/248] linux-next-git-rejects
> > config: sh-allyesconfig (attached as .config)
> > compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 39a08f353e1f30f7ba2e8b751a9034010a99666c
> >         # save the attached .config to linux build tree
> >         GCC_VERSION=7.2.0 make.cross ARCH=sh
> >
> > All errors (new ones prefixed by >>):
> >
> >    arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
> >    drivers/gpu/drm/lima/lima_gem.o: In function `lima_gem_fault':
> >>> lima_gem.c:(.text+0x6c): undefined reference to `vmf_insert_mixed'
>
>
> vmf_insert_mixed() is only built for MMU configs, and the attached config
> does not set/enable MMU.
> Maybe this driver should depend on MMU, like several other drm drivers do.
>
>
> Also, lima_gem.c needs this line to be added to it:
>
> --- mmotm-2019-0405-1828.orig/drivers/gpu/drm/lima/lima_gem.c
> +++ mmotm-2019-0405-1828/drivers/gpu/drm/lima/lima_gem.c
> @@ -1,6 +1,7 @@
>  // SPDX-License-Identifier: GPL-2.0 OR MIT
>  /* Copyright 2017-2019 Qiang Yu <yuq825@gmail.com> */
>
> +#include <linux/mm.h>
>  #include <linux/sync_file.h>
>  #include <linux/pfn_t.h>
>
>
>
> --
> ~Randy

