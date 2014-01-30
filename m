Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id AFC4B6B0031
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 08:46:31 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so3136741pbc.14
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 05:46:31 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id rx8si6572211pac.18.2014.01.30.05.46.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 05:46:30 -0800 (PST)
Message-ID: <52EA57AC.3090700@oracle.com>
Date: Thu, 30 Jan 2014 08:46:20 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, hugetlb: gimme back my page
References: <1391063823.2931.3.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1391063823.2931.3.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Jonathan Gonzalez <jgonzalez@linets.cl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/30/2014 01:37 AM, Davidlohr Bueso wrote:
> From: Davidlohr Bueso<davidlohr@hp.com>
>
> While testing some changes, I noticed an issue triggered by the libhugetlbfs
> test-suite. This is caused by commit 309381fe (mm: dump page when hitting a
> VM_BUG_ON using VM_BUG_ON_PAGE), where an application can unexpectedly OOM due
> to another program that using, or reserving, pool_size-1 pages later triggers
> a VM_BUG_ON_PAGE and thus greedly leaves no memory to the rest of the hugetlb
> aware tasks. For example, in libhugetlbfs 2.14:
>
> mmap-gettest 10 32783 (2M: 64): <---- hit VM_BUG_ON_PAGE
> mmap-cow 32782 32783 (2M: 32):  FAIL    Failed to create shared mapping: Cannot allocate memory
> mmap-cow 32782 32783 (2M: 64):  FAIL    Failed to create shared mapping: Cannot allocate memory
>
> While I have not looked into why 'mmap-gettest' keeps failing, it is of no
> importance to this particular issue. This problem is similar to why we have
> the hugetlb_instantiation_mutex, hugepages are quite finite.
>
> Revert the use of VM_BUG_ON_PAGE back to just VM_BUG_ON.

VM_BUG_ON_PAGE is just a VM_BUG_ON that does dump_page before the BUG().

The only reason to use VM_BUG_ON instead of VM_BUG_ON_PAGE is if the page you're working
with doesn't make sense/isn't useful as debug output.

If doing a dump_page is causing issues somewhere then dump_pages should be fixed - instead
of hiding the problem under the rug by not using it.


Thanks,
sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
