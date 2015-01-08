Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id D06FF6B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 06:34:59 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id s18so8629920lam.2
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 03:34:59 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ql3si7494005lbb.133.2015.01.08.03.34.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 03:34:58 -0800 (PST)
Date: Thu, 8 Jan 2015 12:34:54 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH 0/6] xfs: truncate vs page fault IO exclusion
Message-ID: <20150108113454.GA25807@quack.suse.cz>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420669543-8093-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

  Hi,

On Thu 08-01-15 09:25:37, Dave Chinner wrote:
> This patch set is an attempt to address issues with XFS
> truncate and hole-punch code from racing with page faults that enter
> the IO path. This is traditionally deadlock prone due to the
> inversion of filesystem IO path locks and the mmap_sem.
> 
> To avoid this issue, I have introduced a new "i_mmaplock" rwsem into
> the XFS code similar to the IO lock, but this lock is only taken in
> the mmap fault paths on entry into the filesystem (i.e. ->fault and
> ->page_mkwrite).
> 
> The concept is that if we invalidate the page cache over a range
> after taking both the existing i_iolock and the new i_mmaplock, we
> will have prevented any vector for repopulation of the page cache
> over the invalidated range until one of the io and mmap locks has
> been dropped. i.e. we can guarantee that both the syscall IO path
> and page faults won't race with whatever operation the filesystem is
> performing...
> 
> The introduction of a new lock is necessary to avoid deadlocks due
> to mmap_sem entanglement. It has a defined lock order during page
> faults of:
> 
> mmap_sem
> -> i_mmaplock (read)
>    -> page lock
>       -> i_ilock (get blocks)
> 
> This lock is then taken by any extent manipulation code in XFS in
> addition to the IO lock which has the lock ordering of
> 
> i_iolock (write)
> -> i_mmaplock (write)
>    -> page lock (data writeback, page invalidation)
>       -> i_lock (data writeback)
>    -> i_lock (modification transaction)
> 
> Hence we have consistent lock ordering (which has been validated so
> far by testing with lockdep enabled) for page fault IO vs
> truncate, hole punch, extent shifts, etc.
> 
> This patchset passes xfstests and various benchmarks and stress
> workloads, so the real question is now:
> 
> 	What have I missed?
> 
> Comments, thoughts, flames?
  I had a look at the patches and as far as I can tell this should work
fine (at least from the VFS / MM POV).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
