Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 720376B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 19:17:34 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id l13so234690iga.1
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 16:17:34 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id eg4si631239igb.9.2014.07.15.16.17.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 16:17:33 -0700 (PDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so229334igb.4
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 16:17:33 -0700 (PDT)
Date: Tue, 15 Jul 2014 16:17:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: only collapse hugepages to nodes with
 affinity
In-Reply-To: <53C4B251.5000505@intel.com>
Message-ID: <alpine.DEB.2.02.1407151609120.32274@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com> <53C4B251.5000505@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 Jul 2014, Dave Hansen wrote:

> > +		if (node == NUMA_NO_NODE) {
> > +			node = page_to_nid(page);
> > +		} else {
> > +			int distance = node_distance(page_to_nid(page), node);
> > +
> > +			/*
> > +			 * Do not migrate to memory that would not be reclaimed
> > +			 * from.
> > +			 */
> > +			if (distance > RECLAIM_DISTANCE)
> > +				goto out_unmap;
> > +		}
> 
> Isn't the reclaim behavior based on zone_reclaim_mode and not
> RECLAIM_DISTANCE directly?  And isn't that reclaim behavior disabled by
> default?
> 

Seems that RECLAIM_DISTANCE has taken on a life of its own independent of 
zone_reclaim_mode as a heuristic, such as its use in creating sched 
domains which would be unrelated.

> I think you should at least be consulting zone_reclaim_mode.
> 

Good point, and it matches what the comment is saying about whether we'd 
actually reclaim from the remote node to allocate thp on fault or not.  
I'll add it.

After this change, we'll also need to consider the behavior of thp at 
fault and whether remote HPAGE_PMD_SIZE memory when local memory is 
low/fragmented is better than local PAGE_SIZE memory.  In my page fault 
latency testing on true NUMA machines it's convincing that it's not.

This makes me believe that, somewhat similar to this patch, when we 
allocate thp memory at fault and zone_reclaim_mode is non-zero that we 
should set only nodes with numa_node_id() <= RECLAIM_DISTANCE and then 
otherwise fallback to the PAGE_SIZE fault path.

I've been hesitant to make that exact change, though, because it's a 
systemwide setting and I really hope to avoid a prctl() that controls 
zone reclaim for a particular process.  Perhaps the NUMA balancing work 
makes this more dependable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
