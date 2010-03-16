Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 03A736B0085
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 06:44:33 -0400 (EDT)
Date: Tue, 16 Mar 2010 11:44:22 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
Message-ID: <20100316104422.GA24258@lst.de>
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9F4CBD.3020805@redhat.com> <20100316102637.GA23584@lst.de> <4B9F5F2F.8020501@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B9F5F2F.8020501@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Chris Webb <chris@arachsys.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kevin Wolf <kwolf@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 16, 2010 at 12:36:31PM +0200, Avi Kivity wrote:
> Are you talking about direct volume access or qcow2?

Doesn't matter.

> For direct volume access, I still don't get it.  The number of barriers 
> issues by the host must equal (or exceed, but that's pointless) the 
> number of barriers issued by the guest.  cache=writeback allows the host 
> to reorder writes, but so does cache=none.  Where does the difference 
> come from?
> 
> Put it another way.  In an unvirtualized environment, if you implement a 
> write cache in a storage driver (not device), and sync it on a barrier 
> request, would you expect to see a performance improvement?

cache=none only allows very limited reorderning in the host.  O_DIRECT
is synchronous on the host, so there's just some very limited reordering
going on in the elevator if we have other I/O going on in parallel.
In addition to that the disk writecache can perform limited reodering
and caching, but the disk cache has a rather limited size.  The host
pagecache gives a much wieder opportunity to reorder, especially if
the guest workload is not cache flush heavy.  If the guest workload
is extremly cache flush heavy the usefulness of the pagecache is rather
limited, as we'll only use very little of it, but pay by having to do
a data copy.  If the workload is not cache flush heavy, and we have
multiple guests doing I/O to the same spindles it will allow the host
do do much more efficient data writeout by beeing able to do better
ordered (less seeky) and bigger I/O (especially if the host has real
storage compared to ide for the guest).

> >If you don't have a of lot of cache flushes, e.g. due to dumb
> >applications that do not issue fsync, or even run ext3 in it's default
> >mode never issues cache flushes the benefit will be enormous, but the
> >data loss and possible corruption will be enormous.
> >   
> 
> Shouldn't the host never issue cache flushes in this case? (for direct 
> volume access; qcow2 still needs flushes for metadata integrity).

If the guest never issues a flush the host will neither, indeed.  Data
will only go to disk by background writeout or memory pressure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
