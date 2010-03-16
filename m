Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A8F2E6B0089
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 06:36:39 -0400 (EDT)
Message-ID: <4B9F5F2F.8020501@redhat.com>
Date: Tue, 16 Mar 2010 12:36:31 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9F4CBD.3020805@redhat.com> <20100316102637.GA23584@lst.de>
In-Reply-To: <20100316102637.GA23584@lst.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: Chris Webb <chris@arachsys.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kevin Wolf <kwolf@redhat.com>
List-ID: <linux-mm.kvack.org>

On 03/16/2010 12:26 PM, Christoph Hellwig wrote:
> Avi,
>
> cache=writeback can be faster than cache=none for the same reasons
> a disk cache speeds up access.  As long as the I/O mix contains more
> asynchronous then synchronous writes it allows the host to do much
> more reordering, only limited by the cache size (which can be quite
> huge when using the host pagecache) and the amount of cache flushes
> coming from the host.  If you have a fsync heavy workload or metadata
> operation with a filesystem like the current XFS you will get lots
> of cache flushes that make the use of the additional cache limits.
>    

Are you talking about direct volume access or qcow2?

For direct volume access, I still don't get it.  The number of barriers 
issues by the host must equal (or exceed, but that's pointless) the 
number of barriers issued by the guest.  cache=writeback allows the host 
to reorder writes, but so does cache=none.  Where does the difference 
come from?

Put it another way.  In an unvirtualized environment, if you implement a 
write cache in a storage driver (not device), and sync it on a barrier 
request, would you expect to see a performance improvement?


> If you don't have a of lot of cache flushes, e.g. due to dumb
> applications that do not issue fsync, or even run ext3 in it's default
> mode never issues cache flushes the benefit will be enormous, but the
> data loss and possible corruption will be enormous.
>    

Shouldn't the host never issue cache flushes in this case? (for direct 
volume access; qcow2 still needs flushes for metadata integrity).

> But even for something like btrfs that does provide data integrity
> but issues cache flushes fairly effeciently data=writeback may
> provide a quite nice speedup, especially if using multiple guest
> accessing the same spindle(s).
>
> But I wouldn't be surprised if IBM's exteme differences are indeed due
> to the extremly unsafe ext3 default behaviour.
>    


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
