Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 007308D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 10:34:44 -0500 (EST)
Message-ID: <4D72580D.4000208@gmail.com>
Date: Sat, 05 Mar 2011 18:34:37 +0300
From: Andrew Vagin <avagin@gmail.com>
Reply-To: avagin@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
References: <1299325456-2687-1-git-send-email-avagin@openvz.org> <20110305152056.GA1918@barrios-desktop>
In-Reply-To: <20110305152056.GA1918@barrios-desktop>
Content-Type: multipart/mixed;
 boundary="------------060901050701040301010807"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is a multi-part message in MIME format.
--------------060901050701040301010807
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit

On 03/05/2011 06:20 PM, Minchan Kim wrote:
> On Sat, Mar 05, 2011 at 02:44:16PM +0300, Andrey Vagin wrote:
>> Check zone->all_unreclaimable in all_unreclaimable(), otherwise the
>> kernel may hang up, because shrink_zones() will do nothing, but
>> all_unreclaimable() will say, that zone has reclaimable pages.
>>
>> do_try_to_free_pages()
>> 	shrink_zones()
>> 		 for_each_zone
>> 			if (zone->all_unreclaimable)
>> 				continue
>> 	if !all_unreclaimable(zonelist, sc)
>> 		return 1
>>
>> __alloc_pages_slowpath()
>> retry:
>> 	did_some_progress = do_try_to_free_pages(page)
>> 	...
>> 	if (!page&&  did_some_progress)
>> 		retry;
>>
>> Signed-off-by: Andrey Vagin<avagin@openvz.org>
>> ---
>>   mm/vmscan.c |    2 ++
>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 6771ea7..1c056f7 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2002,6 +2002,8 @@ static bool all_unreclaimable(struct zonelist *zonelist,
>>
>>   	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>>   			gfp_zone(sc->gfp_mask), sc->nodemask) {
>> +		if (zone->all_unreclaimable)
>> +			continue;
>>   		if (!populated_zone(zone))
>>   			continue;
>>   		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>
> zone_reclaimable checks it. Isn't it enough?
I sent one more patch [PATCH] mm: skip zombie in OOM-killer.
This two patches are enough.
> Does the hang up really happen or see it by code review?
Yes. You can reproduce it for help the attached python program. It's not 
very clever:)
It make the following actions in loop:
1. fork
2. mmap
3. touch memory
4. read memory
5. munmmap

>> -- 
>> 1.7.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
>> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>


--------------060901050701040301010807
Content-Type: text/plain;
 name="memeater.py"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="memeater.py"

import sys, time, mmap, os
from subprocess import Popen, PIPE
import random

global mem_size

def info(msg):
	pid = os.getpid()
	print >> sys.stderr, "%s: %s" % (pid, msg)
	sys.stderr.flush()



def memory_loop(cmd = "a"):
	"""
	cmd may be:
		c: check memory
		else: touch memory
	"""
	c = 0
	for j in xrange(0, mem_size):
		if cmd == "c":
			if f[j<<12] != chr(j % 255):
				info("Data corruption")
				sys.exit(1)
		else:
			f[j<<12] = chr(j % 255)

while True:
	pid = os.fork()
	if (pid != 0):
		mem_size = random.randint(0, 56 * 4096)
		f = mmap.mmap(-1, mem_size << 12, mmap.MAP_ANONYMOUS|mmap.MAP_PRIVATE)
		memory_loop()
		memory_loop("c")
		f.close()

--------------060901050701040301010807--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
