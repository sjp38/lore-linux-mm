Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0CB6B0082
	for <linux-mm@kvack.org>; Mon, 25 May 2009 09:16:53 -0400 (EDT)
Date: Mon, 25 May 2009 14:17:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process
	with hugepage shared memory segments attached
Message-ID: <20090525131703.GE12160@csn.ul.ie>
References: <20090521094057.63B8.A69D9226@jp.fujitsu.com> <20090522164101.GA9196@csn.ul.ie> <20090524213838.084C.A69D9226@jp.fujitsu.com> <20090525085137.GA12160@csn.ul.ie> <Pine.LNX.4.64.0905251058480.16521@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905251058480.16521@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, starlight@binnacle.cx, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>, riel@redhat.com, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Mon, May 25, 2009 at 11:10:11AM +0100, Hugh Dickins wrote:
> On Mon, 25 May 2009, Mel Gorman wrote:
> > On Sun, May 24, 2009 at 10:44:29PM +0900, KOSAKI Motohiro wrote:
> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > > --- 
> > > >  arch/x86/mm/hugetlbpage.c |    6 +++++-
> > > >  1 file changed, 5 insertions(+), 1 deletion(-)
> > > > 
> > > > diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> > > > index 8f307d9..16e4bcc 100644
> > > > --- a/arch/x86/mm/hugetlbpage.c
> > > > +++ b/arch/x86/mm/hugetlbpage.c
> > > > @@ -26,12 +26,16 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
> > > >  	unsigned long sbase = saddr & PUD_MASK;
> > > >  	unsigned long s_end = sbase + PUD_SIZE;
> > > >  
> > > > +	/* Allow segments to share if only one is locked */
> > > > +	unsigned long vm_flags = vma->vm_flags & ~VM_LOCKED;
> > > > +	unsigned long svm_flags = vma->vm_flags & ~VM_LOCKED;
> > >                                   svma?
> > > 
> > 
> > /me slaps self
> > 
> > svma indeed.
> > 
> > With the patch corrected, I still cannot trigger the bad pmd messages as
> > applied so I'm convinced the bug is related to hugetlb pagetable
> > sharing and this is more or less the fix. Any opinions?
> 
> Yes, you gave a very good analysis, and I agree with you, your patch
> does seem to be needed for 2.6.27.N, and the right thing to do there
> (though I prefer the way 2.6.28 mlocking skips huge areas completely).
> 

I similarly prefer how 2.6.28 simply makes the pages present and then gets
rid of the flag. I was tempted to back-porting something similar but it felt
better to fix where hugetlb was going wrong. Even though it's essentially a
no-op on mainline, I'd like to apply the patch there as well in case there
is ever another change in mlock() with respect to hugetlbfs.

> One nit, doesn't really matter, but if I'm not too late: please change
> -	/* Allow segments to share if only one is locked */
> +	/* Allow segments to share if only one is marked locked */
> since locking is such a no-op on hugetlb areas.
> 

It's not too late and that change makes sense.

> Hugetlb pagetable sharing does scare me some nights: it's a very easily
> forgotten corner of mm, worrying that we do something so different in
> there; but IIRC this is actually the first bug related to it, much to
> Ken's credit (and Dave McCracken's).
> 

I had totally forgotten about it which is why it took me so long to identify
it as the problem area. I don't remember there ever being a problem with
this area either.

> (I'm glad Kosaki-san noticed the svma before I acked your previous
> version!  And I've still got to go back to your VM_MAYSHARE patch:
> seems right, but still wondering about the remaining VM_SHAREDs -
> will report back later.)
> 

Thanks.

> Feel free to add an
> Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> to your fixed version.
> 

Thanks again Hugh.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
