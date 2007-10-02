Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l92EtAAB027018
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 10:55:10 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l92Et48M453910
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 08:55:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l92Et3gv021449
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 08:55:03 -0600
Subject: Re: Hotplug memory remove
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <20071002095257.5b6e2e4c.kamezawa.hiroyu@jp.fujitsu.com>
References: <1191253063.29581.7.camel@dyn9047017100.beaverton.ibm.com>
	 <20071002011447.7ec1f513.kamezawa.hiroyu@jp.fujitsu.com>
	 <1191260987.29581.14.camel@dyn9047017100.beaverton.ibm.com>
	 <20071002095257.5b6e2e4c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 02 Oct 2007 07:58:09 -0700
Message-Id: <1191337089.6106.2.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-02 at 09:52 +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 01 Oct 2007 10:49:46 -0700
> Badari Pulavarty <pbadari@gmail.com> wrote:
> 
> > > 
> > > > 2) I copied remove_memory() from IA64 to PPC64. When I am testing
> > > > hotplug-remove (echo offline > state), I am not able to remove
> > > > any memory at all. I get different type of failures like ..
> > > > 
> > > > memory offlining 6e000 to 6f000 failed
> > > > 
> > > I'm not sure about this...does this memory is in ZONE_MOVABLE ?
> > > If not ZONE_MOVABLE, offlining can be fail because of not-removable
> > > kernel memory. 
> > 
> > I tried offlining different sections of memory. There is no easy 
> > way to tell if it belonged to ZONE_MOVABLE or not. I was
> > using /proc/page_owner to find out suitable sections to offline.
> > 
> Hmm, I myself cat /proc/zoneinfo to know where is ZONE_MOVABLE.
> [start_pfn, start_pfn+spanned) is zone range.
> But I hear PPC? can overlap plural zones' range...
> 
> Some interface like
> /sys/device/system/memory/memoryXXX/zone_id
> is maybe good, but a section can belongs to multiple zones.
> 
> 
> > > Does PPC64 resister conventinal memory to memory resource ?
> > > This information can be shown in /proc/iomem.
> > > In current code, removable memory must be registerred in /proc/iomem.
> > > Could you confirm ?
> > 
> > I am little confused. Can you point me to the code where you have
> > this assumption ? Why does it have to be registered in /proc/meminfo ?
> > You find the section and try to offline it by migrating pages from that
> > section. If its fails to free up the pages, fail the remove. Isn't it ?
> > 
> Maybe already you noticed, walk_memory_resource() handles it.
> 
> Because a section can includes memory hole or memory for I/O,
> we cannot know whether Pg_reserved memory is just reserved or memory hole
> or for I/O.
> 
> /proc/iomem shows the range of conventional memory if configured in sane way.
> For avoiding memory hole, /proc/iomem  gives us very clear resource range
> information.
> 
> > On my ppc64 machine, I don't see nothing but iomemory in /proc/meminfo.
> > 
> Ah, not meminfo.
> This is my box's proc iomem

I meant /proc/iomem. On PPC64 all the memory information is in "lmb"
structures and not available through /proc/iomem. We need to find a
way to get to that. I will ask around on ppc mailing list to find
out if there is another easy way.

Thanks,
Badari

elm3b155:~/linux-2.6.23-rc8 # cat /proc/iomem
40080000000-400bfffffff : /pci@800000020000002
  40080000000-400a7ffffff : PCI Bus 0000:d0
    40080000000-400807fffff : 0000:d0:01.0
      40080000000-400807fffff : ipr
    40080800000-400808fffff : 0000:d0:01.0
    40080900000-4008093ffff : 0000:d0:01.0
      40080900000-4008093ffff : ipr
  400a8000000-400afffffff : PCI Bus 0000:cc
    400a8000000-400a8003fff : 0000:cc:01.0
  400b0000000-400b7ffffff : PCI Bus 0000:c8
    400b0000000-400b0000fff : 0000:c8:01.1
    400b0001000-400b0001fff : 0000:c8:01.0
    400b0002000-400b00020ff : 0000:c8:01.2
  400b8000000-400bfefffff : PCI Bus 0000:c0
    400b8000000-400b803ffff : 0000:c0:01.1
    400b8040000-400b807ffff : 0000:c0:01.1
      400b8040000-400b807ffff : e1000
    400b8080000-400b80bffff : 0000:c0:01.0
    400b80c0000-400b80fffff : 0000:c0:01.0
      400b80c0000-400b80fffff : e1000
    400b8100000-400b811ffff : 0000:c0:01.1
      400b8100000-400b811ffff : e1000
    400b8120000-400b813ffff : 0000:c0:01.0
      400b8120000-400b813ffff : e1000
401c0000000-401ffffffff : /pci@800000020000003
  401c0000000-401efffffff : PCI Bus 0001:d8
  401f0000000-401f7ffffff : PCI Bus 0001:c8
  401f8000000-401ffefffff : PCI Bus 0001:d0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
