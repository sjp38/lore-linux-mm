Received: from localhost (localhost [127.0.0.1])
	by funky.monkey.org (Postfix) with ESMTP id 018AD14A01
	for <linux-mm@kvack.org>; Fri, 21 Jan 2000 15:21:33 -0500 (EST)
Date: Fri, 21 Jan 2000 15:21:33 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: possible brw_page optimization
Message-ID: <Pine.BSO.4.10.10001211508270.26216-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

i've been exploring swap compaction and encryption, and found that
brw_page wants to break pages into buffer-sized pieces in order to
schedule I/O.  the logic wants to eliminate unnecessary I/O requests, so
it checks each buffer to see if it is up to date; it doesn't schedule
reads for buffers that are already up to date.  all buffers are scheduled
unconditionally during a write request.

for compaction or encryption, all buffers must be read in order to get the
whole page and decrypt or decompress it, so i'd like to make
brw_page(READ) read all buffers for a page unconditionally, just like
brw_page(WRITE).  at first, i thought a simple flag could request this
change in behavior.

however, looking at brw_page's callers, brw_page(READ) in 2.3.39+ is only
invoked on fresh pages, so i can't see where it's possible to not read all
the buffers for a page in brw_page.  seems like the following is a
potential common case optimization of brw_page, with no loss of
performance.

what issues am i missing?

int brw_page(int rw, struct page *page, kdev_t dev, int b[], int size)
{
	struct buffer_head *head, *bh, *arr[MAX_BUF_PER_PAGE];
	int block, nr = 0;

	/*
	 * We pretty much rely on the page lock for this, because
	 * create_page_buffers() might sleep.
	 */
	if (!page->buffers)
		create_page_buffers(rw, page, dev, b, size);

	head = page->buffers;
	bh = head;
	do {
		arr[nr++] = bh;
		atomic_inc(&bh->b_count);

		if (rw == WRITE ) {
			block = *(b++);
			if (!bh->b_blocknr)
				bh->b_blocknr = block;

			set_bit(BH_Uptodate, &bh->b_state);
			set_bit(BH_Dirty, &bh->b_state);
		}

		bh = bh->b_this_page;
	} while (bh != head);

	ll_rw_block(rw, nr, arr);
	if (rw == READ)
		++current->maj_flt;

	return 0;
}

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
