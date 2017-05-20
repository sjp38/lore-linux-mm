Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E779D280753
	for <linux-mm@kvack.org>; Sat, 20 May 2017 03:27:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g12so7849942wrg.15
        for <linux-mm@kvack.org>; Sat, 20 May 2017 00:27:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k2si1694667edc.224.2017.05.20.00.27.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 20 May 2017 00:27:40 -0700 (PDT)
Date: Sat, 20 May 2017 09:27:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: clarify why we want kmalloc before falling backto
 vmallock
Message-ID: <20170520072737.GB11925@dhcp22.suse.cz>
References: <20170517080932.21423-1-mhocko@kernel.org>
 <d6121d8b-8d0f-88da-cd67-e9123bb96454@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d6121d8b-8d0f-88da-cd67-e9123bb96454@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 19-05-17 17:46:58, John Hubbard wrote:
> On 05/17/2017 01:09 AM, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> >While converting drm_[cm]alloc* helpers to kvmalloc* variants Chris
> >Wilson has wondered why we want to try kmalloc before vmalloc fallback
> >even for larger allocations requests. Let's clarify that one larger
> >physically contiguous block is less likely to fragment memory than many
> >scattered pages which can prevent more large blocks from being created.
> >
> >Suggested-by: Chris Wilson <chris@chris-wilson.co.uk>
> >Signed-off-by: Michal Hocko <mhocko@suse.com>
> >---
> >  mm/util.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> >
> >diff --git a/mm/util.c b/mm/util.c
> >index 464df3489903..87499f8119f2 100644
> >--- a/mm/util.c
> >+++ b/mm/util.c
> >@@ -357,7 +357,10 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
> >  	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
> >  	/*
> >-	 * Make sure that larger requests are not too disruptive - no OOM
> >+	 * We want to attempt a large physically contiguous block first because
> >+	 * it is less likely to fragment multiple larger blocks and therefore
> >+	 * contribute to a long term fragmentation less than vmalloc fallback.
> >+	 * However make sure that larger requests are not too disruptive - no OOM
> >  	 * killer and no allocation failure warnings as we have a fallback
> >  	 */
> 
> Thanks for adding this, it's great to have. Here's a slightly polished
> version of your words, if you like:
> 
> 	/*
> 	 * We want to attempt a large physically contiguous block first because
> 	 * it is less likely to fragment multiple larger blocks. This approach
> 	 * therefore contributes less to long term fragmentation than a vmalloc
> 	 * fallback would. However, make sure that larger requests are not too
> 	 * disruptive: no OOM killer and no allocation failure warnings, as we
> 	 * have a fallback.
> 	 */

Looks ok to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
