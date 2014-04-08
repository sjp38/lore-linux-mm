Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 13F496B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 16:38:36 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so1112344eek.18
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 13:38:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z2si4309448eeo.214.2014.04.08.13.38.34
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 13:38:35 -0700 (PDT)
Date: Tue, 08 Apr 2014 16:38:03 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <53445e4b.02d50e0a.2fea.fffff738SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <1396983740-26047-6-git-send-email-lcapitulino@redhat.com>
References: <1396983740-26047-1-git-send-email-lcapitulino@redhat.com>
 <1396983740-26047-6-git-send-email-lcapitulino@redhat.com>
Subject: Re: [PATCH 5/5] hugetlb: add support for gigantic page allocation at
 runtime
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lcapitulino@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com

On Tue, Apr 08, 2014 at 03:02:20PM -0400, Luiz Capitulino wrote:
> HugeTLB is limited to allocating hugepages whose size are less than
> MAX_ORDER order. This is so because HugeTLB allocates hugepages via
> the buddy allocator. Gigantic pages (that is, pages whose size is
> greater than MAX_ORDER order) have to be allocated at boottime.
> 
> However, boottime allocation has at least two serious problems. First,
> it doesn't support NUMA and second, gigantic pages allocated at
> boottime can't be freed.
> 
> This commit solves both issues by adding support for allocating gigantic
> pages during runtime. It works just like regular sized hugepages,
> meaning that the interface in sysfs is the same, it supports NUMA,
> and gigantic pages can be freed.
> 
> For example, on x86_64 gigantic pages are 1GB big. To allocate two 1G
> gigantic pages on node 1, one can do:
> 
>  # echo 2 > \
>    /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
> 
> And to free them all:
> 
>  # echo 0 > \
>    /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
> 
> The one problem with gigantic page allocation at runtime is that it
> can't be serviced by the buddy allocator. To overcome that problem, this
> commit scans all zones from a node looking for a large enough contiguous
> region. When one is found, it's allocated by using CMA, that is, we call
> alloc_contig_range() to do the actual allocation. For example, on x86_64
> we scan all zones looking for a 1GB contiguous region. When one is found,
> it's allocated by alloc_contig_range().
> 
> One expected issue with that approach is that such gigantic contiguous
> regions tend to vanish as runtime goes by. The best way to avoid this for
> now is to make gigantic page allocations very early during system boot, say
> from a init script. Other possible optimization include using compaction,
> which is supported by CMA but is not explicitly used by this commit.
> 
> It's also important to note the following:
> 
>  1. Gigantic pages allocated at boottime by the hugepages= command-line
>     option can be freed at runtime just fine
> 
>  2. This commit adds support for gigantic pages only to x86_64. The
>     reason is that I don't have access to nor experience with other archs.
>     The code is arch indepedent though, so it should be simple to add
>     support to different archs
> 
>  3. I didn't add support for hugepage overcommit, that is allocating
>     a gigantic page on demand when
>    /proc/sys/vm/nr_overcommit_hugepages > 0. The reason is that I don't
>    think it's reasonable to do the hard and long work required for
>    allocating a gigantic page at fault time. But it should be simple
>    to add this if wanted
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

Looks good to me, thanks.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
