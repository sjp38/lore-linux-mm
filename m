Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5326B0003
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 03:05:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 88-v6so2729640wrc.21
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 00:05:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 80sor824503wmk.31.2018.04.28.00.05.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 28 Apr 2018 00:05:57 -0700 (PDT)
Date: Sat, 28 Apr 2018 09:05:53 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/9] [v3] x86, pkeys: two protection keys bug fixes
Message-ID: <20180428070553.yjlt22sb6ntcaqnc@gmail.com>
References: <20180427174527.0031016C@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180427174527.0031016C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, akpm@linux-foundation.org, shuah@kernel.org, shakeelb@google.com


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> Hi x86 maintainers,
> 
> This set is basically unchanged from the last post.  There was
> some previous discussion about other ways to fix this with the ppc
> folks (Ram Pai), but we've concluded that this x86-specific fix is
> fine.  I think Ram had a different fix for ppc.
> 
> Changes from v2:
>  * Clarified commit message in patch 1/9 taking some feedback from
>    Shuah.
> 
> Changes from v1:
>  * Added Fixes: and cc'd stable.  No code changes.
> 
> --
> 
> This fixes two bugs, and adds selftests to make sure they stay fixed:
> 
> 1. pkey 0 was not usable via mprotect_pkey() because it had never
>    been explicitly allocated.
> 2. mprotect(PROT_EXEC) memory could sometimes be left with the
>    implicit exec-only protection key assigned.
> 
> I already posted #1 previously.  I'm including them both here because
> I don't think it's been picked up in case folks want to pull these
> all in a single bundle.

A couple of observations:

1)

Minor patch series organization requests:

 - please include the shortlog and diffstat in the cover letter in the future, as 
   it makes it easier to see the overall structure and makes it easier to reply to 
   certain commits as a group.

 - please capitalize commit titles as is usually done in arch/x86/ and change the 
   change the subsystem tags to the usual ones:

d76eeb1914c8: x86/pkeys: Override pkey when moving away from PROT_EXEC
f30f10248200: x86/pkeys/selftests: Add PROT_EXEC test
0530ebfefcdc: x86/pkeys/selftests: Add allow faults on unknown keys
e81c40e33818: x86/pkeys/selftests: Factor out "instruction page"
57042882631c: x86/pkeys/selftests: Fix pkey exhaustion test off-by-one
6b833e9d3171: x86/pkeys/selftests: Fix pointer math
d16f12e3c4ca: x86/pkeys: Do not special case protection key 0
1cb7691d0ee4: x86/pkeys/selftests: Add a test for pkey 0
273ae5cde423: x86/pkeys/selftests: Save off 'prot' for allocations

 - please re-order the series to first introduce a unit test which specifically 
   tests for the failure, ascertain that it indeed fails, and then apply the 
   kernel fix. I.e. please use the order I used above for future versions of this 
   patch-set.

2)

