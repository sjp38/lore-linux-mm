Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1A35A6B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 20:34:34 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so44973096ieb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 17:34:34 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id g68si4676072iog.64.2015.06.17.17.34.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 17:34:33 -0700 (PDT)
Received: by igbqq3 with SMTP id qq3so3220241igb.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 17:34:33 -0700 (PDT)
Date: Wed, 17 Jun 2015 17:34:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/4] mm, thp: stop preallocating hugepages in khugepaged
In-Reply-To: <1431354940-30740-2-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1506171732530.8203@chino.kir.corp.google.com>
References: <1431354940-30740-1-git-send-email-vbabka@suse.cz> <1431354940-30740-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Alex Thorlton <athorlton@sgi.com>

On Mon, 11 May 2015, Vlastimil Babka wrote:

> Khugepaged tries to preallocate a hugepage before scanning for THP collapse
> candidates. If the preallocation fails, scanning is not attempted. This makes
> sense, but it is only restricted to !NUMA configurations, where it does not
> need to predict on which node to preallocate.
> 
> Besides the !NUMA restriction, the preallocated page may also end up being
> unused and put back when no collapse candidate is found. I have observed the
> thp_collapse_alloc vmstat counter to have 3+ times the value of the counter
> of actually collapsed pages in /sys/.../khugepaged/pages_collapsed. On the
> other hand, the periodic hugepage allocation attempts involving sync
> compaction can be beneficial for the antifragmentation mechanism, but that's
> however harder to evaluate.
> 
> The following patch will introduce per-node THP availability tracking, which
> has more benefits than current preallocation and is applicable to CONFIG_NUMA.
> We can therefore remove the preallocation, which also allows a cleanup of the
> functions involved in khugepaged allocations. Another small benefit of the
> patch is that NUMA configs can now reuse an allocated hugepage for another
> collapse attempt, if the previous one was for the same node and failed.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

I think this is fine if the rest of the series is adopted, and I 
understand how the removal and cleanup is easier when done first before 
the following patches.  I think you can unify alloc_hugepage_node() for 
both NUMA and !NUMA configs and inline it in khugepaged_alloc_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
