Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 610386B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 17:28:34 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b130so4983874oii.4
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 14:28:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h84si1187085oif.273.2017.08.11.14.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 14:28:33 -0700 (PDT)
From: riel@redhat.com
Subject: [PATCH v4 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Date: Fri, 11 Aug 2017 17:28:27 -0400
Message-Id: <20170811212829.29186-1-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mhocko@kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org, torvalds@linux-foundation.org, willy@infradead.org

v4: don't clone anon vma chains, move all fork logic to dup_mmap
v3: simplify implementation, limit to anonymous, private mappings
v2: fix kbuild warnings

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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
