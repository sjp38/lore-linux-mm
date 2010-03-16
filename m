Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A34686B00B5
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 05:55:19 -0400 (EDT)
Message-ID: <4B9F5556.7060103@redhat.com>
Date: Tue, 16 Mar 2010 10:54:30 +0100
From: Kevin Wolf <kwolf@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9F4CBD.3020805@redhat.com>
In-Reply-To: <4B9F4CBD.3020805@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Chris Webb <chris@arachsys.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

Am 16.03.2010 10:17, schrieb Avi Kivity:
> On 03/15/2010 10:23 PM, Chris Webb wrote:
>> Avi Kivity<avi@redhat.com>  writes:
>>
>>    
>>> On 03/15/2010 10:07 AM, Balbir Singh wrote:
>>>
>>>      
>>>> Yes, it is a virtio call away, but is the cost of paying twice in
>>>> terms of memory acceptable?
>>>>        
>>> Usually, it isn't, which is why I recommend cache=off.
>>>      
>> Hi Avi. One observation about your recommendation for cache=none:
>>
>> We run hosts of VMs accessing drives backed by logical volumes carved out
>> from md RAID1. Each host has 32GB RAM and eight cores, divided between (say)
>> twenty virtual machines, which pretty much fill the available memory on the
>> host. Our qemu-kvm is new enough that IDE and SCSI drives with writeback
>> caching turned on get advertised to the guest as having a write-cache, and
>> FLUSH gets translated to fsync() by qemu. (Consequently cache=writeback
>> isn't acting as cache=neverflush like it would have done a year ago. I know
>> that comparing performance for cache=none against that unsafe behaviour
>> would be somewhat unfair!)
>>
>> Wasteful duplication of page cache between guest and host notwithstanding,
>> turning on cache=writeback is a spectacular performance win for our guests.
>> For example, even IDE with cache=writeback easily beats virtio with
>> cache=none in most of the guest filesystem performance tests I've tried. The
>> anecdotal feedback from clients is also very strongly in favour of
>> cache=writeback.
>>    
> 
> Is this with qcow2, raw file, or direct volume access?
> 
> I can understand it for qcow2, but for direct volume access this 
> shouldn't happen.  The guest schedules as many writes as it can, 
> followed by a sync.  The host (and disk) can then reschedule them 
> whether they are in the writeback cache or in the block layer, and must 
> sync in the same way once completed.
> 
> Perhaps what we need is bdrv_aio_submit() which can take a number of 
> requests.  For direct volume access, this allows easier reordering 
> (io_submit() should plug the queues before it starts processing and 
> unplug them when done, though I don't see the code for this?).  For 
> qcow2, we can coalesce metadata updates for multiple requests into one 
> RMW (for example, a sequential write split into multiple 64K-256K write 
> requests).

We already do merge sequential writes back into one larger request. So
this is in fact a case that wouldn't benefit from such changes. It may
help for other cases. But even if it did, coalescing metadata writes in
qcow2 sounds like a good way to mess up, so I'd stay with doing it only
for the data itself.

Apart from that, wouldn't your points apply to writeback as well?

Kevin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
