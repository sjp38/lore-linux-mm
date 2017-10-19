Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEB16B025E
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 09:42:16 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o88so1257963wrb.18
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 06:42:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 11si1235589wmx.90.2017.10.19.06.42.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 06:42:15 -0700 (PDT)
Subject: Re: [PATCH 8/8] mm: Remove __GFP_COLD
References: <20171018075952.10627-1-mgorman@techsingularity.net>
 <20171018075952.10627-9-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f6505442-98a9-12e4-b2cd-0fa83874c159@suse.cz>
Date: Thu, 19 Oct 2017 15:42:12 +0200
MIME-Version: 1.0
In-Reply-To: <20171018075952.10627-9-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On 10/18/2017 09:59 AM, Mel Gorman wrote:
> As the page free path makes no distinction between cache hot and cold
> pages, there is no real useful ordering of pages in the free list that
> allocation requests can take advantage of. Juding from the users of
> __GFP_COLD, it is likely that a number of them are the result of copying
> other sites instead of actually measuring the impact. Remove the
> __GFP_COLD parameter which simplifies a number of paths in the page
> allocator.
> 
> This is potentially controversial but bear in mind that the size of the
> per-cpu pagelists versus modern cache sizes means that the whole per-cpu
> list can often fit in the L3 cache. Hence, there is only a potential benefit
> for microbenchmarks that alloc/free pages in a tight loop. It's even worse
> when THP is taken into account which has little or no chance of getting a
> cache-hot page as the per-cpu list is bypassed and the zeroing of multiple
> pages will thrash the cache anyway.
> 
> The truncate microbenchmarks are not shown as this patch affects the
> allocation path and not the free path. A page fault microbenchmark was
> tested but it showed no sigificant difference which is not surprising given
> that the __GFP_COLD branches are a miniscule percentage of the fault path.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

I've updated patch https://marc.info/?l=linux-mm&m=150831216224521&w=2 on top
of this. It's a small non-functional change, so it might even be folded.

----8<----
