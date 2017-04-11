Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD9E56B0390
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 05:59:40 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b9so52559288qtg.4
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 02:59:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z186si8101171qkb.47.2017.04.11.02.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 02:59:39 -0700 (PDT)
Date: Tue, 11 Apr 2017 11:59:31 +0200
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170411115931.32659dd6@nial.brq.redhat.com>
In-Reply-To: <20170411092306.GD6729@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
	<20170410162749.7d7f31c1@nial.brq.redhat.com>
	<20170410160941.GJ4618@dhcp22.suse.cz>
	<20170411083834.765c2201@nial.brq.redhat.com>
	<20170411092306.GD6729@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Tue, 11 Apr 2017 11:23:07 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 11-04-17 08:38:34, Igor Mammedov wrote:
> > for issue2:
> > -enable-kvm -m 2G,slots=4,maxmem=4G -smp 4 -numa node -numa node \
> > -drive if=virtio,file=disk.img -kernel bzImage -append 'root=/dev/vda1' \
> > -object memory-backend-ram,id=mem1,size=256M -object memory-backend-ram,id=mem0,size=256M \
> > -device pc-dimm,id=dimm1,memdev=mem1,slot=1,node=0 -device pc-dimm,id=dimm0,memdev=mem0,slot=0,node=1  
> 
> I must be doing something wrong here...
> qemu-system-x86_64 -enable-kvm -monitor telnet:127.0.0.1:9999,server,nowait -net nic -net user,hostfwd=tcp:127.0.0.1:5555-:22 -serial file:test.qcow_serial.log -enable-kvm -m 2G,slots=4,maxmem=4G -smp 4 -numa node -numa node -object memory-backend-ram,id=mem1,size=256M -object memory-backend-ram,id=mem0,size=256M -device pc-dimm,id=dimm1,memdev=mem1,slot=1,node=0 -device pc-dimm,id=dimm0,memdev=mem0,slot=0,node=1 -drive file=test.qcow,if=ide,index=0
> 
> for i in $(seq 0 3)
> do
> 	sh probe_memblock.sh $i
> done
dimm to node mapping comes from ACPI subsystem (_PXM object in memory device),
which adds memory blocks automatically on hotplug.

you probably don't have ACPI_HOTPLUG_MEMORY config option enabled.

> 
> # ls -l /sys/devices/system/memory/memory3?/node*
> lrwxrwxrwx 1 root root 0 Apr 11 11:21 /sys/devices/system/memory/memory32/node0 -> ../../node/node0
> lrwxrwxrwx 1 root root 0 Apr 11 11:21 /sys/devices/system/memory/memory33/node0 -> ../../node/node0
> lrwxrwxrwx 1 root root 0 Apr 11 11:21 /sys/devices/system/memory/memory34/node0 -> ../../node/node0
> lrwxrwxrwx 1 root root 0 Apr 11 11:21 /sys/devices/system/memory/memory35/node0 -> ../../node/node0
> 
> all of them end in the same node0
> 
> # grep . /sys/devices/system/memory/memory3?/valid_zones
> /sys/devices/system/memory/memory32/valid_zones:Normal Movable
> /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> /sys/devices/system/memory/memory34/valid_zones:Normal Movable
> /sys/devices/system/memory/memory35/valid_zones:Normal Movable
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
