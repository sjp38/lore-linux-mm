Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 89ABB6B0007
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 03:48:50 -0500 (EST)
Received: by mail-ia0-f178.google.com with SMTP id y26so3569054iab.37
        for <linux-mm@kvack.org>; Thu, 31 Jan 2013 00:48:49 -0800 (PST)
Message-ID: <1359622123.1391.19.camel@kernel>
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
From: Simon Jeons <simon.jeons@gmail.com>
Date: Thu, 31 Jan 2013 02:48:43 -0600
In-Reply-To: <510A18FA.2010107@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
	   <1359463973.1624.15.camel@kernel> <5108F2B3.3090506@cn.fujitsu.com>
	  <1359595344.1557.13.camel@kernel> <5109E59F.5080104@cn.fujitsu.com>
	 <1359613162.1587.0.camel@kernel> <510A18FA.2010107@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Hi Tang,
On Thu, 2013-01-31 at 15:10 +0800, Tang Chen wrote:

1. IIUC, there is a button on machine which supports hot-remove memory,
then what's the difference between press button and echo to /sys?
2. Since kernel memory is linear mapping(I mean direct mapping part),
why can't put kernel direct mapping memory into one memory device, and
other memory into the other devices? As you know x86_64 don't need
highmem, IIUC, all kernel memory will linear mapping in this case. Is my
idea available? If is correct, x86_32 can't implement in the same way
since highmem(kmap/kmap_atomic/vmalloc) can map any address, so it's
hard to focus kernel memory on single memory device.
3. In current implementation, if memory hotplug just need memory
subsystem and ACPI codes support? Or also needs firmware take part in?
Hope you can explain in details, thanks in advance. :)
4. What's the status of memory hotplug? Apart from can't remove kernel
memory, other things are fully implementation?  


> On 01/31/2013 02:19 PM, Simon Jeons wrote:
> > Hi Tang,
> > On Thu, 2013-01-31 at 11:31 +0800, Tang Chen wrote:
> >> Hi Simon,
> >>
> >> Please see below. :)
> >>
> >> On 01/31/2013 09:22 AM, Simon Jeons wrote:
> >>>
> >>> Sorry, I still confuse. :(
> >>> update node_states[N_NORMAL_MEMORY] to node_states[N_MEMORY] or
> >>> node_states[N_NORMAL_MEMOR] present 0...ZONE_MOVABLE?
> >>>
> >>> node_states is what? node_states[N_NORMAL_MEMOR] or
> >>> node_states[N_MEMORY]?
> >>
> >> Are you asking what node_states[] is ?
> >>
> >> node_states[] is an array of nodemask,
> >>
> >>       extern nodemask_t node_states[NR_NODE_STATES];
> >>
> >> For example, node_states[N_NORMAL_MEMOR] represents which nodes have
> >> normal memory.
> >> If N_MEMORY == N_HIGH_MEMORY == N_NORMAL_MEMORY, node_states[N_MEMORY] is
> >> node_states[N_NORMAL_MEMOR]. So it represents which nodes have 0 ...
> >> ZONE_MOVABLE.
> >>
> >
> > Sorry, how can nodes_state[N_NORMAL_MEMORY] represents a node have 0 ...
> > *ZONE_MOVABLE*, the comment of enum nodes_states said that
> > N_NORMAL_MEMORY just means the node has regular memory.
> >
> 
> Hi Simon,
> 
> Let's say it in this way.
> 
> If we don't have CONFIG_HIGHMEM, N_HIGH_MEMORY == N_NORMAL_MEMORY. We 
> don't have a separate
> macro to represent highmem because we don't have highmem.
> This is easy to understand, right ?
> 
> Now, think it just like above:
> If we don't have CONFIG_MOVABLE_NODE, N_MEMORY == N_HIGH_MEMORY == 
> N_NORMAL_MEMORY.
> This means we don't allow a node to have only movable memory, not we 
> don't have movable memory.
> A node could have normal memory and movable memory. So 
> nodes_state[N_NORMAL_MEMORY] represents
> a node have 0 ... *ZONE_MOVABLE*.
> 
> I think the point is: CONFIG_MOVABLE_NODE means we allow a node to have 
> only movable memory.
> So without CONFIG_MOVABLE_NODE, it doesn't mean a node cannot have 
> movable memory. It means
> the node cannot have only movable memory. It can have normal memory and 
> movable memory.
> 
> 1) With CONFIG_MOVABLE_NODE:
>     N_NORMAL_MEMORY: nodes who have normal memory.
>                      normal memory only
>                      normal and highmem
>                      normal and highmem and movablemem
>                      normal and movablemem
>     N_MEMORY: nodes who has memory (any memory)
>                      normal memory only
>                      normal and highmem
>                      normal and highmem and movablemem
>                      normal and movablemem ---------------- We can have 
> movablemem.
>                      highmem only -------------------------
>                      highmem and movablemem ---------------
>                      movablemem only ---------------------- We can have 
> movablemem only.    ***
> 
> 2) With out CONFIG_MOVABLE_NODE:
>     N_MEMORY == N_NORMAL_MEMORY: (Here, I omit N_HIGH_MEMORY)
>                      normal memory only
>                      normal and highmem
>                      normal and highmem and movablemem
>                      normal and movablemem ---------------- We can have 
> movablemem.
>                      No movablemem only ------------------- We cannot 
> have movablemem only. ***
> 
> The semantics is not that clear here. So we can only try to understand 
> it from the code where
> we use N_MEMORY. :)
> 
> That is my understanding of this.
> 
> Thanks. :)
> 
> 
> 
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
