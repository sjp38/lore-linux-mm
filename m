Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 07AA48D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 18:47:37 -0400 (EDT)
Message-ID: <4D93B302.9090103@oracle.com>
Date: Wed, 30 Mar 2011 15:47:30 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix setup_zone_pageset section mismatch
References: <20110324132435.4ee9694e.randy.dunlap@oracle.com> <20110330150510.bc02d041.akpm@linux-foundation.org>
In-Reply-To: <20110330150510.bc02d041.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Paul Mundt <lethal@linux-sh.org>

On 03/30/11 15:05, Andrew Morton wrote:
> On Thu, 24 Mar 2011 13:24:35 -0700
> Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>
>> Fix section mismatch warning:
>> setup_zone_pageset() is called from build_all_zonelists(),
>> which can be called at any time by NUMA sysctl handler
>> numa_zonelist_order_handler(),
>> so it should not be marked as __meminit.
>>
>> WARNING: mm/built-in.o(.text+0xab17): Section mismatch in reference from the function build_all_zonelists() to the function .meminit.text:setup_zone_pageset()
>> The function build_all_zonelists() references
>> the function __meminit setup_zone_pageset().
>> This is often because build_all_zonelists lacks a __meminit 
>> annotation or the annotation of setup_zone_pageset is wrong.
>>
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>> ---
>>  mm/page_alloc.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> --- linux-2.6.38-git13.orig/mm/page_alloc.c
>> +++ linux-2.6.38-git13/mm/page_alloc.c
>> @@ -3511,7 +3511,7 @@ static void setup_pagelist_highmark(stru
>>  		pcp->batch = PAGE_SHIFT * 8;
>>  }
>>  
>> -static __meminit void setup_zone_pageset(struct zone *zone)
>> +static void setup_zone_pageset(struct zone *zone)
>>  {
>>  	int cpu;
>>  
> 
> I already merged Paul Mundt's patch whcih marks build_all_zonelists()
> as __ref.  That seems a better solution?

Merged where?  mmotm?

2.6.39-rc1 still has this section mismatch warning.
If Paul's patch fixes the warning, I'm OK with it.

> I'm rather wondering if we did all this the right way anyway.  The call
> from build_all_zonelists() into setup_zone_pageset() is inside #ifdef
> CONFIG_MEMORY_HOTPLUG, so there is clearly no bug here.  But the build
> system generated a warning anyway.  Why'd it do that?

It's a mystery.

> If we'd handled the section via
> 
> #ifdef CONFIG_MEMORY_HOTPLUG
> #define __meminit
> #else
> #define __meminit __init
> #endif
> 
> of similar then that would fix things.  iirc we used to do it that
> way...

Yes, that older way made more sense to me.

-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
