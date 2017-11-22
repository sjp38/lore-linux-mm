Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 011AD6B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 19:27:58 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v8so8997818wrd.21
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 16:27:57 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z18si11755099eda.277.2017.11.21.16.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 16:27:56 -0800 (PST)
Subject: Re: [PATCH v2] mm: show total hugetlb memory consumption in
 /proc/meminfo
References: <20171115231409.12131-1-guro@fb.com>
 <20171120165110.587918bf75ffecb8144da66c@linux-foundation.org>
 <20171121151545.GA23974@castle>
 <20171121111907.6952d50adcbe435b1b6b4576@linux-foundation.org>
 <20171121195947.GA12709@castle>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <bafb4396-858a-bbbc-743d-43c7312da868@oracle.com>
Date: Tue, 21 Nov 2017 16:27:38 -0800
MIME-Version: 1.0
In-Reply-To: <20171121195947.GA12709@castle>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On 11/21/2017 11:59 AM, Roman Gushchin wrote:
> On Tue, Nov 21, 2017 at 11:19:07AM -0800, Andrew Morton wrote:
>>
>> Why not
>>
>> 	seq_printf(m,
>> 			"HugePages_Total:   %5lu\n"
>> 			"HugePages_Free:    %5lu\n"
>> 			"HugePages_Rsvd:    %5lu\n"
>> 			"HugePages_Surp:    %5lu\n"
>> 			"Hugepagesize:   %8lu kB\n",
>> 			h->nr_huge_pages,
>> 			h->free_huge_pages,
>> 			h->resv_huge_pages,
>> 			h->surplus_huge_pages,
>> 			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
>>
>> 	for_each_hstate(h)
>> 		total += (PAGE_SIZE << huge_page_order(h)) * h->nr_huge_pages;
>> 	seq_printf(m, "Hugetlb:        %8lu kB\n", total / 1024);
>> 	
>> ?
> 
> The idea was that the local variable guarantees the consistency
> between Hugetlb and HugePages_Total numbers. Otherwise we have
> to take hugetlb_lock.

Most important it prevents HugePages_Total from being larger than 
Hugetlb.

> What we can do, is to rename "count" into "nr_huge_pages", like:
> 
> 	for_each_hstate(h) {
> 		unsigned long nr_huge_pages = h->nr_huge_pages;
> 
> 		total += (PAGE_SIZE << huge_page_order(h)) * nr_huge_pages;
> 
> 		if (h == &default_hstate)
> 			seq_printf(m,
> 				   "HugePages_Total:   %5lu\n"
> 				   "HugePages_Free:    %5lu\n"
> 				   "HugePages_Rsvd:    %5lu\n"
> 				   "HugePages_Surp:    %5lu\n"
> 				   "Hugepagesize:   %8lu kB\n",
> 				   nr_huge_pages,
> 				   h->free_huge_pages,
> 				   h->resv_huge_pages,
> 				   h->surplus_huge_pages,
> 				   (PAGE_SIZE << huge_page_order(h)) / 1024);
> 	}
> 
> 	seq_printf(m, "Hugetlb:        %8lu kB\n", total / 1024);
> 
> But maybe taking a lock is not a bad idea, because it will also
> guarantee consistency between other numbers (like HugePages_Free) as well,
> which is not true right now.

You are correct in that there is no consistency guarantee for the numbers
with the default huge page size today.  However, I am not really a fan of
taking the lock for that guarantee.  IMO, the above code is fine.

This discussion reminds me that ideally there should be a per-hstate lock.
My guess is that the global lock is a carry over from the days when only
a single huge page size was supported.  In practice, I don't think this is
much of an issue as people typically only use a single huge page size.  But,
if anyone thinks is/may be an issue I am happy to make the changes.

-- 
Mike Kravetz

> 
> Thanks!
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
