Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 059D38E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 16:45:16 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id x9-v6so1418295ljd.21
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 13:45:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l20-v6sor3201430lji.21.2018.12.07.13.45.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 13:45:14 -0800 (PST)
MIME-Version: 1.0
References: <20181206183945.GA20932@jordon-HP-15-Notebook-PC>
 <53bbc095-c9f5-5d6a-6e50-6e060d17eb68@arm.com> <20181207171116.GA29923@bombadil.infradead.org>
 <CAFqt6zYCWOK-uS85GqCzcgT=+YKn1nBrRPq+M9y6eJjmXEKH+g@mail.gmail.com> <67495f8f-2092-e42d-321e-5216c346513f@arm.com>
In-Reply-To: <67495f8f-2092-e42d-321e-5216c346513f@arm.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Dec 2018 03:18:49 +0530
Message-ID: <CAFqt6zbuT3mhLCSas=EO38NW+M4KAARKeBpMqDz6xwkVbw=FGA@mail.gmail.com>
Subject: Re: [PATCH v3 1/9] mm: Introduce new vm_insert_range API
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robin.murphy@arm.com
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On Sat, Dec 8, 2018 at 2:40 AM Robin Murphy <robin.murphy@arm.com> wrote:
>
> On 2018-12-07 7:28 pm, Souptick Joarder wrote:
> > On Fri, Dec 7, 2018 at 10:41 PM Matthew Wilcox <willy@infradead.org> wrote:
> >>
> >> On Fri, Dec 07, 2018 at 03:34:56PM +0000, Robin Murphy wrote:
> >>>> +int vm_insert_range(struct vm_area_struct *vma, unsigned long addr,
> >>>> +                   struct page **pages, unsigned long page_count)
> >>>> +{
> >>>> +   unsigned long uaddr = addr;
> >>>> +   int ret = 0, i;
> >>>
> >>> Some of the sites being replaced were effectively ensuring that vma and
> >>> pages were mutually compatible as an initial condition - would it be worth
> >>> adding something here for robustness, e.g.:
> >>>
> >>> +     if (page_count != vma_pages(vma))
> >>> +             return -ENXIO;
> >>
> >> I think we want to allow this to be used to populate part of a VMA.
> >> So perhaps:
> >>
> >>          if (page_count > vma_pages(vma))
> >>                  return -ENXIO;
> >
> > Ok, This can be added.
> >
> > I think Patch [2/9] is the only leftover place where this
> > check could be removed.
>
> Right, 9/9 could also have relied on my stricter check here, but since
> it's really testing whether it actually managed to allocate vma_pages()
> worth of pages earlier, Matthew's more lenient version won't help for
> that one.


(Why privcmd_buf_mmap() doesn't clean up and return an error
> as soon as that allocation loop fails, without taking the mutex under
> which it still does a bunch more pointless work to only undo it again,
> is a mind-boggling mystery, but that's not our problem here...)

I think some clean up can be done here in a separate patch.
