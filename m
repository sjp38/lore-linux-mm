Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D14DD6B012C
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:15:06 -0400 (EDT)
Date: Wed, 17 Mar 2010 15:14:10 +0000
From: Chris Webb <chris@arachsys.com>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot
 parameter
Message-ID: <20100317151409.GY31148@arachsys.com>
References: <20100315072214.GA18054@balbir.in.ibm.com>
 <4B9DE635.8030208@redhat.com>
 <20100315080726.GB18054@balbir.in.ibm.com>
 <4B9DEF81.6020802@redhat.com>
 <20100315202353.GJ3840@arachsys.com>
 <4B9EC60A.2070101@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B9EC60A.2070101@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Avi Kivity <avi@redhat.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Anthony Liguori <anthony@codemonkey.ws> writes:

> This really gets down to your definition of "safe" behaviour.  As it
> stands, if you suffer a power outage, it may lead to guest
> corruption.
> 
> While we are correct in advertising a write-cache, write-caches are
> volatile and should a drive lose power, it could lead to data
> corruption.  Enterprise disks tend to have battery backed write
> caches to prevent this.
> 
> In the set up you're emulating, the host is acting as a giant write
> cache.  Should your host fail, you can get data corruption.

Hi Anthony. I suspected my post might spark an interesting discussion!

Before considering anything like this, we did quite a bit of testing with
OSes in qemu-kvm guests running filesystem-intensive work, using an ipmitool
power off to kill the host. I didn't manage to corrupt any ext3, ext4 or
NTFS filesystems despite these efforts.

Is your claim here that:-

  (a) qemu doesn't emulate a disk write cache correctly; or

  (b) operating systems are inherently unsafe running on top of a disk with
      a write-cache; or

  (c) installations that are already broken and lose data with a physical
      drive with a write-cache can lose much more in this case because the
      write cache is much bigger?

Following Christoph Hellwig's patch series from last September, I'm pretty
convinced that (a) isn't true apart from the inability to disable the
write-cache at run-time, which is something that neither recent linux nor
windows seem to want to do out-of-the box.

Given that modern SATA drives come with fairly substantial write-caches
nowadays which operating systems leave on without widespread disaster, I
don't really believe in (b) either, at least for the ide and scsi case.
Filesystems know they have to flush the disk cache to avoid corruption.
(Virtio makes the write cache invisible to the OS except in linux 2.6.32+ so
I know virtio-blk has to be avoided for current windows and obsolete linux
when writeback caching is on.)

I can certainly imagine (c) might be the case, although when I use strace to
watch the IO to the block device, I see pretty regular fdatasyncs being
issued by the guests, interleaved with the writes, so I'm not sure how
likely the problem would be in practice. Perhaps my test guests were
unrepresentatively well-behaved.

However, the potentially unlimited time-window for loss of incorrectly
unsynced data is also something one could imagine fixing at the qemu level.
Perhaps I should be implementing something like
cache=writeback,flushtimeout=N which, upon a write being issued to the block
device, starts an N second timer if it isn't already running. The timer is
destroyed on flush, and if it expires before it's destroyed, a gratuitous
flush is sent. Do you think this is worth doing? Just a simple 'while sleep
10; do sync; done' on the host even!

We've used cache=none and cache=writethrough, and whilst performance is fine
with a single guest accessing a disk, when we chop the disks up with LVM and
run a even a small handful of guests, the constant seeking to serve tiny
synchronous IOs leads to truly abysmal throughput---we've seen less than
700kB/s streaming write rates within guests when the backing store is
capable of 100MB/s.

With cache=writeback, there's still IO contention between guests, but the
write granularity is a bit coarser, so the host's elevator seems to get a
bit more of a chance to help us out and we can at least squeeze out 5-10MB/s
from two or three concurrently running guests, getting a total of 20-30% of
the performance of the underlying block device rather than a total of around
5%.

Cheers,

Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
