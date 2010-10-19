Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EF3316B0098
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 16:40:11 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o9JKe42f008366
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:40:04 -0700
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by wpaz24.hot.corp.google.com with ESMTP id o9JKdXI3030583
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:40:02 -0700
Received: by pxi15 with SMTP id 15so871663pxi.12
        for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:40:00 -0700 (PDT)
Date: Tue, 19 Oct 2010 13:39:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
In-Reply-To: <20101005185725.088808842@linux.com>
Message-ID: <alpine.DEB.2.00.1010191337370.20631@chino.kir.corp.google.com>
References: <20101005185725.088808842@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Oct 2010, Christoph Lameter wrote:

> V3->V4:
> - Lots of debugging
> - Performance optimizations (more would be good)...
> - Drop per slab locking in favor of per node locking for
>   partial lists (queuing implies freeing large amounts of objects
>   to per node lists of slab).
> - Implement object expiration via reclaim VM logic.
> 

I applied this set on top of Pekka's for-next tree reverted back to 
5d1f57e4 since it doesn't apply later then that.

Overall, the results are _much_ better than the vanilla slub allocator 
that I frequently saw ~20% regressions with the TCP_RR netperf benchmark 
on a couple of my machines with larger cpu counts.  However, there still 
is a significant performance degradation compared to slab.

When running this patchset on two (client and server running 
netperf-2.4.5) four 2.2GHz quad-core AMD processors with 64GB of memory,
here're the results:

	threads		SLAB		SLUB		diff
	16		207038		184389		-10.9%
	32		266105		234386		-11.9%
	48		287989		252733		-12.2%
	64		307572		277221		- 9.9%		
	80		309802		284199		- 8.3%
	96		302959		291743		- 3.7%
	112		307381		297459		- 3.2%
	128		314582		299340		- 4.8%
	144		331945		299648		- 9.7%
	160		321882		314192		- 2.4%

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
