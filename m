Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 65DBD6B0037
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 18:23:35 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id r10so3205633pdi.6
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 15:23:35 -0800 (PST)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id vz4si8335761pac.325.2014.01.16.15.23.33
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 15:23:34 -0800 (PST)
From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [RFC PATCH 0/3] Use cached allocations in place of order-3 allocations for sk_page_frag_refill() and __netdev_alloc_frag()
Date: Thu, 16 Jan 2014 18:17:01 -0500
Message-Id: <1389914224-10453-1-git-send-email-dbanerje@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org
Cc: dbanerje@akamai.com, johunt@akamai.com, jbaron@akamai.com, davem@davemloft.net, linux-mm@kvack.org

This is a hack against 3.10.y to see if using cached allocations works better here. The unintended consequence is in the reference benchmark case, it performs ~7% better than the existing code even with a hacked slower get_page()/put_page(). The intent was to avoid very slow order-3 allocations (and really pathological retries under failure) which can cause lots of problems from OOM killer invocation to direct reclaim/compaction cycles that take up nearly all cpu and end up reaping large amounts of page cache which would have been otherwise useful. This is a regression from the same code that used order-0 allocations since those are easy and fast as they are cached per-cpu, and this code is under very heavy alloc/free behavior. This patch eliminates a majority of that due to slab caching the allocations, though could still be improved by slab holding onto free'd slabs longer; this seems like an unoptimized case when object size == slab size.

vmstat output of bad behavior: http://pastebin.ubuntu.com/6687527/

This patchset could be fixed for submission by either making another pool of cached frag buffers specifically page_frag (not using slab), or by converting the whole stack to not use get_page/put_page() to reference count and free page allocations so that hacking swap.c is not necessary and slab use normal.

Benchmark:
ifconfig lo mtu 16436
perf record ./netperf -t UDP_STREAM ; perf report

With order-0 allocations:

UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost (127.0.0.1) port 0 AF_INET
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

262144   65507   10.00      820758      0    43012.26
262144           10.00      820754           43012.05

# Overhead  Command      Shared Object                                      Symbol
# ........  .......  .................  ..........................................
#
    46.15%  netperf  [kernel.kallsyms]  [k] copy_user_generic_string              
     7.89%  netperf  [kernel.kallsyms]  [k] skb_append_datato_frags               
     6.06%  netperf  [kernel.kallsyms]  [k] get_page_from_freelist                
     3.87%  netperf  [kernel.kallsyms]  [k] __rmqueue                             
     1.36%  netperf  [kernel.kallsyms]  [k] __alloc_pages_nodemask                
     1.11%  netperf  [kernel.kallsyms]  [k] alloc_pages_current                   

linux-3.10.y stock order-3 allocations:

UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost (127.0.0.1) port 0 AF_INET
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   10.00     1054158      0    55243.69
212992           10.00     1019505           53427.68

# Overhead  Command      Shared Object                                      Symbol
# ........  .......  .................  ..........................................
#
    59.80%  netperf  [kernel.kallsyms]  [k] copy_user_generic_string              
     2.35%  netperf  [kernel.kallsyms]  [k] get_page_from_freelist                
     1.95%  netperf  [kernel.kallsyms]  [k] skb_append_datato_frags               
     1.27%  netperf  [ip_tables]        [k] ipt_do_table                          
     1.26%  netperf  [kernel.kallsyms]  [k] udp_sendmsg                           
     1.03%  netperf  [kernel.kallsyms]  [k] enqueue_task_fair                     
     1.00%  netperf  [kernel.kallsyms]  [k] ip_finish_output                              

With this patchset:

UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost (127.0.0.1) port 0 AF_INET
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   10.00     1127089      0    59065.70
212992           10.00     1072997           56230.98


# Overhead  Command      Shared Object                                      Symbol
# ........  .......  .................  ..........................................
#
    69.16%  netperf  [kernel.kallsyms]  [k] copy_user_generic_string
     2.56%  netperf  [kernel.kallsyms]  [k] skb_append_datato_frags
     1.00%  netperf  [ip_tables]        [k] ipt_do_table
     0.96%  netperf  [kernel.kallsyms]  [k] sock_alloc_send_pskb
     0.93%  netperf  [kernel.kallsyms]  [k] _raw_spin_lock



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
