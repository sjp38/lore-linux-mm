Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 03D726B0072
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 11:41:56 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so20915559wib.1
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 08:41:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qo2si41735185wjc.150.2015.06.23.08.41.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Jun 2015 08:41:53 -0700 (PDT)
Message-ID: <55897E3F.9050405@suse.cz>
Date: Tue, 23 Jun 2015 17:41:51 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC 2/4] mm, thp: khugepaged checks for THP allocability before
 scanning
References: <1431354940-30740-1-git-send-email-vbabka@suse.cz> <1431354940-30740-3-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1506171739490.8203@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1506171739490.8203@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Alex Thorlton <athorlton@sgi.com>

On 06/18/2015 03:00 AM, David Rientjes wrote:
> On Mon, 11 May 2015, Vlastimil Babka wrote:
>
>> Khugepaged could be scanning for collapse candidates uselessly, if it cannot
>> allocate a hugepage in the end. The hugepage preallocation mechanism prevented
>> this, but only for !NUMA configurations. It was removed by the previous patch,
>> and this patch replaces it with a more generic mechanism.
>>
>> The patch itroduces a thp_avail_nodes nodemask, which initially assumes that
>> hugepage can be allocated on any node. Whenever khugepaged fails to allocate
>> a hugepage, it clears the corresponding node bit. Before scanning for collapse
>> candidates, it tries to allocate a hugepage on each online node with the bit
>> cleared, and set it back on success. It tries to hold on to the hugepage if
>> it doesn't hold any other yet. But the assumption is that even if the hugepage
>> is freed back, it should be possible to allocate it in near future without
>> further reclaim and compaction attempts.
>>
>> During the scaning, khugepaged avoids collapsing on nodes with the bit cleared,
>> as soon as possible. If no nodes have hugepages available, scanning is skipped
>> altogether.
>>
>
> I'm not exactly sure what you mean by avoiding to do something as soon as
> possible.

That's referring to the check when node_load is half the pmd size, which 
you want me to remove :)

>> During testing, the patch did not show much difference in preventing
>> thp_collapse_failed events from khugepaged, but this can be attributed to the
>> sync compaction, which only khugepaged is allowed to use, and which is
>> heavyweight enough to succeed frequently enough nowadays. The next patch will
>> however extend the nodemask check to page fault context, where it has much
>> larger impact. Also, with the future plan to convert THP collapsing to
>> task_work context, this patch is a preparation to avoid useless scanning or
>> heavyweight THP allocations in that context.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>   mm/huge_memory.c | 71 +++++++++++++++++++++++++++++++++++++++++++++++++-------
>>   1 file changed, 63 insertions(+), 8 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 565864b..b86a72a 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -102,7 +102,7 @@ struct khugepaged_scan {
>>   static struct khugepaged_scan khugepaged_scan = {
>>   	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
>>   };
>> -
>> +static nodemask_t thp_avail_nodes = NODE_MASK_ALL;
>
> Seems like it should have khugepaged in its name so it's understood that
> the nodemask doesn't need to be synchronized, even though it will later be
> read outside of khugepaged, or at least a comment to say only khugepaged
> can store to it.

After patch 3, bits can be cleared from the mask also outside of 
khugepaged, i.e. when THP allocations fail on page fault.
But, node_set() and node_clear() use the atomic bitmap functions 
set_bit() and clear_bit(), so it is in fact synchronized.

>>
>>   static int set_recommended_min_free_kbytes(void)
>>   {
>> @@ -2273,6 +2273,14 @@ static bool khugepaged_scan_abort(int nid)
>>   	int i;
>>
>>   	/*
>> +	 * If it's clear that we are going to select a node where THP
>> +	 * allocation is unlikely to succeed, abort
>> +	 */
>> +	if (khugepaged_node_load[nid] == (HPAGE_PMD_NR / 2) &&
>> +				!node_isset(nid, thp_avail_nodes))
>> +		return true;
>> +
>> +	/*
>>   	 * If zone_reclaim_mode is disabled, then no extra effort is made to
>>   	 * allocate memory locally.
>>   	 */
>
> If khugepaged_node_load for a node doesn't reach HPAGE_PMD_NR / 2, then
> this doesn't cause an abort.

Yes such situation is also covered.

> I don't think it's necessary to try to
> optimize and abort the scan early when this is met, I think this should
> only be checked before collapse_huge_page().

Avoiding potentially 256 iterations of a loop sounds good to me, no?
The check shouldn't be expensive thanks to short-circuiting the other 
part.:)

>> @@ -2356,6 +2364,7 @@ static struct page
>>   	if (unlikely(!*hpage)) {
>>   		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
>>   		*hpage = ERR_PTR(-ENOMEM);
>> +		node_clear(node, thp_avail_nodes);
>>   		return NULL;
>>   	}
>>
>> @@ -2363,6 +2372,42 @@ static struct page
>>   	return *hpage;
>>   }
>>
>> +/* Return true, if THP should be allocatable on at least one node */
>> +static bool khugepaged_check_nodes(struct page **hpage)
>> +{
>> +	bool ret = false;
>> +	int nid;
>> +	struct page *newpage = NULL;
>> +	gfp_t gfp = alloc_hugepage_gfpmask(khugepaged_defrag());
>> +
>> +	for_each_online_node(nid) {
>> +		if (node_isset(nid, thp_avail_nodes)) {
>> +			ret = true;
>> +			continue;
>> +		}
>> +
>> +		newpage = alloc_hugepage_node(gfp, nid);
>> +
>> +		if (newpage) {
>> +			node_set(nid, thp_avail_nodes);
>> +			ret = true;
>> +			/*
>> +			 * Heuristic - try to hold on to the page for collapse
>> +			 * scanning, if we don't hold any yet.
>> +			 */
>> +			if (IS_ERR_OR_NULL(*hpage)) {
>> +				*hpage = newpage;
>> +				//NIXME: should we count all/no allocations?
>> +				count_vm_event(THP_COLLAPSE_ALLOC);
>
> Seems like we'd only count the event when the node load has selected a
> target node and the hugepage that is allocated here is used, but if this

Yeah even the node preallocation was misleading in this regard (see 
commit log of patch 1).

> approach is adopted then I think you'll need to introduce a new event to
> track when a hugepage is allocated and subsequently dropped.

Alternatively add event for successful collapses (and keep the current 
one for allocations). It is exported now under /sys but having that in 
vmstat would be more consistent.
Then the count of pages subsequently dropped is simply the difference 
between collapse allocations and collapses (with some rather negligible 
amount possibly being held waiting as you suggest below).
I think this approach would be better as we wouldn't change semantic of 
existing THP_COLLAPSE_ALLOC event?

>
>> +			} else {
>> +				put_page(newpage);
>> +			}
>
> Eek, rather than do put_page() why not store a preallocated hugepage for
> every node and let khugepaged_alloc_page() use it?  It would be
> unfortunate that page_to_nid(*hpage) may not equal the target node after
> scanning.

I considered that but were afraid that if those pages' nodes ended up 
not selected, the stored pages would just occupy memory. But maybe I 
could introduce a shrinker for freeing those?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
