Date: Tue, 5 Jun 2001 09:38:08 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: Comment on patch to remove nr_async_pages limit
In-Reply-To: <Pine.LNX.4.21.0106042142550.2521-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0106050820540.867-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jun 2001, Marcelo Tosatti wrote:

> Zlatko,
>
> I've read your patch to remove nr_async_pages limit while reading an
> archive on the web. (I have to figure out why lkml is not being delivered
> correctly to me...)
>
> Quoting your message:
>
> "That artificial limit hurts both swap out and swap in path as it
> introduces synchronization points (and/or weakens swapin readahead),
> which I think are not necessary."
>
> If we are under low memory, we cannot simply writeout a whole bunch of
> swap data. Remember the writeout operations will potentially allocate
> buffer_head's for the swapcache pages before doing real IO, which takes
> _more memory_: OOM deadlock.

What's the point of creating swapcache pages, and then avoiding doing
the IO until it becomes _dangerous_ to do so?  That's what we're doing
right now.  This is a problem because we guarantee it will become one.
We guarantee that the pagecache will become almost pure swapcache by
delaying the writeout so long that everything else is consumed.

In experiments, speeding swapcache pages on their way helps.  Special
handling (swapcache bean counting) also helps. (was _really ugly_ code..
putting them on a seperate list would be a lot easier on the stomach:)

	$.02

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
