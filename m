Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 63D6B6B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 11:14:08 -0400 (EDT)
Message-ID: <4C45BD34.8030905@redhat.com>
Date: Tue, 20 Jul 2010 10:13:56 -0500
From: Eric Sandeen <sandeen@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fix return value for mb_cache_shrink_fn when nr_to_scan
 > 0
References: <4C425273.5000702@gmail.com> <20100718060106.GA579@infradead.org> <4C42A10B.2080904@gmail.com> <201007192039.06670.agruen@suse.de>
In-Reply-To: <201007192039.06670.agruen@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andreas Gruenbacher <agruen@suse.de>
Cc: Wang Sheng-Hui <crosslonelyover@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andreas Gruenbacher wrote:
> On Sunday 18 July 2010 08:36:59 Wang Sheng-Hui wrote:
>> I regenerated the patch. Please check it.
> 
> The logic for calculating how many objects to free is still wrong: 
> mb_cache_shrink_fn returns the number of entries scaled by 
> sysctl_vfs_cache_pressure / 100.  It should also scale nr_to_scan by the 
> inverse of that.  The sysctl_vfs_cache_pressure == 0 case (never scale) may 
> require special attention.

I don't think that's right:

vfs_cache_pressure
------------------

Controls the tendency of the kernel to reclaim the memory which is used for
caching of directory and inode objects.

At the default value of vfs_cache_pressure=100 the kernel will attempt to
reclaim dentries and inodes at a "fair" rate with respect to pagecache and
swapcache reclaim.  Decreasing vfs_cache_pressure causes the kernel to prefer
to retain dentry and inode caches. When vfs_cache_pressure=0, the kernel will
never reclaim dentries and inodes due to memory pressure and this can easily
lead to out-of-memory conditions. Increasing vfs_cache_pressure beyond 100
causes the kernel to prefer to reclaim dentries and inodes.


0 means "never reclaim," it doesn't mean "never scale."

As for nr_to_scan, after the first call, the shrinker has a scaled
version of the total count, so the requested nr_to_scan on the
next call is already scaled based on that.

I think the logic in the mbcache shrinker is fine.

-Eric

> See dcache_shrinker() in fs/dcache.c.



> 
> Thanks,
> Andreas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
