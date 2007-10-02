Date: Tue, 2 Oct 2007 09:52:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Hotplug memory remove
Message-Id: <20071002095257.5b6e2e4c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1191260987.29581.14.camel@dyn9047017100.beaverton.ibm.com>
References: <1191253063.29581.7.camel@dyn9047017100.beaverton.ibm.com>
	<20071002011447.7ec1f513.kamezawa.hiroyu@jp.fujitsu.com>
	<1191260987.29581.14.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 01 Oct 2007 10:49:46 -0700
Badari Pulavarty <pbadari@gmail.com> wrote:

> > 
> > > 2) I copied remove_memory() from IA64 to PPC64. When I am testing
> > > hotplug-remove (echo offline > state), I am not able to remove
> > > any memory at all. I get different type of failures like ..
> > > 
> > > memory offlining 6e000 to 6f000 failed
> > > 
> > I'm not sure about this...does this memory is in ZONE_MOVABLE ?
> > If not ZONE_MOVABLE, offlining can be fail because of not-removable
> > kernel memory. 
> 
> I tried offlining different sections of memory. There is no easy 
> way to tell if it belonged to ZONE_MOVABLE or not. I was
> using /proc/page_owner to find out suitable sections to offline.
> 
Hmm, I myself cat /proc/zoneinfo to know where is ZONE_MOVABLE.
[start_pfn, start_pfn+spanned) is zone range.
But I hear PPC? can overlap plural zones' range...

Some interface like
/sys/device/system/memory/memoryXXX/zone_id
is maybe good, but a section can belongs to multiple zones.


> > Does PPC64 resister conventinal memory to memory resource ?
> > This information can be shown in /proc/iomem.
> > In current code, removable memory must be registerred in /proc/iomem.
> > Could you confirm ?
> 
> I am little confused. Can you point me to the code where you have
> this assumption ? Why does it have to be registered in /proc/meminfo ?
> You find the section and try to offline it by migrating pages from that
> section. If its fails to free up the pages, fail the remove. Isn't it ?
> 
Maybe already you noticed, walk_memory_resource() handles it.

Because a section can includes memory hole or memory for I/O,
we cannot know whether Pg_reserved memory is just reserved or memory hole
or for I/O.

/proc/iomem shows the range of conventional memory if configured in sane way.
For avoiding memory hole, /proc/iomem  gives us very clear resource range
information.

> On my ppc64 machine, I don't see nothing but iomemory in /proc/meminfo.
> 
Ah, not meminfo.
This is my box's proc iomem
==
[kamezawa@drpq linux-2.6.23-rc8-mm2]$ cat /proc/iomem | grep RAM
00000000-0009ffff : System RAM
00100000-03ffffff : System RAM
04000000-04dabfff : System RAM
04dac000-6b4bffff : System RAM
6b4c0000-6b797fff : System RAM
6b798000-6b799fff : System RAM
6b79a000-6b79dfff : System RAM
6b79e000-6b79efff : System RAM
6b79f000-6b7fbfff : System RAM
6b7fc000-6c629fff : System RAM
6c62a000-6c800fff : System RAM
6c801000-6c843fff : System RAM
6c844000-6c847fff : System RAM
6c848000-6c849fff : System RAM
6c84a000-6c85dfff : System RAM
6c85e000-6c85efff : System RAM
6c85f000-6cbfbfff : System RAM
6cbfc000-6d349fff : System RAM
6d34a000-6d3fbfff : System RAM
6d3fc000-6d455fff : System RAM
6d4fc000-6d773fff : System RAM
100000000-7ffffffff : System RAM
4080000000-40ffffffff : System RAM
14004000000-147ffffffff : System RAM
==
All conventional memory is registered as System RAM. This is done in
efi(firmware)'s memory map parsing in ia64.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
