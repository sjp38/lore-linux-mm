Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 107518E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 05:56:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v4so4149415edm.18
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 02:56:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f14si216833edw.282.2019.01.10.02.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 02:56:43 -0800 (PST)
Date: Thu, 10 Jan 2019 10:56:38 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v7 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
Message-ID: <20190110105638.GJ28934@suse.de>
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690327057.676627.18166704439241470885.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <154690327057.676627.18166704439241470885.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, keith.busch@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 07, 2019 at 03:21:10PM -0800, Dan Williams wrote:
> Randomization of the page allocator improves the average utilization of
> a direct-mapped memory-side-cache. Memory side caching is a platform
> capability that Linux has been previously exposed to in HPC
> (high-performance computing) environments on specialty platforms. In
> that instance it was a smaller pool of high-bandwidth-memory relative to
> higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
> be found on general purpose server platforms where DRAM is a cache in
> front of higher latency persistent memory [1].
> 

So I glanced through the series and while I won't nak it, I'm not a
major fan either so I won't ack it either. While there are merits to
randomisation in terms of cache coloring, it may not be robust. IIRC, the
main strength of randomisation vs being smart was "it's simple and usually
doesn't fall apart completely". In particular I'd worry that compaction
will undo all the randomisation work by moving related pages into the same
direct-mapped lines. Furthermore, the runtime list management of "randomly
place and head or tail of list" will have variable and non-deterministic
outcomes and may also be undone by either high-order merging or compaction.

As bad as it is, an ideal world would have a proper cache-coloring
allocation algorithm but they previously failed as the runtime overhead
exceeded the actual benefit, particularly as fully associative caches
became more popular and there was no universal "one solution fits all". One
hatchet job around it may be to have per-task free-lists that put free
pages into buckets with the obvious caveat that those lists would need
draining and secondary locking. A caveat of that is that there may need
to be arch and/or driver hooks to detect how the colors are managed which
could also turn into a mess.

The big plus of the series is that it's relatively simple and appears to
be isolated enough that it only has an impact when the necessary hardware
in place. It will deal with some cases but I'm not sure it'll survive
long-term, particularly if HPC continues to report in the field that
reboots are necessary to reshufffle the lists (taken from your linked
documents). That workaround of running STREAM before a job starts and
rebooting the machine if the performance SLAs are not met is horrid.

-- 
Mel Gorman
SUSE Labs
