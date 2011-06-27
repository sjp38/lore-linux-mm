Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D530A6B0153
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 09:42:40 -0400 (EDT)
Received: by mail-pv0-f169.google.com with SMTP id 12so3648874pvc.14
        for <linux-mm@kvack.org>; Mon, 27 Jun 2011 06:42:38 -0700 (PDT)
From: Geunsik Lim <leemgs1@gmail.com>
Subject: [PATCH V2 4/4] munmap: documentation of munmap operation interface
Date: Mon, 27 Jun 2011 22:41:56 +0900
Message-Id: <1309182116-26698-5-git-send-email-leemgs1@gmail.com>
In-Reply-To: <1309182116-26698-1-git-send-email-leemgs1@gmail.com>
References: <1309182116-26698-1-git-send-email-leemgs1@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Darren Hart <dvhart@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

From: Geunsik Lim <geunsik.lim@samsung.com>

kernel documentation to utilize flexible memory unmap operation
interface for the ideal scheduler latency.

Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
Acked-by: Hyunjin Choi <hj89.choi@samsung.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Steven Rostedt <rostedt@redhat.com>
CC: Hugh Dickins <hughd@google.com>
CC: Randy Dunlap <randy.dunlap@oracle.com>
CC: Ingo Molnar <mingo@elte.hu>
---
 Documentation/sysctl/vm.txt |   36 ++++++++++++++++++++++++++++++++++++
 MAINTAINERS                 |    7 +++++++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 30289fa..5d70098 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -40,6 +40,7 @@ Currently, these files are in /proc/sys/vm:
 - min_slab_ratio
 - min_unmapped_ratio
 - mmap_min_addr
+- munmap_unit_size
 - nr_hugepages
 - nr_overcommit_hugepages
 - nr_pdflush_threads
@@ -409,6 +410,42 @@ against future potential kernel bugs.
 
 ==============================================================
 
+munmap_unit_size
+
+unmap_vmas(= unmap a range of memory covered by a list of vma) is treading
+a delicate and uncomfortable line between high performance and low latency.
+We've chosen to improve performance at the expense of latency.
+
+So although there may be no need to reschedule right now,
+if we keep on gathering more and more memory without flushing,
+we'll be very unresponsive when a reschedule is needed later on.
+
+Consider the best suitable result between high performance and low latency
+on preemptive mode or non-preemptive mode. Select optimal munmap size to
+return memory space that is allocated by mmap system call.
+
+For example, for recording mass files, if we try to unmap memory that we
+allocated with 100MB for recording in embedded devices, we have to wait
+for more than 3 seconds to change mode from play mode to recording mode.
+This results from the unit of memory unmapped size when we are recording
+mass files like camcorder particularly.
+
+This value can be changed after boot using the
+/proc/sys/vm/munmap_unit_size tunable.
+
+Examples:
+         2048 => 8,388,608 bytes : for straight-line efficiency
+         1024 => 4,194,304 bytes
+          512 => 2,097,152 bytes
+          256 => 1,048,576 bytes
+          128 =>   524,288 bytes
+           64 =>   262,144 bytes
+           32 =>   131,072 bytes
+           16 =>    65,536 bytes
+            8 =>    32,768 bytes : for low-latency
+
+==============================================================
+
 nr_hugepages
 
 Change the minimum size of the hugepage pool.
diff --git a/MAINTAINERS b/MAINTAINERS
index 1380312..3f1960a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4128,6 +4128,12 @@ L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/memcontrol.c
 
+MEMORY UNMAP OPERATION UNIT INTERFACE
+M:      Geunsik Lim <geunsik.lim@samsung.com>
+S:      Maintained
+F:      mm/munmap_unit_size.c
+F:      include/linux/munmap_unit_size.h
+
 MEMORY TECHNOLOGY DEVICES (MTD)
 M:	David Woodhouse <dwmw2@infradead.org>
 L:	linux-mtd@lists.infradead.org
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
