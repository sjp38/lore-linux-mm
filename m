Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B19C6B0005
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 04:03:31 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e3-v6so16756192pld.13
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 01:03:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y26-v6sor4569787pfa.69.2018.10.08.01.03.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 01:03:30 -0700 (PDT)
Date: Mon, 8 Oct 2018 11:03:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH RFC 1/1] hugetlbfs: introduce truncation/fault mutex to
 avoid races
Message-ID: <20181008080323.xg3v35uxgmakf6wy@kshutemo-mobl1>
References: <20181007233848.13397-1-mike.kravetz@oracle.com>
 <20181007233848.13397-2-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181007233848.13397-2-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>

On Sun, Oct 07, 2018 at 04:38:48PM -0700, Mike Kravetz wrote:
> The following hugetlbfs truncate/page fault race can be recreated
> with programs doing something like the following.
> 
> A huegtlbfs file is mmap(MAP_SHARED) with a size of 4 pages.  At
> mmap time, 4 huge pages are reserved for the file/mapping.  So,
> the global reserve count is 4.  In addition, since this is a shared
> mapping an entry for 4 pages is added to the file's reserve map.
> The first 3 of the 4 pages are faulted into the file.  As a result,
> the global reserve count is now 1.
> 
> Task A starts to fault in the last page (routines hugetlb_fault,
> hugetlb_no_page).  It allocates a huge page (alloc_huge_page).
> The reserve map indicates there is a reserved page, so this is
> used and the global reserve count goes to 0.
> 
> Now, task B truncates the file to size 0.  It starts by setting
> inode size to 0(hugetlb_vmtruncate).  It then unmaps all mapping
> of the file (hugetlb_vmdelete_list).  Since task A's page table
> lock is not held at the time, truncation is not blocked.  Truncation
> removes the 3 pages from the file (remove_inode_hugepages).  When
> cleaning up the reserved pages (hugetlb_unreserve_pages), it notices
> the reserve map was for 4 pages.  However, it has only freed 3 pages.
> So it assumes there is still (4 - 3) 1 reserved pages.  It then
> decrements the global reserve count by 1 and it goes negative.
> 
> Task A then continues the page fault process and adds it's newly
> acquired page to the page cache.  Note that the index of this page
> is beyond the size of the truncated file (0).  The page fault process
> then notices the file has been truncated and exits.  However, the
> page is left in the cache associated with the file.
> 
> Now, if the file is immediately deleted the truncate code runs again.
> It will find and free the one page associated with the file.  When
> cleaning up reserves, it notices the reserve map is empty.  Yet, one
> page freed.  So, the global reserve count is decremented by (0 - 1) -1.
> This returns the global count to 0 as it should be.  But, it is
> possible for someone else to mmap this file/range before it is deleted.
> If this happens, a reserve map entry for the allocated page is created
> and the reserved page is forever leaked.
> 
> To avoid all these conditions, let's simply prevent faults to a file
> while it is being truncated.  Add a new truncation specific rw mutex
> to hugetlbfs inode extensions.  faults take the mutex in read mode,
> truncation takes in write mode.

Hm. Don't we have already a lock for this? I mean i_mmap_lock.

-- 
 Kirill A. Shutemov
