Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 20C696B13F0
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 18:03:18 -0500 (EST)
Date: Thu, 9 Feb 2012 15:03:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3 v2] move hugepage test examples to
 tools/testing/selftests/vm
Message-Id: <20120209150316.15be9361.akpm@linux-foundation.org>
In-Reply-To: <20120209014622.GA5143@darkstar.nay.redhat.com>
References: <20120205081555.GA2249@darkstar.redhat.com>
	<20120206155340.b9075240.akpm@linux-foundation.org>
	<20120209014622.GA5143@darkstar.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com, cl@linux.com, Frederic Weisbecker <fweisbec@gmail.com>

On Thu, 9 Feb 2012 09:46:22 +0800
Dave Young <dyoung@redhat.com> wrote:

> Andrew, updated the patch as below, is it ok to you?
> ---
> 
> hugepage-mmap.c, hugepage-shm.c and map_hugetlb.c in Documentation/vm are
> simple pass/fail tests, It's better to promote them to tools/testing/selftests
> 
> Thanks suggestion of Andrew Morton about this. They all need firstly setting up
> proper nr_hugepages and hugepage-mmap need to mount hugetlbfs. So I add a shell
> script run_vmtests to do such work which will call the three test programs and
> check the return value of them.
> 
> Changes to original code including below:
> a. add run_vmtests script
> b. return error when read_bytes mismatch with writed bytes.
> c. coding style fixes: do not use assignment in if condition
> 
> [v1 -> v2]:
> 1. [akpm:] rebased on runing make run_tests from Makefile
> 2. [akpm:] rename test script from run_test ro run_vmtests
> 2. fix a bug about shell exit code checking 
> 

So I tried to run this, from tools/testing/selftests.

a) The testing failed because ./vm's run_test target requires root. 

   We need to make a policy decision here.  Do we require that
   selftests run as root?  If not then the root-requiring selftests
   should warn and bail out without declaring a failure, so that those
   tests which can be run without root permissions can be successfully
   used.

b) When I ran the vm test, my machine went paralytically comatose
   for half a minute.  That's a bit rude - if all the selftests do this
   then the selftests become kinda useless.

c) I can run "make run_tests" in the top-lvel directory and all is
   well: the tools in ./vm get compiled first.  But when I do "make
   clean ; cd vm ; make run-tests" it fails, because vm/Makefile
   doesn't build the targets before trying to run them.

   This can be fixed with

--- a/tools/testing/selftests/vm/Makefile~a
+++ a/tools/testing/selftests/vm/Makefile
@@ -7,7 +7,7 @@ all: hugepage-mmap hugepage-shm  map_hug
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
-run_tests:
+run_tests: all
 	/bin/sh ./run_vmtests
 
 clean:

   But this is unpleasing: a top-level "make run_tests" will end up
   trying to compile the targets twice.

   We could change the top-level Makefile to a single-pass thing
   which just descends into the subdirectories and runs "make
   run_tests".  But that gives us no way of compiling everything
   without also running everything.  That's a huge PITA if running
   everything sends your machine comatose for half a minute!

   So I think I'll go with the above patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
