Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BA5BC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 12:39:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F316206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 12:39:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="m26A6N93"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F316206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4ABA6B0007; Fri, 26 Apr 2019 08:39:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD29E6B0008; Fri, 26 Apr 2019 08:39:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9A1F6B000A; Fri, 26 Apr 2019 08:39:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD686B0007
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 08:39:56 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id k78so1406540vkk.17
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 05:39:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=O7AawR3O9LUFS8kj7n0V35j45u1KfiRyWzvO/3OxrAE=;
        b=Z2aF7GSshdzaG8iVmeP87L5hqRPJG33A/fL+JwgIQbC64nOfzMxffOdYfZDOriCXIs
         RHn4XSUy7JkdscqCwtrfxgS1MxK5MasHkdfS7IVK2hXDTgdQktwPS5PGJFPN0MqE+XnI
         RAi90M1wtjWWsz/K59dDB6nB3Z0fTqZ6sdH+xCYplDFQEOLLEcfzcTcbmjw8KIu2HCjo
         ZSy6pNnyBsP+wNQa5RZzBLpJngMsx/h8bavisaheWna1CBzVzk6i7OdKf1/sQS9iO8Ac
         KDWEFEvy87AHCCWj8xEXtep7NUsCkprcgv6NtTbHSmGtGqsO2kaz0ht+3pjd1+zzfEOr
         IC+Q==
X-Gm-Message-State: APjAAAUhuhqj2TSJT5FG11Y65n31vKDN36vjCF/Y6ZvxlN2yaKRcGGDG
	3rOxnYVdbEWcuRgmVabhfWOl/1/ISjeigr0QlWYzLaNVN3uYY4/UnJWDTwxc5y8CXaeVnnCMOhA
	MlJTUYOxfsy1+UkI0Gsk90z8g6PKcJfJRVElC6oDOG3X4l0i1lqxvxSt4Pmkwb9crKg==
X-Received: by 2002:a67:fbc2:: with SMTP id o2mr23916806vsr.78.1556282396309;
        Fri, 26 Apr 2019 05:39:56 -0700 (PDT)
X-Received: by 2002:a67:fbc2:: with SMTP id o2mr23916779vsr.78.1556282395539;
        Fri, 26 Apr 2019 05:39:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556282395; cv=none;
        d=google.com; s=arc-20160816;
        b=QIcu1nEsaI5OyCrm/ICHuYQhVx0QHng9tnVyt9iq6e1JH5UaQDzz93R/RhvCRP1tBY
         2wkVk5WOj8NZrAPSZpt85sXl98oN/r1UnmOG+J5abxJZixWd1aZu+ejOlNQDEm1tAc5o
         yxXv02Y9ShV/6XyU8we/1NM4mGkv1Tc1+H0T/ss+CiH1Xa+4mY0gOs5/Kdt7hRBSH71X
         GYtSE4GEqC8sn9A5W+TE7aEtYvKY9LRT1zovWuQGIt3VhU0aTr8JuyXVkd6adB3ZaT4b
         ndoT7JIIjzUTBrqgDgDeR2ZukYYe2ZLQTfcxQ7SPLHdgXOkj+9VfuR7NDXxv4nQg3v8o
         WdAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=O7AawR3O9LUFS8kj7n0V35j45u1KfiRyWzvO/3OxrAE=;
        b=a1PPupmTxPpefLYv8nUmjr6aX8JRrfZT/pFkPTOtS0t1pLe8gQtAy1w/bEcRgznpo4
         bGN1LsC8UMPwY+3bAlO7ez5w7P4r67odtDztBIuzrmypAfW/fz2J3cSG1D+7bdIGhRT5
         Ap0LqltrEw+GD2ObSmykcmdGy7GN7F1M552yJCFMwUZ/3XYT+MGbP+xXF9LvgGjzfq8/
         lGoNPKQoPiu56BM8jS6ZGiIvsUBSGSPQw5FxvUG3DfYTwP9fdq8ZuMWnpiguCz2j5IgI
         NEpNdU/lX9oyvP4zi7cHW8bq3yQCSztvkW74NVIOcvjGeHnATzWZdBO7OjgQVcFjPYfu
         A6+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m26A6N93;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w3sor12592103uan.28.2019.04.26.05.39.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 05:39:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m26A6N93;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=O7AawR3O9LUFS8kj7n0V35j45u1KfiRyWzvO/3OxrAE=;
        b=m26A6N93bZJXT6UlaTWtTMsI53w5OVL8HSRwdT1/cquOlHa70Nuz69k33IlTgtWpoc
         HMUj8YpAX3lQQ8mb/nXQA5am3IQVjQhjxstTjFfh8iScQEvro47qgn/8MjDcuPHb9jkf
         6GqXBu2DYardxU8i3XS+9z3AkNDQCCrdNxx0NxX0+Qnxy75R3c9nHUouW1QC7XIW3wmL
         WEETj+ZHkC+ouC8JHRvDRX582jx8YtJ72o5lkDOZI2RpmQx3ZMgQTSUr5c4rM1AceOAl
         WN4nluwmMQkSJRukq5vSC3uX7OsMNRSPKCuuWAKOSxcW7FmYWVXz6qeFUjljTnPPcvww
         Z0sQ==
