Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 157D36B03A1
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 06:42:14 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id b136so25500982ioe.9
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 03:42:14 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c16si1319066itf.27.2017.08.08.03.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 03:42:13 -0700 (PDT)
Date: Tue, 8 Aug 2017 12:42:01 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v5 02/11] mm: Prepare for FAULT_FLAG_SPECULATIVE
Message-ID: <20170808104201.sh7iyanrjs2wjz3y@hirez.programming.kicks-ass.net>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <7e770060-32b2-c136-5d34-2f078800df21@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7e770060-32b2-c136-5d34-2f078800df21@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On Tue, Aug 08, 2017 at 03:54:01PM +0530, Anshuman Khandual wrote:
> On 06/16/2017 11:22 PM, Laurent Dufour wrote:
> > From: Peter Zijlstra <peterz@infradead.org>
> > 
> > When speculating faults (without holding mmap_sem) we need to validate
> > that the vma against which we loaded pages is still valid when we're
> > ready to install the new PTE.
> > 
> > Therefore, replace the pte_offset_map_lock() calls that (re)take the
> > PTL with pte_map_lock() which can fail in case we find the VMA changed
> > since we started the fault.
> 
> Where we are checking if VMA has changed or not since the fault ?

Not there yet, this is what you call a preparatory patch. They help
review in that you can consider smaller steps.

> > diff --git a/mm/memory.c b/mm/memory.c
> > index fd952f05e016..40834444ea0d 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2240,6 +2240,12 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
> >  	pte_unmap_unlock(vmf->pte, vmf->ptl);
> >  }
> >  
> > +static bool pte_map_lock(struct vm_fault *vmf)
> > +{
> > +	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address, &vmf->ptl);
> > +	return true;
> > +}
> 
> This is always true ? Then we should not have all these if (!pte_map_lock(vmf))
> check blocks down below.

Later patches will make it possible to return false. This patch is about
the placing this call. Having this in a separate patch makes it easier
to review all those new error conditions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
