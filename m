Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3927A6B00C1
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 06:17:03 -0400 (EDT)
Message-ID: <4B9F5A96.1040705@redhat.com>
Date: Tue, 16 Mar 2010 12:16:54 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9F4CBD.3020805@redhat.com> <4B9F5556.7060103@redhat.com>
In-Reply-To: <4B9F5556.7060103@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Kevin Wolf <kwolf@redhat.com>
Cc: Chris Webb <chris@arachsys.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

On 03/16/2010 11:54 AM, Kevin Wolf wrote:
>
>> Is this with qcow2, raw file, or direct volume access?
>>
>> I can understand it for qcow2, but for direct volume access this
>> shouldn't happen.  The guest schedules as many writes as it can,
>> followed by a sync.  The host (and disk) can then reschedule them
>> whether they are in the writeback cache or in the block layer, and must
>> sync in the same way once completed.
>>
>> Perhaps what we need is bdrv_aio_submit() which can take a number of
>> requests.  For direct volume access, this allows easier reordering
>> (io_submit() should plug the queues before it starts processing and
>> unplug them when done, though I don't see the code for this?).  For
>> qcow2, we can coalesce metadata updates for multiple requests into one
>> RMW (for example, a sequential write split into multiple 64K-256K write
>> requests).
>>      
> We already do merge sequential writes back into one larger request. So
> this is in fact a case that wouldn't benefit from such changes.

I'm not happy with that.  It increases overall latency.  With qcow2 it's 
fine, but I'd let requests to raw volumes flow unaltered.

> It may
> help for other cases. But even if it did, coalescing metadata writes in
> qcow2 sounds like a good way to mess up, so I'd stay with doing it only
> for the data itself.
>    

I don't see why.

> Apart from that, wouldn't your points apply to writeback as well?
>    

They do, but for writeback the host kernel already does all the 
coalescing/merging/blah for us.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
