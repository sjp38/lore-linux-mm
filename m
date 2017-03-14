Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0E56B038E
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 04:26:26 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 77so340540535pgc.5
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 01:26:26 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id t17si14050601pgi.197.2017.03.14.01.26.19
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 01:26:20 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v6 07/15] lockdep: Avoid adding redundant direct links of crosslocks
Date: Tue, 14 Mar 2017 17:18:54 +0900
Message-ID: <1489479542-27030-8-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On my machine (QEMU x86_64, 4 core, mem 512M, enable-kvm), this patch
does not make different between before/after in lockdep_stats. So this
patch looks unnecessary. However, I wonder if it's still true in other
systems. Could anybody check lockdep_stats in your system?

Before (apply all crossrelease patches except this patch):

 lock-classes:                          988 [max: 8191]
 direct dependencies:                  5814 [max: 32768]
 indirect dependencies:               18915
 all direct dependencies:            119802
 dependency chains:                    6350 [max: 65536]
 dependency chain hlocks:             20771 [max: 327680]
 in-hardirq chains:                      52
 in-softirq chains:                     361
 in-process chains:                    5937
 stack-trace entries:                 80396 [max: 524288]
 combined max dependencies:       113926468
 hardirq-safe locks:                     42
 hardirq-unsafe locks:                  644
 softirq-safe locks:                    129
 softirq-unsafe locks:                  561
 irq-safe locks:                        135
 irq-unsafe locks:                      644
 hardirq-read-safe locks:                 2
 hardirq-read-unsafe locks:             127
 softirq-read-safe locks:                11
 softirq-read-unsafe locks:             119
 irq-read-safe locks:                    12
 irq-read-unsafe locks:                 127
 uncategorized locks:                   165
 unused locks:                            1
 max locking depth:                      14
 max bfs queue depth:                   168
 debug_locks:                             1

After (apply all crossrelease patches without exception):

 lock-classes:                          980 [max: 8191]
 direct dependencies:                  5604 [max: 32768]
 indirect dependencies:               18517
 all direct dependencies:            112620
 dependency chains:                    6215 [max: 65536]
 dependency chain hlocks:             20401 [max: 327680]
 in-hardirq chains:                      51
 in-softirq chains:                     298
 in-process chains:                    5866
 stack-trace entries:                 78707 [max: 524288]
 combined max dependencies:        91220116
 hardirq-safe locks:                     42
 hardirq-unsafe locks:                  637
 softirq-safe locks:                    117
 softirq-unsafe locks:                  561
 irq-safe locks:                        126
 irq-unsafe locks:                      637
 hardirq-read-safe locks:                 2
 hardirq-read-unsafe locks:             127
 softirq-read-safe locks:                10
 softirq-read-unsafe locks:             119
 irq-read-safe locks:                    11
 irq-read-unsafe locks:                 127
 uncategorized locks:                   165
 unused locks:                            1
 max locking depth:                      15
 max bfs queue depth:                   168
 debug_locks:                             1

-----8<-----
