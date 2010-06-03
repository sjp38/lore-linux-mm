Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 555556B0217
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 05:58:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o539wM7H011172
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Jun 2010 18:58:22 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 58A1345DE4E
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 18:58:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 205AC45DE4D
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 18:58:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F084D1DB804C
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 18:58:21 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 80264E18004
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 18:58:21 +0900 (JST)
Date: Thu, 3 Jun 2010 18:54:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/2] memcg: reduce overhead by coalescing css_get/put
Message-Id: <20100603185407.3161e924.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

This is now under development patch (and I can't guarantee this is free from bug.)

The idea is coalescing multiple css_get/put to __css_get(),__css_put() as
we now do in res_counter charging.

Here is a result with multi-threaded page fault program. The program does continuous 
page fault in 60 sec. If the kernel works better, we can see more page faults.

Here is a test result under a memcg(not root cgroup).

[before Patch]
[root@bluextal test]# /root/bin/perf stat -e page-faults,cache-misses ./multi-fault-all-split 8

 Performance counter stats for './multi-fault-all-split 8':

           12357708  page-faults
          161332057  cache-misses

       60.007931275  seconds time elapsed
    25.31%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
     9.24%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
     8.37%  multi-fault-all  [kernel.kallsyms]      [k] try_get_mem_cgroup_from_mm
     5.21%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
     5.13%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
     4.91%  multi-fault-all  [kernel.kallsyms]      [k] __css_put
     4.66%  multi-fault-all  [kernel.kallsyms]      [k] up_read
     3.17%  multi-fault-all  [kernel.kallsyms]      [k] css_put
     2.77%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
     2.58%  multi-fault-all  [kernel.kallsyms]      [k] page_fault

[after Patch]
[root@bluextal test]#  /root/bin/perf stat -e page-faults,cache-misses ./multi-fault-all-split 8

 Performance counter stats for './multi-fault-all-split 8':

           13615258  page-faults
          153207110  cache-misses

       60.004117823  seconds time elapsed

# Overhead          Command          Shared Object  Symbol
# ........  ...............  .....................  ......
#
    27.70%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
    11.18%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
     7.54%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
     5.99%  multi-fault-all  [kernel.kallsyms]      [k] up_read
     5.90%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
     5.13%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
     2.73%  multi-fault-all  [kernel.kallsyms]      [k] __mem_cgroup_commit_charge
     2.71%  multi-fault-all  [kernel.kallsyms]      [k] page_fault
     2.66%  multi-fault-all  [kernel.kallsyms]      [k] handle_mm_fault
     2.35%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock


You can see cache-miss/page-faults is improved and no css_get/css_put in overhead
stat record. Please give me your review if interested.

(I tried to get rid of css_get()/put() per a page ...but..it seems no very easy.
 So, now trying to reduce overheads.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
