Date: Mon, 10 Apr 2000 20:10:21 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
Message-ID: <20000410201021.V17648@redhat.com>
References: <Pine.LNX.4.21.0004080305490.2459-100000@alpha.random> <200004082147.OAA75650@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200004082147.OAA75650@google.engr.sgi.com>; from kanoj@google.engr.sgi.com on Sat, Apr 08, 2000 at 02:47:29PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Apr 08, 2000 at 02:47:29PM -0700, Kanoj Sarcar wrote:
> 
> You have answered your own question in a later email. I quote you:
> "Are you using read_swap_cache from any
> swapin event? The problem is swapin can't use read_swap_cache because with
> read_swap_cache we would never know if we're doing I/O on an inactive swap
> entry"

Right.  The way the swap synchronisation always worked was that
we must have a swap cache entry before _any_ IO, so the page lock 
bit on that swap cache page could also serve as an IO lock on the
swap entry.  (Actually, it didn't _always_ work that way, but that's
the basic mechanism with the current swap cache.)

That relied on the swapper being able to do an atomic operation to
search for a page cache page, and to create a new page and lock it
if it wasn't already there.  That was made atomic only by use of the
big lock.  If you don't have all page cache activity using that lock,
then yes, you'll need the page cache lock while you set all of this 
up.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
