Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6357E6B0036
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 21:23:34 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so297863pab.6
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 18:23:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ok13si6578077pdb.5.2014.07.15.18.23.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 18:23:33 -0700 (PDT)
Message-ID: <53C5D3D2.8080000@oracle.com>
Date: Wed, 16 Jul 2014 09:22:26 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [patch v2] mm, tmp: only collapse hugepages to nodes with affinity
 for zone_reclaim_mode
References: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com> <alpine.DEB.2.02.1407151712520.12279@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407151712520.12279@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On 07/16/2014 08:13 AM, David Rientjes wrote:
> Commit 9f1b868a13ac ("mm: thp: khugepaged: add policy for finding target 
> node") improved the previous khugepaged logic which allocated a 
> transparent hugepages from the node of the first page being collapsed.
> 
> However, it is still possible to collapse pages to remote memory which may 
> suffer from additional access latency.  With the current policy, it is 
> possible that 255 pages (with PAGE_SHIFT == 12) will be collapsed remotely 
> if the majority are allocated from that node.
> 
> When zone_reclaim_mode is enabled, it means the VM should make every attempt
> to allocate locally to prevent NUMA performance degradation.  In this case,
> we do not want to collapse hugepages to remote nodes that would suffer from
> increased access latency.  Thus, when zone_reclaim_mode is enabled, only
> allow collapsing to nodes with RECLAIM_DISTANCE or less.
> 
> There is no functional change for systems that disable zone_reclaim_mode.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  v2: only change behavior for zone_reclaim_mode per Dave Hansen
> 
>  mm/huge_memory.c | 31 +++++++++++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2234,6 +2234,26 @@ static void khugepaged_alloc_sleep(void)
>  static int khugepaged_node_load[MAX_NUMNODES];
>  
>  #ifdef CONFIG_NUMA
> +static bool khugepaged_scan_abort(int nid)
> +{
> +	int i;
> +
> +	/*
> +	 * If zone_reclaim_mode is disabled, then no extra effort is made to
> +	 * allocate memory locally.
> +	 */
> +	if (!zone_reclaim_mode)
> +		return false;
> +
> +	for (i = 0; i < MAX_NUMNODES; i++) {
> +		if (!khugepaged_node_load[i])
> +			continue;
> +		if (node_distance(nid, i) > RECLAIM_DISTANCE)
> +			return true;
> +	}
> +	return false;
> +}
> +
>  static int khugepaged_find_target_node(void)
>  {
>  	static int last_khugepaged_target_node = NUMA_NO_NODE;
> @@ -2309,6 +2329,11 @@ static struct page
>  	return *hpage;
>  }
>  #else
> +static bool khugepaged_scan_abort(int nid)
> +{
> +	return false;
> +}
> +
>  static int khugepaged_find_target_node(void)
>  {
>  	return 0;
> @@ -2515,6 +2540,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  	unsigned long _address;
>  	spinlock_t *ptl;
>  	int node = NUMA_NO_NODE;
> +	int last_node = node;
>  
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>  
> @@ -2545,6 +2571,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  		 * hit record.
>  		 */
>  		node = page_to_nid(page);
> +		if (node != last_node) {
> +			if (khugepaged_scan_abort(node))
> +				goto out_unmap;

Nitpick: How about not break the loop but only reset the related
khugepaged_node_load[] to zero. E.g. modify khugepaged_scan_abort() like
this:
if (node_distance(nid, i) > RECLAIM_DISTANCE)
   khugepaged_node_load[i] = 0;

By this way, we may have a chance to find a more suitable node.

> +			last_node = node;
> +		}
>  		khugepaged_node_load[node]++;
>  		VM_BUG_ON_PAGE(PageCompound(page), page);
>  		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
