Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k4B1l8qh008578 for <linux-mm@kvack.org>; Thu, 11 May 2006 10:47:08 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k4B1l6Xh010246 for <linux-mm@kvack.org>; Thu, 11 May 2006 10:47:06 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp (s6 [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E0AA9398104
	for <linux-mm@kvack.org>; Thu, 11 May 2006 10:47:05 +0900 (JST)
Received: from fjm505.ms.jp.fujitsu.com (fjm505.ms.jp.fujitsu.com [10.56.99.83])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0775939810A
	for <linux-mm@kvack.org>; Thu, 11 May 2006 10:47:05 +0900 (JST)
Received: from fjmscan502.ms.jp.fujitsu.com (fjmscan502.ms.jp.fujitsu.com [10.56.99.142])by fjm505.ms.jp.fujitsu.com with ESMTP id k4B1kSvh005242
	for <linux-mm@kvack.org>; Thu, 11 May 2006 10:46:28 +0900
Received: from unknown ([10.124.100.187])
	by fjmscan502.ms.jp.fujitsu.com (8.13.1/8.12.11) with SMTP id k4B1kPhq004057
	for <linux-mm@kvack.org>; Thu, 11 May 2006 10:46:28 +0900
Date: Thu, 11 May 2006 10:49:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Question: what happens if writeing back to swap ends in error
Message-Id: <20060511104901.572522a9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

What happens when I/O request from swap_writeback() ends in I/O Error ?

swap_writepage() (in mm/page_io.c) sets bio->bi_end_io as end_swap_bio_write().
After I/O ends, bio_endio()->end_swap_bio_write() is called, I think.

If that writeback was end in error, bio-bi_flags's BIO_UPTODATE is cleared.
Then, page is marked with PG_error.
==
static int end_swap_bio_write(struct bio *bio, unsigned int bytes_done, int err)
{
        const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
        struct page *page = bio->bi_io_vec[0].bv_page;

        if (bio->bi_size)
                return 1;

        if (!uptodate)
                SetPageError(page);
        end_page_writeback(page);
        bio_put(bio);
        return 0;
}
==
But here, PG_writeback is cleared, anyway.

Now, shrink_list() doesn't handle PG_error.
If the page is not accessed, page's state is !PageDirty() && !PageWriteback()
and SwapCache and on LRU.
Finally, page marked with PG_error is freed by shrink_list() and data in the
page will be lost.

correct ?

-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
