Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 12ACD6B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 18:34:21 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n126so570978wma.7
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 15:34:21 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l12si219385wrl.519.2017.11.28.15.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 15:34:19 -0800 (PST)
Date: Tue, 28 Nov 2017 15:34:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, compaction: direct freepage allocation for async
 direct compaction
Message-Id: <20171128153416.f7062caba47d86eb4eb15b8b@linux-foundation.org>
In-Reply-To: <32b5f1b6-e3aa-4f15-4ec6-5cbb5fe158d0@suse.cz>
References: <20171122143321.29501-1-hannes@cmpxchg.org>
	<32b5f1b6-e3aa-4f15-4ec6-5cbb5fe158d0@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, 22 Nov 2017 15:52:55 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 11/22/2017 03:33 PM, Johannes Weiner wrote:
> > From: Vlastimil Babka <vbabka@suse.cz>
> > 
> > The goal of direct compaction is to quickly make a high-order page available
> > for the pending allocation. The free page scanner can add significant latency
> > when searching for migration targets, although to succeed the compaction, the
> > only important limit on the target free pages is that they must not come from
> > the same order-aligned block as the migrated pages.
> > 
> > This patch therefore makes direct async compaction allocate freepages directly
> > from freelists. Pages that do come from the same block (which we cannot simply
> > exclude from the freelist allocation) are put on separate list and released
> > only after migration to allow them to merge.
> > 
> > In addition to reduced stall, another advantage is that we split larger free
> > pages for migration targets only when smaller pages are depleted, while the
> > free scanner can split pages up to (order - 1) as it encouters them. However,
> > this approach likely sacrifices some of the long-term anti-fragmentation
> > features of a thorough compaction, so we limit the direct allocation approach
> > to direct async compaction.
> > 
> > For observational purposes, the patch introduces two new counters to
> > /proc/vmstat. compact_free_direct_alloc counts how many pages were allocated
> > directly without scanning, and compact_free_direct_miss counts the subset of
> > these allocations that were from the wrong range and had to be held on the
> > separate list.
> > 
> > Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> > 
> > Hi. I'm resending this because we've been struggling with the cost of
> > compaction in our fleet, and this patch helps substantially.
> > 
> > On 128G+ machines, we have seen isolate_freepages_block() eat up 40%
> > of the CPU cycles and scanning up to a billion PFNs per minute. Not in
> > a spike, but continuously, to service higher-order allocations from
> > the network stack, fork (non-vmap stacks), THP, etc. during regular
> > operation.
> > 
> > I've been running this patch on a handful of less-affected but still
> > pretty bad machines for a week, and the results look pretty great:
> > 
> > 	http://cmpxchg.org/compactdirectalloc/compactdirectalloc.png
> 
> Thanks a lot, that's very encouraging!

Yup.

Should we proceed with this patch for now, or wait for something better
to come along?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
