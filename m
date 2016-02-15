Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE6A6B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 18:52:33 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id gc3so133195210obb.3
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 15:52:33 -0800 (PST)
Received: from rcdn-iport-8.cisco.com (rcdn-iport-8.cisco.com. [173.37.86.79])
        by mx.google.com with ESMTPS id j138si19658701oih.51.2016.02.15.15.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 15:52:32 -0800 (PST)
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
 <20160214211856.GT19486@dastard> <56C216CA.7000703@cisco.com>
 <20160215230511.GU19486@dastard>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <56C264BF.3090100@cisco.com>
Date: Mon, 15 Feb 2016 15:52:31 -0800
MIME-Version: 1.0
In-Reply-To: <20160215230511.GU19486@dastard>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Khalid Mughal <khalidm@cisco.com>, xe-kernel@external.cisco.com, dave.hansen@intel.com, hannes@cmpxchg.org, riel@redhat.com, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Nag Avadhanam (nag)" <nag@cisco.com>

On 02/15/2016 03:05 PM, Dave Chinner wrote:
> On Mon, Feb 15, 2016 at 10:19:54AM -0800, Daniel Walker wrote:
>> On 02/14/2016 01:18 PM, Dave Chinner wrote:
>>> On Fri, Feb 12, 2016 at 12:14:39PM -0800, Daniel Walker wrote:
>>>> From: Khalid Mughal <khalidm@cisco.com>
>>>>
>>>> Currently there is no way to figure out the droppable pagecache size
>>> >from the meminfo output. The MemFree size can shrink during normal
>>>> system operation, when some of the memory pages get cached and is
>>>> reflected in "Cached" field. Similarly for file operations some of
>>>> the buffer memory gets cached and it is reflected in "Buffers" field.
>>>> The kernel automatically reclaims all this cached & buffered memory,
>>>> when it is needed elsewhere on the system. The only way to manually
>>>> reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. But
>>>> this can have performance impact. Since it discards cached objects,
>>>> it may cause high CPU & I/O utilization to recreate the dropped
>>>> objects during heavy system load.
>>>> This patch computes the droppable pagecache count, using same
>>>> algorithm as "vm/drop_caches". It is non-destructive and does not
>>>> drop any pages. Therefore it does not have any impact on system
>>>> performance. The computation does not include the size of
>>>> reclaimable slab.
>>> Why, exactly, do you need this? You've described what the patch
>>> does (i.e. redundant, because we can read the code), and described
>>> that the kernel already accounts this reclaimable memory elsewhere
>>> and you can already read that and infer the amount of reclaimable
>>> memory from it. So why isn't that accounting sufficient?
>> We need it to determine accurately what the free memory in the
>> system is. If you know where we can get this information already
>> please tell, we aren't aware of it. For instance /proc/meminfo isn't
>> accurate enough.
> What you are proposing isn't accurate, either, because it will be
> stale by the time the inode cache traversal is completed and the
> count returned to userspace. e.g. pages that have already been
> accounted as droppable can be reclaimed or marked dirty and hence
> "unreclaimable".
>
> IOWs, the best you are going to get is an approximate point-in-time
> indication of how much memory is available for immediate reclaim.
> We're never going to get an accurate measure in userspace unless we
> accurately account for it in the kernel itself. Which, I think it
> has already been pointed out, is prohibitively expensive so isn't
> done.
>
> As for a replacement, looking at what pages you consider "droppable"
> is really only file pages that are not under dirty or under
> writeback. i.e. from /proc/meminfo:
>
> Active(file):     220128 kB
> Inactive(file):    60232 kB
> Dirty:                 0 kB
> Writeback:             0 kB
>
> i.e. reclaimable file cache = Active + inactive - dirty - writeback.
>
> And while you are there, when you drop slab caches:
>
> SReclaimable:      66632 kB
>
> some amount of that may be freed. No guarantees can be made about
> the amount, though.

I got this response from another engineer here at Cisco (Nag he's CC'd 
also),

"

Approximate point-in-time indication is an accurate characterization of what we are doing. This is good enough for us. NO matter what we do, we are never going to be able to address the "time of check to time of use? window.  But, this approximation works reasonably well for our use case.

As to his other suggestion of estimating the droppable cache, I have considered it but found it unusable. The problem is the inactive file pages count a whole lot pages more than the droppable pages.

See the value of these, before and [after] dropping reclaimable pages.

Before:

Active(file):     183488 kB
Inactive(file):   180504 kB

After (the drop caches):
Active(file):      89468 kB
Inactive(file):    32016 kB

The dirty and the write back are mostly 0KB under our workload as we are 
mostly dealing with the readonly file pages of binaries 
(programs/libraries)..
"


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
