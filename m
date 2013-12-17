Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7D60C6B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 17:05:10 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so7353543pdj.2
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 14:05:10 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id j5si7123894pbs.91.2013.12.17.14.05.07
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 14:05:09 -0800 (PST)
Date: Wed, 18 Dec 2013 09:05:03 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/5] VFS: Directory level cache cleaning
Message-ID: <20131217220503.GA20579@dastard>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@ubuntukylin.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yunchuan Wen <yunchuanwen@ubuntukylin.com>

On Mon, Dec 16, 2013 at 07:00:04AM -0800, Li Wang wrote:
> Currently, Linux only support file system wide VFS
> cache (dentry cache and page cache) cleaning through
> '/proc/sys/vm/drop_caches'. Sometimes this is less
> flexible. The applications may know exactly whether
> the metadata and data will be referenced or not in future,
> a desirable mechanism is to enable applications to
> reclaim the memory of unused cache entries at a finer
> granularity - directory level. This enables applications
> to keep hot metadata and data (to be referenced in the
> future) in the cache, and kick unused out to avoid
> cache thrashing. Another advantage is it is more flexible
> for debugging.
>
> This patch extend the 'drop_caches' interface to
> support directory level cache cleaning and has a complete
> backward compatibility. '{1,2,3}' keeps the same semantics
> as before. Besides, "{1,2,3}:DIRECTORY_PATH_NAME" is allowed
> to recursively clean the caches under DIRECTORY_PATH_NAME.
> For example, 'echo 1:/home/foo/jpg > /proc/sys/vm/drop_caches'
> will clean the page caches of the files inside 'home/foo/jpg'.
> 
> It is easy to demonstrate the advantage of directory level
> cache cleaning. We use a virtual machine configured with
> an Intel(R) Xeon(R) 8-core CPU E5506 @ 2.13GHz, and with 1GB
> memory.  Three directories named '1', '2' and '3' are created,
> with each containing 180000 a?? 280000 files. The test program
> opens all files in a directory and then tries the next directory.
> The order for accessing the directories is '1', '2', '3',
> '1'.
> 
> The time on accessing '1' on the second time is measured
> with/without cache cleaning, under different file counts.
> With cache cleaning, we clean all cache entries of files
> in '2' before accessing the files in '3'. The results
> are as follows (in seconds),

This sounds like a highly contrived test case. There is no reason
why dentry cache access time would change going from 180k to 280k
files in 3 directories unless you're right at the memory pressure
balance point in terms of cache sizing.

> Note: by default, VFS will move those unreferenced inodes
> into a global LRU list rather than freeing them, for this
> experiment, we modified iput() to force to free inode as well,
> this behavior and related codes are left for further discussion,
> thus not reflected in this patch)
> 
> Number of files:   180000 200000 220000 240000 260000
> Without cleaning:  2.165  6.977  10.032 11.571 13.443
> With cleaning:     1.949  1.906  2.336  2.918  3.651
>
> When the number of files is 180000 in each directory,
> the metadata cache is large enough to buffer all entries
> of three directories, so re-accessing '1' will hit in
> the cache, regardless of whether '2' cleaned up or not.
> As the number of files increases, the cache can now only
> buffer two+ directories. Accessing '3' will result in some
> entries of '1' to be evicted (due to LRU). When re-accessing '1',
> some entries need be reloaded from disk, which is time-consuming.

Ok, so exactly as I thought - your example working set is slightly
larger than what the cache holds. Hence what you are describing is
a cache reclaim threshold effect: something you can avoid with
/proc/sys/vm/vfs_cache_pressure.

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
