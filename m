Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 059CA8D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 11:41:35 -0500 (EST)
Message-ID: <4D7267B6.6020406@gmail.com>
Date: Sat, 05 Mar 2011 19:41:26 +0300
From: Andrew Vagin <avagin@gmail.com>
Reply-To: avagin@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
References: <1299325456-2687-1-git-send-email-avagin@openvz.org> <20110305152056.GA1918@barrios-desktop> <4D72580D.4000208@gmail.com> <20110305155316.GB1918@barrios-desktop>
In-Reply-To: <20110305155316.GB1918@barrios-desktop>
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/05/2011 06:53 PM, Minchan Kim wrote:
> On Sat, Mar 05, 2011 at 06:34:37PM +0300, Andrew Vagin wrote:
>> On 03/05/2011 06:20 PM, Minchan Kim wrote:
>>> On Sat, Mar 05, 2011 at 02:44:16PM +0300, Andrey Vagin wrote:
>>>> Check zone->all_unreclaimable in all_unreclaimable(), otherwise the
>>>> kernel may hang up, because shrink_zones() will do nothing, but
>>>> all_unreclaimable() will say, that zone has reclaimable pages.
>>>>
>>>> do_try_to_free_pages()
>>>> 	shrink_zones()
>>>> 		 for_each_zone
>>>> 			if (zone->all_unreclaimable)
>>>> 				continue
>>>> 	if !all_unreclaimable(zonelist, sc)
>>>> 		return 1
>>>>
>>>> __alloc_pages_slowpath()
>>>> retry:
>>>> 	did_some_progress = do_try_to_free_pages(page)
>>>> 	...
>>>> 	if (!page&&   did_some_progress)
>>>> 		retry;
>>>>
>>>> Signed-off-by: Andrey Vagin<avagin@openvz.org>
>>>> ---
>>>>   mm/vmscan.c |    2 ++
>>>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>> index 6771ea7..1c056f7 100644
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -2002,6 +2002,8 @@ static bool all_unreclaimable(struct zonelist *zonelist,
>>>>
>>>>   	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>>>>   			gfp_zone(sc->gfp_mask), sc->nodemask) {
>>>> +		if (zone->all_unreclaimable)
>>>> +			continue;
>>>>   		if (!populated_zone(zone))
>>>>   			continue;
>>>>   		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>>> zone_reclaimable checks it. Isn't it enough?
>> I sent one more patch [PATCH] mm: skip zombie in OOM-killer.
>> This two patches are enough.
> Sorry if I confused you.
> I mean zone->all_unreclaimable become true if !zone_reclaimable in balance_pgdat.
> zone_reclaimable compares recent pages_scanned with the number of zone lru pages.
> So too many page scanning in small lru pages makes the zone to unreclaimable zone.
>
> In all_unreclaimable, we calls zone_reclaimable to detect it.
> It's the same thing with your patch.
balance_pgdat set zone->all_unreclaimable, but the problem is that it is 
cleaned late.

The problem is that zone->all_unreclaimable = True, but 
zone_reclaimable() returns True too.

zone->all_unreclaimable will be cleaned in free_*_pages, but this may be 
late. It is enough allocate one page from page cache, that 
zone_reclaimable() returns True and zone->all_unreclaimable becomes True.
>>> Does the hang up really happen or see it by code review?
>> Yes. You can reproduce it for help the attached python program. It's
>> not very clever:)
>> It make the following actions in loop:
>> 1. fork
>> 2. mmap
>> 3. touch memory
>> 4. read memory
>> 5. munmmap
> It seems the test program makes fork bombs and memory hogging.
> If you applied this patch, the problem is gone?
Yes.
>>>> -- 
>>>> 1.7.1
>>>>
>>>> --
>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>> see: http://www.linux-mm.org/ .
>>>> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
>>>> Don't email:<a href=mailto:"dont@kvack.org">   email@kvack.org</a>
>> import sys, time, mmap, os
>> from subprocess import Popen, PIPE
>> import random
>>
>> global mem_size
>>
>> def info(msg):
>> 	pid = os.getpid()
>> 	print>>  sys.stderr, "%s: %s" % (pid, msg)
>> 	sys.stderr.flush()
>>
>>
>>
>> def memory_loop(cmd = "a"):
>> 	"""
>> 	cmd may be:
>> 		c: check memory
>> 		else: touch memory
>> 	"""
>> 	c = 0
>> 	for j in xrange(0, mem_size):
>> 		if cmd == "c":
>> 			if f[j<<12] != chr(j % 255):
>> 				info("Data corruption")
>> 				sys.exit(1)
>> 		else:
>> 			f[j<<12] = chr(j % 255)
>>
>> while True:
>> 	pid = os.fork()
>> 	if (pid != 0):
>> 		mem_size = random.randint(0, 56 * 4096)
>> 		f = mmap.mmap(-1, mem_size<<  12, mmap.MAP_ANONYMOUS|mmap.MAP_PRIVATE)
>> 		memory_loop()
>> 		memory_loop("c")
>> 		f.close()
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
