Received: from ip03.eastlink.ca ([24.222.39.36])
 by mta01.eastlink.ca (Sun Java System Messaging Server 6.2-4.03 (built Sep 22
 2005)) with ESMTP id <0K8W00K3DS4MMIP0@mta01.eastlink.ca> for
 linux-mm@kvack.org; Fri, 17 Oct 2008 21:31:34 -0300 (ADT)
Date: Fri, 17 Oct 2008 21:31:17 -0300
From: Peter Cordes <peter@cordes.ca>
Subject: Re: no way to swapoff a deleted swap file?
In-reply-to: <Pine.LNX.4.64.0810171250410.22374@blonde.site>
Message-id: <20081018003117.GC26067@cordes.ca>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Content-disposition: inline
References: <bnlDw-5vQ-7@gated-at.bofh.it> <bnwpg-2EA-17@gated-at.bofh.it>
 <bnJFK-3bu-7@gated-at.bofh.it> <bnR0A-4kq-1@gated-at.bofh.it>
 <E1KqkZK-0001HO-WF@be1.7eggert.dyndns.org>
 <Pine.LNX.4.64.0810171250410.22374@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Bodo Eggert <7eggert@gmx.de>, David Newall <davidn@davidnewall.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 17, 2008 at 01:17:17PM +0100, Hugh Dickins wrote:
> On Fri, 17 Oct 2008, Bodo Eggert wrote:
> > 
> > Somebody might want their swapfiles to have zero links,
> > _and_ the possibility of doing swapoff.
> 
> You're right, they might, and it's not an unreasonable wish.
> But we've not supported it in the past, and I still don't
> think it's worth adding special kernel support for it now.

 I'd be inclined to agree with not bloating the kernel to support
this, even though it would have been convenient for me in one case.  I
do have an idea for supporting this without bloat, see below.  In case
anyone wants more details about how I painted myself into that corner,
here's the backstory to my feature request.

 I was cleaning out /var/tmp until I had it down to everything I
wanted to keep.  Then I was going to rsync it to somewhere else,
umount, mkfs (with a newer mkfs.xfs -l version=2,lazy-count=1 -n
version=2, etc...), and copy my files back.  I think I forgot to
/etc/init.d/swapspace stop before rm -r on my swapfile directory.

 I run swapspace(8), http://pqxx.org/development/swapspace
http://packages.debian.org/sid/swapspace.  I have a ~700MB swap
partition that will actually get used most of the time, and let
swapspace(8) make swap files in /var/cache/swapspace.  (I symlink or
bind mount /var/cache so it's actually on /var/tmp, since it seems to
fit better there.)

 Usually dynamic swap file creation just delays the inevitable OOM and
makes thrashing worse. (because one can't create swap files without
writing them full of zeros, not even with xfs_io resvsp, except with
old XFS without unwritten extent tracking.  But that's another feature
request...) In the rare case where you're running a few bloated things
and want to let them swap out while doing something unusual that takes
almost all your RAM, it's fairly convenient.  Basically I like the
idea, even if in practice it's clunky and would be better to just use
some big swap files I could delete if I need the disk space.  It works
well when your swap isn't filling up as fast as your disk can write.

> > If you can do it by keeping some fds open to let
> > /proc/pid/fd point to the files, I think it's OK.
> 
> I've a very strong aversion to adding strange code to abuse the
> /proc/<pid>/fd space of some random kernel thread - a "kswapd"
> because its name contains the substring "swap"?

 Yes, because it has swap in the name :P.  I was just guessing it had
something to do with swap areas.

 Here's another idea: swapoff(2) takes a text string.  It could be
overloaded to parse the string as a numeric index into the list of
swap areas (as listed in /proc/swaps).  It could do this as a fallback
iff the string was numeric and didn't exist as a pathname relative to
the CWD.  (You don't want "/nonexistant/file" to be treated the same as
"0" of course, or you'd always be swapoff()ing the first swap file
instead of returning ENOENT.)

Before rebooting I tried 
# swapoff "/var/tmp/EXP/cache/swap/1 (deleted)"
Then I looked at the source to see that that sys_swapoff only tries
to use the string as a path in the filesystem.  But that doesn't have
to be the case, if there's enough information in data structures
associated with a swap area to get whatever swapoff() needs to let go
of the file.

 This would just add some kernel code that wouldn't usually be in the
CPU icache, and wouldn't allocate any extra objects like file
descriptors or VFS entries to lie around to support this.

 It's a little ugly, though, to change a system call that normally
accepts only paths to accept things that aren't paths.  It would be
even worse to use swapoff("/sys/swaps/2") if /sys/swaps didn't exist
in the VFS, and was parsed specially by sys_swapoff().  So don't do
that. :)   swapoff("0") doesn't seem too bad, if only by comparison
with something horrible.

-- 
#define X(x,y) x##y
Peter Cordes ;  e-mail: X(peter@cor , des.ca)

"The gods confound the man who first found out how to distinguish the hours!
 Confound him, too, who in this place set up a sundial, to cut and hack
 my day so wretchedly into small pieces!" -- Plautus, 200 BC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
