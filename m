Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AEDA6B026D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 14:09:14 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id t68-v6so2258263lje.12
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 11:09:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x21-v6sor3256769ljj.40.2018.10.04.11.09.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 11:09:12 -0700 (PDT)
MIME-Version: 1.0
References: <20181003185854.GA1174@jordon-HP-15-Notebook-PC>
 <20181003200003.GA9965@bombadil.infradead.org> <20181003221444.GZ30658@n2100.armlinux.org.uk>
 <CAFqt6zYHhmPwUdaCZX-BuAvaVwA-x1W39tz+Q50-nbEaW2cYVg@mail.gmail.com> <20181004123400.GC30658@n2100.armlinux.org.uk>
In-Reply-To: <20181004123400.GC30658@n2100.armlinux.org.uk>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 4 Oct 2018 23:42:18 +0530
Message-ID: <CAFqt6zZPOM17QwmcWKF3F1gqkJm=2PxvuJ3naWuRXZGHc2HrEQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Introduce new function vm_insert_kmem_page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Matthew Wilcox <willy@infradead.org>, Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>, robin@protonic.nl, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kees Cook <keescook@chromium.org>, treding@nvidia.com, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, aryabinin@virtuozzo.com, Dmitry Vyukov <dvyukov@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, tchibo@google.com, riel@redhat.com, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Huang, Ying" <ying.huang@intel.com>, ak@linux.intel.com, rppt@linux.vnet.ibm.com, linux@dominikbrodowski.net, Arnd Bergmann <arnd@arndb.de>, cpandya@codeaurora.org, hannes@cmpxchg.org, Joe Perches <joe@perches.com>, mcgrof@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, Linux-MM <linux-mm@kvack.org>

