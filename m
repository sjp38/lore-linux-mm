Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id A0BBA4403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 09:45:25 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id f206so323931437wmf.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 06:45:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ex19si127899805wjc.64.2016.01.12.06.45.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Jan 2016 06:45:24 -0800 (PST)
Date: Tue, 12 Jan 2016 15:45:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix locking order in mm_take_all_locks()
Message-ID: <20160112144521.GL25337@dhcp22.suse.cz>
References: <1452510328-93955-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452510328-93955-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>

On Mon 11-01-16 14:05:28, Kirill A. Shutemov wrote:
> Dmitry Vyukov has reported[1] possible deadlock (triggered by his syzkaller
> fuzzer):
> 
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(&hugetlbfs_i_mmap_rwsem_key);
>                                lock(&mapping->i_mmap_rwsem);
>                                lock(&hugetlbfs_i_mmap_rwsem_key);
>   lock(&mapping->i_mmap_rwsem);
> 
> Both traces points to mm_take_all_locks() as a source of the problem.
> It doesn't take care about ordering or hugetlbfs_i_mmap_rwsem_key (aka
> mapping->i_mmap_rwsem for hugetlb mapping) vs. i_mmap_rwsem.

Hmm, but huge_pmd_share is called with mmap_sem held no? At least my
current cscope claims that huge_pte_alloc is called from
copy_hugetlb_page_range and hugetlb_fault both of which should be called
with mmap sem held for write (via dup_mmap) resp. read (via page fault
resp. gup) while mm_take_all_locks expects mmap_sem for write as well.

> huge_pmd_share() does memory allocation under hugetlbfs_i_mmap_rwsem_key
> and allocator can take i_mmap_rwsem if it hit reclaim. So we need to
> take i_mmap_rwsem from all hugetlb VMAs before taking i_mmap_rwsem from
> rest of VMAs.
> 
> The patch also documents locking order for hugetlbfs_i_mmap_rwsem_key.

The documentation part alone makes sense but I fail to see how this can
solve any deadlock in the current code.

> [1] http://lkml.kernel.org/r/CACT4Y+Zu95tBs-0EvdiAKzUOsb4tczRRfCRTpLr4bg_OP9HuVg@mail.gmail.com
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
