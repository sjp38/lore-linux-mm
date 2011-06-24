Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 91EE0900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 09:10:47 -0400 (EDT)
Message-ID: <4E048CC6.5010400@draigBrady.com>
Date: Fri, 24 Jun 2011 14:10:30 +0100
From: =?ISO-8859-15?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: sandy bridge kswapd0 livelock with pagecache
References: <20110621130756.GH9396@suse.de> <4E00A96D.8020806@draigBrady.com> <20110622094401.GJ9396@suse.de> <4E01C19F.20204@draigBrady.com> <20110623114646.GM9396@suse.de> <4E0339CF.8080407@draigBrady.com> <20110623152418.GN9396@suse.de> <4E035C8B.1080905@draigBrady.com> <20110623165955.GO9396@suse.de> <4E039334.7090502@draigBrady.com> <20110624114444.GP9396@suse.de>
In-Reply-To: <20110624114444.GP9396@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org

On 24/06/11 12:44, Mel Gorman wrote:
> On Thu, Jun 23, 2011 at 08:25:40PM +0100, P?draig Brady wrote:
>> On 23/06/11 17:59, Mel Gorman wrote:
>>> On Thu, Jun 23, 2011 at 04:32:27PM +0100, P?draig Brady wrote:
>>>> On 23/06/11 16:24, Mel Gorman wrote:
>>>>>
>>>>> Theory 2 it is then. This is to be applied on top of the patch for
>>>>> theory 1.
>>>>>
>>>>> ==== CUT HERE ====
>>>>> mm: vmscan: Prevent kswapd doing excessive work when classzone is unreclaimable
>>>>
>>>> No joy :(
>>>>
>>>
>>> Joy is indeed rapidly fleeing the vicinity.
>>>
>>> Check /proc/sys/vm/laptop_mode . If it's set, unset it and try again.
>>
>> It was not set
>>
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index dce95dd..c8c0f5a 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -2426,19 +2426,19 @@ loop_again:
>>>  			 * zone has way too many pages free already.
>>>  			 */
>>>  			if (!zone_watermark_ok_safe(zone, order,
>>> -					8*high_wmark_pages(zone), end_zone, 0))
>>
>> Note 8 was not in my tree.
>> Manually applied patch makes no difference :(
>> Well maybe kswapd0 started spinning a little later.
>>
> 
> Gack :)
> 
> On further reflection "mm: vmscan: Prevent kswapd doing excessive
> work when classzone is unreclaimable" was off but it was along the
> right lines in that the balancing classzone was not being considered
> when going to sleep.
> 
> The following is a patch against mainline 2.6.38.8 and is a
> roll-up of four separate patches that includes a new modification to
> sleeping_prematurely. Because the stack I am working off has changed
> significantly, it's far easier if you apply this on top of a vanilla
> fedora branch of 2.6.38 and test rather than trying to backout and
> reapply. Depending on when you checked out or if you have applied the
> BALANCE_GAP patch yourself, it might collide with 8*high_wmark_pages
> but the resolution should be straight-forward.
> 
> Thanks for persisting.

Bingo!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
