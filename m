Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA5436B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 18:56:59 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id yr2so2947101wjc.4
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 15:56:59 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id 32si12870143wru.4.2017.01.13.15.56.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 15:56:58 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id n129so15597786wmn.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 15:56:58 -0800 (PST)
Date: Sat, 14 Jan 2017 02:56:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LSF/MM TOPIC][LSF/MM ATTEND] Multiple Page Caches, Memory
 Tiering, Better LRU evictions,
Message-ID: <20170113235656.GB26245@node.shutemov.name>
References: <61F9233AFAF8C541AAEC03A42CB0D8C7025D002B@MX203CL01.corp.emc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <61F9233AFAF8C541AAEC03A42CB0D8C7025D002B@MX203CL01.corp.emc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michaud, Adrian" <Adrian.Michaud@dell.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jan 13, 2017 at 09:49:14PM +0000, Michaud, Adrian wrote:
> I'd like to attend and propose one or all of the following topics at this year's summit.
> 
> Multiple Page Caches (Software Enhancements)
> --------------------------
> Support for multiple page caches can provide many benefits to the kernel.
> Different memory types can be put into different page caches. One page
> cache for native DDR system memory, another page cache for slower
> NV-DIMMs, etc.
> General memory can be partitioned into several page caches of different
> sizes and could also be dedicated to high priority processes or used
> with containers to better isolate memory by dedicating a page cache to a
> cgroup process.
> Each VMA, or process, could have a page cache identifier, or page
> alloc/free callbacks that allow individual VMAs or processes to specify
> which page cache they want to use.
> Some VMAs might want anonymous memory backed by vast amounts of slower
> server class memory like NV-DIMMS.
> Some processes or individual VMAs might want their own private page
> cache.
> Each page cache can have its own eviction policy and low-water markers
> Individual page caches could also have their own swap device.

Sounds like you're re-inventing NUMA.
What am I missing?

> Memory Tiering (Software Enhancements)
> --------------------
> Using multiple page caches, evictions from one page cache could be moved
> and remapped to another page cache instead of unmapped and written to
> swap.
> If a system has 16GB of high speed DDR memory, and 64GB of slower
> memory, one could create a page cache with high speed DDR memory,
> another page cache with slower 64GB memory, and evict/copy/remap from
> the DDR page cache to the slow memory page cache. Evictions from the
> slow memory page cache would then get unmapped and written to swap.

I guess it's something that can be done as part of NUMA balancing.

> Better LRU evictions (Software and Hardware Enhancements)
> -------------------------
> Add a page fault counter to the page struct to help colorize page demand.
> We could suggest to Intel/AMD and other architecture leaders that TLB
> entries also have a translation counter (8-10 bits is sufficient)
> instead of just an "accessed" bit.  Scanning/clearing access bits is
> obviously inefficient; however, if TLBs had a translation counter
> instead of a single accessed bit then scanning and recording the amount
> of activity each TLB has would be significantly better and allow us to
> bettern calculate LRU pages for evictions.

Except that would make memory accesses slower.

Even access bit handing is noticible performance hit: processor has to
write into page table entry on first access to the page.
What you're proposing is making 2^8-2^10 first accesses slower.

Sounds like no-go for me.

> TLB Shootdown (Hardware Enhancements)
> --------------------------
> We should stomp our feet and demand that TLB shootdowns should be
> hardware assisted in future architectures. Current TLB shootdown on x86
> is horribly inefficient and obviously doesn't scale. The QPI/UPI local
> bus protocol should provide TLB range invalidation broadcast so that a
> single CPU can concurrently notify other CPU/cores (with a selection
> mask) that a shared TLB entry has changed. Sending an IPI to each core
> is horribly inefficient; especially with the core counts increasing and
> the frequency of TLB unmapping/remapping also possibly increasing
> shortly with new server class memory extension technology.

IIUC, the best you can get from hardware is IPI behind the scene.
I doubt it worth the effort.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
