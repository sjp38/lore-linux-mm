Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9A63D6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 23:38:50 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so485023pab.28
        for <linux-mm@kvack.org>; Wed, 14 May 2014 20:38:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ud7si3946259pab.40.2014.05.14.20.38.49
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 20:38:49 -0700 (PDT)
Date: Wed, 14 May 2014 20:38:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 -next] x86,vdso: Fix an OOPS accessing the hpet
 mapping w/o an hpet
Message-Id: <20140514203859.8c82aa3a.akpm@linux-foundation.org>
In-Reply-To: <CAJd=RBC1E9x-zU-zJbNP+zbPgb=nhi39TqrxqpcGdi=OR9duXg@mail.gmail.com>
References: <c8b0a9a0b8d011a8b273cbb2de88d37190ed2751.1400111179.git.luto@amacapital.net>
	<CAJd=RBC1E9x-zU-zJbNP+zbPgb=nhi39TqrxqpcGdi=OR9duXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, x86@kernel.org, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Stefani Seibold <stefani@seibold.net>

On Thu, 15 May 2014 11:18:29 +0800 Hillf Danton <dhillf@gmail.com> wrote:

> > --- a/arch/x86/vdso/vma.c
> > +++ b/arch/x86/vdso/vma.c
> > @@ -90,6 +90,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
> >         struct vm_area_struct *vma;
> >         unsigned long addr;
> >         int ret = 0;
> > +       static struct page *no_pages[] = {NULL};
> >
> >         if (calculate_addr) {
> >                 addr = vdso_addr(current->mm->start_stack,
> > @@ -125,7 +126,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
> >                                        addr + image->size,
> >                                        image->sym_end_mapping - image->size,
> >                                        VM_READ,
> > -                                      NULL);
> > +                                      no_pages);
> >
> >         if (IS_ERR(vma)) {
> >                 ret = PTR_ERR(vma);
> > --
> > 1.9.0
> >
> As the comment says,
> /*
>  * Called with mm->mmap_sem held for writing.
>  * Insert a new vma covering the given region, with the given flags.
>  * Its pages are supplied by the given array of struct page *.
>  * The array can be shorter than len >> PAGE_SHIFT if it's null-terminated.
>  * The region past the last page supplied will always produce SIGBUS.
>  * The array pointer and the pages it points to are assumed to stay alive
>  * for as long as this mapping might exist.
>  */
> struct vm_area_struct *_install_special_mapping(struct mm_struct *mm,
>    unsigned long addr, unsigned long len,
>    unsigned long vm_flags, struct page **pages)
> {
> 
> we can send sigbus at fault time if no pages are supplied at install time.

Yes, but the way to communicate "no pages" is to pass (*pages)==NULL. 
Passing (pages)==NULL causes the code to oops at fault time.

We could easily change the interface so that pages==NULL means "no
pages" but that isn't the way it works at present.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
