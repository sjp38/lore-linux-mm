Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 318406B006E
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 22:14:18 -0500 (EST)
Received: by mail-vc0-f175.google.com with SMTP id ij19so1581057vcb.20
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 19:14:17 -0800 (PST)
Received: from mail-vc0-x22d.google.com (mail-vc0-x22d.google.com [2607:f8b0:400c:c03::22d])
        by mx.google.com with ESMTPS id at8si1054275vec.151.2014.02.28.19.14.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 19:14:17 -0800 (PST)
Received: by mail-vc0-f173.google.com with SMTP id ld13so1599852vcb.32
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 19:14:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140228135950.4a49ce89b5bff12c149b1f73@linux-foundation.org>
References: <1393507600-24752-1-git-send-email-bob.liu@oracle.com>
	<20140227154808.cbe04fa80cb47e2e091daa31@linux-foundation.org>
	<20140227235959.GA9424@node.dhcp.inet.fi>
	<20140228090745.GE27965@twins.programming.kicks-ass.net>
	<20140228135950.4a49ce89b5bff12c149b1f73@linux-foundation.org>
Date: Sat, 1 Mar 2014 11:14:17 +0800
Message-ID: <CAA_GA1dzMA+RS=TtM6ieJ7_DY5ruAbY9a4Ui9O7EYuvc-bSH_A@mail.gmail.com>
Subject: Re: [PATCH] mm: do_shared_fault: fix potential NULL pointer dereference
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>

On Sat, Mar 1, 2014 at 5:59 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 28 Feb 2014 10:07:45 +0100 Peter Zijlstra <peterz@infradead.org> wrote:
>
>> On Fri, Feb 28, 2014 at 01:59:59AM +0200, Kirill A. Shutemov wrote:
>> > On Thu, Feb 27, 2014 at 03:48:08PM -0800, Andrew Morton wrote:
>> > > On Thu, 27 Feb 2014 21:26:40 +0800 Bob Liu <lliubbo@gmail.com> wrote:
>> > >
>> > > > --- a/mm/memory.c
>> > > > +++ b/mm/memory.c
>> > > > @@ -3419,6 +3419,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>> > > >                 pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
>> > > >  {
>> > > >         struct page *fault_page;
>> > > > +       struct address_space *mapping;
>> > > >         spinlock_t *ptl;
>> > > >         pte_t *pte;
>> > > >         int dirtied = 0;
>> > > > @@ -3454,13 +3455,14 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>> > > >
>> > > >         if (set_page_dirty(fault_page))
>> > > >                 dirtied = 1;
>> > > > +       mapping = fault_page->mapping;
>> > > >         unlock_page(fault_page);
>> > > > -       if ((dirtied || vma->vm_ops->page_mkwrite) && fault_page->mapping) {
>> > > > +       if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
>> > > >                 /*
>> > > >                  * Some device drivers do not set page.mapping but still
>> > > >                  * dirty their pages
>> > > >                  */
>> > > > -               balance_dirty_pages_ratelimited(fault_page->mapping);
>> > > > +               balance_dirty_pages_ratelimited(mapping);
>> > > >         }
>> > > >
>> > > >         /* file_update_time outside page_lock */
>> > >
>> > > So from my reading of the email thread, this patch has issues: the
>> > > compiler can just undo what you did.
>> >
>> > If I read PeterZ correctly, we are fine with the fix since unlock_page()
>> > has release semantics.
>>
>> Yeah, the compiler should not re-read mapping after unlock_page(). That
>> said; it might be good to put a comment near there saying we actually
>> rely on this, and _why_ we rely on this.
>
> Like this?
>
> --- a/mm/memory.c~mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
> +++ a/mm/memory.c
> @@ -3476,6 +3476,12 @@ set_pte:
>
>         if (set_page_dirty(fault_page))
>                 dirtied = 1;
> +       /*
> +        * Take a local copy of the address_space - page.mapping may be zeroed
> +        * by truncate after unlock_page().   The address_space itself remains
> +        * pinned by vma->vm_file's reference.  We rely on unlock_page()'s
> +        * release semantics to prevent the compiler from undoing this copying.
> +        */
>         mapping = fault_page->mapping;
>         unlock_page(fault_page);
>         if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
>
> I don't actually know if that's true.  What *does* protect ->mapping
> from reclaim, drop_caches, etc?
>

I also puzzled what can protect ->mapping. This patch just change the
handling of shared-write-pagefault back to the same way as it used to
be. Perhaps we should add if(mapping==NULL) into
balance_dirty_pages_ratelimited() and balance_dirty_pages()?

BTW: Sasha, could you please have a test with this patch?

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
