Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9ADF26B006E
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:05:31 -0400 (EDT)
Received: by qcsf5 with SMTP id f5so3663323qcs.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 07:05:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i8si9640141qgf.23.2015.06.15.07.05.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 07:05:31 -0700 (PDT)
Message-ID: <557EDBA2.9090308@redhat.com>
Date: Mon, 15 Jun 2015 10:05:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/3] mm: make optimistic check for swapin readahead
References: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com> <1434294283-8699-3-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1434294283-8699-3-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On 06/14/2015 11:04 AM, Ebru Akagunduz wrote:
> This patch makes optimistic check for swapin readahead
> to increase thp collapse rate. Before getting swapped
> out pages to memory, checks them and allows up to a
> certain number. It also prints out using tracepoints
> amount of unmapped ptes.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>

> @@ -2639,11 +2640,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  {
>  	pmd_t *pmd;
>  	pte_t *pte, *_pte;
> -	int ret = 0, none_or_zero = 0;
> +	int ret = 0, none_or_zero = 0, unmapped = 0;
>  	struct page *page;
>  	unsigned long _address;
>  	spinlock_t *ptl;
> -	int node = NUMA_NO_NODE;
> +	int node = NUMA_NO_NODE, max_ptes_swap = HPAGE_PMD_NR/8;
>  	bool writable = false, referenced = false;

This has the effect of only swapping in 4kB pages to form a THP
if 7/8th of the THP is already resident in memory.

This is a pretty conservative thing to do.

I am not sure if we would also need to take into account things
like these:
1) How many pages in the THP-area are recently referenced?
   Maybe this does not matter if 87.5% of the 4kB pages got
   faulted in after swap-out, anyway?
2) How much free memory does the system have?
   We don't test that for collapsing a THP with lots of
   pte_none() ptes, so not sure how much this matters...
3) How many of the pages we want to swap in are already resident
   in the swap cache?
   Not sure exactly what to do with this number...
4) other factors?

I am also not sure how we would determine such a policy, except
by maybe having these patches sit in -mm and -next for a few
cycles, and seeing what happens...


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
