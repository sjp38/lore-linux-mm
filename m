Date: Fri, 22 Sep 2000 10:54:36 +0200 (CEST)
From: Molnar Ingo <mingo@debella.aszi.sztaki.hu>
Subject: test9-pre5+t9p2-vmpatch VM deadlock during write-intensive workload
In-Reply-To: <Pine.LNX.4.21.0009220538500.27435-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0009221046300.12532-100000@debella.aszi.sztaki.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

i'm still getting VM related lockups during heavy write load, in
test9-pre5 + your 2.4.0-t9p2-vmpatch (which i understand as being your
last VM related fix-patch, correct?). Here is a histogram of such a
lockup:

      1 Trace; 4010a720 <__switch_to+38/e8>
      5 Trace; 4010a74b <__switch_to+63/e8>
     13 Trace; 4010abc4 <poll_idle+10/2c>
    819 Trace; 4010abca <poll_idle+16/2c>
   1806 Trace; 4010abce <poll_idle+1a/2c>
      1 Trace; 4010abd0 <poll_idle+1c/2c>
      2 Trace; 4011af51 <schedule+45/884>
      1 Trace; 4011af77 <schedule+6b/884>
      1 Trace; 4011b010 <schedule+104/884>
      3 Trace; 4011b018 <schedule+10c/884>
      1 Trace; 4011b02d <schedule+121/884>
      1 Trace; 4011b051 <schedule+145/884>
      1 Trace; 4011b056 <schedule+14a/884>
      2 Trace; 4011b05c <schedule+150/884>
      3 Trace; 4011b06d <schedule+161/884>
      4 Trace; 4011b076 <schedule+16a/884>
    537 Trace; 4011b2bb <schedule+3af/884>
      2 Trace; 4011b2c6 <schedule+3ba/884>
      1 Trace; 4011b2c9 <schedule+3bd/884>
      4 Trace; 4011b2d5 <schedule+3c9/884>
     31 Trace; 4011b31a <schedule+40e/884>
      1 Trace; 4011b31d <schedule+411/884>
      1 Trace; 4011b32a <schedule+41e/884>
      1 Trace; 4011b346 <schedule+43a/884>
     11 Trace; 4011b378 <schedule+46c/884>
      2 Trace; 4011b381 <schedule+475/884>
      5 Trace; 4011b3f8 <schedule+4ec/884>
     17 Trace; 4011b404 <schedule+4f8/884>
      9 Trace; 4011b43f <schedule+533/884>
      1 Trace; 4011b450 <schedule+544/884>
      1 Trace; 4011b457 <schedule+54b/884>
      2 Trace; 4011b48c <schedule+580/884>
      1 Trace; 4011b49c <schedule+590/884>
    428 Trace; 4011b4cd <schedule+5c1/884>
      6 Trace; 4011b4f7 <schedule+5eb/884>
      4 Trace; 4011b500 <schedule+5f4/884>
      2 Trace; 4011b509 <schedule+5fd/884>
      1 Trace; 4011b560 <schedule+654/884>
      1 Trace; 4011b809 <__wake_up+79/3f0>
      1 Trace; 4011b81b <__wake_up+8b/3f0>
      8 Trace; 4011b81e <__wake_up+8e/3f0>
    310 Trace; 4011ba90 <__wake_up+300/3f0>
      1 Trace; 4011bb7b <__wake_up+3eb/3f0>
      2 Trace; 4011c32b <interruptible_sleep_on_timeout+283/290>
    244 Trace; 4011d40e <add_wait_queue+14e/154>
      1 Trace; 4011d411 <add_wait_queue+151/154>
      1 Trace; 4011d56c <remove_wait_queue+8/d0>
    618 Trace; 4011d62e <remove_wait_queue+ca/d0>
      2 Trace; 40122f28 <do_softirq+48/88>
      2 Trace; 40126c3c <del_timer_sync+6c/78>
      1 Trace; 401377ab <wakeup_kswapd+7/254>
      1 Trace; 401377c8 <wakeup_kswapd+24/254>
      5 Trace; 401377cc <wakeup_kswapd+28/254>
     15 Trace; 401377d4 <wakeup_kswapd+30/254>
     11 Trace; 401377dc <wakeup_kswapd+38/254>
      2 Trace; 401377e0 <wakeup_kswapd+3c/254>
      6 Trace; 401377ee <wakeup_kswapd+4a/254>
      8 Trace; 4013783c <wakeup_kswapd+98/254>
      1 Trace; 401378f8 <wakeup_kswapd+154/254>
      3 Trace; 4013792d <wakeup_kswapd+189/254>
      2 Trace; 401379af <wakeup_kswapd+20b/254>
      2 Trace; 401379f3 <wakeup_kswapd+24f/254>
      1 Trace; 40138524 <__alloc_pages+7c/4b8>
      1 Trace; 4013852b <__alloc_pages+83/4b8>

(first column is number of profiling hits, profiling hits taken on all
CPUs.)

unfortunately i havent captured which processes are running. This is an
8-CPU SMP box, 8 write-intensive processes are running, they create new
1k-1MB files in new directories - a total of many gigabytes.

this lockup happens both during vanilla test9-pre5 and with
2.4.0-t9p2-vmpatch. Your patch makes the lockup happen a bit later than
previous, but it still happens. During the lockup all dirty buffers are
written out to disk until it reaches such a state:

2162688 pages of RAM
1343488 pages of HIGHMEM
116116 reserved pages
652826 pages shared
0 pages swap cached
0 pages in page table cache
Buffer memory:    52592kB
    CLEAN: 664 buffers, 2302 kbyte, 5 used (last=93), 0 locked, 0 protected, 0 dirty
   LOCKED: 661752 buffers, 2646711 kbyte, 37 used (last=661397), 0 locked, 0 protected, 0 dirty
    DIRTY: 17 buffers, 26 kbyte, 1 used (last=1), 0 locked, 0 protected, 17 dirty

no disk IO happens anymore, but the lockup persists. The histogram was
taken after all disk IO has stopped.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
