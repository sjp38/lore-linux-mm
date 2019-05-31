Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 396D5C28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 10:30:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB1DA26780
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 10:30:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IArgLlu8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB1DA26780
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A5306B0270; Fri, 31 May 2019 06:30:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42F5F6B0272; Fri, 31 May 2019 06:30:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31E186B0273; Fri, 31 May 2019 06:30:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 183016B0270
	for <linux-mm@kvack.org>; Fri, 31 May 2019 06:30:03 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id u131so7769054itc.1
        for <linux-mm@kvack.org>; Fri, 31 May 2019 03:30:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vWqWKbrAXVr1vv0ljUZ6j7dXVWf1RBTgGsA5MBSNUDk=;
        b=AmwbENDXY0K3ou5e4+44p586kLhP6I9DaT1oiLnxzAHg2uZ7npic8gTVU764dxRgPI
         DPhuZFh6uACkYi41qy6t39L/TwYzI6gEEuDKaKD7gn3PLqREXjQgsWiIKAlV49TpcNJB
         AxjJnburst6N7uDJzlUvki3LehLDrVpSyM9JdGCR6AEzT1MRbxRmeZfEkovhFW3H4hyq
         PPFt18FLYP+5YQR4w0opaAuawLI5WBrITbfKebXluk2AKhStDReh9ASnG8W9cKKZJY4l
         rn/9ElYI+h+854tUwecx3yLAoI9QkU95+mKaiEqSr1HOqExgy05/kCiHblHQXo+fn2NF
         Vm1A==
X-Gm-Message-State: APjAAAWARpOssnD8+bBmQuxGy8buHTmgHCTV5uOo4EYL6pmGgZJa0JVz
	0t6IFNmK1B21eM8bSSZluforBqPf13MQxW48MfJOTSJEkM3fN6wVgPJ2bWmFlP1lxtbjKRHGw+X
	ArU/dZGIHkqLgK26WYyDgXIgMrT9I8PROUggJd1viTIwu7yHXTeuTmAXYdyFXCrBr+g==
X-Received: by 2002:a05:660c:143:: with SMTP id r3mr6498664itk.84.1559298602809;
        Fri, 31 May 2019 03:30:02 -0700 (PDT)
X-Received: by 2002:a05:660c:143:: with SMTP id r3mr6498621itk.84.1559298602087;
        Fri, 31 May 2019 03:30:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559298602; cv=none;
        d=google.com; s=arc-20160816;
        b=Ax3tTmLbP5SEu8xZQVut6juwAoH2bgEqQWebzryY9k0sLFT6mKiFfZmFE1dlMSyQVb
         RhCo9Vk7IHiTzmlD1JCdn+JmiXrIw2ysfJvyJLhm9Nc81cfmp8ZEaRX0y1KJ8wmHJ5bs
         qfjmK/N0WOOpipN59fZHCBOTzXueerBklo0ViAGTz42Wv16MbhRDkofJC2l7GU/rn5nd
         RAZqeMu+72pgOUweB+Lv45Kceu/hx9sMPsU5BMCo7299TwuJQWtbP+mqySwrAwVusIdD
         oLyXhLvTFVHtKvpoB0+pSX06VkQZqGfoq49zJ3J/sBXFl6rcoW54JWa6FGU9DyAP6PAW
         zLWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vWqWKbrAXVr1vv0ljUZ6j7dXVWf1RBTgGsA5MBSNUDk=;
        b=EYNt6lZlGhsTkgSK7lHJyLnLmlPXXLeXzKd4lM3vAq5gBMnYJ29EGNNWyaZKP74MRN
         2JAlF6dwa7e5zKyKqYnkml9FwxcLOPZLtiSvJvLVRv7nhE7zsecwaIVNMqgvdjjrlPU5
         njfeCNv0RLNgYrWFG7Cq9rjaViJ0j9HlqB64tNW5XylGMmhU3ngQaXDRxtMInKsK49YC
         F3ov7DZaK8AXj0pYlO27IvgcTCUPjxl2jDQa4IDCXz4t5OOPc5CCm2oXWauOsIqzuZEN
         KrFF4c3tZXIC7Sl+3BQ4a1pDjGiRCP8gePj8OKXqmfzUZcds6TtPouizvEywFF6I+De/
         9bpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IArgLlu8;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 75sor8191801itw.4.2019.05.31.03.30.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 03:30:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IArgLlu8;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vWqWKbrAXVr1vv0ljUZ6j7dXVWf1RBTgGsA5MBSNUDk=;
        b=IArgLlu8LmO7rxsbIzDBJH+C6i9e6ya0ROYBmaFB3kCW73c9o7/AAGRhMxxwj5BsQk
         LT8g8mNOZg3+RkmnjyD1jX2oHO8otMAFNYFmpJRNTieoM7JuWMEdIk/MH/wRlzLkzh3c
         wxgzLHTd2OMG9kAh3C65YbgKeePH/wCbNmtVgnKF2LvKD7mxHvppTesb2d3vctOKskrP
         zurQOU+5/Eyjwb5C6VbVvl7G6CF6Z2AOlfsbucyCTiWABaF/hxeIMVWaL/gDVZeLswZA
         oINW4QjBd65Ls/5rhMQfnSVwxOLVzI770l1bBLs3bBsugkPx7avPsn4xu5SYHrRe5J7W
         PKZA==
