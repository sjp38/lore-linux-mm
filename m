Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: DIrect-IO using kernel buffers
Date: Tue, 17 Oct 2006 10:28:40 +0200
Message-ID: <B9FFC3F97441D04093A504CEA31B7C41E9179C@msilexch01.marvell.com>
From: "Ronen Shitrit" <rshitrit@marvell.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

I'm using kernel 2.6.12.
I'm trying to improve the usb gadget file storage implementation by
making it accessing the file storage with O_DIRECT,
In general what I'm trying to do is use DirectIO with buffer which was
allocated by kmalloc.

When trying to do so I get kernel panic, after some debug, I found that
I can't call get_user_pages on pages allocated by the kernel (kmalloc),
Is it correct??
Any way, I implemented some basic function get_kernel_pages to fill the
page array with the pages pointer of the kernel buffer,
Then I got lots of errors on illegal buffer freeing, I did some more
debug and I found that the direct-io is using the get_page and put_page
in order to increment the counter of the page and to make sure no one
will release them while the direct-io is using them, after the direct-io
is doing put_page it check if the page_count is 0, if so it release it
(see page_cache_release in direct-io.c), by doing this the direct-io is
trying to release the pages which I allocated by kmalloc and I get
errors.
So what I get is that the direct-io increments the count and then
decrements it and the count get to zero,
So I checked the count of the pages which I got from kmalloc and I found
that only the first page count is 0 (i.e. one process is using it) and
the rest were initialized by -1 (i.e. no process is using this buffer),
Is this a bug??
Any suggestion on how to use DirectIO with kernel buffers??

Regards
Ronen Shitrit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
