Date: Mon, 6 Aug 2001 11:00:02 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] kill flush_dirty_buffers
In-Reply-To: <663080000.997117789@tiny>
Message-ID: <Pine.LNX.4.33.0108061048240.8972-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <mason@suse.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2001, Chris Mason wrote:
>
> Patch is lightly tested on ext2 and reiserfs, use at your own risk
> for now.  Linus, if this is what you were talking about in the
> vm suckage thread, I'll test/benchmark harder....

This is what I was talking about, but I'd rather have two separate
functions. Right now we have a simple "write_unlocked_buffers()" that is
very straightforward, and I hate having "flags" arguments to functions
that change their behaviour.

In general, the kind of code I like is

	static int generic_helper_fn(...)
	{
	...
	}

	static int another_helper_fn(..)
	{
	...
	}

	static int one_special_case(args)
	{
		if (generic_helper_fn(x) < args)
			another_helper_fn();
	}

	static int another_special_case(void)
	{
		while (another_helper_fn())
			wait_for_results();
	}


Rather than trying to have

	static int both_special_cases(args)
	{
		if (args) {
			if (generic_helper_fn(x) < args)
				another_helper_fn();
		} else {
			while (another_helper_fn())
				wait_for_results();
		}
	}

if you see what I mean?

I know that Computer Science is all about finding the generic solution to
a problem. But the fact is, that the specific solutions are usually
simpler and easier to understand, and if you name your functions
appropriately, it's MUCH easier to understand code that does

	age_page_up_locked(page);

than code that does

	age_page_up(page, 1);

(where "1" is the argument that tells the function that we've already
locked the page).

So I'd rather have a simple and straightforward function called

	write_unlocked_buffers(kdev_t dev)

that just writes all the buffers for that device, and then have _another_
function that does the flushtime checking etc, and is called something
appropriate.

And if they have code that is _unconditionally_ common, then that code can
be made a inline function or something, so that the two functions
themselves are smaller.

The other issue is that I suspect that "flushtime" is completely useless
these days, and should just be dropped. If we've decided to start flushing
stuff out, we shouldn't stop flushing just because some buffer hasn't
quite reached the proper age yet. We'd have been better off maybe deciding
not to even _start_ flushing at all, but once we've started, we might as
well do the dirty buffers we see (up to a maximum that is due to IO
_latency_, not due to "how long since this buffer was dirtied")

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
