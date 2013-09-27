Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E23B46B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 18:25:02 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so3175738pdj.12
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 15:25:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <5245EEAD.7010901@linux.vnet.ibm.com>
References: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1380287787-30252-3-git-send-email-kirill.shutemov@linux.intel.com>
 <5245EEAD.7010901@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 02/10] mm: convert mm->nr_ptes to atomic_t
Content-Transfer-Encoding: 7bit
Message-Id: <20130927222451.3406EE0090@blue.fi.intel.com>
Date: Sat, 28 Sep 2013 01:24:51 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Cody P Schafer wrote:
> On 09/27/2013 06:16 AM, Kirill A. Shutemov wrote:
> > With split page table lock for PMD level we can't hold
> > mm->page_table_lock while updating nr_ptes.
> >
> > Let's convert it to atomic_t to avoid races.
> >
> 
> > ---
> 
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 84e0c56e1e..99f19e850d 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -339,6 +339,7 @@ struct mm_struct {
> >   	pgd_t * pgd;
> >   	atomic_t mm_users;			/* How many users with user space? */
> >   	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
> > +	atomic_t nr_ptes;			/* Page table pages */
> >   	int map_count;				/* number of VMAs */
> >
> >   	spinlock_t page_table_lock;		/* Protects page tables and some counters */
> > @@ -360,7 +361,6 @@ struct mm_struct {
> >   	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
> >   	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
> >   	unsigned long def_flags;
> > -	unsigned long nr_ptes;		/* Page table pages */
> >   	unsigned long start_code, end_code, start_data, end_data;
> >   	unsigned long start_brk, brk, start_stack;
> >   	unsigned long arg_start, arg_end, env_start, env_end;
> 
> Will 32bits always be enough here? Should atomic_long_t be used instead?

Good question!

On x86_64 we need one table to cover 2M (512 entries by 4k, 21 bits) of
virtual address space. Total size of virtual memory which can be covered
by 31-bit (32 - sign) nr_ptes is 52 bits (31 + 21).

Currently, on x86_64 with 4-level page tables we can use at most 48 bit of
virtual address space (only half of it available for userspace), so we
pretty safe here.

Although, it can be a potential problem, if (when) x86_64 will implement
5-level page tables -- 57-bits of virtual address space.

Any thoughts?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
