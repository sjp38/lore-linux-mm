Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 66EA86B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 03:53:13 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id u10so4741933lbd.36
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 00:53:12 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id js3si7644231lab.53.2014.07.09.00.53.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jul 2014 00:53:12 -0700 (PDT)
Date: Wed, 9 Jul 2014 11:52:52 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 0/5] Virtual Memory Resource Controller for cgroups
Message-ID: <20140709075252.GB31067@esperanza>
References: <cover.1404383187.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1404383187.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

On Thu, Jul 03, 2014 at 04:48:16PM +0400, Vladimir Davydov wrote:
> Hi,
> 
> Typically, when a process calls mmap, it isn't given all the memory pages it
> requested immediately. Instead, only its address space is grown, while the
> memory pages will be actually allocated on the first use. If the system fails
> to allocate a page, it will have no choice except invoking the OOM killer,
> which may kill this or any other process. Obviously, it isn't the best way of
> telling the user that the system is unable to handle his request. It would be
> much better to fail mmap with ENOMEM instead.
> 
> That's why Linux has the memory overcommit control feature, which accounts and
> limits VM size that may contribute to mem+swap, i.e. private writable mappings
> and shared memory areas. However, currently it's only available system-wide,
> and there's no way of avoiding OOM in cgroups.
> 
> This patch set is an attempt to fill the gap. It implements the resource
> controller for cgroups that accounts and limits address space allocations that
> may contribute to mem+swap.
> 
> The interface is similar to the one of the memory cgroup except it controls
> virtual memory usage, not actual memory allocation:
> 
>   vm.usage_in_bytes            current vm usage of processes inside cgroup
>                                (read-only)
> 
>   vm.max_usage_in_bytes        max vm.usage_in_bytes, can be reset by writing 0
> 
>   vm.limit_in_bytes            vm.usage_in_bytes must be <= vm.limite_in_bytes;
>                                allocations that hit the limit will be failed
>                                with ENOMEM
> 
>   vm.failcnt                   number of times the limit was hit, can be reset
>                                by writing 0
> 
> In future, the controller can be easily extended to account for locked pages
> and shmem.

Any thoughts on this?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
