Date: Fri, 18 Aug 2000 14:34:06 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: spin_lock(&zone->lock)
Message-Id: <20000818195028Z131165-15482+43@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I have this code in my driver (truncataed for clarity):

    unsigned order;  // set to whatever order you want
    zone_t *zone = contig_page_data.node_zones + ZONE_NORMAL;                  
// Get the zone pointer

    free_area_t *area = zone->free_area+order;                           //
area contains the list_head and map bitmap
    struct list_head *list = &area->free_list;                           //
list contains the head of the mem_map_t linked list
    mem_map_t *mm = (mem_map_t *) list->next;                                  
// get the head of the mem_map_t linked list

    spin_lock(&zone->lock);
    list_del(&mm->list);                                        // yes, so
delete it from the list
    list_add(&mm->list, list);                                  // and add it
back. This moves it to the head
    spin_unlock(&zone->lock);

Will the spinlock effectively protect the linked list in the mm structure from
being modified by another thread?  Is the 2.4 kernel even re-entrant on an SMP
system?  Last I heard, it wasn't, so this spinlock is probably unnecessary.  I
had only one operating system class in college, so I always have a hard time
fully understand spinlocks and stuff like that.



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
