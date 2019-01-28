Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2108F8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 04:18:31 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e12so6336445edd.16
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 01:18:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d21si2038360edz.59.2019.01.28.01.18.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 01:18:29 -0800 (PST)
Subject: Re: [linux-next] kcompactd0 stuck in a CPU-burning loop
References: <20190128085747.GA14454@jagdpanzerIV>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5e98c5e9-9a8a-70db-c991-a5ca9c501e83@suse.cz>
Date: Mon, 28 Jan 2019 10:18:27 +0100
MIME-Version: 1.0
In-Reply-To: <20190128085747.GA14454@jagdpanzerIV>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On 1/28/19 9:57 AM, Sergey Senozhatsky wrote:
> Hello,
> 
> next-20190125
> 
> kcompactd0 is spinning on something, burning CPUs in the meantime:

Hi, could you check/add this to the earlier thread? Thanks.

https://lore.kernel.org/lkml/20190126200005.GB27513@amd/T/#u

> 
>  %CPU         TIME+      COMMAND
>  100.0   0.0  34:04.20 R [kcompactd0]
> 
> Not sure I know how to reproduce it; so am probably not going to
> be a very helpful tester.
> 
> I tried to ftrace kcompactd0 PID, and I see the same path all over
> the tracing file:
> 
>  2)   0.119 us    |    unlock_page();
>  2)   0.109 us    |    unlock_page();
>  2)   0.096 us    |    compaction_free();
>  2)   0.104 us    |    ___might_sleep();
>  2)   0.121 us    |    compaction_alloc();
>  2)   0.111 us    |    page_mapped();
>  2)   0.105 us    |    page_mapped();
>  2)               |    move_to_new_page() {
>  2)   0.102 us    |      page_mapping();
>  2)               |      buffer_migrate_page_norefs() {
>  2)               |        __buffer_migrate_page() {
>  2)               |          expected_page_refs() {
>  2)   0.118 us    |            page_mapping();
>  2)   0.321 us    |          }
>  2)               |          __might_sleep() {
>  2)   0.122 us    |            ___might_sleep();
>  2)   0.332 us    |          }
>  2)               |          _raw_spin_lock() {
>  2)   0.115 us    |            preempt_count_add();
>  2)   0.321 us    |          }
>  2)               |          _raw_spin_unlock() {
>  2)   0.114 us    |            preempt_count_sub();
>  2)   0.321 us    |          }
>  2)               |          invalidate_bh_lrus() {
>  2)               |            on_each_cpu_cond() {
>  2)               |              on_each_cpu_cond_mask() {
>  2)               |                __might_sleep() {
>  2)   0.114 us    |                  ___might_sleep();
>  2)   0.316 us    |                }
>  2)   0.109 us    |                preempt_count_add();
>  2)   0.128 us    |                has_bh_in_lru();
>  2)   0.105 us    |                has_bh_in_lru();
>  2)   0.124 us    |                has_bh_in_lru();
>  2)   0.103 us    |                has_bh_in_lru();
>  2)   0.125 us    |                has_bh_in_lru();
>  2)   0.105 us    |                has_bh_in_lru();
>  2)   0.123 us    |                has_bh_in_lru();
>  2)   0.107 us    |                has_bh_in_lru();
>  2)               |                on_each_cpu_mask() {
>  2)   0.104 us    |                  preempt_count_add();
>  2)   0.110 us    |                  smp_call_function_many();
>  2)   0.105 us    |                  preempt_count_sub();
>  2)   0.764 us    |                }
>  2)   0.116 us    |                preempt_count_sub();
>  2)   3.676 us    |              }
>  2)   3.889 us    |            }
>  2)   4.087 us    |          }
>  2)               |          _raw_spin_lock() {
>  2)   0.112 us    |            preempt_count_add();
>  2)   0.315 us    |          }
>  2)               |          _raw_spin_unlock() {
>  2)   0.108 us    |            preempt_count_sub();
>  2)   0.309 us    |          }
>  2)               |          unlock_buffer() {
>  2)               |            wake_up_bit() {
>  2)   0.118 us    |              __wake_up_bit();
>  2)   0.317 us    |            }
>  2)   0.513 us    |          }
>  2)   7.440 us    |        }
>  2)   7.643 us    |      }
>  2)   8.070 us    |    }
> 
> 
> PG migration fails a lot:
> 
> pgmigrate_success 111063
> pgmigrate_fail 269841559
> compact_migrate_scanned 536253365
> compact_free_scanned 360889
> compact_isolated 270072733
> compact_stall 0
> compact_fail 0
> compact_success 0
> compact_daemon_wake 56
> compact_daemon_migrate_scanned 536253365
> compact_daemon_free_scanned 360889
> 
> Let me know if I can help with anything else. I'll keep the the box alive
> for a while, but will have to power it off eventually.
> 
> 	-ss
> 
