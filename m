Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id WAA22443
	for <linux-mm@kvack.org>; Fri, 6 Sep 2002 22:14:50 -0700 (PDT)
Message-ID: <3D798E8C.3DCD883C@digeo.com>
Date: Fri, 06 Sep 2002 22:28:44 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: inactive_dirty list
References: <3D7960FC.3E2C890A@digeo.com> <Pine.LNX.4.44L.0209062309580.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Fri, 6 Sep 2002, Andrew Morton wrote:
> 
> > I have a silly feeling that setting DEF_PRIORITY to "12" will
> > simply fix this.
> >
> > Duh.
> 
> Ideally we'd get rid of DEF_PRIORITY alltogether and would
> just scan each zone once.
> 

What I'm doing now is:

#define DEF_PRIORITY 12		/* puke */

        for (priority = DEF_PRIORITY; priority; priority--) {
		int total_scanned = 0;

		shrink_caches(priority, &total_scanned);
		if (that didn't work) {
			wakeup_bdflush(total_scanned);
			blk_congestion_wait(WRITE, HZ/4);
		}
	}

and in shrink_caches():

	max_scan = zone->nr_inactive >> priority;
        if (max_scan < nr_pages * 2)
                max_scan = nr_pages * 2;
        nr_pages = shrink_zone(zone, max_scan, gfp_mask, nr_pages);

So in effect, for a 32-page reclaim attempt we'll scan 64 pages
of ZONE_HIGHMEM, then 128 pages of ZONE_NORMAL/DMA.  If that doesn't
yield 32 pages we ask pdflush to write 3*64 pages.  Then take a nap.

Then do it again: scan 64 pages of ZONE_HIGHMEM, then 128 of ZONE_NORMAL/DMA,
then write back 192 pages then nap.

Then do it again: scan 128 pages of ZONE_HIGHMEM, then 256 of ZONE_NORMAL/DMA,
then write back 384 pages then nap.

etc.  Plus there are the actual pages which we started IO against
during the LRU scan - there can be up to 32 of those.

BTW, it turns out that the main reason why kswapd was going silly was
that the VM is *not* treating the `priority' as a logarithmic thing at
all:

        int max_scan = nr_inactive_pages / priority;

so the claims about scanning 1/64th of the list are crap.  That
thing scans 1/6th of the queue on the first pass.  In the mem=1G
case, that's 30,000 damn pages.   Maybe someone should take a look
at Marcelo's kernel?


There are a few warts: pdflush_operation will fail if all pdflush threads
are out doing something (pretty unlikely with the nonblocking stuff.
Might happen if writeback has to run get_block()).  But we'll be writing
back stuff anyway.

I changed blk_congestion_wait a bit too.  The first version would
return immediately if no queues were congested ( > 75% full). Now,
it will sleep even if no queues are congested.  It will return
as soon as someone puts back a write request.  If someone is silly
enough to call blk_congestion_wait() when there are no write requests
in flight at all, they get to take the full 1/4 second sleep.

The mem=1G corner case is fixed, and page reclaim just doesn't
figure:

c012c034 288      0.317709    do_wp_page              
c0144ae0 316      0.348597    __block_commit_write    
c012c910 342      0.377279    do_anonymous_page       
c0143efc 353      0.389414    __find_get_block        
c012f7e0 356      0.392724    find_lock_page          
c012f9f0 356      0.392724    do_generic_file_read    
c01832bc 367      0.404858    ext2_free_branches      
c0136e70 371      0.409271    __free_pages_ok         
c010e7b4 386      0.425818    timer_interrupt         
c01e3cfc 414      0.456707    radix_tree_lookup       
c0141894 434      0.47877     vfs_write               
c012f580 474      0.522896    unlock_page             
c0134348 500      0.551578    kmem_cache_alloc        
c01347d0 531      0.585776    kmem_cache_free         
c013712c 574      0.633212    rmqueue                 
c0141320 605      0.667409    generic_file_llseek     
c0156924 616      0.679544    count_list              
c0142c04 617      0.680647    fget                    
c01091e0 793      0.874803    system_call             
c0155914 860      0.948714    __d_lookup              
c0144674 1076     1.187       __block_prepare_write   
c014c63c 1184     1.30614     link_path_walk          
c012fcd4 10932    12.0597     file_read_actor         
c0130674 16443    18.1392     generic_file_write_nolock 
c0107048 31293    34.5211     poll_idle               

The balancing of the zones looks OK from a first glance and of course
the change in system behaviour under heavy writeout loads is profound.

Let's do the MAP_SHARED-pages-get-a-second-round thing, and it'd
be good if we could come up with some algorithm for setting the
current dirty pagecache clamping level rather than relying on the
dopey /proc/sys/vm/dirty_async_ratio magic number. 

I'm thinking that dirty_async_ratio becomes a maximum ratio, and
that we dynamically lower it when large amounts of dirty pagecache
would be embarrassing.  Or maybe there's just no need for this.  Dunno.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
