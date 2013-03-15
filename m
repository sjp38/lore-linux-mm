Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 8D6B06B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 09:28:41 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAJd=RBBhbEZghvLcm5zYw2ppNOGjfaAPyrgoGqeOYy3YmDEWGw@mail.gmail.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-24-git-send-email-kirill.shutemov@linux.intel.com>
 <CAJd=RBBhbEZghvLcm5zYw2ppNOGjfaAPyrgoGqeOYy3YmDEWGw@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 23/30] thp: prepare zap_huge_pmd() to uncharge file
 pages
Content-Transfer-Encoding: 7bit
Message-Id: <20130315133020.2722BE0085@blue.fi.intel.com>
Date: Fri, 15 Mar 2013 15:30:20 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hillf Danton wrote:
> On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >
> > Uncharge pages from correct counter.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/huge_memory.c |    4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index a23da8b..34e0385 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1368,10 +1368,12 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >                         spin_unlock(&tlb->mm->page_table_lock);
> >                         put_huge_zero_page();
> >                 } else {
> > +                       int counter;
> s/counter/item/ ?

I saw 'member' in other place, so I'll rename it to 'member'.

> >                         page = pmd_page(orig_pmd);
> >                         page_remove_rmap(page);
> >                         VM_BUG_ON(page_mapcount(page) < 0);
> > -                       add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> > +                       counter = PageAnon(page) ? MM_ANONPAGES : MM_FILEPAGES;
> > +                       add_mm_counter(tlb->mm, counter, -HPAGE_PMD_NR);
> >                         VM_BUG_ON(!PageHead(page));
> >                         tlb->mm->nr_ptes--;
> >                         spin_unlock(&tlb->mm->page_table_lock);
> > --
> > 1.7.10.4
> >

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
