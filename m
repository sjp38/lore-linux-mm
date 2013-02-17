Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 1E4786B0083
	for <linux-mm@kvack.org>; Sun, 17 Feb 2013 04:11:00 -0500 (EST)
Received: by mail-gh0-f170.google.com with SMTP id g14so400630ghb.29
        for <linux-mm@kvack.org>; Sun, 17 Feb 2013 01:10:59 -0800 (PST)
Message-ID: <51209E9C.3020507@gmail.com>
Date: Sun, 17 Feb 2013 17:10:52 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC] Reproducible OOM with just a few sleeps
References: <201301120331.r0C3VxXc016220@como.maths.usyd.edu.au> <50F41D9D.1000403@linux.vnet.ibm.com>
In-Reply-To: <50F41D9D.1000403@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: paul.szabo@sydney.edu.au, linux-mm@kvack.org, 695182@bugs.debian.org, linux-kernel@vger.kernel.org

On 01/14/2013 11:00 PM, Dave Hansen wrote:
> On 01/11/2013 07:31 PM, paul.szabo@sydney.edu.au wrote:
>> Seems that any i386 PAE machine will go OOM just by running a few
>> processes. To reproduce:
>>    sh -c 'n=0; while [ $n -lt 19999 ]; do sleep 600 & ((n=n+1)); done'
>> My machine has 64GB RAM. With previous OOM episodes, it seemed that
>> running (booting) it with mem=32G might avoid OOM; but an OOM was
>> obtained just the same, and also with lower memory:
>>    Memory    sleeps to OOM       free shows total
>>    (mem=64G)  5300               64447796
>>    mem=32G   10200               31155512
>>    mem=16G   13400               14509364
>>    mem=8G    14200               6186296
>>    mem=6G    15200               4105532
>>    mem=4G    16400               2041364
>> The machine does not run out of highmem, nor does it use any swap.
> I think what you're seeing here is that, as the amount of total memory
> increases, the amount of lowmem available _decreases_ due to inflation
> of mem_map[] (and a few other more minor things).  The number of sleeps

So if he config sparse memory, the issue can be solved I think.

> you can do is bound by the number of processes, as you noticed from
> ulimit.  Creating processes that don't use much memory eats a relatively
> large amount of low memory.
>
> This is a sad (and counterintuitive) fact: more RAM actually *CREATES*
> RAM bottlenecks on 32-bit systems.
>
>> On my large machine, 'free' fails to show about 2GB memory, e.g. with
>> mem=16G it shows:
>>
>> root@zeno:~# free -l
>>               total       used       free     shared    buffers     cached
>> Mem:      14509364     435440   14073924          0       4068     111328
>> Low:        769044     120232     648812
>> High:     13740320     315208   13425112
>> -/+ buffers/cache:     320044   14189320
>> Swap:    134217724          0  134217724
> You probably have a memory hole.  mem=16G means "give me all the memory
> below the physical address at 16GB".  It does *NOT* mean, "give me
> enough memory such that 'free' will show ~16G available."  If you have a
> 1.5GB hole below 16GB, and you do mem=16G, you'll end up with ~14.5GB
> available.
>
> The e820 map (during early boot in dmesg) or /proc/iomem will let you
> locate your memory holes.

Dear Dave, two questions here:

1) e820 map is read from BIOS, correct? So if all kinds of ranges dump 
from /proc/iomem are setup by BIOS?
2) only "System RAM" range dump from /proc/iomem can be treated as real 
memory, all other ranges can be treated as holes, correct?

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
