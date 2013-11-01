Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id E55656B0036
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 05:01:11 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so2583056pbb.11
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 02:01:11 -0700 (PDT)
Received: from psmtp.com ([74.125.245.169])
        by mx.google.com with SMTP id jp3si4068070pbc.276.2013.11.01.02.01.09
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 02:01:10 -0700 (PDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 984D93EE0BB
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 18:01:07 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7069A45DEC3
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 18:01:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.nic.fujitsu.com [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AD03445DEC2
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 18:01:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B38DE08003
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 18:01:06 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C06CE08001
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 18:01:06 +0900 (JST)
Message-ID: <52736DA4.8000303@jp.fujitsu.com>
Date: Fri, 1 Nov 2013 18:00:20 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: get rid of unnecessary pageblock scanning in setup_zone_migrate_reserve
References: <1382562092-15570-1-git-send-email-kosaki.motohiro@gmail.com> <20131030151904.GO2400@suse.de> <527169BB.8020104@gmail.com> <20131031101525.GT2400@suse.de> <52729003.1060209@gmail.com>
In-Reply-To: <52729003.1060209@gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hi Mel and Kosaki,

Thank you for posting patches.

I tested your patches. And following table shows time of onlining
a memory section.

Amount of memory        | 128GB | 192GB | 256GB|
------------------------------------------------
linux-3.12-rc7          |  24.3 |  30.2 | 45.6 |
Kosaki's first patch    |   8.3 |   8.3 |  8.6 |
Mel + Kosaki's nit pick |  10.9 |  19.2 | 31.3 |
------------------------------------------------
                                    (millisecond)

128GB : 4 nodes and each node has 32GB of memory
192GB : 6 nodes and each node has 32GB of memory
256GB : 8 nodes and each node has 32GB of memory

In my result, Mel's patch does not seem to fix the problem since time
is increasing with increasing amount of memory.

Thanks,
Yasuaki Ishimatsu

(2013/11/01 2:14), KOSAKI Motohiro wrote:
>>> Nit. I would like to add following hunk. This is just nit because moving
>>> reserve pageblock is extreme rare.
>>>
>>>         if (block_migratetype == MIGRATE_RESERVE) {
>>> +                       found++;
>>>             set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>>>             move_freepages_block(zone, page, MIGRATE_MOVABLE);
>>>         }
>>
>> I don't really see the advantage but if you think it is necessary then I
>> do not object either.
>
> For example, a zone has five pageblock b1,b2,b3,b4,b5 and b1 has MIGRATE_RESERVE.
> When hotremove b1 and hotadd again, your code need to scan all of blocks. But
> mine only need to scan b1 and b2. I mean that's a hotplug specific optimization.
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
