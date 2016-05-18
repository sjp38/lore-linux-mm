Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 228896B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 13:56:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 77so108818295pfz.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 10:56:51 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id ag3si13449702pad.44.2016.05.18.10.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 10:56:50 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id b66so100242pfb.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 10:56:49 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [RFC v1 0/2] mm: SLUB Freelist randomization
Date: Wed, 18 May 2016 10:56:13 -0700
Message-Id: <1463594175-111929-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Pranith Kumar <bobby.prani@gmail.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Woodhouse <David.Woodhouse@intel.com>, Thomas Garnier <thgarnie@google.com>, Petr Mladek <pmladek@suse.com>, Kees Cook <keescook@chromium.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, kernel-hardening@lists.openwall.com

This is RFC v1 for the SLUB Freelist randomization.

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
 - Randomize the Freelist used in the SLUB allocator.
 - Ensure good performance to encourage usage.
 - Get best entropy in early boot stage.

***Parts:
 - 01/02 Reorganize the SLAB Freelist randomization to share elements
   with the SLUB implementation.
 - 02/02 The SLUB Freelist randomization implementation. Similar approach
   than the SLAB but tailored to the singled freelist used in SLUB.

***Performance data (no major changes):

slab_test, before:

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 67 cycles kfree -> 101 cycles
10000 times kmalloc(16) -> 68 cycles kfree -> 109 cycles
10000 times kmalloc(32) -> 76 cycles kfree -> 119 cycles
10000 times kmalloc(64) -> 88 cycles kfree -> 114 cycles
10000 times kmalloc(128) -> 100 cycles kfree -> 122 cycles
10000 times kmalloc(256) -> 128 cycles kfree -> 149 cycles
10000 times kmalloc(512) -> 108 cycles kfree -> 152 cycles
10000 times kmalloc(1024) -> 112 cycles kfree -> 158 cycles
10000 times kmalloc(2048) -> 161 cycles kfree -> 208 cycles
10000 times kmalloc(4096) -> 231 cycles kfree -> 239 cycles
10000 times kmalloc(8192) -> 341 cycles kfree -> 270 cycles
10000 times kmalloc(16384) -> 481 cycles kfree -> 323 cycles
2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 90 cycles
10000 times kmalloc(16)/kfree -> 89 cycles
10000 times kmalloc(32)/kfree -> 88 cycles
10000 times kmalloc(64)/kfree -> 88 cycles
10000 times kmalloc(128)/kfree -> 94 cycles
10000 times kmalloc(256)/kfree -> 87 cycles
10000 times kmalloc(512)/kfree -> 91 cycles
10000 times kmalloc(1024)/kfree -> 90 cycles
10000 times kmalloc(2048)/kfree -> 90 cycles
10000 times kmalloc(4096)/kfree -> 90 cycles
10000 times kmalloc(8192)/kfree -> 90 cycles
10000 times kmalloc(16384)/kfree -> 642 cycles

After:

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 60 cycles kfree -> 74 cycles
10000 times kmalloc(16) -> 63 cycles kfree -> 78 cycles
10000 times kmalloc(32) -> 72 cycles kfree -> 85 cycles
10000 times kmalloc(64) -> 91 cycles kfree -> 99 cycles
10000 times kmalloc(128) -> 112 cycles kfree -> 109 cycles
10000 times kmalloc(256) -> 127 cycles kfree -> 120 cycles
10000 times kmalloc(512) -> 125 cycles kfree -> 121 cycles
10000 times kmalloc(1024) -> 128 cycles kfree -> 125 cycles
10000 times kmalloc(2048) -> 167 cycles kfree -> 141 cycles
10000 times kmalloc(4096) -> 249 cycles kfree -> 174 cycles
10000 times kmalloc(8192) -> 377 cycles kfree -> 225 cycles
10000 times kmalloc(16384) -> 459 cycles kfree -> 247 cycles
2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 72 cycles
10000 times kmalloc(16)/kfree -> 74 cycles
10000 times kmalloc(32)/kfree -> 71 cycles
10000 times kmalloc(64)/kfree -> 75 cycles
10000 times kmalloc(128)/kfree -> 71 cycles
10000 times kmalloc(256)/kfree -> 72 cycles
10000 times kmalloc(512)/kfree -> 72 cycles
10000 times kmalloc(1024)/kfree -> 73 cycles
10000 times kmalloc(2048)/kfree -> 73 cycles
10000 times kmalloc(4096)/kfree -> 72 cycles
10000 times kmalloc(8192)/kfree -> 72 cycles
10000 times kmalloc(16384)/kfree -> 546 cycles

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
