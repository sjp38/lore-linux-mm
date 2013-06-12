Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 8005B6B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 17:46:32 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 12 Jun 2013 17:46:31 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 96FA26E8039
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 17:46:21 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5CLjshA280478
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 17:45:55 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5CLjshT015041
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 15:45:54 -0600
Message-ID: <51B8EC10.6070304@linux.vnet.ibm.com>
Date: Wed, 12 Jun 2013 14:45:52 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_alloc: don't re-init pageset in zone_pcp_update()
References: <1370988779-7586-1-git-send-email-cody@linux.vnet.ibm.com> <20130612142032.882a28b7911ed24ca19e282e@linux-foundation.org>
In-Reply-To: <20130612142032.882a28b7911ed24ca19e282e@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Valdis.Kletnieks@vt.edu

On 06/12/2013 02:20 PM, Andrew Morton wrote:
> On Tue, 11 Jun 2013 15:12:59 -0700 Cody P Schafer <cody@linux.vnet.ibm.com> wrote:
>
>> Factor pageset_set_high_and_batch() (which contains all needed logic too
>> set a pageset's ->high and ->batch inrespective of system state) out of
>> zone_pageset_init(), which avoids us calling pageset_init(), and
>> unsafely blowing away a pageset at runtime (leaked pages and
>> potentially some funky allocations would be the result) when memory
>> hotplug is triggered.
>
> This changelog is pretty screwed up :( It tells us what the patch does
> but not why it does it.
>

It says why it does it, though perhaps a bit hidden:
 >  avoids us calling pageset_init(), and unsafely blowing away a pageset

>> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
>> ---
>>
>> Unless memory hotplug is being triggered on boot, this should *not* be cause of Valdis
>> Kletnieks' reported bug in -next:
>>           "next-20130607 BUG: Bad page state in process systemd pfn:127643"
>
> And this addendum appears to hint at the info we need.

Note the *not*. I included this note only because I expected there would 
be a question of whether Valdis's reported bug was caused by this. It 
_isn't_. The bug this fix fixes is only triggered by memory_hotplug, and 
Valdis's bug occurred on boot.

> Please, send a new changelog?  That should include a description of the
> user-visible effects of the bug which is being fixed,  a description of
> why it occurs and a description of how it was fixed.It would also be
> helpful if you can identify which kernel version(s) need the fix.

It's just a -mm issue. It was introduced by my patchset starting with 
"mm/page_alloc: factor out setting of pcp->high and pcp->batch", where 
the actual place the bug snuck in was "mm/page_alloc: in 
zone_pcp_update(), uze zone_pageset_init()".

>
> Also, a Reported-by:Valdis would be appropriate.
>
I'm fine with adding it (I did take a look at my page_alloc.c changes 
because he reported that bug), but as mentioned before, this fixes a 
different bug.

Anyhow, a reorganized (and clearer) changelog with the same content follows:
---
mm/page_alloc: don't re-init pageset in zone_pcp_update()

When memory hotplug is triggered, we call pageset_init() on a 
per-cpu-pageset which both contains pages and is in use, causing both 
the leakage of those pages and (potentially) bad behaviour if a page is 
allocated from the pageset while it is being cleared.

Avoid this by factoring pageset_set_high_and_batch() (which contains all 
needed logic too set a pageset's ->high and ->batch inrespective of 
system state), and using that instead of zone_pageset_init() in 
zone_pcp_update().

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
