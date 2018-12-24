Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id CAB038E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 05:13:54 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id 2-v6so3762039ljs.15
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 02:13:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m72sor8610525lfe.8.2018.12.24.02.13.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 02:13:52 -0800 (PST)
Date: Mon, 24 Dec 2018 13:13:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 0/2] hugetlbfs: use i_mmap_rwsem for better
 synchronization
Message-ID: <20181224101349.jjjmk2hzwah6g64h@kshutemo-mobl1>
References: <20181222223013.22193-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181222223013.22193-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Dec 22, 2018 at 02:30:11PM -0800, Mike Kravetz wrote:
> There are two primary issues addressed here:
> 1) For shared pmds, huge PTE pointers returned by huge_pte_alloc can become
>    invalid via a call to huge_pmd_unshare by another thread.
> 2) hugetlbfs page faults can race with truncation causing invalid global
>    reserve counts and state.
> Both issues are addressed by expanding the use of i_mmap_rwsem.
> 
> These issues have existed for a long time.  They can be recreated with a
> test program that causes page fault/truncation races.  For simple mappings,
> this results in a negative HugePages_Rsvd count.  If racing with mappings
> that contain shared pmds, we can hit "BUG at fs/hugetlbfs/inode.c:444!" or
> Oops! as the result of an invalid memory reference.
> 
> v2 -> v3
>   Incorporated suggestions from Kirill.  Code change to hold i_mmap_rwsem
>   for duration of copy in copy_hugetlb_page_range.  Took i_mmap_rwsem in
>   hugetlbfs_evict_inode to be consistent with other callers.  Other changes
>   were to documentation/comments.
> v1 -> v2
>   Combined patches 2 and 3 of v1 series as suggested by Aneesh.  No other
>   changes were made.
> Patches are a follow up to the RFC,
>   http://lkml.kernel.org/r/20181024045053.1467-1-mike.kravetz@oracle.com
>   Comments made by Naoya were addressed.
> 
> Mike Kravetz (2):
>   hugetlbfs: use i_mmap_rwsem for more pmd sharing synchronization
>   hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
