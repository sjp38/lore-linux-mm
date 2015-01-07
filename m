Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 10BC86B0072
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 17:26:16 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so7643670pab.0
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 14:26:15 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id oz9si5542107pdb.15.2015.01.07.14.26.11
        for <linux-mm@kvack.org>;
        Wed, 07 Jan 2015 14:26:13 -0800 (PST)
From: Dave Chinner <david@fromorbit.com>
Subject: [RFC PATCH 0/6] xfs: truncate vs page fault IO exclusion
Date: Thu,  8 Jan 2015 09:25:37 +1100
Message-Id: <1420669543-8093-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xfs@oss.sgi.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi folks,

This patch set is an attempt to address issues with XFS
truncate and hole-punch code from racing with page faults that enter
the IO path. This is traditionally deadlock prone due to the
inversion of filesystem IO path locks and the mmap_sem.

To avoid this issue, I have introduced a new "i_mmaplock" rwsem into
the XFS code similar to the IO lock, but this lock is only taken in
the mmap fault paths on entry into the filesystem (i.e. ->fault and
->page_mkwrite).

The concept is that if we invalidate the page cache over a range
after taking both the existing i_iolock and the new i_mmaplock, we
will have prevented any vector for repopulation of the page cache
over the invalidated range until one of the io and mmap locks has
been dropped. i.e. we can guarantee that both the syscall IO path
and page faults won't race with whatever operation the filesystem is
performing...

The introduction of a new lock is necessary to avoid deadlocks due
to mmap_sem entanglement. It has a defined lock order during page
faults of:

mmap_sem
-> i_mmaplock (read)
   -> page lock
      -> i_ilock (get blocks)

This lock is then taken by any extent manipulation code in XFS in
addition to the IO lock which has the lock ordering of

i_iolock (write)
-> i_mmaplock (write)
   -> page lock (data writeback, page invalidation)
      -> i_lock (data writeback)
   -> i_lock (modification transaction)

Hence we have consistent lock ordering (which has been validated so
far by testing with lockdep enabled) for page fault IO vs
truncate, hole punch, extent shifts, etc.

This patchset passes xfstests and various benchmarks and stress
workloads, so the real question is now:

	What have I missed?

Comments, thoughts, flames?

-Dave.

GI: [RFC PATCH 1/6] xfs: introduce mmap/truncate lock

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
