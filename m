Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA13660
	for <linux-mm@kvack.org>; Tue, 14 Jul 1998 16:38:29 -0400
Date: Tue, 14 Jul 1998 18:30:19 +0100
Message-Id: <199807141730.SAA07239@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <m190lxmxmv.fsf@flinx.npwt.net>
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 13 Jul 1998 13:08:56 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

>>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:
> 1) We have a minimum size for the buffer cache in percent of physical pages.
>    Setting the minimum to 0% may help.

...

> Personally I think it is broken to set the limits of cache sizes
> (buffer & page) to anthing besides: max=100% min=0% by default.

Yep; I disabled those limits for the benchmarks I announced.  Disabling
the ageing but keeping the limits in place still resulted in a
performance loss.

> 2) If we play with LRU list it may be most practical use page->next
> and page->prev fields for the list, and for truncate_inode_pages &&
> invalidate_inode_pages

Yikes --- for large files the proposal that we do

> do something like:
> for(i = 0; i < inode->i_size; i+= PAGE_SIZE) {
> 	page = find_in_page_cache(inode, i);
> 	if (page) 
> 		/* remove it */
> 		;
> }

will be disasterous.  No, I think we still need the per-inode page
lists.  When we eventually get an fsync() which works through the page
cache, this will become even more important.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
