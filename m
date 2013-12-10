Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id 62BFF6B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 18:03:43 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id b6so4532006yha.37
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 15:03:43 -0800 (PST)
Received: from mail-yh0-x22c.google.com (mail-yh0-x22c.google.com [2607:f8b0:4002:c01::22c])
        by mx.google.com with ESMTPS id l5si15366481yhl.49.2013.12.10.15.03.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 15:03:42 -0800 (PST)
Received: by mail-yh0-f44.google.com with SMTP id f64so4455512yha.3
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 15:03:42 -0800 (PST)
Date: Tue, 10 Dec 2013 15:03:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, page_alloc: allow __GFP_NOFAIL to allocate below
 watermarks after reclaim
In-Reply-To: <20131210075059.GA11295@suse.de>
Message-ID: <alpine.DEB.2.02.1312101453020.22701@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1312091402580.11026@chino.kir.corp.google.com> <20131210075059.GA11295@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 10 Dec 2013, Mel Gorman wrote:

> > If direct reclaim has failed to free memory, __GFP_NOFAIL allocations
> > can potentially loop forever in the page allocator.  In this case, it's
> > better to give them the ability to access below watermarks so that they
> > may allocate similar to the same privilege given to GFP_ATOMIC
> > allocations.
> > 
> > We're careful to ensure this is only done after direct reclaim has had
> > the chance to free memory, however.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> The main problem with doing something like this is that it just smacks
> into the adjusted watermark if there are a number of __GFP_NOFAIL. Who
> was the user of __GFP_NOFAIL that was fixed by this patch?
> 

Nobody, it comes out of a memcg discussion where __GFP_NOFAIL were 
recently given the ability to bypass charges to the root memcg when the 
memcg has hit its limit since we disallow the oom killer to kill a process 
(for the same reason that the vast majority of __GFP_NOFAIL users, those 
that do GFP_NOFS | __GFP_NOFAIL, disallow the oom killer in the page 
allocator).

Without some other thread freeing memory, these allocations simply loop 
forever.  We probably don't want to reconsider the choice that prevents 
calling the oom killer in !__GFP_FS contexts since it will allow 
unnecessary oom killing when memory can actually be freed by another 
thread.

Since there are comments in both gfp.h and page_alloc.c that say no new 
users will be added, it seems legitimate to ensure that the allocation 
will at least have a chance of succeeding, but not the point of depleting 
memory reserves entirely.

> There are enough bad users of __GFP_NOFAIL that I really question how
> good an idea it is to allow emergency reserves to be used when they are
> potentially leaked to other !__GFP_NOFAIL users via the slab allocator
> shortly afterwards.
> 

You could make the same argument for GFP_ATOMIC which can also allow 
access to memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
