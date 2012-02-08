Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 559436B13F0
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 22:41:04 -0500 (EST)
Received: by iagz16 with SMTP id z16so294142iag.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 19:41:03 -0800 (PST)
Date: Wed, 8 Feb 2012 04:40:59 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: [PATCH] selftests: Launch individual selftests from the main Makefile
Message-ID: <20120208034055.GA23894@somewhere.redhat.com>
References: <20120205081555.GA2249@darkstar.redhat.com>
 <20120206155340.b9075240.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120206155340.b9075240.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Young <dyoung@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com, cl@linux.com

On Mon, Feb 06, 2012 at 03:53:40PM -0800, Andrew Morton wrote:
> On Sun, 5 Feb 2012 16:15:55 +0800
> Dave Young <dyoung@redhat.com> wrote:
> 
> > hugepage-mmap.c, hugepage-shm.c and map_hugetlb.c in Documentation/vm are
> > simple pass/fail tests, It's better to promote them to tools/testing/selftests
> > 
> > Thanks suggestion of Andrew Morton about this. They all need firstly setting up
> > proper nr_hugepages and hugepage-mmap need to mount hugetlbfs. So I add a shell
> > script run_test to do such work which will call the three test programs and
> > check the return value of them.
> > 
> > Changes to original code including below:
> > a. add run_test script
> > b. return error when read_bytes mismatch with writed bytes.
> > c. coding style fixes: do not use assignment in if condition
> > 
> 
> I think Frederic is doing away with tools/testing/selftests/run_tests
> in favour of a Makefile target?  ("make run_tests", for example).
> 
> Until we see such a patch we cannot finalise your patch and if I apply
> your patch, his patch will need more work.  Not that this is rocket
> science ;)
> 
> > 
> > ...
> >
> > --- /dev/null
> > +++ b/tools/testing/selftests/vm/run_test
> 
> (We now have a "run_tests" and a "run_test".  The difference in naming
> is irritating)
> 
> Your vm/run_test file does quite a lot of work and we couldn't sensibly
> move all its functionality into Makefile, I expect.
> 
> So I think it's OK to retain a script for this, but I do think that we
> should think up a standardized way of invoking it from vm/Makefile, so
> the top-level Makefile in tools/testing/selftests can simply do "cd
> vm;make run_test", where the run_test target exists in all
> subdirectories.  The vm/Makefile run_test target can then call out to
> the script.
> 
> Also, please do not assume that the script has the x bit set.  The x
> bit easily gets lost on kernel scripts (patch(1) can lose it) so it is
> safer to invoke the script via "/bin/sh script-name" or $SHELL or
> whatever.
> 
> Anyway, we should work with Frederic on sorting out some standard
> behavior before we can finalize this work, please.
> 

Ok. Would the following patch work?

---
From: Frederic Weisbecker <fweisbec@gmail.com>
Date: Wed, 8 Feb 2012 04:21:46 +0100
Subject: [PATCH] selftests: Launch individual selftests from the main
 Makefile

Drop the run_tests script and launch the selftests by calling
"make run_tests" from the selftests top directory instead. This
delegates to the Makefile on each selftest directory where it
is decided how to launch the local test.

This drops the need to add each selftest directory on the
now removed "run_tests" top script.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
---
 tools/testing/selftests/Makefile             |    5 +++++
 tools/testing/selftests/breakpoints/Makefile |    7 +++++--
 tools/testing/selftests/run_tests            |    8 --------
 3 files changed, 10 insertions(+), 10 deletions(-)
 delete mode 100644 tools/testing/selftests/run_tests

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 4ec8401..b1119f0 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -5,6 +5,11 @@ all:
 		make -C $$TARGET; \
 	done;
 
+run_tests:
+	for TARGET in $(TARGETS); do \
+		make -C $$TARGET run_tests; \
+	done;
+
 clean:
 	for TARGET in $(TARGETS); do \
 		make -C $$TARGET clean; \
diff --git a/tools/testing/selftests/breakpoints/Makefile b/tools/testing/selftests/breakpoints/Makefile
index f362722..9312780 100644
--- a/tools/testing/selftests/breakpoints/Makefile
+++ b/tools/testing/selftests/breakpoints/Makefile
@@ -11,10 +11,13 @@ endif
 
 all:
 ifeq ($(ARCH),x86)
-	gcc breakpoint_test.c -o run_test
+	gcc breakpoint_test.c -o breakpoint_test
 else
 	echo "Not an x86 target, can't build breakpoints selftests"
 endif
 
+run_tests:
+	./breakpoint_test
+
 clean:
-	rm -fr run_test
+	rm -fr breakpoint_test
diff --git a/tools/testing/selftests/run_tests b/tools/testing/selftests/run_tests
deleted file mode 100644
index 320718a..0000000
--- a/tools/testing/selftests/run_tests
+++ /dev/null
@@ -1,8 +0,0 @@
-#!/bin/bash
-
-TARGETS=breakpoints
-
-for TARGET in $TARGETS
-do
-	$TARGET/run_test
-done
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
