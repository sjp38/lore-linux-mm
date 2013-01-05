Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 618EE6B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 21:26:10 -0500 (EST)
Received: by mail-da0-f47.google.com with SMTP id s35so7741744dak.34
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 18:26:09 -0800 (PST)
From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v7 0/6] solve deadlock caused by memory allocation with I/O
Date: Sat,  5 Jan 2013 10:25:38 +0800
Message-Id: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>

Hi,

This patchset try to solve one deadlock problem which might be caused
by memory allocation with block I/O during runtime PM and block device
error handling path. Traditionly, the problem is addressed by passing
GFP_NOIO statically to mm, but that is not a effective solution, see
detailed description in patch 1's commit log.

This patch set introduces one process flag and trys to fix the deadlock
problem on block device/network device during runtime PM or usb bus reset.

The 1st one is the change on include/sched.h and mm.

The 2nd patch introduces the flag of memalloc_noio on 'dev_pm_info',
and pm_runtime_set_memalloc_noio(), so that PM Core can teach mm to not
allocate mm with GFP_IO during the runtime_resume callback only on
device with the flag set.

The following 2 patches apply the introduced pm_runtime_set_memalloc_noio()
to mark all devices as memalloc_noio_resume in the path from the block or
network device to the root device in device tree.

The last 2 patches are applied again PM and USB subsystem to demonstrate
how to use the introduced mechanism to fix the deadlock problem.

Andrew, could you queue these patches into your tree since V6 fixes all
your concerns and looks no one objects these patches?

Change logs:
V7:
	- rebase on v3.8-rc2-next-20130104
	- move memalloc_noio_save/memalloc_noio_restore into
        rpm_callback to avoid code duplication, as suggested
        by Rafael
	- optimize on pm_runtime_set_memalloc_noio(true)
	- fix type of 'flags' in memalloc_noio_save()/memalloc_noio_restore()
V6:
        - fix one compile failure(1/6), and only one line change
V5:
        - don't clear GFP_FS
        - coding style fix
        - add comments
        - see details in individual change logs
V4:
        - patches from the 2nd to the 6th changed
        - call pm_runtime_set_memalloc_noio() after device_add() as pointed
        by Alan
        - set PF_MEMALLOC_NOIO during runtime_suspend()
V3:
        - patch 2/6 and 5/6 changed, see their commit log
        - remove RFC from title since several guys have expressed that
        it is a reasonable solution
V2:
        - remove changes on 'may_writepage' and 'may_swap'(1/6)
        - unset GFP_IOFS in try_to_free_pages() path(1/6)
        - introduce pm_runtime_set_memalloc_noio()
        - only apply the meachnism on block/network device and its ancestors
        for runtime resume context
V1:
        - take Minchan's change to avoid the check in alloc_page hot path
        - change the helpers' style into save/restore as suggested by Alan
        - memory allocation with no io in usb bus reset path for all devices
        as suggested by Greg and Oliver

 block/genhd.c                |   10 +++++
 drivers/base/power/runtime.c |   89 +++++++++++++++++++++++++++++++++++++++++-
 drivers/usb/core/hub.c       |   13 ++++++
 include/linux/pm.h           |    1 +
 include/linux/pm_runtime.h   |    3 ++
 include/linux/sched.h        |   22 +++++++++++
 mm/page_alloc.c              |    9 ++++-
 mm/vmscan.c                  |    4 +-
 net/core/net-sysfs.c         |    5 +++
 9 files changed, 152 insertions(+), 4 deletions(-)


Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
