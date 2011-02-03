Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1BE3E8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:44:49 -0500 (EST)
Date: Thu, 3 Feb 2011 22:43:49 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] Huge TLB: Potential NULL deref in
 arch/x86/mm/hugetlbpage.c:huge_pmd_share()
In-Reply-To: <20110203133624.cd353dd6.akpm@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1102032241520.1369@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1102032142580.15101@swampdragon.chaosbits.net> <20110203130150.7031c61f.akpm@linux-foundation.org> <alpine.LNX.2.00.1102032214350.1369@swampdragon.chaosbits.net> <20110203133624.cd353dd6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rohit Seth <rohit.seth@intel.com>

On Thu, 3 Feb 2011, Andrew Morton wrote:

> On Thu, 3 Feb 2011 22:17:53 +0100 (CET)
> Jesper Juhl <jj@chaosbits.net> wrote:
> 
> > Document that NULL deref will never happen post find_vma() in 
> > huge_pmd_share().
> > 
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---
> >  hugetlbpage.c |    5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> > index 069ce7c..7dd2d5f 100644
> > --- a/arch/x86/mm/hugetlbpage.c
> > +++ b/arch/x86/mm/hugetlbpage.c
> > @@ -61,6 +61,11 @@ static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
> >  static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> >  {
> >  	struct vm_area_struct *vma = find_vma(mm, addr);
> > +	/*
> > +	 * There is no potential NULL deref here. mmap_sem is held and
> > +	 * caller knows that the virtual address at `addr' is within a
> > +	 * vma, so find_vma() will never return NULL here.
> > +	 */
> >  	struct address_space *mapping = vma->vm_file->f_mapping;
> >  	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
> >  			vma->vm_pgoff;
> 
> Not really.
> 
> That mmap_sem is held and that `addr' refers to a known-to-be-present
> VMA are part of huge_pmd_share()'s interface.  They are preconditions
> which must be satisfied before the function can be used.
> 
> So they should be documented as such, in the function's documentation. 
> In fact they're the *most important* thing to document about the
> function because they are subtle and unobvious from the implementation
> and from the function signature and name.
> 
> >From an understandability/maintainability POV the code is crap.  It's yet
> another example of kernel developers' liking for pointing machine guns
> at each other's feet.
> 
> Really, some poor schmuck needs to go in and reverse-engineer all the
> secret interface requirements and document them.  But we shouldn't let
> a chance go by - a nice kerneldoc description for huge_pmd_share()
> would be appreciated.  One which documents both the explicit and the
> implicit calling conventions.
> 

Ok. I'm not sure that I'm the right person to actually do this since my 
knowledge of this code is quite limited, but I'll give it a shot tomorrow 
evening (off to get some sleep soon, so now is not the time).
I'll get back to you on this tomorrow or during the weekend (and if 
someone else beats me to it - just fine ;).

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
