Date: Fri, 27 Oct 2006 11:47:40 +1000
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [RFC] reduce hugetlb_instantiation_mutex usage
Message-ID: <20061027014740.GD11733@localhost.localdomain>
References: <000101c6f94c$8138c590$ff0da8c0@amr.corp.intel.com> <20061026154451.bfe110c6.akpm@osdl.org> <20061026233137.GA11733@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061026233137.GA11733@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 27, 2006 at 09:31:37AM +1000, 'David Gibson' wrote:
> On Thu, Oct 26, 2006 at 03:44:51PM -0700, Andrew Morton wrote:
[snip]
> > The key points:
> > 
> > - Use tree_lock to prevent the race
> > 
> > - allocate the hugepage inside tree_lock so we never get into this
> >   two-threads-tried-to-allocate-the-final-page problem.
> > 
> > - The hugepage is zeroed without locks held, under lock_page()
> > 
> > - lock_page() is used to make the other thread(s) sleep while the winner
> >   thread is zeroing out the page.
> > 
> > It means that rather a lot of add_to_page_cache() will need to be copied
> > into hugetlb_no_page().
> 
> This handles the case of processes racing on a shared mapping, but not
> the case of threads racing on a private mapping.  In the latter case
> the race ends at the set_pte() rather than the add_to_page_cache()
> (well, strictly with the whole page_table_lock atomic lump).  And we
> can't move the clear after the set_pte() :(.

At various times many people have proposed "solutions" which address
the SHARED case, or the PRIVATE case, but not both.  As Andrew points
out in a later mail his approach may be fixable for the PRIVATE case,
but nonetheless it's important to check both cases.

So, here's another patch for libhugetlbfs, extending its testcase for
this race to check the MAP_PRIVATE case as well as the MAP_SHARED
case.  Adam, please apply.  Everyone else, please test proposed
approaches against the testsuite.  It's not exhaustive, but it's easy
to run and a good start :).

libhugetlbfs: Testcase for MAP_PRIVATE OOM-liable race condition

The spurious OOM condition which can be caused by race conditions in
the hugetlb fault handler can be triggered with both SHARED mappings
(separate processes racing on the same address_space) and with PRIVATE
mappings (different threads racing on the same vma).

At present the alloc-instantiate-race testcase only tests the SHARED
mapping case.  Since at various times kernel fixes have been proposed
which address only one or the other of the cases, extend the testcase
to check the MAP_PRIVATE in addition to the MAP_SHARED case.

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>

Index: libhugetlbfs/tests/alloc-instantiate-race.c
===================================================================
--- libhugetlbfs.orig/tests/alloc-instantiate-race.c	2006-09-04 17:08:33.000000000 +1000
+++ libhugetlbfs/tests/alloc-instantiate-race.c	2006-10-27 11:31:54.000000000 +1000
@@ -42,13 +42,18 @@
 #include <sched.h>
 #include <signal.h>
 #include <sys/wait.h>
+#include <pthread.h>
+#include <linux/unistd.h>
 
 #include <hugetlbfs.h>
 
 #include "hugetests.h"
 
+_syscall0(pid_t, gettid);
+
 static int hpage_size;
 static pid_t child1, child2;
+static pthread_t thread1, thread2;
 
 void cleanup(void)
 {
@@ -58,9 +63,8 @@ void cleanup(void)
 		kill(child2, SIGKILL);
 }
 
