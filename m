Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79C636B0005
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 19:08:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id v88-v6so3128736pfk.19
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 16:08:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3-v6sor17412130plo.2.2018.10.09.16.08.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 16:08:31 -0700 (PDT)
Date: Tue, 9 Oct 2018 16:08:28 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH] mm: Speed up mremap on large regions
Message-ID: <20181009230828.GB17911@joelaf.mtv.corp.google.com>
References: <20181009201400.168705-1-joel@joelfernandes.org>
 <20181009143859.8b9a700b1caf4e8d1e33a723@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009143859.8b9a700b1caf4e8d1e33a723@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@android.com, minchan@google.com, hughd@google.com, lokeshgidra@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Oct 09, 2018 at 02:38:59PM -0700, Andrew Morton wrote:
> On Tue,  9 Oct 2018 13:14:00 -0700 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> 
> > Android needs to mremap large regions of memory during memory management
> > related operations. The mremap system call can be really slow if THP is
> > not enabled. The bottleneck is move_page_tables, which is copying each
> > pte at a time, and can be really slow across a large map. Turning on THP
> > may not be a viable option, and is not for us. This patch speeds up the
> > performance for non-THP system by copying at the PMD level when possible.
> > 
> > The speed up is three orders of magnitude. On a 1GB mremap, the mremap
> > completion times drops from 160-250 millesconds to 380-400 microseconds.
> > 
> > Before:
> > Total mremap time for 1GB data: 242321014 nanoseconds.
> > Total mremap time for 1GB data: 196842467 nanoseconds.
> > Total mremap time for 1GB data: 167051162 nanoseconds.
> > 
> > After:
> > Total mremap time for 1GB data: 385781 nanoseconds.
> > Total mremap time for 1GB data: 388959 nanoseconds.
> > Total mremap time for 1GB data: 402813 nanoseconds.
> > 
> > Incase THP is enabled, the optimization is skipped. I also flush the
> > tlb every time we do this optimization since I couldn't find a way to
> > determine if the low-level PTEs are dirty. It is seen that the cost of
> > doing so is not much compared the improvement, on both x86-64 and arm64.
> 
> Looks tasty.

Thanks :)

> > --- a/mm/mremap.c
> > +++ b/mm/mremap.c
> > @@ -191,6 +191,54 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
> >  		drop_rmap_locks(vma);
> >  }
> >  
> > +bool move_normal_pmd(struct vm_area_struct *vma, unsigned long old_addr,
> 
> I'll park this for now, shall plan to add a `static' in there then
> merge it up after 4.20-rc1.

Thanks, I will also add static to the function in my own tree just for the
future in case I'm doing another revision.

- Joel
