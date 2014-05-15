Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 52BB86B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 10:14:26 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id bs8so9871600wib.12
        for <linux-mm@kvack.org>; Thu, 15 May 2014 07:14:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id es3si2016711wic.55.2014.05.15.07.14.22
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 07:14:24 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/memory-failure.c: fix memory leak by race between poison and unpoison
Date: Thu, 15 May 2014 10:13:59 -0400
Message-Id: <5374cbc0.43b8b40a.4221.331eSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <5374b1d1.86300f0a.4a16.65ffSMTPIN_ADDED_BROKEN@mx.google.com>
References: <1400080891-5145-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1400124866.26173.19.camel@cyc> <5374b1d1.86300f0a.4a16.65ffSMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: soldier.cyc81@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 15, 2014 at 08:23:10AM -0400, Naoya Horiguchi wrote:
> On Thu, May 15, 2014 at 11:34:26AM +0800, cyc wrote:
> > =E5=9C=A8 2014-05-14=E4=B8=89=E7=9A=84 11:21 -0400=EF=BC=8CNaoya Hori=
guchi=E5=86=99=E9=81=93=EF=BC=9A
> > > When a memory error happens on an in-use page or (free and in-use) =
hugepage,
> > > the victim page is isolated with its refcount set to one. When you =
try to
> > > unpoison it later, unpoison_memory() calls put_page() for it twice =
in order to
> > > bring the page back to free page pool (buddy or free hugepage list.=
)
> > > However, if another memory error occurs on the page which we are un=
poisoning,
> > > memory_failure() returns without releasing the refcount which was i=
ncremented
> > > in the same call at first, which results in memory leak and unconsi=
stent
> > > num_poisoned_pages statistics. This patch fixes it.
> > =

> > We assume that a new memory error occurs on the hugepage which we are=

> > unpoisoning. =

> > =

> >           A   unpoisoned  B    poisoned    C          =

> > hugepage: |---------------+++++++++++++++++|
> > =

> > There are two cases, so shown.
> >   1. the victim page belongs to A-B, the memory_failure will be block=
ed
> > by lock_page() until unlock_page() invoked by unpoison_memory().
> =

> No. memory_failure() set PageHWPoison at first before taking page lock.=

> This is a design choice based on the idea that we need detect errors AS=
AP.

I might have not caught you, sorry. With this patch, we can properly canc=
el
poisoning operation when it races with unpoisoning, so no effect as you s=
aid
for both case.

Thanks,
Naoya


> What happens in this race is like below:
> =

>     CPU 0 (poison)                 CPU 1 (unpoison)
>                                    lock_page
>     TestSetPageHWPoison
>                                    TestClearPageHWPoison
>     lock_page (wait)
>                                    unlock_page
>     check PageHWPoison
>       printk("just unpoisoned")
> =

> >   2. the victim page belongs to B-C, the memory_failure() will return=

> > very soon at the beginning of this function.
> =

> Right.
> =

> Thanks,
> Naoya Horiguchi
> =

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
