Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9DD6B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 10:49:41 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 127so10989539pge.10
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 07:49:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 143sor338751pge.255.2018.04.25.07.49.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 07:49:39 -0700 (PDT)
Date: Wed, 25 Apr 2018 17:49:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v5 PATCH] mm: shmem: make stat.st_blksize return huge page
 size if THP is on
Message-ID: <20180425144938.6mv7idgd2u2cyucu@kshutemo-mobl1>
References: <1524665633-83806-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1524665633-83806-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, mhocko@kernel.org, hch@infradead.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 25, 2018 at 10:13:53PM +0800, Yang Shi wrote:
> Since tmpfs THP was supported in 4.8, hugetlbfs is not the only
> filesystem with huge page support anymore. tmpfs can use huge page via
> THP when mounting by "huge=" mount option.
> 
> When applications use huge page on hugetlbfs, it just need check the
> filesystem magic number, but it is not enough for tmpfs. Make
> stat.st_blksize return huge page size if it is mounted by appropriate
> "huge=" option to give applications a hint to optimize the behavior with
> THP.
> 
> Some applications may not do wisely with THP. For example, QEMU may mmap
> file on non huge page aligned hint address with MAP_FIXED, which results
> in no pages are PMD mapped even though THP is used. Some applications
> may mmap file with non huge page aligned offset. Both behaviors make THP
> pointless.
> 
> statfs.f_bsize still returns 4KB for tmpfs since THP could be split, and it
> also may fallback to 4KB page silently if there is not enough huge page.
> Furthermore, different f_bsize makes max_blocks and free_blocks
> calculation harder but without too much benefit. Returning huge page
> size via stat.st_blksize sounds good enough.
> 
> Since PUD size huge page for THP has not been supported, now it just
> returns HPAGE_PMD_SIZE.
> 
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Suggested-by: Christoph Hellwig <hch@infradead.org>

Looks good to me:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
