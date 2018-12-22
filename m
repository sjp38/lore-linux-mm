Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F52C8E0001
	for <linux-mm@kvack.org>; Sat, 22 Dec 2018 17:14:17 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id f22-v6so2755769lja.7
        for <linux-mm@kvack.org>; Sat, 22 Dec 2018 14:14:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1-v6sor17614805ljj.2.2018.12.22.14.14.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 22 Dec 2018 14:14:15 -0800 (PST)
Date: Sun, 23 Dec 2018 01:14:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 2/2] hugetlbfs: Use i_mmap_rwsem to fix page
 fault/truncate race
Message-ID: <20181222221411.ktm5qeebi43lvce5@kshutemo-mobl1>
References: <20181218223557.5202-1-mike.kravetz@oracle.com>
 <20181218223557.5202-3-mike.kravetz@oracle.com>
 <20181221102824.5v36l6l5t2zthpgr@kshutemo-mobl1>
 <849f5202-2200-265f-7769-8363053e8373@oracle.com>
 <20181221202136.crrwojz3k7muvyrh@kshutemo-mobl1>
 <732c0b7d-5a4e-97a8-9677-30f3520893cb@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <732c0b7d-5a4e-97a8-9677-30f3520893cb@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Fri, Dec 21, 2018 at 02:17:32PM -0800, Mike Kravetz wrote:
> Am I misunderstanding your question/concern?

No. Thanks for the clarification.

> 
> I have decided to add the locking (although unnecessary) with something like
> this in hugetlbfs_evict_inode.
> 
> 	/*
> 	 * The vfs layer guarantees that there are no other users of this
> 	 * inode.  Therefore, it would be safe to call remove_inode_hugepages
> 	 * without holding i_mmap_rwsem.  We acquire and hold here to be
> 	 * consistent with other callers.  Since there will be no contention
> 	 * on the semaphore, overhead is negligible.
> 	 */
> 	i_mmap_lock_write(mapping);
> 	remove_inode_hugepages(inode, 0, LLONG_MAX);
> 	i_mmap_unlock_write(mapping);

LGTM.

-- 
 Kirill A. Shutemov
