Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 848612806CB
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 15:45:49 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 30so17508888qtw.19
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 12:45:49 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id j4si23568110qtc.331.2017.04.13.12.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 12:45:48 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id v3so9247423qtd.3
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 12:45:48 -0700 (PDT)
Subject: Re: [PATCH 2/9] mm, memory_hotplug: use node instead of zone in
 can_online_high_movable
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-3-mhocko@kernel.org>
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Message-ID: <9c2fab88-f49d-b08b-b650-e91d7121a760@gmail.com>
Date: Thu, 13 Apr 2017 15:45:46 -0400
MIME-Version: 1.0
In-Reply-To: <20170410110351.12215-3-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On 04/10/2017 07:03 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> the primary purpose of this helper is to query the node state so use
> the node id directly. This is a preparatory patch for later changes.
> 
> This shouldn't introduce any functional change
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>  mm/memory_hotplug.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9ed251811ec3..342332f29364 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -940,15 +940,15 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>   * When CONFIG_MOVABLE_NODE, we permit onlining of a node which doesn't have
>   * normal memory.
>   */
> -static bool can_online_high_movable(struct zone *zone)
> +static bool can_online_high_movable(int nid)
>  {
>  	return true;
>  }
>  #else /* CONFIG_MOVABLE_NODE */
>  /* ensure every online node has NORMAL memory */
> -static bool can_online_high_movable(struct zone *zone)
> +static bool can_online_high_movable(int nid)
>  {
> -	return node_state(zone_to_nid(zone), N_NORMAL_MEMORY);
> +	return node_state(nid, N_NORMAL_MEMORY);
>  }
>  #endif /* CONFIG_MOVABLE_NODE */
>  
> @@ -1082,7 +1082,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  
>  	if ((zone_idx(zone) > ZONE_NORMAL ||
>  	    online_type == MMOP_ONLINE_MOVABLE) &&
> -	    !can_online_high_movable(zone))
> +	    !can_online_high_movable(pfn_to_nid(pfn)))
>  		return -EINVAL;
>  
>  	if (online_type == MMOP_ONLINE_KERNEL) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
