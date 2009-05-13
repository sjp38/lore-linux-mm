Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 288176B0135
	for <linux-mm@kvack.org>; Wed, 13 May 2009 18:35:08 -0400 (EDT)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id n4DMZcN2030814
	for <linux-mm@kvack.org>; Wed, 13 May 2009 15:35:39 -0700
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by spaceape13.eur.corp.google.com with ESMTP id n4DMZZ7B032307
	for <linux-mm@kvack.org>; Wed, 13 May 2009 15:35:36 -0700
Received: by pxi17 with SMTP id 17so416165pxi.21
        for <linux-mm@kvack.org>; Wed, 13 May 2009 15:35:35 -0700 (PDT)
Date: Wed, 13 May 2009 15:35:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/6] mm, PM/Freezer: Disable OOM killer when tasks are
 frozen
In-Reply-To: <200905131037.50011.rjw@sisk.pl>
Message-ID: <alpine.DEB.2.00.0905131534530.25680@chino.kir.corp.google.com>
References: <200905070040.08561.rjw@sisk.pl> <200905101548.57557.rjw@sisk.pl> <200905131032.53624.rjw@sisk.pl> <200905131037.50011.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009, Rafael J. Wysocki wrote:

> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -175,6 +175,8 @@ static void set_pageblock_migratetype(st
>  					PB_migrate, PB_migrate_end);
>  }
>  
> +bool oom_killer_disabled __read_mostly;
> +
>  #ifdef CONFIG_DEBUG_VM
>  static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
>  {
> @@ -1600,6 +1602,9 @@ nofail_alloc:
>  		if (page)
>  			goto got_pg;
>  	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> +		if (oom_killer_disabled)
> +			goto nopage;
> +
>  		if (!try_set_zone_oom(zonelist, gfp_mask)) {
>  			schedule_timeout_uninterruptible(1);
>  			goto restart;

This allows __GFP_NOFAIL allocations to fail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
