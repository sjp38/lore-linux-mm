Date: Sun, 14 May 2000 02:48:58 -0700 (MST)
From: Craig Kulesa <ckulesa@loke.as.arizona.edu>
Subject: Summary of recent VM behavior [2.3.99-pre8]
Message-ID: <Pine.LNX.4.21.0005140101390.4107-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


Greetings...

Below are a summary of issues that I've encountered in the pre7 and pre8
kernels (at least on mid-range hardware).  I'd appreciate comments, any
enlightening information or pointers to documentation so I can answer the
questions myself. :) Also consider me a guinea pig for patches... 


1)  Unnecessary OOM situations, killing of processes
    (pathological)

Example:  On a 64 MB box, dd'ing >64 MB from /dev/zero to a file
on disk runs the kernel aground, usually killing a large RSS process 
like X11. This has been a consistent problem since pre6(-7?). This
behavior seems quite broken.  

I assume this is in the mmap code.  Cache increases as the file is written
but when the limit of physical memory is reached, problems ensue.  The CPU
is consumed ("hijacked") by kswapd or other internal kernel operations; as
though mmap'ed allocations can't be shrunk effectively (or quickly).

Not a problem w/ classzone.


2)  What's in the cache anyways?
    (puzzling)

Example: Play mp3's on an otherwise unloaded 64 MB system until cache
fills the rest of physical RAM. Then open an xterm (or GNU emacs,
or...).  After less than 10 MB of mp3 data goes goes by, close the
xterm. Open a new one. The xterm code is not in cache but is loaded from
scratch from disk, with a flurry of disk I/O (but no swapped pages). 
Why? The cache allocation is almost 50 MB -- *why* isn't it in there
somewhere?

One might imagine that the previous mp3's are solidly in cache, but
loading an mp3 only 15 MB earlier in the queue... comes from disk and not
from cache!  Why?

Another example on a 40 MB system: Open a lightweight X11/WindowMaker
session. Open Netscape 4.72 (Navigator). Close it. Log out. Login again,
load Netscape. Both X, window manager, and Netscape seem to come
straight from disk, with no swapped pages.  But the buffer cache is 
25 MB!  What's in there if the applications aren't? 

This is also seen on a 32 MB system by simply opening Navigator, closing
it, and opening it again. In kernel 2.2.xx and 2.3.99-pre5 (or with
classzone), it comes quickly out of cache.  In pre8, there's substantial
disk I/O, and about half of the pages are read from disk and not the
cache.  (??)

Before pre6 and with AA's classzone patch, a 25 MB cache seemed to contain
the "last" 25 MB of mmap'd files or I/O buffers. This doesn't seem true
anymore (?!), and it's an impediment to performance on at least
lower-end hardware.


3) Slow I/O performance

Disk access seems to incur large CPU overhead once physical memory must be
shared between "application" memory and cache.  kswapd is invoked
excessively, applications that stream data from disk hesitate, even the
mouse pointer becomes jumpy. The system load is ~50% higher in heavy disk
access than in earlier 2.2 and 2.3 kernels. 

Untarring the kernel source is a good example of this. Even a 128 MB
system doesn't do this smoothly in pre8. 

The overall memory usage in pre6 and later seems good -- there is no
gratuitous swapping as seen in pre5 (and earlier in pre2-3 etc). But the
general impression is that in the mmap code (somewhere else?), there are a
LOT of pages moved around or scanned that incurs expensive system
overhead. 

Before an "improved" means of handling vm pages (like the active/inactive
lists that Rik is working on), surely the current code in vmscan and
filemap (etc) should be shown to be fast and not conducive to this
puzzling, even pathological, behavior?  


4)  Confusion about inode_cache and dentry_cache

I'm surely confused here, but in kernel 2.3 the inode_cache and
dentry_cache are not as limited as in kernel 2.2.  Thusly,
sample applications like Redhat's 'slocate' daemon or any global use of
the "find" command will cause these slab caches to fill quickly. These
caches are effectively released under memory pressure. No problem.

But why do these "caches" show up as "used app memory" and not cache in
common tools like 'free' (or /proc/meminfo)?  This looks like a recipe for
lots of confused souls once kernel 2.4 is adopted by major distributions. 

Thoughts?


Craig Kulesa
Steward Observatory, Tucson AZ
ckulesa@as.arizona.edu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
