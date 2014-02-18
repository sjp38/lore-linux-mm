Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 805F06B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 16:01:43 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id t10so7976878eei.7
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 13:01:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 43si42681405eeh.136.2014.02.18.13.01.40
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 13:01:41 -0800 (PST)
Date: Tue, 18 Feb 2014 16:01:15 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5303ca35.c3030e0a.3e0a.2a2aSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140218124400.c173bdbf42c5a32848da2f76@linux-foundation.org>
References: <52fdd350.dwn4aII31EyWlDq9%fengguang.wu@intel.com>
 <20140214130450.GA14755@localhost>
 <52fe31de.89cfe00a.338f.ffff9a19SMTPIN_ADDED_BROKEN@mx.google.com>
 <20140218124400.c173bdbf42c5a32848da2f76@linux-foundation.org>
Subject: Re: [PATCH] fs/proc/task_mmu.c: assume non-NULL vma in
 pagemap_hugetlb() (Re: [mmotm:master 97/220] fs/proc/task_mmu.c:1042
 pagemap_hugetlb() error: we previously assumed 'vma' could be null (see line
 1037))
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: fengguang.wu@intel.com, kbuild-all@01.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Tue, Feb 18, 2014 at 12:44:00PM -0800, Andrew Morton wrote:
> On Fri, 14 Feb 2014 10:09:58 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > Fengguang reported smatch error about potential NULL pointer access.
> > 
> > In updated page table walker, we never run ->hugetlb_entry() callback
> > on the address without vma. This is because __walk_page_range() checks
> > it in advance. So we can assume non-NULL vma in pagemap_hugetlb().
> > 
> > ...
> >
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -1032,9 +1032,9 @@ static int pagemap_hugetlb(pte_t *pte, unsigned long addr, unsigned long end,
> >  	pagemap_entry_t pme;
> >  	unsigned long hmask;
> >  
> > -	WARN_ON_ONCE(!vma);
> > +	BUG_ON(!vma);
> 
> Let's just remove it altogether.
> 
> > -	if (vma && (vma->vm_flags & VM_SOFTDIRTY))
> > +	if (vma->vm_flags & VM_SOFTDIRTY)
> 
> The null deref oops will provide us the same info as the BUG_ON.  It
> will require a *little* more thinking to work out that `vma' was NULL,
> but it will be pretty obvious.

Yes, I agree. pagemap_hugetlb() is callback and never inlined, so we will
have an info like 'NULL pointer access on pagemap_hugetlb()' with call trace,
which is enough to pinpoint the problem.

> 
> This requires knowing offsetof(vm_area_struct, vm_flags).  I use a gdb macro:
> 
> define offsetof
> 	set $off = &(((struct $arg0 *)0)->$arg1)
> 	printf "%d 0x%x\n", $off, $off
> end
> 
> akpm3:/usr/src/25> gdb fs/proc/task_mmu.o
> ...
> (gdb) offsetof vm_area_struct vm_flags
> 80 0x50

Nice note, thank you.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
