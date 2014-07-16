Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 60E1B6B00B3
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 11:47:44 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id m15so1060787wgh.17
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 08:47:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bw8si24459347wjb.69.2014.07.16.08.47.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 08:47:35 -0700 (PDT)
Message-ID: <53C69E92.70608@suse.cz>
Date: Wed, 16 Jul 2014 17:47:30 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v2] mm, tmp: only collapse hugepages to nodes with affinity
 for zone_reclaim_mode
References: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com> <alpine.DEB.2.02.1407151712520.12279@chino.kir.corp.google.com> <53C5D3D2.8080000@oracle.com>
In-Reply-To: <53C5D3D2.8080000@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/16/2014 03:22 AM, Bob Liu wrote:
>> @@ -2545,6 +2571,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>>  		 * hit record.
>>  		 */
>>  		node = page_to_nid(page);
>> +		if (node != last_node) {
>> +			if (khugepaged_scan_abort(node))
>> +				goto out_unmap;
> 
> Nitpick: How about not break the loop but only reset the related
> khugepaged_node_load[] to zero. E.g. modify khugepaged_scan_abort() like
> this:
> if (node_distance(nid, i) > RECLAIM_DISTANCE)
>    khugepaged_node_load[i] = 0;
> 
> By this way, we may have a chance to find a more suitable node.

Hm theoretically there might be a suitable node, but this approach wouldn't
work. By resetting it to zero you forget that there ever was node 'i'. If there
is no more base page from node 'i', the load remains zero and the next call with
'nid' will think that 'nid' is OK.

So the correct way would be more complex but I wonder if it's worth the trouble...

>> +			last_node = node;
>> +		}
>>  		khugepaged_node_load[node]++;
>>  		VM_BUG_ON_PAGE(PageCompound(page), page);
>>  		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
>> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