X-Google-Smtp-Source: APXvYqzYTr1kpS8dYgBhDfPdqedl7565LwdCIfJCzPIpaGiHrI2c19+u7oNKWzbrOaBScV3cHo/Y8XKYWKFwwcEK1Lo=
X-Received: by 2002:ab0:d95:: with SMTP id i21mr14349633uak.110.1556282394874;
 Fri, 26 Apr 2019 05:39:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190418154208.131118-1-glider@google.com> <CAGXu5j+tJJbyoZ=nSpSeiihD=NHwFJ6G9Ku5c21G5nQfEiKPwQ@mail.gmail.com>
In-Reply-To: <CAGXu5j+tJJbyoZ=nSpSeiihD=NHwFJ6G9Ku5c21G5nQfEiKPwQ@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 26 Apr 2019 14:39:43 +0200
Message-ID: <CAG_fn=WmTh8hesU0RDpbdYDf0iYSdmAWH1dMkejRg5sBnaCw3g@mail.gmail.com>
Subject: Re: [PATCH 0/3] RFC: add init_allocations=1 boot option
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 8:49 PM Kees Cook <keescook@chromium.org> wrote:
>
> On Thu, Apr 18, 2019 at 8:42 AM Alexander Potapenko <glider@google.com> w=
rote:
> >
> > Following the recent discussions here's another take at initializing
> > pages and heap objects with zeroes. This is needed to prevent possible
> > information leaks and make the control-flow bugs that depend on
> > uninitialized values more deterministic.
> >
> > The patchset introduces a new boot option, init_allocations, which
> > makes page allocator and SL[AOU]B initialize newly allocated memory.
> > init_allocations=3D0 doesn't (hopefully) add any overhead to the
> > allocation fast path (no noticeable slowdown on hackbench).
>
> I continue to prefer to have a way to both at-allocation
> initialization _and_ poison-on-free, so let's not redirect this to
> doing it only at free time.
There's a problem with poison-on-free.
By default SLUB stores the freelist pointer (not sure if it's the only
piece of data) in the memory chunk itself, so newly allocated memory
is dirty despite it has been zeroed out previously.
We could probably zero out the bits used by the allocator when
allocating the memory chunk, but it sounds hacky (yet saves us 8 bytes
on every allocation)
A cleaner solution would be to unconditionally relocate the free
pointer by short-circuiting
https://elixir.bootlin.com/linux/latest/source/mm/slub.c#L3531
Surprisingly, this doesn't work, because now the sizes of slub caches
are a bit off, and create_unique_id() in slub.c returns clashing sysfs
names.

> We're going to need both hooks when doing
> Memory Tagging, so let's just get it in place now. The security
> benefits on tagging, IMO, easily justify a 1-2% performance hit. And
> likely we'll see this improve with new hardware.
>
> > With only the the first of the proposed patches the slowdown numbers ar=
e:
> >  - 1.1% (stdev 0.2%) sys time slowdown building Linux kernel
> >  - 3.1% (stdev 0.3%) sys time slowdown on af_inet_loopback benchmark
> >  - 9.4% (stdev 0.5%) sys time slowdown on hackbench
> >
> > The second patch introduces a GFP flag that allows to disable
> > initialization for certain allocations. The third page is an example of
> > applying it to af_unix.c, which helps hackbench greatly.
> >
> > Slowdown numbers for the whole patchset are:
> >  - 1.8% (stdev 0.8%) on kernel build
> >  - 6.5% (stdev 0.2%) on af_inet_loopback
>
> Any idea why thes two went _up_?
>
> >  - 0.12% (stdev 0.6%) on hackbench
>
> Well that's quite an improvement. :)
>
> --
> Kees Cook



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

