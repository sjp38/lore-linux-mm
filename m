Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7996B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 16:18:55 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so189687573pab.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:18:55 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id hx5si52880805pbc.82.2015.11.16.13.18.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 13:18:54 -0800 (PST)
Received: by padhx2 with SMTP id hx2so186794978pad.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:18:54 -0800 (PST)
Date: Mon, 16 Nov 2015 13:18:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: do not loop over ALLOC_NO_WATERMARKS without
 triggering reclaim
In-Reply-To: <1447680139-16484-3-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1511161318180.11456@chino.kir.corp.google.com>
References: <1447680139-16484-1-git-send-email-mhocko@kernel.org> <1447680139-16484-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 16 Nov 2015, mhocko@kernel.org wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> __alloc_pages_slowpath is looping over ALLOC_NO_WATERMARKS requests if
> __GFP_NOFAIL is requested. This is fragile because we are basically
> relying on somebody else to make the reclaim (be it the direct reclaim
> or OOM killer) for us. The caller might be holding resources (e.g.
> locks) which block other other reclaimers from making any progress for
> example. Remove the retry loop and rely on __alloc_pages_slowpath to
> invoke all allowed reclaim steps and retry logic.
> 
> We have to be careful about __GFP_NOFAIL allocations from the
> PF_MEMALLOC context even though this is a very bad idea to begin with
> because no progress can be gurateed at all.  We shouldn't break the
> __GFP_NOFAIL semantic here though. It could be argued that this is
> essentially GFP_NOWAIT context which we do not support but PF_MEMALLOC
> is much harder to check for existing users because they might happen
> deep down the code path performed much later after setting the flag
> so we cannot really rule out there is no kernel path triggering this
> combination.
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

It'll be scary if anything actually relies on this, but I think it's more 
correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
