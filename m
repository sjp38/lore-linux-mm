Date: Fri, 10 Sep 1999 19:35:18 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Asynchronous I/O
In-Reply-To: <E11P7JJ-0005Fd-00@heaton.cl.cam.ac.uk>
Message-ID: <Pine.LNX.4.10.9909101924330.16780-100000@laser.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Hand <Steven.Hand@cl.cam.ac.uk>
Cc: linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Sep 1999, Steven Hand wrote:

>   b) should it work? 

Your plain suggestion is not ok becaue you end freeing the page two times,
one in filemap_write_page and one in kpiod so you'll also remove the page
from the page cache if you avoided MS_INVALIDED and you'll corrupt memory
with MS_INVALIDATE. So you should do something like:

	error = filemap_write_page(vma, address - vma->vm_start + 
		vma->vm_offset, page, !(flags & MS_ASYNC));
	if (!(flags & MS_ASYNC))
		page_cache_free(page);

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
