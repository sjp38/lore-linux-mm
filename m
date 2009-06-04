Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 42B256B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 01:12:03 -0400 (EDT)
Date: Thu, 4 Jun 2009 07:19:15 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [6/16] HWPOISON: Add various poison checks in mm/memory.c
Message-ID: <20090604051915.GN1065@one.firstfloor.org>
References: <20090603846.816684333@firstfloor.org> <20090603184639.1933B1D028F@basil.firstfloor.org> <20090604042603.GA15682@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604042603.GA15682@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 12:26:03PM +0800, Wu Fengguang wrote:
> On Thu, Jun 04, 2009 at 02:46:38AM +0800, Andi Kleen wrote:
> > 
> > Bail out early when hardware poisoned pages are found in page fault handling.
> 
> I suspect this patch is also not absolutely necessary: the poisoned
> page will normally have been isolated already.

It's needed to prevent new pages comming in when there is a parallel 
fault while the memory failure handling is in process.
Otherwise the pages could get remapped in that small window.

> > --- linux.orig/mm/memory.c	2009-06-03 19:36:23.000000000 +0200
> > +++ linux/mm/memory.c	2009-06-03 19:36:23.000000000 +0200
> > @@ -2797,6 +2797,9 @@
> >  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
> >  		return ret;
> >  
> > +	if (unlikely(PageHWPoison(vmf.page)))
> > +		return VM_FAULT_HWPOISON;
> > +
> 
> Direct return with locked page could lockup someone later.
> Either drop this patch or fix it with this check?

Fair point. Fixed. 

Thanks,
-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
