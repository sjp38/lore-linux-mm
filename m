Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 373E76B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 08:15:28 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id l11-v6so3548259ljb.2
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 05:15:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p20-v6sor592221ljg.43.2018.10.04.05.15.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 05:15:26 -0700 (PDT)
MIME-Version: 1.0
References: <20181003185854.GA1174@jordon-HP-15-Notebook-PC>
 <20181003200003.GA9965@bombadil.infradead.org> <20181003221444.GZ30658@n2100.armlinux.org.uk>
In-Reply-To: <20181003221444.GZ30658@n2100.armlinux.org.uk>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 4 Oct 2018 17:45:13 +0530
Message-ID: <CAFqt6zYHhmPwUdaCZX-BuAvaVwA-x1W39tz+Q50-nbEaW2cYVg@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Introduce new function vm_insert_kmem_page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Matthew Wilcox <willy@infradead.org>, Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>, robin@protonic.nl, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kees Cook <keescook@chromium.org>, treding@nvidia.com, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, aryabinin@virtuozzo.com, Dmitry Vyukov <dvyukov@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, tchibo@google.com, riel@redhat.com, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Huang, Ying" <ying.huang@intel.com>, ak@linux.intel.com, rppt@linux.vnet.ibm.com, linux@dominikbrodowski.net, Arnd Bergmann <arnd@arndb.de>, cpandya@codeaurora.org, hannes@cmpxchg.org, Joe Perches <joe@perches.com>, mcgrof@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, Linux-MM <linux-mm@kvack.org>

On Thu, Oct 4, 2018 at 3:45 AM Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
>
> On Wed, Oct 03, 2018 at 01:00:03PM -0700, Matthew Wilcox wrote:
> > On Thu, Oct 04, 2018 at 12:28:54AM +0530, Souptick Joarder wrote:
> > > These are the approaches which could have been taken to handle
> > > this scenario -
> > >
> > > *  Replace vm_insert_page with vmf_insert_page and then write few
> > >    extra lines of code to convert VM_FAULT_CODE to errno which
> > >    makes driver users more complex ( also the reverse mapping errno to
> > >    VM_FAULT_CODE have been cleaned up as part of vm_fault_t migration ,
> > >    not preferred to introduce anything similar again)
> > >
> > > *  Maintain both vm_insert_page and vmf_insert_page and use it in
> > >    respective places. But it won't gurantee that vm_insert_page will
> > >    never be used in #PF context.
> > >
> > > *  Introduce a similar API like vm_insert_page, convert all non #PF
> > >    consumer to use it and finally remove vm_insert_page by converting
> > >    it to vmf_insert_page.
> > >
> > > And the 3rd approach was taken by introducing vm_insert_kmem_page().
> > >
> > > In short, vmf_insert_page will be used in page fault handlers
> > > context and vm_insert_kmem_page will be used to map kernel
> > > memory to user vma outside page fault handlers context.
> >
> > As far as I can tell, vm_insert_kmem_page() is line-for-line identical
> > with vm_insert_page().  Seriously, here's a diff I just did:
> >
> > -static int insert_page(struct vm_area_struct *vma, unsigned long addr,
> > -                       struct page *page, pgprot_t prot)
> > +static int insert_kmem_page(struct vm_area_struct *vma, unsigned long addr,
> > +               struct page *page, pgprot_t prot)
> > -       /* Ok, finally just insert the thing.. */
> > -int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
> > +int vm_insert_kmem_page(struct vm_area_struct *vma, unsigned long addr,
> > -       return insert_page(vma, addr, page, vma->vm_page_prot);
> > +       return insert_kmem_page(vma, addr, page, vma->vm_page_prot);
> > -EXPORT_SYMBOL(vm_insert_page);
> > +EXPORT_SYMBOL(vm_insert_kmem_page);
> >
> > What on earth are you trying to do?

>
> Reading the commit log, it seems that the intention is to split out
> vm_insert_page() used outside of page-fault handling with the use
> within page-fault handling, so that different return codes can be
> used.
>
> I don't see that justifies the code duplication - can't
> vm_insert_page() and vm_insert_kmem_page() use the same mechanics
> to do their job, and just translate the error code from the most-
> specific to the least-specific error code?  Do we really need two
> copies of the same code just to return different error codes.

Sorry about it.
can I take below approach in a patch series ->

create a wrapper function vm_insert_kmem_page using vm_insert_page.
Convert all the non #PF users to use it.
Then make vm_insert_page static and convert inline vmf_insert_page to caller.
