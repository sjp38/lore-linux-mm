Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id DD7386B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 05:18:57 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id y19so1988105wgg.4
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 02:18:57 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dl3si14511244wjb.119.2015.01.13.02.18.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 02:18:56 -0800 (PST)
Message-ID: <54B4F10F.6060005@suse.cz>
Date: Tue, 13 Jan 2015 11:18:55 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch 4/6] mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone
References: <548f68bb.wuNDZDL8qk6xEWTm%akpm@linux-foundation.org>,<alpine.DEB.2.10.1412171537560.16260@chino.kir.corp.google.com> <E0FB9EDDBE1AAD4EA62C90D3B6E4783B739E6CA4@P-EXMB2-DC21.corp.sgi.com>
In-Reply-To: <E0FB9EDDBE1AAD4EA62C90D3B6E4783B739E6CA4@P-EXMB2-DC21.corp.sgi.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Custer <jcuster@sgi.com>, David Rientjes <rientjes@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, Russ Anderson <rja@sgi.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On 12/18/2014 06:16 PM, James Custer wrote:
> Reading the documentation on pageblock_pfn_to_page it checks to see if all
> of
> [start_pfn, end_pfn) is valid and within the same zone. But the validity in the
> entirety of [start_pfn, end_pfn) doesn't seem to be a requirement of
> test_pages_in_a_zone, unless I'm missing something.

(please don't top-post in reply, it makes further replying harder)

Yes there is a subtle difference you point out. So pageblock_pfn_to_page()
cannot be readily used. But a similar approach could still work, but I fear we
might have to distinguish by CONFIG_HOLES_IN_ZONE

a) CONFIG_HOLES_IN_ZONE is disabled, jut check first/last pfn of each pageblock
for validity. If any is valid, check if it belongs to the zone.

b) CONFIG_HOLES_IN_ZONE is enabled: try the above first, but if first or last is
invalid, we probably have to resort to a full pageblock scan, because there
might be holes containing pageblocks boundaries, and the valid pfn's are in the
middle?

Note that compaction just skips over such pageblocks described in case b) if
such configurations even exist. That might be suboptimal, but not fatal. In case
of memory offlining, it could be I guess.



> Disclaimer: I'm very much not familiar with this area of code, and I fixed
this bug based off of documentation that I read.
> 
> Regards, James ________________________________________
> From: David Rientjes [rientjes@google.com]
> Sent: Wednesday, December 17, 2014 5:40 PM
> To: akpm@linux-foundation.org
> Cc: linux-mm@kvack.org; James Custer; isimatu.yasuaki@jp.fujitsu.com; kamezawa.hiroyu@jp.fujitsu.com; Russ Anderson; stable@vger.kernel.org
> Subject: Re: [patch 4/6] mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone
> 
> On Mon, 15 Dec 2014, akpm@linux-foundation.org wrote:
> 
>> diff -puN mm/memory_hotplug.c~mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone mm/memory_hotplug.c
>> --- a/mm/memory_hotplug.c~mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone
>> +++ a/mm/memory_hotplug.c
>> @@ -1331,7 +1331,7 @@ int is_mem_section_removable(unsigned lo
>>  }
>>
>>  /*
>> - * Confirm all pages in a range [start, end) is belongs to the same zone.
>> + * Confirm all pages in a range [start, end) belong to the same zone.
>>   */
>>  int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>>  {
>> @@ -1342,10 +1342,11 @@ int test_pages_in_a_zone(unsigned long s
>>       for (pfn = start_pfn;
>>            pfn < end_pfn;
>>            pfn += MAX_ORDER_NR_PAGES) {
>> -             i = 0;
>> -             /* This is just a CONFIG_HOLES_IN_ZONE check.*/
>> -             while ((i < MAX_ORDER_NR_PAGES) && !pfn_valid_within(pfn + i))
>> -                     i++;
>> +             /* Find the first valid pfn in this pageblock */
>> +             for (i = 0; i < MAX_ORDER_NR_PAGES; i++) {
>> +                     if (pfn_valid(pfn + i))
>> +                             break;
>> +             }
>>               if (i == MAX_ORDER_NR_PAGES)
>>                       continue;
>>               page = pfn_to_page(pfn + i);
> 
> I think it would be much better to implement test_pages_in_a_zone() as a
> wrapper around the logic in memory compaction's pageblock_pfn_to_page()
> that does this exact same check for a pageblock.  It would only need to
> iterate the valid pageblocks in the [start_pfn, end_pfn) range and find
> the zone of the first pfn of the first valid pageblock.  This not only
> removes code, but it also unifies the implementation since your
> implementation above would be slower.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
