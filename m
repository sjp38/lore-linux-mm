Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBAE06B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 18:07:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f75so782939wmf.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 15:07:04 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id m198si393486wmd.60.2016.05.23.15.07.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 15:07:03 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id f75so532421wmf.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 15:07:03 -0700 (PDT)
Date: Tue, 24 May 2016 00:14:05 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: [PATCH v1 0/3] Introduce the latent_entropy gcc plugin
Message-Id: <20160524001405.3e6abd1d5a63a871cc366cff@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: pageexec@freemail.hu, spender@grsecurity.net, mmarek@suse.com, keescook@chromium.org, linux-kernel@vger.kernel.org, yamada.masahiro@socionext.com, linux-kbuild@vger.kernel.org, tytso@mit.edu, akpm@linux-foundation.org, linux-mm@kvack.org, axboe@kernel.dk, viro@zeniv.linux.org.uk, paulmck@linux.vnet.ibm.com, mingo@redhat.com, tglx@linutronix.de, bart.vanassche@sandisk.com, davem@davemloft.net

I would like to introduce the latent_entropy gcc plugin. This plugin mitigates
the problem of the kernel having too little entropy during and after boot
for generating crypto keys.

This plugin mixes random values into the latent_entropy global variable
in functions marked by the __latent_entropy attribute.
The value of this global variable is added to the kernel entropy pool
to increase the entropy.

It is a CII project supported by the Linux Foundation.

The latent_entropy plugin was ported from grsecurity/PaX originally written by
the PaX Team. You can find more about the plugin here:
https://grsecurity.net/pipermail/grsecurity/2012-July/001093.html

The plugin supports all gcc version from 4.5 to 6.0.

I do some changes above the PaX version. The important one is mixing
the stack pointer into the global variable too.
You can find more about the changes here:
https://github.com/ephox-gcc-plugins/latent_entropy

This patch set is based on the "Introduce GCC plugin infrastructure" patch set (v9).

Emese Revfy (3):
 Add the latent_entropy gcc plugin
 Mark functions with the latent_entropy attribute
 Add the extra_latent_entropy kernel parameter

---
 Documentation/kernel-parameters.txt         |   5 +
 arch/Kconfig                                |  22 ++
 arch/powerpc/kernel/Makefile                |   8 +-
 block/blk-softirq.c                         |   2 +-
 drivers/char/random.c                       |   6 +-
 fs/namespace.c                              |   2 +-
 include/linux/compiler-gcc.h                |   5 +
 include/linux/compiler.h                    |   4 +
 include/linux/fdtable.h                     |   2 +-
 include/linux/genhd.h                       |   2 +-
 include/linux/init.h                        |  10 +-
 include/linux/random.h                      |  12 +-
 init/main.c                                 |   1 +
 kernel/fork.c                               |   5 +-
 kernel/rcu/tiny.c                           |   2 +-
 kernel/rcu/tree.c                           |   2 +-
 kernel/sched/fair.c                         |   2 +-
 kernel/softirq.c                            |   4 +-
 kernel/time/timer.c                         |   2 +-
 lib/irq_poll.c                              |   2 +-
 lib/random32.c                              |   2 +-
 mm/page_alloc.c                             |  28 ++
 net/core/dev.c                              |   4 +-
 scripts/Makefile.gcc-plugins                |  10 +-
 scripts/gcc-plugins/Makefile                |   1 +
 scripts/gcc-plugins/latent_entropy_plugin.c | 446 ++++++++++++++++++++++++++++
 26 files changed, 562 insertions(+), 29 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
