Date: Tue, 28 Mar 2000 20:10:57 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: how text page of executable are shared ?
In-Reply-To: <Pine.LNX.4.10.10003281019140.5753-100000@coffee.psychology.mcmaster.ca>
Message-ID: <Pine.LNX.4.21.0003282006550.1383-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Mar 2000, Mark Hahn wrote:

>in shrink_mmap:
>                /*
>                 * We can't free pages unless there's just one user
>                 * (count == 2 because we added one ourselves above).
>                 */
>                if (page_count(page) != 2)
>                        goto cache_unlock_continue;
>
>is this wrong, since the page cache holds a reference?

That is right. At that point the miniumum count is 2 (there you could
say also:

	if (page_count < 2)
		BUG()

if you want).

1 reference is in the page cache and 1 reference is for the additional
get_page that shrink_mmap does to avoid the page to be freed under it.
Thus if the page count is 2 we can go ahead and release the page. If the
page count is != 2 (that means >2) we can't play with such page since
somebody else is using it.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
