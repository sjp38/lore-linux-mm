Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ABBDB6B0116
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:40:38 -0400 (EDT)
Message-ID: <4BA105FE.2000607@redhat.com>
Date: Wed, 17 Mar 2010 18:40:30 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9F4CBD.3020805@redhat.com> <20100317152452.GZ31148@arachsys.com> <4BA101C5.9040406@redhat.com>
In-Reply-To: <4BA101C5.9040406@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Kevin Wolf <kwolf@redhat.com>
List-ID: <linux-mm.kvack.org>

On 03/17/2010 06:22 PM, Avi Kivity wrote:
>> Also, if my guest kernel issues (say) three small writes, one at the 
>> start
>> of the disk, one in the middle, one at the end, and then does a 
>> flush, can
>> virtio really express this as one non-contiguous O_DIRECT write (the 
>> three
>> components of which can be reordered by the elevator with respect to one
>> another) rather than three distinct O_DIRECT writes which can't be 
>> permuted?
>> Can qemu issue a write like that? cache=writeback + flush allows this 
>> to be
>> optimised by the block layer in the normal way.
>
>
> Guest side virtio will send this as three requests followed by a 
> flush.  Qemu will issue these as three distinct requests and then 
> flush.  The requests are marked, as Christoph says, in a way that 
> limits their reorderability, and perhaps if we fix these two problems 
> performance will improve.
>
> Something that comes to mind is merging of flush requests.  If N 
> guests issue one write and one flush each, we should issue N writes 
> and just one flush - a flush for the disk applies to all volumes on 
> that disk.
>

Chris, can you carry out an experiment?  Write a program that pwrite()s 
a byte to a file at the same location repeatedly, with the file opened 
using O_SYNC.  Measure the write rate, and run blktrace on the host to 
see what the disk (/dev/sda, not the volume) sees.  Should be a (write, 
flush, write, flush) per pwrite pattern or similar (for writing the data 
and a journal block, perhaps even three writes will be needed).

Then scale this across multiple guests, measure and trace again.  If 
we're lucky, the flushes will be coalesced, if not, we need to work on it.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
