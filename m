Date: Mon, 8 May 2000 16:51:44 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: PATCH: Bug in invalidate_inode_pages()?
In-Reply-To: <yttk8h4vcgp.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005081648230.5411-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On 9 May 2000, Juan J. Quintela wrote:
>         I think that I have found a bug in invalidate_inode_pages.
> It results that we don't remove the pages from the
> &inode->i_mapping->pages list, then when we return te do the next loop
> through all the pages, we can try to free a page that we have freed in
> the previous pass.

This is what "remove_inode_page()" does. Maybe that's not quite clear
enough, so this function may certainly need some comments or something
like that, but your patch is wrong (it will now delete the thing twice,
which can and will result in list corruption).

>  Once here I have also removed the goto

Because we dropped the page cache lock, we really have to repeat, because
the lists are now no longer protected..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
