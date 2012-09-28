Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id E28476B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 22:00:31 -0400 (EDT)
Message-ID: <5065005A.4020907@cn.fujitsu.com>
Date: Fri, 28 Sep 2012 09:41:46 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v9 PATCH 00/21] memory-hotplug: hot-remove physical memory
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com> <20120926164649.GA7559@dhcp-192-168-178-175.profitbricks.localdomain> <5063F41A.3010600@cn.fujitsu.com> <20120927103557.GA30772@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20120927103557.GA30772@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

At 09/27/2012 06:35 PM, Vasilis Liaskovitis Wrote:
> On Thu, Sep 27, 2012 at 02:37:14PM +0800, Wen Congyang wrote:
>> Hi Vasilis Liaskovitis
>>
>> At 09/27/2012 12:46 AM, Vasilis Liaskovitis Wrote:
>>> Hi,
>>>
>>> I am testing 3.6.0-rc7 with this v9 patchset plus more recent fixes [1],[2],[3]
>>> Running in a guest (qemu+seabios from [4]). 
>>> CONFIG_SLAB=y
>>> CONFIG_DEBUG_SLAB=y
>>>
>>> After succesfull hot-add and online, I am doing a hot-remove with "echo 1 > /sys/bus/acpi/devices/PNP/eject"
>>> When I do the OSPM-eject, I often get slab corruption in "acpi-state" cache, or in other caches
>>
>> I can't reproduce this problem. Can you provide the following information:
>> 1. config file
>> 2. qemu's command line
>>
>> You said you did OSPM-eject. Do you mean write 1 to /sys/bus/acpi/devices/PNP0C80:XX/eject?
> yes.
> 
> example qemu command line with one dimm:
> 
> "/opt/qemu-kvm-memhp/bin/qemu-system-x86_64 -bios
> /opt/extra/vliaskov/devel/seabios-upstream/out/bios.bin -enable-kvm -M pc -smp
> 4,maxcpus=8 -cpu host -m 2048 -drive file=/opt/extra/debian-template.raw,if=none,id=drive-virtio-disk0,format=raw
> -device virtio-blk-pci,bus=pci.0,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1
> -vga cirrus -netdev type=tap,id=guest0,vhost=on -device virtio-net-pci,netdev=guest0
> -monitor unix:/tmp/qemu.monitor11,server,nowait -chardev stdio,id=seabios  -device
> isa-debugcon,iobase=0x402,chardev=seabios
> -dimm id=n0,size=512M,node=0"
> 
> or last line with 2 numa nodes:
> "-dimm id=n0,size=512M,node=0 -dimm id=n1,size=512M,node=1 -numa node,nodeid=0 -numa node,nodeid=1"

I have reproduced this problem. It only can be reproduced when the dimm's memory is on node 0.
I investigate it now.

Thanks
Wen Congyang

> 
> attached config. Tree is at:
> https://github.com/vliaskov/linux/commits/memhp-fujitsu
> 
> thanks,
> - Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
