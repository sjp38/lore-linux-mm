Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id CF8156B0099
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 09:18:28 -0400 (EDT)
Received: by mail-bk0-f44.google.com with SMTP id r7so288937bkg.31
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 06:18:27 -0700 (PDT)
Date: Mon, 3 Jun 2013 15:18:23 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [PATCH v3 07/13] x86, numa, mem-hotplug: Mark nodes which the
 kernel resides in.
Message-ID: <20130603131823.GA4729@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1369387762-17865-1-git-send-email-tangchen@cn.fujitsu.com>
 <1369387762-17865-8-git-send-email-tangchen@cn.fujitsu.com>
 <20130531162401.GA31139@dhcp-192-168-178-175.profitbricks.localdomain>
 <51AC4759.6090101@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51AC4759.6090101@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Tang,

On Mon, Jun 03, 2013 at 03:35:53PM +0800, Tang Chen wrote:
> Hi Vasilis,
>
[...]
> >The ranges above belong to node 0, but the node's bit is never marked.
> >
> >With a buggy bios that marks all memory as hotpluggable, this results in a
> >panic, because both checks against hotpluggable bit and memblock_kernel_bitmask
> >(in early_mem_hotplug_init) fail, the numa regions have all been merged together
> >and memblock_reserve_hotpluggable is called for all memory.
> >
> >With a correct bios (some part of initial memory is not hotplug-able) the kernel
> >can boot since the hotpluggable bit check works ok, but extra dimms on node 0
> >will still be allowed to be in MOVABLE_ZONE.
> >
> 
> OK, I see the problem. But would you please give me a call trace
> that can show
> how this could happen. I think the memory block info should be the same as
> numa_meminfo. Can we fix the caller to make it set nid correctly ?

memblock_reserve() calls memblock_add_region with nid == MAX_NUMNODES. So
all calls of memblock_reserve() in arch/x86/kernel/setup.c will cause memblock
additions with this non-specific node id I think.

Call sites I have seen in practice in my tests are trim_low_memory_range,
early_reserve_initrd, reserve_brk, all from setup_arch.

The MAX_NUMNODES case also happens when setup_arch adds memblocks for e820 map
entries:

setup_arch
  memblock_x86_fill
    memblock_add <--(calls memblock_add_region with nid == MAX_NUMNODES)

The problem is that these functions are called before numa/srat discovery in
early_initmem_init. So we don't have the numa_meminfo yet when these memblocks
are added/reserved. If calls can be re-ordered that would work, otherwise we should
update nid memblock fields after numa_meminfo has been setup.

> 
> >Actually this behaviour (being able to have MOVABLE memory on nodes with kernel
> >reserved memblocks) sort of matches the policy I requested in v2 :). But i
> >suspect that is not your intent i.e. you want memblock_kernel_nodemask_bitmap to
> >prevent movable reservations for the whole node where kernel has reserved
> >memblocks.
> 
> I intended to set the whole node which the kernel resides in as
> un-hotpluggable.
> 
> >
> >Is there a way to get accurate nid information for memblocks at early boot? I
> >suspect pfn_to_nid doesn't work yet at this stage (i got a panic when I
> >attempted iirc)
> 
> In such an early time, I think we can only get nid from
> numa_meminfo. So as I
> said above, I'd like to fix this problem by making memblock has correct nid.
> 
> And I read the patch below. I think if we get nid from numa_meminfo,
> than we
> don't need to call memblock_get_region_node().
> 

ok. If we update the memblock nid fields from numa_meminfo,
memblock_get_region_node will always return the correct node id.

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
