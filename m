Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0044C6B0268
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 11:05:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m72so4574805wmc.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 08:05:37 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 138sor1782117wmf.91.2017.10.09.08.05.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 08:05:36 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2 3/3] kcov: update documentation
Date: Mon,  9 Oct 2017 17:05:21 +0200
Message-Id: <20171009150521.82775-3-glider@google.com>
In-Reply-To: <20171009150521.82775-1-glider@google.com>
References: <20171009150521.82775-1-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mark.rutland@arm.com, alex.popov@linux.com, aryabinin@virtuozzo.com, quentin.casasnovas@oracle.com, dvyukov@google.com, andreyknvl@google.com, keescook@chromium.org, vegard.nossum@oracle.com
Cc: syzkaller@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Victor Chibotaru <tchibo@google.com>

The updated documentation describes new KCOV mode for collecting
comparison operands.

Signed-off-by: Victor Chibotaru <tchibo@google.com>
Signed-off-by: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
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
v2: - reflect the changes to kcov.c in the test program.
---
 Documentation/dev-tools/kcov.rst | 103 +++++++++++++++++++++++++++++++++++++--
 1 file changed, 99 insertions(+), 4 deletions(-)

diff --git a/Documentation/dev-tools/kcov.rst b/Documentation/dev-tools/kcov.rst
index 44886c91e112..6ee65c6e2448 100644
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
@@ -111,3 +125,84 @@ The interface is fine-grained to allow efficient forking of test processes.
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
+     /* Number of 64-bit words per record. */
+     #define KCOV_WORDS_PER_CMP 4
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
+		type = cover[i * KCOV_WORDS_PER_CMP + 1];
+		/* arg1 and arg2 - operands of the comparison. */
+		arg1 = cover[i * KCOV_WORDS_PER_CMP + 2];
+		arg2 = cover[i * KCOV_WORDS_PER_CMP + 3];
+		/* ip - caller address. */
+		ip = cover[i * KCOV_WORDS_PER_CMP + 4];
+		/* size == KCOV_CMP_SIZEi. */
+		size = type & KCOV_CMP_SIZE_MASK;
+		/* is_const - shows whether arg1 is a compile-time constant.*/
+		is_const = type & KCOV_CMP_CONST;
+		printf("ip: 0x%lx type: 0x%lx, arg1: 0x%lx, arg2: 0x%lx, "
+			"size: %lu, %s\n",
+			ip, type, arg1, arg2, size,
+		is_const ? "const" : "non-const");
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
2.14.2.920.gcf0c67979c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
