Date: Fri, 12 Nov 1999 11:17:51 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: zoned allocator in 2.3.27
Message-ID: <Pine.LNX.4.10.9911121116480.3494-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

we now have an explicitly zoned page allocator in 2.3.27 (yeah). Here is
the changelog, you guys might want to comment on it:


- explicit zone_t added:

	typedef struct zone_struct {
	       spinlock_t lock;
	       unsigned long offset;
	       unsigned long size;
	       free_area_t free_area[MAX_ORDER];
	
	       unsigned long free_pages;
	       unsigned long pages_low, pages_high;
	       int low_on_memory;
	       char * name;
	} zone_t;

  zone->offset is the offset into mem_map, page granularity. (it _should_
  work even if the boundary of zones does not lie on a 1<<MAX_ORDER
  boundary). zone->free_pages is the 'global' counter, and it's being
  exported via functions.

  i couldnt make up my mind wether to export the zone structure to outer
  subsystems, and ended up exporting these three functions:
  nr_free_pages(), nr_free_buffer_pages(), nr_free_highpages().

  zone->size is not strictly needed, but it doesnt hurt either and can be
  used for a temporary debugging check. (it has caught a nasty bug
  already)

- allocation uses per-zone spinlocks, page_alloc_lock is gone.

- removed area->count from the per-order bitmap structures. This speeds up
  things a bit, the only place which needed it was a debugging printout,
  which can get this info otherwise.

- fixed the utility functions rmqueue() and EXPAND() to work correctly
  with zone->offset. My experience is that in the attached version there
  are no bugs in this area, but i've left some debugging checks in there
  anyway, maybe it's getting triggered somewhere.

- moved mem_type_strs[] into zone->name

- fixed balance_memory to be generic, removed the #ifdef CONFIG_HIGHMEM
  maze.

- removed some old stuff not needed anymore

- renamed NR_MEM_LISTS to MAX_ORDER, that is more accurate.

- changed the free_area_init() interface to pass in zone sizes - this
  affects non-x86 architectures as well.

The NUMA and huge-mem folks can use this as a base for further hacking.
We are almost zone-neutral now, no more 'if (highmem)' type of stuff.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
