Received: from remus.clara.net (remus.clara.net [195.8.69.79])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA31852
	for <Linux-MM@kvack.org>; Wed, 27 Jan 1999 18:55:32 -0500
Received: from atlantis.mail (du-1537.claranet.co.uk [195.8.78.102])
	by remus.clara.net (8.8.8/8.8.8) with SMTP id XAA19119
	for <Linux-MM@kvack.org>; Wed, 27 Jan 1999 23:54:00 GMT
	(envelope-from ph@clara.net)
From: Paul Hamshere <ph@clara.net>
Subject: Fwd: Inoffensive bug in mm/page_alloc.c
Reply-To: Paul Hamshere <ph@clara.net>
Message-Id: <990127235552.n0002181.ph@mail.clara.net>
References: <990119214302.n0001113.ph@mail.clara.net>
Date: Wed, 27 Jan 99 23:55:52 GMT
Sender: owner-linux-mm@kvack.org
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Is this of any interest here?
Paul
------------------------------
Hi
I was trawling through the mm sources to try and understand how linux tracks the
use of pages of memory, how kmalloc and vmalloc work, and I think there is a bug
in the kernel (2.0) - it doesn't affect anything, only waste a tiny amount of
memory....does anyone else think it looks wrong?
The problem is in free_area_init where it allocates the bitmaps - I think they
are twice the size they need to be.
The dodgy line is

            bitmap_size = (end_mem - PAGE_OFFSET) >> (PAGE_SHIFT + i );

which I think should be 

            bitmap_size = (end_mem - PAGE_OFFSET) >> (PAGE_SHIFT + i + 1);

because the bitmap refers to adjacent pages.
I've changed my kernel to the second line and it seems to work.
Paul


----------------------------------------------------

unsigned long free_area_init(unsigned long start_mem, unsigned long end_mem)
{
      mem_map_t * p;
      unsigned long mask = PAGE_MASK;
      int i;

      /*
       * select nr of pages we try to keep free for important stuff
       * with a minimum of 48 pages. This is totally arbitrary
       */
      i = (end_mem - PAGE_OFFSET) >> (PAGE_SHIFT+7);
      if (i < 24)
            i = 24;
      i += 24;   /* The limit for buffer pages in __get_free_pages is
                * decreased by 12+(i>>3) */
      min_free_pages = i;
      free_pages_low = i + (i>>1);
      free_pages_high = i + i;
      start_mem = init_swap_cache(start_mem, end_mem);
      mem_map = (mem_map_t *) start_mem;
      p = mem_map + MAP_NR(end_mem);
      start_mem = LONG_ALIGN((unsigned long) p);
      memset(mem_map, 0, start_mem - (unsigned long) mem_map);
      do {
            --p;
            p->flags = (1 << PG_DMA) | (1 << PG_reserved);
            p->map_nr = p - mem_map;
      } while (p > mem_map);

      for (i = 0 ; i < NR_MEM_LISTS ; i++) {
            unsigned long bitmap_size;
            init_mem_queue(free_area+i);
            mask += mask;
            end_mem = (end_mem + ~mask) & mask;
/* commented out because not correct ?? PH
            bitmap_size = (end_mem - PAGE_OFFSET) >> (PAGE_SHIFT + i);
*/
            bitmap_size = (end_mem - PAGE_OFFSET) >> (PAGE_SHIFT + i +1);
            bitmap_size = (bitmap_size + 7) >> 3;
            bitmap_size = LONG_ALIGN(bitmap_size);
            free_area[i].map = (unsigned int *) start_mem;
            memset((void *) start_mem, 0, bitmap_size);
            start_mem += bitmap_size;
      }
      return start_mem;
}




--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
