Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72AC16B02B4
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 10:48:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q87so3830771pfk.15
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 07:48:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 73si267068ple.514.2017.07.06.07.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 07:48:57 -0700 (PDT)
Date: Thu, 6 Jul 2017 16:48:52 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v5 09/11] mm: Try spin lock in speculative path
Message-ID: <20170706144852.fwtuygj4ikcjmqat@hirez.programming.kicks-ass.net>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-10-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170705185023.xlqko7wgepwsny5g@hirez.programming.kicks-ass.net>
 <3af22f3b-03ab-1d37-b2b1-b616adde7eb6@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3af22f3b-03ab-1d37-b2b1-b616adde7eb6@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On Thu, Jul 06, 2017 at 03:46:59PM +0200, Laurent Dufour wrote:
> On 05/07/2017 20:50, Peter Zijlstra wrote:
> > On Fri, Jun 16, 2017 at 07:52:33PM +0200, Laurent Dufour wrote:
> >> @@ -2294,8 +2295,19 @@ static bool pte_map_lock(struct vm_fault *vmf)
> >>  	if (vma_has_changed(vmf->vma, vmf->sequence))
> >>  		goto out;
> >>  
> >> -	pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
> >> -				  vmf->address, &ptl);

> >> +	ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> >> +	pte = pte_offset_map(vmf->pmd, vmf->address);
> >> +	if (unlikely(!spin_trylock(ptl))) {
> >> +		pte_unmap(pte);
> >> +		goto out;
> >> +	}
> >> +
> >>  	if (vma_has_changed(vmf->vma, vmf->sequence)) {
> >>  		pte_unmap_unlock(pte, ptl);
> >>  		goto out;
> > 
> > Right, so if you look at my earlier patches you'll see I did something
> > quite disgusting here.
> > 
> > Not sure that wants repeating, but I cannot remember why I thought this
> > deadlock didn't exist anymore.
> 
> Regarding the deadlock I did face it on my Power victim node, so I guess it
> is still there, and the stack traces are quiet explicit.
> Am I missing something here ?

No, you are right in that the deadlock is quite real. What I cannot
remember is what made me think to remove the really 'wonderful' code I
had to deal with it.

That said, you might want to look at how often you terminate the
speculation because of your trylock failing. If that shows up at all we
might need to do something about it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
