Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5EEA16B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 14:18:06 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id r205-v6so1682347lff.4
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 11:18:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c17-v6sor1152749lja.38.2018.10.04.11.18.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 11:18:04 -0700 (PDT)
MIME-Version: 1.0
References: <20181003185854.GA1174@jordon-HP-15-Notebook-PC> <20181003200003.GA9965@bombadil.infradead.org>
In-Reply-To: <20181003200003.GA9965@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 4 Oct 2018 23:51:12 +0530
Message-ID: <CAFqt6za_OxXArRQfzK1h3L1o+TgU+Xz02gLy2yp0rxAJfFwnqA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Introduce new function vm_insert_kmem_page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>, Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>, robin@protonic.nl, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kees Cook <keescook@chromium.org>, treding@nvidia.com, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, aryabinin@virtuozzo.com, Dmitry Vyukov <dvyukov@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, tchibo@google.com, riel@redhat.com, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Huang, Ying" <ying.huang@intel.com>, ak@linux.intel.com, rppt@linux.vnet.ibm.com, linux@dominikbrodowski.net, Arnd Bergmann <arnd@arndb.de>, cpandya@codeaurora.org, hannes@cmpxchg.org, Joe Perches <joe@perches.com>, mcgrof@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, Linux-MM <linux-mm@kvack.org>

Hi Matthew,

On Thu, Oct 4, 2018 at 1:30 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Oct 04, 2018 at 12:28:54AM +0530, Souptick Joarder wrote:
> > These are the approaches which could have been taken to handle
> > this scenario -
> >
> > *  Replace vm_insert_page with vmf_insert_page and then write few
> >    extra lines of code to convert VM_FAULT_CODE to errno which
> >    makes driver users more complex ( also the reverse mapping errno to
> >    VM_FAULT_CODE have been cleaned up as part of vm_fault_t migration ,
> >    not preferred to introduce anything similar again)
> >
> > *  Maintain both vm_insert_page and vmf_insert_page and use it in
> >    respective places. But it won't gurantee that vm_insert_page will
> >    never be used in #PF context.
> >
> > *  Introduce a similar API like vm_insert_page, convert all non #PF
> >    consumer to use it and finally remove vm_insert_page by converting
> >    it to vmf_insert_page.
> >
> > And the 3rd approach was taken by introducing vm_insert_kmem_page().
> >
> > In short, vmf_insert_page will be used in page fault handlers
> > context and vm_insert_kmem_page will be used to map kernel
> > memory to user vma outside page fault handlers context.
>
> As far as I can tell, vm_insert_kmem_page() is line-for-line identical
> with vm_insert_page().  Seriously, here's a diff I just did:
>
> -static int insert_page(struct vm_area_struct *vma, unsigned long addr,
> -                       struct page *page, pgprot_t prot)
> +static int insert_kmem_page(struct vm_area_struct *vma, unsigned long addr,
> +               struct page *page, pgprot_t prot)
> -       /* Ok, finally just insert the thing.. */
> -int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
> +int vm_insert_kmem_page(struct vm_area_struct *vma, unsigned long addr,
> -       return insert_page(vma, addr, page, vma->vm_page_prot);
> +       return insert_kmem_page(vma, addr, page, vma->vm_page_prot);
> -EXPORT_SYMBOL(vm_insert_page);
> +EXPORT_SYMBOL(vm_insert_kmem_page);
>
> What on earth are you trying to do?

Shall I take below approach rather than just creating a identical API
same as vm_insert_page ??

1. create a wrapper function vm_insert_kmem_page using vm_insert_page.
2. Convert all the non #PF users to use it.
3. Then make vm_insert_page static and convert inline vmf_insert_page to caller.

In that way we will be having two functions vmf_insert_page (#PF) and
vm_insert_kmem_page (non #PF) and both will be using common vm_insert_page
which will be static.

I am clear with the problem statement but not very clear on my solution.
