Date: Sun, 24 Sep 2000 21:56:47 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu>
Message-ID: <Pine.LNX.4.10.10009242142510.1224-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hmm..

 Thinking some more about this issue, I actually suspect that there's a
better solution.

The fact is that GFP_BUFFER is only used for the old-fashioned buffer
block allocations, and anything that uses the page cache automatically
avoids the whole issue. As such, from a VM balancing standpoint we would
fix the problem equally well by just avoiding using old-fashioned buffer
blocks..

Now, I don't believe that the indirect blocks etc of the meta-data is much
of an issue - whenever we need to access indirect blocks we're certainly
already doing the page cache thing, so the page cache VM pressure should
be qutie sufficient to keep the VM balanced - regular file access is very
much biased towards the page cache, and the meta-data buffer-cache
accesses are likely to be a very very small part of the big picture.

The remaining part if the directory handling. THAT is very buffer-cache
intensive, as the directory handling hasn't been moved over to the page
cache at all for ext2. Doing a large "find" (or even just a "ls -l") will
basically do purely buffer cache accesses, first for the directory data
and then for the inode data. With no page cache activity to balance things
out at all - leading to a potentially quite unbalanced VM that never
really had a good chance to get rid of dentries etc.

However, Al Viro already basically has the "directories using the page
cache" code pretty much done, so for 2.5.x we'll just do that, and I bet
that the VM balancing will improve (as well as performance going up simply
just because the page cache is more efficient anyway). With the directory
information in the page cache, there simply isn't any regular operations
that depend entirely on the buffer cache any more.

Sure, there will still be the inode and indirect blocks, but there just
aren't loads that I know of that can put as much pressure on those as on
the page cache..

So the proper approach may be to just ignore the current issue with
__GFP_IO being a big deal under some loads, because it probably will go
away on its own (the superblock lock contention is still an issue, of
course, but while somewhat related it's still fairly orthogonal). 

Al, if you'd port over the "namei in page-cache" stuff from UFS to ext2, I
bet that there would be people interested in seeing whether the above
theory is just another of Linu's whimsies, or whether it really does make
a difference.. It may not be 2.4.x material, but it won't hurt to have it
tested some more anyway. Comments?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