The new self-test you added does not fail overly nicely, it does the following on 
older kernels:

  deimos:~/tip/tools/testing/selftests/x86> ./protection_keys_64 
  has pku: 1
  startup pkru: 55555554
  WARNING: not run as root, can not do hugetlb test
  test  0 PASSED (iteration 1)
  test  1 PASSED (iteration 1)
  test  2 PASSED (iteration 1)
  test  3 PASSED (iteration 1)
  test  4 PASSED (iteration 1)
  test  5 PASSED (iteration 1)
  test  6 PASSED (iteration 1)
  test  7 PASSED (iteration 1)
  test  8 PASSED (iteration 1)
  assert() at protection_keys.c::668 test_nr: 9 iteration: 1
  errno at assert: 22running abort_hooks()...
  protection_keys_64: protection_keys.c:668: mprotect_pkey: Assertion `!ret' failed.
  Aborted (core dumped)

It would be nice to catch the crash or the error in a more obvious way and turn it 
into a proper test failure - and maybe print an indication that this is probably 
an older kernel or so?

This, beyond being less scary to users, would also allow the other tests to be run 
on older kernels. (It would also be helpful to us should we (accidentally) 
reintroduce a similar bug in the future.)

I.e. x86 unit tests should never 'crash' in a way that suggests that the testing 
itself might be buggy - the crashes/failures should always be well controlled.

3)

When the first kernel bug fix is applied but not the second, then I don't see the 
new PROT_EXEC test catching the bug:

  deimos:~/tip/tools/testing/selftests/x86> ./protection_keys_64 
  has pku: 1
  startup pkru: 55555554
  WARNING: not run as root, can not do hugetlb test
  test  0 PASSED (iteration 1)
  test  1 PASSED (iteration 1)
  ...
  done (all tests OK)

I.e. in the booted kernel I didn't have this kernel fix applied:

  x86/pkeys: Override pkey when moving away from PROT_EXEC

But I had these applied:

  f30f10248200 x86/pkeys/selftests: Add PROT_EXEC test
  0530ebfefcdc x86/pkeys/selftests: Add allow faults on unknown keys
  e81c40e33818 x86/pkeys/selftests: Factor out "instruction page"
  57042882631c x86/pkeys/selftests: Fix pkey exhaustion test off-by-one
  6b833e9d3171 x86/pkeys/selftests: Fix pointer math
  d16f12e3c4ca x86/pkeys: Do not special case protection key 0
  1cb7691d0ee4 x86/pkeys/selftests: Add a test for pkey 0
  273ae5cde423 x86/pkeys/selftests: Save off 'prot' for allocations

(Note that the key-0 kernel fix is applied, so that test passes.)

4)

In the above kernel that was missing the PROT_EXEC fix I was repeatedly running 
the 64-bit and 32-bit testcases as non-root and as root as well, until I got a 
hang in the middle of a 32-bit test running as root:

  test  7 PASSED (iteration 19)
  test  8 PASSED (iteration 19)
  test  9 PASSED (iteration 19)

  < test just hangs here >

this is what it looked like in ps:

 3954 pts/0    S      0:00 bash
 3987 pts/0    S+     0:00 ./protection_keys_32
 4006 pts/0    t+     0:00 ./protection_keys_32

And when attaching to it via gdb the main process was hanging here:

(gdb) bt
#0  0xf7f7ac79 in __kernel_vsyscall ()
#1  0xf7e69b11 in ?? () from /lib32/libc.so.6
#2  0xf7ddc1fb in ?? () from /lib32/libc.so.6
#3  0xf7ddc5b6 in _IO_flush_all () from /lib32/libc.so.6
#4  0x0804bc63 in sig_chld (x=17) at protection_keys.c:342
#5  <signal handler called>
#6  0xf7ddc1fb in ?? () from /lib32/libc.so.6
#7  0xf7ddc5b6 in _IO_flush_all () from /lib32/libc.so.6
#8  0x0804c5b2 in __wrpkru (pkru=4) at pkey-helpers.h:93
#9  pkey_set (pkey=1, rights=1, flags=0) at protection_keys.c:437
#10 0x0804c687 in pkey_disable_set (pkey=1, flags=1) at protection_keys.c:463
#11 0x0804f286 in pkey_access_deny (pkey=1) at protection_keys.c:525
#12 test_ptrace_of_child (ptr=0xf7800000, pkey=1) at protection_keys.c:1248
#13 0x0804fd18 in run_tests_once () at protection_keys.c:1429
#14 0x08049145 in main () at protection_keys.c:1476

the child task could not be attached to, because it was already a ptrace child of 
the main task. Then I killed the main task (while it was still being ptraced by 
gdb), which allowed me to attach gdb to the child task:

(gdb) bt
#0  0xf7f7ac79 in __kernel_vsyscall ()
#1  0xf7e25233 in nanosleep () from /lib32/libc.so.6
#2  0xf7e2516d in sleep () from /lib32/libc.so.6
#3  0x0804c476 in fork_lazy_child () at protection_keys.c:390
#4  0x0804f20b in test_ptrace_of_child (ptr=0xf7800000, pkey=1) at protection_keys.c:1231
#5  0x0804fd18 in run_tests_once () at protection_keys.c:1429
#6  0x08049145 in main () at protection_keys.c:1476

After I got the GDB backtraces I tried to clean up leftover tasks, but the main 
thread would not go away:

 4006 pts/0    00:00:00 protection_keys <defunct>

neither SIGCONT nor SIGKILL appears to help:

 root@deimos:/home/mingo/tip/tools/testing/selftests/x86# kill -CONT 4006
 root@deimos:/home/mingo/tip/tools/testing/selftests/x86# kill -9 4006
 root@deimos:/home/mingo/tip/tools/testing/selftests/x86# ps
   PID TTY          TIME CMD
  3953 pts/0    00:00:00 su
  3954 pts/0    00:00:00 bash
  4006 pts/0    00:00:00 protection_keys <defunct>
  4307 pts/0    00:00:00 ps

This task stayed zombie until the next reboot. There were no suspicious kernel 
messages in the log during or after the test.

I ran the tests based on tip:x86/urgent (which is v4.17-rc2 based), on top of a 
pretty vanilla installation of Ubuntu:

  # cat /etc/os-release 
  NAME="Ubuntu"
  VERSION="17.10 (Artful Aardvark)"

Thanks,

	Ingo
