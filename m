Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m8T2LDPa008050
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 07:51:13 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8T2LCcJ1622156
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 07:51:13 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m8T2LCYV016521
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 07:51:12 +0530
Message-ID: <48E03B92.2090402@linux.vnet.ibm.com>
Date: Mon, 29 Sep 2008 07:51:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] memory.min_usage again
References: <20080912184630.35773102.kamezawa.hiroyu@jp.fujitsu.com> <20080929004332.13B0083F2@siro.lan>
In-Reply-To: <20080929004332.13B0083F2@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, containers@lists.osdl.org, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
> hi,
> 
>> On Wed, 10 Sep 2008 08:32:15 -0700
>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>>> YAMAMOTO Takashi wrote:
>>>> hi,
>>>>
>>>>> hi,
>>>>>
>>>>> here's a patch to implement memory.min_usage,
>>>>> which controls the minimum memory usage for a cgroup.
>>>>>
>>>>> it works similarly to mlock;
>>>>> global memory reclamation doesn't reclaim memory from
>>>>> cgroups whose memory usage is below the value.
>>>>> setting it too high is a dangerous operation.
>>>>>
>>> Looking through the code I am a little worried, what if every cgroup is below
>>> minimum value and the system is under memory pressure, do we OOM, while we could
>>> have easily reclaimed?
> 
> i'm not sure what you are worring about.  can you explain a little more?
> under the configuration, OOM is an expected behaviour.
> 

Yes, but an OOM will violate the min_memory right? We promise not to reclaim,
but we can OOM. I would rather implement them as watermarks (best effort
service, rather than a guarantee). OOMing the system sounds bad, specially if
memory can be reclaimed.. No?

>>> I would prefer to see some heuristics around such a feature, mostly around the
>>> priority that do_try_to_free_pages() to determine how desperate we are for
>>> reclaiming memory.
>>>
>> Taking "priority" of memory reclaim path into account is good.
>>
>> ==
>> static unsigned long shrink_inactive_list(unsigned long max_scan,
>>                         struct zone *zone, struct scan_control *sc,
>>                         int priority, int file)
>> ==
>> How about ignore min_usage if "priority < DEF_PRIORITY - 2" ?
> 
> are you suggesting ignoring mlock etc as well in that case?
>

No.. not at all, we will get an mlock controller as well.


> YAMAMOTO Takashi
> 


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