X-Google-Smtp-Source: APXvYqyN+gUIJsr2+bHWe1Wx8z3cnmNTBcqucuzX9xp4KiKGGrOa6Hjyz1OY/59rJtFUDo9xy0JNdMXT6rf8fbtyzB4=
X-Received: by 2002:a24:5095:: with SMTP id m143mr6363629itb.68.1559298601767;
 Fri, 31 May 2019 03:30:01 -0700 (PDT)
MIME-Version: 1.0
References: <1559170444-3304-1-git-send-email-kernelfans@gmail.com> <20190530214726.GA14000@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190530214726.GA14000@iweiny-DESK2.sc.intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 31 May 2019 18:29:50 +0800
Message-ID: <CAFgQCTvatXv68gv-g7ZwpvVMoX78F616bxVMchgeQX-wGCRkow@mail.gmail.com>
Subject: Re: [PATCH] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
To: Ira Weiny <ira.weiny@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, 
	Mike Rapoport <rppt@linux.ibm.com>, Dan Williams <dan.j.williams@intel.com>, 
	Matthew Wilcox <willy@infradead.org>, John Hubbard <jhubbard@nvidia.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 5:46 AM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Thu, May 30, 2019 at 06:54:04AM +0800, Pingfan Liu wrote:
> > As for FOLL_LONGTERM, it is checked in the slow path
> > __gup_longterm_unlocked(). But it is not checked in the fast path, which
> > means a possible leak of CMA page to longterm pinned requirement through
> > this crack.
> >
> > Place a check in the fast path.
> >
> > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Mike Rapoport <rppt@linux.ibm.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Matthew Wilcox <willy@infradead.org>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> > Cc: Keith Busch <keith.busch@intel.com>
> > Cc: linux-kernel@vger.kernel.org
> > ---
> >  mm/gup.c | 12 ++++++++++++
> >  1 file changed, 12 insertions(+)
> >
> > diff --git a/mm/gup.c b/mm/gup.c
> > index f173fcb..00feab3 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -2235,6 +2235,18 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
> >               local_irq_enable();
> >               ret = nr;
> >       }
> > +#if defined(CONFIG_CMA)
> > +     if (unlikely(gup_flags & FOLL_LONGTERM)) {
> > +             int i, j;
> > +
> > +             for (i = 0; i < nr; i++)
> > +                     if (is_migrate_cma_page(pages[i])) {
> > +                             for (j = i; j < nr; j++)
> > +                                     put_page(pages[j]);
>
> Should be put_user_page() now.  For now that just calls put_page() but it is
> slated to change soon.
>
Not aware of these changes. And get your point now.

> I also wonder if this would be more efficient as a check as we are walking the
> page tables and bail early.
>
> Perhaps the code complexity is not worth it?
>
Yes. That will spread such logic in huge page and normal page.
> > +                             nr = i;
>
> Why not just break from the loop here?
>
A mistake.

Thanks,
  Pingfan
> Or better yet just use 'i' in the inner loop...
>
> Ira
>
> > +                     }
> > +     }
> > +#endif
> >
> >       if (nr < nr_pages) {
> >               /* Try to get the remaining pages with get_user_pages */
> > --
> > 2.7.5
> >

