Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PIu1ho004016
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 14:56:01 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PIu1K2185446
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 14:56:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PItt0T026160
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 14:55:56 -0400
Date: Fri, 25 Apr 2008 11:55:43 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 12/18] hugetlbfs: support larger than MAX_ORDER
Message-ID: <20080425185543.GA14623@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.965631000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015430.965631000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:14 +1000], npiggin@suse.de wrote:
> This is needed on x86-64 to handle GB pages in hugetlbfs, because it is
> not practical to enlarge MAX_ORDER to 1GB. 
> 
> Instead the 1GB pages are only allocated at boot using the bootmem
> allocator using the hugepages=... option.
> 
> These 1G bootmem pages are never freed. In theory it would be possible
> to implement that with some complications, but since it would be a one-way
> street (>= MAX_ORDER pages cannot be allocated later) I decided not to
> currently.
> 
> The >= MAX_ORDER code is not ifdef'ed per architecture. It is not very big
> and the ifdef uglyness seemed not be worth it.
> 
> Known problems: /proc/meminfo and "free" do not display the memory 
> allocated for gb pages in "Total". This is a little confusing for the
> user.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  mm/hugetlb.c |   74 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 72 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -14,6 +14,7 @@
>  #include <linux/mempolicy.h>
>  #include <linux/cpuset.h>
>  #include <linux/mutex.h>
> +#include <linux/bootmem.h>
> 
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
> @@ -160,7 +161,7 @@ static void free_huge_page(struct page *
>  	INIT_LIST_HEAD(&page->lru);
> 
>  	spin_lock(&hugetlb_lock);
> -	if (h->surplus_huge_pages_node[nid]) {
> +	if (h->surplus_huge_pages_node[nid] && h->order < MAX_ORDER) {

Shouldn't all h->order accesses actually be using the huge_page_order()
to be consistent?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
