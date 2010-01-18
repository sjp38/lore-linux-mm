Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE946B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 03:26:53 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id o0IJQmFQ011238
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 06:26:48 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0I8M62I1597576
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 19:22:07 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0I8QlDq024363
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 19:26:47 +1100
Message-ID: <4B541B44.3090407@linux.vnet.ibm.com>
Date: Mon, 18 Jan 2010 13:56:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] Shared page accounting for memory cgroup
References: <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com> <20100106070150.GL3059@balbir.in.ibm.com> <20100106161211.5a7b600f.kamezawa.hiroyu@jp.fujitsu.com> <20100107071554.GO3059@balbir.in.ibm.com> <20100107163610.aaf831e6.kamezawa.hiroyu@jp.fujitsu.com> <20100107083440.GS3059@balbir.in.ibm.com> <20100107174814.ad6820db.kamezawa.hiroyu@jp.fujitsu.com> <20100107180800.7b85ed10.kamezawa.hiroyu@jp.fujitsu.com> <20100107092736.GW3059@balbir.in.ibm.com> <20100108084727.429c40fc.kamezawa.hiroyu@jp.fujitsu.com> <661de9471001171130p2b0ac061he6f3dab9ef46fd06@mail.gmail.com> <20100118094920.151e1370.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100118094920.151e1370.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Monday 18 January 2010 06:19 AM, Daisuke Nishimura wrote:
> On Mon, 18 Jan 2010 01:00:44 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> On Fri, Jan 8, 2010 at 5:17 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>> On Thu, 7 Jan 2010 14:57:36 +0530
>>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>
>>>> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-07 18:08:00]:
>>>>
>>>>> On Thu, 7 Jan 2010 17:48:14 +0900
>>>>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>>>>>>> "How pages are shared" doesn't show good hints. I don't hear such parameter
>>>>>>>> is used in production's resource monitoring software.
>>>>>>>>
>>>>>>>
>>>>>>> You mean "How many pages are shared" are not good hints, please see my
>>>>>>> justification above. With Virtualization (look at KSM for example),
>>>>>>> shared pages are going to be increasingly important part of the
>>>>>>> accounting.
>>>>>>>
>>>>>>
>>>>>> Considering KSM, your cuounting style is tooo bad.
>>>>>>
>>>>>> You should add
>>>>>>
>>>>>>  - MEM_CGROUP_STAT_SHARED_BY_KSM
>>>>>>  - MEM_CGROUP_STAT_FOR_TMPFS/SYSV_IPC_SHMEM
>>>>>>
>>>>
>>>> No.. I am just talking about shared memory being important and shared
>>>> accounting being useful, no counters for KSM in particular (in the
>>>> memcg context).
>>>>
>>> Think so ? The number of memcg-private pages is in interest in my point of view.
>>>
>>> Anyway, I don't change my opinion as "sum of rss" is not necessary to be calculated
>>> in the kernel.
>>> If you want to provide that in memcg, please add it to global VM as /proc/meminfo.
>>>
>>> IIUC, KSM/SHMEM has some official method in global VM.
>>>
>>
>> Kamezawa-San,
>>
>> I implemented the same in user space and I get really bad results, here is why
>>
>> 1. I need to hold and walk the tasks list in cgroups and extract RSS
>> through /proc (results in worse hold times for the fork() scenario you
>> menioned)
>> 2. The data is highly inconsistent due to the higher margin of error
>> in accumulating data which is changing as we run. By the time we total
>> and look at the memcg data, the data is stale
>>
>> Would you be OK with the patch, if I renamed "shared_usage_in_bytes"
>> to "non_private_usage_in_bytes"?
>>
> I think the name is still ambiguous.
> 
> For example, if process A belongs to /cgroup/memory/01 and process B to /cgroup/memory/02,
> both process have 10MB anonymous pages and 10MB file caches of the same pages, and all of the
> file caches are charged to 01.
> In this case, the value in 01 is 0MB(=20MB - 20MB) and 10MB(20MB - 10MB), right?
> 

Correct, file cache is almost always considered shared, so it has

1. non-private or shared usage of 10MB
2. 10 MB of file cache

> I don't think "non private usage" is appropriate to this value.
> Why don't you just show "sum_of_each_process_rss" ? I think it would be easier
> to understand for users.

Here is my concern

1. The gap between looking at memcg stat and sum of all RSS is way
higher in user space
2. Summing up all rss without walking the tasks atomically can and
will lead to consistency issues. Data can be stale as long as it
represents a consistent snapshot of data

We need to differentiate between

1. Data snapshot (taken at a time, but valid at that point)
2. Data taken from different sources that does not form a uniform
snapshot, because the timestamping of the each of the collected data
items is different


> But, hmm, I don't see any strong reason to do this in kernel, then :(

Please see my reason above for doing it in the kernel.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
