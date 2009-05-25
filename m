Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6484B6B004D
	for <linux-mm@kvack.org>; Mon, 25 May 2009 06:10:04 -0400 (EDT)
Date: Mon, 25 May 2009 11:10:11 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process with
 hugepage shared memory segments attached
In-Reply-To: <20090525085137.GA12160@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0905251058480.16521@sister.anvils>
References: <20090521094057.63B8.A69D9226@jp.fujitsu.com> <20090522164101.GA9196@csn.ul.ie>
 <20090524213838.084C.A69D9226@jp.fujitsu.com> <20090525085137.GA12160@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, starlight@binnacle.cx, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>, riel@redhat.com, hugh.dickins@tiscali.co.uk, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 25 May 2009, Mel Gorman wrote:
> On Sun, May 24, 2009 at 10:44:29PM +0900, KOSAKI Motohiro wrote:
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > --- 
> > >  arch/x86/mm/hugetlbpage.c |    6 +++++-
> > >  1 file changed, 5 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> > > index 8f307d9..16e4bcc 100644
> > > --- a/arch/x86/mm/hugetlbpage.c
> > > +++ b/arch/x86/mm/hugetlbpage.c
> > > @@ -26,12 +26,16 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
> > >  	unsigned long sbase = saddr & PUD_MASK;
> > >  	unsigned long s_end = sbase + PUD_SIZE;
> > >  
> > > +	/* Allow segments to share if only one is locked */
> > > +	unsigned long vm_flags = vma->vm_flags & ~VM_LOCKED;
> > > +	unsigned long svm_flags = vma->vm_flags & ~VM_LOCKED;
> >                                   svma?
> > 
> 
> /me slaps self
> 
> svma indeed.
> 
> With the patch corrected, I still cannot trigger the bad pmd messages as
> applied so I'm convinced the bug is related to hugetlb pagetable
> sharing and this is more or less the fix. Any opinions?

Yes, you gave a very good analysis, and I agree with you, your patch
does seem to be needed for 2.6.27.N, and the right thing to do there
(though I prefer the way 2.6.28 mlocking skips huge areas completely).

One nit, doesn't really matter, but if I'm not too late: please change
-	/* Allow segments to share if only one is locked */
+	/* Allow segments to share if only one is marked locked */
since locking is such a no-op on hugetlb areas.

Hugetlb pagetable sharing does scare me some nights: it's a very easily
forgotten corner of mm, worrying that we do something so different in
there; but IIRC this is actually the first bug related to it, much to
Ken's credit (and Dave McCracken's).

(I'm glad Kosaki-san noticed the svma before I acked your previous
version!  And I've still got to go back to your VM_MAYSHARE patch:
seems right, but still wondering about the remaining VM_SHAREDs -
will report back later.)

Feel free to add an
Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
to your fixed version.

Hugh

> 
> >  - kosaki
> > 
> > > +
> > >  	/*
> > >  	 * match the virtual addresses, permission and the alignment of the
> > >  	 * page table page.
> > >  	 */
> > >  	if (pmd_index(addr) != pmd_index(saddr) ||
> > > -	    vma->vm_flags != svma->vm_flags ||
> > > +	    vm_flags != svm_flags ||
> > >  	    sbase < svma->vm_start || svma->vm_end < s_end)
> > >  		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
