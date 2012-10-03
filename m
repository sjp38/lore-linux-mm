Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 69EC86B005D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 21:21:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 514743EE0BC
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 10:21:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A1BC45DD74
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 10:21:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0277545DE55
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 10:21:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E71EA1DB803C
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 10:21:52 +0900 (JST)
Received: from G01JPEXCHKW21.g01.fujitsu.local (G01JPEXCHKW21.g01.fujitsu.local [10.0.193.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D23A1DB8038
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 10:21:52 +0900 (JST)
Message-ID: <506B930C.2080000@jp.fujitsu.com>
Date: Wed, 3 Oct 2012 10:21:16 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] memory-hotplug : notification of memoty block's state
References: <506AA4E2.7070302@jp.fujitsu.com> <20121002144211.b60881a8.akpm@linux-foundation.org>
In-Reply-To: <20121002144211.b60881a8.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

Hi Andrew,

2012/10/03 6:42, Andrew Morton wrote:
> On Tue, 2 Oct 2012 17:25:06 +0900
> Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:
>
>> remove_memory() offlines memory. And it is called by following two cases:
>>
>> 1. echo offline >/sys/devices/system/memory/memoryXX/state
>> 2. hot remove a memory device
>>
>> In the 1st case, the memory block's state is changed and the notification
>> that memory block's state changed is sent to userland after calling
>> offline_memory(). So user can notice memory block is changed.
>>
>> But in the 2nd case, the memory block's state is not changed and the
>> notification is not also sent to userspcae even if calling offline_memory().
>> So user cannot notice memory block is changed.
>>
>> We should also notify to userspace at 2nd case.
>
> These two little patches look reasonable to me.
>
> There's a lot of recent activity with memory hotplug!  We're in the 3.7
> merge window now so it is not a good time to be merging new material.

> Also there appear to be two teams working on it and it's unclear to me
> how well coordinated this work is?

As you know, there are two teams for developing the memory hotplug.
   - Wen's patch-set
     https://lkml.org/lkml/2012/9/5/201

   - Lai's patch-set
     https://lkml.org/lkml/2012/9/10/180

Wen's patch-set is for removing physical memory. Now, I'm splitting the
patch-set for reviewing more easy. If the patch-set is merged into
linux kernel, I believe that linux on x86 can hot remove a physical
memory device.

But it is not enough since we cannot remove a memory which has kernel
memory. If we guarantee the memory hot remove, the memory must belong
to ZONE_MOVABLE.

So Lai's patch-set tries to create a movable node that the all memory
belongs to ZONE_MOVABLE.

I think there are two chances for creating the movable node.
   - boot time
   - after hot add memory

- boot time

For creating a movable memory, linux has two kernel parameters
(kernelcore and movablecore). But it is not enough, since even if we
set the kernel paramter, the movable memory is distributed evenly in
each node. So we introduce the kernelcore_max_addr boot parameter.
The parameter limits the range of the memory used as a kernel memory.

For example, the system has following nodes.

     node0 : 0x40000000 - 0x80000000
     node1 : 0x80000000 - 0xc0000000

And when I want to hot remove a node1, we set "kernelcore_max_addr=0x80000000".
In doing so, kernel memory is limited within 0x80000000 and node1's
memory belongs to ZONE_MOEVALBE. As a result, we can guarantee that
node1 is a movable node and we always hot remove node1.

- after hot add memory

When hot adding memory, the memory belongs to ZONE_NORMAL and is offline.
If we online the memory, the memory may have kernel memory. In this case,
we cannot hot remove the memory. So we introduce the online_movable
function. If we use the function as follow, the memory belongs to
ZONE_MOVABLE.

echo online_movable > /sys/devices/system/node/nodeX/memoryX/state

So when new node is hot added and I echo "online_movale" to all hot added
memory, the node's memory belongs to ZONE_MOVABLE. As a result, we can
guarantee that the node is a movable node and we always hot remove node.

# I hope to help your understanding about our works by the information.

Thanks,
Yasuaki Ishimatsu

>
> However these two patches are pretty simple and do fix a problem, so I
> added them to the 3.7 MM queue.
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
