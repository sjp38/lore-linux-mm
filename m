Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4F1A6600044
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 13:33:57 -0400 (EDT)
Received: by fxm3 with SMTP id 3so197272fxm.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 10:33:55 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Subject: [PATCH 00/10] zram: various improvements and cleanups
Date: Mon,  9 Aug 2010 22:56:46 +0530
Message-Id: <1281374816-904-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>
Cc: Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

The zram module creates RAM based block devices named /dev/zram<id>
(<id> = 0, 1, ...). Pages written to these disks are compressed and stored
in memory itself.

One of the major changes done is the replacement of ioctls with sysfs
interface. One of the advantages of this approach is we no longer depend on the
userspace tool (rzscontrol) which was used to set various parameters and check
statistics. Maintaining updated version of rzscontrol as changes were done to
ioctls, statistics exported etc. was a major pain.

Another significant change is the introduction of percpu stats and compression
buffers. Earlier, we had per-device buffers protected by a mutex. This was a
major bottleneck on multi-core systems. With these changes, benchmarks with
fio[1] showed a speedup of about 20% for write performance on dual-core
system (see patch 4/10 description for details).


For easier testing, a single patch against 2.6.35-git8 has been uploaded at:
http://compcache.googlecode.com/hg/sub-projects/mainline/zram_2.6.36-rc0.patch

[1] fio I/O benchmarking tool: http://freshmeat.net/projects/fio/

Nitin Gupta (10):
  Replace ioctls with sysfs interface
  Remove need for explicit device initialization
  Use percpu stats
  Use percpu buffers
  Reduce per table entry overhead by 4 bytes
  Block discard support
  Increase compressed page size threshold
  Some cleanups
  Update zram documentation
  Document sysfs entries

 Documentation/ABI/testing/sysfs-block-zram |   99 ++++
 drivers/staging/zram/Kconfig               |   12 -
 drivers/staging/zram/Makefile              |    2 +-
 drivers/staging/zram/xvmalloc.c            |   22 +-
 drivers/staging/zram/zram.txt              |   58 ++-
 drivers/staging/zram/zram_drv.c            |  670 ++++++++++++++--------------
 drivers/staging/zram/zram_drv.h            |  138 ++----
 drivers/staging/zram/zram_ioctl.h          |   41 --
 drivers/staging/zram/zram_sysfs.c          |  253 +++++++++++
 9 files changed, 760 insertions(+), 535 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-block-zram
 delete mode 100644 drivers/staging/zram/zram_ioctl.h
 create mode 100644 drivers/staging/zram/zram_sysfs.c

-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
