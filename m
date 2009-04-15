Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DA07C5F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 00:12:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3F4CwFB007642
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Apr 2009 13:12:58 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CACFD45DD72
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:12:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F4EF45DD76
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:12:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AA0AE08007
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:12:57 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A10B1DB8014
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:12:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: meminfo Committed_AS underflows
In-Reply-To: <20090415105033.AC29.A69D9226@jp.fujitsu.com>
References: <1239737619.32604.118.camel@nimitz> <20090415105033.AC29.A69D9226@jp.fujitsu.com>
Message-Id: <20090415131009.AC40.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Apr 2009 13:12:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric B Munson <ebmunson@us.ibm.com>, Mel Gorman <mel@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


fix stupid mistake.

Changelog:
	since v1
		- change the type of commited value from ulong to long


=========================
Subject: [PATCH v2] fix Commited_AS underflow

Dave Hansen reported committed_AS field can underfolow.

>         # while true; do cat /proc/meminfo  | grep _AS; sleep 1; done | uniq -c
>               1 Committed_AS: 18446744073709323392 kB
>              11 Committed_AS: 18446744073709455488 kB
>               6 Committed_AS:    35136 kB
>               5 Committed_AS: 18446744073709454400 kB
>               7 Committed_AS:    35904 kB
>               3 Committed_AS: 18446744073709453248 kB
>               2 Committed_AS:    34752 kB
>               9 Committed_AS: 18446744073709453248 kB
>               8 Committed_AS:    34752 kB
>               3 Committed_AS: 18446744073709320960 kB
>               7 Committed_AS: 18446744073709454080 kB
>               3 Committed_AS: 18446744073709320960 kB
>               5 Committed_AS: 18446744073709454080 kB
>               6 Committed_AS: 18446744073709320960 kB

Because NR_CPU can be greater than 1000. and meminfo_proc_show()
doesn't have underflow check.

this patch have two change.

1. Change NR_CPU to nr_online_cpus()
   vm_acct_memory() isn't fast-path. then cpumask_weight() calculation
   isn't so expensive and the parameter for scalability issue should
   consider number of _physical_ cpus. not theoretical maximum number.
2. Add under-flow check to meminfo_proc_show().
   Almost field in /proc/meminfo have underflow check. but Committed_AS
   is significant exeption.
   it should do.

Reported-by: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/meminfo.c |    4 +++-
 mm/swap.c         |    2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

Index: b/fs/proc/meminfo.c
===================================================================
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -22,7 +22,7 @@ void __attribute__((weak)) arch_report_m
 static int meminfo_proc_show(struct seq_file *m, void *v)
 {
 	struct sysinfo i;
-	unsigned long committed;
+	long committed;
 	unsigned long allowed;
 	struct vmalloc_info vmi;
 	long cached;
@@ -36,6 +36,8 @@ static int meminfo_proc_show(struct seq_
 	si_meminfo(&i);
 	si_swapinfo(&i);
 	committed = atomic_long_read(&vm_committed_space);
+	if (committed < 0)
+		committed = 0;
 	allowed = ((totalram_pages - hugetlb_total_pages())
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;
 
Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -519,7 +519,7 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
  * We tolerate a little inaccuracy to avoid ping-ponging the counter between
  * CPUs
  */
-#define ACCT_THRESHOLD	max(16, NR_CPUS * 2)
+#define ACCT_THRESHOLD	max_t(long, 16, num_online_cpus() * 2)
 
 static DEFINE_PER_CPU(long, committed_space);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
