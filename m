Date: Mon, 11 Sep 2000 14:51:47 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Page aging for 2.4.0-test8
In-Reply-To: <20000911114520.A22732@keymaster.enme.ucalgary.ca>
Message-ID: <Pine.LNX.4.21.0009111448320.21018-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Sep 2000, Neil Schemenauer wrote:
> On Mon, Sep 11, 2000 at 01:12:32PM -0300, Rik van Riel wrote:
> > Your idea /heavily/ penalises libc and executable pages by aging them
> > more often than anonymous pages...
> 
> I don't think I age anonymous pages any more than any other type
> of page.

Think again.

You're aging them both in try_to_swap_out() /and/ in
shrink_mmap().

> Perhaps you are saying that shared pages should recieve some
> bonus?

No. I'm saying shared pages should have the accessed bits
propagated and be only aged once. I know we can't handle
this right for 2.4, but for 2.5 I hope to use physical-page
based page aging to get this one right...

> That is a different issue and it is handled naturally with my
> patch.  If shared pages are actually used then PageTouch() will
> be called on them more often.

This is /not/ the case. Think of a page from libc, which
is mapped by 30 processes. Now imagine that page is being
heavily used and was used by 5 processes since we scanned
it the last time.

With your patch we'd age the page down 25 (!!) times and
only age it up 5 times. This is clearly not what you want
for a page which was used by 5 different processes since
the last time we scanned it...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
