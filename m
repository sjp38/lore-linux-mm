Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 972AF6B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 22:52:40 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 00C653EE1A3
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 11:52:39 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E7CA945DE56
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 11:52:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D0EF645DE54
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 11:52:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C39D3E08002
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 11:52:38 +0900 (JST)
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 723B61DB804B
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 11:52:38 +0900 (JST)
Message-ID: <522E894A.7030803@jp.fujitsu.com>
Date: Tue, 10 Sep 2013 11:51:54 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: thp: khugepaged: add policy for finding target
 node
References: <1378093542-31971-1-git-send-email-bob.liu@oracle.com> <1378093542-31971-2-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1378093542-31971-2-git-send-email-bob.liu@oracle.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, konrad.wilk@oracle.com, davidoff@qedmf.net, Bob Liu <bob.liu@oracle.com>

(2013/09/02 12:45), Bob Liu wrote:
> Currently khugepaged will try to merge HPAGE_PMD_NR normal pages to a huge page
> which is allocated from the node of the first normal page, this policy is very
> rough and may affect userland applications.
> Andrew Davidoff reported a related issue several days ago.
> 
> Using "numactl --interleave=all ./test" to run the testcase, but the result
> wasn't not as expected.
> cat /proc/2814/numa_maps:
> 7f50bd440000 interleave:0-3 anon=51403 dirty=51403 N0=435 N1=435 N2=435
> N3=50098
> The end results showed that most pages are from Node3 instead of interleave
> among node0-3 which was unreasonable.
> 

> This patch adds a more complicated policy.
> When searching HPAGE_PMD_NR normal pages, record which node those pages come
> from. Alway allocate hugepage from the node with the max record. If several
> nodes have the same max record, try to interleave among them.

I don't understand this policy. Why does ths patch allocate hugepage from the
node with the max record?

> 
> After this patch the result was as expected:
> 7f78399c0000 interleave:0-3 anon=51403 dirty=51403 N0=12723 N1=12723 N2=13235
> N3=12722
> 
> The simple testcase is like this:
> #include<stdio.h>
> #include<stdlib.h>
> 
> int main() {
> 	char *p;
> 	int i;
> 	int j;
> 
> 	for (i=0; i < 200; i++) {
> 		p = (char *)malloc(1048576);
> 		printf("malloc done\n");
> 
> 		if (p == 0) {
> 			printf("Out of memory\n");
> 			return 1;
> 		}
> 		for (j=0; j < 1048576; j++) {
> 			p[j] = 'A';
> 		}
> 		printf("touched memory\n");
> 
> 		sleep(1);
> 	}
> 	printf("enter sleep\n");
> 	while(1) {
> 		sleep(100);
> 	}
> }
> 
> Reported-by: Andrew Davidoff <davidoff@qedmf.net>
> Signed-off-by: Bob Liu <bob.liu@oracle.com>
> ---
>   mm/huge_memory.c |   50 +++++++++++++++++++++++++++++++++++++++++---------
>   1 file changed, 41 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7448cf9..86c7f0d 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2144,7 +2144,33 @@ static void khugepaged_alloc_sleep(void)
>   			msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
>   }
>   
> +static int khugepaged_node_load[MAX_NUMNODES];
>   #ifdef CONFIG_NUMA
> +static int last_khugepaged_target_node = NUMA_NO_NODE;
> +static int khugepaged_find_target_node(void)
> +{

> +	int i, target_node = 0, max_value = 1;

i is used as node ids. So please use node or nid instead of i.

> +

> +	/* find first node with most normal pages hit */
> +	for (i = 0; i < MAX_NUMNODES; i++)
> +		if (khugepaged_node_load[i] > max_value) {
> +			max_value = khugepaged_node_load[i];
> +			target_node = i;
> +		}

khugepaged_node_load[] is initialized as 0 and max_value is initialized
as 1. So this loop does not work well until khugepage_node_load[] is set
to 2 or more. How about initializing max_value to 0?


> +
> +	/* do some balance if several nodes have the same hit number */
> +	if (target_node <= last_khugepaged_target_node) {
> +		for (i = last_khugepaged_target_node + 1; i < MAX_NUMNODES; i++)
> +			if (max_value == khugepaged_node_load[i]) {
> +				target_node = i;
> +				break;
> +			}
> +	}
> +
> +	last_khugepaged_target_node = target_node;
> +	return target_node;
> +}
> +
>   static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
>   {
>   	if (IS_ERR(*hpage)) {
> @@ -2178,9 +2204,8 @@ static struct page
>   	 * mmap_sem in read mode is good idea also to allow greater
>   	 * scalability.
>   	 */

> -	*hpage  = alloc_hugepage_vma(khugepaged_defrag(), vma, address,
> -				      node, __GFP_OTHER_NODE);
> -
> +	*hpage = alloc_pages_exact_node(node, alloc_hugepage_gfpmask(
> +			khugepaged_defrag(), __GFP_OTHER_NODE), HPAGE_PMD_ORDER);

Why do you use alloc_pages_exact_node()?

Thanks,
Yasuaki Ishimatsu

>   	/*
>   	 * After allocating the hugepage, release the mmap_sem read lock in
>   	 * preparation for taking it in write mode.
> @@ -2196,6 +2221,11 @@ static struct page
>   	return *hpage;
>   }
>   #else
> +static int khugepaged_find_target_node(void)
> +{
> +	return 0;
> +}
> +
>   static inline struct page *alloc_hugepage(int defrag)
>   {
>   	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
> @@ -2405,6 +2435,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>   	if (pmd_trans_huge(*pmd))
>   		goto out;
>   
> +	memset(khugepaged_node_load, 0, sizeof(khugepaged_node_load));
>   	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
>   	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
>   	     _pte++, _address += PAGE_SIZE) {
> @@ -2421,12 +2452,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>   		if (unlikely(!page))
>   			goto out_unmap;
>   		/*
> -		 * Chose the node of the first page. This could
> -		 * be more sophisticated and look at more pages,
> -		 * but isn't for now.
> +		 * Chose the node of most normal pages hit, record this
> +		 * informaction to khugepaged_node_load[]
>   		 */
> -		if (node == NUMA_NO_NODE)
> -			node = page_to_nid(page);
> +		node = page_to_nid(page);
> +		khugepaged_node_load[node]++;
>   		VM_BUG_ON(PageCompound(page));
>   		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
>   			goto out_unmap;
> @@ -2441,9 +2471,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>   		ret = 1;
>   out_unmap:
>   	pte_unmap_unlock(pte, ptl);
> -	if (ret)
> +	if (ret) {
> +		node = khugepaged_find_target_node();
>   		/* collapse_huge_page will return with the mmap_sem released */
>   		collapse_huge_page(mm, address, hpage, vma, node);
> +	}
>   out:
>   	return ret;
>   }
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