On Thu, Oct 4, 2018 at 6:04 PM Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
>
> On Thu, Oct 04, 2018 at 05:45:13PM +0530, Souptick Joarder wrote:
> > On Thu, Oct 4, 2018 at 3:45 AM Russell King - ARM Linux
> > <linux@armlinux.org.uk> wrote:
> > >
> > > On Wed, Oct 03, 2018 at 01:00:03PM -0700, Matthew Wilcox wrote:
> > > > On Thu, Oct 04, 2018 at 12:28:54AM +0530, Souptick Joarder wrote:
> > > > > These are the approaches which could have been taken to handle
> > > > > this scenario -
> > > > >
> > > > > *  Replace vm_insert_page with vmf_insert_page and then write few
> > > > >    extra lines of code to convert VM_FAULT_CODE to errno which
> > > > >    makes driver users more complex ( also the reverse mapping errno to
> > > > >    VM_FAULT_CODE have been cleaned up as part of vm_fault_t migration ,
> > > > >    not preferred to introduce anything similar again)
> > > > >
> > > > > *  Maintain both vm_insert_page and vmf_insert_page and use it in
> > > > >    respective places. But it won't gurantee that vm_insert_page will
> > > > >    never be used in #PF context.
> > > > >
> > > > > *  Introduce a similar API like vm_insert_page, convert all non #PF
> > > > >    consumer to use it and finally remove vm_insert_page by converting
> > > > >    it to vmf_insert_page.
> > > > >
> > > > > And the 3rd approach was taken by introducing vm_insert_kmem_page().
> > > > >
> > > > > In short, vmf_insert_page will be used in page fault handlers
> > > > > context and vm_insert_kmem_page will be used to map kernel
> > > > > memory to user vma outside page fault handlers context.
> > > >
> > > > As far as I can tell, vm_insert_kmem_page() is line-for-line identical
> > > > with vm_insert_page().  Seriously, here's a diff I just did:
> > > >
> > > > -static int insert_page(struct vm_area_struct *vma, unsigned long addr,
> > > > -                       struct page *page, pgprot_t prot)
> > > > +static int insert_kmem_page(struct vm_area_struct *vma, unsigned long addr,
> > > > +               struct page *page, pgprot_t prot)
> > > > -       /* Ok, finally just insert the thing.. */
> > > > -int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
> > > > +int vm_insert_kmem_page(struct vm_area_struct *vma, unsigned long addr,
> > > > -       return insert_page(vma, addr, page, vma->vm_page_prot);
> > > > +       return insert_kmem_page(vma, addr, page, vma->vm_page_prot);
> > > > -EXPORT_SYMBOL(vm_insert_page);
> > > > +EXPORT_SYMBOL(vm_insert_kmem_page);
> > > >
> > > > What on earth are you trying to do?
> >
> > >
> > > Reading the commit log, it seems that the intention is to split out
> > > vm_insert_page() used outside of page-fault handling with the use
> > > within page-fault handling, so that different return codes can be
> > > used.
> > >
> > > I don't see that justifies the code duplication - can't
> > > vm_insert_page() and vm_insert_kmem_page() use the same mechanics
> > > to do their job, and just translate the error code from the most-
> > > specific to the least-specific error code?  Do we really need two
> > > copies of the same code just to return different error codes.
> >
> > Sorry about it.
> > can I take below approach in a patch series ->
> >
> > create a wrapper function vm_insert_kmem_page using vm_insert_page.
> > Convert all the non #PF users to use it.
> > Then make vm_insert_page static and convert inline vmf_insert_page to caller.
>
> I'm confused, what are you trying to do?
>
> It seems that we already have:
>
> vm_insert_page() - returns an errno
> vmf_insert_page() - returns a VM_FAULT_* code
>
> From what I _think_ you're saying, you're trying to provide
> vm_insert_kmem_page() as a direct replacement for the existing
> vm_insert_page(), and then make vm_insert_page() behave as per
> vmf_insert_page(), so we end up with:

yes, vm_insert_kmem_page() can be a direct replacement of vm_insert_page
or might be a wrapper function written using vm_insert_page whichever
suites better
based on feedback.

>
> vm_insert_kmem_page() - returns an errno
> vm_insert_page() - returns a VM_FAULT_* code
> vmf_insert_page() - returns a VM_FAULT_* code and is identical to
>       vm_insert_page()
>

After completion of conversion we end up with

 vm_insert_kmem_page() - returns an errno
 vmf_insert_page() - returns a VM_FAULT_* code


> Given that the documentation for vm_insert_page() says:
>
>  * Usually this function is called from f_op->mmap() handler
>  * under mm->mmap_sem write-lock, so it can change vma->vm_flags.
>  * Caller must set VM_MIXEDMAP on vma if it wants to call this
>  * function from other places, for example from page-fault handler.
>
> this says that the "usual" use method for vm_insert_page() is
> _outside_ of page fault handling - if it is used _inside_ page fault
> handling, then it states that additional fixups are required on the
> VMA.  So I don't get why your patch commentry seems to be saying that
> users of vm_insert_page() outside of page fault handling all need to
> be patched - isn't this the use case that this function is defined
> to be handling?

The answer is yes best of my knowledge.

But as mentioned in change log ->

Going forward, the plan is to restrict future drivers not
to use vm_insert_page ( *it will generate new errno to
VM_FAULT_CODE mapping code for new drivers which were already
cleaned up for existing drivers*) in #PF (page fault handler)
context but to make use of vmf_insert_page which returns
VMF_FAULT_CODE and that is not possible until both vm_insert_page
and vmf_insert_page API exists.

But there are some consumers of vm_insert_page which use it
outside #PF context. straight forward conversion of vm_insert_page
to vmf_insert_page won't work there as those function calls expects
errno not vm_fault_t in return.

If both {vm, vmf}_insert_page exists, vm_insert_page might be used for
#PF context which we want to protect by removing/ replacing vm_insert_page
with another similar/ wrapper API.

Is that the right answer of your question ? no ?

>
> If you're going to be changing the semantics, doesn't this create a
> flag day where we could get new users of vm_insert_page() using the
> _existing_ semantics merged after you've changed its semantics (eg,
> the return code)?

No, vm_insert_page API will remove/ replace only when all the user are
converted.
We will do it intermediately by first introducing new API, convert all
user to use it
and at final step remove the old API.
