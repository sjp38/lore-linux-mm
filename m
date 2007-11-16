Received: from l-036148a.enterprise.veritas.com([10.10.97.179]) (3025 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1It5UP-00003VC@megami.veritas.com>
	for <linux-mm@kvack.org>; Fri, 16 Nov 2007 10:00:25 -0800 (PST)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Fri, 16 Nov 2007 18:00:02 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page_referenced() and VM_LOCKED
In-Reply-To: <20071116144641.f12fd610.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0711161749020.12201@blonde.wat.veritas.com>
References: <473D1BC9.8050904@google.com> <20071116144641.f12fd610.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ethan Solomita <solo@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Nov 2007, KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Nov 2007 20:25:45 -0800
> Ethan Solomita <solo@google.com> wrote:
> 
> > page_referenced_file() checks for the vma to be VM_LOCKED|VM_MAYSHARE
> > and adds returns 1.

That's a case where it can deduce that the page is present and should
be treated as referenced, without even examining the page tables.

> > We don't do the same in page_referenced_anon().

It cannot make that same deduction in the page_referenced_anon() case
(different vmas may well contain different COWs of some original page).

Perhaps you're suggesting that page_referenced_one() ought to cover
this case.  Yes.  I think we were coming at it from the 2.6.4 rmap.c
in which VM_LOCKED was checked only in the try_to_unmap() case; but
I was worried about the length of the vma lists and tried to short-
circuit the full search in the one case I could; without thinking
about doing the equivalent elsewhere for the other cases.

> > I would've thought the point was to treat locked pages as active, never
> > pushing them into the inactive list, but since that's not quite what's
> > happening I was hoping someone could give me a clue.

Rik and Lee and others have proposed that we keep VM_LOCKED pages
off both active and inactive lists: that seems a better way forward.

> > 
> > 	Thanks,
> > 	-- Ethan
> Hmm,
> 
> == vmscan.c::shrink_page_list()
> 
>    page_referenced()  if returns 1 ->  link to active list
>    
>    add to swap  # only works if anon
> 
>    try_to_unmap()    if VM_LOCKED -> SWAP_FAIL -> link to active list
> 
> ==
> 
> Then, "VM_LOCKED & not referenced" anon page is added to swap cache
> (before pushed back to active list)
> 
> Seems intended ?

Not intended, no.  Rather a waste of swap.  How about this patch?

--- 2.6.24-rc2/mm/rmap.c	2007-10-24 07:16:04.000000000 +0100
+++ linux/mm/rmap.c	2007-11-16 17:45:32.000000000 +0000
@@ -283,7 +283,10 @@ static int page_referenced_one(struct pa
 	if (!pte)
 		goto out;
 
-	if (ptep_clear_flush_young(vma, address, pte))
+	if (vma->vm_flags & VM_LOCKED) {
+		referenced++;
+		*mapcount = 1;
+	} else if (ptep_clear_flush_young(vma, address, pte))
 		referenced++;
 
 	/* Pretend the page is referenced if the task has the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
