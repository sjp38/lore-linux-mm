Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 365CC6B0254
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 16:19:01 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id y8so63188006igp.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 13:19:01 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id 87si37763525ios.62.2016.02.14.13.18.59
        for <linux-mm@kvack.org>;
        Sun, 14 Feb 2016 13:19:00 -0800 (PST)
Date: Mon, 15 Feb 2016 08:18:56 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
Message-ID: <20160214211856.GT19486@dastard>
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walker <danielwa@cisco.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Khalid Mughal <khalidm@cisco.com>, xe-kernel@external.cisco.com, dave.hansen@intel.com, hannes@cmpxchg.org, riel@redhat.com, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 12, 2016 at 12:14:39PM -0800, Daniel Walker wrote:
> From: Khalid Mughal <khalidm@cisco.com>
> 
> Currently there is no way to figure out the droppable pagecache size
> from the meminfo output. The MemFree size can shrink during normal
> system operation, when some of the memory pages get cached and is
> reflected in "Cached" field. Similarly for file operations some of
> the buffer memory gets cached and it is reflected in "Buffers" field.
> The kernel automatically reclaims all this cached & buffered memory,
> when it is needed elsewhere on the system. The only way to manually
> reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. But
> this can have performance impact. Since it discards cached objects,
> it may cause high CPU & I/O utilization to recreate the dropped
> objects during heavy system load.
> This patch computes the droppable pagecache count, using same
> algorithm as "vm/drop_caches". It is non-destructive and does not
> drop any pages. Therefore it does not have any impact on system
> performance. The computation does not include the size of
> reclaimable slab.

Why, exactly, do you need this? You've described what the patch
does (i.e. redundant, because we can read the code), and described
that the kernel already accounts this reclaimable memory elsewhere
and you can already read that and infer the amount of reclaimable
memory from it. So why isn't that accounting sufficient?

As to the code, I think it is a horrible hack - the calculation
does not come for free. Forcing iteration all the inodes in the
inode cache is not something we should allow users to do - what's to
stop someone just doing this 100 times in parallel and DOSing the
machine?

Or what happens when someone does 'grep "" /proc/sys/vm/*" to see
what all the VM settings are on a machine with a couple of TB of
page cache spread across a couple of hundred million cached inodes?
It a) takes a long time, b) adds sustained load to an already
contended lock (sb->s_inode_list_lock), and c) isn't configuration
information.

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
