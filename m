Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5FD88E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 11:15:40 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id 39so2612743edq.13
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:15:40 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id b54si1191222ede.267.2019.01.16.08.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 08:15:39 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id C3C651C291B
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:15:38 +0000 (GMT)
Date: Wed, 16 Jan 2019 16:15:37 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 12/25] mm, compaction: Keep migration source private to a
 single compaction instance
Message-ID: <20190116161537.GG27437@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-13-mgorman@techsingularity.net>
 <0d02b611-85a7-b161-1310-883c4b1594f8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <0d02b611-85a7-b161-1310-883c4b1594f8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Wed, Jan 16, 2019 at 04:45:59PM +0100, Vlastimil Babka wrote:
> On 1/4/19 1:49 PM, Mel Gorman wrote:
> > Due to either a fast search of the free list or a linear scan, it is
> > possible for multiple compaction instances to pick the same pageblock
> > for migration.  This is lucky for one scanner and increased scanning for
> > all the others. It also allows a race between requests on which first
> > allocates the resulting free block.
> > 
> > This patch tests and updates the pageblock skip for the migration scanner
> > carefully. When isolating a block, it will check and skip if the block is
> > already in use. Once the zone lock is acquired, it will be rechecked so
> > that only one scanner can set the pageblock skip for exclusive use. Any
> > scanner contending will continue with a linear scan. The skip bit is
> > still set if no pages can be isolated in a range.
> 
> Also the skip bit will remain set even if pages *could* be isolated,

That's the point -- the pageblock is scanned by one compaction instance
and skipped by others.

> AFAICS there's no clearing after a block was finished with
> nr_isolated>0. Is it intended?

Yes, defer to a full reset later when the compaction scanners meet.
Tracing really indicated we spent a stupid amount of time scanning,
rescanning and competing for pageblocks within short intervals.

> > Migration scan rates are reduced by 52%.
> 
> Wonder how much of that is due to not clearing as pointed out above.
> Also interesting how free scanned was reduced so disproportionally.
> 

The amount of free scanning is related to the amount of migration
scanning. If migration sources are scanning, rescanning and competing
for the same pageblocks, it can result in unnecessary free scanning too.
It doesn't fully explain the drop but I didn't specifically try to quantify
it either as the free scanner is altered further in later patches.

-- 
Mel Gorman
SUSE Labs
