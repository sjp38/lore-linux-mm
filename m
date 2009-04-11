Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 448385F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 08:01:42 -0400 (EDT)
Subject: [RFC][PATCH 0/9] File descriptor hot-unplug support
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 11 Apr 2009 05:01:29 -0700
Message-ID: <m1skkf761y.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>


A couple of weeks ago I found myself looking at the uio, seeing that
it does not support pci hot-unplug, and thinking "Great yet another
implementation of hotunplug logic that needs to be added".

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

This infrastructure could also be used to implement sys_revoke and
when I could not think of a better name I have drawn on that.

The following changes draw on and generalize the work in tty_io sysfs,
proc, and sysctl and move it into the vfs level.  Where the basic
primitives are running faster, and the solution more general.

The work is not complete.  I have only fully converted proc.  And
there are more places in the vfs that need to be touched.  But it is
close enough the code works in practice and all of the core challenges
should have been solved, and the design should be clear.

 Documentation/filesystems/vfs.txt |    4 +
 drivers/char/pty.c                |    2 +-
 drivers/char/tty_io.c             |    2 +-
 fs/Makefile                       |    2 +-
 fs/compat.c                       |   31 +++-
 fs/fcntl.c                        |   32 +++--
 fs/file_table.c                   |  189 ++++++++++++++++++---
 fs/inode.c                        |    1 +
 fs/ioctl.c                        |   39 +++--
 fs/locks.c                        |   81 +++++++--
 fs/open.c                         |   32 +++-
 fs/proc/generic.c                 |  100 ++++--------
 fs/proc/inode.c                   |  339 +------------------------------------
 fs/proc/internal.h                |    2 +
 fs/proc/root.c                    |    2 +-
 fs/read_write.c                   |  143 ++++++++++++----
 fs/readdir.c                      |   14 ++-
 fs/revoked_file.c                 |  181 ++++++++++++++++++++
 fs/select.c                       |   17 ++-
 fs/super.c                        |   49 +++---
 fs/sysfs/bin.c                    |  193 +---------------------
 include/linux/fs.h                |   31 +++-
 include/linux/mm.h                |    3 +
 include/linux/proc_fs.h           |    4 -
 mm/memory.c                       |   96 +++++++++++
 25 files changed, 841 insertions(+), 748 deletions(-)

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
