Date: Tue, 17 Aug 1999 02:10:43 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <199908162339.QAA67278@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9908170151190.14379-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 1999, Kanoj Sarcar wrote:

>a page to remap to). Remapping in just the swap code is acceptable, but
>probably not for other cases (like rawio).

Agreed completly.

>way it is, is so that drivers don't break. I think 2.3 is the place to 
>teach the kernel and drivers that all of memory is not directly mappable.

I tried to avoid this (and I am been successfully until I noticed raw-io
in 2.3.13... sigh).

In the meantime I'll take raw-io disabled if CONFIG_BIGMEM is set .

> [..] And kmalloc could also use
>bigmem pages for holding kernel data structures ...

I really don't think this will ever happen.

BTW, the previous patch I posted for disable raw-io on bigmem pages seems
that won't work correctly but it seems a bug in map_user_kiobuf:

[..]
static struct page * get_page_map(unsigned long page)
{
	struct page *map;
	
	if (MAP_NR(page) >= max_mapnr)
		return 0;
	if (page == ZERO_PAGE(page))
		return 0;
	map = mem_map + MAP_NR(page);
	if (PageReserved(map))
		return 0;
#ifdef CONFIG_BIGMEM
	if (PageBIGMEM(map))
		return 0;
#endif
	return map;
}
[..]
		map = get_page_map(page);
		if (map) {
			if (TryLockPage(map)) {
				goto retry;
			}
			atomic_inc(&map->count);
		}
		spin_unlock(&mm->page_table_lock);
		dprintk ("Installing page %p %p: %d\n", (void *)page, map, i);
		iobuf->pagelist[i] = page;
		iobuf->maplist[i] = map;
		iobuf->nr_pages = ++i;
		
		ptr += PAGE_SIZE;
[..]

If get_page_map() will return zero, then the page will be queued anyway in
the iobuf. The fact that the map is null won't be checked in brw_kiovec().
So it seems you could write to the ZERO_PAGE if you first mmap() the zero
page and then you give as buffer the userspace area where you have mapped
the zero-page... What am I missing?

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
