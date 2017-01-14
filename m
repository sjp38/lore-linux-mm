Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D68926B0069
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 19:20:10 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id b22so155886708pfd.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 16:20:10 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a90si14129224plc.330.2017.01.13.16.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 16:20:09 -0800 (PST)
Date: Fri, 13 Jan 2017 17:20:08 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [LSF/MM TOPIC] Future direction of DAX
Message-ID: <20170114002008.GA25379@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-block@vger.kernel.org, linux-mm@kvack.org

This past year has seen a lot of new DAX development.  We have added support
for fsync/msync, moved to the new iomap I/O data structure, introduced radix
tree based locking, re-enabled PMD support (twice!), and have fixed a bunch of
bugs.

We still have a lot of work to do, though, and I'd like to propose a discussion
around what features people would like to see enabled in the coming year as
well as what what use cases their customers have that we might not be aware of.

Here are a few topics to start the conversation:

- The current plan to allow users to safely flush dirty data from userspace is
  built around the PMEM_IMMUTABLE feature [1].  I'm hoping that by LSF/MM we
  will have at least started work on PMEM_IMMUTABLE, but I'm guessing there
  will be more to discuss.

- The DAX fsync/msync model was built for platforms that need to flush dirty
  processor cache lines in order to make data durable on NVDIMMs.  There exist
  platforms, however, that are set up so that the processor caches are
  effectively part of the ADR safe zone.  This means that dirty data can be
  assumed to be durable even in the processor cache, obviating the need to
  manually flush the cache during fsync/msync.  These platforms still need to
  call fsync/msync to ensure that filesystem metadata updates are properly
  written to media.  Our first idea on how to properly support these platforms
  would be for DAX to be made aware that in some cases doesn't need to keep
  metadata about dirty cache lines.  A similar issue exists for volatile uses
  of DAX such as with BRD or with PMEM and the memmap command line parameter,
  and we'd like a solution that covers them all.

- If I recall correctly, at one point Dave Chinner suggested that we change
  DAX so that I/O would use cached stores instead of the non-temporal stores
  that it currently uses.  We would then track pages that were written to by
  DAX in the radix tree so that they would be flushed later during
  fsync/msync.  Does this sound like a win?  Also, assuming that we can find a
  solution for platforms where the processor cache is part of the ADR safe
  zone (above topic) this would be a clear improvement, moving us from using
  non-temporal stores to faster cached stores with no downside.

- Jan suggested [2] that we could use the radix tree as a cache to service DAX
  faults without needing to call into the filesystem.  Are there any issues
  with this approach, and should we move forward with it as an optimization?

- Whenever you mount a filesystem with DAX, it spits out a message that says
  "DAX enabled. Warning: EXPERIMENTAL, use at your own risk".  What criteria
  needs to be met for DAX to no longer be considered experimental?

- When we msync() a huge page, if the range is less than the entire huge page,
  should we flush the entire huge page and mark it clean in the radix tree, or
  should we only flush the requested range and leave the radix tree entry
  dirty?

- Should we enable 1 GiB huge pages in filesystem DAX?  Does anyone have any
  specific customer requests for this or performance data suggesting it would
  be a win?  If so, what work needs to be done to get 1 GiB sized and aligned
  filesystem block allocations, to get the required enabling in the MM layer,
  etc?

Thanks,
- Ross

[1] https://lkml.org/lkml/2016/12/19/571
[2] https://lkml.org/lkml/2016/10/12/70

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
