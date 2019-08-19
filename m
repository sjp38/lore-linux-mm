Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7698C3A5A1
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:45:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A640122CE8
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:45:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lkS0EhBo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A640122CE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 459946B026C; Mon, 19 Aug 2019 11:45:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40AEB6B026D; Mon, 19 Aug 2019 11:45:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FADC6B026E; Mon, 19 Aug 2019 11:45:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id 12FA76B026C
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 11:45:52 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A8861180AD7C1
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:45:51 +0000 (UTC)
X-FDA: 75839602902.24.quilt52_50357a9b7ae49
X-HE-Tag: quilt52_50357a9b7ae49
X-Filterd-Recvd-Size: 5339
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:45:51 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id f17so1385776pfn.6
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 08:45:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XtYpFyhBgTCiaGChS6+kaxar4vStZcnCYRWo71+/RtE=;
        b=lkS0EhBoToJ8+dJ5+nnxpdrWvVmMHHZI7bNv0YOTEttc921AvasCizSuRflFNbq1Xj
         Lpzl84ZZA2OQ6Fl0mVnvOJyIXEqYXu5ps1wPAfD33F9fSphuk4sFgI4SIKqe5ey5Tr57
         G8XUL4SKezAspF0tskCc378nq+6tOXS5v2s6iY1fnPR8AmhGw3iI/NsuI0cW+A20hgEk
         y05U8D//d6jldI/IInc3BskYQojRq9cgHqOL/Sxxioz1XALAEdpp/8OiQun/RJSUXJyo
         GJMLBdsjaVvdZjcjp2MQ4TMMJwlzyVeEF08ndFUH3hSYiwHwBHn4nNJfq4wngD77uKww
         /CPA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=XtYpFyhBgTCiaGChS6+kaxar4vStZcnCYRWo71+/RtE=;
        b=CTGz14rn2i8OIop1iItaAOGeFJ7gWRu0rm6HUgWH54QyfZPs9BmipVpT3d0i1wtSux
         1KzZ2UEusuXAFT10T0fFfxBgQC0gaVGjbX5AI71yvQsfj4PC8zP6d4poXh5ywkJqXJAR
         tdLliHhp82c9bYINF96O0A70XsNkYWYElKLIkPvHxNzUnh0vbPk3iowAqI762X8ZOaT8
         +uMmQUc5PB/S3PaY5uWenBviO04oS8o75Q7aLwblQB2AC75NX4pUsE1hl4yMukHYW755
         67PYu44VllB+OsOLADqHxZUPSqyI7H1S8603L98FoRddyXS/JTmzRlSQuFbRNKF49CvF
         /QeQ==
X-Gm-Message-State: APjAAAXwlf+x5Vc26EXgPnXOL965IimRfzVjv4g1YxwKs7d5sKr1Djr8
	VcZPUARkytx9sLCzkhMPPO5KMaZDRIWjU3TB7HKM1A==
X-Google-Smtp-Source: APXvYqz6VTqoLf1MfWlpYT4kff14E1OwztGKr414bguuFTgjh6si0OD8mf+UDVjfdzyW4l952foknf+zoYxofSvLevs=
X-Received: by 2002:aa7:9790:: with SMTP id o16mr25133292pfp.51.1566229549716;
 Mon, 19 Aug 2019 08:45:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190815154403.16473-1-catalin.marinas@arm.com> <20190815154403.16473-2-catalin.marinas@arm.com>
In-Reply-To: <20190815154403.16473-2-catalin.marinas@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 19 Aug 2019 17:45:38 +0200
Message-ID: <CAAeHK+z6y4_rSH8b8Q=yMmNZYd_bsmMo2XPP0DO-74+=XPPrMg@mail.gmail.com>
Subject: Re: [PATCH v8 1/5] mm: untag user pointers in mmap/munmap/mremap/brk
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Szabolcs Nagy <szabolcs.nagy@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Dave P Martin <Dave.Martin@arm.com>, Dave Hansen <dave.hansen@intel.com>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 5:44 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> There isn't a good reason to differentiate between the user address
> space layout modification syscalls and the other memory
> permission/attributes ones (e.g. mprotect, madvise) w.r.t. the tagged
> address ABI. Untag the user addresses on entry to these functions.
>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

Acked-by: Andrey Konovalov <andreyknvl@google.com>

> ---
>  mm/mmap.c   | 5 +++++
>  mm/mremap.c | 6 +-----
>  2 files changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 7e8c3e8ae75f..b766b633b7ae 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -201,6 +201,8 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
>         bool downgraded = false;
>         LIST_HEAD(uf);
>
> +       brk = untagged_addr(brk);
> +
>         if (down_write_killable(&mm->mmap_sem))
>                 return -EINTR;
>
> @@ -1573,6 +1575,8 @@ unsigned long ksys_mmap_pgoff(unsigned long addr, unsigned long len,
>         struct file *file = NULL;
>         unsigned long retval;
>
> +       addr = untagged_addr(addr);
> +
>         if (!(flags & MAP_ANONYMOUS)) {
>                 audit_mmap_fd(fd, flags);
>                 file = fget(fd);
> @@ -2874,6 +2878,7 @@ EXPORT_SYMBOL(vm_munmap);
>
>  SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
>  {
> +       addr = untagged_addr(addr);
>         profile_munmap(addr);
>         return __vm_munmap(addr, len, true);
>  }
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 64c9a3b8be0a..1fc8a29fbe3f 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -606,12 +606,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>         LIST_HEAD(uf_unmap_early);
>         LIST_HEAD(uf_unmap);
>
> -       /*
> -        * Architectures may interpret the tag passed to mmap as a background
> -        * colour for the corresponding vma. For mremap we don't allow tagged
> -        * new_addr to preserve similar behaviour to mmap.
> -        */
>         addr = untagged_addr(addr);
> +       new_addr = untagged_addr(new_addr);
>
>         if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
>                 return ret;

