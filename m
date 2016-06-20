Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 311D96B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 14:32:37 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so29309883lfg.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 11:32:37 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id k2si30911644wjf.190.2016.06.20.11.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 11:32:31 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id a66so10990693wme.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 11:32:31 -0700 (PDT)
Date: Mon, 20 Jun 2016 20:39:10 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: [PATCH v4 0/4] Introduce the latent_entropy gcc plugin
Message-Id: <20160620203910.a8b6b5b10d18f24661916e7b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: pageexec@freemail.hu, spender@grsecurity.net, mmarek@suse.com, keescook@chromium.org, linux-kernel@vger.kernel.org, yamada.masahiro@socionext.com, linux-kbuild@vger.kernel.org, tytso@mit.edu, akpm@linux-foundation.org, linux-mm@kvack.org, axboe@kernel.dk, viro@zeniv.linux.org.uk, paulmck@linux.vnet.ibm.com, mingo@redhat.com, tglx@linutronix.de, bart.vanassche@sandisk.com, davem@davemloft.net

I would like to introduce the latent_entropy gcc plugin. This plugin
mitigates the problem of the kernel having too little entropy during and
after boot for generating crypto keys.

This plugin mixes random values into the latent_entropy global variable
in functions marked by the __latent_entropy attribute.
The value of this global variable is added to the kernel entropy pool
to increase the entropy.

It is a CII project supported by the Linux Foundation.

The latent_entropy plugin was ported from grsecurity/PaX originally written
by the PaX Team. You can find more about the plugin here:
https://grsecurity.net/pipermail/grsecurity/2012-July/001093.html

The plugin supports all gcc version from 4.5 to 6.0.

I do some changes above the PaX version. The important one is mixing
the stack pointer into the global variable too.
You can find more about the changes here:
https://github.com/ephox-gcc-plugins/latent_entropy

This patch set is based on the "Introduce GCC plugin infrastructure"
patch set (git/mmarek/kbuild.git#kbuild HEAD: 543c37cb165049c3be).

Emese Revfy (4):
 Add support for passing gcc plugin arguments
 Add the latent_entropy gcc plugin
 Mark functions with the latent_entropy attribute
 Add the extra_latent_entropy kernel parameter


Changes from v3:
  * Fix disabling latent_entropy on some powerpc files
    (Reported-by: Kees Cook <keescook@chromium.org>)
  * Truncate the lines into <= 80 columns to follow the kernel coding style
    (Suggested-by: Kees Cook <keescook@chromium.org>)

Changes from v2:
  * Moved the passing of gcc plugin arguments into a separate patch
    (Suggested-by: Kees Cook <keescook@chromium.org>)
  * Mix the global entropy variable with the stack pointer
    (latent_entropy_plugin.c)
  * Handle tail calls (latent_entropy_plugin.c)
  * Fix some indentation related warnings suggested by checkpatch.pl
    (latent_entropy_plugin.c)
  * Commented some latent_entropy plugin code
    (Suggested-by: Kees Cook <keescook@chromium.org>)

Changes from v1:
  * Remove unnecessary ifdefs
    (Suggested-by: Kees Cook <keescook@chromium.org>)
  * Separate the two definitions of add_latent_entropy()
    (Suggested-by: Kees Cook <keescook@chromium.org>)
  * Removed unnecessary global variable (latent_entropy_plugin.c)
  * About the latent_entropy gcc attribute (latent_entropy_plugin.c)
  * Measure the boot time performance impact of the latent_entropy plugin
    (arch/Kconfig)

---
 Documentation/kernel-parameters.txt         |   5 +
 arch/Kconfig                                |  23 +
 arch/powerpc/kernel/Makefile                |   4 +
 block/blk-softirq.c                         |   2 +-
 drivers/char/random.c                       |   6 +-
 fs/namespace.c                              |   1 +
 include/linux/compiler-gcc.h                |   7 +
 include/linux/compiler.h                    |   4 +
 include/linux/fdtable.h                     |   2 +-
 include/linux/genhd.h                       |   2 +-
 include/linux/init.h                        |   5 +-
 include/linux/random.h                      |  14 +-
 init/main.c                                 |   1 +
 kernel/fork.c                               |   7 +-
 kernel/rcu/tiny.c                           |   2 +-
 kernel/rcu/tree.c                           |   2 +-
 kernel/sched/fair.c                         |   2 +-
 kernel/softirq.c                            |   4 +-
 kernel/time/timer.c                         |   2 +-
 lib/irq_poll.c                              |   2 +-
 lib/random32.c                              |   2 +-
 mm/page_alloc.c                             |  31 ++
 net/core/dev.c                              |   4 +-
 scripts/Makefile.gcc-plugins                |  10 +-
 scripts/gcc-plugins/Makefile                |   1 +
 scripts/gcc-plugins/latent_entropy_plugin.c | 639 ++++++++++++++++++++++++++++
 26 files changed, 760 insertions(+), 24 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
