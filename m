Message-ID: <3D479F21.F08C406C@zip.com.au>
Date: Wed, 31 Jul 2002 01:26:09 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: throttling dirtiers
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Here's an interesting test.

- mem=512m
- Run a program which mallocs 400 megs and then madly sits
  there touching each page.
- Do a big `dd' to a file.

Everything works nicely - all the anon memory sits on the active
list, all writeback is via shrink_cache -> vm_writeback.
Bandwidth is good.

But as we discussed, we really shouldn't be doing the IO from
within the VM.  balance_dirty_pages() is never triggering
because the system is not reaching 40% dirty.

It would make sense for the VM to detect an overload
of dirty pages coming off the tail of the LRU and to reach
over and tell balance_dirty_pages() to provide throttling,

If we were to say "gee, of the last 1,000 pages, 25% were
dirty, so tell balance_dirty_pages() to throttle everyone"
then that would be too late because the LRU will be _full_
of dirty pages.

I can't think of a sane way of keeping track of the number
of dirty pages on the inactive list, because the locking
is quite disjoint.

But we can certainly track the amount of anon memory in
the machine, and set the balance_dirty_pages thresholds
at 0.4 * (total memory - anon memory) or something like
that.

Thoughts?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
