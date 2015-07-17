Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 449806B02AC
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 05:03:03 -0400 (EDT)
Received: by oige126 with SMTP id e126so66915820oig.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 02:03:03 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id o6si8862423oig.109.2015.07.17.02.03.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 02:03:02 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 00/10] hugetlbfs: add fallocate support
Date: Fri, 17 Jul 2015 09:01:36 +0000
Message-ID: <20150717090135.GA32135@hori1.linux.bs1.fc.nec.co.jp>
References: <1436761268-6397-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1436761268-6397-1-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <96F258FE34C42B469AD397F286F9104A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>

On Sun, Jul 12, 2015 at 09:20:58PM -0700, Mike Kravetz wrote:
> Only change in this revision is the fix to the self-discovered
> issue in region_chg().  Functional and stress tests passing.
> Full changelog below.
>=20
> As suggested during the RFC process, tests have been proposed to
> libhugetlbfs as described at:
> http://librelist.com/browser//libhugetlbfs/2015/6/25/patch-tests-add-test=
s-for-fallocate-system-call/
> fallocate(2) man page modifications are also necessary to specify
> that fallocate for hugetlbfs only operates on whole pages.  This
> change will be submitted once the code has stabilized and been
> proposed for merging.
>=20
> hugetlbfs is used today by applications that want a high degree of
> control over huge page usage.  Often, large hugetlbfs files are used
> to map a large number huge pages into the application processes.
> The applications know when page ranges within these large files will
> no longer be used, and ideally would like to release them back to
> the subpool or global pools for other uses.  The fallocate() system
> call provides an interface for preallocation and hole punching within
> files.  This patch set adds fallocate functionality to hugetlbfs.
>=20
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
>   Moved hugetlb_fix_reserve_counts in series as suggested by Naoya Horigu=
chi
>   Inline'ed hugetlb_fault_mutex routines as suggested by Davidlohr Bueso =
and
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
>=20
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
>=20
>  fs/hugetlbfs/inode.c    | 281 +++++++++++++++++++++++++++++---
>  include/linux/hugetlb.h |  17 +-
>  mm/hugetlb.c            | 423 ++++++++++++++++++++++++++++++++++++++----=
------
>  mm/madvise.c            |   2 +-
>  4 files changed, 619 insertions(+), 104 deletions(-)

I've read through this series and it looks good to me.
I'll send a comment later for 1/10, but it's kind of nitpicks.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
