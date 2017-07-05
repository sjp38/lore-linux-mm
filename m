Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 187166B03A9
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 14:50:37 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id n6so53773283itc.6
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 11:50:37 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h71si21651982ioh.192.2017.07.05.11.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 11:50:36 -0700 (PDT)
Date: Wed, 5 Jul 2017 20:50:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v5 09/11] mm: Try spin lock in speculative path
Message-ID: <20170705185023.xlqko7wgepwsny5g@hirez.programming.kicks-ass.net>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-10-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497635555-25679-10-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On Fri, Jun 16, 2017 at 07:52:33PM +0200, Laurent Dufour wrote:
> @@ -2294,8 +2295,19 @@ static bool pte_map_lock(struct vm_fault *vmf)
>  	if (vma_has_changed(vmf->vma, vmf->sequence))
>  		goto out;
>  
> -	pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
> -				  vmf->address, &ptl);
> +	/* Same as pte_offset_map_lock() except that we call

comment style..

> +	 * spin_trylock() in place of spin_lock() to avoid race with
> +	 * unmap path which may have the lock and wait for this CPU
> +	 * to invalidate TLB but this CPU has irq disabled.
> +	 * Since we are in a speculative patch, accept it could fail
> +	 */
> +	ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> +	pte = pte_offset_map(vmf->pmd, vmf->address);
> +	if (unlikely(!spin_trylock(ptl))) {
> +		pte_unmap(pte);
> +		goto out;
> +	}
> +
>  	if (vma_has_changed(vmf->vma, vmf->sequence)) {
>  		pte_unmap_unlock(pte, ptl);
>  		goto out;

Right, so if you look at my earlier patches you'll see I did something
quite disgusting here.

Not sure that wants repeating, but I cannot remember why I thought this
deadlock didn't exist anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
