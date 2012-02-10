Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 18F646B13F1
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 21:59:02 -0500 (EST)
Date: Fri, 10 Feb 2012 11:01:28 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH 3/3 v2] move hugepage test examples to
 tools/testing/selftests/vm
Message-ID: <20120210030128.GA23704@darkstar.nay.redhat.com>
References: <20120205081555.GA2249@darkstar.redhat.com>
 <20120206155340.b9075240.akpm@linux-foundation.org>
 <20120209014622.GA5143@darkstar.nay.redhat.com>
 <20120209150316.15be9361.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120209150316.15be9361.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com, cl@linux.com, Frederic Weisbecker <fweisbec@gmail.com>

On Thu, Feb 09, 2012 at 03:03:16PM -0800, Andrew Morton wrote:
> On Thu, 9 Feb 2012 09:46:22 +0800
> Dave Young <dyoung@redhat.com> wrote:
> 
> > Andrew, updated the patch as below, is it ok to you?
> > ---
> > 
> > hugepage-mmap.c, hugepage-shm.c and map_hugetlb.c in Documentation/vm are
> > simple pass/fail tests, It's better to promote them to tools/testing/selftests
> > 
> > Thanks suggestion of Andrew Morton about this. They all need firstly setting up
> > proper nr_hugepages and hugepage-mmap need to mount hugetlbfs. So I add a shell
> > script run_vmtests to do such work which will call the three test programs and
> > check the return value of them.
> > 
> > Changes to original code including below:
> > a. add run_vmtests script
> > b. return error when read_bytes mismatch with writed bytes.
> > c. coding style fixes: do not use assignment in if condition
> > 
> > [v1 -> v2]:
> > 1. [akpm:] rebased on runing make run_tests from Makefile
> > 2. [akpm:] rename test script from run_test ro run_vmtests
> > 2. fix a bug about shell exit code checking 
> > 
> 
> So I tried to run this, from tools/testing/selftests.
> 
> a) The testing failed because ./vm's run_test target requires root. 
> 
>    We need to make a policy decision here.  Do we require that
>    selftests run as root?  If not then the root-requiring selftests
>    should warn and bail out without declaring a failure, so that those
>    tests which can be run without root permissions can be successfully
>    used.

I agree with bailing out with warning for root-requiring selftests.

> 
> b) When I ran the vm test, my machine went paralytically comatose
>    for half a minute.  That's a bit rude - if all the selftests do this
>    then the selftests become kinda useless.

Maybe 256M testing is too much, how about lower it to 64M hugepage test?

> 
> c) I can run "make run_tests" in the top-lvel directory and all is
>    well: the tools in ./vm get compiled first.  But when I do "make
>    clean ; cd vm ; make run-tests" it fails, because vm/Makefile
>    doesn't build the targets before trying to run them.
> 
>    This can be fixed with
> 
> --- a/tools/testing/selftests/vm/Makefile~a
> +++ a/tools/testing/selftests/vm/Makefile
> @@ -7,7 +7,7 @@ all: hugepage-mmap hugepage-shm  map_hug
>  %: %.c
>  	$(CC) $(CFLAGS) -o $@ $^
>  
> -run_tests:
> +run_tests: all
>  	/bin/sh ./run_vmtests
>  
>  clean:
> 
>    But this is unpleasing: a top-level "make run_tests" will end up
>    trying to compile the targets twice.
> 
>    We could change the top-level Makefile to a single-pass thing
>    which just descends into the subdirectories and runs "make
>    run_tests".  But that gives us no way of compiling everything
>    without also running everything.  That's a huge PITA if running
>    everything sends your machine comatose for half a minute!
> 
>    So I think I'll go with the above patch.
> 

Thanks for the fix. For your comment a) and b), how about below fix?
If it's ok, then do you need I resend it with a refreshed whole patch?

---

Run make run_tests will fail without root previledge for vm selftests.
Change to Just bail out with a warning. At the same time lower the test
memory to 64M to avoid comatose machine.

Signed-off-by: Dave Young <dyoung@redhat.com>
---
 tools/testing/selftests/vm/hugepage-mmap.c |    4 ++--
 tools/testing/selftests/vm/hugepage-shm.c  |    8 ++++----
 tools/testing/selftests/vm/map_hugetlb.c   |    4 ++--
 tools/testing/selftests/vm/run_vmtests     |   14 +++++++-------
 4 files changed, 15 insertions(+), 15 deletions(-)

--- linux-2.6.orig/tools/testing/selftests/vm/run_vmtests	2012-02-10 10:33:38.623148609 +0800
+++ linux-2.6/tools/testing/selftests/vm/run_vmtests	2012-02-10 10:40:24.229796996 +0800
@@ -1,8 +1,8 @@
 #!/bin/bash
 #please run as root
 
