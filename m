Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0977C6B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 17:55:54 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u65so4967962wrc.8
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 14:55:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d83si3288946wmc.179.2018.03.01.14.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 14:55:52 -0800 (PST)
Date: Thu, 1 Mar 2018 14:55:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm: indirectly reclaimable memory and dcache
Message-Id: <20180301145549.8ff621a708ccd8fb59d924f7@linux-foundation.org>
In-Reply-To: <20180301221713.25969-1-guro@fb.com>
References: <20180301221713.25969-1-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Mel Gorman <mgorman@techsingularity.net>

On Thu, 1 Mar 2018 22:17:13 +0000 Roman Gushchin <guro@fb.com> wrote:

> I was reported about suspicious growth of unreclaimable slabs
> on some machines. I've found that it happens on machines
> with low memory pressure, and these unreclaimable slabs
> are external names attached to dentries.
> 
> External names are allocated using generic kmalloc() function,
> so they are accounted as unreclaimable. But they are held
> by dentries, which are reclaimable, and they will be reclaimed
> under the memory pressure.
> 
> In particular, this breaks MemAvailable calculation, as it
> doesn't take unreclaimable slabs into account.
> This leads to a silly situation, when a machine is almost idle,
> has no memory pressure and therefore has a big dentry cache.
> And the resulting MemAvailable is too low to start a new workload.
> 
> To resolve this issue, a new mm counter is introduced:
> NR_INDIRECTLY_RECLAIMABLE_BYTES .
> Since it's not possible to count such objects on per-page basis,
> let's make the unit obvious (by analogy to NR_KERNEL_STACK_KB).
> 
> The counter is increased in dentry allocation path, if an external
> name structure is allocated; and it's decreased in dentry freeing
> path. I believe, that it's not the only case in the kernel, when
> we do have such indirectly reclaimable memory, so I expect more
> use cases to be added.
> 
> This counter is used to adjust MemAvailable calculations:
> indirectly reclaimable memory is considered as available.
> 
> To reproduce the problem I've used the following Python script:
>   import os
> 
>   for iter in range (0, 10000000):
>       try:
>           name = ("/some_long_name_%d" % iter) + "_" * 220
>           os.stat(name)
>       except Exception:
>           pass
> 
> Without this patch:
>   $ cat /proc/meminfo | grep MemAvailable
>   MemAvailable:    7811688 kB
>   $ python indirect.py
>   $ cat /proc/meminfo | grep MemAvailable
>   MemAvailable:    2753052 kB
> 
> With the patch:
>   $ cat /proc/meminfo | grep MemAvailable
>   MemAvailable:    7809516 kB
>   $ python indirect.py
>   $ cat /proc/meminfo | grep MemAvailable
>   MemAvailable:    7749144 kB
> 
> Also, this patch adds a corresponding entry to /proc/vmstat:
> 
>   $ cat /proc/vmstat | grep indirect
>   nr_indirectly_reclaimable 5117499104
> 
>   $ echo 2 > /proc/sys/vm/drop_caches
> 
>   $ cat /proc/vmstat | grep indirect
>   nr_indirectly_reclaimable 7104

hm, I guess so...

I wonder if it should be more general, as there are probably other
potential users of NR_INDIRECTLY_RECLAIMABLE_BYTES.  And they might be
using alloc_pages() or even vmalloc()?  Whereas
NR_INDIRECTLY_RECLAIMABLE_BYTES is pretty closely tied to kmalloc, at
least in the code comments.

If we're really OK with the "only for kmalloc" concept then why create
NR_INDIRECTLY_RECLAIMABLE_BYTES at all?  Could we just use
NR_SLAB_RECLAIMABLE to account the external names?  After all, kmalloc
is slab.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
