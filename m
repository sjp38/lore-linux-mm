Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CDE006B00AD
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 04:19:39 -0400 (EDT)
Date: Tue, 16 Mar 2010 04:19:19 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot
	parameter
Message-ID: <20100316081919.GA4258@infradead.org>
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9EC60A.2070101@codemonkey.ws> <20100316004307.GA19470@infradead.org> <4B9EDE7D.4040809@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B9EDE7D.4040809@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Christoph Hellwig <hch@infradead.org>, Chris Webb <chris@arachsys.com>, Avi Kivity <avi@redhat.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 08:27:25PM -0500, Anthony Liguori wrote:
>> Actually cache=writeback is as safe as any normal host is with a
>> volatile disk cache, except that in this case the disk cache is
>> actually a lot larger.  With a properly implemented filesystem this
>> will never cause corruption.
>
> Metadata corruption, not necessarily corruption of data stored in a file.

Again, this will not cause metadata corruption either if the filesystem
loses barriers, although we may lose up to the cache size of new (data
or metadata operations).  The consistency of the filesystem is still
guaranteed.

> Not all software uses fsync as much as they should.  And often times,  
> it's for good reason (like ext3).

If an application needs data on disk it must call fsync, or there
is no guaranteed at all, even on ext3.  And with growing disk caches
these issues show up on normal disks often enough that people have
realized it by now.


> IIUC, an O_DIRECT write using cache=writeback is not actually on the  
> spindle when the write() completes.  Rather, an explicit fsync() would  
> be required.  That will cause data corruption in many applications (like  
> databases) regardless of whether the fs gets metadata corruption.

It's neither for O_DIRECT without qemu involved.  The O_DIRECT write
goes through the disk cache and requires and explicit fsync or O_SYNC
open flag to make sure it goes to disk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
