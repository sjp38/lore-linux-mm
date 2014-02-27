Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f49.google.com (mail-oa0-f49.google.com [209.85.219.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4686B0072
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 11:07:31 -0500 (EST)
Received: by mail-oa0-f49.google.com with SMTP id g12so606096oah.22
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 08:07:31 -0800 (PST)
Received: from g5t1627.atlanta.hp.com (g5t1627.atlanta.hp.com. [15.192.137.10])
        by mx.google.com with ESMTPS id b6si7063281oem.31.2014.02.27.08.07.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Feb 2014 08:07:30 -0800 (PST)
Message-ID: <1393517246.3884.16.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v3] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 27 Feb 2014 08:07:26 -0800
In-Reply-To: <CANN689FmKv1wy-sM--VOnEc=+r9=xesfT4frq=3TEH-uMHhjjA@mail.gmail.com>
References: <1393459641.25123.21.camel@buesod1.americas.hpqcorp.net>
	 <CANN689FmKv1wy-sM--VOnEc=+r9=xesfT4frq=3TEH-uMHhjjA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2014-02-26 at 22:47 -0800, Michel Lespinasse wrote:
> Agree with Linus; this is starting to look pretty good.
> 
> I still have nits though :)
> 
> On Wed, Feb 26, 2014 at 4:07 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > @@ -0,0 +1,45 @@
> > +#ifndef __LINUX_VMACACHE_H
> > +#define __LINUX_VMACACHE_H
> > +
> > +#include <linux/mm.h>
> > +
> > +#ifdef CONFIG_MMU
> > +#define VMACACHE_BITS 2
> > +#else
> > +#define VMACACHE_BITS 0
> > +#endif
> 
> I wouldn't even both with the #ifdef here - why not just always use 2 bits ?

Sure.

> > +#define vmacache_flush(tsk)                                     \
> > +       do {                                                     \
> > +               memset(tsk->vmacache, 0, sizeof(tsk->vmacache)); \
> > +       } while (0)
> 
> I think inline functions are preferred

Indeed, but I used a macro instead because we don't have access to
'struct task_struct' from vmacache.h, since we also include it in
sched.h.

> 
> > diff --git a/mm/nommu.c b/mm/nommu.c
> > index 8740213..9a5347b 100644
> > --- a/mm/nommu.c
> > +++ b/mm/nommu.c
> > @@ -768,16 +768,19 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
> >   */
> >  static void delete_vma_from_mm(struct vm_area_struct *vma)
> >  {
> > +       int i;
> >         struct address_space *mapping;
> >         struct mm_struct *mm = vma->vm_mm;
> > +       struct task_struct *curr = current;
> >
> >         kenter("%p", vma);
> >
> >         protect_vma(vma, 0);
> >
> >         mm->map_count--;
> > -       if (mm->mmap_cache == vma)
> > -               mm->mmap_cache = NULL;
> > +       for (i = 0; i < VMACACHE_SIZE; i++)
> > +               if (curr->vmacache[i] == vma)
> > +                       curr->vmacache[i] = NULL;
> 
> Why is the invalidation done differently here ? shouldn't it be done
> by bumping the mm's sequence number so that invalidation works accross
> all threads sharing that mm ?

You are absolutely right. I will update this.

> 
> > +#ifndef CONFIG_MMU
> > +struct vm_area_struct *vmacache_find_exact(struct mm_struct *mm,
> > +                                          unsigned long start,
> > +                                          unsigned long end)
> > +{
> > +       int i;
> > +
> > +       if (!vmacache_valid(mm))
> > +               return NULL;
> > +
> > +       for (i = 0; i < VMACACHE_SIZE; i++) {
> > +               struct vm_area_struct *vma = current->vmacache[i];
> > +
> > +               if (vma && vma->vm_start == start && vma->vm_end == end)
> > +                       return vma;
> > +       }
> > +
> > +       return NULL;
> > +
> > +}
> > +#endif
> 
> I think the caller could do instead
> vma = vmacache_find(mm, start)
> if (vma && vma->vm_start == start && vma->vm_end == end) {
> }
> 
> I.e. better deal with it at the call site than add a new vmacache
> function for it.

But that would require two vma checks as the vmacache_find() function
needs to verify the matching vmas before returning. I had also thought
of passing a pointer to a matching function where we do the default (the
addr within a range) or the exact lookup. Seemed more of an overkill so
I just went with just adding a vmacache_find_exact() for !CONFIG_MMU.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
