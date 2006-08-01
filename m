Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k71FtXra014770
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 1 Aug 2006 11:55:33 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k71FtVp5132912
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 1 Aug 2006 09:55:32 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k71FtUCa029507
	for <linux-mm@kvack.org>; Tue, 1 Aug 2006 09:55:30 -0600
Subject: Re: [patch 1/2] mm: speculative get_page
From: Dave Kleikamp <shaggy@austin.ibm.com>
In-Reply-To: <20060801193203.GA191@oleg>
References: <20060801193203.GA191@oleg>
Content-Type: text/plain
Date: Tue, 01 Aug 2006 10:55:29 -0500
Message-Id: <1154447729.10401.16.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-08-01 at 23:32 +0400, Oleg Nesterov wrote:
> Nick Piggin wrote:
> >
> > --- linux-2.6.orig/mm/vmscan.c
> > +++ linux-2.6/mm/vmscan.c
> > @@ -380,6 +380,8 @@ int remove_mapping(struct address_space 
> >  	if (!mapping)
> >  		return 0;		/* truncate got there first */
> >
> > +	SetPageNoNewRefs(page);
> > +	smp_wmb();
> >  	write_lock_irq(&mapping->tree_lock);
> >
> 
> Is it enough?
> 
> PG_nonewrefs could be already set by another add_to_page_cache()/remove_mapping(),
> and it will be cleared when we take ->tree_lock.

Isn't the page locked when calling remove_mapping()?  It looks like
SetPageNoNewRefs & ClearPageNoNewRefs are called in safe places.  Either
the page is locked, or it's newly allocated.  I could have missed
something, though.

>  For example:
> 
> CPU_0					CPU_1					CPU_3
> 
> add_to_page_cache:
> 
>     SetPageNoNewRefs();
>     write_lock_irq(->tree_lock);

      SetPageLocked(page);

>     ...
>     write_unlock_irq(->tree_lock);
> 
> 					remove_mapping:
> 	
> 					    SetPageNoNewRefs();
> 
>     ClearPageNoNewRefs();
> 					    write_lock_irq(->tree_lock);
> 
> 					    check page_count()
> 
> 										page_cache_get_speculative:
> 
> 										    increment page_count()
> 
> 										    no PG_nonewrefs => return
> 
> Oleg.

Shaggy
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
