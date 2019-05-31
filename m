Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DAB3C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 11:05:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD11C267F3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 11:05:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a4mRQqxd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD11C267F3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C4896B0276; Fri, 31 May 2019 07:05:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 574AB6B0278; Fri, 31 May 2019 07:05:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 413A66B027A; Fri, 31 May 2019 07:05:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE4D6B0276
	for <linux-mm@kvack.org>; Fri, 31 May 2019 07:05:40 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id t7so7256985iof.21
        for <linux-mm@kvack.org>; Fri, 31 May 2019 04:05:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=60Qw700xF164wG7p5BsIJw5jAg3eroN4jWr2z/QxvPU=;
        b=PpuutezpgXEyCz80rBtyMm2/FpYUlG+aZxkpzs/0TsmNtgrWy7wjjGFcxutkMk1GD3
         FxzZBvgtOum/NgnbOVnN9+KWqVj+QyN9V3RbyZHEts2+hih+UlAHNSMzTPFYKFKI7s0M
         R0CkzhF3Uc2Tnhxz5CDfYR2dY9KSQYgmAviwfvzAanoRn5rWTr1FsznkoOv/gwmM0J9G
         RxipBsGLqoYguOSsWKWMOFCosIPiIvISQVMn5OO/DB/9fw3lb5pJF1uCCFzlleOI80SF
         sEijQBGZSANhFeh1kDroQm2t2OBK/Qcy7xlEFQfBvQUeW1FiptC5cd7jPbFcsa4a3Q8b
         5y0Q==
X-Gm-Message-State: APjAAAX1IniAdums8JzlwMXy1oowKsUf+4C3sXQ2qb2Z2ZjTfi3V9ox8
	5Iyx/1YNqzcg/KHb23Zftz9bzdNUFqtc/39IN/eGXPaQT7fpfjIFOINjooGYC9PBmEVtA7t29F1
	fiOkZ4MMDdcgCPqUcUAc1svsTVsa8lrPhIetI4+GAsNxMtQlVsulMhAvQ9QdYUoTiVA==
X-Received: by 2002:a24:320b:: with SMTP id j11mr6258655ita.129.1559300739879;
        Fri, 31 May 2019 04:05:39 -0700 (PDT)
X-Received: by 2002:a24:320b:: with SMTP id j11mr6258612ita.129.1559300739095;
        Fri, 31 May 2019 04:05:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559300739; cv=none;
        d=google.com; s=arc-20160816;
        b=vzqMQMay7cdhLYtAql7GsPsbiZv2/fjdTEJgxsHH6pzSpmij97w6Es78VBz4MdouOq
         2ysU2nhB25L3yZxJ3VYVhGIK7HlCazz7RyAma/75yzHr+9VGlzJ1lcd8SkxLE/2XSDrR
         159wjrJCh2lAKZUDjxlH2cCeVLgfB5IZsupcwxJKhVNgP572EQR3ooR/q1QhdSPDZ0aS
         m3Kq4Mb4T5+FsU306e8ky9u4l7CO1r15CN+JOIKf6vrq07CH/NFpIJJ160zRVGbH0r/+
         VA4k5/42eJ2AcSNxEGN7g1Z2uFv1AGXSUppS39gL8LYRqs3BFNaDZjTHYVglqeK+O/ZN
         6Z/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=60Qw700xF164wG7p5BsIJw5jAg3eroN4jWr2z/QxvPU=;
        b=He5XJxjidhZG1SeFp1YO0uqZPaHmLzCa9mSpP6Dl4btq9rz72Rsg8WDAGKeM8398aJ
         uLS0rMtC9Ujo9U6k5rq/aEsS9F68rCvMDbP/t2JDKyMj6bHdmHPcrJc3ciZ7pzOl6/Dm
         TjCD5GliotuALVCQWqPu6DmyBUDcRPwpKgiK7n5gb4+Vo9BQ7hHabz4GS8HxmAtqGbFE
         +1Gi5t944b+y6lNAePlYQaZTjrXab78jzhXSB47FYp9P0s9cim36tUvOy8JZ3ykVL1fZ
         t0ZKrBKNayL0DAecGfjJvUOAOUWYPTsacp6g+dIaY+NcWO3RkCXG2M9V8mygYStBbN4M
         ozDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a4mRQqxd;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7sor3140099iox.40.2019.05.31.04.05.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 04:05:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a4mRQqxd;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=60Qw700xF164wG7p5BsIJw5jAg3eroN4jWr2z/QxvPU=;
        b=a4mRQqxdQjhQGZEE+NmBCzyeQc+ZVPtaxK/OqZYYdmzyZw/ms7KnKg28+WenzXoqQ9
         RbLiH8SECZHXZl8On7zljNcq9ZbjamcvHSHwwyZoYdNkt+LT5GrkwRdWOLKBNdrnV38S
         RIaZKQbm0SF/w7k8E3L2VoTpXgVwf/PDydUHQ0xZuEeua1Mhz9MrrMT3PGQXVYhjCk7h
         d5oDC2ML2yXo7Y4seRpm1X93vpVz2nzjRDhFxdO/Vjt+gUWgXQF1zdHCTqGhA6XRTLTq
         ikGo2JCpjGG+ey24sLxCJYHy6LbiQnz9qnul40bEzX/emxK25pjJC0HHewOFr6oTYZfM
         gRbg==
