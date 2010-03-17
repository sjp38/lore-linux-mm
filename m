Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 47ABB6B01B3
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:25:09 -0400 (EDT)
Date: Wed, 17 Mar 2010 15:24:53 +0000
From: Chris Webb <chris@arachsys.com>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot
 parameter
Message-ID: <20100317152452.GZ31148@arachsys.com>
References: <20100315072214.GA18054@balbir.in.ibm.com>
 <4B9DE635.8030208@redhat.com>
 <20100315080726.GB18054@balbir.in.ibm.com>
 <4B9DEF81.6020802@redhat.com>
 <20100315202353.GJ3840@arachsys.com>
 <4B9F4CBD.3020805@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B9F4CBD.3020805@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Kevin Wolf <kwolf@redhat.com>
List-ID: <linux-mm.kvack.org>

Avi Kivity <avi@redhat.com> writes:

> On 03/15/2010 10:23 PM, Chris Webb wrote:
>
> >Wasteful duplication of page cache between guest and host notwithstanding,
> >turning on cache=writeback is a spectacular performance win for our guests.
> 
> Is this with qcow2, raw file, or direct volume access?

This is with direct access to logical volumes. No file systems or qcow2 in
the stack. Our typical host has a couple of SATA disks, combined in md
RAID1, chopped up into volumes with LVM2 (really just dm linear targets).
The performance measured outside qemu is excellent, inside qemu-kvm is fine
too until multiple guests are trying to access their drives at once, but
then everything starts to grind badly.

> I can understand it for qcow2, but for direct volume access this
> shouldn't happen.  The guest schedules as many writes as it can,
> followed by a sync.  The host (and disk) can then reschedule them
> whether they are in the writeback cache or in the block layer, and
> must sync in the same way once completed.

I don't really understand what's going on here, but I wonder if the
underlying problem might be that all the O_DIRECT/O_SYNC writes from the
guests go down into the same block device at the bottom of the device mapper
stack, and thus can't be reordered with respect to one another. For our
purposes,

  Guest AA   Guest BB       Guest AA   Guest BB       Guest AA   Guest BB
  write A1                  write A1                             write B1
             write B1       write A2                  write A1
  write A2                             write B1       write A2

are all equivalent, but the system isn't allowed to reorder in this way
because there isn't a separate request queue for each logical volume, just
the one at the bottom. (I don't know whether nested request queues would
behave remotely reasonably either, though!)

Also, if my guest kernel issues (say) three small writes, one at the start
of the disk, one in the middle, one at the end, and then does a flush, can
virtio really express this as one non-contiguous O_DIRECT write (the three
components of which can be reordered by the elevator with respect to one
another) rather than three distinct O_DIRECT writes which can't be permuted?
Can qemu issue a write like that? cache=writeback + flush allows this to be
optimised by the block layer in the normal way.

Cheers,

Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
