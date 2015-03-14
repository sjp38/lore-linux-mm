Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8857D6B007D
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 13:04:53 -0400 (EDT)
Received: by lbbzq9 with SMTP id zq9so8038497lbb.0
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 10:04:52 -0700 (PDT)
Received: from shrek.krogh.cc (188-178-198-210-static.dk.customer.tdc.net. [188.178.198.210])
        by mx.google.com with ESMTPS id qu8si1573570lbb.49.2015.03.14.10.04.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Mar 2015 10:04:51 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by shrek.krogh.cc (Postfix) with ESMTP id 5B5A11F007F8
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 18:06:00 +0100 (CET)
Received: from shrek.krogh.cc ([127.0.0.1])
	by localhost (shrek.krogh.cc [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5IlgPPxRozoc for <linux-mm@kvack.org>;
	Sat, 14 Mar 2015 18:05:51 +0100 (CET)
Received: from shrek.krogh.cc (localhost [IPv6:::1])
	by shrek.krogh.cc (Postfix) with ESMTP id 1660C1F007EA
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 18:05:51 +0100 (CET)
Message-ID: <52ec58f434865829c37337624d124981.squirrel@shrek.krogh.cc>
Date: Sat, 14 Mar 2015 18:05:51 +0100
Subject: High system load and 3TB of memory. 
From: jesper@krogh.cc
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi.

I have a 3.13 (ubuntu LTS) server with 3TB of memory and under certain load
conditions it can spiral off to 80+% system load. Per recommendation on IRC
yesterday I have captured 2 perf reports (I'm new to perf, so I'm not
sure they tell precisely whats needed.

Bad situation (high sysload 80%+)

Samples: 381K of event 'cycles', Event count (approx.): 1228296411165
+  27.84%         postgres  [kernel.kallsyms]     [k] isolate_freepages_block
+  21.08%             psql  [kernel.kallsyms]     [k] isolate_freepages_block
+  20.72%       pg_restore  [kernel.kallsyms]     [k] isolate_freepages_block
+   3.94%         postgres  postgres              [.] pglz_compress
+   2.86%         postgres  [kernel.kallsyms]     [k]
set_pageblock_flags_mask
+   2.35%        bacula-fd  [kernel.kallsyms]     [k] isolate_freepages_block
+   2.07%       pg_restore  [kernel.kallsyms]     [k]
set_pageblock_flags_mask
+   2.06%             psql  [kernel.kallsyms]     [k]
set_pageblock_flags_mask
+   1.56%         postgres  libc-2.15.so          [.] 0x000000000003c95f
+   0.93%       irqbalance  [kernel.kallsyms]     [k] isolate_freepages_block
+   0.88%       pg_restore  [kernel.kallsyms]     [k] isolate_freepages
+   0.87%             psql  [kernel.kallsyms]     [k] isolate_freepages
+   0.86%         postgres  [kernel.kallsyms]     [k] isolate_freepages
+   0.81%         postgres  postgres              [.] 0x000000000027ff5b
+   0.60%         postgres  [kernel.kallsyms]     [k]
get_pageblock_flags_mask
+   0.44%         proc_pri  [kernel.kallsyms]     [k] isolate_freepages_block

Good situation .. sysload < 5%

Samples: 509K of event 'cycles', Event count (approx.): 1635259826919
+  21.14%         postgres  postgres                  [.] pglz_compress
+  14.46%         postgres  postgres                  [.] 0x000000000016b643
+  10.11%         postgres  libc-2.15.so              [.] 0x0000000000092f69
+   5.74%         postgres  postgres                  [.] s_lock
+   2.86%         postgres  postgres                  [.] LWLockAcquire
+   2.51%       pg_restore  [kernel.kallsyms]         [k]
isolate_freepages_block
+   2.33%         postgres  postgres                  [.]
NextCopyFromRawFields
+   2.15%         postgres  postgres                  [.] LWLockRelease
+   2.10%         postgres  postgres                  [.] _start
+   1.93%         postgres  [kernel.kallsyms]         [k]
copy_user_enhanced_fast_string
+   1.70%         postgres  [kernel.kallsyms]         [k] change_pte_range
+   1.61%         postgres  postgres                  [.] pg_verify_mbstr_len
+   1.31%         postgres  postgres                  [.]
hash_search_with_hash_value
+   1.21%         postgres  libc-2.15.so              [.] __strcoll_l
+   0.86%          kswapd0  [kernel.kallsyms]         [k]
__mem_cgroup_uncharge_common
+   0.72%         postgres  postgres                  [.] heap_fill_tuple
+   0.68%        bacula-fd  [kernel.kallsyms]         [k]
isolate_freepages_block
+   0.66%         postgres  [kernel.kallsyms]         [k] clear_page_c_e
+   0.63%       pg_restore  [kernel.kallsyms]         [k]
copy_user_enhanced_fast_string


Hugepages are disabled. All suggestions for configuration changes, etc are
welcome?

IO subsystem is not particulary busy in any of the situations. A sar
output can be seen here:
http://thread.gmane.org/gmane.linux.kernel/1908263

Jesper



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