X-Google-Smtp-Source: APXvYqwMU5rDEa406o+bbKgj0fzapXZvu0xsaWzm/rjJr4JCcUTfVdJypAB9+uofzpooHKyOjABQcmADHK211MgFzNE=
X-Received: by 2002:a5e:d70c:: with SMTP id v12mr5592967iom.12.1559300738725;
 Fri, 31 May 2019 04:05:38 -0700 (PDT)
MIME-Version: 1.0
References: <1559170444-3304-1-git-send-email-kernelfans@gmail.com>
 <20190530214726.GA14000@iweiny-DESK2.sc.intel.com> <1497636a-8658-d3ff-f7cd-05230fdead19@nvidia.com>
In-Reply-To: <1497636a-8658-d3ff-f7cd-05230fdead19@nvidia.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 31 May 2019 19:05:27 +0800
Message-ID: <CAFgQCTtVcmLUdua_nFwif_TbzeX5wp31GfTpL6CWmXXviYYLyw@mail.gmail.com>
Subject: Re: [PATCH] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>, linux-mm@kvack.org, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 7:21 AM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 5/30/19 2:47 PM, Ira Weiny wrote:
> > On Thu, May 30, 2019 at 06:54:04AM +0800, Pingfan Liu wrote:
> [...]
> >> +                            for (j = i; j < nr; j++)
> >> +                                    put_page(pages[j]);
> >
> > Should be put_user_page() now.  For now that just calls put_page() but it is
> > slated to change soon.
> >
> > I also wonder if this would be more efficient as a check as we are walking the
> > page tables and bail early.
> >
> > Perhaps the code complexity is not worth it?
>
> Good point, it might be worth it. Because now we've got two loops that
> we run, after the interrupts-off page walk, and it's starting to look like
> a potential performance concern.
>
> >
> >> +                            nr = i;
> >
> > Why not just break from the loop here?
> >
> > Or better yet just use 'i' in the inner loop...
> >
>
> ...but if you do end up putting in the after-the-fact check, then we can
> go one or two steps further in cleaning it up, by:
>
>     * hiding the visible #ifdef that was slicing up gup_fast,
>
>     * using put_user_pages() instead of either put_page or put_user_page,
>       thus getting rid of j entirely, and
>
>     * renaming an ancient minor confusion: nr --> nr_pinned),
>
> we could have this, which is looks cleaner and still does the same thing:
>
> diff --git a/mm/gup.c b/mm/gup.c
> index f173fcbaf1b2..0c1f36be1863 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1486,6 +1486,33 @@ static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
>  }
>  #endif /* CONFIG_FS_DAX || CONFIG_CMA */
>
> +#ifdef CONFIG_CMA
> +/*
> + * Returns the number of pages that were *not* rejected. This makes it
> + * exactly compatible with its callers.
> + */
> +static int reject_cma_pages(int nr_pinned, unsigned gup_flags,
> +                           struct page **pages)
> +{
> +       int i = 0;
> +       if (unlikely(gup_flags & FOLL_LONGTERM)) {
> +
> +               for (i = 0; i < nr_pinned; i++)
> +                       if (is_migrate_cma_page(pages[i])) {
> +                               put_user_pages(&pages[i], nr_pinned - i);
> +                               break;
> +                       }
> +       }
> +       return i;
> +}
> +#else
> +static int reject_cma_pages(int nr_pinned, unsigned gup_flags,
> +                           struct page **pages)
> +{
> +       return nr_pinned;
> +}
> +#endif
> +
>  /*
>   * This is the same as get_user_pages_remote(), just with a
>   * less-flexible calling convention where we assume that the task
> @@ -2216,7 +2243,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>                         unsigned int gup_flags, struct page **pages)
>  {
>         unsigned long addr, len, end;
> -       int nr = 0, ret = 0;
> +       int nr_pinned = 0, ret = 0;
>
>         start &= PAGE_MASK;
>         addr = start;
> @@ -2231,25 +2258,27 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>
>         if (gup_fast_permitted(start, nr_pages)) {
>                 local_irq_disable();
> -               gup_pgd_range(addr, end, gup_flags, pages, &nr);
> +               gup_pgd_range(addr, end, gup_flags, pages, &nr_pinned);
>                 local_irq_enable();
> -               ret = nr;
> +               ret = nr_pinned;
>         }
>
> -       if (nr < nr_pages) {
> +       nr_pinned = reject_cma_pages(nr_pinned, gup_flags, pages);
> +
> +       if (nr_pinned < nr_pages) {
>                 /* Try to get the remaining pages with get_user_pages */
> -               start += nr << PAGE_SHIFT;
> -               pages += nr;
> +               start += nr_pinned << PAGE_SHIFT;
> +               pages += nr_pinned;
>
> -               ret = __gup_longterm_unlocked(start, nr_pages - nr,
> +               ret = __gup_longterm_unlocked(start, nr_pages - nr_pinned,
>                                               gup_flags, pages);
>
>                 /* Have to be a bit careful with return values */
> -               if (nr > 0) {
> +               if (nr_pinned > 0) {
>                         if (ret < 0)
> -                               ret = nr;
> +                               ret = nr_pinned;
>                         else
> -                               ret += nr;
> +                               ret += nr_pinned;
>                 }
>         }
>
>
> Rather lightly tested...I've compile-tested with CONFIG_CMA and !CONFIG_CMA,
> and boot tested with CONFIG_CMA, but could use a second set of eyes on whether
> I've added any off-by-one errors, or worse. :)
>
Do you mind I send V2 based on your above patch? Anyway, it is a simple bug fix.

Thanks,
  Pingfan

