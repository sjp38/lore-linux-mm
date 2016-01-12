Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 421AD680F80
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 22:10:50 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id e65so55087622pfe.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:10:50 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id 7si32810877pfi.90.2016.01.11.19.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 19:10:49 -0800 (PST)
Received: by mail-pa0-x242.google.com with SMTP id a20so20167057pag.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:10:49 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: soft-offline: exit with failure for non anonymous thp
Date: Tue, 12 Jan 2016 12:10:43 +0900
Message-Id: <1452568245-10412-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20160108123300.843d370916d3248be297d831@linux-foundation.org>
References: <20160108123300.843d370916d3248be297d831@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Fri, Jan 08, 2016 at 12:33:00PM -0800, Andrew Morton wrote:
> On Fri,  8 Jan 2016 16:24:02 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
>
> > Currently memory_failure() doesn't handle non anonymous thp case, because we
> > can hardly expect the error handling to be successful, and it can just hit
> > some corner case which results in BUG_ON or something severe like that.
> > This is also a case for soft offline code, so let's make it in the same way.
> >
> > ...
> >
> > --- v4.4-rc8/mm/memory-failure.c
> > +++ v4.4-rc8_patched/mm/memory-failure.c
> > @@ -1751,9 +1751,11 @@ int soft_offline_page(struct page *page, int flags)
> >         return -EBUSY;
> >     }
> >     if (!PageHuge(page) && PageTransHuge(hpage)) {
> > -       if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
> > -           pr_info("soft offline: %#lx: failed to split THP\n",
> > -               pfn);
> > +       if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
> > +           if (!PageAnon(hpage))
> > +               pr_info("soft offline: %#lx: non anonymous thp\n", pfn);
> > +           else
> > +               pr_info("soft offline: %#lx: thp split failed\n", pfn);
> >             if (flags & MF_COUNT_INCREASED)
> >                 put_hwpoison_page(page);
> >             return -EBUSY;
>
> Kirill's
> http://ozlabs.org/~akpm/mmots/broken-out/thp-mm-split_huge_page-caller-need-to-lock-page.patch
> mucks with this code as well.  Could you please redo this patch against
> linux-next?

OK, I did it, which will come after this email.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
