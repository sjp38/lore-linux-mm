Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 831846B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 18:07:09 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id y8so84938265igp.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 15:07:09 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id u3si46315182iou.71.2016.02.15.15.07.07
        for <linux-mm@kvack.org>;
        Mon, 15 Feb 2016 15:07:08 -0800 (PST)
Date: Tue, 16 Feb 2016 10:05:11 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
Message-ID: <20160215230511.GU19486@dastard>
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
 <20160214211856.GT19486@dastard>
 <56C216CA.7000703@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56C216CA.7000703@cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walker <danielwa@cisco.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Khalid Mughal <khalidm@cisco.com>, xe-kernel@external.cisco.com, dave.hansen@intel.com, hannes@cmpxchg.org, riel@redhat.com, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon, Feb 15, 2016 at 10:19:54AM -0800, Daniel Walker wrote:
> On 02/14/2016 01:18 PM, Dave Chinner wrote:
> >On Fri, Feb 12, 2016 at 12:14:39PM -0800, Daniel Walker wrote:
> >>From: Khalid Mughal <khalidm@cisco.com>
> >>
> >>Currently there is no way to figure out the droppable pagecache size
> >>from the meminfo output. The MemFree size can shrink during normal
> >>system operation, when some of the memory pages get cached and is
> >>reflected in "Cached" field. Similarly for file operations some of
> >>the buffer memory gets cached and it is reflected in "Buffers" field.
> >>The kernel automatically reclaims all this cached & buffered memory,
> >>when it is needed elsewhere on the system. The only way to manually
> >>reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. But
> >>this can have performance impact. Since it discards cached objects,
> >>it may cause high CPU & I/O utilization to recreate the dropped
> >>objects during heavy system load.
> >>This patch computes the droppable pagecache count, using same
> >>algorithm as "vm/drop_caches". It is non-destructive and does not
> >>drop any pages. Therefore it does not have any impact on system
> >>performance. The computation does not include the size of
> >>reclaimable slab.
> >Why, exactly, do you need this? You've described what the patch
> >does (i.e. redundant, because we can read the code), and described
> >that the kernel already accounts this reclaimable memory elsewhere
> >and you can already read that and infer the amount of reclaimable
> >memory from it. So why isn't that accounting sufficient?
> 
> We need it to determine accurately what the free memory in the
> system is. If you know where we can get this information already
> please tell, we aren't aware of it. For instance /proc/meminfo isn't
> accurate enough.

What you are proposing isn't accurate, either, because it will be
stale by the time the inode cache traversal is completed and the
count returned to userspace. e.g. pages that have already been
accounted as droppable can be reclaimed or marked dirty and hence
"unreclaimable".

IOWs, the best you are going to get is an approximate point-in-time
indication of how much memory is available for immediate reclaim.
We're never going to get an accurate measure in userspace unless we
accurately account for it in the kernel itself. Which, I think it
has already been pointed out, is prohibitively expensive so isn't
done.

As for a replacement, looking at what pages you consider "droppable"
is really only file pages that are not under dirty or under
writeback. i.e. from /proc/meminfo:

Active(file):     220128 kB
Inactive(file):    60232 kB
Dirty:                 0 kB
Writeback:             0 kB

i.e. reclaimable file cache = Active + inactive - dirty - writeback.

And while you are there, when you drop slab caches:

SReclaimable:      66632 kB

some amount of that may be freed. No guarantees can be made about
the amount, though.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
