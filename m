Date: Thu, 4 May 2000 12:38:31 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <Pine.LNX.4.21.0005041702560.2512-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0005041234490.23740-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Andrea Arcangeli wrote:

> --- 2.2.15/mm/filemap.c	Thu May  4 13:00:40 2000
> +++ /tmp/filemap.c	Thu May  4 17:11:18 2000
> @@ -68,7 +68,7 @@
>  
>  	p = &inode->i_pages;
>  	while ((page = *p) != NULL) {
> -		if (PageLocked(page)) {
> +		if (PageLocked(page) || atomic_read(&page->count) > 1) {
>  			p = &page->next;
>  			continue;
>  		}

Fun, fun, fun ...

So the other CPU takes a lock on the page while we're testing
for the page->count and increments the pagecount after the lock,
while we try to do something (call __free_page(page)?) with the
page ...

As long as the other cpu increments the page count quick enough
it should be ok, but when it doesn't we can *still* end up freeing
a locked page.  I've seen backtraces where __free_pages_ok()
Oopsed on PageLocked(page) and the function was called from
truncate_inode_pages().

The fix which is in the latest kernel from Linus fixed the bug for
those people. Stubbornly reversing the fix because you haven't
managed to reproduce it yet is most probably not the right thing
to do.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
