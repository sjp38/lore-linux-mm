Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 139518D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:18:51 -0500 (EST)
Date: Thu, 3 Feb 2011 22:17:53 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] Huge TLB: Potential NULL deref in
 arch/x86/mm/hugetlbpage.c:huge_pmd_share()
In-Reply-To: <20110203130150.7031c61f.akpm@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1102032214350.1369@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1102032142580.15101@swampdragon.chaosbits.net> <20110203130150.7031c61f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rohit Seth <rohit.seth@intel.com>

On Thu, 3 Feb 2011, Andrew Morton wrote:

> On Thu, 3 Feb 2011 21:50:04 +0100 (CET)
> Jesper Juhl <jj@chaosbits.net> wrote:
> 
> > In arch/x86/mm/hugetlbpage.c:huge_pmd_share() we call find_vma(mm, addr) 
> > and then subsequently dereference the pointer returned without checking if 
> > it was NULL. I can't find anything that guarantees that find_vma() will 
> > never return NULL in this case, so I believe there's a genuine bug. 
> > However, I'd greatly appreciate it if someone would take the time to 
> > double check me.
> > This patch implements what I believe to be the correct handling of a NULL 
> > return from find_vma(). Please consider for inclusion.
> > 
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---
> >  hugetlbpage.c |   11 ++++++++---
> >  1 file changed, 8 insertions(+), 3 deletions(-)
> > 
> > diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> > index 069ce7c..0ebd3d0 100644
> > --- a/arch/x86/mm/hugetlbpage.c
> > +++ b/arch/x86/mm/hugetlbpage.c
> > @@ -61,14 +61,19 @@ static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
> >  static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> >  {
> >  	struct vm_area_struct *vma = find_vma(mm, addr);
> > -	struct address_space *mapping = vma->vm_file->f_mapping;
> > -	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
> > -			vma->vm_pgoff;
> > +	struct address_space *mapping;
> > +	pgoff_t idx;
> >  	struct prio_tree_iter iter;
> >  	struct vm_area_struct *svma;
> >  	unsigned long saddr;
> >  	pte_t *spte = NULL;
> >  
> > +	if (!vma)
> > +		return;
> > +
> > +	mapping = vma->vm_file->f_mapping;
> > +	idx = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> > +
> >  	if (!vma_shareable(vma, addr))
> >  		return;
> 
> mmap_sem is held and the caller (copy_hugetlb_page_range) knows that
> the virtual address at `addr' is within a vma.  So it's a "can't happen".
> 
> The code's all undocumented and you got fooled.  Cause, effect.

Thank you very much for taking the time to check and explain.

How about we then merge the following patch instead, so noone else gets 
fooled in the future?


Document that NULL deref will never happen post find_vma() in 
huge_pmd_share().

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 hugetlbpage.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 069ce7c..7dd2d5f 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -61,6 +61,11 @@ static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
 static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 {
 	struct vm_area_struct *vma = find_vma(mm, addr);
+	/*
+	 * There is no potential NULL deref here. mmap_sem is held and
+	 * caller knows that the virtual address at `addr' is within a
+	 * vma, so find_vma() will never return NULL here.
+	 */
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
 			vma->vm_pgoff;


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
