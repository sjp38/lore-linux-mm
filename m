Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id D56AC6B0124
	for <linux-mm@kvack.org>; Sun,  5 May 2013 22:24:54 -0400 (EDT)
Message-ID: <51871520.6020703@cn.fujitsu.com>
Date: Mon, 06 May 2013 10:27:44 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 10/13] x86, acpi, numa, mem-hotplug: Introduce MEMBLK_HOTPLUGGABLE
 to mark and reserve hotpluggable memory.
References: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com> <1367313683-10267-11-git-send-email-tangchen@cn.fujitsu.com> <20130503105037.GA4533@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20130503105037.GA4533@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, laijs@cn.fujitsu.com, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Vasilis,

Sorry for the delay and thank you for reviewing and testing. :)

On 05/03/2013 06:50 PM, Vasilis Liaskovitis wrote:
>
> Should we skip ranges on nodes that the kernel uses? e.g. with
>
>          if (memblock_is_kernel_node(nid))
>              continue;

Yes. I think I forgot to call it in this patch.
Will update in the next version.

>
>
> - I am getting a "PANIC: early exception" when rebooting with movablecore=acpi
> after hotplugging memory on node0 or node1 of a 2-node VM. The guest kernel is
> based on
> git://git.kernel.org/pub/scm/linux/kernel/git/yinghai/linux-yinghai.git
> for-x86-mm (e9058baf) + these v2 patches.
>
> This happens with or without the above memblock_is_kernel_node(nid) check.
> Perhaps I am missing something or I need a newer "ACPI, numa: Parse numa info
> early" patch-set?

I didn't test it on a VM. But on my real box, I haven't got a panic
when rebooting. I think I can help to test it in a VM, but would you 
please to
tell me how to setup a environment as yours ?

>
> A general question: Disabling hot-pluggability/zone-movable eligibility for a
> whole node sounds a bit inflexible, if the machine only has one node to begin
> with.  Would it be possible to keep movable information per SRAT entry? I.e
> if the BIOS presents multiple SRAT entries for one node/PXM (say node 0), and
> there is no memblock/kernel allocation on one of these SRAT entries, could
> we still mark this SRAT entry's range as hot-pluggable/movable?  Not sure if
> many real machine BIOSes would do this, but seabios could.  This implies that
> SRAT entries are processed for movable-zone eligilibity before they are merged
> on node/PXM basis entry-granularity (I think numa_cleanup_meminfo currently does
> this merge).

Yes, this can be done. But in real usage, part of the memory in a node
is hot-removable makes no sense, I think. We cannot remove the whole node,
so we cannot remove a real hardware device.

But in virtualization, would you please give a reason why we need this
entry-granularity ?


Another thinking. Assume I didn't understand your question correctly. :)

Now in kernel, we can recognize a node (by PXM in SRAT), but we cannot
recognize a memory device. Are you saying if we have this 
entry-granularity,
we can hotplug a single memory device in a node ? (Perhaps there are more
than on memory device in a node.)

If so, it makes sense. But I don't the kernel is able to recognize which
device a memory range belongs to now. And I'm not sure if we can do this.

>
> Of course the kernel should still have enough memory(i.e. non movable zone) to
> boot. Can we ensure that at least certain amount of memory is non-movable, and
> then, given more separate SRAT entries for node0 not used by kernel, treat
> these rest entries as movable?

I tried this idea before. But as HPA said, it seems no way to calculate 
how much
memory the kernel needs.
https://lkml.org/lkml/2012/11/27/29


Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
