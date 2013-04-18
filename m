Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id B4A006B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 06:14:42 -0400 (EDT)
In-Reply-To: <516D90F6.3020603@linux.intel.com>
References: <OF000BBE68.EBB4E92E-ON48257B4F.0010C2E7-48257B4F.0013FB89@zte.com.cn> <516D90F6.3020603@linux.intel.com>
Subject: =?GB2312?B?tPC4tDogUmU6IFtQQVRDSF0gZnV0ZXg6IGJ1Z2ZpeCBmb3IgZnV0ZXgta2V5?=
 =?GB2312?B?IGNvbmZsaWN0IHdoZW4gZnV0ZXggdXNlIGh1Z2VwYWdl?=
MIME-Version: 1.0
Message-ID: <OF043B794B.C2870B50-ON48257B51.0037D9F7-48257B51.00384768@zte.com.cn>
From: zhang.yi20@zte.com.cn
Date: Thu, 18 Apr 2013 18:14:06 +0800
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Darren Hart <dvhart@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

Darren Hart <dvhart@linux.intel.com> wrote on 2013/04/17 01:57:10:


> 
> Again, a functional testcase in futextest would be a good idea. This
> helps validate the patch and also can be used to identify regressions in
> the future.
> 
> 

I write the testcase for futex using hugepage:

diff -uprN functional/futex_hugepage.c functional/futex_hugepage.c
--- functional/futex_hugepage.c 1970-01-01 00:00:00.000000000 +0000
+++ functional/futex_hugepage.c 2013-04-18 16:55:44.119239404 +0000
@@ -0,0 +1,188 @@
+/*********************************************************************
+ *   This program is free software;  you can redistribute it and/or 
+ *   modify it under the terms of the GNU General Public License as 
+ *   published by the Free Software Foundation; either version 2 of 
+ *   the License, or (at your option) any later version.
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ *   the GNU General Public License for more details.
+ *
+ *   You should have received a copy of the GNU General Public License
+ *   along with this program;  if not, write to the Free Software
+ *   Foundation, Inc., 59 Temple Place, Suite 330, Boston,
+ *   MA 02111-1307 USA
+ * NAME
+ *      futex_hugepage.c
+ *
+ * DESCRIPTION
+ *      Testing futex when using huge page
+ *
+ * AUTHOR
+ *      Zhang Yi <zhang.yi20@zte.com.cn>
+ *
+ * HISTORY
+ *      2013-4-18: Initial version by Zhang Yi <zhang.yi20@zte.com.cn>
+ *
+ ********************************************************************/
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <sys/syscall.h>
+#include <sys/mman.h>
+#include <sys/types.h>
+#include <fcntl.h>
+#include <pthread.h>
+#include <errno.h>
+#include <sys/time.h>
+#include <signal.h>
+
+#include "futextest.h"
+#include "logging.h"
+
+#define DEFAULT_FILE_NAME "/mnt/hugepagefile"
+#define MAX_FILENAME_LEN 128
+
+#define DEFAULT_HUGE_SIZE (2 * 1024 * 1024)
+
+#define PROTECTION (PROT_READ | PROT_WRITE)
+
+/* Only ia64 requires this */
+#ifdef __ia64__
+#define ADDR (void *)(0x8000000000000000UL)
+#define FLAGS (MAP_SHARED | MAP_FIXED)
+#else
+#define ADDR (void *)(0x0UL)
+#define FLAGS (MAP_SHARED)
+#endif
+
+
+futex_t *futex1, *futex2;
+
+unsigned long th2_wait_time;
+int th2_wait_done;
+
+void usage(char *prog)
+{
+       printf("Usage: %s\n", prog);
+       printf("  -f    hugetlbfs file path\n");
+       printf("  -l    hugepage size\n");
+}
+
+int gettid(void)
+{
+       return syscall(SYS_gettid);
+}
+
+void *wait_thread1(void *arg)
+{
+       futex_wait(futex1, *futex1, NULL, 0);
+       return NULL;
+}
+
+
+void *wait_thread2(void *arg)
+{
+       struct timeval tv;
+
+       gettimeofday(&tv, NULL);
+       th2_wait_time = tv.tv_sec;
+       futex_wait(futex2, *futex2, NULL, 0);;
+       th2_wait_done = 1;
+
+       return NULL;
+}
+
+int huge_futex_test(char *file_path, unsigned long huge_size)
+{
+       void *addr;
+       int fd, pgsz, wait_max_time = 30;
+       int ret = RET_PASS;
+       pthread_t th1, th2;
+       struct timeval tv;
+ 
+       fd = open(file_path, O_CREAT | O_RDWR, 0755);
+       if (fd < 0) {
+               perror("Open failed");
+               exit(1);
+       }
+ 
+       /*map hugetlbfs file*/
+       addr = mmap(ADDR, huge_size, PROTECTION, FLAGS, fd, 0);
+       if (addr == MAP_FAILED) {
+               perror("mmap");
+               unlink(file_path);
+               exit(1);
+       }
+
+       pgsz = getpagesize();
+       printf("page size is %d\n", pgsz);
+ 
+       /*apply the first subpage to futex1*/
+       futex1 = addr;
+       *futex1 = FUTEX_INITIALIZER ;
+       /*apply the second subpage to futex2*/
+       futex2 = addr + pgsz;
+       *futex2 = FUTEX_INITIALIZER ;
+ 
+
+       /*thread1 block on futex1 first,then thread2 block on futex2*/
+       pthread_create(&th1, NULL, wait_thread1, NULL);
+       sleep(2);
+       pthread_create(&th2, NULL, wait_thread2, NULL);
+       sleep(2);
+
+       /*try to wake up thread2*/
+       futex_wake(futex2, 1, 0);
+
+       /*see if thread2 can be woke up*/
+       while(!th2_wait_done) {
+               gettimeofday(&tv, NULL);
+               /*thread2 block over 30 secs, test fail*/
+               if(tv.tv_sec > (th2_wait_time + wait_max_time)) {
+                       printf("wait_thread2 wait for %ld secs\n", 
+                                   tv.tv_sec - th2_wait_time);
+                       ret = RET_FAIL;
+               }
+               sleep(2);
+       }
+
+       munmap(addr, huge_size);
+       close(fd);
+       unlink(file_path);
+
+       return ret;
+}
+
+int main(int argc, char *argv[])
+{
+       unsigned long huge_size = DEFAULT_HUGE_SIZE;
+       char file_path[MAX_FILENAME_LEN];
+       int ret, c;
+
+       strcpy(file_path, DEFAULT_FILE_NAME);
+
+       while ((c = getopt(argc, argv, "cf:l:")) != -1) {
+               switch(c) {
+               case 'c':
+                       log_color(1);
+               case 'f':
+                       strcpy(file_path, optarg);
+                       break;
+               case 'l':
+                       huge_size = atoi(optarg) * 1024 * 1024;
+                       break;
+               default:
+                       usage(basename(argv[0]));
+                       exit(1);
+               }
+       }
+ 
+       ret = huge_futex_test(file_path, huge_size);
+
+       print_result(ret);
+
+       return ret;
+}
+
diff -uprN functional/run.sh functional/run.sh
--- functional/run.sh   2013-04-18 06:39:56.000000000 +0000
+++ functional/run.sh   2013-04-18 16:55:59.447240286 +0000
@@ -89,3 +89,6 @@ echo
 echo
 ./futex_wait_uninitialized_heap $COLOR
 ./futex_wait_private_mapped_file $COLOR
+
+echo
+./futex_hugepage $COLOR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
