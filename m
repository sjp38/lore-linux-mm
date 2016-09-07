Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0F46B026C
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 08:40:51 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 10so25720513ual.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 05:40:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i186si13249759ywf.293.2016.09.07.05.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 05:40:50 -0700 (PDT)
Date: Wed, 7 Sep 2016 14:40:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: use-after-free in collapse_huge_page
Message-ID: <20160907124046.o2tmoedx4j3jyux5@redhat.com>
References: <CACT4Y+Z3gigBvhca9kRJFcjX0G70V_nRhbwKBU+yGoESBDKi9Q@mail.gmail.com>
 <20160829124233.GA40092@black.fi.intel.com>
 <20160829153548.pmwcup4q74hafwmu@redhat.com>
 <20160907122559.GA6542@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160907122559.GA6542@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <levinsasha928@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

On Wed, Sep 07, 2016 at 03:25:59PM +0300, Kirill A. Shutemov wrote:
> Here's updated version.
> 
> From 14d748bd8a7eb003efc10b1e5d5b8a644e7181b1 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 29 Aug 2016 15:32:50 +0300
> Subject: [PATCH] khugepaged: fix use-after-free in collapse_huge_page()
> 
> hugepage_vma_revalidate() tries to re-check if we still should try to
> collapse small pages into huge one after the re-acquiring mmap_sem.
> 
> The problem Dmitry Vyukov reported[1] is that the vma found by
> hugepage_vma_revalidate() can be suitable for huge pages, but not the
> same vma we had before dropping mmap_sem. And dereferencing original vma
> can lead to fun results..
> 
> Let's use vma hugepage_vma_revalidate() found instead of assuming it's
> the same as what we had before the lock was dropped.
> 
> [1] http://lkml.kernel.org/r/CACT4Y+Z3gigBvhca9kRJFcjX0G70V_nRhbwKBU+yGoESBDKi9Q@mail.gmail.com
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> ---
>  mm/khugepaged.c | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
