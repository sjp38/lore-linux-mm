Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l92HEWma026851
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 13:14:32 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l92HETnY447516
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 11:14:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l92HETDA024499
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 11:14:29 -0600
Subject: Re: Hotplug memory remove
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <20071002095257.5b6e2e4c.kamezawa.hiroyu@jp.fujitsu.com>
References: <1191253063.29581.7.camel@dyn9047017100.beaverton.ibm.com>
	 <20071002011447.7ec1f513.kamezawa.hiroyu@jp.fujitsu.com>
	 <1191260987.29581.14.camel@dyn9047017100.beaverton.ibm.com>
	 <20071002095257.5b6e2e4c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 02 Oct 2007 10:17:34 -0700
Message-Id: <1191345455.6106.10.camel@dyn9047017100.beaverton.ibm.com>
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

Kame,

With little bit of hacking /proc/iomem on ppc64, I got hotplug memory
remove working. I didn't have to spend lot of time debugging the
infrastructure you added. Good work !!

Only complaint I have is, the use of /proc/iomem for verification.
I see few issues.

1) On X86-64, /proc/iomem contains all the memory regions, but they
are all marked IORESOURCE_BUSY. So looking for IORESOURCE_MEM wouldn't
work and always fails. Is any one working on x86-64 ? 

2) On ppc64, /proc/iomem shows only io-mapped-memory regions. So I
had to hack it to add all the memory information. I am going to ask
on ppc64 mailing list on how to do it sanely, but I am afraid that
they are going to say "all the information is available in the kernel
data (lmb) structures, parse them - rather than exporting it
to /proc/iomem". 

We may have to have arch-specific hooks to verify a memory region :(
What do you think ?



Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
