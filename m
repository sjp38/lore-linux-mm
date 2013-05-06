Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 0CDFE6B00FC
	for <linux-mm@kvack.org>; Mon,  6 May 2013 06:37:48 -0400 (EDT)
Received: by mail-bk0-f46.google.com with SMTP id w5so1535072bku.33
        for <linux-mm@kvack.org>; Mon, 06 May 2013 03:37:47 -0700 (PDT)
Date: Mon, 6 May 2013 12:37:43 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [PATCH v2 10/13] x86, acpi, numa, mem-hotplug: Introduce
 MEMBLK_HOTPLUGGABLE to mark and reserve hotpluggable memory.
Message-ID: <20130506103743.GA4929@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
 <1367313683-10267-11-git-send-email-tangchen@cn.fujitsu.com>
 <20130503105037.GA4533@dhcp-192-168-178-175.profitbricks.localdomain>
 <51871520.6020703@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51871520.6020703@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, laijs@cn.fujitsu.com, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Tang,

On Mon, May 06, 2013 at 10:27:44AM +0800, Tang Chen wrote:
> Hi Vasilis,
> 
> Sorry for the delay and thank you for reviewing and testing. :)
> 
> On 05/03/2013 06:50 PM, Vasilis Liaskovitis wrote:
> >
> >Should we skip ranges on nodes that the kernel uses? e.g. with
> >
> >         if (memblock_is_kernel_node(nid))
> >             continue;
> 
> Yes. I think I forgot to call it in this patch.
> Will update in the next version.
ok

> 
> >
> >
> >- I am getting a "PANIC: early exception" when rebooting with movablecore=acpi
> >after hotplugging memory on node0 or node1 of a 2-node VM. The guest kernel is
> >based on
> >git://git.kernel.org/pub/scm/linux/kernel/git/yinghai/linux-yinghai.git
> >for-x86-mm (e9058baf) + these v2 patches.
> >
> >This happens with or without the above memblock_is_kernel_node(nid) check.
> >Perhaps I am missing something or I need a newer "ACPI, numa: Parse numa info
> >early" patch-set?
> 
> I didn't test it on a VM. But on my real box, I haven't got a panic
> when rebooting. I think I can help to test it in a VM, but would you
> please to
> tell me how to setup a environment as yours ?

you can use qemu-kvm and seabios from these branches:
https://github.com/vliaskov/qemu-kvm/commits/memhp-v4
https://github.com/vliaskov/seabios/commits/memhp-v4

Instructions on how to use the DIMM/memory hotplug are here:

http://lists.gnu.org/archive/html/qemu-devel/2012-12/msg02693.html
(these patchsets are not in mainline qemu/qemu-kvm and seabios)

e.g. the following creates a VM with 2G initial memory on 2 nodes (1GB on each).
There is also an extra 1GB DIMM on each node (the last 3 lines below describe
this):

/opt/qemu/bin/qemu-system-x86_64 -bios /opt/devel/seabios-upstream/out/bios.bin \
-enable-kvm -M pc -smp 4,maxcpus=8 -cpu host -m 2G  \
-drive
file=/opt/images/debian.img,if=none,id=drive-virtio-disk0,format=raw,cache=none \
-device virtio-blk-pci,bus=pci.0,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1 \
-netdev type=tap,id=guest0,vhost=on -device virtio-net-pci,netdev=guest0 -vga \
std -monitor stdio \ 
-numa node,mem=1G,cpus=2,nodeid=0 -numa node,mem=0,cpus=2,nodeid=1 \
-device dimm,id=dimm0,size=1G,node=0,bus=membus.0,populated=off \
-device dimm,id=dimm1,size=1G,node=1,bus=membus.0,populated=off

After startup I hotplug the dimm0 on node0 (or dimm1 on node1, same result)
(qemu) device_add dimm,id=dimm0,size=1G,node=0,bus=membus.0

than i reboot VM. Kernel works without "movablecore=acpi" but panics with this
option.

Note this qemu/seabios does not model initial memory (-m 2G) as memory devices.
Only extra dimms ("device -dimm") are modeled as separate memory devices.

> 
> >
> >A general question: Disabling hot-pluggability/zone-movable eligibility for a
> >whole node sounds a bit inflexible, if the machine only has one node to begin
> >with.  Would it be possible to keep movable information per SRAT entry? I.e
> >if the BIOS presents multiple SRAT entries for one node/PXM (say node 0), and
> >there is no memblock/kernel allocation on one of these SRAT entries, could
> >we still mark this SRAT entry's range as hot-pluggable/movable?  Not sure if
> >many real machine BIOSes would do this, but seabios could.  This implies that
> >SRAT entries are processed for movable-zone eligilibity before they are merged
> >on node/PXM basis entry-granularity (I think numa_cleanup_meminfo currently does
> >this merge).
> 
> Yes, this can be done. But in real usage, part of the memory in a node
> is hot-removable makes no sense, I think. We cannot remove the whole node,
> so we cannot remove a real hardware device.
> 
> But in virtualization, would you please give a reason why we need this
> entry-granularity ?

see below, basically as you suggest we may have multiple memory devices on same
node.
> 
> 
> Another thinking. Assume I didn't understand your question correctly. :)
> 
> Now in kernel, we can recognize a node (by PXM in SRAT), but we cannot
> recognize a memory device. Are you saying if we have this
> entry-granularity,
> we can hotplug a single memory device in a node ? (Perhaps there are more
> than on memory device in a node.)

yes, this is what I mean. Multiple memory devices on one node is possible in
both a real machine and a VM.
In the VM case, seabios can present different DIMM devices for any number of
nodes. Each DIMM is also given a separate SRAT entry by seabios. So when the
kernel initially parses the entries, it sees multiple ones for the same node.
(these are merged together in numa_cleanup_meminfo though)

> 
> If so, it makes sense. But I don't the kernel is able to recognize which
> device a memory range belongs to now. And I'm not sure if we can do this.

kernel knows which memory ranges belong to each DIMM (with ACPI enabled, each
DIMM is represented by an acpi memory device, see drivers/acpi/acpi_memhotplug.c)

> 
> >
> >Of course the kernel should still have enough memory(i.e. non movable zone) to
> >boot. Can we ensure that at least certain amount of memory is non-movable, and
> >then, given more separate SRAT entries for node0 not used by kernel, treat
> >these rest entries as movable?
> 
> I tried this idea before. But as HPA said, it seems no way to
> calculate how much
> memory the kernel needs.
> https://lkml.org/lkml/2012/11/27/29

yes, if we can't guarantee enough non-movable memory for the kernel, I am not
sure how to do this.

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
