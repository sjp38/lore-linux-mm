Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4704F6B006E
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 07:51:11 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id em10so9961196wid.1
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 04:51:10 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.234])
        by mx.google.com with ESMTP id eo6si1824830wid.75.2014.10.14.04.51.09
        for <linux-mm@kvack.org>;
        Tue, 14 Oct 2014 04:51:09 -0700 (PDT)
Date: Tue, 14 Oct 2014 14:48:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] mm, thp: khugepaged can't allocate on requested node when
 confined to a cpuset
Message-ID: <20141014114828.GA6524@node.dhcp.inet.fi>
References: <20141008191050.GK3778@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141008191050.GK3778@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Wed, Oct 08, 2014 at 02:10:50PM -0500, Alex Thorlton wrote:
> Hey everyone,
> 
> I've run into a some frustrating behavior from the khugepaged thread,
> that I'm hoping to get sorted out.  It appears that if you pin
> khugepaged to a cpuset (i.e. node 0),

Why whould you want to pin khugpeaged? Is there a valid use-case?
Looks like userspace shoots to its leg.

> and it begins scanning/collapsing pages for a process on a cpuset that
> doesn't have any memory nodes in common with kugepaged (i.e. node 1),
> then the collapsed pages will all be allocated khugepaged's node (in
> this case node 0), clearly breaking the cpuset boundary set up for the
> process in question.
> 
> I'm aware that there are some known issues with khugepaged performing
> off-node allocations in certain situations, but I believe this is a bit
> of a special circumstance since, in this situation, there's no way for
> khugepaged to perform an allocation on the desired node.
> 
> The problem really stems from the way that we determine the allowed
> memory nodes in get_page_from_freelist.  When we call down to
> cpuset_zone_allowed_softwall, we check current->mems_allowed to
> determine what nodes we're allowed on.  In the case of khugepaged, we'll
> be making allocations for the mm of the process we're collapsing for,
> but we'll be checking the mems_allowed of khugepaged, which can
> obviously cause some problems.

Is there a reason why we should respect cpuset limitation for kernel
threads?

Should we bypass cpuset for PF_KTHREAD completely?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 736d8e1b6381..03a74878ad46 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1960,6 +1960,9 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 zonelist_scan:
        zonelist_rescan = false;
 
+       /* Bypass cpuset limitation if allocate from kernel thread context */
+       if (current->flags & PF_KTHREAD)
+               alloc_flags &= ~ALLOC_CPUSET;
        /*
         * Scan zonelist, looking for a zone with enough free.
         * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
