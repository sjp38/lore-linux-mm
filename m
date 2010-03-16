Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C20446B00CC
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 06:26:52 -0400 (EDT)
Date: Tue, 16 Mar 2010 11:26:37 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
Message-ID: <20100316102637.GA23584@lst.de>
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9F4CBD.3020805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B9F4CBD.3020805@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Chris Webb <chris@arachsys.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Kevin Wolf <kwolf@redhat.com>
List-ID: <linux-mm.kvack.org>

Avi,

cache=writeback can be faster than cache=none for the same reasons
a disk cache speeds up access.  As long as the I/O mix contains more
asynchronous then synchronous writes it allows the host to do much
more reordering, only limited by the cache size (which can be quite
huge when using the host pagecache) and the amount of cache flushes
coming from the host.  If you have a fsync heavy workload or metadata
operation with a filesystem like the current XFS you will get lots
of cache flushes that make the use of the additional cache limits.

If you don't have a of lot of cache flushes, e.g. due to dumb
applications that do not issue fsync, or even run ext3 in it's default
mode never issues cache flushes the benefit will be enormous, but the
data loss and possible corruption will be enormous.

But even for something like btrfs that does provide data integrity
but issues cache flushes fairly effeciently data=writeback may
provide a quite nice speedup, especially if using multiple guest
accessing the same spindle(s).

But I wouldn't be surprised if IBM's exteme differences are indeed due
to the extremly unsafe ext3 default behaviour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
