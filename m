Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFE176B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 18:17:00 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x6-v6so3628640wrl.6
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 15:17:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1-v6sor3859690wrp.72.2018.06.28.15.16.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 15:16:58 -0700 (PDT)
MIME-Version: 1.0
References: <20180627214447.260804-1-cannonmatthews@google.com> <20180628112139.GC32348@dhcp22.suse.cz>
In-Reply-To: <20180628112139.GC32348@dhcp22.suse.cz>
From: Cannon Matthews <cannonmatthews@google.com>
Date: Thu, 28 Jun 2018 15:16:46 -0700
Message-ID: <CAJfu=Uc8zkN1fc73_UtiREW061xakrnMNP27oV5i3AreP1XS+w@mail.gmail.com>
Subject: Re: [PATCH] mm: hugetlb: yield when prepping struct pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, mike.kravetz@oracle.com
Cc: akpm@linux-foundation.org, nyc@holomorphy.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, Peter Feiner <pfeiner@google.com>, Greg Thelen <gthelen@google.com>

Thanks for the quick turnaround.

Good to know about the how the 2M code path differs, I have been
trying to trace through some of this and it's easy to get lost between
which applies to which size.

Thanks!
On Thu, Jun 28, 2018 at 12:03 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 27-06-18 14:44:47, Cannon Matthews wrote:
> > When booting with very large numbers of gigantic (i.e. 1G) pages, the
> > operations in the loop of gather_bootmem_prealloc, and specifically
> > prep_compound_gigantic_page, takes a very long time, and can cause a
> > softlockup if enough pages are requested at boot.
> >
> > For example booting with 3844 1G pages requires prepping
> > (set_compound_head, init the count) over 1 billion 4K tail pages, which
> > takes considerable time. This should also apply to reserving the same
> > amount of memory as 2M pages, as the same number of struct pages
> > are affected in either case.
> >
> > Add a cond_resched() to the outer loop in gather_bootmem_prealloc() to
> > prevent this lockup.
> >
> > Tested: Booted with softlockup_panic=1 hugepagesz=1G hugepages=3844 and
> > no softlockup is reported, and the hugepages are reported as
> > successfully setup.
> >
> > Signed-off-by: Cannon Matthews <cannonmatthews@google.com>
>
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> Thanks!
>
> > ---
> >  mm/hugetlb.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index a963f2034dfc..d38273c32d3b 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -2169,6 +2169,7 @@ static void __init gather_bootmem_prealloc(void)
> >                */
> >               if (hstate_is_gigantic(h))
> >                       adjust_managed_page_count(page, 1 << h->order);
> > +             cond_resched();
> >       }
> >  }
> >
> > --
> > 2.18.0.rc2.346.g013aa6912e-goog
>
> --
> Michal Hocko
> SUSE Labs
