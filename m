From: riel@redhat.com
Subject: [PATCH 0/2] mm,fork: MADV_WIPEONFORK - an empty VMA in the child
Date: Fri,  4 Aug 2017 15:01:08 -0400
Message-ID: <20170804190110.17087-1-riel@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org
List-Id: linux-mm.kvack.org

Introduce MADV_WIPEONFORK semantics, which result in a VMA being
empty in the child process after fork. This differs from MADV_DONTFORK
in one important way.
    
If a child process accesses memory that was MADV_WIPEONFORK, it
will get zeroes. The address ranges are still valid, they are just empty.
    
If a child process accesses memory that was MADV_DONTFORK, it will
get a segmentation fault, since those address ranges are no longer
valid in the child after fork.
    
Since MADV_DONTFORK also seems to be used to allow very large
programs to fork in systems with strict memory overcommit restrictions,
changing the semantics of MADV_DONTFORK might break existing programs.
    
The use case is libraries that store or cache information, and
want to know that they need to regenerate it in the child process
after fork.
Examples of this would be:
- systemd/pulseaudio API checks (fail after fork)
  (replacing a getpid check, which is too slow without a PID cache)
- PKCS#11 API reinitialization check (mandated by specification)
- glibc's upcoming PRNG (reseed after fork)
- OpenSSL PRNG (reseed after fork)
    
 The security benefits of a forking server having a re-inialized
 PRNG in every child process are pretty obvious. However, due to
 libraries having all kinds of internal state, and programs getting
 compiled with many different versions of each library, it is
 unreasonable to expect calling programs to re-initialize everything
 manually after fork.
    
 A further complication is the proliferation of clone flags,
 programs bypassing glibc's functions to call clone directly,
 and programs calling unshare, causing the glibc pthread_atfork
 hook to not get called.
    
 It would be better to have the kernel take care of this automatically.
    
 This is similar to the OpenBSD minherit syscall with MAP_INHERIT_ZERO:

	https://man.openbsd.org/minherit.2
