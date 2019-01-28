Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB6E08E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 03:57:53 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id s71so13531153pfi.22
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 00:57:53 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i10sor48681134pgn.17.2019.01.28.00.57.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 00:57:52 -0800 (PST)
Date: Mon, 28 Jan 2019 17:57:47 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [linux-next] kcompactd0 stuck in a CPU-burning loop
Message-ID: <20190128085747.GA14454@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

next-20190125

kcompactd0 is spinning on something, burning CPUs in the meantime:

 %CPU         TIME+      COMMAND
 100.0   0.0  34:04.20 R [kcompactd0]

Not sure I know how to reproduce it; so am probably not going to
be a very helpful tester.

I tried to ftrace kcompactd0 PID, and I see the same path all over
the tracing file:

 2)   0.119 us    |    unlock_page();
 2)   0.109 us    |    unlock_page();
 2)   0.096 us    |    compaction_free();
 2)   0.104 us    |    ___might_sleep();
 2)   0.121 us    |    compaction_alloc();
 2)   0.111 us    |    page_mapped();
 2)   0.105 us    |    page_mapped();
 2)               |    move_to_new_page() {
 2)   0.102 us    |      page_mapping();
 2)               |      buffer_migrate_page_norefs() {
 2)               |        __buffer_migrate_page() {
 2)               |          expected_page_refs() {
 2)   0.118 us    |            page_mapping();
 2)   0.321 us    |          }
 2)               |          __might_sleep() {
 2)   0.122 us    |            ___might_sleep();
 2)   0.332 us    |          }
 2)               |          _raw_spin_lock() {
 2)   0.115 us    |            preempt_count_add();
 2)   0.321 us    |          }
 2)               |          _raw_spin_unlock() {
 2)   0.114 us    |            preempt_count_sub();
 2)   0.321 us    |          }
 2)               |          invalidate_bh_lrus() {
 2)               |            on_each_cpu_cond() {
 2)               |              on_each_cpu_cond_mask() {
 2)               |                __might_sleep() {
 2)   0.114 us    |                  ___might_sleep();
 2)   0.316 us    |                }
 2)   0.109 us    |                preempt_count_add();
 2)   0.128 us    |                has_bh_in_lru();
 2)   0.105 us    |                has_bh_in_lru();
 2)   0.124 us    |                has_bh_in_lru();
 2)   0.103 us    |                has_bh_in_lru();
 2)   0.125 us    |                has_bh_in_lru();
 2)   0.105 us    |                has_bh_in_lru();
 2)   0.123 us    |                has_bh_in_lru();
 2)   0.107 us    |                has_bh_in_lru();
 2)               |                on_each_cpu_mask() {
 2)   0.104 us    |                  preempt_count_add();
 2)   0.110 us    |                  smp_call_function_many();
 2)   0.105 us    |                  preempt_count_sub();
 2)   0.764 us    |                }
 2)   0.116 us    |                preempt_count_sub();
 2)   3.676 us    |              }
 2)   3.889 us    |            }
 2)   4.087 us    |          }
 2)               |          _raw_spin_lock() {
 2)   0.112 us    |            preempt_count_add();
 2)   0.315 us    |          }
 2)               |          _raw_spin_unlock() {
 2)   0.108 us    |            preempt_count_sub();
 2)   0.309 us    |          }
 2)               |          unlock_buffer() {
 2)               |            wake_up_bit() {
 2)   0.118 us    |              __wake_up_bit();
 2)   0.317 us    |            }
 2)   0.513 us    |          }
 2)   7.440 us    |        }
 2)   7.643 us    |      }
 2)   8.070 us    |    }


PG migration fails a lot:

pgmigrate_success 111063
pgmigrate_fail 269841559
compact_migrate_scanned 536253365
compact_free_scanned 360889
compact_isolated 270072733
compact_stall 0
compact_fail 0
compact_success 0
compact_daemon_wake 56
compact_daemon_migrate_scanned 536253365
compact_daemon_free_scanned 360889

Let me know if I can help with anything else. I'll keep the the box alive
for a while, but will have to power it off eventually.

	-ss
