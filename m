Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1E078E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 04:29:03 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t2so3397665edb.22
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 01:29:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w14si12996413edd.398.2019.01.17.01.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 01:29:02 -0800 (PST)
Subject: Re: [PATCH 12/25] mm, compaction: Keep migration source private to a
 single compaction instance
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-13-mgorman@techsingularity.net>
 <0d02b611-85a7-b161-1310-883c4b1594f8@suse.cz>
 <20190116161537.GG27437@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ff6953a1-6cb4-8f5d-4bfa-f1e8f5dd4f7a@suse.cz>
Date: Thu, 17 Jan 2019 10:29:00 +0100
MIME-Version: 1.0
In-Reply-To: <20190116161537.GG27437@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/16/19 5:15 PM, Mel Gorman wrote:
> On Wed, Jan 16, 2019 at 04:45:59PM +0100, Vlastimil Babka wrote:
>> On 1/4/19 1:49 PM, Mel Gorman wrote:
>> > Due to either a fast search of the free list or a linear scan, it is
>> > possible for multiple compaction instances to pick the same pageblock
>> > for migration.  This is lucky for one scanner and increased scanning for
>> > all the others. It also allows a race between requests on which first
>> > allocates the resulting free block.
>> > 
>> > This patch tests and updates the pageblock skip for the migration scanner
>> > carefully. When isolating a block, it will check and skip if the block is
>> > already in use. Once the zone lock is acquired, it will be rechecked so
>> > that only one scanner can set the pageblock skip for exclusive use. Any
>> > scanner contending will continue with a linear scan. The skip bit is
>> > still set if no pages can be isolated in a range.
>> 
>> Also the skip bit will remain set even if pages *could* be isolated,
> 
> That's the point -- the pageblock is scanned by one compaction instance
> and skipped by others.

OK, I understood wrongly that this is meant just to avoid races.

>> AFAICS there's no clearing after a block was finished with
>> nr_isolated>0. Is it intended?
> 
> Yes, defer to a full reset later when the compaction scanners meet.
> Tracing really indicated we spent a stupid amount of time scanning,
> rescanning and competing for pageblocks within short interval.

Right.

>> > Migration scan rates are reduced by 52%.
>> 
>> Wonder how much of that is due to not clearing as pointed out above.
>> Also interesting how free scanned was reduced so disproportionally.
>> 
> 
> The amount of free scanning is related to the amount of migration
> scanning. If migration sources are scanning, rescanning and competing
> for the same pageblocks, it can result in unnecessary free scanning too.
> It doesn't fully explain the drop but I didn't specifically try to quantify
> it either as the free scanner is altered further in later patches.

Perhaps lots of skipping in migration scanners mean that they progress faster
into the parts of zone that would otherwise be scanned by the free scanner, so
the free scanner has less work to do. But agree that it's moot to investigate
too much if there are further changes later.
