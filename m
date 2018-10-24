Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id A26AF6B000A
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 01:00:37 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id l126-v6so2353391ywb.17
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 22:00:37 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z89-v6si2025229ybh.334.2018.10.23.22.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 22:00:36 -0700 (PDT)
Message-ID: <460643f8371a423e97af375f9835243e1e8831bb.camel@oracle.com>
Subject: Re: [PATCH] hugetlbfs: dirty pages as they are added to pagecache
From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Wed, 24 Oct 2018 10:30:42 +0530
In-Reply-To: <b5be45b8-5afe-56cd-9482-28384699a049@oracle.com>
References: <20181018041022.4529-1-mike.kravetz@oracle.com>
	 <20181023074340.GO18839@dhcp22.suse.cz>
	 <b5be45b8-5afe-56cd-9482-28384699a049@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Alexander Viro <viro@zeniv.linux.org.uk>, stable@vger.kernel.org

On Tue, 2018-10-23 at 10:30 -0700, Mike Kravetz wrote:
> ..... snip....
> Here is updated patch without the drop_caches change and updated
> fixes tag.
> 
> From: Mike Kravetz <mike.kravetz@oracle.com>
> 
> hugetlbfs: dirty pages as they are added to pagecache
> 
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
> Fixes: 6bda666a03f0 ("hugepages: fold find_or_alloc_pages into
> huge_no_page()")
> Cc: stable@vger.kernel.org
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/hugetlb.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 5c390f5a5207..7b5c0ad9a6bd 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3690,6 +3690,12 @@ int huge_add_to_page_cache(struct page *page,
> struct address_space *mapping,
>  		return err;
>  	ClearPagePrivate(page);
>  
> +	/*
> +	 * set page dirty so that it will not be removed from
> cache/file
> +	 * by non-hugetlbfs specific code paths.
> +	 */
> +	set_page_dirty(page);
> +
>  	spin_lock(&inode->i_lock);
>  	inode->i_blocks += blocks_per_huge_page(h);
>  	spin_unlock(&inode->i_lock);

This looks good.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

--
Khalid
