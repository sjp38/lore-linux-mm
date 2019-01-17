Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 70E7D8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 11:00:43 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so3873253edc.6
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:00:43 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id w5si1263442edr.322.2019.01.17.08.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 08:00:41 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 7B5A6B89B1
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 16:00:41 +0000 (GMT)
Date: Thu, 17 Jan 2019 16:00:39 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 14/25] mm, compaction: Avoid rescanning the same
 pageblock multiple times
Message-ID: <20190117160039.GJ27437@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-15-mgorman@techsingularity.net>
 <67b95fef-6f9a-a91f-c1b2-1c3fbc9330ca@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <67b95fef-6f9a-a91f-c1b2-1c3fbc9330ca@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Thu, Jan 17, 2019 at 04:16:54PM +0100, Vlastimil Babka wrote:
> On 1/4/19 1:50 PM, Mel Gorman wrote:
> > Pageblocks are marked for skip when no pages are isolated after a scan.
> > However, it's possible to hit corner cases where the migration scanner
> > gets stuck near the boundary between the source and target scanner. Due
> > to pages being migrated in blocks of COMPACT_CLUSTER_MAX, pages that
> > are migrated can be reallocated before the pageblock is complete. The
> > pageblock is not necessarily skipped so it can be rescanned multiple
> > times. Similarly, a pageblock with some dirty/writeback pages may fail
> > to isolate and be rescanned until writeback completes which is wasteful.
> 
>      ^ migrate? If we failed to isolate, then it wouldn't bump nr_isolated.
> Wonder if we could do better checks and not isolate pages that cannot be at the
> moment migrated anyway.
> 

Potentially but it would be considered a layering violation. There may be
per-fs reasons why a page cannot migrate and no matter how well we check,
there will be race conditions.

> > The fault latency reduction is large and while the THP allocation
> > success rate is only slightly higher, it's already high at this
> > point of the series.
> > 
> > Compaction migrate scanned    60718343.00    31772603.00
> > Compaction free scanned      933061894.00    63267928.00
> 
> Hm I thought the order of magnitude difference between migrate and free scanned
> was already gone at this point as reported in the previous 2 patches.

There are corner cases that mean there can be large differences for a
single run. In some cases it doesn't matter but this one might have been
unlucky. It's something that occurs less as the series progresses.

> Or is this
> from different system/configuration?

I don't *think* so. While I had multiple machines running tests, I'm
pretty sure I wrote the changelogs based on one machine and only checked
the others had nothing strange.

> Anyway, encouraging result. I would expect
> that after "Keep migration source private to a single compaction instance" sets
> the skip bits much more early and aggressively, the rescans would not happen
> anymore thanks to those, even if cached pfns were not updated.
> 

Yes and no. The corner case where the scanner gets stuck rescanning one
pageblock can happen when the fast search fails. In that case, the
linear scanner needs to get to the end of a pageblock and if it fails,
it'll simply rescan like a lunatic. This happened specifically for pages
under writeback for me.

> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

Thanks

-- 
Mel Gorman
SUSE Labs
