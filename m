Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 511B36B0203
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 20:43:36 -0400 (EDT)
Date: Mon, 15 Mar 2010 20:43:07 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot
	parameter
Message-ID: <20100316004307.GA19470@infradead.org>
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9EC60A.2070101@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B9EC60A.2070101@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Chris Webb <chris@arachsys.com>, Avi Kivity <avi@redhat.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 06:43:06PM -0500, Anthony Liguori wrote:
> I knew someone would do this...
>
> This really gets down to your definition of "safe" behaviour.  As it  
> stands, if you suffer a power outage, it may lead to guest corruption.
>
> While we are correct in advertising a write-cache, write-caches are  
> volatile and should a drive lose power, it could lead to data  
> corruption.  Enterprise disks tend to have battery backed write caches  
> to prevent this.
>
> In the set up you're emulating, the host is acting as a giant write  
> cache.  Should your host fail, you can get data corruption.
>
> cache=writethrough provides a much stronger data guarantee.  Even in the  
> event of a host failure, data integrity will be preserved.

Actually cache=writeback is as safe as any normal host is with a
volatile disk cache, except that in this case the disk cache is
actually a lot larger.  With a properly implemented filesystem this
will never cause corruption.  You will lose recent updates after
the last sync/fsync/etc up to the size of the cache, but filesystem
metadata should never be corrupted, and data that has been forced to
disk using fsync/O_SYNC should never be lost either.  If it is that's
a bug somewhere in the stack, but in my powerfail testing we never did
so using xfs or ext3/4 after I fixed up the fsync code in the latter
two.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
