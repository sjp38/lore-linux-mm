Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A32E6B19C9
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 11:32:28 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j9-v6so13610744qtn.22
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 08:32:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a185-v6si5301154qke.251.2018.08.20.08.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 08:32:27 -0700 (PDT)
Date: Mon, 20 Aug 2018 11:32:14 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180820153214.GC13047@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <6D0E157B-3ECC-4642-BF98-FEB884D49854@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6D0E157B-3ECC-4642-BF98-FEB884D49854@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

Hello,

On Mon, Aug 20, 2018 at 08:35:17AM -0400, Zi Yan wrote:
> I think this can also be triggered in khugepaged. In collapse_huge_page(), khugepaged_alloc_page()
> would also cause DIRECT_RECLAIM if defrag==always, since GFP_TRANSHUGE implies __GFP_DIRECT_RECLAIM.
> 
> But is it an expected behavior of khugepaged?

That's a good point, and answer it not obvious. It's not an apple to
apple comparison because khugepaged is not increasing the overall
memory footprint of the app. The pages that gets compacted gets freed
later. However not all memory of the node may be possible to compact
100% so it's not perfectly a 1:1 exchange and it could require some
swap to succeed compaction.

So we may want to look also at khugepaged later, but it's not obvious
it needs fixing too. It'd weaken a bit khugepaged to add
__GFP_COMPACT_ONLY to it, if compaction returns COMPACT_SKIPPED
especially.

As opposed in the main allocation path (when memory footprint
definitely increases) I even tried to still allow reclaim only for
COMPACT_SKIPPED and it still caused swapout storms because new THP
kept being added to the local node as the old memory was swapped out
to make more free memory to compact more 4k pages. Otherwise I could
have gotten away with using __GFP_NORETRY instead of
__GFP_COMPACT_ONLY but it wasn't nearly enough.

Similarly to khugepaged NUMA balancing also uses __GFP_THISNODE but if
it decided to migrate a page to such node supposedly there's a good
reason to call reclaim to allocate the page there if needed. That also
is freeing memory on node and adding memory to another node, and it's
not increasing the memory footprint overall (unlike khugepaged, it
increases the footprint cross-node though).

Thanks,
Andrea
