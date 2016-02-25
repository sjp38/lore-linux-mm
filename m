Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id B1F766B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 10:07:48 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id b205so35539027wmb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 07:07:48 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id hk5si10311553wjb.22.2016.02.25.07.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 07:07:47 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id g62so35794172wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 07:07:46 -0800 (PST)
Date: Thu, 25 Feb 2016 18:07:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] thp, mm: remove comments on serializion of THP split vs.
 gup_fast
Message-ID: <20160225150744.GA19707@node.shutemov.name>
References: <1456329561-4319-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160224185025.65711ed6@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160224185025.65711ed6@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, Feb 24, 2016 at 06:50:25PM +0100, Gerald Schaefer wrote:
> On Wed, 24 Feb 2016 18:59:21 +0300
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > Previously, __split_huge_page_splitting() required serialization against
> > gup_fast to make sure nobody can obtain new reference to the page after
> > __split_huge_page_splitting() returns. This was a way to stabilize page
> > references before starting to distribute them from head page to tail
> > pages.
> > 
> > With new refcounting, we don't care about this. Splitting PMD is now
> > decoupled from splitting underlying compound page. It's okay to get new
> > pins after split_huge_pmd(). To stabilize page references during
> > split_huge_page() we rely on setting up migration entries once all
> > pmds are split into page tables.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/gup.c         | 11 +++--------
> >  mm/huge_memory.c |  7 +++----
> >  2 files changed, 6 insertions(+), 12 deletions(-)
> > 
> > diff --git a/mm/gup.c b/mm/gup.c
> > index 7bf19ffa2199..2f528fce3a62 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -1087,8 +1087,7 @@ struct page *get_dump_page(unsigned long addr)
> >   *
> >   * get_user_pages_fast attempts to pin user pages by walking the page
> >   * tables directly and avoids taking locks. Thus the walker needs to be
> > - * protected from page table pages being freed from under it, and should
> > - * block any THP splits.
> > + * protected from page table pages being freed from under it.
> >   *
> >   * One way to achieve this is to have the walker disable interrupts, and
> >   * rely on IPIs from the TLB flushing code blocking before the page table
> > @@ -1097,9 +1096,8 @@ struct page *get_dump_page(unsigned long addr)
> >   *
> >   * Another way to achieve this is to batch up page table containing pages
> >   * belonging to more than one mm_user, then rcu_sched a callback to free those
> > - * pages. Disabling interrupts will allow the fast_gup walker to both block
> > - * the rcu_sched callback, and an IPI that we broadcast for splitting THPs
> > - * (which is a relatively rare event). The code below adopts this strategy.
> > + * pages. Disabling interrupts will allow the fast_gup walker to block
> > + * the rcu_sched callback. The code below adopts this strategy.
> >   *
> >   * Before activating this code, please be aware that the following assumptions
> >   * are currently made:
> > @@ -1391,9 +1389,6 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >  	 * With interrupts disabled, we block page table pages from being
> >  	 * freed from under us. See mmu_gather_tlb in asm-generic/tlb.h
> >  	 * for more details.
> > -	 *
> > -	 * We do not adopt an rcu_read_lock(.) here as we also want to
> > -	 * block IPIs that come from THPs splitting.
> >  	 */
> 
> Hmm, now that the IPI from THP splitting is not needed anymore, this
> comment would suggest that we could use rcu_read_lock(_sched) for
> fast_gup, instead of keeping the (probably more expensive) IRQ enable/
> disable. That should be enough to synchronize against the
> call_rcu_sched() from the batched tlb_table_flush, right?

Possibly. I'm not hugely aware about all details here.

+ People from the patch which introduced the comment.

Can anybody comment on this?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
