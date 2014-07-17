Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9486B007D
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 12:28:33 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so3634378pad.21
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 09:28:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id c9si1460402pds.66.2014.07.17.09.28.30
        for <linux-mm@kvack.org>;
        Thu, 17 Jul 2014 09:28:31 -0700 (PDT)
Message-ID: <53C7F9AC.1080007@intel.com>
Date: Thu, 17 Jul 2014 09:28:28 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [patch v3] mm, thp: only collapse hugepages to nodes with affinity
 for zone_reclaim_mode
References: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com> <alpine.DEB.2.02.1407151712520.12279@chino.kir.corp.google.com> <53C69C7B.1010709@suse.cz> <alpine.DEB.2.02.1407161754000.23892@chino.kir.corp.google.com> <alpine.DEB.2.02.1407161757500.23892@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407161757500.23892@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/16/2014 05:59 PM, David Rientjes wrote:
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
>  v3: optimization based on previous node counts per Vlastimil Babka
> 
>  mm/huge_memory.c | 31 +++++++++++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2234,6 +2234,30 @@ static void khugepaged_alloc_sleep(void)
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
> +	/* If there is a count for this node already, it must be acceptable */
> +	if (khugepaged_node_load[nid])
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
> @@ -2309,6 +2333,11 @@ static struct page
>  	return *hpage;
>  }
>  #else
> +static bool khugepaged_scan_abort(int nid)
> +{
> +	return false;
> +}

Minor nit: I guess this makes it more explicit, but this #ifdef is
unnecessary in practice because we define zone_reclaim_mode this way:

#ifdef CONFIG_NUMA
extern int zone_reclaim_mode;
#else
#define zone_reclaim_mode 0
#endif

Looks fine to me otherwise, though.  Definitely addresses the concerns I
had about RECLAIM_DISTANCE being consulted directly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
