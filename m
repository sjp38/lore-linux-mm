Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2D16B0037
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 04:50:56 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so7178411wib.1
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 01:50:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k3si4204938wja.3.2014.06.25.01.50.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 01:50:54 -0700 (PDT)
Message-ID: <53AA8D6B.6090301@suse.cz>
Date: Wed, 25 Jun 2014 10:50:51 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/13] mm, compaction: move pageblock checks up from
 isolate_migratepages_range()
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz> <1403279383-5862-5-git-send-email-vbabka@suse.cz> <20140624045252.GA18289@nhori.bos.redhat.com> <53A99A88.1040500@suse.cz> <20140624165821.GC18289@nhori.bos.redhat.com>
In-Reply-To: <20140624165821.GC18289@nhori.bos.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On 06/24/2014 06:58 PM, Naoya Horiguchi wrote:
> On Tue, Jun 24, 2014 at 05:34:32PM +0200, Vlastimil Babka wrote:
>> On 06/24/2014 06:52 AM, Naoya Horiguchi wrote:
>>>> -	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn, false);
>>>> -	if (!low_pfn || cc->contended)
>>>> -		return ISOLATE_ABORT;
>>>> +		/* Do not scan within a memory hole */
>>>> +		if (!pfn_valid(low_pfn))
>>>> +			continue;
>>>> +
>>>> +		page = pfn_to_page(low_pfn);
>>>
>>> Can we move (page_zone != zone) check here as isolate_freepages() does?
>>
>> Duplicate perhaps, not sure about move.
>
> Sorry for my unclearness.
> I meant that we had better do this check in per-pageblock loop (as the free
> scanner does) instead of in per-pfn loop (as we do now.)

Hm I see, the migration and free scanners really do this differently. 
Free scanned per-pageblock, but migration scanner per-page.
Can we assume that zones will never overlap within a single pageblock?
The example dc9086004 seems to be overlapping at even higher alignment 
so it should be safe only to check first page in pageblock.
And if it wasn't the case, then I guess the freepage scanner would 
already hit some errors on such system?

But if that's true, why does page_is_buddy test if pages are in the same 
zone?

>> Does CMA make sure that all pages
>> are in the same zone?
>
> It seems not, CMA just specifies start pfn and end pfn, so it can cover
> multiple zones.
> And we also have a case of node overlapping as commented in commit dc9086004
> "mm: compaction: check for overlapping nodes during isolation for migration".
> So we need this check in compaction side.
>
> Thanks,
> Naoya Horiguchi
>
>> Common sense tells me it would be useless otherwise,
>> but I haven't checked if we can rely on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
