Date: Mon, 26 Jun 2000 16:45:34 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: referenced/uptodate pages in the free list?
Message-Id: <20000626215518Z131165-21002+48@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I've written a small driver which traverses the free list and prints out a list
of all the pages that are free (yes, I know it's a huge list).

The code goes from contig_page_data.node_zones[1].free_area[0] to
contig_page_data.node_zones[1].free_area[MAX_ORDER-1].  It traverses the
free_list for each free_area.  If I read everything correctly, each element in
free_area[x].free_list is a pointer to a physically contiguous list of 2^x
elements in the mem_map array.  IOW, if free_area[2].free_list.prev points to a
mem_map_t structure, then it means that that mem_map_t and the 3 following it
are supposed to be all free.

If I have that right, then I'm seeing something odd.  My program prints out the
contents of each mem_map_t pointed to be each element of free_list of each
free_area of orders 0, 1, 2, and 3.  I'm seeing something weird:

Jun 26 16:30:57 two kernel: O2: free_area c025c8a0, prev=c127bb28,
next=c129ad88, *map=0 

Jun 26 16:30:57 two kernel: mem_map_t at c127bb28: phys: 8d44000 flags: 0 zone:
c025c86c, phys: 8d45000 flags: 0 zone: c025c86c, phys: 8d46000 flags: 0 zone:
c025c86c, phys: 8d47000 flags: 0 zone: c025c86c,  

Jun 26 16:30:57 two kernel: mem_map_t at c129ad88: phys: 9430000 flags: c zone:
c025c86c, phys: 9431000 flags: c zone: c025c86c, phys: 9432000 flags: c zone:
c025c86c, phys: 9433000 flags: c zone: c025c86c,  

Look at the flags for these two lines.  The first block of mem_map_t structures
(4 mem_map_t's starting at address c127bb28) each has a value for 0 in the flags
field.  But this second block (4 mem_map_t's starting at address c129ad88) each
has a value of 0xC for the flags field.  This translates to the

#define PG_referenced		 2
#define PG_uptodate		 3

bits being set.  Could someone explain to me what it means for a free page to
have these bits set?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
