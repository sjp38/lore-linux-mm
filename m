Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7146B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 15:44:02 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so17211249pbc.16
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 12:44:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id l8si19423721paa.315.2014.02.18.12.44.01
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 12:44:02 -0800 (PST)
Date: Tue, 18 Feb 2014 12:44:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fs/proc/task_mmu.c: assume non-NULL vma in
 pagemap_hugetlb() (Re: [mmotm:master 97/220] fs/proc/task_mmu.c:1042
 pagemap_hugetlb() error: we previously assumed 'vma' could be null (see
 line 1037))
Message-Id: <20140218124400.c173bdbf42c5a32848da2f76@linux-foundation.org>
In-Reply-To: <52fe31de.89cfe00a.338f.ffff9a19SMTPIN_ADDED_BROKEN@mx.google.com>
References: <52fdd350.dwn4aII31EyWlDq9%fengguang.wu@intel.com>
	<20140214130450.GA14755@localhost>
	<52fe31de.89cfe00a.338f.ffff9a19SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 14 Feb 2014 10:09:58 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Fengguang reported smatch error about potential NULL pointer access.
> 
> In updated page table walker, we never run ->hugetlb_entry() callback
> on the address without vma. This is because __walk_page_range() checks
> it in advance. So we can assume non-NULL vma in pagemap_hugetlb().
> 
> ...
>
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1032,9 +1032,9 @@ static int pagemap_hugetlb(pte_t *pte, unsigned long addr, unsigned long end,
>  	pagemap_entry_t pme;
>  	unsigned long hmask;
>  
> -	WARN_ON_ONCE(!vma);
> +	BUG_ON(!vma);

Let's just remove it altogether.

> -	if (vma && (vma->vm_flags & VM_SOFTDIRTY))
> +	if (vma->vm_flags & VM_SOFTDIRTY)

The null deref oops will provide us the same info as the BUG_ON.  It
will require a *little* more thinking to work out that `vma' was NULL,
but it will be pretty obvious.


This requires knowing offsetof(vm_area_struct, vm_flags).  I use a gdb macro:

define offsetof
	set $off = &(((struct $arg0 *)0)->$arg1)
	printf "%d 0x%x\n", $off, $off
end

akpm3:/usr/src/25> gdb fs/proc/task_mmu.o
...
(gdb) offsetof vm_area_struct vm_flags
80 0x50

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
