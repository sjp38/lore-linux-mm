Date: Sat, 6 Jul 2002 20:05:20 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: vm lock contention reduction
In-Reply-To: <3D27AC81.FC72D08F@zip.com.au>
Message-ID: <Pine.LNX.4.44.0207061949240.1558-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
List-ID: <linux-mm.kvack.org>


On Sat, 6 Jul 2002, Andrew Morton wrote:
>
> Martin is being bitten by the global invalidate more than by the lock.
> He increased the size of the kmap pool just to reduce the invalidate
> frequency and saw 40% speedups of some stuff.
>
> Those invalidates don't show up nicely on profiles.

I'd like to enhance the profiling support a bit, to create some
infrastructure for doing different kinds of profiles, not just the current
timer-based one (and not just for the kernel).

There's also the P4 native support for "event buffers" or whatever intel
calls them, that allows profiling at a lower level by interrupting not for
every event, but only when the hw buffer overflows.

I haven't had much time to look at the oprofile thing, but what I _have_
seen has made me rather unhappy (especially the horrid system call
tracking kludges).

I'd rather have some generic hooks (a notion of a "profile buffer" and
events that cause us to have to synchronize with it, like process
switches, mmap/munmap - oprofile wants these too), and some generic helper
routines for profiling (turn any eip into a "dentry + offset" pair
together with ways to tag specific dentries as being "worthy" of
profiling).

Depending on the regular timer interrupt will never give good profiles,
simply because it can't be NMI, but also because you then don't have the
choice of using other counters (cache miss etc).

oprofile does much of this, but in a damn ugly manner.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
