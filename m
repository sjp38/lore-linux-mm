Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE928E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 04:04:57 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f31so34616176edf.17
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 01:04:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si1716542eds.261.2019.01.04.01.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 01:04:56 -0800 (PST)
Date: Fri, 4 Jan 2019 10:04:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memory cgroup pagecache and inode problem
Message-ID: <20190104090441.GI31793@dhcp22.suse.cz>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fam Zheng <zhengfeiran@bytedance.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, vdavydov.dev@gmail.com, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>

On Fri 04-01-19 12:43:40, Fam Zheng wrote:
> Hi,
> 
> In our server which frequently spawns containers, we find that if a
> process used pagecache in memory cgroup, after the process exits and
> memory cgroup is offlined, because the pagecache is still charged in
> this memory cgroup, this memory cgroup will not be destroyed until the
> pagecaches are dropped. This brings huge memory stress over time. We
> find that over one hundred thounsand such offlined memory cgroup in
> system hold too much memory (~100G). This memory can not be released
> immediately even after all associated pagecahes are released, because
> those memory cgroups are destroy asynchronously by a kworker. In some
> cases this can cause oom, since the synchronous memory allocation
> failed.

You are right that an offline memcg keeps memory behind and expects
kswapd or the direct reclaim to prune that memory on demand. Do you have
any examples when this would cause extreme memory stress though? For
example a high direct reclaim activity that would be result of these
offline memcgs? You are mentioning OOM which is even more unexpected.
I haven't seen such a disruptive behavior.

> We think a fix is to create a kworker that scans all pagecaches and
> dentry caches etc. in the background, if a referenced memory cgroup is
> offline, try to drop the cache or move it to the parent cgroup. This
> kworker can wake up periodically, or upon memory cgroup offline event
> (or both).

We do that from the kswapd context already. I do not think we need
another kworker.

Another option might be to enforce the reclaim on the offline path.
We are discussing a similar issue with Yang Shi
http://lkml.kernel.org/r/1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com

> There is a similar problem in inode. After digging in ext4 code, we
> find that when creating inode cache, SLAB_ACCOUNT is used. In this
> case, inode will alloc in slab which belongs to the current memory
> cgroup. After this memory cgroup goes offline, this inode may be held
> by a dentry cache. If another process uses the same file. this inode
> will be held by that process, preventing the previous memory cgroup
> from being destroyed until this other process closes the file and
> drops the dentry cache.

This is a natural side effect of shared memory, I am afraid. Isolated
memory cgroups should limit any shared resources to bare minimum. You
will get "who touches first gets charged" behavior otherwise and that is
not really deterministic.
-- 
Michal Hocko
SUSE Labs
