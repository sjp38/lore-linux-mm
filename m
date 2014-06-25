Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id E6CA06B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 04:57:40 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w61so1598571wes.15
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 01:57:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eg5si4171555wjd.91.2014.06.25.01.57.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 01:57:37 -0700 (PDT)
Message-ID: <53AA8F00.4000902@suse.cz>
Date: Wed, 25 Jun 2014 10:57:36 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v3 12/13] mm, compaction: try to capture the just-created
 high-order freepage
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz> <1403279383-5862-13-git-send-email-vbabka@suse.cz> <20140625015733.GC12855@nhori.redhat.com>
In-Reply-To: <20140625015733.GC12855@nhori.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On 06/25/2014 03:57 AM, Naoya Horiguchi wrote:
> On Fri, Jun 20, 2014 at 05:49:42PM +0200, Vlastimil Babka wrote:
>> Compaction uses watermark checking to determine if it succeeded in creating
>> a high-order free page. My testing has shown that this is quite racy and it
>> can happen that watermark checking in compaction succeeds, and moments later
>> the watermark checking in page allocation fails, even though the number of
>> free pages has increased meanwhile.
>>
>> It should be more reliable if direct compaction captured the high-order free
>> page as soon as it detects it, and pass it back to allocation. This would
>> also reduce the window for somebody else to allocate the free page.
>>
>> Capture has been implemented before by 1fb3f8ca0e92 ("mm: compaction: capture
>> a suitable high-order page immediately when it is made available"), but later
>> reverted by 8fb74b9f ("mm: compaction: partially revert capture of suitable
>> high-order page") due to a bug.
>>
>> This patch differs from the previous attempt in two aspects:
>>
>> 1) The previous patch scanned free lists to capture the page. In this patch,
>>     only the cc->order aligned block that the migration scanner just finished
>>     is considered, but only if pages were actually isolated for migration in
>>     that block. Tracking cc->order aligned blocks also has benefits for the
>>     following patch that skips blocks where non-migratable pages were found.
>>
>> 2) The operations done in buffered_rmqueue() and get_page_from_freelist() are
>>     closely followed so that page capture mimics normal page allocation as much
>>     as possible. This includes operations such as prep_new_page() and
>>     page->pfmemalloc setting (that was missing in the previous attempt), zone
>>     statistics are updated etc. Due to subtleties with IRQ disabling and
>>     enabling this cannot be simply factored out from the normal allocation
>>     functions without affecting the fastpath.
>>
>> This patch has tripled compaction success rates (as recorded in vmstat) in
>> stress-highalloc mmtests benchmark, although allocation success rates increased
>> only by a few percent. Closer inspection shows that due to the racy watermark
>> checking and lack of lru_add_drain(), the allocations that resulted in direct
>> compactions were often failing, but later allocations succeeeded in the fast
>> path. So the benefit of the patch to allocation success rates may be limited,
>> but it improves the fairness in the sense that whoever spent the time
>> compacting has a higher change of benefitting from it, and also can stop
>> compacting sooner, as page availability is detected immediately. With better
>> success detection, the contribution of compaction to high-order allocation
>> success success rates is also no longer understated by the vmstats.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Michal Nazarewicz <mina86@mina86.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: David Rientjes <rientjes@google.com>
>> ---
> ...
>> @@ -669,6 +708,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>>   				continue;
>>   			if (PageTransHuge(page)) {
>>   				low_pfn += (1 << compound_order(page)) - 1;
>> +				next_capture_pfn = low_pfn + 1;
>
> Don't we need if (next_capture_pfn) here?

Good catch, thanks! It should also use ALIGN properly as the non-locked 
test above.

> Thanks,
> Naoya Horiguchi
>
>>   				continue;
>>   			}
>>   		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
