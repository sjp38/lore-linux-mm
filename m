Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 322209003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 23:09:09 -0400 (EDT)
Received: by igvi1 with SMTP id i1so91936944igv.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 20:09:08 -0700 (PDT)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-248.mail.alibaba.com. [205.204.113.248])
        by mx.google.com with ESMTP id a5si27282838pdg.240.2015.07.20.20.09.06
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 20:09:08 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1436761268-6397-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1436761268-6397-1-git-send-email-mike.kravetz@oracle.com>
Subject: RE: [PATCH v3 00/10] hugetlbfs: add fallocate support
Date: Tue, 21 Jul 2015 11:08:46 +0800
Message-ID: <063901d0c362$8ff7d6e0$afe784a0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'David Rientjes' <rientjes@google.com>, 'Hugh Dickins' <hughd@google.com>, 'Davidlohr Bueso' <dave@stgolabs.net>, 'Aneesh Kumar' <aneesh.kumar@linux.vnet.ibm.com>, 'Christoph Hellwig' <hch@infradead.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Michal Hocko' <mhocko@suse.cz>

> 
> Only change in this revision is the fix to the self-discovered
> issue in region_chg().  Functional and stress tests passing.
> Full changelog below.
> 
> As suggested during the RFC process, tests have been proposed to
> libhugetlbfs as described at:
> http://librelist.com/browser//libhugetlbfs/2015/6/25/patch-tests-add-tests-for-fallocate-system-call/
> fallocate(2) man page modifications are also necessary to specify
> that fallocate for hugetlbfs only operates on whole pages.  This
> change will be submitted once the code has stabilized and been
> proposed for merging.
> 
> hugetlbfs is used today by applications that want a high degree of
> control over huge page usage.  Often, large hugetlbfs files are used
> to map a large number huge pages into the application processes.
> The applications know when page ranges within these large files will
> no longer be used, and ideally would like to release them back to
> the subpool or global pools for other uses.  The fallocate() system
> call provides an interface for preallocation and hole punching within
> files.  This patch set adds fallocate functionality to hugetlbfs.
> 
> v3:
>   Fixed issue with region_chg to recheck if there are sufficient
>   entries in the cache after acquiring lock.
> v2:
>   Fixed leak in resv_map_release discovered by Hillf Danton.
>   Used LONG_MAX as indicator of truncate function for region_del.
> v1:
>   Add a cache of region descriptors to the resv_map for use by
>     region_add in case hole punch deletes entries necessary for
>     a successful operation.
> RFC v4:
>   Removed alloc_huge_page/hugetlb_reserve_pages race patches as already
>     in mmotm
>   Moved hugetlb_fix_reserve_counts in series as suggested by Naoya Horiguchi
>   Inline'ed hugetlb_fault_mutex routines as suggested by Davidlohr Bueso and
>     existing code changed to use new interfaces as suggested by Naoya
>   fallocate preallocation code cleaned up and made simpler
>   Modified alloc_huge_page to handle special case where allocation is
>     for a hole punched area with spool reserves
> RFC v3:
>   Folded in patch for alloc_huge_page/hugetlb_reserve_pages race
>     in current code
>   fallocate allocation and hole punch is synchronized with page
>     faults via existing mutex table
>    hole punch uses existing hugetlb_vmtruncate_list instead of more
>     generic unmap_mapping_range for unmapping
>    Error handling for the case when region_del() fauils
> RFC v2:
>   Addressed alignment and error handling issues noticed by Hillf Danton
>   New region_del() routine for region tracking/resv_map of ranges
>   Fixed several issues found during more extensive testing
>   Error handling in region_del() when kmalloc() fails stills needs
>     to be addressed
>   madvise remove support remains
> 
> Mike Kravetz (10):
>   mm/hugetlb: add cache of descriptors to resv_map for region_add
>   mm/hugetlb: add region_del() to delete a specific range of entries
>   mm/hugetlb: expose hugetlb fault mutex for use by fallocate
>   hugetlbfs: hugetlb_vmtruncate_list() needs to take a range to delete
>   hugetlbfs: truncate_hugepages() takes a range of pages
>   mm/hugetlb: vma_has_reserves() needs to handle fallocate hole punch
>   mm/hugetlb: alloc_huge_page handle areas hole punched by fallocate
>   hugetlbfs: New huge_add_to_page_cache helper routine
>   hugetlbfs: add hugetlbfs_fallocate()
>   mm: madvise allow remove operation for hugetlbfs
> 
>  fs/hugetlbfs/inode.c    | 281 +++++++++++++++++++++++++++++---
>  include/linux/hugetlb.h |  17 +-
>  mm/hugetlb.c            | 423 ++++++++++++++++++++++++++++++++++++++----------
>  mm/madvise.c            |   2 +-
>  4 files changed, 619 insertions(+), 104 deletions(-)
> 
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
