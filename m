Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 60DB96B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 09:05:51 -0400 (EDT)
Date: Fri, 1 Oct 2010 15:05:28 +0200
From: Johannes Stezenbach <js@sig21.net>
Subject: Re: block cache replacement strategy?
Message-ID: <20101001130528.GA28723@sig21.net>
References: <20100907133429.GB3430@sig21.net>
 <20100930232758.GI3573@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100930232758.GI3573@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Oct 01, 2010 at 01:27:59AM +0200, Jan Kara wrote:
> On Tue 07-09-10 15:34:29, Johannes Stezenbach wrote:
> > 
> > zzz:~# echo 3 >/proc/sys/vm/drop_caches 
> > zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
> > 1000+0 records in
> > 1000+0 records out
> > 1048576000 bytes (1.0 GB) copied, 13.9454 s, 75.2 MB/s
> > zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
> > 1000+0 records in
> > 1000+0 records out
> > 1048576000 bytes (1.0 GB) copied, 0.92799 s, 1.1 GB/s
> > 
> > OK, seems like the blocks are cached. But:
> > 
> > zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000 skip=1000
> > 1000+0 records in
> > 1000+0 records out
> > 1048576000 bytes (1.0 GB) copied, 13.8375 s, 75.8 MB/s
> > zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000 skip=1000
> > 1000+0 records in
> > 1000+0 records out
> > 1048576000 bytes (1.0 GB) copied, 13.8429 s, 75.7 MB/s
>   I took a look at this because it looked strange at the first sight to me.
> After some code reading the result is that everything is working as
> designed.
>   The first dd fills up memory with 1GB of data. Pages with data just freshly
> read from disk are in "Inactive" state. When these pages are read again by
> the second dd, they move into the "Active" state - caching has proved
> useful and thus we value the data more. When the third dd is run, it
> eventually needs to reclaim some pages to cache new data. System preferably
> reclaims "Inactive" pages and since it has plenty of them - all the data
> the third dd has read so far - it succeeds. Thus when a third dd finishes,
> only a small part of the whole 1 GB chunk is in memory since we continually
> reclaimed pages from it.
>   Active pages would start becoming inactive only when there would be too
> many of them (e.g. when there would be more active pages than inactive
> pages). But that does not happen with your workload... I guess this
> explains it.

Thank you for your comments, I see now how it works.

What you snipped from my post:

> > Even if I let 15min pass and repeat the dd command
> > several times, I cannot see any caching effects, it
> > stays at ~75 MB/s.
...
> > Active:           792720 kB
> > Inactive:         758832 kB

So with my new knowledge I tried to run dd with a smaller data set
to get new data on the Active pages list:

zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=680 skip=1000
680+0 records in
680+0 records out
713031680 bytes (713 MB) copied, 9.8105 s, 72.7 MB/s
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=680 skip=1000
680+0 records in
680+0 records out
713031680 bytes (713 MB) copied, 0.676862 s, 1.1 GB/s

zzz:~# cat /proc/meminfo 
MemTotal:        1793272 kB
MemFree:           15788 kB
Buffers:         1379332 kB
Cached:            14084 kB
SwapCached:        19516 kB
Active:          1493748 kB
Inactive:          45928 kB
Active(anon):     106416 kB
Inactive(anon):    42456 kB
Active(file):    1387332 kB
Inactive(file):     3472 kB

zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000 skip=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 5.09198 s, 206 MB/s
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000 skip=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 1.63369 s, 642 MB/s
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000 skip=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 0.892916 s, 1.2 GB/s


Yippie!

BTW, it seems this has nothing to do with sequential read, and my
earlier testing with lmdd was flawed since lmdd uses 1M = 1000000
and 1m = 1048576, thus my test read overlapping blocks and the
resulting data set was smaller than the number of inactive pages.
A correct test with lmdd would use

  lmdd if=some_large_file_or_blockdev bs=1m count=1024 rand=5g norepeat=
  lmdd if=some_large_file_or_blockdev bs=1m count=1024 rand=5g norepeat= start=5g

and shows the same caching behaviour (on a machine with 2G RAM).


Thanks
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
