Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id ABBAD38CAE
	for <linux-mm@kvack.org>; Mon, 23 Jul 2001 15:35:28 -0300 (EST)
Date: Mon, 23 Jul 2001 15:35:28 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Swap progress accounting
In-Reply-To: <Pine.LNX.4.33L.0107231425190.20326-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33L.0107231534070.20326-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2001, Rik van Riel wrote:
> On Mon, 23 Jul 2001, Arjan van de Ven wrote:
>
> > Currently, calling swap_out() on a zone doesn't count progress, and the
> > result can be that you swap_out() a lot of pages, and still return "no
> > progress possible" to try_to_free_pages(), which in turn makes a GFP_KERNEL
> > allocation fail (and that can kill init).
>
> "makes GFP_KERNEL allocation fail" ?!?!?!

OK, after talking on IRC it turns out that recursive allocations
are failing.

This isn't influenced by either changing __alloc_pages() or
by changing swap_out(). What we need to do is limit the amount
of recursive allocations going on at the same time, probably
by making the system sleep on IO completion instead of looping
like crazy in __alloc_pages()/page_launder() until we run out
of all our memory ...

regards,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
