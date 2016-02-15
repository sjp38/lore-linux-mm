Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4304F6B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 13:19:57 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id jq7so38790411obb.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 10:19:57 -0800 (PST)
Received: from rcdn-iport-1.cisco.com (rcdn-iport-1.cisco.com. [173.37.86.72])
        by mx.google.com with ESMTPS id v16si18471727oif.13.2016.02.15.10.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 10:19:56 -0800 (PST)
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
 <20160214211856.GT19486@dastard>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <56C216CA.7000703@cisco.com>
Date: Mon, 15 Feb 2016 10:19:54 -0800
MIME-Version: 1.0
In-Reply-To: <20160214211856.GT19486@dastard>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Khalid Mughal <khalidm@cisco.com>, xe-kernel@external.cisco.com, dave.hansen@intel.com, hannes@cmpxchg.org, riel@redhat.com, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 02/14/2016 01:18 PM, Dave Chinner wrote:
> On Fri, Feb 12, 2016 at 12:14:39PM -0800, Daniel Walker wrote:
>> From: Khalid Mughal <khalidm@cisco.com>
>>
>> Currently there is no way to figure out the droppable pagecache size
>> from the meminfo output. The MemFree size can shrink during normal
>> system operation, when some of the memory pages get cached and is
>> reflected in "Cached" field. Similarly for file operations some of
>> the buffer memory gets cached and it is reflected in "Buffers" field.
>> The kernel automatically reclaims all this cached & buffered memory,
>> when it is needed elsewhere on the system. The only way to manually
>> reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. But
>> this can have performance impact. Since it discards cached objects,
>> it may cause high CPU & I/O utilization to recreate the dropped
>> objects during heavy system load.
>> This patch computes the droppable pagecache count, using same
>> algorithm as "vm/drop_caches". It is non-destructive and does not
>> drop any pages. Therefore it does not have any impact on system
>> performance. The computation does not include the size of
>> reclaimable slab.
> Why, exactly, do you need this? You've described what the patch
> does (i.e. redundant, because we can read the code), and described
> that the kernel already accounts this reclaimable memory elsewhere
> and you can already read that and infer the amount of reclaimable
> memory from it. So why isn't that accounting sufficient?

We need it to determine accurately what the free memory in the system 
is. If you know where we can get this information already please tell, 
we aren't aware of it. For instance /proc/meminfo isn't accurate enough.

> As to the code, I think it is a horrible hack - the calculation
> does not come for free. Forcing iteration all the inodes in the
> inode cache is not something we should allow users to do - what's to
> stop someone just doing this 100 times in parallel and DOSing the
> machine?

Yes it is costly.

>
> Or what happens when someone does 'grep "" /proc/sys/vm/*" to see
> what all the VM settings are on a machine with a couple of TB of
> page cache spread across a couple of hundred million cached inodes?
> It a) takes a long time, b) adds sustained load to an already
> contended lock (sb->s_inode_list_lock), and c) isn't configuration
> information.
>

We could make it "echo 4 > /proc/sys/vm/drop_cache" then you "cat 
/proc/sys/vm/drop_cache_count" that would make the person executing the 
command responsible for the latency. So grep wouldn't trigger it.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