-#we need 256M, below is the size in kB
-needmem=262144
+#we need 64M, below is the size in kB
+needmem=65536
 mnt=./huge
 
 #get pagesize and freepages from /proc/meminfo
@@ -23,13 +23,13 @@ if [ -n "$freepgs" ] && [ -n "$pgsize" ]
 		lackpgs=$(( $needpgs - $freepgs ))
 		echo $(( $lackpgs + $nr_hugepgs )) > /proc/sys/vm/nr_hugepages
 		if [ $? -ne 0 ]; then
-			echo "Please run this test as root"
-			exit 1
+			echo "WARN: Bail out! Please run vm tests as root."
+			exit 0
 		fi
 	fi
 else
-	echo "no hugetlbfs support in kernel?"
-	exit 1
+	echo "WARN: Bail out! no hugetlbfs support in kernel?"
+	exit 0
 fi
 
 mkdir $mnt
@@ -47,7 +47,7 @@ fi
 
 shmmax=`cat /proc/sys/kernel/shmmax`
 shmall=`cat /proc/sys/kernel/shmall`
-echo 268435456 > /proc/sys/kernel/shmmax
+echo 67108864 > /proc/sys/kernel/shmmax
 echo 4194304 > /proc/sys/kernel/shmall
 echo "--------------------"
 echo "runing hugepage-shm"
--- linux-2.6.orig/tools/testing/selftests/vm/hugepage-mmap.c	2012-02-10 10:39:50.619798511 +0800
+++ linux-2.6/tools/testing/selftests/vm/hugepage-mmap.c	2012-02-10 10:40:07.656464407 +0800
@@ -5,7 +5,7 @@
  * system call.  Before running this application, make sure that the
  * administrator has mounted the hugetlbfs filesystem (on some directory
  * like /mnt) using the command mount -t hugetlbfs nodev /mnt. In this
- * example, the app is requesting memory of size 256MB that is backed by
+ * example, the app is requesting memory of size 64MB that is backed by
  * huge pages.
  *
  * For the ia64 architecture, the Linux kernel reserves Region number 4 for
@@ -23,7 +23,7 @@
 #include <fcntl.h>
 
 #define FILE_NAME "huge/hugepagefile"
-#define LENGTH (256UL*1024*1024)
+#define LENGTH (64UL*1024*1024)
 #define PROTECTION (PROT_READ | PROT_WRITE)
 
 /* Only ia64 requires this */
--- linux-2.6.orig/tools/testing/selftests/vm/hugepage-shm.c	2012-02-10 10:39:47.966465296 +0800
+++ linux-2.6/tools/testing/selftests/vm/hugepage-shm.c	2012-02-10 10:40:24.229796996 +0800
@@ -2,7 +2,7 @@
  * hugepage-shm:
  *
  * Example of using huge page memory in a user application using Sys V shared
- * memory system calls.  In this example the app is requesting 256MB of
+ * memory system calls.  In this example the app is requesting 64MB of
  * memory that is backed by huge pages.  The application uses the flag
  * SHM_HUGETLB in the shmget system call to inform the kernel that it is
  * requesting huge pages.
@@ -17,9 +17,9 @@
  * Note: The default shared memory limit is quite low on many kernels,
  * you may need to increase it via:
  *
- * echo 268435456 > /proc/sys/kernel/shmmax
+ * echo 67108864 > /proc/sys/kernel/shmmax
  *
- * This will increase the maximum size per shared memory segment to 256MB.
+ * This will increase the maximum size per shared memory segment to 64MB.
  * The other limit that you will hit eventually is shmall which is the
  * total amount of shared memory in pages. To set it to 16GB on a system
  * with a 4kB pagesize do:
@@ -38,7 +38,7 @@
 #define SHM_HUGETLB 04000
 #endif
 
-#define LENGTH (256UL*1024*1024)
+#define LENGTH (64UL*1024*1024)
 
 #define dprintf(x)  printf(x)
 
--- linux-2.6.orig/tools/testing/selftests/vm/map_hugetlb.c	2012-02-10 10:39:50.623131844 +0800
+++ linux-2.6/tools/testing/selftests/vm/map_hugetlb.c	2012-02-10 10:40:07.659797740 +0800
@@ -2,7 +2,7 @@
  * Example of using hugepage memory in a user application using the mmap
  * system call with MAP_HUGETLB flag.  Before running this program make
  * sure the administrator has allocated enough default sized huge pages
- * to cover the 256 MB allocation.
+ * to cover the 64 MB allocation.
  *
  * For ia64 architecture, Linux kernel reserves Region number 4 for hugepages.
  * That means the addresses starting with 0x800000... will need to be
@@ -15,7 +15,7 @@
 #include <sys/mman.h>
 #include <fcntl.h>
 
-#define LENGTH (256UL*1024*1024)
+#define LENGTH (64UL*1024*1024)
 #define PROTECTION (PROT_READ | PROT_WRITE)
 
 #ifndef MAP_HUGETLB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
