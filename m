Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA03813
	for <linux-mm@kvack.org>; Mon, 24 Aug 1998 09:08:51 -0400
Date: Mon, 24 Aug 1998 11:36:47 +0100
Message-Id: <199808241036.LAA06879@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: memory use in Linux
In-Reply-To: <3.0.3.32.19980820223733.006b4b5c@valemount.com>
References: <3.0.3.32.19980820223733.006b4b5c@valemount.com>
Sender: owner-linux-mm@kvack.org
To: lonnie@valemount.com
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 20 Aug 1998 22:37:33 -0700, Lonnie Nunweiler
<lonnie@valemount.com> said:

> I am researching why Linux runs into memory problems.  We recently had
> to convert our dialin server, email and web server to NT, because the
> Linux machine would eventually eat up all ram, and then crash.  We
> were using 128MB machines, and it would take about 3 days before
> rebooting was required.  If we didn't reboot soon enough, it was a
> very messy job rebuilding some of the chewed files.

> I have encountered the saying "free memory is wasted memory", and it
> got me thinking.  I believe that statement is completely wrong, and is
> responsible for the current problems that Linux is having for systems
> that keep running (servers) as opposed to systems that get shut down
> nightly.

No --- the statement "free memory is wasted memory" simply implies that
if we have otherwise unused memory available, we should not be afraid to
temporarily use it for cache.  Linux does not keep such memory
indefinitely, but should release it on demand.

Linux does keep a pool of completely free pages available at all times
to cope with short-term memory requirements.  As soon as we start eating
into this, the kernel will preemptively start releasing cache pages.

> From what I have observed, processes will eventually use up all
> available ram, and get into swapping.  

Nasty --- you should find out which process is hogging all of the
memory.  If you have an 80MB process on a 64MB machine, it is simply not
going to be happy.

There _is_ a know problem in that Linux is sometimes too reluctant to
kill a process which runs away with memory, but at that point there is
really no alternative to killing the process anyway: if you have let it
get that far then there is a problem in some application in the system.

> It's silly to have a 64M machine, running only a primary DNS task, and
> having it slowly get its memory chewed up, and then get into swapping.
> When it crashes due to no available memory, what was gained in a few
> milliseconds faster disk access because of caching?

The system will not swap significantly if there is cache to be
reclaimed: the kernel is much more eager to reclaim cache than to swap.

The real question is where is your memory being used?  Simply assuming
it is cache is not necessarily valid.  "ps max" will show the memory
consumption of all processes, and "free" will show the current cache
size (which includes ALL mapped library and program pages, so don't be
worried if it's a few MB in size: that memory is likely to be actively
in use, and reflected in the "shared" size).

For what it's worth, named has a known problem (in all versions, on all
systems) that the DNS server can grow arbitrarily large.  Most sysadmins
I know at large sites restart DNS nightly to cope with this.  The latest
versions may be better, but it's still something to be aware of. 

Finally, what version of the kernel are you running?  There are known
memory leaks in many versions.  In particular, version 2.0.30 had a
fairly bad worst-case-behaviour bug in leaving too large a cache
around.  That bug was present in only one version of the kernel and has
been fixed for over a year, so if you are running 2.0.30, that's almost
certainly part of the problem and you _really_ want to upgrade.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
