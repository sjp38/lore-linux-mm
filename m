Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id AA6C26B0039
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 19:59:41 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id uy5so4341675obc.6
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 16:59:41 -0800 (PST)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id tm2si16661232oeb.94.2014.03.03.16.59.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 16:59:41 -0800 (PST)
Message-ID: <1393894778.30648.29.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v4] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 03 Mar 2014 16:59:38 -0800
In-Reply-To: <20140303164002.02df915e12d05bb98762407f@linux-foundation.org>
References: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
	 <20140303164002.02df915e12d05bb98762407f@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2014-03-03 at 16:40 -0800, Andrew Morton wrote:
> On Thu, 27 Feb 2014 13:48:24 -0800 Davidlohr Bueso <davidlohr@hp.com> wrote:
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -342,9 +342,9 @@ struct mm_rss_stat {
> >  
> >  struct kioctx_table;
> >  struct mm_struct {
> > -	struct vm_area_struct * mmap;		/* list of VMAs */
> > +	struct vm_area_struct *mmap;		/* list of VMAs */
> >  	struct rb_root mm_rb;
> > -	struct vm_area_struct * mmap_cache;	/* last find_vma result */
> > +	u32 vmacache_seqnum;                   /* per-thread vmacache */
> 
> nitpick: in kernelese this is typically "per-task".  If it was in the
> mm_struct then it would be "per process".  And I guess if it was in the
> thread_struct it would be "per thread", but that isn't a distinction
> I've seen made.

Sure, I am referring to per-task, subject title as well. My mind just
treats them as synonyms in this context. My bad.

> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -23,6 +23,7 @@ struct sched_param {
> >  #include <linux/errno.h>
> >  #include <linux/nodemask.h>
> >  #include <linux/mm_types.h>
> > +#include <linux/vmacache.h>
> 
> This might be awkward - vmacache.h drags in mm.h and we have had tangly
> problems with these major header files in the past.  I'd be inclined to
> remove this inclusion and just forward-declare vm_area_struct, but we
> still need VMACACHE_SIZE, sigh.  Wait and see what happens, I guess.

Yeah, I wasn't sure what to do about that and was expecting it to come
up in the review process. Let me know if you want me to change/update
this.

> > ...
> >
> > --- /dev/null
> > +++ b/include/linux/vmacache.h
> > @@ -0,0 +1,40 @@
> > +#ifndef __LINUX_VMACACHE_H
> > +#define __LINUX_VMACACHE_H
> > +
> > +#include <linux/mm.h>
> > +
> > +#define VMACACHE_BITS 2
> > +#define VMACACHE_SIZE (1U << VMACACHE_BITS)
> > +#define VMACACHE_MASK (VMACACHE_SIZE - 1)
> > +/*
> > + * Hash based on the page number. Provides a good hit rate for
> > + * workloads with good locality and those with random accesses as well.
> > + */
> > +#define VMACACHE_HASH(addr) ((addr >> PAGE_SHIFT) & VMACACHE_MASK)
> > +
> > +#define vmacache_flush(tsk)					 \
> > +	do {							 \
> > +		memset(tsk->vmacache, 0, sizeof(tsk->vmacache)); \
> > +	} while (0)
> 
> There's no particular reason to implement this in cpp.  Using C is
> typesafer and nicer.  But then we get into header file issues again. 
> More sigh

Yep, I ran into that issue when trying to make it an inline function.

> 
> > +extern void vmacache_flush_all(struct mm_struct *mm);
> > +extern void vmacache_update(unsigned long addr, struct vm_area_struct *newvma);
> > +extern struct vm_area_struct *vmacache_find(struct mm_struct *mm,
> > +						    unsigned long addr);
> > +
> > +#ifndef CONFIG_MMU
> > +extern struct vm_area_struct *vmacache_find_exact(struct mm_struct *mm,
> > +						  unsigned long start,
> > +						  unsigned long end);
> > +#endif
> 
> We often omit the ifdefs in this case.  It means that a compile-time
> error becomes a link-time error but that's a small cost for unmucking
> the header files.  It doesn't matter much in vmacache.h, but some
> headers would become a complete maze of ifdefs otherwise.

Ok.

> >...
> >
> > +static bool vmacache_valid(struct mm_struct *mm)
> > +{
> > +	struct task_struct *curr = current;
> > +
> > +	if (mm != curr->mm)
> > +		return false;
> 
> What's going on here?  Handling a task poking around in someone else's
> mm?  I'm thinking "__access_remote_vm", but I don't know what you were
> thinking ;) An explanatory comment would be revealing.

I don't understand the doubt here. Seems like a pretty obvious thing to
check -- yes it's probably unlikely but we certainly don't want to be
validating the cache on an mm that's not ours... or are you saying it's
redundant??

And no, we don't want __access_remote_vm() here.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
