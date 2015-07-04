Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8EC280281
	for <linux-mm@kvack.org>; Sat,  4 Jul 2015 04:05:41 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so86072755qkb.2
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 01:05:41 -0700 (PDT)
Received: from nm42-vm4.bullet.mail.bf1.yahoo.com (nm42-vm4.bullet.mail.bf1.yahoo.com. [216.109.114.191])
        by mx.google.com with ESMTPS id 123si13379815qha.40.2015.07.04.01.05.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 04 Jul 2015 01:05:40 -0700 (PDT)
Date: Sat, 4 Jul 2015 08:05:30 +0000 (UTC)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Message-ID: <1492667856.2385879.1435997130547.JavaMail.yahoo@mail.yahoo.com>
In-Reply-To: <20150703183809.GA6781@cmpxchg.org>
References: <20150703183809.GA6781@cmpxchg.org>
Subject: Re: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
 feature
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Pintu Kumar <pintu.k@samsung.com>, Pintu Kumar <pintu_agarwal@yahoo.com>
Cc: "corbet@lwn.net" <corbet@lwn.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "gorcunov@openvz.org" <gorcunov@openvz.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "emunson@akamai.com" <emunson@akamai.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "standby24x7@gmail.com" <standby24x7@gmail.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "hughd@google.com" <hughd@google.com>, "minchan@kernel.org" <minchan@kernel.org>, "tj@kernel.org" <tj@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "xypron.glpk@gmx.de" <xypron.glpk@gmx.de>, "dzickus@redhat.com" <dzickus@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "uobergfe@redhat.com" <uobergfe@redhat.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "cj@linux.com" <cj@linux.com>, "opensource.ganesh@gmail.com" <opensource.ganesh@gmail.com>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "cpgs@samsung.com" <cpgs@samsung.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, "rohit.kr@samsung.com" <rohit.kr@samsung.com>, "iqbal.ams@samsung.com" <iqbal.ams@samsung.com>



Hi,

Thanks for reviewing the patch.
Please find my comments inline.

>________________________________
> From: Johannes Weiner <hannes@cmpxchg.org>
>To: Pintu Kumar <pintu.k@samsung.com>
>Cc: corbet@lwn.net; akpm@linux-foundation.org; vbabka@suse.cz; gorcunov@openvz.org; mhocko@suse.cz; emunson@akamai.com; kirill.shutemov@linux.intel.com; standby24x7@gmail.com; vdavydov@parallels.com; hughd@google.com; minchan@kernel.org; tj@kernel.org; rientjes@google.com; xypron.glpk@gmx.de; dzickus@redhat.com; prarit@redhat.com; ebiederm@xmission.com; rostedt@goodmis.org; uobergfe@redhat.com; paulmck@linux.vnet.ibm.com; iamjoonsoo.kim@lge.com; ddstreet@ieee.org; sasha.levin@oracle.com; koct9i@gmail.com; mgorman@suse.de; cj@linux.com; opensource.ganesh@gmail.com; vinmenon@codeaurora.org; linux-doc@vger.kernel.org; linux-kernel@vger.kernel.org; linux-mm@kvack.org; linux-pm@vger.kernel.org; cpgs@samsung.com; pintu_agarwal@yahoo.com; vishnu.ps@samsung.com; rohit.kr@samsung.com; iqbal.ams@samsung.com
>Sent: Saturday, 4 July 2015 12:08 AM
>Subject: Re: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory feature
>
>
>On Fri, Jul 03, 2015 at 06:50:07PM +0530, Pintu Kumar wrote:
>> This patch provides 2 things:
>> 1. Add new control called shrink_memory in /proc/sys/vm/.
>> This control can be used to aggressively reclaim memory system-wide
>> in one shot from the user space. A value of 1 will instruct the
>> kernel to reclaim as much as totalram_pages in the system.
>> Example: echo 1 > /proc/sys/vm/shrink_memory
>>
>> 2. Enable shrink_all_memory API in kernel with new CONFIG_SHRINK_MEMORY.
>> Currently, shrink_all_memory function is used only during hibernation.
>> With the new config we can make use of this API for non-hibernation case
>> also without disturbing the hibernation case.
>>
>> The detailed paper was presented in Embedded Linux Conference, Mar-2015
>> http://events.linuxfoundation.org/sites/events/files/slides/
>> %5BELC-2015%5D-System-wide-Memory-Defragmenter.pdf
>>
>> Scenarios were this can be used and helpful are:
>> 1) Can be invoked just after system boot-up is finished.
>
>The allocator automatically reclaims when memory is needed, that's why
>the metrics quoted in those slides, free pages and fragmentation level,
>don't really mean much.  We don't care how much memory is free or how
>fragmented it is UNTIL somebody actually asks for it.  The only metric
>that counts is the allocation success ratio (and possibly the latency).

