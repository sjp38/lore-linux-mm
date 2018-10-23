Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 380A76B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 03:43:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x20-v6so471126eda.21
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 00:43:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t25-v6si64193eji.127.2018.10.23.00.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 00:43:42 -0700 (PDT)
Date: Tue, 23 Oct 2018 09:43:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] hugetlbfs: dirty pages as they are added to pagecache
Message-ID: <20181023074340.GO18839@dhcp22.suse.cz>
References: <20181018041022.4529-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018041022.4529-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Alexander Viro <viro@zeniv.linux.org.uk>, stable@vger.kernel.org

On Wed 17-10-18 21:10:22, Mike Kravetz wrote:
> Some test systems were experiencing negative huge page reserve
> counts and incorrect file block counts.  This was traced to
> /proc/sys/vm/drop_caches removing clean pages from hugetlbfs
> file pagecaches.  When non-hugetlbfs explicit code removes the
> pages, the appropriate accounting is not performed.
> 
> This can be recreated as follows:
>  fallocate -l 2M /dev/hugepages/foo
>  echo 1 > /proc/sys/vm/drop_caches
>  fallocate -l 2M /dev/hugepages/foo
>  grep -i huge /proc/meminfo
>    AnonHugePages:         0 kB
>    ShmemHugePages:        0 kB
>    HugePages_Total:    2048
>    HugePages_Free:     2047
>    HugePages_Rsvd:    18446744073709551615
>    HugePages_Surp:        0
>    Hugepagesize:       2048 kB
>    Hugetlb:         4194304 kB
>  ls -lsh /dev/hugepages/foo
>    4.0M -rw-r--r--. 1 root root 2.0M Oct 17 20:05 /dev/hugepages/foo
> 
> To address this issue, dirty pages as they are added to pagecache.
> This can easily be reproduced with fallocate as shown above. Read
> faulted pages will eventually end up being marked dirty.  But there
> is a window where they are clean and could be impacted by code such
> as drop_caches.  So, just dirty them all as they are added to the
> pagecache.
> 
> In addition, it makes little sense to even try to drop hugetlbfs
> pagecache pages, so disable calls to these filesystems in drop_caches
> code.
> 
> Fixes: 70c3547e36f5 ("hugetlbfs: add hugetlbfs_fallocate()")
> Cc: stable@vger.kernel.org
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

I do agree with others that HUGETLBFS_MAGIC check in drop_pagecache_sb
is wrong in principal. I am not even sure we want to special case memory
backed filesystems. What if we ever implement MADV_FREE on fs? Should
those pages be dropped? My first idea take would be yes.

Acked-by: Michal Hocko <mhocko@suse.com> to the set_page_dirty dirty
part.

Although I am wondering why you haven't covered only the fallocate path
wrt Fixes tag. In other words, do we need the same treatment for the
page fault path? We do not set dirty bit on page there as well. We rely
on the dirty bit in pte and only for writable mappings. I have hard time
to see why we have been safe there as well. So maybe it is your Fixes:
tag which is not entirely correct, or I am simply missing the fault
path.
-- 
Michal Hocko
SUSE Labs
