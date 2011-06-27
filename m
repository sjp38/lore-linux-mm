Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9066B0148
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 09:42:37 -0400 (EDT)
Received: by pvc12 with SMTP id 12so3648874pvc.14
        for <linux-mm@kvack.org>; Mon, 27 Jun 2011 06:42:34 -0700 (PDT)
From: Geunsik Lim <leemgs1@gmail.com>
Subject: [PATCH V2 3/4] munmap: kbuild menu for munmap interface
Date: Mon, 27 Jun 2011 22:41:55 +0900
Message-Id: <1309182116-26698-4-git-send-email-leemgs1@gmail.com>
In-Reply-To: <1309182116-26698-1-git-send-email-leemgs1@gmail.com>
References: <1309182116-26698-1-git-send-email-leemgs1@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Darren Hart <dvhart@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

From: Geunsik Lim <geunsik.lim@samsung.com>

Support kbuild menu to select memory unmap operation size
at build time.

Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
Acked-by: Hyunjin Choi <hj89.choi@samsung.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Steven Rostedt <rostedt@redhat.com>
CC: Hugh Dickins <hughd@google.com>
CC: Randy Dunlap <randy.dunlap@oracle.com>
CC: Ingo Molnar <mingo@elte.hu>
---
 init/Kconfig |   70 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 84 insertions(+), 7 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 56240e7..47283ed 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -557,6 +557,79 @@ config LOG_BUF_SHIFT
 		     13 =>  8 KB
 		     12 =>  4 KB
 
+config PREEMPT_OK_MUNMAP_RANGE
+	int "Memory unmap unit on preemptive mode (8 => 32KB)"
+	depends on !PREEMPT_NONE
+	range 8 2048
+	default 8
+	help
+	  unmap_vmas(= unmap a range of memory covered by a list of vma) is
+	  treading a delicate and uncomfortable line between high performance
+	  and low latency.
+	  This option improves performance at the expense of latency.
+
+	  So although there may be no need to reschedule right now,
+	  if we keep on gathering more and more memory without flushing,
+	  we'll be very unresponsive when a reschedule is needed later on.
+
+	  Consider the best suitable result between high performance and
+	  low latency on preempt mode. Select optimal munmap size to return
+          memory space that is allocated by mmap system call.
+
+	  For example, for recording mass files, if we try to unmap memory
+	  that we allocated with 100MB for recording in embedded devices,
+	  we have to wait for more than 3 seconds to change mode from play
+	  mode to recording mode. This results from the unit of memory unmapped
+	  size when we are recording mass files like camcorder particularly.
+
+	  This value can be changed after boot using the
+	  /proc/sys/vm/munmap_unit_size tunable.
+
+	  Examples:
+                  2048 => 8,388,608 bytes : for straight-line efficiency
+                  1024 => 4,194,304 bytes
+                   512 => 2,097,152 bytes
+                   256 => 1,048,576 bytes
+                   128 =>   524,288 bytes
+                    64 =>   262,144 bytes
+                    32 =>   131,072 bytes
+                    16 =>    65,536 bytes
+                     8 =>    32,768 bytes : for low-latency (*default)
+
+config PREEMPT_NO_MUNMAP_RANGE
+	int "Memory unmap unit on non-preempt mode (1024 => 4MB)"
+	depends on PREEMPT_NONE
+	range 8 2048
+	default 1024
+	help
+
+	  unmap_vmas(= unmap a range of memory covered by a list of vma) is
+	  treading a delicate and uncomfortable line between high performance
+	  and low latency.
+	  This option improves performance at the expense of latency.
+
+	  So although there may be no need to reschedule right now,
+	  if we keep on gathering more and more memory without flushing,
+	  we'll be very unresponsive when a reschedule is needed later on.
+
+	  Consider the best suitable result between high performance and
+	  low latency on non-preempt mode. Select optimal munmap size to return
+	  memory space that is allocated by mmap system call.
+
+	  This value can be changed after boot using the
+	  /proc/sys/vm/munmap_unit_size tunable.
+
+	  Examples:
+                  2048 => 8,388,608 bytes : for straight-line efficiency
+                  1024 => 4,194,304 bytes (*default)
+                   512 => 2,097,152 bytes
+                   256 => 1,048,576 bytes
+                   128 =>   524,288 bytes
+                    64 =>   262,144 bytes
+                    32 =>   131,072 bytes
+                    16 =>    65,536 bytes
+                     8 =>    32,768 bytes : for low-latency
+
 #
 # Architectures with an unreliable sched_clock() should select this:
 #
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