>

Yes, the allocator automatically reclaims memory but in the slowpath. Also it reclaims only to satisfy the current allocation needs. That means for all future higher-order allocations the system will be entering slowpath again and again. Over a point of time (with multiple application launch), the higher-orders (2^4 and above) will be gone. The system entering slowpath means that the first allocation attempt has already failed. Then in slowpath the sequence is: kswapd -> compaction -> then direct reclaim. Thus entering slowpath again and again will be a costly operation.

Thus keeping free memory ready in higher-order pages will be helpful for succeeding first allocation attempt.

This is important at least in the embedded world with IOMMU (order 8,4,0) allocation.
For example: in the Android ION system-heap driver.
I will cover this example in the next patch set.

For now, it is just about implementing a command, in user space.
# echo 1 > /proc/sys/vm/shrink_memory

If somebody interested they can use it by enabling CONFIG_SHRINK_MEMORY.


The scenario that is discussed here is about:
Invoking shrink_memory from user space, as soon as the system boot is finished.
Because as per my observation, the buffer+caches that is accumulated during boot-up is not very helpful for the system for later application launch.
Thus reclaiming all memory in shot after the boot-up will help grab higher-order pages and freeing lots of memory. Also the reclaimed memory stays in as actual free memory. The cached that gets accumulated after the application launch will be having more hits.
It is like a little advanced version of drop_caches.

>> 2) Can be invoked just before entering entire system suspend.
>
>Why is that?  Suspend already allocates as much as it needs to create

>the system image.

Sorry, but I think you got it wrong here. We are not talking about snapshot image creation part that comes under hibernation.
We are talking about the mobile world, where the system gets suspended when it is kept idle for longer time. The hibernation part does not comes here.
The idea is that the shrink_memory can be best utilized when the system is not doing any useful stuffs and going from idle to suspend. In this scenario, we can check the state of free memory and perform the system-wide reclaim if necessary. Thus when the system resume again, it will have enough memory as free.
Again, this is mainly for embedded world where hibernation is not enabled.
For normal world, it already does it during hibernation snapshot image creation.

Anyways, its an idea that people can utilize it if required and not always enabled.

>
>> 3) Can be invoked from kernel when order-4 pages starts failing.
>
>We have compaction for that, and compaction invokes page reclaim

>automatically to satisfy its need for free pages.

It is not always true. Compaction may not be always successful. Again it is related to slowpath. When order-4 starts failing very often that means all higher-orders becomes 0. Thus system will be entering slowpath again and again, doing swap, compaction, reclaim most of the time.
And even for compaction, there is a knob in user space to call compaction from user space:
#echo 1 > /proc/sys/vm/compact_memory


Similarly, we can have an interface for direct reclaim from user space.
>
>> 4) Can be helpful to completely avoid or delay the kerenl OOM condition.
>
>That's not how OOM works.  An OOM is triggered when there is demand for
>memory but no more pages to reclaim, telling the kernel to look harder
>will not change that.

>
Yes, I know this. I am not talking about calling shrink_memory after OOM.

Rather much before OOM when the first attempt of higher-order starts failing.
This will delay the OOM to a much later stage.

Already explained above.

>
>> 5) Can be developed as a system-tool to quickly defragment entire system
>>    from user space, without the need to kill any application.
>
>Again, the kernel automatically reclaims and compacts memory on demand.
>If the existing mechanisms don't do this properly, and you have actual
>problems with them, they should be reported and fixed, not bypassed.
>But the metrics you seem to base this change on are not representative

>of something that should matter in practice.

It is not always guaranteed that compaction/reclaim _did_some_progress_ always yield some results on the fly. It takes sometime to get sync with the free memory.
Thus keeping the free list ready before hand will be much more helpful.

Anyways, the use case here is to develop a system utility which can perform compaction/reclaim/compaction aggressively.
Its an additional idea that somebody interested can develop.


>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
