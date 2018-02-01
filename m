Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 513E26B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 04:44:34 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q2so5699086pgf.22
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 01:44:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w22-v6si1576561pll.98.2018.02.01.01.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Feb 2018 01:44:33 -0800 (PST)
Date: Thu, 1 Feb 2018 01:44:31 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] lru_lock scalability
Message-ID: <20180201094431.GA20742@bombadil.infradead.org>
References: <2a16be43-0757-d342-abfb-d4d043922da9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2a16be43-0757-d342-abfb-d4d043922da9@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, steven.sistare@oracle.com, pasha.tatashin@oracle.com, yossi.lev@oracle.com, Dave.Dice@oracle.com, akpm@linux-foundation.org, mhocko@kernel.org, ldufour@linux.vnet.ibm.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ak@linux.intel.com, mgorman@suse.de

On Wed, Jan 31, 2018 at 11:44:29PM -0500, Daniel Jordan wrote:
> I'd like to propose a discussion of lru_lock scalability on the mm track.  Since this is similar to Laurent Dufour's mmap_sem topic, it might make sense to discuss these around the same time.
> 
> On large systems, lru_lock is one of the hottest locks in the kernel, showing up on many memory-intensive benchmarks such as decision support.  It also inhibits scalability in many of the mm paths that could be parallelized, such as freeing pages during exit/munmap and inode eviction.
> 
> I'd like to discuss the following two ways of solving this problem, as well as any other approaches or ideas people have.

Something I've been thinking about is changing the LRU from an embedded
list_head to an external data structure that I call the XQueue.
It's based on the XArray, but is used like a queue; pushing items onto
the end of the queue and popping them off the beginning.  You can also
remove items from the middle of the queue.

Removing items from the list usually involves dirtying three cachelines.
With the XQueue, you'd only dirty one.  That's going to reduce lock
hold time.  There may also be opportunities to reduce lock hold time;
removal and addition can be done in parallel as long as there's more
than 64 entries between head and tail of the list.

The downside is that adding to the queue would require memory allocation.
And I don't have time to work on it at the moment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
