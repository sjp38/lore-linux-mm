Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 75FEF6B00F7
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 06:50:49 -0400 (EDT)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate6.uk.ibm.com (8.13.1/8.13.1) with ESMTP id oA3Aog9Y020757
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 10:50:42 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oA3Aobom2470126
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 10:50:42 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oA3Aoaxt003980
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 04:50:36 -0600
Message-ID: <4CD13E7B.5090804@linux.vnet.ibm.com>
Date: Wed, 03 Nov 2010 11:50:35 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] Reduce latencies and improve overall reclaim efficiency
 v2
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie> <4CB721A1.4010508@linux.vnet.ibm.com> <20101018135535.GC30667@csn.ul.ie>
In-Reply-To: <20101018135535.GC30667@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>



On 10/18/2010 03:55 PM, Mel Gorman wrote:
> On Thu, Oct 14, 2010 at 05:28:33PM +0200, Christian Ehrhardt wrote:
> 
>> Seing the patches Mel sent a few weeks ago I realized that this series
>> might be at least partially related to my reports in 1Q 2010 - so I ran my
>> testcase on a few kernels to provide you with some more backing data.
> 
> Thanks very much for revisiting this.
> 
>> Results are always the average of three iozone runs as it is known to be somewhat noisy - especially when affected by the issue I try to show here.
>> As discussed in detail in older threads the setup uses 16 disks and scales the number of concurrent iozone processes.
>> Processes are evenly distributed so that it always is one process per disk.
>> In the past we reported 40% to 80% degradation for the sequential read case based on 2.6.32 which can still be seen.
>> What we found was that the allocations for page cache with GFP_COLD flag loop a long time between try_to_free, get_page, reclaim as free makes some progress and due to that GFP_COLD allocations can loop and retry.
>> In addition my case had no writes at all, which forced congestion_wait to wait the full timeout all the time.
>>
>> Kernel (git)                   4          8         16   deviation #16 case                           comment
>> linux-2.6.30              902694    1396073    1892624                 base                              base
>> linux-2.6.32              752008     990425     932938               -50.7%     impact as reported in 1Q 2010
>> linux-2.6.35               63532      71573      64083               -96.6%                    got even worse
>> linux-2.6.35.6            176485     174442     212102               -88.8%  fixes useful, but still far away
>> linux-2.6.36-rc4-trace    119683     188997     187012               -90.1%                         still bad
>> linux-2.6.36-rc4-fix      884431    1114073    1470659               -22.3%            Mels fixes help a lot!
>>
[...]
> If all goes according to plan,
> kernel 2.6.37-rc1 will be of interest. Thanks again.

Here a measurement with 2.6.37-rc1 as confirmation of progress:
   linux-2.6.37-rc1          876588    1161876    1643430               -13.1%       even better than 2.6.36-fix

That means 2.6.37-rc1 really shows what we hoped for.
And it eventually even turned out a little bit better than 2.6.36 + your fixes.

 

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
