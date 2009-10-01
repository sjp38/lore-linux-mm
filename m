Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7DEED6B004D
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 17:09:37 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n91L9xr1000916
	for <linux-mm@kvack.org>; Thu, 1 Oct 2009 22:09:59 +0100
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by spaceape11.eur.corp.google.com with ESMTP id n91L6k5G010730
	for <linux-mm@kvack.org>; Thu, 1 Oct 2009 14:09:56 -0700
Received: by pxi14 with SMTP id 14so653401pxi.3
        for <linux-mm@kvack.org>; Thu, 01 Oct 2009 14:09:55 -0700 (PDT)
Date: Thu, 1 Oct 2009 14:09:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04/31] mm: tag reseve pages
In-Reply-To: <1254405917-15796-1-git-send-email-sjayaraman@suse.de>
Message-ID: <alpine.DEB.1.00.0910011407390.32006@chino.kir.corp.google.com>
References: <1254405917-15796-1-git-send-email-sjayaraman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thu, 1 Oct 2009, Suresh Jayaraman wrote:

> Index: mmotm/mm/page_alloc.c
> ===================================================================
> --- mmotm.orig/mm/page_alloc.c
> +++ mmotm/mm/page_alloc.c
> @@ -1501,8 +1501,10 @@ zonelist_scan:
>  try_this_zone:
>  		page = buffered_rmqueue(preferred_zone, zone, order,
>  						gfp_mask, migratetype);
> -		if (page)
> +		if (page) {
> +			page->reserve = !!(alloc_flags & ALLOC_NO_WATERMARKS);
>  			break;
> +		}
>  this_zone_full:
>  		if (NUMA_BUILD)
>  			zlc_mark_zone_full(zonelist, z);

page->reserve won't necessary indicate that access to reserves was 
_necessary_ for the allocation to succeed, though.  This will mark any 
page being allocated under PF_MEMALLOC as reserve when all zones may be 
well above their min watermarks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
