Subject: Re: Estrange behaviour of pre9-1
References: <Pine.LNX.4.10.10005160642440.1398-100000@penguin.transmeta.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Tue, 16 May 2000 06:53:22 -0700 (PDT)"
Date: 16 May 2000 16:20:02 +0200
Message-ID: <yttitwey3u5.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

linus> Remember, we walk the LRU list from the "old" end, and whenever we hita
linus> dirty buffer we will write it out asynchronously. AND WE WILL MOVE IT TO
linus> THE TOP OF THE LRU QUEUE!

linus> Which means that we will only see actual locked buffers if we have gotten
linus> through the whole LRU queue without giving our write-outs time to
linus> complete: which is exactly the situation where we do want to wait for
linus> them.

Linus, I think that we want to wait for a buffer if we have start the
write of a lot of them, i.e., If the last pass of shrink_mmap has
found a lot of dirty buffers (put here a magic number, 100, 1000, one
percentage of the count parameter...), then we want to wait for some
of that buffers to be write, before continue starting more writings.
I have done that change here and it appears to be working at least as
good as the actual vanilla kernel, and with a bit of tuning I think
that I can make it work better,  I will try to send a patch later
today.  I have achieved now to be able to reduce the cache, when we
are low on memory, we begin to shrink the cache at the same time that
we begin to swap.  With my patch I shrink it *too* aggressively, I need
to tune that a bit.

linus> So normally, we will write out a ton of buffers, and then wait for the
linus> oldest one. You're obviously right that we may end up waiting for more
linus> than one buffer, but when that happens it will be the right thing to do:
linus> whenever we're waiting for the oldest buffer to flush, the others are also
linus> likely to have flushed (remember - we started them pretty much at the same
linus> time because we've tried hard to delay the 'run_task(&tq_disk)' too).

That thing is write if we have *some* dirty pages, but if *almost* all
the pages are *dirty* we don't want that, because in that round when
we start the writes of the page cache, we will cause all the clean
pages of the innocent programs (bash, less, daemons, ....) to be
freed, and we do that too fast to let the programs to soft fault that
pages.

linus> Well, right now we cannot avoid doing that. The reason is simply that the
linus> current MM layerdoes not know how many pages are dirty. THAT is a problem,
linus> but it's not a problem we're going to solve for 2.4.x. 

If my patch work it will solve some of that problems.  If I have some
success I will let you know.

Later, Juan.




-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
