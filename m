Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 823466B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 17:15:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so52069082pfz.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 14:15:46 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id 192si1256125pfw.92.2016.05.24.14.15.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 14:15:45 -0700 (PDT)
Received: by mail-pa0-x232.google.com with SMTP id qo8so10245075pab.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 14:15:45 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [RFC v2 0/2] mm: SLUB Freelist randomization
Date: Tue, 24 May 2016 14:15:21 -0700
Message-Id: <1464124523-43051-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Pranith Kumar <bobby.prani@gmail.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Woodhouse <David.Woodhouse@intel.com>, Thomas Garnier <thgarnie@google.com>, Petr Mladek <pmladek@suse.com>, Kees Cook <keescook@chromium.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, kernel-hardening@lists.openwall.com

This is RFC v2 for the SLUB Freelist randomization. The patch is now based
on the Linux master branch (as the based SLAB patch was merged).

Changes since RFC v1:
 - Redone slab_test testing to decide best entropy approach on new page
   creation.
 - Moved to use get_random_int as best approach to still use hardware
   randomization when available but lower cost when not available.
 - Update SLAB implementation to use get_random_long and get_random_int
   on refactoring.
 - Updated testing that highlight 3-4% impact on slab_test.

Based on 0e01df100b6bf22a1de61b66657502a6454153c5.

***Background:
This proposal follows the previous SLAB Freelist patch submitted to next.
It resuses parts of previous implementation and keep a similar approach.

The kernel heap allocators are using a sequential freelist making their
allocation predictable. This predictability makes kernel heap overflow
easier to exploit. An attacker can careful prepare the kernel heap to
control the following chunk overflowed.

For example these attacks exploit the predictability of the heap:
 - Linux Kernel CAN SLUB overflow (https://goo.gl/oMNWkU)
 - Exploiting Linux Kernel Heap corruptions (http://goo.gl/EXLn95)

***Problems that needed solving:
 - Randomize the Freelist (singled linked) used in the SLUB allocator.
 - Ensure good performance to encourage usage.
 - Get best entropy in early boot stage.

***Parts:
 - 01/02 Reorganize the SLAB Freelist randomization to share elements
   with the SLUB implementation.
 - 02/02 The SLUB Freelist randomization implementation. Similar approach
   than the SLAB but tailored to the singled freelist used in SLUB.

***Performance data:

slab_test impact is between 3% to 4% on average:

Before:

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
100000 times kmalloc(8) -> 49 cycles kfree -> 77 cycles
100000 times kmalloc(16) -> 51 cycles kfree -> 79 cycles
100000 times kmalloc(32) -> 53 cycles kfree -> 83 cycles
100000 times kmalloc(64) -> 62 cycles kfree -> 90 cycles
100000 times kmalloc(128) -> 81 cycles kfree -> 97 cycles
100000 times kmalloc(256) -> 98 cycles kfree -> 121 cycles
100000 times kmalloc(512) -> 95 cycles kfree -> 122 cycles
100000 times kmalloc(1024) -> 96 cycles kfree -> 126 cycles
100000 times kmalloc(2048) -> 115 cycles kfree -> 140 cycles
100000 times kmalloc(4096) -> 149 cycles kfree -> 171 cycles
2. Kmalloc: alloc/free test
100000 times kmalloc(8)/kfree -> 70 cycles
100000 times kmalloc(16)/kfree -> 70 cycles
100000 times kmalloc(32)/kfree -> 70 cycles
100000 times kmalloc(64)/kfree -> 70 cycles
100000 times kmalloc(128)/kfree -> 70 cycles
100000 times kmalloc(256)/kfree -> 69 cycles
100000 times kmalloc(512)/kfree -> 70 cycles
100000 times kmalloc(1024)/kfree -> 73 cycles
100000 times kmalloc(2048)/kfree -> 72 cycles
100000 times kmalloc(4096)/kfree -> 71 cycles

After:

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
100000 times kmalloc(8) -> 57 cycles kfree -> 78 cycles
100000 times kmalloc(16) -> 61 cycles kfree -> 81 cycles
100000 times kmalloc(32) -> 76 cycles kfree -> 93 cycles
100000 times kmalloc(64) -> 83 cycles kfree -> 94 cycles
100000 times kmalloc(128) -> 106 cycles kfree -> 107 cycles
100000 times kmalloc(256) -> 118 cycles kfree -> 117 cycles
100000 times kmalloc(512) -> 114 cycles kfree -> 116 cycles
100000 times kmalloc(1024) -> 115 cycles kfree -> 118 cycles
100000 times kmalloc(2048) -> 147 cycles kfree -> 131 cycles
100000 times kmalloc(4096) -> 214 cycles kfree -> 161 cycles
2. Kmalloc: alloc/free test
100000 times kmalloc(8)/kfree -> 66 cycles
100000 times kmalloc(16)/kfree -> 66 cycles
100000 times kmalloc(32)/kfree -> 66 cycles
100000 times kmalloc(64)/kfree -> 66 cycles
100000 times kmalloc(128)/kfree -> 65 cycles
100000 times kmalloc(256)/kfree -> 67 cycles
100000 times kmalloc(512)/kfree -> 67 cycles
100000 times kmalloc(1024)/kfree -> 64 cycles
100000 times kmalloc(2048)/kfree -> 67 cycles
100000 times kmalloc(4096)/kfree -> 67 cycles

Kernbench, before:

Average Optimal load -j 12 Run (std deviation):
Elapsed Time 101.873 (1.16069)
User Time 1045.22 (1.60447)
System Time 88.969 (0.559195)
Percent CPU 1112.9 (13.8279)
Context Switches 189140 (2282.15)
Sleeps 99008.6 (768.091)

After:

Average Optimal load -j 12 Run (std deviation):
Elapsed Time 102.47 (0.562732)
User Time 1045.3 (1.34263)
System Time 88.311 (0.342554)
Percent CPU 1105.8 (6.49444)
Context Switches 189081 (2355.78)
Sleeps 99231.5 (800.358)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
