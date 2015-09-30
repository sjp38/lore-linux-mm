Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id F23666B025F
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 09:17:23 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so197829445wic.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 06:17:23 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id hr17si819080wib.24.2015.09.30.06.17.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 06:17:22 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id B27DC988CC
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 13:17:21 +0000 (UTC)
Date: Wed, 30 Sep 2015 14:17:19 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 05/10] mm, page_alloc: Distinguish between being unable
 to sleep, unwilling to sleep and avoiding waking kswapd
Message-ID: <20150930131719.GO3068@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-6-git-send-email-mgorman@techsingularity.net>
 <20150924205509.GI3009@cmpxchg.org>
 <20150925125106.GG3068@techsingularity.net>
 <20150925190138.GA16359@cmpxchg.org>
 <20150929133547.GI3068@techsingularity.net>
 <560BD4F0.3080402@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <560BD4F0.3080402@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>

On Wed, Sep 30, 2015 at 02:26:24PM +0200, Vlastimil Babka wrote:
> [+CC lustre maintainers]
> 
> On 09/29/2015 03:35 PM, Mel Gorman wrote:
> >>>Ok, I'll add a TODO to create a patch that removes GFP_IOFS entirely. It
> >>>can be tacked on to the end of the series.
> >>
> >>Okay, that makes sense to me. Thanks!
> >>
> >
> >This?
> 
> Thanks for adding this, I think I also pointed this GFP_IOFS oddness in
> earlier versions.
> 
> >---8<---
> >mm: page_alloc: Remove GFP_IOFS
> >
> >GFP_IOFS was intended to be shorthand for clearing two flags, not a
> >set of allocation flags. There is only one user of this flag combination
> >now and there appears to be no reason why Lustre had to be protected
> 
> Looks like a mistake to me. __GFP_IO | __GFP_FS have no effect without
> (former) __GFP_WAIT, so I doubt __GFP_WAIT was omitted on purpose, while
> leaving the other two. The naming of GFP_IOFS suggested it was to be used in
> allocations, leading to the mistake.
> 

GFP_IOFS is shorthand clearing bits and should not have been used as an
allocation flag. Using it as an allocation flag is almost certainly a
mistake.

At a stretch, GFP_IOFS could make sense if we supprted page reclaim that does
not block (e.g. discard clean pages without buffers to release) but we don't.

> But I see you also converted several instances of GFP_NOFS to GFP_KERNEL. Is
> that correct? This is a filesystem driver after all...
> 

Only in the cases where a reclaim path is reentrant and could already be
holding locks that results in deadlock. I didn't spot such a case but then
again, I'm not familiar with the filesystem and it's complex.

Lets see what they say because how they are currently using GFP_IOFS is
almost certainly wrong or at least surprising.

> >diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
> >index effa2af58c13..a7d72f69c4eb 100644
> >--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
> >+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
> >@@ -810,7 +810,7 @@ int cfs_trace_allocate_string_buffer(char **str, int nob)
> >  	if (nob > 2 * PAGE_CACHE_SIZE)	    /* string must be "sensible" */
> >  		return -EINVAL;
> >
> >-	*str = kmalloc(nob, GFP_IOFS | __GFP_ZERO);
> >+	*str = kmalloc(nob, GFP_KERNEL | __GFP_ZERO);
> 
> This could use kzalloc.
> 

True.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
