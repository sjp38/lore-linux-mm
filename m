Date: Fri, 29 Sep 2000 16:55:11 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000929165511.C32079@athlon.random>
References: <20000928165216.J17518@athlon.random> <Pine.LNX.4.21.0009291138080.23266-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009291138080.23266-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Fri, Sep 29, 2000 at 11:39:18AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 29, 2000 at 11:39:18AM -0300, Rik van Riel wrote:
> OK, good to see that we agree on the fact that we
> should age and swapout all pages equally agressively.

Actually I think we should start looking at the mapped stuff _only_ when the
I/O cache aging is relevant. If the I/O cache aging isn't relevant there's no
point to look at the mapped stuff since there's cache pollution going on. It's
much less costly to drop a page from the unmapped cache than to play with
pagetables, and also having slow read() is much better than having to fault
into the .text areas (because the process is going to be designed in a way that
expects read to block so it may do it asynchronously or in a separate thread or
whatever). A `cp /dev/zero .` shouldn't swapout/unmap anything.

If the cache is re-used (so if it's useful) that's completly different issue and
in that case unmapping potentially unused stuff is the right thing to do of
course.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
