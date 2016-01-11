Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:06:15 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 00/13] aio: thread (work queue) based aio and new aio functionality
Message-ID: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Hello all,

First off, sorry for the wide reaching To and Cc, but this patch series
touches the core kernel and also reaches across subsystems a bit.  If
some of the people who read this can provide review feedback, I would
very much appreciate it.

This series introduces new AIO functionality to make use of kernel
threads (by way of queue_work()) to implement additional asynchronous
operations.  The work came about as the result of various tuning done to
the kernel for my employer (Solace Systems) that we ship in our
products.

First off, the benefits: using kernel threads to implement AIO
functionality has a significant benefit in our application.  Compared to
a user space thread pool based AIO implementation, we see roughly a 25%
performance improvement in our application by using this new kernel
based AIO functionality.  This comes about as a consequence of fewer
context switches, fewer transitions to/from userspace, and the ability
to make certain optimizations in the kernel that are otherwise
impossible in userspace (ie the new readahead functionality).

Now the downsides: when using queue_work(), code executes in the context
of a different task that the submitter of the operation.  This means
that there are significant security concerns if there are any bugs in
the code that sets up the appropriate security credentials and related
context in struct task.  There may well be DoS bugs in this
implementation which have yet to be discovered.

Given the benefits, I am of the opinion that this patch series is a
useful addition to the kernel.  Since this code will be experimental for
some period of time as the interactions with other subsystems are
reviewed and tested, I have implemented a config option to allow for
this code to be compiled out and a sysctl (fs.aio-auto-threads) that
must be explicitly set to 1 before this new functionality is available
to userspace.  Hopefully this is enough to address the security concerns
during the growing pains and allow other developers to safely explore
the new functionality.

Caveats: the existing O_DIRECT AIO code path is currently bypassed when
the new thread helpers are enabled.  I plan to do additional work in
this area, but the fact that the dio code can block under certain
conditions is not acceptable to the applications I am working on, as it
leads to starvation of other requests the system is processing.  That
said, this is what's ready today, and I hope that people can provide
feedback to help drive further improvements.

I will be posting further documentation and test cases later this week
for people to experiment with, but for those looking for a few test
programs to exercise the new functionality, there is a collection of
code at git://git.kvack.org/aio-testprogs.git/ .  Getting the code
cleaned up from the internal implementation to something that is in
reasonable condition for submission ended up taking longer than
expected.  Thankfully, this kernel cycle lines up with some internal QA
work, so there should be additional testing taking place over the next
couple of months.

Also, the libaio test harness has some bugs that the new functionality
revealed.  A version with fixes for those tests can be fetched from
git://git.kvack.org/~bcrl/libaio.git/ .  Wrappers for the new IOCB_CMD
types should be posted there by the end of the day.

Some notes on the new functionality: all operations are cancellable
providing the kernel subsystem involved aborts operations when delivered
a SIGKILL.  This ensures that async operations on pipe and sockets are
cancelled when the process that issued the operations exits.  A couple
of the test programs exercise this functionality on pipes.

Signal handling is slightly impacted by this AIO functionality.
Specifically, the first patch in the series introduces a new helper,
io_send_sig() that delivers a signal intended for the performer of an io
operation.  This is used to deliver signals like SIGXFS and SIGPIPE.  It
is a straightforward replacement of send_sig(SIGXXX, current, 0) to
io_send_sig(SIGXXX). 

As always, comments, bug reports and feedback are appreciated.
Developers looking for a git pull can find one at
git://git.kvack.org/aio-next.git/ .  Cheers!

		-ben

Benjamin LaHaise (13):
  signals: distinguish signals sent due to i/o via io_send_sig()
  aio: add aio_get_mm() helper
  aio: for async operations, make the iter argument persistent
  signals: add and use aio_get_task() to direct signals sent via
    io_send_sig()
  fs: make do_loop_readv_writev() non-static
  aio: add queue_work() based threaded aio support
  aio: enabled thread based async fsync
  aio: add support for aio poll via aio thread helper
  aio: add support for async openat()
  aio: add async unlinkat functionality
  mm: enable __do_page_cache_readahead() to include present pages
  aio: add support for aio readahead
  aio: add support for aio renameat operation

 drivers/gpu/drm/drm_lock.c     |   2 +-
 drivers/gpu/drm/ttm/ttm_lock.c |   6 +-
 fs/aio.c                       | 727 ++++++++++++++++++++++++++++++++++++++---
 fs/attr.c                      |   2 +-
 fs/binfmt_flat.c               |   2 +-
 fs/fuse/dev.c                  |   2 +-
 fs/internal.h                  |   6 +
 fs/namei.c                     |   2 +-
 fs/pipe.c                      |   4 +-
 fs/read_write.c                |   5 +-
 fs/splice.c                    |   8 +-
 include/linux/aio.h            |   9 +
 include/linux/fs.h             |   3 +
 include/linux/sched.h          |   6 +
 include/uapi/linux/aio_abi.h   |  15 +-
 init/Kconfig                   |  13 +
 kernel/auditsc.c               |   6 +-
 kernel/signal.c                |  20 ++
 kernel/sysctl.c                |   9 +
 mm/filemap.c                   |   6 +-
 mm/internal.h                  |   4 +-
 mm/readahead.c                 |  13 +-
 net/atm/common.c               |   4 +-
 net/ax25/af_ax25.c             |   2 +-
 net/caif/caif_socket.c         |   2 +-
 net/core/stream.c              |   2 +-
 net/decnet/af_decnet.c         |   2 +-
 net/irda/af_irda.c             |   4 +-
 net/netrom/af_netrom.c         |   2 +-
 net/rose/af_rose.c             |   2 +-
 net/sctp/socket.c              |   2 +-
 net/unix/af_unix.c             |   4 +-
 net/x25/af_x25.c               |   2 +-
 33 files changed, 817 insertions(+), 81 deletions(-)

-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
