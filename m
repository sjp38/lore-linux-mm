Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE7496B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 06:01:57 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id y72-v6so4387405lje.17
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 03:01:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k9-v6sor4304611lji.9.2018.10.05.03.01.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 03:01:56 -0700 (PDT)
MIME-Version: 1.0
References: <20181003185854.GA1174@jordon-HP-15-Notebook-PC>
 <20181003200003.GA9965@bombadil.infradead.org> <20181003221444.GZ30658@n2100.armlinux.org.uk>
 <CAFqt6zYHhmPwUdaCZX-BuAvaVwA-x1W39tz+Q50-nbEaW2cYVg@mail.gmail.com>
 <20181004123400.GC30658@n2100.armlinux.org.uk> <CAFqt6zZPOM17QwmcWKF3F1gqkJm=2PxvuJ3naWuRXZGHc2HrEQ@mail.gmail.com>
 <20181004181736.GB20842@bombadil.infradead.org> <CAFqt6zaN0PQHkjuwFf8VriROLy7qrPDu-iNE=VPiXJw8C7GpQg@mail.gmail.com>
 <CANiq72mkTP_m20vqei-cpN+ypQ_gU472qn5m68vb_4Nqj5afMQ@mail.gmail.com>
 <CAFqt6zaFc_GenhfvsD0VPfepR-jjXypj+4CgNEuHMVq1WXV+8w@mail.gmail.com> <CANiq72kVJn7985EET067Dgj+z0dwb0x2MTUnREMWKCVU6=WnJA@mail.gmail.com>
In-Reply-To: <CANiq72kVJn7985EET067Dgj+z0dwb0x2MTUnREMWKCVU6=WnJA@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 5 Oct 2018 15:31:42 +0530
Message-ID: <CAFqt6zZ4sPjtb5BaDfwc5tZv+vMj6ao3NJZ_3quX9AH5pCMwJg@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Introduce new function vm_insert_kmem_page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin@protonic.nl, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kees Cook <keescook@chromium.org>, treding@nvidia.com, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, aryabinin@virtuozzo.com, Dmitry Vyukov <dvyukov@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, tchibo@google.com, riel@redhat.com, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Huang, Ying" <ying.huang@intel.com>, ak@linux.intel.com, rppt@linux.vnet.ibm.com, linux@dominikbrodowski.net, Arnd Bergmann <arnd@arndb.de>, cpandya@codeaurora.org, hannes@cmpxchg.org, Joe Perches <joe@perches.com>, mcgrof@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, Linux-MM <linux-mm@kvack.org>

On Fri, Oct 5, 2018 at 2:22 PM Miguel Ojeda
<miguel.ojeda.sandonis@gmail.com> wrote:
>
> Hi Souptick,
>
> On Fri, Oct 5, 2018 at 7:51 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
> >
> > On Fri, Oct 5, 2018 at 1:16 AM Miguel Ojeda
> > <miguel.ojeda.sandonis@gmail.com> wrote:
> > >
> > >
> > > Also, not sure if you saw my comments/review: if the interface is not
> > > going to change, why the name change? Why can't we simply keep using
> > > vm_insert_page?
> >
> > yes, changing the name without changing the interface is a
> > bad approach and this can't be taken. As Matthew mentioned,
> > "vm_insert_range() which takes an array of struct page pointers.
> > That fits the majority of remaining users" would be a better approach
> > to fit this use case.
> >
> > But yes, we can't keep vm_insert_page and vmf_insert_page together
> > as it doesn't guarantee  that future drivers will not use vm_insert_page
> > in #PF context ( which will generate new errno to VM_FAULT_CODE).
> >
>
> Maybe I am hard of thinking, but aren't you planning to remove
> vm_insert_page with these changes? If yes, why you can't use the keep
> vm_insert_page name? In other words, keep returning what the drivers
> expect?

The final goal is to remove vm_insert_page by converting it to
vmf_insert_page. But to do that we have to first introduce the
new API which is similar to vm_insert_page  (for non #PF). I tried this by
introducing vm_insert_kmem_page ( * identical as vm_insert_page
except API name *) in this patch. But this looks like a bad approach.

The new proposal is to introduce vm_insert_range() ( * which might be
bit different from vm_insert_page but will serve all the non #PF use cases)
