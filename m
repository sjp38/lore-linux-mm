Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B42506B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 13:20:35 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o13IKXXA031973
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 10:20:34 -0800
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by wpaz9.hot.corp.google.com with ESMTP id o13IKWQX027918
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 10:20:32 -0800
Received: by pxi6 with SMTP id 6so1611688pxi.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 10:20:32 -0800 (PST)
Date: Wed, 3 Feb 2010 10:20:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH][mmotm-2010-02-01-16-25] Fix wrong accouting of anon and
 file
In-Reply-To: <1265210739.1052.36.camel@barrios-desktop>
Message-ID: <alpine.DEB.2.00.1002031007150.14088@chino.kir.corp.google.com>
References: <1265210739.1052.36.camel@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Feb 2010, Minchan Kim wrote:

> Unfortunately, Kame said he doesn't support this series.
> I am not sure we need this patch or revert patch.
> 

Nobody is currently using it and it adds an overhead just by doing the 
extra branches, so I'd be inclined to drop mm-count-lowmem-rss.patch from 
-mm and then reintroduce it later if something needs it down the line.

> Who need this?
> 
> David. Do you want to remain this patch in mmotm for your OOM patch 
> in future?
> 

We'll need to do something for lowmem ooms so that we aren't needlessly 
killing taks that don't consume it.  At this point, I think it's better to 
just fail GFP_DMA allocations where direct reclaim (and, later, memory 
compaction) has failed unless it is __GFP_NOFAIL, which none of them are.  
So this would be a change to the page allocator to defer the oom killer 
and return NULL on GFP_DMA instead of needlessly killing tasks.

> If anyone doesn't reply my question, Do we have to make revert patch?
> 

We won't need a revert patch, Andrew will be able to simply drop 
mm-count-lowmem-rss.patch from -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
