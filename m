Date: Fri, 22 Sep 2000 18:11:25 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: kernel BUG at page_alloc.c:85 (iounmap)
Message-Id: <20000922230543Z131169-10809+23@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I have a driver which calls marks a physical page as PG_Reserved, calls
ioremap_nocache() on it, performs a non-destructive memory write, and then
calls iounmap().  I have a recurring problem which I can't figure out.  After
28 such map/unmap calls, I get an error in page_alloc.c on line 85.  This is
with 2.4.0-test2.  The offending line is in function __free_pages_ok:

	if (page->buffers)
		BUG();

My guess is that the page I'm trying to map with iounmap() has a non-zero value
of buffers before I map it, but ioremap() doesn't care about that.  But when I
go to iounmap it, then it checks buffers and complains.  

Is this correct?  And if so, what does 'buffers' do?






-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
