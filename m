Date: Sun, 24 Sep 2000 22:38:14 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: __GFP_IO && shrink_[d|i]cache_memory()?
Message-ID: <20000924223814.B2615@redhat.com>
References: <Pine.LNX.4.10.10009241101320.10311-100000@penguin.transmeta.com> <Pine.LNX.4.21.0009242038480.7843-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009242038480.7843-100000@elte.hu>; from mingo@elte.hu on Sun, Sep 24, 2000 at 08:40:05PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Sep 24, 2000 at 08:40:05PM +0200, Ingo Molnar wrote:
> On Sun, 24 Sep 2000, Linus Torvalds wrote:
> 
> > [...] I don't think shrinking the inode cache is actually illegal when
> > GPF_IO isn't set. In fact, it's probably only the buffer cache itself
> > that has to avoid recursion - the other stuff doesn't actually do any
> > IO.
> 
> i just found this out by example, i'm running the shrink_[i|d]cache stuff
> even if __GFP_IO is not set, and no problems so far. (and much better
> balancing behavior)

Careful --- I found out to my cost that there are hidden recursions
here.  ext3 was bitten once by the fact that shrink_icache does a
quota drop, and that involves quota writeback if it was the last inode
on that particular quota struct.

shrinking the icache _usually_ involves no IO, but the quota case is
an exception which a lot of developers won't encounter during testing.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
