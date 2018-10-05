Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 49F996B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 01:51:04 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id r20-v6so2363267ljj.1
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 22:51:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z7-v6sor3992484ljk.22.2018.10.04.22.51.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 22:51:02 -0700 (PDT)
MIME-Version: 1.0
References: <20181003185854.GA1174@jordon-HP-15-Notebook-PC>
 <20181003200003.GA9965@bombadil.infradead.org> <20181003221444.GZ30658@n2100.armlinux.org.uk>
 <CAFqt6zYHhmPwUdaCZX-BuAvaVwA-x1W39tz+Q50-nbEaW2cYVg@mail.gmail.com>
 <20181004123400.GC30658@n2100.armlinux.org.uk> <CAFqt6zZPOM17QwmcWKF3F1gqkJm=2PxvuJ3naWuRXZGHc2HrEQ@mail.gmail.com>
 <20181004181736.GB20842@bombadil.infradead.org> <CAFqt6zaN0PQHkjuwFf8VriROLy7qrPDu-iNE=VPiXJw8C7GpQg@mail.gmail.com>
 <CANiq72mkTP_m20vqei-cpN+ypQ_gU472qn5m68vb_4Nqj5afMQ@mail.gmail.com>
In-Reply-To: <CANiq72mkTP_m20vqei-cpN+ypQ_gU472qn5m68vb_4Nqj5afMQ@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 5 Oct 2018 11:20:49 +0530
Message-ID: <CAFqt6zaFc_GenhfvsD0VPfepR-jjXypj+4CgNEuHMVq1WXV+8w@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Introduce new function vm_insert_kmem_page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin@protonic.nl, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kees Cook <keescook@chromium.org>, treding@nvidia.com, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, aryabinin@virtuozzo.com, Dmitry Vyukov <dvyukov@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, tchibo@google.com, riel@redhat.com, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Huang, Ying" <ying.huang@intel.com>, ak@linux.intel.com, rppt@linux.vnet.ibm.com, linux@dominikbrodowski.net, Arnd Bergmann <arnd@arndb.de>, cpandya@codeaurora.org, hannes@cmpxchg.org, Joe Perches <joe@perches.com>, mcgrof@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, Linux-MM <linux-mm@kvack.org>

On Fri, Oct 5, 2018 at 1:16 AM Miguel Ojeda
<miguel.ojeda.sandonis@gmail.com> wrote:
>
> Hi Souptick,
>
> On Thu, Oct 4, 2018 at 8:49 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
> >
> > On Thu, Oct 4, 2018 at 11:47 PM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > I think this is a bad plan.  What we should rather do is examine the current
> > > users of vm_insert_page() and ask "What interface would better replace
> > > vm_insert_page()?"
> > >
> > > As I've said to you before, I believe the right answer is to have a
> > > vm_insert_range() which takes an array of struct page pointers.  That
> > > fits the majority of remaining users.
> >
> > Ok, but it will take some time.
> > Is it a good idea to introduce the final vm_fault_t patch and then
> > start working on vm_insert_range as it will be bit time consuming ?
> >
>
> Well, why is there a rush? Development should be done in a patch
> series or a tree, and submitted as a whole, instead of sending partial
> patches.

Not in hurry, will do it in a patch series :-)
>
> Also, not sure if you saw my comments/review: if the interface is not
> going to change, why the name change? Why can't we simply keep using
> vm_insert_page?

yes, changing the name without changing the interface is a
bad approach and this can't be taken. As Matthew mentioned,
"vm_insert_range() which takes an array of struct page pointers.
That fits the majority of remaining users" would be a better approach
to fit this use case.

But yes, we can't keep vm_insert_page and vmf_insert_page together
as it doesn't guarantee  that future drivers will not use vm_insert_page
in #PF context ( which will generate new errno to VM_FAULT_CODE).

Any further comment form others on vm_Insert_range() approach ?
