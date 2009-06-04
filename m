Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F334D6B004D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 22:43:08 -0400 (EDT)
Received: by rv-out-0506.google.com with SMTP id l9so175086rvb.41
        for <linux-mm@kvack.org>; Wed, 03 Jun 2009 19:43:07 -0700 (PDT)
Message-ID: <4A2734BA.7080004@gmail.com>
Date: Wed, 03 Jun 2009 19:43:06 -0700
From: Joel Krauska <jkrauska@gmail.com>
MIME-Version: 1.0
Subject: Re: swapoff throttling and speedup?
References: <4A26AC73.6040804@gmail.com> <20090604110456.90b0ebcb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090604110456.90b0ebcb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
>> 1. Has anyone tried making a nicer swapoff?
>> Right now swapoff can be pretty aggressive if the system is otherwise
>> heavily loaded.  On systems that I need to leave running other jobs,
>> swapoff compounds the slowness of the system overall by burning up
>> a single CPU and lots of IO
>>
>> I wrote a perl wrapper that briefly runs swapoff 
>> and then kills it, but it would seem more reasonable to have a knob
>> to make swapoff less aggressive. (max kb/s, etc)  
>>
>> It looked to me like the swapoff code was immediately hitting kernel 
>> internals instead of doing more lifting itself (and making it 
>> obvious where I could insert some sleeps)
>>

I find I need a slower swapoff when a system that's already running very hot
needs to be recovered from lots of swapping without overly impacting the other
running processes.

The bulk of the work is still being done in normal RAM, and the overhead
of consuming an entire CPU just for swapoff degrades my other running processes.

> How about throttling swapoff's cpu usage by cpu scheduler cgroup ?
> No help ?

I think swapoff is all done as systemcalls, not in userspace, so I'm not
sure that cgroups would apply here.  (granted I had never heard of control
groups until just now...)

My initial analogy and insight for this was the MD RAID rebuild throttle toggles.
/proc/sys/dev/raid/speed_limit_max

Which I've had to tune down on occasion to reduce impact to other running processes.
(aside: MD RAID rebuilds do seem to be multi-threaded?)

Thanks Kame,

Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
