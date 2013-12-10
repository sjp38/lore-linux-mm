Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id BB6536B005A
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 02:51:04 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so2038165eaj.12
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 23:51:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id j47si13152423eeo.137.2013.12.09.23.51.03
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 23:51:03 -0800 (PST)
Date: Tue, 10 Dec 2013 07:50:59 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm, page_alloc: allow __GFP_NOFAIL to allocate below
 watermarks after reclaim
Message-ID: <20131210075059.GA11295@suse.de>
References: <alpine.DEB.2.02.1312091402580.11026@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312091402580.11026@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 09, 2013 at 02:03:45PM -0800, David Rientjes wrote:
> If direct reclaim has failed to free memory, __GFP_NOFAIL allocations
> can potentially loop forever in the page allocator.  In this case, it's
> better to give them the ability to access below watermarks so that they
> may allocate similar to the same privilege given to GFP_ATOMIC
> allocations.
> 
> We're careful to ensure this is only done after direct reclaim has had
> the chance to free memory, however.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

The main problem with doing something like this is that it just smacks
into the adjusted watermark if there are a number of __GFP_NOFAIL. Who
was the user of __GFP_NOFAIL that was fixed by this patch?

It appears there are more __GFP_NOFAIL users than I expected and some of
them are silly. md uses it after mempool_alloc fails GFP_ATOMIC and then
immediately calls with __GFP_NOFAIL in a context that can sleep. It could
just have used GFP_NOIO for the mempool alloc which would "never" fail.

btrfs is using __GFP_NOFAIL to call the slab allocator for the extent
cache but also a kmalloc cache which is just dangerous. After this
patch, that thing can push the system below watermarks and then
effectively "leak" them to other !__GFP_NOFAIL users.

Buffer cache uses __GFP_NOFAIL to grow buffers where it expects the page
allocator can loop endlessly but again, allowing it to go below reserves
is just going to hit the same wall a short time later

gfs is using the flag with kmalloc slabs, same as btrfs this can "leak"
the reserves. jbd is the same although jbd2 avoids using the flag in a
manner of speaking.

There are enough bad users of __GFP_NOFAIL that I really question how
good an idea it is to allow emergency reserves to be used when they are
potentially leaked to other !__GFP_NOFAIL users via the slab allocator
shortly afterwards.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
