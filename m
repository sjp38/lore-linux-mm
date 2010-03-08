Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7209A6B0083
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 02:33:27 -0500 (EST)
Message-ID: <4B94A842.9010902@panasas.com>
Date: Mon, 08 Mar 2010 09:33:22 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: [LSF/VM TOPIC] Dynamic sizing of dirty_limit
References: <20100224143442.GF3687@quack.suse.cz> <alpine.DEB.2.00.1002241007220.27592@router.home>
In-Reply-To: <alpine.DEB.2.00.1002241007220.27592@router.home>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, lsf10-pc@lists.linuxfoundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/24/2010 06:10 PM, Christoph Lameter wrote:
> On Wed, 24 Feb 2010, Jan Kara wrote:
> 
>> fine (and you probably don't want much more because the memory is better
>> used for something else), when a machine does random rewrites, going to 40%
>> might be well worth it. So I'd like to discuss how we could measure that
>> increasing amount of dirtiable memory helps so that we could implement
>> dynamic sizing of it.
> 
> Another issue around dirty limits is that they are global. If you are
> running multiple jobs on the same box (memcg or cpusets or you set
> affinities to separate the box) then every job may need different dirty
> limits. One idea that I had in the past was to set dirty limits based on
> nodes or cpusets. But that will not cover the other cases that I have
> listed above.
> 
> The best solution would be an algorithm that can accomodate multiple loads
> and manage the amount of dirty memory automatically.
> 

One more point to consider if changes are made (and should) in this area is:
	The stacking filesystems problem.
There are many examples, here is just a simple one. A local iscsi-target backed
by a file an a filesystem, is logged into from local host, the created block device
is mounted by a filesystem. Such a setup used to dead-lock before and has very poor
dribbling performance today. This is because the upper-layer filesystem consumes all
cache quota and leaves no available cache headroom for the lower-level FS, causing
the lower-level FS a page by page write-out (at best). For example mounting such a
scenario through a UML or VM will solve this problem and will preform optimally.
(The iscsi-initiator + upper FS is inside the UML).
There are endless examples of stacking filesystem examples, including NFS local mounts,
clustered setup with local access to one of the devices, and so on. All these preform
badly.

A per-FS cache limit, (proportional to performance, cache is optimally measured by
a time constant), should easily solve this problem as well.

Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
