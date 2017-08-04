Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9754C280396
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 15:07:33 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d136so12517434qkg.11
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 12:07:33 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id f89si2044394qtb.408.2017.08.04.12.07.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 12:07:32 -0700 (PDT)
From: riel@redhat.com
Subject: [PATCH 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Date: Fri,  4 Aug 2017 15:07:28 -0400
Message-Id: <20170804190730.17858-1-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org

[resend because half the recipients got dropped due to IPv6 firewall issues]

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
