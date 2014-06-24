Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC576B003B
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 11:34:34 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id k14so574927wgh.18
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 08:34:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id la3si920156wjb.23.2014.06.24.08.34.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 08:34:33 -0700 (PDT)
Message-ID: <53A99A88.1040500@suse.cz>
Date: Tue, 24 Jun 2014 17:34:32 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/13] mm, compaction: move pageblock checks up from
 isolate_migratepages_range()
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz> <1403279383-5862-5-git-send-email-vbabka@suse.cz> <20140624045252.GA18289@nhori.bos.redhat.com>
In-Reply-To: <20140624045252.GA18289@nhori.bos.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On 06/24/2014 06:52 AM, Naoya Horiguchi wrote:
>> -	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn, false);
>> -	if (!low_pfn || cc->contended)
>> -		return ISOLATE_ABORT;
>> +		/* Do not scan within a memory hole */
>> +		if (!pfn_valid(low_pfn))
>> +			continue;
>> +
>> +		page = pfn_to_page(low_pfn);
>
> Can we move (page_zone != zone) check here as isolate_freepages() does?

Duplicate perhaps, not sure about move. Does CMA make sure that all 
pages are in the same zone? Common sense tells me it would be useless 
otherwise, but I haven't checked if we can rely on it.

> Thanks,
> Naoya Horiguchi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
