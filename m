Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B9E516B02F3
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 12:23:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b187so2929275wmh.6
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:23:40 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id y10si3094453edc.131.2017.08.30.09.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 09:23:39 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id a80so13314020wma.0
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:23:39 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 3/3] kcov: update documentation
Date: Wed, 30 Aug 2017 18:23:31 +0200
Message-Id: <3983cf0d7709685ffcd7af007b5f5dc987bdbe3f.1504109849.git.dvyukov@google.com>
In-Reply-To: <cover.1504109849.git.dvyukov@google.com>
References: <cover.1504109849.git.dvyukov@google.com>
In-Reply-To: <cover.1504109849.git.dvyukov@google.com>
References: <cover.1504109849.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: tchibo@google.com, Mark Rutland <mark.rutland@arm.com>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org

From: Victor Chibotaru <tchibo@google.com>

The updated documentation describes new KCOV mode for collecting
comparison operands.

Signed-off-by: Victor Chibotaru <tchibo@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Alexander Popov <alex.popov@linux.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Vegard Nossum <vegard.nossum@oracle.com>
Cc: Quentin Casasnovas <quentin.casasnovas@oracle.com>
Cc: syzkaller@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 Documentation/dev-tools/kcov.rst | 94 ++++++++++++++++++++++++++++++++++++++--
 1 file changed, 90 insertions(+), 4 deletions(-)

diff --git a/Documentation/dev-tools/kcov.rst b/Documentation/dev-tools/kcov.rst
index 44886c91e112..080cb603bf79 100644
--- a/Documentation/dev-tools/kcov.rst
+++ b/Documentation/dev-tools/kcov.rst
@@ -12,19 +12,30 @@ To achieve this goal it does not collect coverage in soft/hard interrupts
 and instrumentation of some inherently non-deterministic parts of kernel is
 disabled (e.g. scheduler, locking).
 
-Usage
------
+kcov is also able to collect comparison operands from the instrumented code
+(this feature currently requires that the kernel is compiled with clang).
+
+Prerequisites
+-------------
 
 Configure the kernel with::
 
         CONFIG_KCOV=y
 
 CONFIG_KCOV requires gcc built on revision 231296 or later.
+
+If the comparison operands need to be collected, set::
+
+	CONFIG_KCOV_ENABLE_COMPARISONS=y
+
 Profiling data will only become accessible once debugfs has been mounted::
 
         mount -t debugfs none /sys/kernel/debug
 
-The following program demonstrates kcov usage from within a test program:
+Coverage collection
+-------------------
+The following program demonstrates coverage collection from within a test
+program using kcov:
 
 .. code-block:: c
 
@@ -44,6 +55,9 @@ The following program demonstrates kcov usage from within a test program:
     #define KCOV_DISABLE			_IO('c', 101)
     #define COVER_SIZE			(64<<10)
 
+    #define KCOV_TRACE_PC  0
+    #define KCOV_TRACE_CMP 1
+
     int main(int argc, char **argv)
     {
 	int fd;
@@ -64,7 +78,7 @@ The following program demonstrates kcov usage from within a test program:
 	if ((void*)cover == MAP_FAILED)
 		perror("mmap"), exit(1);
 	/* Enable coverage collection on the current thread. */
-	if (ioctl(fd, KCOV_ENABLE, 0))
+	if (ioctl(fd, KCOV_ENABLE, KCOV_TRACE_PC))
 		perror("ioctl"), exit(1);
 	/* Reset coverage from the tail of the ioctl() call. */
 	__atomic_store_n(&cover[0], 0, __ATOMIC_RELAXED);
@@ -111,3 +125,75 @@ The interface is fine-grained to allow efficient forking of test processes.
 That is, a parent process opens /sys/kernel/debug/kcov, enables trace mode,
 mmaps coverage buffer and then forks child processes in a loop. Child processes
 only need to enable coverage (disable happens automatically on thread end).
+
+Comparison operands collection
+------------------------------
+Comparison operands collection is similar to coverage collection:
+
+.. code-block:: c
+
+    /* Same includes and defines as above. */
+
+     enum kcov_cmp_type {
+	/*
+	* LSB shows whether the first argument is a compile-time constant.
+	*/
+	KCOV_CMP_CONST = 1,
+	/*
+	* Second and third LSBs contain the size of arguments (1/2/4/8 bytes).
+	*/
+	KCOV_CMP_SIZE1 = 0,
+	KCOV_CMP_SIZE2 = 2,
+	KCOV_CMP_SIZE4 = 4,
+	KCOV_CMP_SIZE8 = 6,
+	KCOV_CMP_SIZE_MASK = 6,
+    };
+
+    int main(int argc, char **argv)
+    {
+	int fd;
+	uint64_t *cover, type, arg1, arg2, is_const, size;
+	unsigned long n, i;
+
+	fd = open("/sys/kernel/debug/kcov", O_RDWR);
+	if (fd == -1)
+		perror("open"), exit(1);
+	if (ioctl(fd, KCOV_INIT_TRACE, COVER_SIZE))
+		perror("ioctl"), exit(1);
+	/*
+	* Note that the buffer pointer is of type uint64_t*, because all
+	* the comparison operands are promoted to uint64_t.
+	*/
+	cover = (uint64_t *)mmap(NULL, COVER_SIZE * sizeof(unsigned long),
+				     PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
+	if ((void*)cover == MAP_FAILED)
+		perror("mmap"), exit(1);
+	/* Note KCOV_TRACE_CMP instead of KCOV_TRACE_PC. */
+	if (ioctl(fd, KCOV_ENABLE, KCOV_TRACE_CMP))
+		perror("ioctl"), exit(1);
+	__atomic_store_n(&cover[0], 0, __ATOMIC_RELAXED);
+	read(-1, NULL, 0);
+	/* Read number of comparisons collected. */
+	n = __atomic_load_n(&cover[0], __ATOMIC_RELAXED);
+	for (i = 0; i < n; i++) {
+		type = cover[i*3 + 1];
+		/* arg1 and arg2 - operands of the comparison. */
+		arg1 = cover[i*3 + 2];
+		arg2 = cover[i*3 + 3];
+		/* size == KCOV_CMP_SIZEi. */
+		size = type & KCOV_CMP_SIZE_MASK;
+		/* is_const - shows whether arg1 is a compile-time constant.*/
+		is_const = type & KCOV_CMP_CONST;
+	}
+	if (ioctl(fd, KCOV_DISABLE, 0))
+		perror("ioctl"), exit(1);
+	/* Free resources. */
+	if (munmap(cover, COVER_SIZE * sizeof(unsigned long)))
+		perror("munmap"), exit(1);
+	if (close(fd))
+		perror("close"), exit(1);
+	return 0;
+    }
+
+Note that the kcov modes (coverage collection or comparison operands) are
+mutually exclusive.
-- 
2.14.1.581.gf28d330327-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
