Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB8DC6B0038
	for <linux-mm@kvack.org>; Sun, 11 Sep 2016 12:24:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x24so305931628pfa.0
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 09:24:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o15si5259627wmd.3.2016.09.11.09.24.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Sep 2016 09:24:06 -0700 (PDT)
Date: Sun, 11 Sep 2016 17:24:02 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] sched,numa,mm: revert to checking pmd/pte_write instead
 of VMA flags
Message-ID: <20160911162402.GA2775@suse.de>
References: <20160908213053.07c992a9@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160908213053.07c992a9@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, aarcange@redhat.com

On Thu, Sep 08, 2016 at 09:30:53PM -0400, Rik van Riel wrote:
> Commit 4d9424669946 ("mm: convert p[te|md]_mknonnuma and remaining
> page table manipulations") changed NUMA balancing from _PAGE_NUMA
> to using PROT_NONE, and was quickly found to introduce a regression
> with NUMA grouping.
> 
> It was followed up by these changesets:
> 
> 53da3bc2ba9e ("mm: fix up numa read-only thread grouping logic")
> bea66fbd11af ("mm: numa: group related processes based on VMA flags instead of page table flags")
> b191f9b106ea ("mm: numa: preserve PTE write permissions across a NUMA hinting fault")
> 
> The first of those two changesets try alternate approaches to NUMA
> grouping, which apparently do not work as well as looking at the PTE
> write permissions.
> 
> The latter patch preserves the PTE write permissions across a NUMA
> protection fault. However, it forgets to revert the condition for
> whether or not to group tasks together back to what it was before
> 3.19, even though the information is now preserved in the page tables
> once again.
> 
> This patch brings the NUMA grouping heuristic back to what it was
> before changeset 4d9424669946, which the changelogs of subsequent
> changesets suggest worked best.
> 
> We have all the information again. We should probably use it.
> 

Patch looks ok other than the comment above the second hunk being out of
date. Out of curiousity, what workload benefitted from this? I saw a mix
of marginal results when I ran this on a 2-socket and 4-socket box.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
