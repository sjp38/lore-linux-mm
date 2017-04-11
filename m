Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51C516B0390
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 07:38:23 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w96so19045197wrb.13
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 04:38:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r185si2675425wma.136.2017.04.11.04.38.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 04:38:21 -0700 (PDT)
Date: Tue, 11 Apr 2017 13:38:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170411113816.GH6729@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410162749.7d7f31c1@nial.brq.redhat.com>
 <20170410160941.GJ4618@dhcp22.suse.cz>
 <20170411083834.765c2201@nial.brq.redhat.com>
 <20170411092306.GD6729@dhcp22.suse.cz>
 <20170411115931.32659dd6@nial.brq.redhat.com>
 <20170411110143.GG6729@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170411110143.GG6729@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Tue 11-04-17 13:01:43, Michal Hocko wrote:
> On Tue 11-04-17 11:59:31, Igor Mammedov wrote:
> > On Tue, 11 Apr 2017 11:23:07 +0200
> > Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > On Tue 11-04-17 08:38:34, Igor Mammedov wrote:
> > > > for issue2:
> > > > -enable-kvm -m 2G,slots=4,maxmem=4G -smp 4 -numa node -numa node \
> > > > -drive if=virtio,file=disk.img -kernel bzImage -append 'root=/dev/vda1' \
> > > > -object memory-backend-ram,id=mem1,size=256M -object memory-backend-ram,id=mem0,size=256M \
> > > > -device pc-dimm,id=dimm1,memdev=mem1,slot=1,node=0 -device pc-dimm,id=dimm0,memdev=mem0,slot=0,node=1  
> > > 
> > > I must be doing something wrong here...
> > > qemu-system-x86_64 -enable-kvm -monitor telnet:127.0.0.1:9999,server,nowait -net nic -net user,hostfwd=tcp:127.0.0.1:5555-:22 -serial file:test.qcow_serial.log -enable-kvm -m 2G,slots=4,maxmem=4G -smp 4 -numa node -numa node -object memory-backend-ram,id=mem1,size=256M -object memory-backend-ram,id=mem0,size=256M -device pc-dimm,id=dimm1,memdev=mem1,slot=1,node=0 -device pc-dimm,id=dimm0,memdev=mem0,slot=0,node=1 -drive file=test.qcow,if=ide,index=0
> > > 
> > > for i in $(seq 0 3)
> > > do
> > > 	sh probe_memblock.sh $i
> > > done
> >
> > dimm to node mapping comes from ACPI subsystem (_PXM object in memory device),
> > which adds memory blocks automatically on hotplug.
> 
> Hmm, memory_probe_store relies on memory_add_physaddr_to_nid which in
> turn relies on numa_meminfo. I am not familiar with the intialization
> and got lost in in the code rather quickly but I assumed this should get
> the proper information from the ACPI subsystem. I will have to double
> check.
> 
> > you probably don't have ACPI_HOTPLUG_MEMORY config option enabled.
> 
> Yes that is the case and enabling it made all 4 memblocks available
> and associated with the proper node
> # ls -l /sys/devices/system/memory/memory3?/node*
> lrwxrwxrwx 1 root root 0 Apr 11 12:56 /sys/devices/system/memory/memory32/node0 -> ../../node/node0
> lrwxrwxrwx 1 root root 0 Apr 11 12:56 /sys/devices/system/memory/memory33/node0 -> ../../node/node0
> lrwxrwxrwx 1 root root 0 Apr 11 12:56 /sys/devices/system/memory/memory34/node1 -> ../../node/node1
> lrwxrwxrwx 1 root root 0 Apr 11 12:56 /sys/devices/system/memory/memory35/node1 -> ../../node/node1
> 
> # grep . /sys/devices/system/memory/memory3?/valid_zones
> /sys/devices/system/memory/memory32/valid_zones:Normal Movable
> /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> /sys/devices/system/memory/memory34/valid_zones:Normal Movable
> /sys/devices/system/memory/memory35/valid_zones:Normal Movable
> 
> I can even reproduce your problem
> # echo online_movable > /sys/devices/system/memory/memory33/state
> # echo online > /sys/devices/system/memory/memory32/state
> # grep . /sys/devices/system/memory/memory3?/valid_zones
> /sys/devices/system/memory/memory32/valid_zones:Movable
> /sys/devices/system/memory/memory33/valid_zones:Movable
> /sys/devices/system/memory/memory34/valid_zones:Normal Movable
> /sys/devices/system/memory/memory35/valid_zones:Normal Movable
> 
> I will investigate this

Dang, guess what. It is a similar type bug I've fixed in
show_valid_zones [1] already.

[1] http://lkml.kernel.org/r/20170410152228.GF4618@dhcp22.suse.cz
---
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ec2f987ec549..410c7ccb74fb 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -541,7 +541,7 @@ static inline bool zone_intersects(struct zone *zone,
 {
 	if (zone->zone_start_pfn <= start_pfn && start_pfn < zone_end_pfn(zone))
 		return true;
-	if (start_pfn + nr_pages > start_pfn && !zone_is_empty(zone))
+	if (start_pfn + nr_pages > zone->zone_start_pfn && !zone_is_empty(zone))
 		return true;
 	return false;
 }

I have decided to make it more readable and did zone_is_empty check
first. Everything is in my git tree attempts/rewrite-mem_hotplug branch.
I have to test it but I believe this is the culprit here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
