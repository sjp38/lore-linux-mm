Date: Wed, 31 Jul 2002 13:06:12 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: throttling dirtiers
Message-ID: <20020731200612.GJ29537@holomorphy.com>
References: <3D479F21.F08C406C@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D479F21.F08C406C@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2002 at 01:26:09AM -0700, Andrew Morton wrote:
> Here's an interesting test.
> - mem=512m
> - Run a program which mallocs 400 megs and then madly sits
>   there touching each page.
> - Do a big `dd' to a file.
> Everything works nicely - all the anon memory sits on the active
> list, all writeback is via shrink_cache -> vm_writeback.
> Bandwidth is good.

The VM has to do some because pages can be dirtied by mmap()'d access.
Only scanning for modified bits or trapping write access (ugh) can find
these pages.


On Wed, Jul 31, 2002 at 01:26:09AM -0700, Andrew Morton wrote:
> But as we discussed, we really shouldn't be doing the IO from
> within the VM.  balance_dirty_pages() is never triggering
> because the system is not reaching 40% dirty.
> It would make sense for the VM to detect an overload
> of dirty pages coming off the tail of the LRU and to reach
> over and tell balance_dirty_pages() to provide throttling,
> If we were to say "gee, of the last 1,000 pages, 25% were
> dirty, so tell balance_dirty_pages() to throttle everyone"
> then that would be too late because the LRU will be _full_
> of dirty pages.

balance_dirty_pages() is the closest thing to source throttling
available, so it should definitely be used before VM background
writeback. Perhaps assigning dirty page budgets to tasks and/or
struct address_space and checking for budget excess would be good?
Trouble is I'm not sure exactly how well they can be enforced
given the mmap() problem.


On Wed, Jul 31, 2002 at 01:26:09AM -0700, Andrew Morton wrote:
> I can't think of a sane way of keeping track of the number
> of dirty pages on the inactive list, because the locking
> is quite disjoint.
> But we can certainly track the amount of anon memory in
> the machine, and set the balance_dirty_pages thresholds
> at 0.4 * (total memory - anon memory) or something like
> that.
> Thoughts?

I'm not a fan of this kind of global decision. For example, I/O devices
may be fast enough and memory small enough to dump all memory in < 1s,
in which case dirtying most or all of memory is okay from a latency
standpoint, or it may take hours to finish dumping out 40% of memory,
in which case it should be far more eager about writeback.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
