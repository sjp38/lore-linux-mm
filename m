Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 57AD06B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 05:39:27 -0400 (EDT)
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id n929ojE9031754
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 10:50:45 +0100
Received: from pzk12 (pzk12.prod.google.com [10.243.19.140])
	by spaceape12.eur.corp.google.com with ESMTP id n929oOuD007292
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 02:50:43 -0700
Received: by pzk12 with SMTP id 12so1039665pzk.13
        for <linux-mm@kvack.org>; Fri, 02 Oct 2009 02:50:42 -0700 (PDT)
Date: Fri, 2 Oct 2009 02:50:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04/31] mm: tag reseve pages
In-Reply-To: <19141.34038.274185.392663@notabene.brown>
Message-ID: <alpine.DEB.1.00.0910020243190.22702@chino.kir.corp.google.com>
References: <1254405917-15796-1-git-send-email-sjayaraman@suse.de> <alpine.DEB.1.00.0910011407390.32006@chino.kir.corp.google.com> <19141.34038.274185.392663@notabene.brown>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Fri, 2 Oct 2009, Neil Brown wrote:

> Normally if zones are above their watermarks, page->reserve will not
> be set.
> This is because __alloc_page_nodemask (which seems to be the main
> non-inline entrypoint) first calls get_page_from_freelist with
> alloc_flags set to ALLOC_WMARK_LOW|ALLOC_CPUSET.
> Only if this fails does __alloc_page_nodemask call
> __alloc_pages_slowpath which potentially sets ALLOC_NO_WATERMARKS in
> alloc_flags.
> 
> So page->reserved being set actually tells us:
>   PF_MEMALLOC or GFP_MEMALLOC were used, and
>   a WMARK_LOW allocation attempt failed very recently
> 
> which is close enough to "the emergency reserves were used" I think.
> 

There're a couple cornercases for GFP_ATOMIC, though:

 - it isn't restricted by cpuset, so ALLOC_CPUSET will never get set for 
   the slowpath allocs and may very well allow the allocation to succeed 
   in zones far above their min watermark.

 - it allows for allocating beyond the min watermark in allowed zones
   simply by setting ALLOC_HARDER; these types of "reserve" allocations
   wouldn't be marked as page->reserve with your patches if
   ALLOC_NO_WATERMARKS wasn't set because of the allocation context.

The second one is debatable whether it fits your definition of reserve or 
not, but there's an inconsistency if it doesn't because the allocation may 
succeed in "no watermark" context (for example, in hard irq context) even 
though that privilege wasn't necessary to successfully allocate: perhaps 
it only needed ALLOC_HARDER.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
