Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA05331
	for <linux-mm@kvack.org>; Mon, 13 Jul 1998 14:07:57 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 13 Jul 1998 13:08:56 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Mon, 13 Jul 1998 17:53:55 +0100
Message-ID: <m190lxmxmv.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi all,
ST> OK, a bit more benchmarking is showing bad problems with page ageing.
ST> I've been running 2.1 with a big ramdisk and without, with page ageing
ST> and without.  The results for a simple compile job (make a few
ST> dependency files then compile four .c files) look like this:

ST> 	2.0.34, 6m ram:			1:22

ST> 	2.1.108, 16m ram, 10m ramdisk:
ST> 		With page cache ageing:	Not usable (swap death during boot.)
ST> 		Without cache ageing:	8:47

ST> 	2.1.108, 6m ram:
ST> 		With page cache ageing:	4:14
ST> 		Without cache ageing:	3:22

O.k. Just a few thoughts.
1) We have a minimum size for the buffer cache in percent of physical pages.
   Setting the minimum to 0% may help.

2) If we play with LRU list it may be most practical use page->next and page->prev
   fields for the list, and for truncate_inode_pages && invalidate_inode_pages
do something like:
for(i = 0; i < inode->i_size; i+= PAGE_SIZE) {
	page = find_in_page_cache(inode, i);
	if (page) 
		/* remove it */
		;
}
And remove the inode->i_pages list.  This should be roughly equivalent
to the bforgets needed by truncate anyway so should impose not large
peformance penalty.

Personally I think it is broken to set the limits of cache sizes
(buffer & page) to anthing besides: max=100% min=0% by default.

But now that we have this hand tuneing option in addition to auto
tuning we should experiment with it as well.

Eric

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
