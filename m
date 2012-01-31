Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 741DF6B13F1
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 09:49:06 -0500 (EST)
Message-ID: <4F27FF3C.5050000@stericsson.com>
Date: Tue, 31 Jan 2012 15:48:28 +0100
From: Maxime Coquelin <maxime.coquelin@stericsson.com>
MIME-Version: 1.0
Subject: Re: [RFCv1 0/6] PASR: Partial Array Self-Refresh Framework
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com> <20120130135341.GA3720@elte.hu> <4F26A701.3090006@stericsson.com> <20120131123903.GB4408@elte.hu>
In-Reply-To: <20120131123903.GB4408@elte.hu>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus WALLEIJ <linus.walleij@stericsson.com>, Andrea GALLO <andrea.gallo@stericsson.com>, Vincent GUITTOT <vincent.guittot@stericsson.com>, Philippe LANGLAIS <philippe.langlais@stericsson.com>, Loic PALLARDY <loic.pallardy@stericsson.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On 01/31/2012 01:39 PM, Ingo Molnar wrote:
> * Maxime Coquelin<maxime.coquelin@stericsson.com>  wrote:
>
>> Dear Ingo,
>>
>> On 01/30/2012 02:53 PM, Ingo Molnar wrote:
>>> * Maxime Coquelin<maxime.coquelin@stericsson.com>   wrote:
>>>
>>>> The role of this framework is to stop the refresh of unused
>>>> memory to enhance DDR power consumption.
>>> I'm wondering in what scenarios this is useful, and how
>>> consistently it is useful.
>>>
>>> The primary concern I can see is that on most Linux systems with
>>> an uptime more than a couple of minutes RAM gets used up by the
>>> Linux page-cache:
>>>
>>>   $ uptime
>>>    14:46:39 up 11 days,  2:04, 19 users,  load average: 0.11, 0.29, 0.80
>>>   $ free
>>>                total       used       free     shared    buffers     cached
>>>   Mem:      12255096   12030152     224944          0     651560    6000452
>>>   -/+ buffers/cache:    5378140    6876956
>>>
>>> Even mobile phones easily have days of uptime - quite often
>>> weeks of uptime. I'd expect the page-cache to fill up RAM on
>>> such systems.
>>>
>>> So how will this actually end up saving power consistently?
>>> Does it have to be combined with a VM policy that more
>>> aggressively flushes cached pages from the page-cache?
>> You're right Ingo, page-cache fills up the RAM. This framework
>> is to be used in combination with a page-cache flush governor.
>> In the case of a mobile phone, we can imagine dropping the
>> cache when system's screen is off for a while, in order to
>> preserve user's experience.
> Is this "page-cache flush governor" some existing code?
> How does it work and does it need upstream patches?
For now, such a governor has not been implemented.
I use the dedicated ProcFS interface to test the framework (echo 3 > 
/proc/sys/vm/drop_caches).


>>> A secondary concern is fragmentation: right now we fragment
>>> memory rather significantly.
>> Yes, I think fragmentation is the main challenge. This is the
>> same problem faced for Memory Hotplug feature. The solution I
>> see is to add a significant Movable zone in the system and use
>> the Compaction feature from Mel Gorman. The problem of course
>> remains for the Normal zone.
> Ok. I guess phones/appliances can generally live with a
> relatively large movable zone as they don't have serious
> memory pressure issues.
Actually, current high-end smartphones and tablets have 1GB DDR.
Smartphones and tablets arriving later this year should have up to 2GB DDR.
For example, my Android phone running for 2 days has only 230MB are used 
in idle once the page-caches dropped.
So I think having a 1GB movable zone on a 2GB DDR phone is conceivable.

>>> For the Ux500 PASR driver you've implemented the section
>>> size is 64 MB. Do I interpret the code correctly in that a
>>> continuous, 64MB physical block of RAM has to be 100% free
>>> for us to be able to turn off refresh and power for this
>>> block of RAM?
>> Current DDR (2Gb/4Gb dies) used in mobile platform have 64MB
>> banks and segments. This is the lower granularity for Partial
>> Array Self-refresh.
> Ok, so do you see real, consistent power savings with a large
> movable zone, with page cache governor patches applied (assuming
> it's a kernel mechanism) and CONFIG_COMPACTION=y enabled, on an
> upstream kernel with all these patches applied?
I don't have consistent figures for now as it is being prototyped.
 From the DDR datasheet I gathered, the DDR power savings is about 33% 
when half of the die is in self-refresh, compared to the full die in 
self-refresh.



Thanks for your comments,
Maxime

>
> Thanks,
>
> 	Ingo
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
