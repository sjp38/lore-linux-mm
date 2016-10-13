Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5962C6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 14:04:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h24so30606100pfh.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 11:04:04 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id r195si11976679pgr.210.2016.10.13.11.04.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 11:04:03 -0700 (PDT)
Date: Thu, 13 Oct 2016 11:04:02 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] Don't touch single threaded PTEs which are on the right
 node
Message-ID: <20161013180402.GI3078@tassilo.jf.intel.com>
References: <1476288949-20970-1-git-send-email-andi@firstfloor.org>
 <20161013083910.GC20573@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013083910.GC20573@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, peterz@infradead.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

> >  	do {
> >  		oldpte = *pte;
> > @@ -94,6 +100,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> >  				/* Avoid TLB flush if possible */
> >  				if (pte_protnone(oldpte))
> >  					continue;
> > +
> > +				/*
> > +				 * Don't mess with PTEs if page is already on the node
> > +				 * a single-threaded process is running on.
> > +				 */
> > +				if (target_node == page_to_nid(page))
> > +					continue;
> >  			}
> >  
> 
> Check target_node != NUMA_NODE && target_node == page_to_nid(page) to
> avoid unnecessary page->flag masking and shifts?

I didn't do this last change because I expect a potentially mispredicted
check is more expensive than some shifting/masking.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
