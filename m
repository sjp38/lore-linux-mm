Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47F046B026D
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 13:39:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e7-v6so3535448edb.23
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 10:39:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g21si1123720edy.160.2018.10.10.10.38.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 10:38:59 -0700 (PDT)
Date: Wed, 10 Oct 2018 19:38:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't clobber partially overlapping VMA with
 MAP_FIXED_NOREPLACE
Message-ID: <20181010173857.GM5873@dhcp22.suse.cz>
References: <20181010152736.99475-1-jannh@google.com>
 <20181010171944.GJ5873@dhcp22.suse.cz>
 <CAG48ez04KK62doMwsTVN4nN8y_wmv7hn+4my2jk5VXKL0wP7Lg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez04KK62doMwsTVN4nN8y_wmv7hn+4my2jk5VXKL0wP7Lg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, abdhalee@linux.vnet.ibm.com, joel@jms.id.au, Kees Cook <keescook@chromium.org>, jasone@google.com, davidtgoldblatt@gmail.com, trasz@freebsd.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Daniel Micay <danielmicay@gmail.com>, kernel list <linux-kernel@vger.kernel.org>

On Wed 10-10-18 19:26:50, Jann Horn wrote:
[...]
> As you can see, the first page of the mapping at 0x10001000 was clobbered.
> 
> > > diff --git a/mm/mmap.c b/mm/mmap.c
> > > index 5f2b2b184c60..f7cd9cb966c0 100644
> > > --- a/mm/mmap.c
> > > +++ b/mm/mmap.c
> > > @@ -1410,7 +1410,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
> > >       if (flags & MAP_FIXED_NOREPLACE) {
> > >               struct vm_area_struct *vma = find_vma(mm, addr);
> > >
> > > -             if (vma && vma->vm_start <= addr)
> > > +             if (vma && vma->vm_start < addr + len)
> >
> > find_vma is documented to - Look up the first VMA which satisfies addr <
> > vm_end, NULL if none.
> > This means that the above check guanratees that
> >         vm_start <= addr < vm_end
> > so an overlap is guanrateed. Why should we care how much we overlap?
> 
> "an overlap is guaranteed"? I have no idea what you're trying to say.

I have misread your changelog and the patch. Sorry about that. I thought
you meant a false possitive but you in fact meant false negative. Now it
makes complete sense.

Acked-by: Michal Hocko <mhocko@suse.com>

And thanks a lot for catching that!

-- 
Michal Hocko
SUSE Labs
