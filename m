Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 686C7280244
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 19:07:06 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so56920655pdb.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:07:06 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id y9si46488546pdl.235.2015.07.21.16.07.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 16:07:05 -0700 (PDT)
Received: by padck2 with SMTP id ck2so126968176pad.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:07:05 -0700 (PDT)
Date: Tue, 21 Jul 2015 16:07:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
In-Reply-To: <55AE0AFE.8070200@suse.cz>
Message-ID: <alpine.DEB.2.10.1507211549380.3833@chino.kir.corp.google.com>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz> <1435826795-13777-2-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com> <55AE0AFE.8070200@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, 21 Jul 2015, Vlastimil Babka wrote:

> > Khugepaged benefits from the periodic memory compaction being done
> > immediately before it attempts to compact memory, and that may be lost
> > with a de-coupled approach like this.
> 

Meant to say "before it attempts to allocate a hugepage", but it seems you 
understood that :)

> That could be helped with waking up khugepaged after kcompactd is successful
> in making a hugepage available.

I don't think the criteria for waking up khugepaged should become any more 
complex beyond its current state, which is impacted by two different 
tunables, and whether it actually has memory to scan.  During this 
additional wakeup, you'd also need to pass kcompactd's node and only do 
local khugepaged scanning since there's no guarantee khugepaged can 
allocate on all nodes when one kcompactd defragments memory.  I think 
coupling these two would be too complex and not worth it.

> Also in your rfc you propose the compaction
> period to be 15 minutes, while khugepaged wakes up each 10 (or 30) seconds by
> default for the scanning and collapsing, so only fraction of the work is
> attempted right after the compaction anyway?
> 

The rfc actually proposes the compaction period to be 0, meaning it's 
disabled, but suggests in the changelog that we have seen a reproducible 
benefit with the period of 15m.

I'm not concerned about scan_sleep_millisecs here, if khugepaged was able 
to successfully allocate in its last scan.  I'm only concerned with 
alloc_sleep_millisecs which defaults to 60000.  I think it would be 
unfortunate if kcompactd were to free a pageblock, and then khugepaged 
waits for 60s before allocating.

> Hm reports of even not-so-high-order allocation failures occur from time to
> time. Some might be from atomic context, but some are because compaction just
> can't help due to the unmovable fragmentation. That's mostly a guess, since
> such detailed information isn't there, but I think Joonsoo did some
> experiments that confirmed this.
> 

If it's unmovable fragmentation, then any periodic synchronous memory 
compaction isn't going to help either.  The page allocator already does 
MIGRATE_SYNC_LIGHT compaction on its second pass and that will terminate 
when a high-order page is available.  If it is currently failing, then I 
don't see the benefit of synchronous memory compaction over all memory 
that would substantially help this case.

> Also effects on the fragmentation are evaluated when making changes to
> compaction, see e.g. http://marc.info/?l=linux-mm&m=143634369227134&w=2
> In the past it has prevented changes that would improve latency of direct
> compaction. They might be possible if there was a reliable source of more
> thorough periodic compaction to counter the not-so-thorough direct compaction.
> 

Hmm, I don't think we have to select one to the excusion of the other.  I 
don't think that because khugepaged may do periodic synchronous memory 
compaction (to eventually remove direct compaction entirely from the page 
fault path, since we have checks in the page allocator that specifically 
do that) that we can't do background memory compaction elsewhere.  I think 
it would be trivial to schedule a workqueue in the page allocator when 
MIGRATE_ASYNC compaction fails for a high-order allocation on a node and 
to have that local compaction done in the background.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
