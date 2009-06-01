Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A6D646B007E
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:12:05 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 01 Jun 2009 14:45:17 -0700
In-Reply-To: <m1skkf761y.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sat\, 11 Apr 2009 05\:01\:29 -0700")
Message-ID: <m1oct739xu.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [PATCH 0/23] File descriptor hot-unplug support v2
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>


I found myself looking at the uio, seeing that it does not support pci
hot-unplug, and thinking "Great yet another implementation of
hotunplug logic that needs to be added".

I decided to see what it would take to add a generic implementation of
the code we have for supporting hot unplugging devices in sysfs, proc,
sysctl, tty_io, and now almost in the tun driver.

Not long after I touched the tun driver and made it safe to delete the
network device while still holding it's file descriptor open I someone
else touch the code adding a different feature and my careful work
went up in flames.  Which brought home another point at the best of it
this is ultimately complex tricky code that subsystems should not need
to worry about.

What makes this even more interesting is that in the presence of pci
hot-unplug it looks like most subsystems and most devices will have to
deal with the issue one way or another.

This infrastructure could also be used to implement both force
unmounts and sys_revoke.  When I could not think of a better name for
I have drawn on that and used revoke.

The following changes draw on and generalize the work in tty_io sysfs,
proc, and sysctl and move it into the vfs level.  Where the basic
primitives are running faster, and the solution is more general.


... Changes since version 1.

All of that lead to the first version of this patchset.  The feedback
I got from that was generally positive but there was a concern about
performance  when two there are two simultaneous accessors to the tty
at the same time.

After looking into the performance concerns of what happens when
multiple programs access the same struct file and finding that I could
not rule out a performance regression I have gone back and redesigned
my mutual exclusion primitive creating something simpler and faster.

I have also changed my synchronization primitives extending them to
protect most of what is read-only in struct file today and abandoning
rcu-ness of struct file.

Giving up rcu-ness leads to true exclusion and makes the code much
easier to think about.

In this patchset is the basic code patchs 1-4 and a conversion of
the vfs except for the nfsd entry points.  Enough for a reasonable
result. 

These patches are based on Al's vfs/for-next tree.

The vfs changes in this patchset.

 Documentation/filesystems/vfs.txt |    5 +
 drivers/char/pty.c                |    2 +-
 drivers/char/tty_io.c             |   22 ++--
 fs/Kconfig                        |    4 +
 fs/aio.c                          |   51 +++++--
 fs/compat.c                       |   16 ++-
 fs/compat_ioctl.c                 |   14 ++-
 fs/eventpoll.c                    |   41 +++++-
 fs/fcntl.c                        |   28 +++--
 fs/file_table.c                   |  281 +++++++++++++++++++++++++++++--------
 fs/inode.c                        |    1 +
 fs/ioctl.c                        |    8 +-
 fs/locks.c                        |    8 +-
 fs/namei.c                        |   11 ++-
 fs/open.c                         |   81 +++++++++--
 fs/proc/base.c                    |   29 ++--
 fs/read_write.c                   |  122 ++++++++++++----
 fs/readdir.c                      |   20 ++-
 fs/select.c                       |   53 ++++++-
 fs/splice.c                       |  111 ++++++++++-----
 fs/super.c                        |    1 -
 fs/sync.c                         |    9 +-
 include/linux/fs.h                |   49 ++++++-
 include/linux/mm.h                |    2 +
 include/linux/poll.h              |    3 +
 include/linux/sched.h             |    7 +
 include/linux/tty.h               |    2 +-
 mm/fadvise.c                      |    7 +
 mm/filemap.c                      |   25 ++--
 mm/memory.c                       |   98 +++++++++++++
 mm/mmap.c                         |   78 +++++++----
 mm/nommu.c                        |   21 +++-
 security/selinux/hooks.c          |    8 +-
 33 files changed, 950 insertions(+), 268 deletions(-)

The necessary changes to proc to take advantage of this functionality.

 fs/proc/Kconfig         |    1 +
 fs/proc/generic.c       |   56 +++-----
 fs/proc/inode.c         |  354 ++++-------------------------------------------
 fs/proc/internal.h      |    1 +
 include/linux/proc_fs.h |    4 -
 5 files changed, 44 insertions(+), 372 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
