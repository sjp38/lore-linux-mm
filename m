Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id DA22B6B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 17:23:16 -0500 (EST)
Date: Wed, 9 Jan 2013 14:23:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
Message-Id: <20130109142314.1ce04a96.akpm@linux-foundation.org>
In-Reply-To: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On Wed, 9 Jan 2013 17:32:24 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> Here is the physical memory hot-remove patch-set based on 3.8rc-2.
> 
> This patch-set aims to implement physical memory hot-removing.
> 
> The patches can free/remove the following things:
> 
>   - /sys/firmware/memmap/X/{end, start, type} : [PATCH 4/15]
>   - memmap of sparse-vmemmap                  : [PATCH 6,7,8,10/15]
>   - page table of removed memory              : [RFC PATCH 7,8,10/15]
>   - node and related sysfs files              : [RFC PATCH 13-15/15]
> 
> 
> Existing problem:
> If CONFIG_MEMCG is selected, we will allocate memory to store page cgroup
> when we online pages.
> 
> For example: there is a memory device on node 1. The address range
> is [1G, 1.5G). You will find 4 new directories memory8, memory9, memory10,
> and memory11 under the directory /sys/devices/system/memory/.
> 
> If CONFIG_MEMCG is selected, when we online memory8, the memory stored page
> cgroup is not provided by this memory device. But when we online memory9, the
> memory stored page cgroup may be provided by memory8. So we can't offline
> memory8 now. We should offline the memory in the reversed order.
> 
> When the memory device is hotremoved, we will auto offline memory provided
> by this memory device. But we don't know which memory is onlined first, so
> offlining memory may fail.

This does sound like a significant problem.  We should assume that
mmecg is available and in use.

> In patch1, we provide a solution which is not good enough:
> Iterate twice to offline the memory.
> 1st iterate: offline every non primary memory block.
> 2nd iterate: offline primary (i.e. first added) memory block.

Let's flesh this out a bit.

If we online memory8, memory9, memory10 and memory11 then I'd have
thought that they would need to offlined in reverse order, which will
require four iterations, not two.  Is this wrong and if so, why?

Also, what happens if we wish to offline only memory9?  Do we offline
memory11 then memory10 then memory9 and then re-online memory10 and
memory11?

> And a new idea from Wen Congyang <wency@cn.fujitsu.com> is:
> allocate the memory from the memory block they are describing.

Yes.

> But we are not sure if it is OK to do so because there is not existing API
> to do so, and we need to move page_cgroup memory allocation from MEM_GOING_ONLINE
> to MEM_ONLINE.

This all sounds solvable - can we proceed in this fashion?

> And also, it may interfere the hugepage.

Please provide full details on this problem.

> Note: if the memory provided by the memory device is used by the kernel, it
> can't be offlined. It is not a bug.

Right.  But how often does this happen in testing?  In other words,
please provide an overall description of how well memory hot-remove is
presently operating.  Is it reliable?  What is the success rate in
real-world situations?  Are there precautions which the administrator
can take to improve the success rate?  What are the remaining problems
and are there plans to address them?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
