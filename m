Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8EBE78D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:46:50 -0400 (EDT)
Date: Tue, 19 Apr 2011 21:46:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110419134645.GA26123@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.515923886@intel.com>
 <20110419073523.GF23985@dastard>
 <20110419095740.GC5257@quack.suse.cz>
 <20110419125616.GA20059@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419125616.GA20059@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

> wfg /tmp% g cpu log-* | g dd
> log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 9% cpu 13.658 total
> log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 9% cpu 12.961 total
> log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 9% cpu 13.420 total
> log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.30s system 9% cpu 13.103 total
> log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.31s system 9% cpu 13.650 total
> log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.25s system 8% cpu 15.258 total
> log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 8% cpu 14.255 total
> log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 8% cpu 14.443 total
> log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.25s system 8% cpu 14.051 total
> log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.27s system 8% cpu 14.648 total
> 
> wfg /tmp% g cpu log-* | g tar
> log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.49s user 3.99s system 60% cpu 27.285 total
> log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.78s user 4.40s system 65% cpu 26.125 total
> log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.50s user 4.56s system 64% cpu 26.265 total
> log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.50s user 4.18s system 62% cpu 26.766 total
> log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.60s user 4.03s system 60% cpu 27.463 total
> log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.42s user 4.17s system 57% cpu 28.688 total
> log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.67s user 4.04s system 58% cpu 28.738 total
> log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.53s user 4.50s system 58% cpu 29.287 total
> log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.38s user 4.28s system 57% cpu 28.861 total
> log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.44s user 4.19s system 56% cpu 29.443 total

Jan, here are the ext4 numbers. It's also doing better now. And I find
the behaviors and hence dd vs. tar numbers are pretty different from XFS.

- XFS like redirtying the inode after writing pages while ext4 not

- ext4 enforces large 128MB write chunk size, while XFS uses the
  adaptive 24-28MB chunk size (close to half disk bandwidth)

log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.34s user 3.46s system 93% cpu 16.848 total
log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.59s user 3.30s system 95% cpu 16.655 total
log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.45s user 3.54s system 94% cpu 16.881 total
log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.62s user 3.38s system 93% cpu 17.187 total
log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.70s user 3.20s system 92% cpu 17.219 total
log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.48s user 3.31s system 86% cpu 18.345 total
log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.89s user 3.35s system 86% cpu 18.730 total
log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.84s user 3.41s system 86% cpu 18.820 total
log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.63s user 3.23s system 84% cpu 18.831 total
log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.76s user 3.41s system 84% cpu 19.026 total
log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.72s user 3.29s system 86% cpu 18.597 total

log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.71s system 9% cpu 19.019 total
log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.77s system 9% cpu 19.053 total
log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.79s system 9% cpu 19.238 total
log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.80s system 9% cpu 19.227 total
log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.76s system 9% cpu 19.439 total
log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.65s system 8% cpu 20.518 total
log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.73s system 8% cpu 20.693 total
log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.78s system 8% cpu 20.745 total
log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.72s system 8% cpu 20.369 total
log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.74s system 8% cpu 20.682 total
log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.74s system 8% cpu 20.593 total

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
