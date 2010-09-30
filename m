Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4C7346B0047
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 19:29:03 -0400 (EDT)
Date: Fri, 1 Oct 2010 01:27:59 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: block cache replacement strategy?
Message-ID: <20100930232758.GI3573@quack.suse.cz>
References: <20100907133429.GB3430@sig21.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100907133429.GB3430@sig21.net>
Sender: owner-linux-mm@kvack.org
To: Johannes Stezenbach <js@sig21.net>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

  Hi,

On Tue 07-09-10 15:34:29, Johannes Stezenbach wrote:
> during some simple disk read throughput testing I observed
> caching behaviour that doesn't seem right.  The machine
> has 2G of RAM and AMD Athlon 4850e, x86_64 kernel but 32bit
> userspace, Linux 2.6.35.4.  It seems that contents of the
> block cache are not evicted to make room for other blocks.
> (Or something like that, I have no real clue about this.)
> 
> Since this is a rather artificial test I'm not too worried,
> but it looks strange to me so I thought I better report it.
> 
> 
> zzz:~# echo 3 >/proc/sys/vm/drop_caches 
> zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
> 1000+0 records in
> 1000+0 records out
> 1048576000 bytes (1.0 GB) copied, 13.9454 s, 75.2 MB/s
> zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
> 1000+0 records in
> 1000+0 records out
> 1048576000 bytes (1.0 GB) copied, 0.92799 s, 1.1 GB/s
> 
> OK, seems like the blocks are cached. But:
> 
> zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000 skip=1000
> 1000+0 records in
> 1000+0 records out
> 1048576000 bytes (1.0 GB) copied, 13.8375 s, 75.8 MB/s
> zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000 skip=1000
> 1000+0 records in
> 1000+0 records out
> 1048576000 bytes (1.0 GB) copied, 13.8429 s, 75.7 MB/s
  I took a look at this because it looked strange at the first sight to me.
After some code reading the result is that everything is working as
designed.
  The first dd fills up memory with 1GB of data. Pages with data just freshly
read from disk are in "Inactive" state. When these pages are read again by
the second dd, they move into the "Active" state - caching has proved
useful and thus we value the data more. When the third dd is run, it
eventually needs to reclaim some pages to cache new data. System preferably
reclaims "Inactive" pages and since it has plenty of them - all the data
the third dd has read so far - it succeeds. Thus when a third dd finishes,
only a small part of the whole 1 GB chunk is in memory since we continually
reclaimed pages from it.
  Active pages would start becoming inactive only when there would be too
many of them (e.g. when there would be more active pages than inactive
pages). But that does not happen with your workload... I guess this
explains it.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
