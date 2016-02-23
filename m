Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4702E6B0255
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:06:13 -0500 (EST)
Received: by mail-qk0-f180.google.com with SMTP id o6so71412308qkc.2
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:06:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w198si34965248qkw.58.2016.02.23.10.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 10:06:12 -0800 (PST)
Date: Tue, 23 Feb 2016 19:06:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: THP race?
Message-ID: <20160223180609.GC23289@redhat.com>
References: <20160223154950.GA22449@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223154950.GA22449@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org

On Tue, Feb 23, 2016 at 06:49:50PM +0300, Kirill A. Shutemov wrote:
> Hi Andrea,
> 
> I suspect there's race with THP in __handle_mm_fault(). It's pure
> theoretical and race window is small, but..
> 
> Consider following scenario:
> 
>   - THP got allocated by other thread just before "pmd_none() &&
>     __pte_alloc()" check, so pmd_none() is false and we don't
>     allocate the page table.
> 
>   - But before pmd_trans_huge() check the page got unmap by
>     MADV_DONTNEED in other thread.
> 
>   - At this point we will call pte_offset_map() for pmd which is
>     pmd_none().
> 
> Nothing pleasant would happen after this...
> 
> Do you see anything what would prevent this scenario?

No so I think we need s/pmd_trans_huge/pmd_trans_unstable/ and use the
atomic read in C to sort this out lockless. The MADV_DONTNEED part
that isn't holding the mmap_sem for writing unfortunately wasn't
sorted out immediately, that was unexpected in
fact. pmd_trans_unstable() was introduced precisely to handle this
trouble caused by MADV_DONTNEED running with the mmap_sem only for
reading which causes infinite possible transactions back and forth
between none and transhuge while holding only the mmap_sem for
reading.

==
