Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 759806B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:51:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i85so193751457pfa.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:51:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 88si30771686pfs.216.2016.10.17.05.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 05:51:33 -0700 (PDT)
Date: Mon, 17 Oct 2016 14:51:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: mmap_sem bottleneck
Message-ID: <20161017125130.GU3142@twins.programming.kicks-ass.net>
References: <ea12b8ee-1892-fda1-8a83-20fdfdfa39c4@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ea12b8ee-1892-fda1-8a83-20fdfdfa39c4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Davidlohr Bueso <dbueso@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Mon, Oct 17, 2016 at 02:33:53PM +0200, Laurent Dufour wrote:
> Hi all,
> 
> I'm sorry to resurrect this topic, but with the increasing number of
> CPUs, this becomes more frequent that the mmap_sem is a bottleneck
> especially between the page fault handling and the other threads memory
> management calls.
> 
> In the case I'm seeing, there is a lot of page fault occurring while
> other threads are trying to manipulate the process memory layout through
> mmap/munmap.
> 
> There is no *real* conflict between these operations, the page fault are
> done a different page and areas that the one addressed by the mmap/unmap
> operations. Thus threads are dealing with different part of the
> process's memory space. However since page fault handlers and mmap/unmap
> operations grab the mmap_sem, the page fault handling are serialized
> with the mmap operations, which impact the performance on large system.
> 
> For the record, the page fault are done while reading data from a file
> system, and I/O are really impacted by this serialization when dealing
> with a large number of parallel threads, in my case 192 threads (1 per
> online CPU). But the source of the page fault doesn't really matter I guess.
> 
> I took time trying to figure out how to get rid of this bottleneck, but
> this is definitively too complex for me.
> I read this mailing history, and some LWN articles about that and my
> feeling is that there is no clear way to limit the impact of this
> semaphore. Last discussion on this topic seemed to happen last march
> during the LSFMM submit (https://lwn.net/Articles/636334/). But this
> doesn't seem to have lead to major changes, or may be I missed them.
> 
> I'm now seeing that this is a big thing and that it would be hard and
> potentially massively intrusive to get rid of this bottleneck, and I'm
> wondering what could be to best approach here, RCU, range locks, etc..
> 
> Does anyone have an idea ?

If its really just the pagefaults you care about you can have a look at
my speculative page fault stuff that I don't ever seem to get around to
updating :/

Latest version is here:

  https://lkml.kernel.org/r/20141020215633.717315139@infradead.org

Plenty of bits left to sort with that, but the general idea is to use
the split page-table locks (PTLs) as range lock for the mmap_sem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
