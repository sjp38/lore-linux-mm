Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA02013
	for <linux-mm@kvack.org>; Fri, 17 Jul 1998 22:30:21 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<199807141730.SAA07239@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 17 Jul 1998 20:10:25 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Tue, 14 Jul 1998 18:30:19 +0100
Message-ID: <m14swgm0am.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi,
ST> On 13 Jul 1998 13:08:56 -0500, ebiederm+eric@npwt.net (Eric
ST> W. Biederman) said:

>>>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:
>> 1) We have a minimum size for the buffer cache in percent of physical pages.
>> Setting the minimum to 0% may help.

ST> ...

>> Personally I think it is broken to set the limits of cache sizes
>> (buffer & page) to anthing besides: max=100% min=0% by default.

ST> Yep; I disabled those limits for the benchmarks I announced.  Disabling
ST> the ageing but keeping the limits in place still resulted in a
ST> performance loss.

>> 2) If we play with LRU list it may be most practical use page->next
>> and page->prev fields for the list, and for truncate_inode_pages &&
>> invalidate_inode_pages

ST> Yikes --- for large files the proposal that we do

>> do something like:
>> for(i = 0; i < inode->i_size; i+= PAGE_SIZE) {
>> page = find_in_page_cache(inode, i);
>> if (page) 
>> /* remove it */
>> ;
>> }

ST> will be disasterous.  No, I think we still need the per-inode page
ST> lists.  When we eventually get an fsync() which works through the page
ST> cache, this will become even more important.

Duh.  Ext2 only does with in truncate with the block cache on a real
truncate, when and inode is closed it doesn't need to do that.  Sorry
I though I had precedent for that algorithm.

O.k. scracth that idea.

So I guess a LRU list for pages will require that we increase the size
of struct page.  I guess it is makes sense if we can ultimately:
a) use if for every page on the system ala the swap cache.
b) remove the buffer cache which should provide the necessary
   expansion room.  So we won't ultimately use more space.
c) use it for a lru on dirty pages.
d) doesn't fragment memory with slabs...

I hate considering expanding struct page after all of the work
that has gone into shriking the lately....

And for writes it looks like I'll need a write time too, for best
performance.  I've written the code I just haven't tested it yet.

Zlatko could I talk you into setting the defines in mmap.h so it shmfs
will use those and report if bonnie improves...

Eric

p.s. Everyone please excuse any slow replies I'm in the middle of
moving and I can't read my mail too often.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
