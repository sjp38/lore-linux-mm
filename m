Date: Fri, 23 Jun 2000 14:28:26 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: Why is the free_list not null-terminated?
Message-Id: <20000623193609Z131187-21004+54@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is probably more of a general Linux kernel programming question that an MM
question, but maybe not.

I've written a program which traverses the free_area[] array of a zone.  The
output looks like this:

Jun 23 13:48:42 two kernel: Zone: c025c86c 
Jun 23 13:48:42 two kernel: O0: free_area c025c888, prev=c12c9ba0,
next=c12c9ba0, *map=0 
Jun 23 13:48:42 two kernel: mem_map_t at c12c9ba0: phys: 42cd4000 zone:
c025c86c 
Jun 23 13:48:42 two kernel: mem_map_t at c12c9ba0: phys: 42cd4000 zone:
c025c86c 
Jun 23 13:48:42 two kernel: O1: free_area c025c894, prev=c12c9ac8,
next=c12c9ac8, *map=0 
Jun 23 13:48:42 two kernel: mem_map_t at c12c9ac8: phys: 42cd1000 zone:
c025c86c 
Jun 23 13:48:42 two kernel: mem_map_t at c12c9ac8: phys: 42cd1000 zone:
c025c86c 
Jun 23 13:48:42 two kernel: O2: free_area c025c8a0, prev=c025c8a0,
next=c025c8a0, *map=0 
Jun 23 13:48:42 two kernel: mem_map_t at c025c8a0: phys: 8657000 zone: c1484080 
Jun 23 13:48:42 two kernel: mem_map_t at c025c8a0: phys: 8657000 zone: c1484080 

This is for the ZONE_NORMAL zone.  O0 means Order 0 or free_area[0].

If you look at O2, you'll see that the &free_area[2] is c024c8a0, and the prev
and next pointers are the same.  

Question #1: Does this mean that there are no free zones of Order 2 (16KB)?

Question #2: Why are prev and next not set to null?  Why do they point back to
free_area?  *prev is supposed to be of type mem_map_t, but in the case of O2,
it's not, so wouldn't that be a type mismatch?  If you look at the last two
lines, you'll see I'm displaying the contents of two *prev and *next, as if they
were mem_map_t structures, but they're not, so I get garbage values.  I would
think that the code would be better if prev and next, in this case, were set to
NULL to indicate the end of the list.  After all, *prev and *next are not
meaningful any more.



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
