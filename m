Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 032FF6B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 10:55:59 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id hc3so68880812pac.4
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 07:55:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c22si133040pfl.262.2016.11.09.07.55.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 07:55:57 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA9FrZaH042102
	for <linux-mm@kvack.org>; Wed, 9 Nov 2016 10:55:57 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26m22qyaxv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 09 Nov 2016 10:55:56 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 9 Nov 2016 15:55:54 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id CE8251B0805F
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 15:58:04 +0000 (GMT)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA9Ftpd129425886
	for <linux-mm@kvack.org>; Wed, 9 Nov 2016 15:55:51 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA9FtpR0029664
	for <linux-mm@kvack.org>; Wed, 9 Nov 2016 08:55:51 -0700
Date: Wed, 9 Nov 2016 16:55:49 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH v2 2/2] mm: hugetlb: support gigantic surplus pages
In-Reply-To: <1478675294-2507-1-git-send-email-shijie.huang@arm.com>
References: <1478141499-13825-3-git-send-email-shijie.huang@arm.com>
	<1478675294-2507-1-git-send-email-shijie.huang@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20161109165549.1cf320c5@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Wed, 9 Nov 2016 15:08:14 +0800
Huang Shijie <shijie.huang@arm.com> wrote:

> When testing the gigantic page whose order is too large for the buddy
> allocator, the libhugetlbfs test case "counter.sh" will fail.
> 
> The failure is caused by:
>  1) kernel fails to allocate a gigantic page for the surplus case.
>     And the gather_surplus_pages() will return NULL in the end.
> 
>  2) The condition checks for "over-commit" is wrong.
> 
> This patch adds code to allocate the gigantic page in the
> __alloc_huge_page(). After this patch, gather_surplus_pages()
> can return a gigantic page for the surplus case.
> 
> This patch changes the condition checks for:
>      return_unused_surplus_pages()
>      nr_overcommit_hugepages_store()
>      hugetlb_overcommit_handler()
> 
> This patch also set @nid with proper value when NUMA_NO_NODE is
> passed to alloc_gigantic_page().
> 
> After this patch, the counter.sh can pass for the gigantic page.
> 
> Acked-by: Steve Capper <steve.capper@arm.com>
> Signed-off-by: Huang Shijie <shijie.huang@arm.com>
> ---
>   1. fix the wrong check in hugetlb_overcommit_handler();
>   2. try to fix the s390 issue.
> ---
>  mm/hugetlb.c | 20 ++++++++++++++------
>  1 file changed, 14 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 9fdfc24..5dbfd62 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1095,6 +1095,9 @@ static struct page *alloc_gigantic_page(int nid, unsigned int order)
>  	unsigned long ret, pfn, flags;
>  	struct zone *z;
> 
> +	if (nid == NUMA_NO_NODE)
> +		nid = numa_mem_id();
> +

Now counter.sh works (on s390) w/o the lockdep warning. However, it looks
like this change will now result in inconsistent behavior compared to the
normal sized hugepages, regarding surplus page allocation. Setting nid to
numa_mem_id() means that only the node of the current CPU will be considered
for allocating a gigantic page, as opposed to just "preferring" the current
node in the normal size case (__hugetlb_alloc_buddy_huge_page() ->
alloc_pages_node()) with a fallback to using other nodes.

I am not really familiar with NUMA, and I might be wrong here, but if
this is true then gigantic pages, which may be hard allocate at runtime
in general, will be even harder to find (as surplus pages) because you
only look on the current node.

I honestly do not understand why alloc_gigantic_page() needs a nid
parameter at all, since it looks like it will only be called from
alloc_fresh_gigantic_page_node(), which in turn is only called
from alloc_fresh_gigantic_page() in a "for_each_node" loop (at least
before your patch).

Now it could be an option to also use alloc_fresh_gigantic_page()
in your patch, instead of directly calling alloc_gigantic_page(),
in __alloc_huge_page(). This would fix the "local node only" issue,
but I am not sure how to handle the required nodes_allowed parameter.

Maybe someone with more NUMA insight could have a look at this.
The patch as it is also seems to work, with the "local node only"
restriction, so it may be an option to just accept this restriction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
