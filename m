Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 229956B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 16:23:12 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id w63so330052722oiw.4
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:23:12 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id p7si26182357oif.168.2016.11.29.13.23.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 13:23:11 -0800 (PST)
Date: Tue, 29 Nov 2016 13:23:08 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: next: Commit 'mm: Prevent __alloc_pages_nodemask() RCU CPU stall
 ...' causing hang on sparc32 qemu
Message-ID: <20161129212308.GA12447@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, sparclinux@vger.kernel.org, davem@davemloft.net

Hi Paul,

most of my qemu tests for sparc32 targets started to fail in next-20161129.
The problem is only seen in SMP builds; non-SMP builds are fine.
Bisect points to commit 2d66cccd73436 ("mm: Prevent __alloc_pages_nodemask()
RCU CPU stall warnings"); reverting that commit fixes the problem.

Test scripts are available at:
	https://github.com/groeck/linux-build-test/tree/master/rootfs/sparc
Test results are at:
	https://github.com/groeck/linux-build-test/tree/master/rootfs/sparc

Bisect log is attached.

Please let me know if there is anything I can do to help tracking down the
problem.

Thanks,
Guenter

---
# bad: [4030ddad30d69fa041f57a2b742d69889b91e93b] Add linux-next specific files for 20161129
# good: [e5517c2a5a49ed5e99047008629f1cd60246ea0e] Linux 4.9-rc7
git bisect start 'HEAD' 'v4.9-rc7'
# good: [d129495078c343c047171844bfa9c3f81d69125c] next-20161128/crypto
git bisect good d129495078c343c047171844bfa9c3f81d69125c
# good: [64c09c8edb6b4ea872538acd144a72434ae20f07] Merge remote-tracking branch 'tip/auto-latest'
git bisect good 64c09c8edb6b4ea872538acd144a72434ae20f07
# good: [2d2139c5c746ec61024fdfa9c36e4e034bb18e59] Merge tag 'iio-for-4.10d' of git://git.kernel.org/pub/scm/linux/kernel/git/jic23/iio into staging-next
git bisect good 2d2139c5c746ec61024fdfa9c36e4e034bb18e59
# bad: [c927024badfb7d3835bed3c386011c9e2b5b28b8] Merge remote-tracking branch 'char-misc/char-misc-next'
git bisect bad c927024badfb7d3835bed3c386011c9e2b5b28b8
# bad: [72910000a4180a2f51f4d29308da6138da8e7229] Merge remote-tracking branch 'tty/tty-next'
git bisect bad 72910000a4180a2f51f4d29308da6138da8e7229
# bad: [cda711541e3b7a101f3e1ebe9f17e05c144976bd] Merge remote-tracking branch 'kvm-ppc-paulus/kvm-ppc-next'
git bisect bad cda711541e3b7a101f3e1ebe9f17e05c144976bd
# bad: [22fa38d8da8ca508c5630b6499acc088dde1dc89] Merge remote-tracking branch 'rcu/rcu/next'
git bisect bad 22fa38d8da8ca508c5630b6499acc088dde1dc89
# good: [0f5bacb434cae111078b89df1acaea738c712251] Merge remote-tracking branch 'irqchip/irqchip/for-next'
git bisect good 0f5bacb434cae111078b89df1acaea738c712251
# good: [80c099e11c191b0e3c1c7dac2d460cb12d0ea3c7] mm: Prevent shrink_node() RCU CPU stall warnings
git bisect good 80c099e11c191b0e3c1c7dac2d460cb12d0ea3c7
# good: [60c1afbf10528f646a6fcae1a2c404d216e594d5] selftests: ftrace: Add a testcase for function filter glob match
git bisect good 60c1afbf10528f646a6fcae1a2c404d216e594d5
# good: [9b5e3ff6b9baa77548c6cb832780162055733c67] stm dummy: Mark dummy_stm_packet() with notrace
git bisect good 9b5e3ff6b9baa77548c6cb832780162055733c67
# bad: [2d66cccd73436ac9985a08e5c2f82e4344f72264] mm: Prevent __alloc_pages_nodemask() RCU CPU stall warnings
git bisect bad 2d66cccd73436ac9985a08e5c2f82e4344f72264
# good: [34c53f5cd399801b083047cc9cf2ad3ed17c3144] mm: Prevent shrink_node_memcg() RCU CPU stall warnings
git bisect good 34c53f5cd399801b083047cc9cf2ad3ed17c3144
# first bad commit: [2d66cccd73436ac9985a08e5c2f82e4344f72264] mm: Prevent __alloc_pages_nodemask() RCU CPU stall warnings

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
