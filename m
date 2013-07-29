Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 8EC886B0031
	for <linux-mm@kvack.org>; Sun, 28 Jul 2013 22:10:01 -0400 (EDT)
Message-ID: <51F5CF98.1080101@cn.fujitsu.com>
Date: Mon, 29 Jul 2013 10:12:40 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/21] x86, acpi, numa: Reserve hotpluggable memory at
 early time.
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com> <1374220774-29974-15-git-send-email-tangchen@cn.fujitsu.com> <20130723205557.GS21100@mtj.dyndns.org> <20130723213212.GA21100@mtj.dyndns.org> <51F089C1.4010402@cn.fujitsu.com> <20130725151719.GE26107@mtj.dyndns.org> <51F1F0E0.7040800@cn.fujitsu.com> <20130726102609.GB30786@mtj.dyndns.org>
In-Reply-To: <20130726102609.GB30786@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 07/26/2013 06:26 PM, Tejun Heo wrote:
> On Fri, Jul 26, 2013 at 11:45:36AM +0800, Tang Chen wrote:
>> I just don't want to any new variables to store the hotpluggable regions.
>> But without a new shared variable, it seems difficult to achieve the goal
>> you said below.
>
> Why can't it be done with the .flags field that was added anyway?

I'm sorry but I'm a little misunderstanding here. There are some more 
things I
want to confirm, thanks for your patient. :)

By "the goal" above, I mean making ACPI and memblock parts more 
independent from
each other. I think in this patch-set, I called memblock_reserve() which 
made
these two parts interactive.

So the point is, how to mark the hotpluggable regions and at the same 
time, make
ACPI and memblock parts independent, right ?

But, please see below.

>
>> So how about this.
>> 1. Introduce a new global list used to store hotpluggable regions.
>> 2. On acpi side, find and fulfill the list.
>> 3. On memblock side, make the default allocation function stay away from
>>     these regions.
>
> I was thinking more along the line of
>
> 1. Mark hotpluggable regions with a flag in memblock.
> 2. On ACPI side, find and mark hotpluggable regions.

But marking hotpluggable regions on ACPI side will also make ACPI and 
memblock
parts more interactive. In this patch-set, I just called memblock_reserve()
directly on ACPI side.

I think marking hotpluggable regions on ACPI side is much the same as 
reserving
the regions. I will just call something like memblock_mark_flags() to 
mark the
regions. The only difference will be a different memblock_xxx() function 
call,
right ?

In the last mail, I suggested a global array. So both sides will just 
use the
array, and it seems to be independent. But I think the global array and 
the flags
in memblock are redundant. They are for the same goal.

Actually I want to use flags. I think it is also useful when we try to 
put thins
on local node, such as node_data.

So, is it OK to mark the hotpluggable regions on ACPI side ?


> 3. Make memblock avoid giving out hotpluggable regions for normal
>     allocations.

This step3 is different from this patch-set. I reserved hotpluggable 
regions in
memblock.reserved.

So are you saying mark the hotpluggable regions in memblock.memory, but not
reserve them in memblock.reserved, and make the default allocate 
function avoid
the hotpluggable regions in memblock.memory ?

This way will be convenient when we put the node_data on local node 
(don't need
to free regions from memblock.reserved, as you mentioned before), right?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
