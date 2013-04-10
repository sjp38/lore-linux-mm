Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id D60206B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:25:58 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 15:25:58 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3976919D8036
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:25:49 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3ALPpEJ131392
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:25:52 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3ALPpxM018092
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:25:51 -0600
Message-ID: <5165D8DE.5090801@linux.vnet.ibm.com>
Date: Wed, 10 Apr 2013 14:25:50 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/11] mm: fixup changers of per cpu pageset's ->high
 and ->batch
References: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com> <20130410142354.6044338fd68ff2ad165b1bc8@linux-foundation.org>
In-Reply-To: <20130410142354.6044338fd68ff2ad165b1bc8@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/10/2013 02:23 PM, Andrew Morton wrote:
> On Wed, 10 Apr 2013 11:23:28 -0700 Cody P Schafer <cody@linux.vnet.ibm.com> wrote:
>
>> "Problems" with the current code:
>>   1. there is a lack of synchronization in setting ->high and ->batch in
>>      percpu_pagelist_fraction_sysctl_handler()
>>   2. stop_machine() in zone_pcp_update() is unnecissary.
>>   3. zone_pcp_update() does not consider the case where percpu_pagelist_fraction is non-zero
>>
>> To fix:
>>   1. add memory barriers, a safe ->batch value, an update side mutex when
>>      updating ->high and ->batch, and use ACCESS_ONCE() for ->batch users that
>>      expect a stable value.
>>   2. avoid draining pages in zone_pcp_update(), rely upon the memory barriers added to fix #1
>>   3. factor out quite a few functions, and then call the appropriate one.
>>
>> Note that it results in a change to the behavior of zone_pcp_update(), which is
>> used by memory_hotplug. I'm rather certain that I've diserned (and preserved)
>> the essential behavior (changing ->high and ->batch), and only eliminated
>> unneeded actions (draining the per cpu pages), but this may not be the case.
>>
>> Further note that the draining of pages that previously took place in
>> zone_pcp_update() occured after repeated draining when attempting to offline a
>> page, and after the offline has "succeeded". It appears that the draining was
>> added to zone_pcp_update() to avoid refactoring setup_pageset() into 2
>> funtions.
>
> There hasn't been a ton of review activity for this patchset :(
>
> I'm inclined to duck it until after 3.9.  Do the patches fix any
> noticeably bad userspace behavior?

No, all the bugs are theoretical. Waiting should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
