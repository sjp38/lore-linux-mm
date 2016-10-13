Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4FAE96B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 14:16:42 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b81so54250984lfe.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 11:16:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id om8si19206050wjc.45.2016.10.13.11.16.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 11:16:40 -0700 (PDT)
Date: Thu, 13 Oct 2016 19:16:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] Don't touch single threaded PTEs which are on the right
 node
Message-ID: <20161013181637.GF20573@suse.de>
References: <1476288949-20970-1-git-send-email-andi@firstfloor.org>
 <20161013083910.GC20573@suse.de>
 <20161013180402.GI3078@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161013180402.GI3078@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, peterz@infradead.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Thu, Oct 13, 2016 at 11:04:02AM -0700, Andi Kleen wrote:
> > >  	do {
> > >  		oldpte = *pte;
> > > @@ -94,6 +100,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> > >  				/* Avoid TLB flush if possible */
> > >  				if (pte_protnone(oldpte))
> > >  					continue;
> > > +
> > > +				/*
> > > +				 * Don't mess with PTEs if page is already on the node
> > > +				 * a single-threaded process is running on.
> > > +				 */
> > > +				if (target_node == page_to_nid(page))
> > > +					continue;
> > >  			}
> > >  
> > 
> > Check target_node != NUMA_NODE && target_node == page_to_nid(page) to
> > avoid unnecessary page->flag masking and shifts?
> 
> I didn't do this last change because I expect a potentially mispredicted
> check is more expensive than some shifting/masking.
> 

Ok, that's fair enough. For something that minor I expect it to be a
case of "you win some you lose some" depending on workload, CPU and
phase of the moon.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
