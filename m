Message-ID: <3D76EEFE.13467890@zip.com.au>
Date: Wed, 04 Sep 2002 22:43:26 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: nonblocking-vm.patch
References: <3D768C12.6CEBDA74@zip.com.au> <Pine.LNX.4.44L.0209041944510.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

For the record...

One thing we could do is to make the heavy write()r perform
blocking writeback in the page allocator:

generic_file_write()
{
	current->bdi = mapping->backing_dev_info;
	...
	current->bdi = NULL;
}

shrink_list()
{
	...
	if (PageDirty(page) && mapping->backing_dev_info == current->bdi)
		writeback(page->mapping);
	...
}

So when that writer allocates a page, he gets to clean up
his own mess, rather than scanning past those pages.

We have to write back just that queue; otherwise we get back to
the situation where one queue enters congested and that blocks the
whole world.

It's just an idea to bear in mind - balance_dirty_pages() is
supposed to be the place where this happens, but the above would
perhaps mop up some mmapped dirty memory, stray dirty pages which
reach the cold end of the LRU, etc.   And this is definitely a
writeback resource which we can use in that situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
