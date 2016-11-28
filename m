Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D982A6B025E
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:20:07 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a20so37469404wme.5
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:20:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10si26048486wma.60.2016.11.28.06.20.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 06:20:06 -0800 (PST)
Subject: Re: [PATCH v2 0/6] mm: fix the "counter.sh" failure for libhugetlbfs
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6b83ea5d-a465-7582-a215-51a21fb4ce2e@suse.cz>
Date: Mon, 28 Nov 2016 15:20:05 +0100
MIME-Version: 1.0
In-Reply-To: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>, akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On 11/14/2016 08:07 AM, Huang Shijie wrote:
> (1) Background
>    For the arm64, the hugetlb page size can be 32M (PMD + Contiguous bit).
>    In the 4K page environment, the max page order is 10 (max_order - 1),
>    so 32M page is the gigantic page.
>
>    The arm64 MMU supports a Contiguous bit which is a hint that the TTE
>    is one of a set of contiguous entries which can be cached in a single
>    TLB entry.  Please refer to the arm64v8 mannul :
>        DDI0487A_f_armv8_arm.pdf (in page D4-1811)
>
> (2) The bug
>    After I tested the libhugetlbfs, I found the test case "counter.sh"
>    will fail with the gigantic page (32M page in arm64 board).
>
>    This patch set adds support for gigantic surplus hugetlb pages,
>    allowing the counter.sh unit test to pass.
>
> v1 -- > v2:
>    1.) fix the compiler error in X86.
>    2.) add new patches for NUMA.
>        The patch #2 ~ #5 are new patches.
>
> Huang Shijie (6):
>   mm: hugetlb: rename some allocation functions
>   mm: hugetlb: add a new parameter for some functions
>   mm: hugetlb: change the return type for alloc_fresh_gigantic_page
>   mm: mempolicy: intruduce a helper huge_nodemask()
>   mm: hugetlb: add a new function to allocate a new gigantic page
>   mm: hugetlb: support gigantic surplus pages
>
>  include/linux/mempolicy.h |   8 +++
>  mm/hugetlb.c              | 128 ++++++++++++++++++++++++++++++++++++----------
>  mm/mempolicy.c            |  20 ++++++++
>  3 files changed, 130 insertions(+), 26 deletions(-)

Can't say I'm entirely happy with the continued direction of maze of 
functions for huge page allocation :( Feels like path of least 
resistance to basically copy/paste the missing parts here. Is there no 
way to consolidate the code more?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
