Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA04742
	for <linux-mm@kvack.org>; Sat, 18 Jul 1998 09:28:24 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk> 	<m190lxmxmv.fsf@flinx.npwt.net> 	<199807141730.SAA07239@dax.dcs.ed.ac.uk> <m14swgm0am.fsf@flinx.npwt.net>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 18 Jul 1998 15:28:17 +0200
In-Reply-To: ebiederm+eric@npwt.net's message of "17 Jul 1998 20:10:25 -0500"
Message-ID: <87d8b370ge.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ebiederm+eric@npwt.net (Eric W. Biederman) writes:

> >>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:
> 
> ST> Hi,
> ST> On 13 Jul 1998 13:08:56 -0500, ebiederm+eric@npwt.net (Eric
> ST> W. Biederman) said:
> 
> >>>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:
> >> 1) We have a minimum size for the buffer cache in percent of physical pages.
> >> Setting the minimum to 0% may help.
> 
> ST> ...
> 
> >> Personally I think it is broken to set the limits of cache sizes
> >> (buffer & page) to anthing besides: max=100% min=0% by default.
> 
> ST> Yep; I disabled those limits for the benchmarks I announced.  Disabling
> ST> the ageing but keeping the limits in place still resulted in a
> ST> performance loss.
> 
> >> 2) If we play with LRU list it may be most practical use page->next
> >> and page->prev fields for the list, and for truncate_inode_pages &&
> >> invalidate_inode_pages
> 
> ST> Yikes --- for large files the proposal that we do
> 
> >> do something like:
> >> for(i = 0; i < inode->i_size; i+= PAGE_SIZE) {
> >> page = find_in_page_cache(inode, i);
> >> if (page) 
> >> /* remove it */
> >> ;
> >> }
> 
> ST> will be disasterous.  No, I think we still need the per-inode page
> ST> lists.  When we eventually get an fsync() which works through the page
> ST> cache, this will become even more important.
> 
> Duh.  Ext2 only does with in truncate with the block cache on a real
> truncate, when and inode is closed it doesn't need to do that.  Sorry
> I though I had precedent for that algorithm.
> 
> O.k. scracth that idea.
> 
> So I guess a LRU list for pages will require that we increase the size
> of struct page.  I guess it is makes sense if we can ultimately:
> a) use if for every page on the system ala the swap cache.
> b) remove the buffer cache which should provide the necessary
>    expansion room.  So we won't ultimately use more space.
> c) use it for a lru on dirty pages.
> d) doesn't fragment memory with slabs...
> 
> I hate considering expanding struct page after all of the work
> that has gone into shriking the lately....
> 
> And for writes it looks like I'll need a write time too, for best
> performance.  I've written the code I just haven't tested it yet.
> 
> Zlatko could I talk you into setting the defines in mmap.h so it shmfs
> will use those and report if bonnie improves...
> 

When it comes to benchmarking, I'm always prepared. :)

It's just, that I didn't understand completely what are you trying to
do, but if you have a prepared patch, I'll gladly test it.

BTW, looking at 2.1.109, I'm very pleased with the changes made in mm/ 
directory. Finally, free_memory_available is simple, readable and
efficient. ;)

Next week, I will test some ideas which possibly could improve things
WITH page aging.

I must admit, after lot of critics I made upon page aging, that I
believe it's the right way to go, but it should be done properly.
Performance should be better, not worse.

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
  Any sufficiently advanced bug is indistinguishable from a feature.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
