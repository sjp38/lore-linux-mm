Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id BEA3F6B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 05:06:51 -0500 (EST)
Received: by wmec201 with SMTP id c201so64576614wme.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 02:06:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a80si3111845wmd.0.2015.11.20.02.06.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 02:06:50 -0800 (PST)
Subject: Re: hugepage compaction causes performance drop
References: <20151119092920.GA11806@aaronlu.sh.intel.com>
 <564DCEA6.3000802@suse.cz> <564EDFE5.5010709@intel.com>
 <564EE8FD.7090702@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564EF0B6.10508@suse.cz>
Date: Fri, 20 Nov 2015 11:06:46 +0100
MIME-Version: 1.0
In-Reply-To: <564EE8FD.7090702@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, lkp@lists.01.org, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 11/20/2015 10:33 AM, Aaron Lu wrote:
> On 11/20/2015 04:55 PM, Aaron Lu wrote:
>> On 11/19/2015 09:29 PM, Vlastimil Babka wrote:
>>> +CC Andrea, David, Joonsoo
>>>
>>> On 11/19/2015 10:29 AM, Aaron Lu wrote:
>>>> The vmstat and perf-profile are also attached, please let me know if you
>>>> need any more information, thanks.
>>>
>>> Output from vmstat (the tool) isn't much useful here, a periodic "cat
>>> /proc/vmstat" would be much better.
>>
>> No problem.
>>
>>> The perf profiles are somewhat weirdly sorted by children cost (?), but
>>> I noticed a very high cost (46%) in pageblock_pfn_to_page(). This could
>>> be due to a very large but sparsely populated zone. Could you provide
>>> /proc/zoneinfo?
>>
>> Is a one time /proc/zoneinfo enough or also a periodic one?
>
> Please see attached, note that this is a new run so the perf profile is
> a little different.
>
> Thanks,
> Aaron

Thanks.

DMA32 is a bit sparse:

Node 0, zone    DMA32
   pages free     62829
         min      327
         low      408
         high     490
         scanned  0
         spanned  1044480
         present  495951
         managed  479559

Since the other zones are much larger, probably this is not the culprit. 
But tracepoints should tell us more. I have a theory that updating free 
scanner's cached pfn doesn't happen if it aborts due to need_resched() 
during isolate_freepages(), before hitting a valid pageblock, if the 
zone has a large hole in it. But zoneinfo doesn't tell us if the large 
difference between "spanned" and "present"/"managed" is due to a large 
hole, or many smaller holes...

compact_migrate_scanned 1982396
compact_free_scanned 40576943
compact_isolated 2096602
compact_stall 9070
compact_fail 6025
compact_success 3045

So it's struggling to find free pages, no wonder about that. I'm working 
on a series that should hopefully help here, and Joonsoo as well.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
