Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB3B6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 10:41:52 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id d139so85261224oig.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 07:41:52 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id v12si7922339ioi.108.2016.05.18.07.41.50
        for <linux-mm@kvack.org>;
        Wed, 18 May 2016 07:41:51 -0700 (PDT)
Date: Thu, 19 May 2016 00:41:48 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: why the kmalloc return fail when there is free physical address
 but return success after dropping page caches
Message-ID: <20160518144148.GD21200@dastard>
References: <D64A3952-53D8-4B9D-98A1-C99D7E231D42@gmail.com>
 <573C2BB6.6070801@suse.cz>
 <78A99337-5542-4E59-A648-AB2A328957D3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <78A99337-5542-4E59-A648-AB2A328957D3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: baotiao <baotiao@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

On Wed, May 18, 2016 at 04:58:31PM +0800, baotiao wrote:
> Thanks for your reply
> 
> >> Hello every, I meet an interesting kernel memory problem. Can anyone
> >> help me explain what happen under the kernel
> > 
> > Which kernel version is that?
> 
> The kernel version is 3.10.0-327.4.5.el7.x86_64

RHEL7 kernel. Best you report the problem to your RH support
contact - the RHEL7 kernels are far different to upstream kernels..

> >> The machine's status is describe as blow:
> >> 
> >> the machine has 96 physical memory. And the real use memory is about
> >> 64G, and the page cache use about 32G. we also use the swap area, at
> >> that time we have about 10G(we set the swap max size to 32G). At that
> >> moment, we find xfs report
> >> 
> >> |Apr 29 21:54:31 w-openstack86 kernel: XFS: possible memory allocation
> >> deadlock in kmem_alloc (mode:0x250) |

Pretty sure that's a GFP_NOFS allocation context.

> > Just once, or many times?
> 
> the message appear many times
> from the code, I know that xfs will try 100 time of kmalloc() function

The curent upstream kernels report much more information - process,
size of allocation, etc.

In general, the cause of such problems is memory fragmentation
preventing a large contiguous allocation from taking place (e.g.
when you try to read a file with millions of extents).

> >> in the system. But there is still 32G page cache.
> >> 
> >> So I run
> >> 
> >> |echo 3 > /proc/sys/vm/drop_caches |
> >> 
> >> to drop the page cache.
> >> 
> >> Then the system is fine.
> > 
> > Are you saying that the error message was repeated infinitely until you did the drop_caches?
> 
> 
> No. the error message don't appear after I drop_cache.

Of course - freeing memory will cause contiguous free space to
reform. then the allocation will succeed.

IIRC, the reason the system can't recover itself is that memory
compaction is not triggered from GFP_NOFS allocation context, which
means memory reclaim won't try to create contiguous regions by
moving things around and hence the allocation will not succeed until
a significant amount of memory is freed by some other trigger....

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
