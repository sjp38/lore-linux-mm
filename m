Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 748E86B0033
	for <linux-mm@kvack.org>; Thu, 30 May 2013 17:01:18 -0400 (EDT)
Received: by mail-ob0-f177.google.com with SMTP id ta17so1606507obb.36
        for <linux-mm@kvack.org>; Thu, 30 May 2013 14:01:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130524140114.GK23650@twins.programming.kicks-ass.net>
References: <alpine.DEB.2.10.1305221523420.9944@vincent-weaver-1.um.maine.edu>
 <alpine.DEB.2.10.1305221953370.11450@vincent-weaver-1.um.maine.edu>
 <alpine.DEB.2.10.1305222344060.12929@vincent-weaver-1.um.maine.edu>
 <20130523044803.GA25399@ZenIV.linux.org.uk> <20130523104154.GA23650@twins.programming.kicks-ass.net>
 <0000013ed1b8d0cc-ad2bb878-51bd-430c-8159-629b23ed1b44-000000@email.amazonses.com>
 <20130523152458.GD23650@twins.programming.kicks-ass.net> <0000013ed2297ba8-467d474a-7068-45b3-9fa3-82641e6aa363-000000@email.amazonses.com>
 <20130523163901.GG23650@twins.programming.kicks-ass.net> <0000013ed28b638a-066d7dc7-b590-49f8-9423-badb9537b8b6-000000@email.amazonses.com>
 <20130524140114.GK23650@twins.programming.kicks-ass.net>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 30 May 2013 17:00:55 -0400
Message-ID: <CAHGf_=oL+8n1aFx1T-7iH0gw9f95yY9doAdE+PZd4biSUTzstw@mail.gmail.com>
Subject: Re: [RFC][PATCH] mm: Fix RLIMIT_MEMLOCK
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux.com>, Al Viro <viro@zeniv.linux.org.uk>, Vince Weaver <vincent.weaver@maine.edu>, LKML <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, trinity@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Roland Dreier <roland@kernel.org>, infinipath@qlogic.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
> index a841123..f8f47dc 100644
> --- a/drivers/infiniband/core/umem.c
> +++ b/drivers/infiniband/core/umem.c
> @@ -137,17 +137,22 @@ struct ib_umem *ib_umem_get (struct ib_ucontext *context, unsigned long addr,
>
>         down_write(&current->mm->mmap_sem);
>
> -       locked     = npages + current->mm->pinned_vm;
> +       locked     = npages + mm_locked_pages(current->mm);
>         lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>
>         if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
>                 ret = -ENOMEM;
> -               goto out;
> +               goto err;
>         }
>
>         cur_base = addr & PAGE_MASK;
> +       umem->start_addr = cur_base;
> +       umem->end_addr   = cur_base + npages;
> +
> +       ret = mm_mpin(umem->start_addr, umem->end_addr);
> +       if (ret)
> +               goto err;

I believe RLIMIT_MEMLOCK should be checked within mm_mpin().


> +static inline unsigned long mm_locked_pages(struct mm_struct *mm)
> +{
> +       return mm->pinned_vm + mm->locked_vm;
> +}

This is acceptable. but if we create mm_locked_pages(), /proc should
also use this.
Otherwise pinning operation magically decrease VmLck field in
/proc/pid/status and people
get a confusion.



> @@ -310,9 +309,49 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
>          * Keep track of amount of locked VM.
>          */
>         nr_pages = (end - start) >> PAGE_SHIFT;
> -       if (!lock)
> -               nr_pages = -nr_pages;
> -       mm->locked_vm += nr_pages;
> +
> +       /*
> +        * We should only account pages once, if VM_PINNED is set pages are
> +        * accounted in mm_struct::pinned_vm, otherwise if VM_LOCKED is set,
> +        * we'll account them in mm_struct::locked_vm.
> +        *
> +        * PL  := vma->vm_flags
> +        * PL' := newflags
> +        * PLd := {pinned,locked}_vm delta
> +        *
> +        * PL->PL' PLd
> +        * -----------
> +        * 00  01  0+
> +        * 00  10  +0
> +        * 01  11  +-
> +        * 01  00  0-
> +        * 10  00  -0
> +        * 10  11  00
> +        * 11  01  -+
> +        * 11  10  00
> +        */

This comment is too cryptic. :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
