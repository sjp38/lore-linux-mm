Date: Thu, 8 Mar 2001 09:17:24 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: nr_async_pages and swapin readahead on -ac series
In-Reply-To: <Pine.LNX.4.21.0103072241130.1268-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0103080916530.1409-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Mar 2001, Marcelo Tosatti wrote:

> On the latest 2.4 -ac series, nr_async_pages is only being used to count
> swap outs, and not for both swap reads and writes (as Linus tree does).
>
> The problem is that nr_async_pages is used to limit swapin readahead based
> on the number of on flight swap pages (mm/memory.c::swapin_readahead):
>
>                 /* Don't block on I/O for read-ahead */
>                 if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster
>                                 * (1 << page_cluster)) {
>                         while (i++ < num)
>                                 swap_free(SWP_ENTRY(SWP_TYPE(entry), offset++));
>                         break;
>                 }
>
>
> So swapin readahead is (theorically) unlimited.

> However, I think a better solution is to ask the block layer if
> there are free requests on the device queue and stop the
> readahead in case there are no free ones. (we don't something
> like that right now, but it can be easily done in the block
> layer)

An even better idea would be to only do swapin readahead if
there is memory available ...

regards,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
