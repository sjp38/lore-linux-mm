Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4246B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 03:26:27 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so177499166pfy.2
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 00:26:27 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f8si15058228pgc.288.2017.01.14.00.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 00:26:26 -0800 (PST)
Date: Sat, 14 Jan 2017 00:26:21 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [LSF/MM TOPIC] Future direction of DAX
Message-ID: <20170114082621.GC10498@birch.djwong.org>
References: <20170114002008.GA25379@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114002008.GA25379@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 13, 2017 at 05:20:08PM -0700, Ross Zwisler wrote:
> This past year has seen a lot of new DAX development.  We have added support
> for fsync/msync, moved to the new iomap I/O data structure, introduced radix
> tree based locking, re-enabled PMD support (twice!), and have fixed a bunch of
> bugs.
> 
> We still have a lot of work to do, though, and I'd like to propose a discussion
> around what features people would like to see enabled in the coming year as
> well as what what use cases their customers have that we might not be aware of.
> 
> Here are a few topics to start the conversation:
> 
> - The current plan to allow users to safely flush dirty data from userspace is
>   built around the PMEM_IMMUTABLE feature [1].  I'm hoping that by LSF/MM we
>   will have at least started work on PMEM_IMMUTABLE, but I'm guessing there
>   will be more to discuss.

Yes, probably. :)

> - The DAX fsync/msync model was built for platforms that need to flush dirty
>   processor cache lines in order to make data durable on NVDIMMs.  There exist
>   platforms, however, that are set up so that the processor caches are
>   effectively part of the ADR safe zone.  This means that dirty data can be
>   assumed to be durable even in the processor cache, obviating the need to
>   manually flush the cache during fsync/msync.  These platforms still need to
>   call fsync/msync to ensure that filesystem metadata updates are properly
>   written to media.  Our first idea on how to properly support these platforms
>   would be for DAX to be made aware that in some cases doesn't need to keep
>   metadata about dirty cache lines.  A similar issue exists for volatile uses
>   of DAX such as with BRD or with PMEM and the memmap command line parameter,
>   and we'd like a solution that covers them all.
> 
> - If I recall correctly, at one point Dave Chinner suggested that we change
>   DAX so that I/O would use cached stores instead of the non-temporal stores
>   that it currently uses.  We would then track pages that were written to by
>   DAX in the radix tree so that they would be flushed later during
>   fsync/msync.  Does this sound like a win?  Also, assuming that we can find a
>   solution for platforms where the processor cache is part of the ADR safe
>   zone (above topic) this would be a clear improvement, moving us from using
>   non-temporal stores to faster cached stores with no downside.
> 
> - Jan suggested [2] that we could use the radix tree as a cache to service DAX
>   faults without needing to call into the filesystem.  Are there any issues
>   with this approach, and should we move forward with it as an optimization?
> 
> - Whenever you mount a filesystem with DAX, it spits out a message that says
>   "DAX enabled. Warning: EXPERIMENTAL, use at your own risk".  What criteria
>   needs to be met for DAX to no longer be considered experimental?

For XFS I'd like to get reflink working with it, for starters.  We
probably need a bunch more verification work to show that file IO
doesn't adopt any bad quirks having turned on the per-inode DAX flag.

Some day we'll start designing a pmem-native fs, I guess. :P

> - When we msync() a huge page, if the range is less than the entire huge page,
>   should we flush the entire huge page and mark it clean in the radix tree, or
>   should we only flush the requested range and leave the radix tree entry
>   dirty?
> 
> - Should we enable 1 GiB huge pages in filesystem DAX?  Does anyone have any
>   specific customer requests for this or performance data suggesting it would
>   be a win?  If so, what work needs to be done to get 1 GiB sized and aligned
>   filesystem block allocations, to get the required enabling in the MM layer,
>   etc?

<giggle> :)

--D

> 
> Thanks,
> - Ross
> 
> [1] https://lkml.org/lkml/2016/12/19/571
> [2] https://lkml.org/lkml/2016/10/12/70
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