-
-static void one_racer(void *p, int cpu,
-	       volatile int *mytrigger, volatile int *othertrigger)
+static int one_racer(void *p, int cpu,
+		     volatile int *mytrigger, volatile int *othertrigger)
 {
 	volatile int *pi = p;
 	cpu_set_t cpuset;
@@ -70,7 +74,7 @@ static void one_racer(void *p, int cpu,
 	CPU_ZERO(&cpuset);
 	CPU_SET(cpu, &cpuset);
 
-	err = sched_setaffinity(getpid(), CPU_SETSIZE/8, &cpuset);
+	err = sched_setaffinity(gettid(), CPU_SETSIZE/8, &cpuset);
 	if (err != 0)
 		CONFIG("sched_setaffinity(cpu%d): %s", cpu, strerror(errno));
 
@@ -83,16 +87,39 @@ static void one_racer(void *p, int cpu,
 	/* Instantiate! */
 	*pi = 1;
 
-	exit(0);
+	return 0;
+}
+
+static void proc_racer(void *p, int cpu,
+		       volatile int *mytrigger, volatile int *othertrigger)
+{
+	exit(one_racer(p, cpu, mytrigger, othertrigger));
 }
 
-static void run_race(void *syncarea)
+struct racer_info {
+	void *p; /* instantiation address */
+	int cpu;
+	int race_type;
+	volatile int *mytrigger;
+	volatile int *othertrigger;
+	int status;
+};
+
+static void *thread_racer(void *info)
+{
+	struct racer_info *ri = info;
+	int rc;
+
+	rc = one_racer(ri->p, ri->cpu, ri->mytrigger, ri->othertrigger);
+	return ri;
+}
+static void run_race(void *syncarea, int race_type)
 {
 	volatile int *trigger1, *trigger2;
 	int fd;
 	void *p;
 	int status1, status2;
-	pid_t ret;
+	int ret;
 
 	memset(syncarea, 0, sizeof(*trigger1) + sizeof(*trigger2));
 	trigger1 = syncarea;
@@ -104,47 +131,90 @@ static void run_race(void *syncarea)
 		FAIL("hugetlbfs_unlinked_fd()");
 
 	verbose_printf("Mapping final page.. ");
-	p = mmap(NULL, hpage_size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
+	p = mmap(NULL, hpage_size, PROT_READ|PROT_WRITE, race_type, fd, 0);
 	if (p == MAP_FAILED)
 		FAIL("mmap(): %s", strerror(errno));
 	verbose_printf("%p\n", p);
 
-	child1 = fork();
-	if (child1 < 0)
-		FAIL("fork(): %s", strerror(errno));
-	if (child1 == 0)
-		one_racer(p, 0, trigger1, trigger2);
-
-	child2 = fork();
-	if (child2 < 0)
-		FAIL("fork(): %s", strerror(errno));
-	if (child2 == 0)
-		one_racer(p, 1, trigger2, trigger1);
-
-	/* wait() calls */
-	ret = waitpid(child1, &status1, 0);
-	if (ret < 0)
-		FAIL("waitpid() child 1: %s", strerror(errno));
-	verbose_printf("Child 1 status: %x\n", status1);
-
-
-	ret = waitpid(child2, &status2, 0);
-	if (ret < 0)
-		FAIL("waitpid() child 2: %s", strerror(errno));
-	verbose_printf("Child 2 status: %x\n", status2);
-
-	if (WIFSIGNALED(status1))
-		FAIL("Child 1 killed by signal %s",
-		     strsignal(WTERMSIG(status1)));
-	if (WIFSIGNALED(status2))
+	if (race_type == MAP_SHARED) {
+		child1 = fork();
+		if (child1 < 0)
+			FAIL("fork(): %s", strerror(errno));
+		if (child1 == 0)
+			proc_racer(p, 0, trigger1, trigger2);
+
+		child2 = fork();
+		if (child2 < 0)
+			FAIL("fork(): %s", strerror(errno));
+		if (child2 == 0)
+			proc_racer(p, 1, trigger2, trigger1);
+
+		/* wait() calls */
+		ret = waitpid(child1, &status1, 0);
+		if (ret < 0)
+			FAIL("waitpid() child 1: %s", strerror(errno));
+		verbose_printf("Child 1 status: %x\n", status1);
+
+
+		ret = waitpid(child2, &status2, 0);
+		if (ret < 0)
+			FAIL("waitpid() child 2: %s", strerror(errno));
+		verbose_printf("Child 2 status: %x\n", status2);
+
+		if (WIFSIGNALED(status1))
+			FAIL("Child 1 killed by signal %s",
+			     strsignal(WTERMSIG(status1)));
+		if (WIFSIGNALED(status2))
 		FAIL("Child 2 killed by signal %s",
 		     strsignal(WTERMSIG(status2)));
 
-	if (WEXITSTATUS(status1) != 0)
-		FAIL("Child 1 terminated with code %d", WEXITSTATUS(status1));
+		status1 = WEXITSTATUS(status1);
+		status2 = WEXITSTATUS(status2);
+	} else {
+		struct racer_info ri1 = {
+			.p = p,
+			.cpu = 0,
+			.mytrigger = trigger1,
+			.othertrigger = trigger2,
+		};
+		struct racer_info ri2 = {
+			.p = p,
+			.cpu = 1,
+			.mytrigger = trigger2,
+			.othertrigger = trigger1,
+		};
+		void *tret1, *tret2;
+
+		ret = pthread_create(&thread1, NULL, thread_racer, &ri1);
+		if (ret != 0)
+			FAIL("pthread_create() 1: %s\n", strerror(errno));
+
+		ret = pthread_create(&thread2, NULL, thread_racer, &ri2);
+		if (ret != 0)
+			FAIL("pthread_create() 2: %s\n", strerror(errno));
+
+		ret = pthread_join(thread1, &tret1);
+		if (ret != 0)
+			FAIL("pthread_join() 1: %s\n", strerror(errno));
+		if (tret1 != &ri1)
+			FAIL("Thread 1 returned %p not %p, killed?\n",
+			     tret1, &ri1);
+		ret = pthread_join(thread2, &tret2);
+		if (ret != 0)
+			FAIL("pthread_join() 2: %s\n", strerror(errno));
+		if (tret2 != &ri2)
+			FAIL("Thread 2 returned %p not %p, killed?\n",
+			     tret2, &ri2);
+
+		status1 = ri1.status;
+		status2 = ri2.status;
+	}
 
-	if (WEXITSTATUS(status2) != 0)
-		FAIL("Child 2 terminated with code %d", WEXITSTATUS(status2));
+	if (status1 != 0)
+		FAIL("Racer 1 terminated with code %d", status1);
+
+	if (status2 != 0)
+		FAIL("Racer 2 terminated with code %d", status2);
 }
 
 int main(int argc, char *argv[])
@@ -153,14 +223,25 @@ int main(int argc, char *argv[])
 	int fd;
 	void *p, *q;
 	unsigned long i;
+	int race_type;
 
 	test_init(argc, argv);
 
-	if (argc != 2)
-		CONFIG("Usage: alloc-instantiate-race <# total available hugepages>");
+	if (argc != 3)
+		CONFIG("Usage: alloc-instantiate-race"
+		       "<# total available hugepages> <private|shard>");
 
 	totpages = atoi(argv[1]);
 
+	if (strcmp(argv[2], "shared") == 0) {
+		race_type = MAP_SHARED;
+	} else if (strcmp(argv[2], "private") == 0) {
+		race_type = MAP_PRIVATE;
+	} else {
+		CONFIG("Usage: alloc-instantiate-race"
+		       "<# total available hugepages> <private|shard>");
+	}
+
 	hpage_size = gethugepagesize();
 	if (hpage_size < 0)
 		CONFIG("No hugepage kernel support");
@@ -189,7 +270,7 @@ int main(int argc, char *argv[])
 		memset(p + (i * hpage_size), 0, sizeof(int));
 	verbose_printf("done\n");
 
-	run_race(q);
+	run_race(q, race_type);
 
 	PASS();
 }
Index: libhugetlbfs/tests/run_tests.sh
===================================================================
--- libhugetlbfs.orig/tests/run_tests.sh	2006-10-27 10:08:23.000000000 +1000
+++ libhugetlbfs/tests/run_tests.sh	2006-10-27 10:45:06.000000000 +1000
@@ -147,7 +147,8 @@ functional_tests () {
 # killall -HUP hugetlbd
 # to make the sharing daemon give up the files
     run_test chunk-overcommit `free_hpages`
-    run_test alloc-instantiate-race `free_hpages`
+    run_test alloc-instantiate-race `free_hpages` shared
+    run_test alloc-instantiate-race `free_hpages` private
     run_test truncate_reserve_wraparound
     run_test truncate_sigbus_versus_oom `free_hpages`
 }


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
