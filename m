Message-ID: <3A705802.5C4DD2F2@augan.com>
Date: Thu, 25 Jan 2001 17:44:51 +0100
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: Re: ioremap_nocache problem?
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org>
		<20010123165117Z131182-221+34@kanga.kvack.org> ; from ttabi@interactivesi.com on Tue, Jan 23, 2001 at 10:53:51AM -0600 <20010125155345Z131181-221+38@kanga.kvack.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

Timur Tabi wrote:

> I mark the page as reserved when I ioremap() it.  However, if I leave it marked
> reserved, then iounmap() will not unmap it.  If I mark it "unreserved" (i.e.
> reset the reserved bit), then iounmap will unmap it, but it will decrement the
> page counter to -1 and the whole system will crash soon thereafter.
> 
> I've been asking about this problem for months, but no one has bothered to help
> me out.

The order is important:

	get_free_page();
	set_bit(PG_reserved, &page->flags);
	ioremap();
	...
	iounmap();
	clear_bit(PG_reserved, &page->flags);
	free_page();

Alternatively something like this should also be possible:

	get_free_page();
	ioremap();
	...
	iounmap();

nopage() {
	...
	atomic_inc(&page->count);
	return page;
}

But I never tried this version, so I can't guarantee anything. :)

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
