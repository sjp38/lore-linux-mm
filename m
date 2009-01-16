Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 830276B004F
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 15:07:21 -0500 (EST)
Received: from acsinet13.oracle.com (acsinet13.oracle.com [141.146.126.235])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n0GK6jkW008335
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 20:06:46 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by acsinet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n0GK7uT1031125
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 20:07:58 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Page lock stack trace instrumentation
Date: Fri, 16 Jan 2009 15:06:58 -0500
Message-ID: <20090116193424.23026.45385.stgit@ingres.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: chuck.lever@oracle.com
List-ID: <linux-mm.kvack.org>

The following patches implement a mechanism for capturing the stack
backtrace of processes that lock and unlock pages.  This
instrumentation was used to track down an application hang that
occurred when a ^C was used to kill a multi-threaded application
(often referred to euphemistically as a "well-known commercial OLTP
database") running on top of NFS.

The patches are somewhat specific to the particular problem we
were chasing, so first, a little background:

Using sysRq-T, our hang was tracked down to a process waiting in
invalidate_inode_pages2_range() for a page to be unlocked.  The
process was holding the i_mutex on a particular file, and a set of
other processes were waiting for the same i_mutex.

The process waiting for the page was never awoken in this case, though
the page flags for that page showed that it was in fact not locked.
Since this process never awoke, it never released the i_mutex, thus
all of the other processes were waiting forever for the mutex.

This problem appeared only in SMP configurations, and only after
Matthew Wilcox's work to use lock_page_killable() to eliminate the
need for the "intr" and "nointr" NFS mount options.

To pursue this further, I created some instrumentation, suggested by
Chris Mason, to identify the processes and functions that had last
touched the problematic page.  A queue of pages waiting in
invalidate_inode_pages2_range() quickly identifies which page or pages
we are stuck on.

The first patch is what our test team was using when Chris discovered
the problem.  It evolved over several months of testing.

The second patch is some clean-up that I had planned for the next
iteration of this patch, before the fix was discovered.  It was never
tested, and is included for completeness.

These patches are against 2.6.27 stable, and are posted here for the
record, at Chris's request.

---

Chuck Lever (2):
      PAGECACHE: Page lock tracing clean up
      PAGECACHE: Record stack backtrace in lock_page()


 drivers/char/sysrq.c     |    4 +
 include/linux/mm_types.h |   21 +++++++
 include/linux/pagemap.h  |   21 +++++++
 include/linux/wait.h     |    2 +
 kernel/sched.c           |   24 ++++++++
 kernel/wait.c            |    9 +++
 mm/filemap.c             |  130 ++++++++++++++++++++++++++++++++++++++++++++--
 mm/hugetlb.c             |    1 
 mm/page_alloc.c          |    4 +
 mm/slub.c                |    5 ++
 mm/truncate.c            |   64 ++++++++++++++++++++++-
 11 files changed, 277 insertions(+), 8 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
