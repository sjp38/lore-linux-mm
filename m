Received: from mail.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA11939
	for <linux-mm@kvack.org>; Sat, 23 Jan 1999 22:43:55 -0500
Subject: Re: 2.2.0-final
References: <Pine.LNX.3.96.990123210422.2856A-100000@laser.bogus>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 23 Jan 1999 20:57:10 -0600
In-Reply-To: Andrea Arcangeli's message of "Sat, 23 Jan 1999 21:56:20 +0100 (CET)"
Message-ID: <m1pv85fke1.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:

bh-> b_count++ with bget(bh) and implementing bget() this way: 

AA> extern inline unsigned int bget(struct buffer_head * bh)
AA> {
AA>         buffer_get(bh);
AA>         return ++bh->b_count;
AA> }

AA> where buffer_get() is this:

AA> extern inline void buffer_get(struct buffer_head *bh)
AA> {
AA>         struct page * page = mem_map + MAP_NR(bh->b_data);

AA>         switch (atomic_read(&page->count))
AA>         {
AA>         case 1:
AA>                 atomic_inc(&page->count);
AA>                 nr_freeable_pages--;

This is bogus.   Consider the case when you have 4 buffers per page (common with ext2fs)
You will way underestimate the number of freeable pages.

AA>                 break;
AA> #if 1 /* PARANOID */
AA>         case 0:
AA>                 printk(KERN_ERR "buffer_get: page was unused!\n");
AA> #endif
AA>         }
AA> }

AA> And for b_count-- exists a bput().

AA> Taking uptodate the file cache instead is been very easier (some line
AA> changed and nothing more). Lukily the only b_count++ or b_count-- are in
AA> buffer.c and in ext2fs, other fs has one or two b_count only.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
